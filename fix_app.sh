#!/bin/bash
set -e

echo "🔍 فقط دیباگ — بدون تغییر"

# فقط بخش اول: استخراج
head -1 PARSAVPN.sh > /dev/null
START=$(grep -n "^package com.mlmvpn.app" PARSAVPN.sh | head -1 | cut -d: -f1)
END=$(awk -v s="$START" 'NR > s && /^KOTLIN_EOF/ {print NR; exit}' PARSAVPN.sh)
[ -z "$END" ] && END=$(wc -l < PARSAVPN.sh)

sed -n "${START},$((END-1))p" PARSAVPN.sh > App.kt

# اضافه کردن ۲۰۰ خط خالی برای هم‌راستا شدن با App.kt اصلی
python3 << 'PYEOF'
with open("App.kt") as f:
    lines = f.readlines()

# اضافه کردن ۲۰۰ خط کامنت در ابتدا (برای هم‌راستا شدن با importها)
header = ["// padding line\n"] * 200
lines = header + lines

with open("App.kt", "w") as f:
    f.writelines(lines)

# چاپ خط ۹۸۴ دقیقاً
print("")
print("╔════════════════════════════════════════════════════════╗")
print("║  📍 خط ۹۸۴ در App.kt (بعد از اضافه شدن importها):      ║")
print("╚════════════════════════════════════════════════════════╝")
print("")
print(lines[983].rstrip() if len(lines) > 983 else "خط وجود ندارد")
print("")
print("╔════════════════════════════════════════════════════════╗")
print("║  📍 ۱۰ خط قبل تا ۱۰ خط بعد:                            ║")
print("╚════════════════════════════════════════════════════════╝")
print("")
for i in range(max(0, 973), min(995, len(lines))):
    marker = " ← خطا اینجاست" if i == 983 else ""
    print("{:4d} | {}{}".format(i+1, lines[i].rstrip(), marker))
print("")
PYEOF

echo ""
echo "════════════════════════════════════════════════════════"
echo "  ⚠️ حالا این خط رو از لاگ Actions پیدا کن و کپی کن"
echo "════════════════════════════════════════════════════════"
