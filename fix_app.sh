#!/bin/bash
# ═══════════════════════════════════════════════════════════════
#  fix_app.sh — استخراج کد Kotlin از فایل ترکیبی
# ═══════════════════════════════════════════════════════════════

set -e

echo "═══════════════════════════════════════════════════"
echo " 🔍 بررسی فایل PARSAVPN.sh"
echo "═══════════════════════════════════════════════════"

if [ ! -f "PARSAVPN.sh" ]; then
    echo "❌ PARSAVPN.sh پیدا نشد!"
    ls -la
    exit 1
fi

echo "📄 حجم: $(wc -l < PARSAVPN.sh) خط"

# ═══════════════════════════════════════════════════════════════
#  استخراج کد Kotlin با Python
# ═══════════════════════════════════════════════════════════════

python3 << 'PYEOF'
import re

with open("PARSAVPN.sh", "r", encoding="utf-8") as f:
    content = f.read()

# ═══ پیدا کردن heredoc اول (App.kt) ═══
heredoc_match = re.search(
    r"<< 'KOTLIN_EOF'\n(.*?)\nKOTLIN_EOF",
    content,
    re.DOTALL
)

if heredoc_match:
    part1 = heredoc_match.group(1)
    print(f"📦 بخش ۱ (heredoc): {len(part1.splitlines())} خط")
else:
    part1 = ""
    print("⚠️ heredoc پیدا نشد")

# ═══ پیدا کردن کد Kotlin بعد از bash ═══
# آخرین موقعیت X19 یا exit
marker_pos = 0
for marker in ["\nX19\n", "\nexit 0\n", "\necho \"\"\n"]:
    idx = content.rfind(marker)
    if idx > marker_pos:
        marker_pos = idx + len(marker)

if marker_pos > 0:
    part2_raw = content[marker_pos:]
    print(f"📦 بخش ۲ (خام): {len(part2_raw.splitlines())} خط")
    
    # فیلتر خطوط Bash
    lines = part2_raw.split("\n")
    cleaned = []
    in_bash = True
    
    for line in lines:
        stripped = line.strip()
        
        # تشخیص شروع Kotlin واقعی
        if not in_bash:
            cleaned.append(line)
            continue
        
        # اگر خط Kotlin هست، از اینجا به بعد همه رو نگه دار
        if re.match(r'^(package |import |class |object |fun |@|data class|enum class|sealed class)', stripped):
            in_bash = False
            cleaned.append(line)
            continue
        
        # فیلتر Bash
        if not stripped:
            continue
        if stripped in ("KOTLIN_EOF", "EOF", "X1", "X2", "X3", "X4", "X5",
                        "X6", "X7", "X8", "X9", "X10", "X11", "X12",
                        "X13", "X14", "X15", "X16", "X17", "X18", "X19"):
            continue
        if re.match(r'^(cat >|cat >>|chmod |mkdir |rm |mv |cp |echo |printf |exit |sleep |curl |wget |git |set -|local |function |fi$|then$|else$|done$|do$|esac$)', stripped):
            continue
        if re.match(r'^[A-Z_]+=', stripped):
            continue
        if stripped.startswith("#!/"):
            continue
        if stripped.startswith("#"):
            continue
        if re.match(r'^(if \[|for [a-z_]+ in|while |case )', stripped):
            continue
    
    part2 = "\n".join(cleaned)
    print(f"📦 بخش ۲ (پاک): {len(part2.splitlines())} خط")
else:
    part2 = ""
    print("⚠️ بخش ۲ پیدا نشد")

# ═══ ترکیب ═══
if part1 and part2:
    final = part1 + "\n\n" + part2
elif part1:
    final = part1
elif part2:
    final = part2
else:
    print("❌ هیچ Kotlin پیدا نشد!")
    exit(1)

# ═══ پاک‌سازی نهایی ═══
# حذف خطوط خالی پشت سرهم
final = re.sub(r'\n{3,}', '\n\n', final)

# حذف خطوطی که فقط کامنت bash هستن
lines = final.split("\n")
cleaned = []
for line in lines:
    stripped = line.strip()
    # حذف خطوط X marker
    if re.match(r'^X\d+$', stripped):
        continue
    if stripped in ("KOTLIN_EOF", "EOF"):
        continue
    cleaned.append(line)

final = "\n".join(cleaned)

# ═══ نوشتن ═══
with open("App.kt", "w", encoding="utf-8") as f:
    f.write(final)

total = len(final.splitlines())
print(f"")
print(f"✅ App.kt نوشته شد: {total} خط")
PYEOF

# ═══════════════════════════════════════════════════════════════
#  فیکس تایپوهای نهایی
# ═══════════════════════════════════════════════════════════════

echo ""
echo "🔧 فیکس تایپوها..."

sed -i 's/^omposable/@Composable/g' App.kt
sed -i 's/^n App(/fun App(/g' App.kt
sed -i 's/^n \([A-Z][a-zA-Z]*\)(/fun \1(/g' App.kt

# ═══════════════════════════════════════════════════════════════
#  گزارش
# ═══════════════════════════════════════════════════════════════

echo ""
echo "═══════════════════════════════════════════════════"
echo " ✅ پاک‌سازی کامل شد!"
echo "═══════════════════════════════════════════════════"
echo " 📏 حجم App.kt: $(wc -l < App.kt) خط"
echo " 📦 importها: $(grep -c '^import ' App.kt)"
echo " 🎨 Composables: $(grep -c '@Composable' App.kt)"
echo " 🏛️ کلاس‌ها: $(grep -c '^class\|^object\|^data class\|^enum class' App.kt)"
echo " 🎯 توابع: $(grep -c '^fun ' App.kt)"
echo "═══════════════════════════════════════════════════"
echo ""
echo "📋 ۵ خط اول:"
head -5 App.kt
echo ""
echo "📋 ۵ خط آخر:"
tail -5 App.kt
echo ""
echo "✅ آماده Build!"

exit 0
