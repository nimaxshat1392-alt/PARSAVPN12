#!/bin/bash
# ═══════════════════════════════════════════════════════════════
#  fix_app.sh — استخراج + اضافه‌کردن همه importها
# ═══════════════════════════════════════════════════════════════

set -e

echo "═══════════════════════════════════════════════════"
echo " 🔧 فیکس نهایی App.kt"
echo "═══════════════════════════════════════════════════"

# ═══════════════════════════════════════════════════════════════
#  ۱. استخراج کد Kotlin از PARSAVPN.sh
# ═══════════════════════════════════════════════════════════════

python3 << 'PYEOF'
import re

with open("PARSAVPN.sh", "r", encoding="utf-8") as f:
    content = f.read()

# پیدا کردن all heredoc ها با KOTLIN_EOF
parts = re.findall(r"<< 'KOTLIN_EOF'\n(.*?)\nKOTLIN_EOF", content, re.DOTALL)

if parts:
    kotlin = "\n\n".join(parts)
    print(f"📦 {len(parts)} بخش heredoc پیدا شد")
else:
    # پیدا کردن کل کد Kotlin از اول فایل
    pkg_idx = content.find("package com.mlmvpn.app")
    if pkg_idx == -1:
        print("❌ هیچ کد Kotlin پیدا نشد")
        exit(1)
    kotlin = content[pkg_idx:]

# حذف خطوط bash باقی‌مانده
lines = kotlin.split("\n")
cleaned = []
skip_next = False
for line in lines:
    stripped = line.strip()
    if re.match(r'^X\d+$', stripped):
        continue
    if stripped in ("KOTLIN_EOF", "EOF"):
        continue
    if re.match(r'^(cat >|cat >>|chmod |mkdir |rm |mv |cp |echo |printf |exit |sleep |curl |wget |git |set -|local |function )', stripped):
        continue
    if re.match(r'^[A-Z_]+=', stripped):
        continue
    if stripped.startswith("#!/"):
        continue
    cleaned.append(line)

kotlin = "\n".join(cleaned)
kotlin = re.sub(r'\n{3,}', '\n\n', kotlin)

# پیدا کردن انتهای کد (آخرین })
# حذف هر چیز اضافی در انتها
last_brace = kotlin.rfind("}")
if last_brace > 0:
    kotlin = kotlin[:last_brace+1]

with open("App_raw.kt", "w", encoding="utf-8") as f:
    f.write(kotlin)

print(f"📏 حجم خام: {len(kotlin.splitlines())} خط")
PYEOF

# ═══════════════════════════════════════════════════════════════
#  ۲. اضافه‌کردن تمام importها
# ═══════════════════════════════════════════════════════════════

python3 << 'PYEOF'
import re

with open("App_raw.kt", "r", encoding="utf-8") as f:
    content = f.read()

