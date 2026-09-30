# ═══ فیکس Type Mismatch String? ═══
echo "🔧 فیکس Type Mismatch..."

# ۱. رفع مشکل uri.host (nullable → non-null)
sed -i 's/addProperty("address", u\.host)/addProperty("address", u.host ?: "")/g' App.kt
sed -i 's/addProperty("address", uri\.host)/addProperty("address", uri.host ?: "")/g' App.kt

# ۲. رفع مشکل uri.userInfo
sed -i 's/addProperty("id", u\.userInfo)/addProperty("id", u.userInfo ?: "")/g' App.kt
sed -i 's/addProperty("id", uri\.userInfo)/addProperty("id", uri.userInfo ?: "")/g' App.kt
sed -i 's/addProperty("password", u\.userInfo)/addProperty("password", u.userInfo ?: "")/g' App.kt

# ۳. رفع مشکل userInfo در VpnConfig
sed -i 's/userInfo = u\.userInfo/userInfo = u.userInfo ?: ""/g' App.kt

# ۴. هر جایی که uri.host بدون ?: هست و به String پاس داده می‌شه
sed -i 's/server = uri\.host/server = uri.host ?: ""/g' App.kt
