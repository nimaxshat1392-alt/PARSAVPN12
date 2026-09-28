#!/bin/bash
# ═══════════════════════════════════════════════════════════════
#  fix_app.sh — فیکس خودکار (نسخه هوشمند)
#  - فایل .kt رو پیدا می‌کنه
#  - اگه پیدا نشد، داخل PARSAVPN.sh رو بررسی می‌کنه
#  - اگه کد Kotlin داخل فایل اشتباه بود، استخراج می‌کنه
# ═══════════════════════════════════════════════════════════════

set -e

echo "═══════════════════════════════════════════════════"
echo " 🔍 جستجوی فایل کد اصلی PARSA VPN"
echo "═══════════════════════════════════════════════════"
echo ""

# ═══════════════════════════════════════════════════════════════
#  مرحله ۱: جستجوی فایل .kt
# ═══════════════════════════════════════════════════════════════

KT_FILE=""

# ۱.۱: دنبال App.kt
if [ -f "App.kt" ]; then
    KT_FILE="App.kt"
    echo "✅ App.kt پیدا شد"
fi

# ۱.۲: دنبال هر .kt دیگه‌ای
if [ -z "$KT_FILE" ]; then
    for f in *.kt; do
        if [ -f "$f" ]; then
            KT_FILE="$f"
            echo "✅ فایل .kt پیدا شد: $f"
            break
        fi
    done
fi

# ۱.۳: اگه هیچ .kt نبود، داخل فایل‌های دیگه بگرد
if [ -z "$KT_FILE" ]; then
    echo "⚠️ هیچ فایل .kt پیدا نشد"
    echo ""
    echo "🔍 بررسی فایل‌های دیگه برای کد Kotlin..."
    echo ""
    
    # بررسی همه فایل‌های ریشه
    for f in *; do
        if [ -f "$f" ]; then
            # بررسی اینکه آیا فایل شامل کد Kotlin هست
            if grep -q "data class VpnConfig\|package com.mlmvpn.app" "$f" 2>/dev/null; then
                echo "🎯 کد Kotlin در فایل: $f"
                echo "🔄 تغییر نام $f → App.kt"
                mv "$f" App.kt
                KT_FILE="App.kt"
                break
            fi
        fi
    done
fi

# ۱.۴: اگه هنوز پیدا نشد، داخل PARSAVPN.sh بگرد
if [ -z "$KT_FILE" ] && [ -f "PARSAVPN.sh" ]; then
    echo ""
    echo "🔍 بررسی PARSAVPN.sh..."
    
    # بررسی اینکه آیا PARSAVPN.sh حاوی heredoc برای App.kt هست
    if grep -q "cat > .*App.kt" "PARSAVPN.sh" 2>/dev/null; then
        echo "🎯 heredoc App.kt در PARSAVPN.sh پیدا شد"
        echo "📤 استخراج..."
        
        python3 << 'PYEOF'
import re
with open("PARSAVPN.sh", "r", encoding="utf-8") as f:
    content = f.read()

# الگوهای مختلف heredoc
patterns = [
    r"cat > [\"']?\$ROOT/app/src/main/java/\$PKG/App\.kt[\"']? << 'KOTLIN_EOF'\n(.*?)\nKOTLIN_EOF",
    r"cat > [\"']?App\.kt[\"']? << 'KOTLIN_EOF'\n(.*?)\nKOTLIN_EOF",
    r"cat > [\"']?[^\"']*App\.kt[\"']? << 'EOF'\n(.*?)\nEOF",
    r"cat > [\"']?[^\"']*App\.kt[\"']? << '[A-Z_]+'\n(.*?)\n[A-Z_]+",
]

extracted = None
for pattern in patterns:
    match = re.search(pattern, content, re.DOTALL)
    if match:
        extracted = match.group(1)
        break

if extracted:
    with open("App.kt", "w", encoding="utf-8") as f:
        f.write(extracted)
    print(f"✅ استخراج شد — {len(extracted.splitlines())} خط")
    exit(0)
else:
    print("❌ الگوی heredoc پیدا نشد")
    exit(1)
PYEOF

        if [ -f "App.kt" ]; then
            KT_FILE="App.kt"
        fi
    fi
fi

# ═══════════════════════════════════════════════════════════════
#  اگر پیدا نشد → خطا
# ═══════════════════════════════════════════════════════════════

if [ -z "$KT_FILE" ]; then
    echo ""
    echo "❌ فایل کد اصلی PARSA VPN پیدا نشد!"
    echo ""
    echo "📁 محتوای ریشه ریپو:"
    ls -la
    echo ""
    echo "📄 بررسی فایل‌های بزرگ:"
    for f in *; do
        if [ -f "$f" ]; then
            SIZE=$(stat -c%s "$f")
            LINES=$(wc -l < "$f" 2>/dev/null || echo "?")
            echo "  $f — $SIZE بایت، $LINES خط"
        fi
    done
    echo ""
    echo "💡 راه‌حل: در گیت‌هاب، فایل کد اصلیت رو به App.kt تغییر نام بده."
    exit 1
fi

echo ""
echo "✅ فایل هدف: $KT_FILE"
echo "📏 حجم: $(wc -l < $KT_FILE) خط"
echo ""