# ═══ همه importهای لازم ═══
ALL_IMPORTS = [
    # Android Base
    "android.app.Activity",
    "android.app.Notification",
    "android.app.NotificationChannel",
    "android.app.NotificationManager",
    "android.app.PendingIntent",
    "android.content.BroadcastReceiver",
    "android.content.ClipData",
    "android.content.ClipboardManager",
    "android.content.Context",
    "android.content.Intent",
    "android.content.IntentFilter",
    "android.content.SharedPreferences",
    "android.content.pm.ApplicationInfo",
    "android.content.pm.PackageManager",
    "android.net.ConnectivityManager",
    "android.net.Network",
    "android.net.NetworkCallback",
    "android.net.TrafficStats",
    "android.net.Uri",
    "android.net.VpnService",
    "android.os.Build",
    "android.os.Bundle",
    "android.os.Handler",
    "android.os.IBinder",
    "android.os.Looper",
    "android.os.ParcelFileDescriptor",
    "android.os.VibrationEffect",
    "android.os.Vibrator",
    "android.os.VibratorManager",
    "android.provider.Settings",
    "android.service.quicksettings.Tile",
    "android.service.quicksettings.TileService",
    "android.util.Base64",
    "android.util.Log",
    "android.widget.Toast",

    # Compose
    "androidx.activity.ComponentActivity",
    "androidx.activity.compose.setContent",
    "androidx.activity.result.contract.ActivityResultContracts",
    "androidx.compose.animation.core.Animatable",
    "androidx.compose.animation.core.FastOutSlowInEasing",
    "androidx.compose.animation.core.LinearEasing",
    "androidx.compose.animation.core.RepeatMode",
    "androidx.compose.animation.core.Spring",
    "androidx.compose.animation.core.animateDpAsState",
    "androidx.compose.animation.core.animateFloat",
    "androidx.compose.animation.core.animateFloatAsState",
    "androidx.compose.animation.core.infiniteRepeatable",
    "androidx.compose.animation.core.rememberInfiniteTransition",
    "androidx.compose.animation.core.spring",
    "androidx.compose.animation.core.tween",
    "androidx.compose.foundation.Canvas",
    "androidx.compose.foundation.background",
    "androidx.compose.foundation.border",
    "androidx.compose.foundation.clickable",
    "androidx.compose.foundation.combinedClickable",
    "androidx.compose.foundation.ExperimentalFoundationApi",
    "androidx.compose.foundation.Image",
    "androidx.compose.foundation.layout.Arrangement",
    "androidx.compose.foundation.layout.Box",
    "androidx.compose.foundation.layout.Column",
    "androidx.compose.foundation.layout.ColumnScope",
    "androidx.compose.foundation.layout.PaddingValues",
    "androidx.compose.foundation.layout.Row",
    "androidx.compose.foundation.layout.Spacer",
    "androidx.compose.foundation.layout.fillMaxSize",
    "androidx.compose.foundation.layout.fillMaxWidth",
    "androidx.compose.foundation.layout.height",
    "androidx.compose.foundation.layout.offset",
    "androidx.compose.foundation.layout.padding",
    "androidx.compose.foundation.layout.size",
    "androidx.compose.foundation.layout.width",
    "androidx.compose.foundation.layout.widthIn",
    "androidx.compose.foundation.lazy.LazyColumn",
    "androidx.compose.foundation.lazy.items",
    "androidx.compose.foundation.rememberScrollState",
    "androidx.compose.foundation.shape.CircleShape",
    "androidx.compose.foundation.shape.RoundedCornerShape",
    "androidx.compose.foundation.verticalScroll",
    "androidx.compose.material.icons.Icons",
    "androidx.compose.material.icons.filled.ArrowBack",
    "androidx.compose.material.icons.filled.CheckCircle",
    "androidx.compose.material.icons.filled.Close",
    "androidx.compose.material.icons.filled.Delete",
    "androidx.compose.material.icons.filled.Dns",
    "androidx.compose.material.icons.filled.Info",
    "androidx.compose.material.icons.filled.Lock",
    "androidx.compose.material.icons.filled.LockOpen",
    "androidx.compose.material.icons.filled.PieChart",
    "androidx.compose.material.icons.filled.Refresh",
    "androidx.compose.material.icons.filled.Search",
    "androidx.compose.material.icons.filled.SearchOff",
    "androidx.compose.material.icons.filled.Security",
    "androidx.compose.material.icons.filled.Settings",
    "androidx.compose.material.icons.filled.Speed",
    "androidx.compose.material.icons.filled.Star",
    "androidx.compose.material.icons.filled.Sync",
    "androidx.compose.material.icons.outlined.StarBorder",
    "androidx.compose.material3.Button",
    "androidx.compose.material3.ButtonDefaults",
    "androidx.compose.material3.Card",
    "androidx.compose.material3.CardDefaults",
    "androidx.compose.material3.Checkbox",
    "androidx.compose.material3.CheckboxDefaults",
    "androidx.compose.material3.CircularProgressIndicator",
    "androidx.compose.material3.Divider",
    "androidx.compose.material3.FilterChip",
    "androidx.compose.material3.Icon",
    "androidx.compose.material3.IconButton",
    "androidx.compose.material3.MaterialTheme",
    "androidx.compose.material3.OutlinedButton",
    "androidx.compose.material3.OutlinedTextField",
    "androidx.compose.material3.OutlinedTextFieldDefaults",
    "androidx.compose.material3.ScrollableTabRow",
    "androidx.compose.material3.Switch",
    "androidx.compose.material3.SwitchDefaults",
    "androidx.compose.material3.Tab",
    "androidx.compose.material3.Text",
    "androidx.compose.material3.TextButton",
    "androidx.compose.material3.darkColorScheme",
    "androidx.compose.runtime.Composable",
    "androidx.compose.runtime.DisposableEffect",
    "androidx.compose.runtime.LaunchedEffect",
    "androidx.compose.runtime.collectAsState",
    "androidx.compose.runtime.getValue",
    "androidx.compose.runtime.mutableStateListOf",
    "androidx.compose.runtime.mutableStateOf",
    "androidx.compose.runtime.remember",
    "androidx.compose.runtime.rememberCoroutineScope",
    "androidx.compose.runtime.setValue",
    "androidx.compose.ui.Alignment",
    "androidx.compose.ui.Modifier",
    "androidx.compose.ui.draw.blur",
    "androidx.compose.ui.draw.clip",
    "androidx.compose.ui.draw.rotate",
    "androidx.compose.ui.geometry.Offset",
    "androidx.compose.ui.geometry.Size",
    "androidx.compose.ui.graphics.Brush",
    "androidx.compose.ui.graphics.Color",
    "androidx.compose.ui.graphics.Path",
    "androidx.compose.ui.graphics.StrokeCap",
    "androidx.compose.ui.graphics.StrokeJoin",
    "androidx.compose.ui.graphics.asImageBitmap",
    "androidx.compose.ui.graphics.drawscope.Stroke",
    "androidx.compose.ui.graphics.graphicsLayer",
    "androidx.compose.ui.graphics.vector.ImageVector",
    "androidx.compose.ui.hapticfeedback.HapticFeedbackType",
    "androidx.compose.ui.platform.LocalContext",
    "androidx.compose.ui.platform.LocalHapticFeedback",
    "androidx.compose.ui.text.TextStyle",
    "androidx.compose.ui.text.font.FontFamily",
    "androidx.compose.ui.text.font.FontWeight",
    "androidx.compose.ui.text.input.PasswordVisualTransformation",
    "androidx.compose.ui.text.style.TextAlign",
    "androidx.compose.ui.text.style.TextOverflow",
    "androidx.compose.ui.unit.Dp",
    "androidx.compose.ui.unit.dp",
    "androidx.compose.ui.unit.sp",

    # Lifecycle
    "androidx.lifecycle.ViewModel",
    "androidx.lifecycle.viewModelScope",
    "androidx.lifecycle.viewmodel.compose.viewModel",

    # Security
    "androidx.security.crypto.EncryptedSharedPreferences",
    "androidx.security.crypto.MasterKey",

    # Coroutines
    "kotlinx.coroutines.CoroutineScope",
    "kotlinx.coroutines.Dispatchers",
    "kotlinx.coroutines.Job",
    "kotlinx.coroutines.SupervisorJob",
    "kotlinx.coroutines.async",
    "kotlinx.coroutines.awaitAll",
    "kotlinx.coroutines.cancel",
    "kotlinx.coroutines.coroutineScope",
    "kotlinx.coroutines.delay",
    "kotlinx.coroutines.isActive",
    "kotlinx.coroutines.launch",
    "kotlinx.coroutines.withContext",
    "kotlinx.coroutines.withTimeoutOrNull",
    "kotlinx.coroutines.flow.MutableStateFlow",
    "kotlinx.coroutines.flow.StateFlow",
    "kotlinx.coroutines.flow.asStateFlow",
    "kotlinx.coroutines.sync.Semaphore",
    "kotlinx.coroutines.sync.withPermit",

    # Gson
    "com.google.gson.Gson",
    "com.google.gson.JsonArray",
    "com.google.gson.JsonObject",
    "com.google.gson.JsonParser",
    "com.google.gson.reflect.TypeToken",

    # OkHttp
    "okhttp3.OkHttpClient",
    "okhttp3.Request",

    # Java
    "java.net.InetSocketAddress",
    "java.net.URI",
    "java.net.URLDecoder",
    "java.util.UUID",
    "java.util.concurrent.TimeUnit",
    "java.util.concurrent.atomic.AtomicInteger",
]

