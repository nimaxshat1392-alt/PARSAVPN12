#!/bin/bash
set -e

echo "🔧 استخراج و آماده‌سازی..."

# ═══ ۱. استخراج با sed ═══
sed -n '/^package com.mlmvpn.app/,/^KOTLIN_EOF/p' PARSAVPN.sh | sed '$d' > body.txt

# ═══ ۲. حذف package و importهای قدیمی از body ═══
grep -v '^package com.mlmvpn.app' body.txt | grep -v '^import ' > body_clean.txt

# ═══ ۳. ساخت فایل نهایی ═══
cat > App.kt << 'HEAD_EOF'
package com.mlmvpn.app

import android.app.Notification
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
import android.service.quicksettings.TileService
import android.util.Base64
import android.util.Log
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.spring
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.ChevronRight
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.DarkMode
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Dns
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.LocationOn
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.LockOpen
import androidx.compose.material.icons.filled.Menu
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material.icons.filled.PieChart
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.filled.SearchOff
import androidx.compose.material.icons.filled.Security
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.filled.Share
import androidx.compose.material.icons.filled.Speed
import androidx.compose.material.icons.filled.Star
import androidx.compose.material.icons.filled.Sync
import androidx.compose.material.icons.outlined.StarBorder
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Checkbox
import androidx.compose.material3.CheckboxDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Divider
import androidx.compose.material3.FilterChip
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.ScrollableTabRow
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.material3.Tab
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.blur
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.StrokeJoin
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.cancel
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import kotlinx.coroutines.withTimeoutOrNull
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.sync.Semaphore
import kotlinx.coroutines.sync.withPermit
import com.google.gson.Gson
import com.google.gson.JsonArray
import com.google.gson.JsonObject
import com.google.gson.JsonParser
import com.google.gson.reflect.TypeToken
import java.net.InetSocketAddress
import java.net.URI
import java.net.URLDecoder
import java.util.UUID
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicInteger
import okhttp3.OkHttpClient
import okhttp3.Request
HEAD_EOF

# ═══ ۴. اضافه کردن body ═══
cat body_clean.txt >> App.kt

# ═══ ۵. فیکس‌های ساده با sed ═══
sed -i 's/^omposable/@Composable/' App.kt
sed -i 's/^n App(/fun App(/' App.kt
sed -i 's/App(vm)/AppFinal()/g' App.kt
sed -i 's/"home" -> HomeFinal(vm) { screen = it }/"home" -> HotVpnHome(vm) { screen = it }/' App.kt
sed -i 's|// LibXray.startXray|LibXray.startXray|' App.kt
sed -i 's|// LibXray.stopXray|LibXray.stopXray|' App.kt

# ═══ ۶. Append UI جدید ═══
cat >> App.kt << 'UI_EOF'

