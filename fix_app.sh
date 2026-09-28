#!/bin/bash
# ═══════════════════════════════════════════════════════════════
#  fix_app.sh — فیکس خودکار App.kt
#  این اسکریپت خودش فایل .kt رو در ریشه ریپو پیدا می‌کند
# ═══════════════════════════════════════════════════════════════

set -e

# ═══════════════════════════════════════════════════════════════
#  مرحله ۱: پیدا کردن فایل .kt در ریشه ریپو
# ═══════════════════════════════════════════════════════════════

echo "🔍 جستجوی فایل .kt در ریشه ریپو..."
echo ""

# لیست فایل‌های .kt
KT_FILES=$(find . -maxdepth 2 -name "*.kt" -type f 2>/dev/null | grep -v "/app/" || true)

if [ -z "$KT_FILES" ]; then
    echo "❌ هیچ فایل .kt در ریشه ریپو پیدا نشد!"
    echo ""
    echo "📁 محتوای ریشه ریپو:"
    ls -la
    echo ""
    echo "⚠️ لطفاً یک فایل .kt در ریشه ریپو بساز."
    exit 1
fi

echo "📄 فایل‌های .kt پیدا شده:"
echo "$KT_FILES"
echo ""

# اگر چند فایل بود، بزرگ‌ترین را انتخاب کن
APP=$(echo "$KT_FILES" | xargs ls -S 2>/dev/null | head -1)
echo "✅ انتخاب شد: $APP"
echo ""

# ═══════════════════════════════════════════════════════════════
#  مرحله ۲: بررسی محتوا
# ═══════════════════════════════════════════════════════════════

LINES=$(wc -l < "$APP")
echo "📝 حجم فایل: $LINES خط"

if [ "$LINES" -lt 100 ]; then
    echo "⚠️ فایل خیلی کوتاه است — احتمالاً اشتباه است"
fi

# بررسی اینکه کد اصلی است (شامل VpnConfig)
if ! grep -q "data class VpnConfig" "$APP"; then
    echo "⚠️ این فایل شامل کد اصلی PARSA VPN نیست!"
    echo "   به دنبال فایلی می‌گردم که 'VpnConfig' داشته باشد..."
    
    FOUND=0
    for f in $KT_FILES; do
        if grep -q "data class VpnConfig" "$f"; then
            APP="$f"
            FOUND=1
            echo "✅ پیدا شد: $APP"
            break
        fi
    done
    
    if [ $FOUND -eq 0 ]; then
        echo "❌ فایل حاوی کد اصلی PARSA VPN پیدا نشد!"
        exit 1
    fi
fi

# تغییر نام به App.kt اگر اسم دیگری دارد
if [ "$APP" != "./App.kt" ] && [ "$APP" != "App.kt" ]; then
    echo "🔄 تغییر نام $APP → App.kt"
    mv "$APP" App.kt
    APP="App.kt"
fi

echo ""
echo "✅ فایل هدف: $APP"
echo ""

# ═══════════════════════════════════════════════════════════════
#  ۱. فیکس تایپوهای رایج
# ═══════════════════════════════════════════════════════════════

echo "🔧 فیکس تایپوها..."

# فیکس omposable → @Composable
sed -i 's/^omposable/@Composable/g' "$APP"

# فیکس n App( → fun App(
sed -i 's/^n App(/fun App(/g' "$APP"

# فیکس n HomeFinal( → fun HomeFinal(
sed -i 's/^n \([A-Z][a-zA-Z]*\)(/fun \1(/g' "$APP"

# ═══════════════════════════════════════════════════════════════
#  ۲. اضافه کردن importهای مورد نیاز
# ═══════════════════════════════════════════════════════════════

add_import_if_missing() {
    local import_line="$1"
    if ! grep -q "^import $import_line$" "$APP"; then
        local last_import_line=$(grep -n "^import " "$APP" | tail -1 | cut -d: -f1)
        if [ -n "$last_import_line" ]; then
            sed -i "${last_import_line}a import $import_line" "$APP"
        fi
    fi
}

echo "🔧 افزودن importهای مورد نیاز..."

# Compose foundation
add_import_if_missing "androidx.compose.foundation.border"
add_import_if_missing "androidx.compose.foundation.combinedClickable"
add_import_if_missing "androidx.compose.foundation.ExperimentalFoundationApi"
add_import_if_missing "androidx.compose.foundation.layout.ColumnScope"

# Compose animation
add_import_if_missing "androidx.compose.animation.core.Animatable"

# Compose graphics
add_import_if_missing "androidx.compose.ui.graphics.graphicsLayer"
add_import_if_missing "androidx.compose.ui.graphics.asImageBitmap"
add_import_if_missing "androidx.compose.ui.draw.blur"
add_import_if_missing "androidx.compose.ui.draw.rotate"

# Compose text
add_import_if_missing "androidx.compose.ui.text.style.TextOverflow"
add_import_if_missing "androidx.compose.ui.text.style.TextAlign"

# Material icons
add_import_if_missing "androidx.compose.material.icons.filled.Close"
add_import_if_missing "androidx.compose.material.icons.filled.Dns"
add_import_if_missing "androidx.compose.material.icons.filled.Lock"
add_import_if_missing "androidx.compose.material.icons.filled.LockOpen"
add_import_if_missing "androidx.compose.material.icons.filled.PieChart"
add_import_if_missing "androidx.compose.material.icons.filled.Refresh"
add_import_if_missing "androidx.compose.material.icons.filled.Search"
add_import_if_missing "androidx.compose.material.icons.filled.SearchOff"
add_import_if_missing "androidx.compose.material.icons.filled.Security"
add_import_if_missing "androidx.compose.material.icons.filled.Settings"
add_import_if_missing "androidx.compose.material.icons.filled.Speed"
add_import_if_missing "androidx.compose.material.icons.filled.Star"
add_import_if_missing "androidx.compose.material.icons.filled.Sync"
add_import_if_missing "androidx.compose.material.icons.filled.CheckCircle"
add_import_if_missing "androidx.compose.material.icons.filled.Info"
add_import_if_missing "androidx.compose.material.icons.filled.ArrowBack"
add_import_if_missing "androidx.compose.material.icons.filled.Delete"
add_import_if_missing "androidx.compose.material.icons.outlined.StarBorder"

