#!/bin/bash
set -e

echo "═══════════════════════════════════════════════════"
echo " 🔧 فیکس نهایی App.kt"
echo "═══════════════════════════════════════════════════"

# ═══ ۱. پیدا کردن شروع Kotlin ═══
START=$(grep -n "^package com.mlmvpn.app" PARSAVPN.sh | head -1 | cut -d: -f1)
if [ -z "$START" ]; then
    echo "❌ package پیدا نشد"
    exit 1
fi
echo "🎯 شروع: خط $START"

# ═══ ۲. پیدا کردن پایان با چند نشانه‌گر ═══
END=$(awk -v s="$START" '
    NR > s {
        # نشانه‌های پایان Kotlin
        if (/^KOTLIN_EOF/ || /^X[0-9]+$/ || /^cat >/ || /^cat >>/ || \
            /^echo ""/ || /^echo "═══/ || /^exit 0/ || /^set -e/ || \
            /^ROOT=/ || /^chmod / || /^mkdir -p/) {
            print NR
            exit
        }
    }
' PARSAVPN.sh)

# اگه پیدا نشد → دنبال آخرین } در ستون ۰ بگرد
if [ -z "$END" ]; then
    echo "⚠️ نشانه پایان پیدا نشد، دنبال آخرین } در ستون ۰..."
    END=$(awk -v s="$START" '
        NR > s && /^}$/ { last = NR }
        END { print last + 1 }
    ' PARSAVPN.sh)
fi

[ -z "$END" ] && END=$(wc -l < PARSAVPN.sh)
echo "🎯 پایان: خط $END"

# ═══ ۳. نمایش اطراف خط پایان (برای دیباگ) ═══
echo ""
echo "📋 ۵ خط قبل از پایان:"
sed -n "$((END-5)),$((END-1))p" PARSAVPN.sh | cat -n | sed 's/^/    /'
echo ""
echo "📋 خط پایان و بعدش:"
sed -n "${END},$((END+3))p" PARSAVPN.sh | cat -n | sed 's/^/    /'
echo ""

# ═══ ۴. استخراج ═══
sed -n "${START},$((END-1))p" PARSAVPN.sh > App.kt
LINES=$(wc -l < App.kt)
echo "✅ استخراج شد: $LINES خط"
echo ""

# ═══ ۵. بررسی: آیا خطوط bash داخلش هست؟ ═══
echo "🔍 بررسی خطوط bash داخل Kotlin..."
BASH_LINES=$(grep -cE "^(cat >|echo |X[0-9]+$|ROOT=|chmod |mkdir -p|exit 0|set -e|rem )" App.kt || true)
echo "   تعداد خطوط مشکوک bash: $BASH_LINES"

if [ "$BASH_LINES" -gt 0 ]; then
    echo "   📋 نمونه:"
    grep -nE "^(cat >|echo |X[0-9]+$|ROOT=|chmod |mkdir -p|exit 0|set -e|rem )" App.kt | head -5 | sed 's/^/     /'
fi
echo ""

# ═══ ۶. برش در انتها: حذف هر خط bash باقی‌مانده ═══
echo "🔧 برش انتهایی خطوط bash..."
python3 << 'PYEOF'
import re

with open("App.kt") as f:
    lines = f.readlines()

# پیدا کردن آخرین } در ستون ۰
last_close = -1
for i in range(len(lines) - 1, -1, -1):
    if lines[i].rstrip() == "}":
        last_close = i
        break

if last_close > 0 and last_close < len(lines) - 1:
    print("  ✂️ برش تا خط " + str(last_close + 1))
    lines = lines[:last_close + 1]

# چک نهایی برای bash
final = "".join(lines)
final = re.sub(r'\n{3,}', '\n\n', final)

with open("App.kt", "w") as f:
    f.write(final)

print("  ✅ برش انجام شد")
PYEOF

LINES=$(wc -l < App.kt)
echo "📏 حجم نهایی: $LINES خط"
echo ""

# ═══ ۷. فیکس تایپوها ═══
sed -i 's/^omposable/@Composable/g' App.kt
sed -i 's/^n App(/fun App(/g' App.kt
sed -i 's/else -> return null/else -> null/g' App.kt

# ═══ ۸. اضافه کردن importها ═══
python3 << 'PYEOF'
import re
with open("App.kt") as f:
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
found_pkg = False
for line in lines:
    s = line.strip()
    if s.startswith("package ") and not found_pkg:
        out.append(line)
        out.append("")
        out.append(IMPORTS)
        out.append("")
        found_pkg = True
        continue
    if found_pkg and s.startswith("import "):
        continue
    out.append(line)

final = re.sub(r'\n{3,}', '\n\n', "\n".join(out))
with open("App.kt", "w") as f:
    f.write(final)
print("✅ import اضافه شد")
PYEOF

# جایگزینی App(vm)
if grep -q "fun AppFinal()" App.kt; then
    sed -i 's/App(vm)/AppFinal()/g' App.kt
fi

echo ""
echo "═══════════════════════════════════════════════════"
echo " ✅ آماده شد!"
echo " 📏 حجم: $(wc -l < App.kt) خط"
echo " 📦 import: $(grep -c '^import ' App.kt)"
echo "═══════════════════════════════════════════════════"

exit 0