# ═══ ساخت هدر import ═══
import_block = "\n".join(f"import {imp}" for imp in ALL_IMPORTS)

# ═══ پیدا کردن خط package ═══
pkg_match = re.search(r'^package\s+com\.mlmvpn\.app\s*$', content, re.MULTILINE)

if not pkg_match:
    print("❌ خط package پیدا نشد")
    exit(1)

pkg_line = pkg_match.group(0)

# ═══ حذف importهای قدیمی موجود ═══
lines = content.split("\n")
new_lines = []
after_pkg = False
skip_imports = False

for line in lines:
    stripped = line.strip()
    
    if stripped == pkg_line.strip():
        new_lines.append(line)
        after_pkg = True
        # اضافه کردن importهای جدید بعد از package
        new_lines.append("")
        new_lines.append(import_block)
        new_lines.append("")
        skip_imports = True
        continue
    
    # رد کردن importهای قدیمی
    if skip_imports and stripped.startswith("import "):
        continue
    
    # پایان رد کردن importها
    if skip_imports and stripped and not stripped.startswith("import ") and not stripped.startswith("//") and not stripped.startswith("/*"):
        skip_imports = False
    
    if skip_imports and stripped.startswith("//"):
        # کامنت‌های بین importها رو نگه دار
        continue
    
    new_lines.append(line)