# Material3
add_import_if_missing "androidx.compose.material3.FilterChip"
add_import_if_missing "androidx.compose.material3.OutlinedTextFieldDefaults"
add_import_if_missing "androidx.compose.material3.ScrollableTabRow"
add_import_if_missing "androidx.compose.material3.Switch"
add_import_if_missing "androidx.compose.material3.SwitchDefaults"
add_import_if_missing "androidx.compose.material3.Tab"
add_import_if_missing "androidx.compose.material3.Checkbox"
add_import_if_missing "androidx.compose.material3.CheckboxDefaults"

# Android
add_import_if_missing "android.widget.Toast"
add_import_if_missing "android.content.Context"
add_import_if_missing "androidx.compose.ui.platform.LocalContext"
add_import_if_missing "androidx.activity.result.contract.ActivityResultContracts"
add_import_if_missing "androidx.compose.ui.platform.LocalHapticFeedback"
add_import_if_missing "androidx.compose.ui.hapticfeedback.HapticFeedbackType"

echo "✅ importها اضافه شدند"

# ═══════════════════════════════════════════════════════════════
#  ۳. اطمینان از import LibXray
# ═══════════════════════════════════════════════════════════════

echo "🔧 بررسی import LibXray..."

if grep -q "RealXrayCore\|RealPingEngine\|RealVpnService" "$APP"; then
    if ! grep -q "^import libXray" "$APP"; then
        # اضافه کردن import LibXray
        python3 << 'PYEOF'
with open("App.kt", "r", encoding="utf-8") as f:
    content = f.read()

if "import libXray.LibXray" not in content and "import libXray.Libv2ray" not in content:
    lines = content.split("\n")
    for i, line in enumerate(lines):
        if line.startswith("import "):
            lines.insert(i, "import libXray.LibXray")
            break
    content = "\n".join(lines)

with open("App.kt", "w", encoding="utf-8") as f:
    f.write(content)
PYEOF
        echo "  ➕ import libXray.LibXray اضافه شد"
    fi
fi

# ═══════════════════════════════════════════════════════════════
#  ۴. حذف importهای تکراری
# ═══════════════════════════════════════════════════════════════

echo "🧹 حذف importهای تکراری..."

python3 << 'PYEOF'
with open("App.kt", "r", encoding="utf-8") as f:
    lines = f.readlines()

seen = set()
output = []
for line in lines:
    stripped = line.strip()
    if stripped.startswith("import "):
        if stripped in seen:
            continue
        seen.add(stripped)
    output.append(line)

with open("App.kt", "w", encoding="utf-8") as f:
    f.writelines(output)
PYEOF

# ═══════════════════════════════════════════════════════════════
#  ۵. اطمینان از AppFinal
# ═══════════════════════════════════════════════════════════════

if ! grep -q "fun AppFinal()" "$APP"; then
    echo "⚠️ تابع AppFinal در فایل نیست — از App استفاده می‌کنیم"
    if ! grep -q "fun App(" "$APP"; then
        echo "❌ نه AppFinal نه App — فایل ناقص است!"
        exit 1
    fi
else
    echo "✅ AppFinal پیدا شد"
    
    # جایگزینی App(vm) با AppFinal()
    sed -i 's/App(vm)/AppFinal()/g' "$APP"
    echo "✅ App(vm) → AppFinal()"
fi

# ═══════════════════════════════════════════════════════════════
#  ۶. بررسی توابع کلیدی
# ═══════════════════════════════════════════════════════════════

echo "🔍 بررسی توابع کلیدی..."

REQUIRED_FUNCS=(
    "VpnConfig"
    "ConnState"
    "DefaultConfigs"
    "ConfigManager"
    "XrayBuilder"
    "PingEngine"
    "RealXrayCore"
    "RealVpnService"
    "CoreVpnService"
    "RealPingEngine"
    "FinalVpnViewModel"
    "HomeFinal"
    "ServersFinal"
    "SettingsFinal"
    "AdminFinal"
    "FavoritesFinal"
    "AppFinal"
    "MainActivity"
)

MISSING=0
for fn in "${REQUIRED_FUNCS[@]}"; do
    if ! grep -q "$fn" "$APP"; then
        echo "  ⚠️ یافت نشد: $fn"
        MISSING=$((MISSING+1))
    fi
done

if [ $MISSING -gt 0 ]; then
    echo "⚠️ $MISSING مورد یافت نشد"
else
    echo "✅ همه توابع کلیدی موجودند"
fi

# ═══════════════════════════════════════════════════════════════
#  ۷. گزارش نهایی
# ═══════════════════════════════════════════════════════════════

echo ""
echo "═══════════════════════════════════════════════════"
echo " ✅ فیکس کامل شد!"
echo "═══════════════════════════════════════════════════"
echo " 📄 فایل: $APP"
echo " 📏 حجم: $(wc -l < $APP) خط"
echo " 📦 تعداد import: $(grep -c '^import ' $APP)"
echo " 🎨 تعداد Composables: $(grep -c '@Composable' $APP)"
echo "═══════════════════════════════════════════════════"
echo ""

exit 0
