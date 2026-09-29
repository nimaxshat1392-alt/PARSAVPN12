#!/bin/bash
set -e

echo "═══════════════════════════════════════════════════"
echo " 🔧 فیکس نهایی (ساده و مطمئن)"
echo "═══════════════════════════════════════════════════"

if [ ! -f "PARSAVPN.sh" ]; then
    echo "❌ PARSAVPN.sh پیدا نشد!"
    exit 1
fi

# ═══ ۱. استخراج Kotlin ═══
START_LINE=$(grep -n "^package com.mlmvpn.app" PARSAVPN.sh | head -1 | cut -d: -f1)
if [ -z "$START_LINE" ]; then
    echo "❌ package پیدا نشد!"
    exit 1
fi

END_LINE=$(awk -v start="$START_LINE" 'NR > start && /^KOTLIN_EOF/ {print NR; exit}' PARSAVPN.sh)
if [ -z "$END_LINE" ]; then
    END_LINE=$(wc -l < PARSAVPN.sh)
fi

sed -n "${START_LINE},$((END_LINE - 1))p" PARSAVPN.sh > App_raw.kt
echo "📦 استخراج: $(wc -l < App_raw.kt) خط"

# ═══ ۲. تبدیل فقط توابع "= try {" ═══
python3 << 'PYEOF'
import re

with open("App_raw.kt") as f:
    content = f.read()

def find_matching_close(text, open_pos):
    """پیدا کردن بسته‌ی متناظر با شمارش عمیق"""
    depth = 1
    i = open_pos + 1
    in_str = False
    in_char = False
    in_comment = False
    in_line_comment = False
    while i < len(text):
        c = text[i]
        prev = text[i-1] if i > 0 else ''
        nxt = text[i+1] if i+1 < len(text) else ''
        
        if in_line_comment:
            if c == '\n':
                in_line_comment = False
        elif in_comment:
            if c == '*' and nxt == '/':
                in_comment = False
                i += 1
        elif in_str:
            if c == '\\':
                i += 1
            elif c == '"':
                in_str = False
        elif in_char:
            if c == '\\':
                i += 1
            elif c == "'":
                in_char = False
        else:
            if c == '/' and nxt == '/':
                in_line_comment = True
                i += 1
            elif c == '/' and nxt == '*':
                in_comment = True
                i += 1
            elif c == '"':
                in_str = True
            elif c == "'":
                in_char = True
            elif c == '{':
                depth += 1
            elif c == '}':
                depth -= 1
                if depth == 0:
                    return i
        i += 1
    return -1

# الگو: تابع با expression body "= try {"  فقط
pattern = re.compile(
    r'^(\s*)'                                   # indent
    r'((?:(?:public|private|internal|protected)\s+)?'
    r'(?:override\s+)?(?:suspend\s+)?fun\s+\w+\s*\([^)]*\)\s*'
    r'(?::\s*[^={]+?)?)'                        # signature
    r'\s*=\s*try\s*\{',                         # = try {
    re.MULTILINE
)

# از انتها به ابتدا پردازش کن که ایندکس‌ها جابجا نشه
matches = list(pattern.finditer(content))
print("📋 " + str(len(matches)) + " تابع با '= try {' پیدا شد")

for m in reversed(matches):
    sig_end = m.end() - 1  # موقعیت '{' شروع
    close_pos = find_matching_close(content, sig_end)
    
    if close_pos < 0:
        print("  ⚠️ نتونستم بسته رو پیدا کنم")
        continue
    
    indent = m.group(1)
    signature = m.group(2).rstrip()
    
    # محتوای داخلی try
    inner = content[sig_end + 1:close_pos]
    
    # ساختار جدید:
    # fun foo(): Type {
    #     return try {
    #         ...inner...
    #     }
    # }
    
    new_func = (
        indent + signature + " {\n" +
        indent + "    return try {" +
        inner +
        "}\n" +
        indent + "}"
    )
    
    # جایگزینی
    content = content[:m.start()] + new_func + content[close_pos + 1:]
    print("  ✓ " + signature[:60])

with open("App_raw.kt", "w") as f:
    f.write(content)

print("✅ تبدیل کامل شد")
PYEOF

# ═══ ۳. فیکس تایپوها ═══
sed -i 's/^omposable/@Composable/g' App_raw.kt
sed -i 's/^n App(/fun App(/g' App_raw.kt

# ═══ ۴. اضافه کردن importها ═══
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

pkg_match = re.search(r'^package\s+com\.mlmvpn\.app\s*$', content, re.MULTILINE)
if not pkg_match:
    print("❌ package پیدا نشد")
    exit(1)

lines = content.split("\n")
new_lines = []
found_pkg = False

for line in lines:
    stripped = line.strip()
    if stripped.startswith("package "):
        found_pkg = True
        new_lines.append(line)
        new_lines.append("")
        new_lines.append(IMPORTS)
        new_lines.append("")
        continue
    if found_pkg and stripped.startswith("import "):
        continue
    new_lines.append(line)

final = "\n".join(new_lines)
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

rm -f App_raw.kt
exit 0