# ═══════════════════════════════════════════════════════════════
#  مرحله ۲: اطمینان از اینکه فایل واقعاً کد Kotlin هست
# ═══════════════════════════════════════════════════════════════

if ! grep -q "package com.mlmvpn.app\|data class VpnConfig" "$KT_FILE"; then
    echo "⚠️ فایل $KT_FILE شامل کد اصلی PARSA VPN نیست"
    echo "   اما با این حال ادامه می‌دهیم..."
fi

# ═══════════════════════════════════════════════════════════════
#  مرحله ۳: فیکس‌های خودکار
# ═══════════════════════════════════════════════════════════════

APP="$KT_FILE"

echo "🔧 شروع فیکس خودکار..."
echo ""

# ─── فیکس تایپوها ───
echo "  ۱. فیکس تایپوها"
sed -i 's/^omposable/@Composable/g' "$APP"
sed -i 's/^n App(/fun App(/g' "$APP"
sed -i 's/^n \([A-Z][a-zA-Z]*\)(/fun \1(/g' "$APP"

# ─── افزودن importها ───
echo "  ۲. افزودن importهای مورد نیاز"

add_import_if_missing() {
    local import_line="$1"
    if ! grep -q "^import $import_line$" "$APP"; then
        local last_import_line=$(grep -n "^import " "$APP" | tail -1 | cut -d: -f1)
        if [ -n "$last_import_line" ]; then
            sed -i "${last_import_line}a import $import_line" "$APP"
        fi
    fi
}

# Compose
add_import_if_missing "androidx.compose.foundation.border"
add_import_if_missing "androidx.compose.foundation.combinedClickable"
add_import_if_missing "androidx.compose.foundation.ExperimentalFoundationApi"
add_import_if_missing "androidx.compose.foundation.layout.ColumnScope"
add_import_if_missing "androidx.compose.animation.core.Animatable"
add_import_if_missing "androidx.compose.ui.graphics.graphicsLayer"
add_import_if_missing "androidx.compose.ui.graphics.asImageBitmap"
add_import_if_missing "androidx.compose.ui.draw.blur"
add_import_if_missing "androidx.compose.ui.draw.rotate"
add_import_if_missing "androidx.compose.ui.text.style.TextOverflow"
add_import_if_missing "androidx.compose.ui.text.style.TextAlign"
add_import_if_missing "androidx.compose.ui.platform.LocalContext"
add_import_if_missing "androidx.compose.ui.platform.LocalHapticFeedback"
add_import_if_missing "androidx.compose.ui.hapticfeedback.HapticFeedbackType"

# Icons
for icon in Close Dns Lock LockOpen PieChart Refresh Search SearchOff Security Settings Speed Star Sync CheckCircle Info ArrowBack Delete; do
    add_import_if_missing "androidx.compose.material.icons.filled.$icon"
done
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
add_import_if_missing "androidx.activity.result.contract.ActivityResultContracts"

# ─── import LibXray ───
echo "  ۳. import LibXray"
if grep -q "RealXrayCore\|RealPingEngine" "$APP"; then
    if ! grep -q "^import libXray" "$APP"; then
        LAST_IMPORT=$(grep -n "^import " "$APP" | tail -1 | cut -d: -f1)
        sed -i "${LAST_IMPORT}a import libXray.LibXray" "$APP"
        echo "     ➕ LibXray اضافه شد"
    fi
fi

# ─── حذف import تکراری ───
echo "  ۴. حذف importهای تکراری"
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

# ─── جایگزینی App(vm) ───
echo "  ۵. جایگزینی App(vm) → AppFinal()"
if grep -q "fun AppFinal()" "$APP"; then
    sed -i 's/App(vm)/AppFinal()/g' "$APP"
    echo "     ✅ انجام شد"
else
    echo "     ⚠️ AppFinal پیدا نشد"
fi

# ═══════════════════════════════════════════════════════════════
#  گزارش نهایی
# ═══════════════════════════════════════════════════════════════

echo ""
echo "🔍 بررسی توابع کلیدی..."

MISSING=0
for fn in "VpnConfig" "ConnState" "DefaultConfigs" "ConfigManager" "XrayBuilder" "MainActivity"; do
    if ! grep -q "$fn" "$APP"; then
        echo "  ⚠️ یافت نشد: $fn"
        MISSING=$((MISSING+1))
    fi
done

echo ""
echo "═══════════════════════════════════════════════════"
echo " ✅ فیکس کامل شد!"
echo "═══════════════════════════════════════════════════"
echo " 📄 فایل: $APP"
echo " 📏 حجم: $(wc -l < $APP) خط"
echo " 📦 import: $(grep -c '^import ' $APP)"
echo " 🎨 Composables: $(grep -c '@Composable' $APP)"
echo " ⚠️ توابع گم‌شده: $MISSING"
echo "═══════════════════════════════════════════════════"
echo ""

# اطمینان از اینکه فایل در ریشه است
if [ ! -f "App.kt" ]; then
    cp "$APP" App.kt
fi

ls -la App.kt
echo ""
echo "🎯 آماده برای Build!"
exit 0
