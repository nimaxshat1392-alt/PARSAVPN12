#!/bin/bash
set -e

echo "═══════════════════════════════════════════════════"
echo " 🔧 فیکس قطعی App.kt"
echo "═══════════════════════════════════════════════════"

if [ ! -f "PARSAVPN.sh" ]; then
    echo "❌ PARSAVPN.sh پیدا نشد!"
    exit 1
fi

# ═══ استخراج ═══
START=$(grep -n "^package com.mlmvpn.app" PARSAVPN.sh | head -1 | cut -d: -f1)
if [ -z "$START" ]; then
    echo "❌ package پیدا نشد"
    exit 1
fi

END=$(awk -v s="$START" 'NR > s && /^KOTLIN_EOF/ {print NR; exit}' PARSAVPN.sh)
if [ -z "$END" ]; then
    END=$(wc -l < PARSAVPN.sh)
fi

sed -n "${START},$((END-1))p" PARSAVPN.sh > App_raw.kt
echo "📦 استخراج: $(wc -l < App_raw.kt) خط"
echo ""

# ═══ تبدیل توابع = try { ═══
python3 << 'PYEOF'
import re

with open("App_raw.kt") as f:
    content = f.read()

def find_close_brace(text, open_pos):
    """پیدا کردن بسته براکت با شمارش دقیق (نادیده گرفتن string/comment)"""
    depth = 0
    i = open_pos
    n = len(text)
    while i < n:
        c = text[i]
        # String با سه کوتیشن
        if c == '"' and i+2 < n and text[i:i+3] == '"""':
            i += 3
            while i+2 < n and text[i:i+3] != '"""':
                i += 1
            i += 3
            continue
        # String معمولی
        if c == '"':
            i += 1
            while i < n and text[i] != '"':
                if text[i] == '\\':
                    i += 1
                i += 1
            i += 1
            continue
        # Char
        if c == "'":
            i += 1
            while i < n and text[i] != "'":
                if text[i] == '\\':
                    i += 1
                i += 1
            i += 1
            continue
        # Line comment
        if c == '/' and i+1 < n and text[i+1] == '/':
            while i < n and text[i] != '\n':
                i += 1
            continue
        # Block comment
        if c == '/' and i+1 < n and text[i+1] == '*':
            i += 2
            while i+1 < n and not (text[i] == '*' and text[i+1] == '/'):
                i += 1
            i += 2
            continue
        # Brace counting
        if c == '{':
            depth += 1
        elif c == '}':
            depth -= 1
            if depth == 0:
                return i
        i += 1
    return -1

# پیدا کردن توابع "fun ... = try {"
pattern = re.compile(
    r'(?m)^([ \t]*)'
    r'((?:(?:public|private|internal|protected)\s+)?'
    r'(?:override\s+)?(?:suspend\s+)?fun\s+\w+\s*\([^)]*\)\s*'
    r'(?::\s*[^={\n]+?)?)'
    r'\s*=\s*try\s*\{'
)

matches = list(pattern.finditer(content))
print("📋 " + str(len(matches)) + " تابع با '= try {' پیدا شد")
print("")