@Composable
fun HotVpnHome(vm: VpnViewModel, nav: (String) -> Unit) {
    val st by vm.state.collectAsState()
    val sel by vm.selected.collectAsState()
    val ctx = LocalContext.current
    var menuOpen by remember { mutableStateOf(false) }
    var darkMode by remember { mutableStateOf(false) }
    var seconds by remember { mutableStateOf(0L) }

    LaunchedEffect(st) {
        if (st == ConnState.CONNECTED) {
            seconds = 0
            while (true) { delay(1000); seconds++ }
        } else seconds = 0
    }

    val bg = if (darkMode) Color(0xFF0F0F1A) else Color(0xFFFAFAFA)
    val tc = if (darkMode) Color.White else Color(0xFF1A1A2E)
    val sc = if (darkMode) Color.White.copy(0.6f) else Color(0xFF7A7A8C)
    val cardBg = if (darkMode) Color(0xFF1A1A2E) else Color.White
    val btnColor = if (st == ConnState.CONNECTED)
        listOf(Color(0xFF00E676), Color(0xFF00B8D4))
    else listOf(Color(0xFFFF5252), Color(0xFFFF1744))

    Box(Modifier.fillMaxSize().background(bg)) {
        Column(Modifier.fillMaxSize().padding(20.dp), horizontalAlignment = Alignment.CenterHorizontally) {
            Row(Modifier.fillMaxWidth(), Arrangement.SpaceBetween, Alignment.CenterVertically) {
                IconButton(onClick = { menuOpen = !menuOpen }) {
                    Icon(Icons.Filled.Menu, null, tint = tc, modifier = Modifier.size(28.dp))
                }
                Text("HotVpn", color = tc, fontSize = 24.sp, fontWeight = FontWeight.Bold)
                Box {
                    IconButton(onClick = {}) {
                        Icon(Icons.Filled.Notifications, null, tint = tc, modifier = Modifier.size(26.dp))
                    }
                    Box(Modifier.size(16.dp).clip(CircleShape).background(Color(0xFFFF4444)),
                        contentAlignment = Alignment.Center) {
                        Text("1", color = Color.White, fontSize = 9.sp, fontWeight = FontWeight.Bold)
                    }
                }
            }
            Spacer(Modifier.height(20.dp))
            Box(Modifier.fillMaxWidth().clip(RoundedCornerShape(16.dp))
                .background(cardBg).clickable { nav("servers") }.padding(16.dp)) {
                Row(Modifier.fillMaxWidth(), Arrangement.SpaceBetween, Alignment.CenterVertically) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Filled.LocationOn, null, tint = tc, modifier = Modifier.size(22.dp))
                        Spacer(Modifier.width(12.dp))
                        Column {
                            Text(if (sel.name.isNotEmpty()) sel.name else "Choose Server",
                                color = tc, fontSize = 15.sp, fontWeight = FontWeight.Medium)
                            Text("${sel.server}:${sel.port}", color = sc, fontSize = 11.sp)
                        }
                    }
                    Icon(Icons.Filled.ChevronRight, null, tint = sc)
                }
            }
            Spacer(Modifier.height(40.dp))
            Text("Your IP : Getting ip...", color = sc, fontSize = 14.sp, fontWeight = FontWeight.Medium)
            Spacer(Modifier.height(30.dp))
            Box(Modifier.size(220.dp), contentAlignment = Alignment.Center) {
                Box(Modifier.size(220.dp).clip(CircleShape)
                    .background(btnColor[0].copy(0.1f)))
                Box(Modifier.size(180.dp).clip(CircleShape)
                    .background(btnColor[0].copy(0.15f)))
                Box(Modifier.size(150.dp).clip(CircleShape)
                    .background(Brush.linearGradient(btnColor))
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
                    contentAlignment = Alignment.Center) {
                    Text(when (st) {
                        ConnState.CONNECTED -> "STOP"
                        ConnState.CONNECTING -> "..."
                        else -> "START"
                    }, color = Color.White, fontSize = 28.sp, fontWeight = FontWeight.Bold)
                }
            }
            Spacer(Modifier.height(30.dp))
            Icon(Icons.Filled.Security, null, tint = btnColor[0], modifier = Modifier.size(28.dp))
            Spacer(Modifier.height(6.dp))
            Text(when (st) {
                ConnState.CONNECTED -> "Connected"
                ConnState.CONNECTING -> "Connecting..."
                ConnState.DISCONNECTING -> "Disconnecting..."
                ConnState.ERROR -> "Error"
                else -> "Disconnected"
            }, color = tc, fontSize = 18.sp, fontWeight = FontWeight.Bold)
            Spacer(Modifier.height(4.dp))
            Text(formatTime(seconds), color = sc, fontSize = 15.sp, fontWeight = FontWeight.Medium)
            Spacer(Modifier.weight(1f))
        }

        if (menuOpen) {
            Box(Modifier.fillMaxSize().background(Color.Black.copy(0.4f)).clickable { menuOpen = false })
            Box(Modifier.fillMaxHeight().width(280.dp).background(cardBg).padding(20.dp)) {
                Column {
                    Spacer(Modifier.height(40.dp))
                    Row(Modifier.fillMaxWidth().clickable { darkMode = !darkMode },
                        Arrangement.SpaceBetween, Alignment.CenterVertically) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Icon(Icons.Filled.DarkMode, null, tint = tc)
                            Spacer(Modifier.width(14.dp))
                            Text("Dark Mode", color = tc, fontSize = 15.sp)
                        }
                        Switch(checked = darkMode, onCheckedChange = { darkMode = it })
                    }
                    Spacer(Modifier.height(24.dp))
                    HotMenuItem(Icons.Filled.Lock, "پنل مدیریت", tc) { menuOpen = false; nav("admin") }
                    HotMenuItem(Icons.Filled.Settings, "تنظیمات", tc) { menuOpen = false; nav("settings") }
                    HotMenuItem(Icons.Filled.Dns, "سرورها", tc) { menuOpen = false; nav("servers") }
                    HotMenuItem(Icons.Filled.Share, "اشتراک‌گذاری", tc) {
                        val i = Intent(Intent.ACTION_SEND).apply {
                            type = "text/plain"; putExtra(Intent.EXTRA_TEXT, "PARSA VPN")
                        }
                        ctx.startActivity(Intent.createChooser(i, "Share"))
                    }
                    Spacer(Modifier.weight(1f))
                    Text("Version : 9.1.0", color = sc, fontSize = 12.sp,
                        modifier = Modifier.align(Alignment.CenterHorizontally))
                    Spacer(Modifier.height(20.dp))
                }
            }
        }
    }
}

@Composable
fun HotMenuItem(icon: androidx.compose.ui.graphics.vector.ImageVector, label: String, color: Color, onClick: () -> Unit) {
    Row(Modifier.fillMaxWidth().clickable(onClick = onClick).padding(vertical = 14.dp),
        verticalAlignment = Alignment.CenterVertically) {
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
UI_EOF

echo "✅ App.kt: $(wc -l < App.kt) خط"
rm -f body.txt body_clean.txt