final = "\n".join(new_lines)

# ═══ پاک‌سازی ═══
final = re.sub(r'\n{3,}', '\n\n', final)

# ═══ اطمینان از بسته شدن درست فایل ═══
# حذف خطوط اضافی بعد از آخرین }
last_brace = final.rfind("}")
if last_brace > 0:
    trailing = final[last_brace+1:].strip()
    if trailing:
        final = final[:last_brace+1] + "\n"

with open("App.kt", "w", encoding="utf-8") as f:
    f.write(final)

print(f"✅ {len(ALL_IMPORTS)} import اضافه شد")
print(f"📏 حجم نهایی: {len(final.splitlines())} خط")
PYEOF

# ═══════════════════════════════════════════════════════════════
#  ۳. فیکس تایپوها
# ═══════════════════════════════════════════════════════════════

echo "🔧 فیکس تایپوها..."

sed -i 's/^omposable/@Composable/g' App.kt
sed -i 's/^n App(/fun App(/g' App.kt
sed -i 's/^n \([A-Z][a-zA-Z]*\)(/fun \1(/g' App.kt

# جایگزینی App(vm) → AppFinal()
if grep -q "fun AppFinal()" App.kt; then
    sed -i 's/App(vm)/AppFinal()/g' App.kt
fi

# ═══════════════════════════════════════════════════════════════
#  ۴. گزارش نهایی
# ═══════════════════════════════════════════════════════════════

echo ""
echo "═══════════════════════════════════════════════════"
echo " ✅ App.kt آماده شد!"
echo "═══════════════════════════════════════════════════"
echo " 📏 حجم: $(wc -l < App.kt) خط"
echo " 📦 importها: $(grep -c '^import ' App.kt)"
echo " 🎨 Composables: $(grep -c '@Composable' App.kt)"
echo " 🏛️ کلاس‌ها: $(grep -c '^class \|^object \|^data class \|^enum class ' App.kt)"
echo " 🎯 توابع: $(grep -c '^fun ' App.kt)"
echo "═══════════════════════════════════════════════════"
echo ""
echo "📋 ۱۰ خط اول:"
head -10 App.kt
echo ""
echo "📋 ۵ خط آخر:"
tail -5 App.kt
echo ""

# حذف فایل کمکی
rm -f App_raw.kt

exit 0
