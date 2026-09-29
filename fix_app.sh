# ═══════════════════════════════════════════════════════════════
#  ۱. استخراج فقط بخش Kotlin
# ═══════════════════════════════════════════════════════════════

python3 << 'PYEOF'
import re

with open("PARSAVPN.sh", "r", encoding="utf-8") as f:
    lines = f.readlines()

print("📄 حجم فایل اصلی: {} خط".format(len(lines)))

# ═══ پیدا کردن خط شروع Bash ═══
bash_start = len(lines)

for i, line in enumerate(lines):
    # فقط از خط ۵۰ به بعد چک کن (که داخل کامنت نباشه)
    if i < 50:
        continue
    s = line.rstrip()
    if s in ("#!/bin/bash", "#!/usr/bin/env bash", "set -e", "set -eu",
             'ROOT="PARSAVPN"', 'ROOT="PARSA"'):
        bash_start = i
        print("🎯 اولین خط Bash در خط {}: {}".format(i + 1, s))
        break
    # چک برای cat > و heredoc
    if re.match(r'^cat > ', s) or re.match(r'^mkdir -p ', s) or re.match(r'^rm -rf ', s):
        bash_start = i
        print("🎯 اولین خط Bash در خط {}: {}".format(i + 1, s))
        break

kotlin = "".join(lines[:bash_start])
print("📦 بخش Kotlin: {} خط".format(bash_start))

# ═══ اطمینان از بسته شدن براکت‌ها ═══
kotlin_lines = kotlin.split("\n")
last_closing = 0
for i, line in enumerate(kotlin_lines):
    if line.rstrip() == "}" and i > 100:
        last_closing = i

if last_closing > 0 and last_closing < len(kotlin_lines) - 1:
    kotlin = "\n".join(kotlin_lines[:last_closing + 1])
    print("✂️ برش تا خط {}".format(last_closing + 1))

with open("App_raw.kt", "w", encoding="utf-8") as f:
    f.write(kotlin)

print("✅ Kotlin استخراج شد: {} خط".format(len(kotlin.splitlines())))
PYEOF
