#!/bin/bash
set -e

python3 << 'PYEOF'
import re

with open("PARSAVPN.sh", encoding="utf-8", errors="replace") as f:
    text = f.read()

start = text.find("package com.mlmvpn.app")
end = text.find("KOTLIN_EOF", start)
if end < 0:
    m = re.search(r'\nX\d+\s*\n', text[start:])
    end = start + m.start() if m else len(text)
kotlin = text[start:end]

clean = []
for line in kotlin.split("\n"):
    s = line.strip()
    if s in ("KOTLIN_EOF", "EOF"): break
    if s.startswith("cat >") or s.startswith("echo ") or s == "exit 0": break
    clean.append(line)
kotlin = "\n".join(clean)

# ═══════════════════════════════════════════════════
#  ⭐ ۱. فعال‌کردن LibXray (اتصال واقعی)
# ═══════════════════════════════════════════════════
lines = kotlin.split("\n")
i = 0
while i < len(lines):
    line = lines[i]
    s = line.strip()
    if "LibXray.startXray" in line and s.startswith("//"):
        lines[i] = "            LibXray.startXray(xrayJson, tunFd) { socketFd ->"
        if i+1 < len(lines) and "protect" in lines[i+1]:
            lines[i+1] = "                protect(socketFd)"
        if i+2 < len(lines) and lines[i+2].strip() == "// }":
            lines[i+2] = "            }"
        i += 3
        continue
    if "LibXray.stopXray" in line and s.startswith("//"):
        lines[i] = "            LibXray.stopXray()"
    i += 1
kotlin = "\n".join(lines)

# ═══════════════════════════════════════════════════
#  ⭐ ۲. فیکس‌ها
# ═══════════════════════════════════════════════════
kotlin = kotlin.replace("\nomposable", "\n@Composable")
kotlin = kotlin.replace("\nn App(", "\nfun App(")
kotlin = re.sub(r'else\s*->\s*return\s+null', 'else -> throw IllegalArgumentException("x")', kotlin)
kotlin = re.sub(r'else\s*->\s*null', 'else -> throw IllegalArgumentException("x")', kotlin)
kotlin = re.sub(r'\bserver\s*=\s*u\.host\b(?!\s*[?!])', 'server = u.host ?: ""', kotlin)
kotlin = re.sub(r'\bserver\s*=\s*uri\.host\b(?!\s*[?!])', 'server = uri.host ?: ""', kotlin)
kotlin = re.sub(r'\bu\.userInfo\b(?!\s*[?!])', 'u.userInfo ?: ""', kotlin)
kotlin = re.sub(r'\buri\.userInfo\b(?!\s*[?!])', 'uri.userInfo ?: ""', kotlin)

