#!/bin/bash
set -e

echo "═══════════════════════════════════════════════════"
echo " 🔍 دیباگ App.kt"
echo "═══════════════════════════════════════════════════"

# ═══ ۱. استخراج ═══
START=$(grep -n "^package com.mlmvpn.app" PARSAVPN.sh | head -1 | cut -d: -f1)
END=$(awk -v s="$START" 'NR > s && /^KOTLIN_EOF/ {print NR; exit}' PARSAVPN.sh)
[ -z "$END" ] && END=$(wc -l < PARSAVPN.sh)

sed -n "${START},$((END-1))p" PARSAVPN.sh > App.kt
echo "✅ استخراج: $(wc -l < App.kt) خط"

# ═══ ۲. چاپ خطوط اطراف خطا ═══
echo ""
echo "══════════════ 📋 خطوط 1610 تا 1650 ══════════════"
sed -n '1610,1650p' App.kt | cat -n | sed 's/^/  /'
echo "═══════════════════════════════════════════════════"

echo ""
echo "══════════════ 📋 بررسی براکت‌ها ══════════════"
OPEN=$(grep -o "{" App.kt | wc -l)
CLOSE=$(grep -o "}" App.kt | wc -l)
echo "  { = $OPEN"
echo "  } = $CLOSE"
echo "  تفاوت = $((OPEN - CLOSE))"
echo "═══════════════════════════════════════════════════"