# از انتها به ابتدا پردازش کن (چون ایندکس‌ها جابجا می‌شن)
for m in reversed(matches):
    indent = m.group(1)
    signature = m.group(2).rstrip()
    open_brace = m.end() - 1  # موقعیت { در "= try {"
    
    # پیدا کردن بسته try
    try_close = find_close_brace(content, open_brace)
    if try_close < 0:
        print("  ⚠️ نتونستم بسته try رو پیدا کنم")
        continue
    
    # بررسی catch/finally بعدش
    cursor = try_close + 1
    while cursor < len(content) and content[cursor] in ' \t\n\r':
        cursor += 1
    
    # اگه catch/finally هست
    while cursor < len(content):
        rest = content[cursor:cursor+20]
        if rest.startswith('catch') or rest.startswith('finally'):
            # پیدا کردن { بعدی
            brace = content.find('{', cursor)
            if brace < 0:
                break
            brace_close = find_close_brace(content, brace)
            if brace_close < 0:
                break
            try_close = brace_close
            cursor = brace_close + 1
            while cursor < len(content) and content[cursor] in ' \t\n\r':
                cursor += 1
        else:
            break
    
    # حالا محدوده کامل try-catch-finally مشخص است
    # try_start: از موقعیت 't' در try شروع می‌شه
    try_start = m.end() - 4  # موقعیت t در try (بعد از "= ")
    # دوباره چک کن
    if content[try_start:try_start+3] != 'try':
        try_start = m.end() - 4
        for offset in range(1, 10):
            if content[m.end()-offset:m.end()-offset+3] == 'try':
                try_start = m.end() - offset
                break
    
    inner_expr = content[try_start:try_close+1]
    
    # ساخت تابع جدید:
    # fun foo(): Type {
    #     return try { ... } catch { ... }
    # }
    new_func = (
        indent + signature + " {\n"
        + indent + "    return " + inner_expr + "\n"
        + indent + "}"
    )
    
    # جایگزینی
    content = content[:m.start()] + new_func + content[try_close+1:]
    
    print("  ✓ " + signature[:65])

with open("App_raw.kt", "w") as f:
    f.write(content)

print("")
print("✅ تبدیل کامل شد")
PYEOF

# ═══ فیکس تایپوها ═══
sed -i 's/^omposable/@Composable/g' App_raw.kt
sed -i 's/^n App(/fun App(/g' App_raw.kt

# ═══ اضافه کردن importها ═══
python3 << 'PYEOF'
import re
with open("App_raw.kt") as f:
    content = f.read()

IMPORTS = """import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.SharedPreferences
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.net.ConnectivityManager
import android.net.TrafficStats
import android.net.VpnService
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.ParcelFileDescriptor
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.provider.Settings
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService
import android.util.Base64
import android.util.Log
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.spring
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Dns
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.LockOpen
import androidx.compose.material.icons.filled.PieChart
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.filled.SearchOff
import androidx.compose.material.icons.filled.Security
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.filled.Speed
import androidx.compose.material.icons.filled.Star
import androidx.compose.material.icons.filled.Sync
import androidx.compose.material.icons.outlined.StarBorder
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Checkbox
import androidx.compose.material3.CheckboxDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Divider
import androidx.compose.material3.FilterChip
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.ScrollableTabRow
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.material3.Tab
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.blur
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.StrokeJoin
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.cancel
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import kotlinx.coroutines.withTimeoutOrNull
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.sync.Semaphore
import kotlinx.coroutines.sync.withPermit
import com.google.gson.Gson
import com.google.gson.JsonArray
import com.google.gson.JsonObject
import com.google.gson.JsonParser
import com.google.gson.reflect.TypeToken
import java.net.InetSocketAddress
import java.net.URI
import java.net.URLDecoder
import java.util.UUID
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicInteger"""

pkg = re.search(r'^package\s+com\.mlmvpn\.app\s*$', content, re.MULTILINE)
if not pkg:
    print("❌ package پیدا نشد")
    exit(1)

lines = content.split("\n")
out = []
done = False
for line in lines:
    s = line.strip()
    if s.startswith("package "):
        out.append(line)
        out.append("")
        out.append(IMPORTS)
        out.append("")
        done = True
        continue
    if done and s.startswith("import "):
        continue
    out.append(line)

final = "\n".join(out)
final = re.sub(r'\n{3,}', '\n\n', final)

with open("App.kt", "w") as f:
    f.write(final)

print("✅ importها اضافه شد")
PYEOF

echo ""
echo "═══════════════════════════════════════════════════"
echo " ✅ App.kt آماده شد!"
echo "═══════════════════════════════════════════════════"
echo " 📏 حجم: $(wc -l < App.kt) خط"
echo " 📦 import: $(grep -c '^import ' App.kt)"
echo "═══════════════════════════════════════════════════"

# حذف فایل‌های موقت
rm -f App_raw.kt
exit 0