# ═══════════════════════════════════════════════════
#  ⭐ ۳. اضافه کردن UI جدید
# ═══════════════════════════════════════════════════
NEW_CODE = r'''

// ═══════════════════════════════════════════════════════════════
//   ⭐ 80. UI جدید به سبک HotVPN
// ═══════════════════════════════════════════════════════════════

@Composable
fun HotVpnHome(vm: VpnViewModel, nav: (String) -> Unit) {
    val st by vm.state.collectAsState()
    val sel by vm.selected.collectAsState()
    val ctx = LocalContext.current
    var menuOpen by remember { mutableStateOf(false) }
    var darkMode by remember { mutableStateOf(false) }
    var seconds by remember { mutableStateOf(0L) }
    var userIp by remember { mutableStateOf("Getting ip...") }

    LaunchedEffect(st) {
        if (st == ConnState.CONNECTED) {
            seconds = 0
            while (true) { delay(1000); seconds++ }
        } else seconds = 0
    }

    LaunchedEffect(st) {
        if (st == ConnState.CONNECTED) {
            userIp = "..."
            try {
                val r = withContext(Dispatchers.IO) {
                    OkHttpClient().newCall(
                        Request.Builder().url("https://api.ipify.org").build()
                    ).execute()
                }
                userIp = r.body?.string()?.trim() ?: "Unknown"
            } catch (e: Exception) { userIp = "Unknown" }
        } else userIp = "Getting ip..."
    }

    val bg = if (darkMode) Color(0xFF0F0F1A) else Color(0xFFFAFAFA)
    val tc = if (darkMode) Color.White else Color(0xFF1A1A2E)
    val sc = if (darkMode) Color.White.copy(0.6f) else Color(0xFF7A7A8C)
    val cardBg = if (darkMode) Color(0xFF1A1A2E) else Color.White

    Box(Modifier.fillMaxSize().background(bg)) {
        Column(
            Modifier.fillMaxSize().padding(20.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Row(Modifier.fillMaxWidth(), Arrangement.SpaceBetween, Alignment.CenterVertically) {
                IconButton(onClick = { menuOpen = !menuOpen }) {
                    Icon(Icons.Filled.Menu, null, tint = tc, modifier = Modifier.size(28.dp))
                }
                Text("HotVpn", color = tc, fontSize = 24.sp, fontWeight = FontWeight.Bold)
                Box {
                    IconButton(onClick = {}) {
                        Icon(Icons.Filled.Notifications, null, tint = tc, modifier = Modifier.size(26.dp))
                    }
                    Box(
                        Modifier.size(16.dp).clip(CircleShape).background(Color(0xFFFF4444)),
                        contentAlignment = Alignment.Center
                    ) { Text("1", color = Color.White, fontSize = 9.sp, fontWeight = FontWeight.Bold) }
                }
            }

            Spacer(Modifier.height(20.dp))

            Box(
                Modifier.fillMaxWidth().clip(RoundedCornerShape(16.dp))
                    .background(cardBg).clickable { nav("servers") }.padding(16.dp)
            ) {
                Row(Modifier.fillMaxWidth(), Arrangement.SpaceBetween, Alignment.CenterVertically) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Filled.LocationOn, null, tint = tc, modifier = Modifier.size(22.dp))
                        Spacer(Modifier.width(12.dp))
                        Column {
                            Text(
                                if (sel.name.isNotEmpty()) sel.name else "Choose Server",
                                color = tc, fontSize = 15.sp, fontWeight = FontWeight.Medium
                            )
                            Text("${sel.server}:${sel.port}", color = sc, fontSize = 11.sp)
                        }
                    }
                    Icon(Icons.Filled.ChevronRight, null, tint = sc)
                }
            }

            Spacer(Modifier.height(40.dp))

            Text("Your IP : $userIp", color = sc, fontSize = 14.sp, fontWeight = FontWeight.Medium)

            Spacer(Modifier.height(30.dp))

            Box(Modifier.size(220.dp), contentAlignment = Alignment.Center) {
                Box(Modifier.size(220.dp).clip(CircleShape)
                    .background(if (st == ConnState.CONNECTED) Color(0xFF00E676).copy(0.1f) else Color(0xFFFF4444).copy(0.1f)))
                Box(Modifier.size(180.dp).clip(CircleShape)
                    .background(if (st == ConnState.CONNECTED) Color(0xFF00E676).copy(0.15f) else Color(0xFFFF4444).copy(0.15f)))
                Box(
                    Modifier.size(150.dp).clip(CircleShape)
                        .background(Brush.linearGradient(
                            if (st == ConnState.CONNECTED)
                                listOf(Color(0xFF00E676), Color(0xFF00B8D4))
                            else listOf(Color(0xFFFF5252), Color(0xFFFF1744))
                        ))
                        .clickable {
                            when (st) {
                                ConnState.CONNECTED -> vm.disconnect()
                                ConnState.DISCONNECTED, ConnState.ERROR -> {
                                    VpnBridge.onPermissionGranted = { vm.connect() }
                                    VpnBridge.onPermissionDenied = {
                                        Toast.makeText(ctx, "مجوز VPN لازم است", Toast.LENGTH_LONG).show()
                                    }
                                    VpnBridge.requestVpnPermission?.invoke()
                                }
                                else -> {}
                            }
                        },
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        when (st) {
                            ConnState.CONNECTED -> "STOP"
                            ConnState.CONNECTING -> "..."
                            else -> "START"
                        },
                        color = Color.White, fontSize = 28.sp, fontWeight = FontWeight.Bold
                    )
                }
            }

            Spacer(Modifier.height(30.dp))

            Icon(
                Icons.Filled.Security, null,
                tint = if (st == ConnState.CONNECTED) Color(0xFF00E676) else Color(0xFFFF4444),
                modifier = Modifier.size(28.dp)
            )
            Spacer(Modifier.height(6.dp))
            Text(
                when (st) {
                    ConnState.CONNECTED -> "Connected"
                    ConnState.CONNECTING -> "Connecting..."
                    ConnState.DISCONNECTING -> "Disconnecting..."
                    ConnState.ERROR -> "Error"
                    else -> "Disconnected"
                },
                color = tc, fontSize = 18.sp, fontWeight = FontWeight.Bold
            )
            Spacer(Modifier.height(4.dp))
            Text(formatTime(seconds), color = sc, fontSize = 15.sp, fontWeight = FontWeight.Medium)

            Spacer(Modifier.weight(1f))
        }

        // ═══ منوی کناری ═══
        if (menuOpen) {
            Box(Modifier.fillMaxSize().background(Color.Black.copy(0.4f)).clickable { menuOpen = false })
            Box(
                Modifier.fillMaxHeight().width(280.dp).background(cardBg).padding(20.dp)
            ) {
                Column {
                    Spacer(Modifier.height(40.dp))
                    Row(
                        Modifier.fillMaxWidth().clickable { darkMode = !darkMode },
                        Arrangement.SpaceBetween, Alignment.CenterVertically
                    ) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Icon(Icons.Filled.DarkMode, null, tint = tc)
                            Spacer(Modifier.width(14.dp))
                            Text("Dark Mode", color = tc, fontSize = 15.sp)
                        }
                        Switch(checked = darkMode, onCheckedChange = { darkMode = it })
                    }
                    Spacer(Modifier.height(24.dp))
                    MenuItem(Icons.Filled.Lock, "پنل مدیریت", tc) { menuOpen = false; nav("admin") }
                    MenuItem(Icons.Filled.Settings, "تنظیمات", tc) { menuOpen = false; nav("settings") }
                    MenuItem(Icons.Filled.Dns, "سرورها", tc) { menuOpen = false; nav("servers") }
                    MenuItem(Icons.Filled.Share, "اشتراک‌گذاری", tc) {
                        val i = Intent(Intent.ACTION_SEND).apply {
                            type = "text/plain"
                            putExtra(Intent.EXTRA_TEXT, "PARSA VPN")
                        }
                        ctx.startActivity(Intent.createChooser(i, "Share"))
                    }
                    Spacer(Modifier.weight(1f))
                    Text(
                        "Version : 9.1.0", color = sc, fontSize = 12.sp,
                        modifier = Modifier.align(Alignment.CenterHorizontally)
                    )
                    Spacer(Modifier.height(20.dp))
                }
            }
        }
    }
}

@Composable
fun MenuItem(icon: androidx.compose.ui.graphics.vector.ImageVector, label: String, color: Color, onClick: () -> Unit) {
    Row(
        Modifier.fillMaxWidth().clickable(onClick = onClick).padding(vertical = 14.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(icon, null, tint = color, modifier = Modifier.size(22.dp))
        Spacer(Modifier.width(14.dp))
        Text(label, color = color, fontSize = 15.sp)
    }
}

fun formatTime(sec: Long): String {
    val h = sec / 3600
    val m = (sec % 3600) / 60
    val s = sec % 60
    return "%02d : %02d : %02d".format(h, m, s)
}

// ═══════════════════════════════════════════════════════════════
//   ⭐ 81. پنل مدیریت: Bulk Import + Sub URL + حذف همه
// ═══════════════════════════════════════════════════════════════

@Composable
fun AdminPanelBulk(vm: VpnViewModel, back: () -> Unit) {
    var linkInput by remember { mutableStateOf("") }
    var subUrl by remember { mutableStateOf("") }
    var msg by remember { mutableStateOf("") }
    var loading by remember { mutableStateOf(false) }
    val cfgs by vm.configs.collectAsState()
    val scope = rememberCoroutineScope()

    Column(Modifier.fillMaxSize().background(Color(0xFF0A0E27)).padding(16.dp)) {
        Row(Modifier.fillMaxWidth(), Arrangement.SpaceBetween, Alignment.CenterVertically) {
            IconButton(onClick = back) { Icon(Icons.Filled.ArrowBack, null, tint = Color.White) }
            Text("مدیریت کانفیگ‌ها", color = Color.White, fontSize = 18.sp, fontWeight = FontWeight.Bold)
            Spacer(Modifier.width(48.dp))
        }

        Spacer(Modifier.height(12.dp))

        Column(Modifier.fillMaxWidth().weight(1f).verticalScroll(rememberScrollState())) {

            // ═══ Bulk Import ═══
            Text("📥 افزودن چندتایی (هر خط یک لینک)", color = Color.White, fontSize = 14.sp, fontWeight = FontWeight.Bold)
            Spacer(Modifier.height(8.dp))
            OutlinedTextField(
                value = linkInput,
                onValueChange = { linkInput = it },
                label = { Text("چندین لینک...") },
                modifier = Modifier.fillMaxWidth().height(150.dp),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedTextColor = Color.White, unfocusedTextColor = Color.White
                )
            )
            Spacer(Modifier.height(8.dp))
            Button(
                onClick = {
                    val links = linkInput.split("\n").map { it.trim() }.filter { it.isNotEmpty() }
                    var added = 0
                    links.forEach { if (vm.addAdmin(it, "")) added++ }
                    msg = "✓ $added از ${links.size} افزوده شد"
                    linkInput = ""
                },
                modifier = Modifier.fillMaxWidth(),
                colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF00E676))
            ) { Text("افزودن همه", color = Color.Black) }

            Spacer(Modifier.height(20.dp))

            // ═══ Sub URL ═══
            Text("🔗 لینک ساب", color = Color.White, fontSize = 14.sp, fontWeight = FontWeight.Bold)
            Spacer(Modifier.height(8.dp))
            OutlinedTextField(
                value = subUrl, onValueChange = { subUrl = it },
                label = { Text("https://example.com/sub") },
                modifier = Modifier.fillMaxWidth(),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedTextColor = Color.White, unfocusedTextColor = Color.White
                )
            )
            Spacer(Modifier.height(8.dp))
            Button(
                onClick = {
                    if (subUrl.isBlank()) { msg = "لینک خالی"; return@Button }
                    loading = true
                    scope.launch {
                        try {
                            val body = withContext(Dispatchers.IO) {
                                OkHttpClient().newCall(Request.Builder().url(subUrl).build())
                                    .execute().body?.string() ?: ""
                            }
                            val decoded = if (!body.contains("://")) {
                                try { String(android.util.Base64.decode(body, android.util.Base64.DEFAULT)) } catch (_: Exception) { body }
                            } else body
                            val links = decoded.split("\n").map { it.trim() }.filter {
                                it.startsWith("vless://") || it.startsWith("vmess://") ||
                                it.startsWith("ss://") || it.startsWith("trojan://")
                            }
                            var added = 0
                            links.forEach { if (vm.addAdmin(it, "")) added++ }
                            msg = "✓ $added کانفیگ از ساب"
                        } catch (e: Exception) { msg = "✗ ${e.message}" }
                        loading = false
                    }
                },
                modifier = Modifier.fillMaxWidth(),
                colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF7C4DFF)),
                enabled = !loading
            ) {
                if (loading) { CircularProgressIndicator(Modifier.size(16.dp), strokeWidth = 2.dp); Spacer(Modifier.width(8.dp)) }
                Text(if (loading) "دریافت..." else "دریافت از ساب")
            }

            if (msg.isNotEmpty()) {
                Spacer(Modifier.height(8.dp))
                Text(msg, color = if (msg.startsWith("✓")) Color(0xFF00E676) else Color(0xFFFF5252), fontSize = 13.sp)
            }

            Spacer(Modifier.height(24.dp))

            // ═══ همه کانفیگ‌ها با حذف ═══
            Row(Modifier.fillMaxWidth(), Arrangement.SpaceBetween, Alignment.CenterVertically) {
                Text("🗑️ همه کانفیگ‌ها (${cfgs.size})", color = Color.White, fontSize = 14.sp, fontWeight = FontWeight.Bold)
                TextButton(onClick = {
                    cfgs.forEach { vm.removeAdmin(it.id) }
                    msg = "✓ همه حذف شد"
                }) { Text("حذف همه", color = Color(0xFFFF5252), fontSize = 12.sp) }
            }
            Spacer(Modifier.height(8.dp))

            cfgs.forEach { c ->
                Card(
                    Modifier.fillMaxWidth().padding(vertical = 3.dp),
                    colors = CardDefaults.cardColors(containerColor = Color(0xFF1B1F3A))
                ) {
                    Row(
                        Modifier.fillMaxWidth().padding(12.dp),
                        Arrangement.SpaceBetween, Alignment.CenterVertically
                    ) {
                        Column(Modifier.weight(1f)) {
                            Text(c.name, color = Color.White, fontSize = 13.sp, fontWeight = FontWeight.Medium)
                            Text(c.server, color = Color.White.copy(0.5f), fontSize = 10.sp)
                        }
                        IconButton(onClick = { vm.removeAdmin(c.id) }) {
                            Icon(Icons.Filled.Delete, null, tint = Color(0xFFFF5252))
                        }
                    }
                }
            }

            Spacer(Modifier.height(32.dp))
        }
    }
}
'''

kotlin = kotlin.rstrip() + "\n" + NEW_CODE

# تغییر مسیر Home به UI جدید
kotlin = kotlin.replace('"home" -> HomeFinal(vm) { screen = it }', '"home" -> HotVpnHome(vm) { screen = it }')

# اضافه کردن importهای جدید
NEW_IMPORTS = """import androidx.compose.material.icons.filled.Menu
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material.icons.filled.LocationOn
import androidx.compose.material.icons.filled.ChevronRight
import androidx.compose.material.icons.filled.DarkMode
import androidx.compose.material.icons.filled.Call
import androidx.compose.foundation.layout.fillMaxHeight
import okhttp3.OkHttpClient
import okhttp3.Request"""

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
import android.se
