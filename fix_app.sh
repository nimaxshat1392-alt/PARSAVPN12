#!/bin/bash
# ═══════════════════════════════════════════════════════════════
#  fix_app.sh — پیدا کردن و آماده‌سازی فایل کد Kotlin
# ═══════════════════════════════════════════════════════════════

set -e

echo "═══════════════════════════════════════════════════"
echo " 🔍 جستجوی کد Kotlin در ریپو"
echo "═══════════════════════════════════════════════════"

# ═══════════════════════════════════════════════════════════════
#  مرحله ۱: پیدا کردن فایلی که کد Kotlin داره
# ═══════════════════════════════════════════════════════════════

FOUND=""
for f in *; do
    if [ -f "$f" ] && [ "$f" != "fix_app.sh" ] && [ "$f" != "README.md" ]; then
        if grep -q "package com.mlmvpn.app" "$f" 2>/dev/null; then
            FOUND="$f"
            echo "✅ کد Kotlin پیدا شد در: $f"
            break
        fi
    fi
done

if [ -z "$FOUND" ]; then
    echo ""
    echo "❌ هیچ فایلی شامل 'package com.mlmvpn.app' پیدا نشد"
    echo ""
    echo "📁 محتوای ریشه:"
    ls -la
    echo ""
    echo "📄 بررسی هر فایل:"
    for f in *; do
        if [ -f "$f" ]; then
            SIZE=$(stat -c%s "$f")
            HAS_PKG=$(grep -c "package com" "$f" 2>/dev/null || echo 0)
            echo "  $f — $SIZE بایت — package: $HAS_PKG"
        fi
    done
    exit 1
fi

# ═══════════════════════════════════════════════════════════════
#  مرحله ۲: تغییر نام به App.kt
# ═══════════════════════════════════════════════════════════════

if [ "$FOUND" != "App.kt" ]; then
    echo "🔄 تغییر نام: $FOUND → App.kt"
    mv "$FOUND" App.kt
fi

APP="App.kt"

# ═══════════════════════════════════════════════════════════════
#  مرحله ۳: حذف خطوط ابتدایی bash (اگه وجود داره)
# ═══════════════════════════════════════════════════════════════

# حذف shebang اگه وجود داره
if head -1 "$APP" | grep -q "^#!"; then
    echo "🗑️ حذف shebang"
    sed -i '1d' "$APP"
fi

# پیدا کردن خط شروع package
FIRST_PKG=$(grep -n "^package com.mlmvpn.app" "$APP" | head -1 | cut -d: -f1)

if [ -n "$FIRST_PKG" ] && [ "$FIRST_PKG" -gt 1 ]; then
    echo "🗑️ حذف $((FIRST_PKG - 1)) خط اول (bash/کامنت)"
    sed -i "1,$((FIRST_PKG - 1))d" "$APP"
fi

# ═══════════════════════════════════════════════════════════════
#  مرحله ۴: فیکس‌های ساده
# ═══════════════════════════════════════════════════════════════

echo "🔧 فیکس‌های خودکار..."

# فیکس تایپوها
sed -i 's/^omposable/@Composable/g' "$APP"
sed -i 's/^n App(/fun App(/g' "$APP"
sed -i 's/^n \([A-Z][a-zA-Z]*\)(/fun \1(/g' "$APP"

# جایگزینی App(vm) → AppFinal()
if grep -q "fun AppFinal()" "$APP"; then
    sed -i 's/App(vm)/AppFinal()/g' "$APP"
    echo "  ✅ App(vm) → AppFinal()"
fi

# ═══════════════════════════════════════════════════════════════
#  مرحله ۵: بررسی ساختار
# ═══════════════════════════════════════════════════════════════

echo ""
echo "🔍 بررسی ساختار فایل..."

# بررسی خط اول
FIRST_LINE=$(head -1 "$APP")
echo "  خط اول: $FIRST_LINE"

if ! echo "$FIRST_LINE" | grep -q "^package "; then
    echo "  ⚠️ خط اول package نیست — ممکنه خطا بده"
fi

# بررسی بسته‌شدن براکت‌ها (تخمینی)
OPEN=$(grep -o "{" "$APP" | wc -l)
CLOSE=$(grep -o "}" "$APP" | wc -l)
echo "  { تعداد: $OPEN — } تعداد: $CLOSE"

if [ "$OPEN" -ne "$CLOSE" ]; then
    DIFF=$((OPEN - CLOSE))
    echo "  ⚠️ عدم تعادل: $DIFF براکت"
fi

# ═══════════════════════════════════════════════════════════════
#  گزارش نهایی
# ═══════════════════════════════════════════════════════════════

echo ""
echo "═══════════════════════════════════════════════════"
echo " ✅ آماده شد!"
echo "═══════════════════════════════════════════════════"
echo " 📄 فایل: $APP"
echo " 📏 حجم: $(wc -l < $APP) خط"
echo " 📦 import: $(grep -c '^import ' $APP)"
echo " 🎨 Composables: $(grep -c '@Composable' $APP)"
echo " 🏛️ کلاس‌ها: $(grep -c '^class ' $APP)"
echo " 🎯 توابع: $(grep -c '^fun ' $APP)"
echo "═══════════════════════════════════════════════════"
echo ""

# نمایش ۵ خط اول برای اطمینان
echo "📋 ۵ خط اول فایل:"
head -5 "$APP"
echo ""

exit 0
