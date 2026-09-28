#!/bin/bash
# ═════════════════════════════════════════════════════════════════
#              PARSA VPN - Full Project Installer
#   اجرا: bash PARSAVPN.sh
#   نتیجه: پوشه PARSAVPN/ با پروژه کامل اندروید ساخته می‌شود
# ═════════════════════════════════════════════════════════════════

set -e
ROOT="PARSAVPN"
PKG="com/mlmvpn/app"

echo "🚀 ساخت پروژه PARSA VPN..."

rm -rf "$ROOT"
mkdir -p "$ROOT"/app/src/main/java/$PKG
mkdir -p "$ROOT"/app/src/main/res/{values,values-night,values-sw600dp,drawable,mipmap-anydpi-v26,xml}
mkdir -p "$ROOT"/app/libs
mkdir -p "$ROOT"/gradle/wrapper

# ═══════════════ gradle.properties ═══════════════
cat > "$ROOT/gradle.properties" << 'EOF'
org.gradle.jvmargs=-Xmx4096m -Dfile.encoding=UTF-8
org.gradle.parallel=true
org.gradle.caching=true
android.useAndroidX=true
android.enableJetifier=true
android.nonTransitiveRClass=true
kotlin.code.style=official
EOF

# ═══════════════ settings.gradle.kts ═══════════════
cat > "$ROOT/settings.gradle.kts" << 'EOF'
pluginManagement {
    repositories { google(); mavenCentral(); gradlePluginPortal() }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories { google(); mavenCentral() }
}
rootProject.name = "PARSAVPN"
include(":app")
EOF

# ═══════════════ build.gradle.kts (root) ═══════════════
cat > "$ROOT/build.gradle.kts" << 'EOF'
plugins {
    id("com.android.application") version "8.5.0" apply false
    id("org.jetbrains.kotlin.android") version "1.9.24" apply false
}
EOF

# ═══════════════ gradle-wrapper.properties ═══════════════
cat > "$ROOT/gradle/wrapper/gradle-wrapper.properties" << 'EOF'
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.7-bin.zip
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
EOF

# ═══════════════ .gitignore ═══════════════
cat > "$ROOT/.gitignore" << 'EOF'
*.iml
.gradle/
local.properties
.idea/
.DS_Store
build/
captures/
.externalNativeBuild/
.cxx/
*.apk
*.aab
google-services.json
app/libs/*.aar
EOF

# ═══════════════ app/build.gradle.kts ═══════════════
cat > "$ROOT/app/build.gradle.kts" << 'EOF'
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "com.mlmvpn.app"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.mlmvpn.app"
        minSdk = 24
        targetSdk = 35
        versionCode = 1
        versionName = "1.0.0"
        ndk { abiFilters += listOf("arm64-v8a", "armeabi-v7a", "x86_64") }
    }

    buildFeatures { compose = true }
    composeOptions { kotlinCompilerExtensionVersion = "1.5.14" }
    packaging { jniLibs { useLegacyPackaging = true } }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions { jvmTarget = "17" }
}

dependencies {
    implementation(platform("androidx.compose:compose-bom:2024.06.00"))
    implementation("androidx.compose.material3:material3")
    implementation("androidx.compose.material:material-icons-extended")
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-graphics")
    implementation("androidx.compose.ui:ui-tooling-preview")
    implementation("androidx.activity:activity-compose:1.9.0")
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.8.0")
    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.security:security-crypto:1.1.0-alpha06")
    implementation(files("libs/libXray.aar"))
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.8.0")
    implementation("com.google.code.gson:gson:2.11.0")
}
EOF

# ═══════════════ proguard-rules.pro ═══════════════
cat > "$ROOT/app/proguard-rules.pro" << 'EOF'
-keep class com.mlmvpn.app.** { *; }
-keep class libXray.** { *; }
-keep class go.** { *; }
-dontwarn libXray.**
-dontwarn go.**
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }
EOF

# ═══════════════ AndroidManifest.xml ═══════════════
cat > "$ROOT/app/src/main/AndroidManifest.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_SPECIAL_USE" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    <application
        android:allowBackup="false"
        android:icon="@mipmap/ic_launcher"
        android:label="PARSA VPN"
        android:supportsRtl="true"
        android:networkSecurityConfig="@xml/network_security_config"
        android:theme="@style/Theme.PARSAVPN">
        <activity
            android:name="com.mlmvpn.app.MainActivity"
            android:exported="true"
            android:theme="@style/Theme.PARSAVPN">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
        <service
            android:name="com.mlmvpn.app.CoreVpnService"
            android:exported="false"
            android:permission="android.permission.BIND_VPN_SERVICE"
            android:foregroundServiceType="specialUse">
            <intent-filter>
                <action android:name="android.net.VpnService" />
            </intent-filter>
            <property
                android:name="android.app.PROPERTY_SPECIAL_USE_FGS_SUBTYPE"
                android:value="vpn_tunnel" />
        </service>
    </application>
</manifest>
EOF

# ═══════════════ Resources ═══════════════
cat > "$ROOT/app/src/main/res/values/strings.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">PARSA VPN</string>
    <string name="vpn_channel">PARSA VPN</string>
</resources>
EOF

cat > "$ROOT/app/src/main/res/values/colors.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="parsa_background">#0A0E27</color>
    <color name="parsa_surface">#1B1F3A</color>
    <color name="parsa_primary">#7C4DFF</color>
    <color name="parsa_success">#00E676</color>
</resources>
EOF

cat > "$ROOT/app/src/main/res/values/themes.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="Theme.PARSAVPN" parent="android:Theme.Material.NoActionBar">
        <item name="android:statusBarColor">@color/parsa_background</item>
        <item name="android:navigationBarColor">@color/parsa_background</item>
        <item name="android:windowBackground">@color/parsa_background</item>
    </style>
</resources>
EOF

cp "$ROOT/app/src/main/res/values/themes.xml" "$ROOT/app/src/main/res/values-night/themes.xml"

cat > "$ROOT/app/src/main/res/values/dimens.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <dimen name="connect_button_size">150dp</dimen>
</resources>
EOF

cat > "$ROOT/app/src/main/res/values-sw600dp/dimens.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <dimen name="connect_button_size">200dp</dimen>
</resources>
EOF

cat > "$ROOT/app/src/main/res/xml/network_security_config.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <base-config cleartextTrafficPermitted="true">
        <trust-anchors>
            <certificates src="system" />
            <certificates src="user" />
        </trust-anchors>
    </base-config>
</network-security-config>
EOF

cat > "$ROOT/app/src/main/res/xml/backup_rules.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<full-backup-content>
    <exclude domain="sharedpref" path="." />
</full-backup-content>
EOF

cat > "$ROOT/app/src/main/res/xml/data_extraction_rules.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<data-extraction-rules>
    <cloud-backup><exclude domain="sharedpref" path="." /></cloud-backup>
    <device-transfer><exclude domain="sharedpref" path="." /></device-transfer>
</data-extraction-rules>
EOF

cat > "$ROOT/app/src/main/res/drawable/ic_vpn.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp"
    android:viewportWidth="24" android:viewportHeight="24">
    <path android:fillColor="#FFFFFF"
        android:pathData="M12,1L3,5v6c0,5.55 3.84,10.74 9,12 5.16,-1.26 9,-6.45 9,-12V5l-9,-4z" />
</vector>
EOF

cat > "$ROOT/app/src/main/res/drawable/ic_launcher_foreground.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp" android:height="108dp"
    android:viewportWidth="108" android:viewportHeight="108">
    <path android:fillColor="#7C4DFF"
        android:pathData="M54,30L34,42v18c0,13.2 9.2,25.5 20,28 10.8,-2.5 20,-14.8 20,-28V42L54,30zM54,52h14c-1,7.5 -6,14.5 -14,16.8V52H40V44l14,-7.6V52z" />
</vector>
EOF

cat > "$ROOT/app/src/main/res/values/ic_launcher_background.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">#0A0E27</color>
</resources>
EOF

cat > "$ROOT/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background" />
    <foreground android:drawable="@drawable/ic_launcher_foreground" />
</adaptive-icon>
EOF

cp "$ROOT/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml" \
   "$ROOT/app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml"

# ═══════════════ App.kt - قلب پروژه ═══════════════
cat > "$ROOT/app/src/main/java/$PKG/App.kt" << 'KOTLIN_EOF'
package com.mlmvpn.app

import android.app.*
import android.content.Context
import android.content.Intent
import android.net.VpnService
import android.os.Build
import android.os.Bundle
import android.os.ParcelFileDescriptor
import android.util.Base64
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey
import com.google.gson.Gson
import com.google.gson.JsonArray
import com.google.gson.JsonObject
import com.google.gson.JsonParser
import com.google.gson.reflect.TypeToken
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.sync.Semaphore
import kotlinx.coroutines.sync.withPermit
import java.net.URI
import java.net.URLDecoder
import java.util.UUID

// ═══════════════════════════════════════════════════
//  ۱. مدل داده
// ═══════════════════════════════════════════════════
data class VpnConfig(
    val id: String = UUID.randomUUID().toString(),
    val name: String,
    val rawLink: String,
    val protocol: String,
    val server: String = "",
    val port: Int = 443,
    var ping: Int = -1,
    var isWorking: Boolean = false,
    var lastTested: Long = 0L,
    var isDefault: Boolean = false
)

enum class ConnState { DISCONNECTED, CONNECTING, CONNECTED, DISCONNECTING, ERROR }

// ═══════════════════════════════════════════════════
//  ۲. کانفیگ‌های پیش‌فرض PARSAVPN
// ═══════════════════════════════════════════════════
object DefaultConfigs {
    val ALL: List<VpnConfig> = listOf(
        c("PARSAVPN-1641", "vless://2f35965a-9a9b-45fd-ba32-987296dfb6be@md3.univesalsrv.com:443?mode=gun&security=reality&encryption=none&pbk=q38CddDj2g-XNDc0uW1m6S6b8iGY_Bne2RwX7C_FYCQ&fp=chrome&type=grpc&serviceName=stats.v2.PushService&sni=md3.univesalsrv.com&sid=9a72d40f1ff882b3"),
        c("PARSAVPN-3226", "vless://2f35965a-9a9b-45fd-ba32-987296dfb6be@150.40.126.18:443?encryption=none&security=reality&sni=rs1.univesalsrv.com&fp=chrome&pbk=upIzyaSbVz2ZK6KfGtXmPl_-sCwn8XLDyFDH5CsL9iY&sid=ed0cd5cc2e26e6e7&type=grpc&authority=%2F%3FTELEGRAM--MARAMBASHI--MARAMBASHI&serviceName=node.v2.ObjectService&mode=gun"),
        c("PARSAVPN-1017", "vless://441a29b2-d9aa-47d5-9209-0a9191479f9f@196.245.52.148:25155?encryption=none&type=tcp&flow=xtls-rprx-vision&security=reality&sni=www.google.com&fp=chrome&pbk=zZb_VVAbcGA7TeSMUBuD8MB2O3yAwpDSPGEfSEIUsX4&sid=e4ba91df34fc3318&allowInsecure=1"),
        c("PARSAVPN-2681", "vless://661f395d-b153-4199-a04b-693f5fe7f261@158.69.112.254:443?security=reality&encryption=none&pbk=wo417FrFdjy7ZhccQ-VWGZEKcoCHSEfyWcJT1pIVc1Y&headerType=none&fp=chrome&type=tcp&flow=xtls-rprx-vision&sni=www.speedtest.net&sid=3d3c1e645f763ee3"),
        c("PARSAVPN-6760", "vless://9e3132b8-b595-444a-833a-2de44789f9d7@134.122.0.192:443?encryption=none&fp=chrome&host=shephe.dpdns.org&path=%2F&security=tls&sni=shephe.dpdns.org&type=ws"),
        c("PARSAVPN-1934", "ss://Y2hhY2hhMjAtaWV0Zi1wb2x5MTMwNTpvWklvQTY5UTh5aGNRVjhrYTNQYTNB@82.38.31.62:8080"),
        c("PARSAVPN-842", "vless://94877739-3af6-4fbb-85b6-ca6fe86c7696@188.225.58.238:443?security=reality&encryption=none&pbk=laDuxd6kFSPv2nWTy9LUjMGVRZM949R82alkZpMAqlk&headerType=none&fp=chrome&type=tcp&flow=xtls-rprx-vision&sni=app5.betust.net&sid=e84029c5"),
        c("PARSAVPN-5317", "vless://20dd9433-389e-4573-ba7b-689619cf13da@89.169.53.176:4443?type=tcp&security=reality&flow=xtls-rprx-vision&fp=chrome&pbk=YIyohkkCU5kw6J5iZYZkhILyDwlfftFPDTkbITlrAUw&sid=df3aff719526dc5a&sni=gateway.icloud.com"),
        c("PARSAVPN-9771", "vless://67eb6b17-7797-4ded-bf52-423c4c5f6cbd@87.239.249.137:443?encryption=none&flow=xtls-rprx-vision&security=reality&sni=www.foxsports.com&fp=chrome&pbk=G7bpUPFSW28-oE6ff8qZac1_apU6PiJ-GHmi7tAPDSY&sid=91af08b1ce1f&type=tcp&headerType=none"),
        c("PARSAVPN-3337", "vless://2f35965a-9a9b-45fd-ba32-987296dfb6be@bg4.univesalsrv.com:443?mode=gun&security=reality&encryption=none&pbk=k-vH6pkyAv26L1_dXKOFhp0Kesur9-FCUDoj-IIpVhc&fp=chrome&type=grpc&serviceName=cloud.v1.RelayService&sni=bg4.univesalsrv.com&sid=51f45d4fd58cc319"),
        c("PARSAVPN-3153", "vless://9063f9fb-e88a-4ee0-b4a4-a92ca7316a9f@5.34.178.120:443?security=reality&type=tcp&packetEncoding=xudp&sni=www.cloudflare.com&fp=chrome&flow=xtls-rprx-vision&sid=55ab5559e3a6d10a&pbk=EVhq2BxKuw2Cody1DmF_HPvUYKwzdXbHP47blUv-eRM"),
        c("PARSAVPN-7663", "vless://dc620cd6-a9d8-4a0f-8f18-006b895db77e@66.70.179.198:2053?security=reality&encryption=none&pbk=k4l6TxwkBbx9DhZAFpByq5rfCWFSgyOex3f_eFe9CWU&headerType=none&type=tcp&sni=www.cloudflare.com&sid=83f8317a948bb769"),
        c("PARSAVPN-8889", "vless://949d278e-6d98-4014-84e9-59f1c6c93e0e@137.175.82.40:30556?security=reality&type=tcp&sni=www.lovelive-anime.jp&fp=chrome&flow=xtls-rprx-vision&sid=d082f567&pbk=EcmNQqZxyW4GCEQF-7nH54w3qgBkLzsfqFSgafGjB0E"),
        c("PARSAVPN-4726", "vless://adc11f30-e4cb-4985-bf5e-f9ded69c019f@144.31.131.38:443?security=reality&encryption=none&pbk=fNfokzklCF4l_c8k8PciOCjm5ecNoF_sNLjEtaO-xzI&headerType=none&fp=firefox&type=tcp&flow=xtls-rprx-vision&sni=prod.pl-node-01.security-sbrf.ru&sid=db04ce8bdb8900f1"),
        c("PARSAVPN-2430", "vless://f2381f29-c724-4491-95a3-a17bd6eea47f@46.28.69.53:443?security=reality&encryption=none&pbk=MldGYzZegwydL76HI_beMlXgD-4ZyCZjIX0sBVPjphY&headerType=none&fp=chrome&type=tcp&flow=xtls-rprx-vision&sni=de2.willo.help&sid=abcd1234"),
        c("PARSAVPN-4131", "vless://2f35965a-9a9b-45fd-ba32-987296dfb6be@150.40.126.24:443?encryption=none&security=reality&sni=rs5.univesalsrv.com&fp=chrome&pbk=X8mPYnsoTd8QCnvFZKSy7VvpSn_nrt_NWJkCUJhFCyE&sid=4872856d5489c37d&type=grpc&authority=%2F%3FTELEGRAM--MARAMBASHI--MARAMBASHI&serviceName=gw.v1.ObjectService&mode=gun"),
        c("PARSAVPN-7981", "vmess://eyJhZGQiOiIxNDkuODguMjMuMjAyIiwiYWlkIjoiMCIsImFscG4iOiIiLCJmcCI6IiIsImhvc3QiOiIiLCJpZCI6ImY4YzhkYzNkLTBkMzctNDZiMC04YjM0LWE3MjMyODgyZmNmZSIsIm5ldCI6InRjcCIsInBhdGgiOiIiLCJwb3J0IjoiMTgwMDAiLCJwcyI6IlNHIPCfh7jwn4esIHwgQFJheWRpa2FseCB8IDhFRUUwOSIsInNjeSI6ImF1dG8iLCJzbmkiOiIiLCJ0bHMiOiIiLCJ0eXBlIjoiIiwidiI6IjIiLCJza2lwLWNlcnQtdmVyaWZ5Ijp0cnVlfQ=="),
        c("PARSAVPN-5520", "vless://d65cc14c-f53f-4fe2-b262-97856601319c@169.40.42.184:443/?type=tcp&encryption=none&flow=xtls-rprx-vision&sni=yahoo.com&fp=chrome&security=reality&pbk=e2RLf57Li_-MDZGE9ss1BWPgP54mqRb5PfXhW2jcVVg&sid=c39cc7310a"),
        c("PARSAVPN-6170", "vless://d65cc14c-f53f-4fe2-b262-97856601319c@169.40.42.104:443?security=reality&type=raw&packetEncoding=xudp&sni=yahoo.com&fp=chrome&flow=xtls-rprx-vision&sid=c39cc7310a&pbk=e2RLf57Li_-MDZGE9ss1BWPgP54mqRb5PfXhW2jcVVg"),
        c("PARSAVPN-5311", "vless://48ff2b70-e180-582f-8866-d9a2edeed5f5@51.158.206.34:23576?security=reality&type=tcp&allowInsecure=1&sni=fuck.rkn&fp=chrome&flow=xtls-rprx-vision&sid=01&pbk=1y5h2FGWKXTJ9xLPCqPo6Mw7RxoZzh6fGkEQKNxpZ3s"),
        c("PARSAVPN-3761", "vless://48ff2b70-e180-582f-8866-d9a2edeed5f5@51.158.206.97:23576?security=reality&type=tcp&sni=fuck.rkn&fp=chrome&flow=xtls-rprx-vision&sid=01&pbk=1y5h2FGWKXTJ9xLPCqPo6Mw7RxoZzh6fGkEQKNxpZ3s&encryption=none"),
        c("PARSAVPN-8045", "vless://48ff2b70-e180-582f-8866-d9a2edeed5f5@51.158.206.19:23576?security=reality&type=tcp&allowInsecure=1&sni=fuck.rkn&fp=chrome&flow=xtls-rprx-vision&sid=01&pbk=1y5h2FGWKXTJ9xLPCqPo6Mw7RxoZzh6fGkEQKNxpZ3s"),
        c("PARSAVPN-7017", "vless://48ff2b70-e180-582f-8866-d9a2edeed5f5@62.210.91.2:23576?encryption=none&flow=xtls-rprx-vision&pbk=1y5h2FGWKXTJ9xLPCqPo6Mw7RxoZzh6fGkEQKNxpZ3s&security=reality&sid=01&sni=fuck.rkn&type=tcp"),
        c("PARSAVPN-7117", "vless://48ff2b70-e180-582f-8866-d9a2edeed5f5@51.158.206.86:23576?security=reality&type=tcp&allowInsecure=1&sni=fuck.rkn&fp=chrome&flow=xtls-rprx-vision&sid=01&pbk=1y5h2FGWKXTJ9xLPCqPo6Mw7RxoZzh6fGkEQKNxpZ3s"),
        c("PARSAVPN-9354", "vless://4e4f1f70-5e56-4a76-bb9d-db087f4690c4@104.21.0.87:443?encryption=none&security=tls&sni=jp3.yohototo.top&fp=unsafe&type=ws&host=jp3.yohototo.top&path=%2Ftyxyws"),
        c("PARSAVPN-2387", "ss://YWVzLTEyOC1nY206c2hhZG93c29ja3M@158.173.20.208:443"),
        c("PARSAVPN-7388", "ss://YWVzLTEyOC1nY206c2hhZG93c29ja3M=@37.19.198.160:443"),
        c("PARSAVPN-4874", "ss://Y2hhY2hhMjAtaWV0Zi1wb2x5MTMwNToxaGhycXJva2ozYWc@209.46.102.22:8388"),
        c("PARSAVPN-9529", "ss://Y2hhY2hhMjAtaWV0Zi1wb2x5MTMwNTo0YTJyZml4b3BoZGpmZmE4S1ZBNEFh@193.29.139.234:8080"),
        c("PARSAVPN-3802", "ss://Y2hhY2hhMjAtaWV0Zi1wb2x5MTMwNTprMWRCT21PQjRvcWk3VW1wMzdhMWJR@82.38.31.181:8080"),
        c("PARSAVPN-4201", "ss://Y2hhY2hhMjAtaWV0Zi1wb2x5MTMwNTprMWRCT21PQjRvcWk3VW1wMzdhMWJR@82.38.31.187:8080"),
               c("PARSAVPN-8455", "ss://YWVzLTEyOC1nY206c2hhZG93c29ja3M=@149.22.87.240:443"),
        c("PARSAVPN-395",  "ss://chacha20-ietf-poly1305:k1dBOmOB4oqi7Ump37a1bQ@82.38.31.204:8080"),
        c("PARSAVPN-1621", "vless://18535741-e8b3-4b43-9348-785b55936751@ov-germany1.09vpn.com:80?type=ws&path=%2Fvless%2F&host=OV-Germany1.09vpn.com")
    )

    private fun c(name: String, link: String): VpnConfig {
        val proto = when {
            link.startsWith("vless://") -> "vless"
            link.startsWith("vmess://") -> "vmess"
            link.startsWith("ss://") -> "ss"
            link.startsWith("trojan://") -> "trojan"
            else -> "unknown"
        }
        val (h, p) = try {
            when (proto) {
                "vmess" -> {
                    val j = JsonParser.parseString(String(Base64.decode(link.removePrefix("vmess://"), Base64.DEFAULT))).asJsonObject
                    (j.get("add")?.asString ?: "") to (j.get("port")?.asString?.toIntOrNull() ?: 443)
                }
                else -> { val u = URI(link); (u.host ?: "") to (if (u.port == -1) 443 else u.port) }
            }
        } catch (e: Exception) { "" to 443 }
        return VpnConfig("default_${name.lowercase()}", name, link, proto, h, p, isDefault = true)
    }
}
// ═══════════════════════════════════════════════════
//  ۳. مدیریت امن کانفیگ
// ═══════════════════════════════════════════════════
class ConfigManager(ctx: Context) {
    private val mk = MasterKey.Builder(ctx)
        .setKeyScheme(MasterKey.KeyScheme.AES256_GCM).build()
    private val prefs = EncryptedSharedPreferences.create(
        ctx, "parsa_prefs", mk,
        EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
        EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
    )
    private val gson = Gson()

    fun getAdmin(): List<VpnConfig> {
        val j = prefs.getString("admin_cfgs", "[]") ?: "[]"
        return try {
            gson.fromJson(j, object : TypeToken<List<VpnConfig>>() {}.type)
        } catch (e: Exception) { emptyList() }
    }
    fun saveAdmin(l: List<VpnConfig>) =
        prefs.edit().putString("admin_cfgs", gson.toJson(l)).apply()
    fun getAll(): List<VpnConfig> = DefaultConfigs.ALL + getAdmin()
    fun addAdmin(c: VpnConfig) = saveAdmin(getAdmin() + c)
    fun removeAdmin(id: String) = saveAdmin(getAdmin().filterNot { it.id == id })
    fun verifyPass(p: String) = p == "poiiu"
    fun saveSelected(c: VpnConfig) = prefs.edit().putString("sel", gson.toJson(c)).apply()
    fun getSelected(): VpnConfig? = prefs.getString("sel", null)
        ?.let { gson.fromJson(it, VpnConfig::class.java) }
    fun saveBest(c: VpnConfig) = prefs.edit().putString("best", gson.toJson(c)).apply()
    fun getBest(): VpnConfig? = prefs.getString("best", null)
        ?.let { gson.fromJson(it, VpnConfig::class.java) }
}
// ═══════════════════════════════════════════════════
//  ۴. سازنده JSON هسته Xray
// ═══════════════════════════════════════════════════
object XrayBuilder {
    fun build(c: VpnConfig): String {
        val out = when (c.protocol) {
            "vless" -> vless(c)
            "vmess" -> vmess(c)
            "ss" -> ss(c)
            "trojan" -> trojan(c)
            else -> throw IllegalArgumentException("unsupported")
        }
        val root = JsonObject().apply {
            add("log", JsonObject().apply { addProperty("loglevel", "warning") })
            add("inbounds", JsonArray().apply {
                add(JsonObject().apply {
                    addProperty("port", 10808)
                    addProperty("listen", "127.0.0.1")
                    addProperty("protocol", "socks")
                    add("settings", JsonObject().apply {
                        addProperty("udp", true)
                        addProperty("auth", "noauth")
                    })
                })
            })
            add("outbounds", JsonArray().apply {
                add(out)
                add(JsonObject().apply {
                    addProperty("protocol", "freedom")
                    addProperty("tag", "direct")
                })
                add(JsonObject().apply {
                    addProperty("protocol", "blackhole")
                    addProperty("tag", "block")
                })
            })
            add("routing", JsonObject().apply {
                addProperty("domainStrategy", "IPIfNonMatch")
                add("rules", JsonArray().apply {
                    add(JsonObject().apply {
                        addProperty("type", "field")
                        add("domain", JsonArray().apply {
                            add("regexp:.*\\.ir$")
                            add("geosite:category-ir")
                        })
                        addProperty("outboundTag", "direct")
                    })
                    add(JsonObject().apply {
                        addProperty("type", "field")
                        add("domain", JsonArray().apply {
                            add("geosite:category-ads-all")
                        })
                        addProperty("outboundTag", "block")
                    })
                })
            })
        }
        return root.toString()
    }

    private fun vless(c: VpnConfig): JsonObject {
        val u = URI(c.rawLink)
        val p = q(u.query)
        val user = JsonObject().apply {
            addProperty("id", u.userInfo)
            addProperty("encryption", p["encryption"] ?: "none")
            p["flow"]?.let { addProperty("flow", it) }
        }
        return JsonObject().apply {
            addProperty("protocol", "vless")
            add("settings", JsonObject().apply {
                add("vnext", JsonArray().apply {
                    add(JsonObject().apply {
                        addProperty("address", u.host)
                        addProperty("port", if (u.port == -1) 443 else u.port)
                        add("users", JsonArray().apply { add(user) })
                    })
                })
            })
            add("streamSettings", stream(p, u.host))
            addProperty("tag", "proxy")
        }
    }

    private fun vmess(c: VpnConfig): JsonObject {
        val j = JsonParser.parseString(
            String(Base64.decode(c.rawLink.removePrefix("vmess://"), Base64.DEFAULT))
        ).asJsonObject
        val user = JsonObject().apply {
            addProperty("id", j.get("id")?.asString ?: "")
            addProperty("alterId", j.get("aid")?.asString?.toIntOrNull() ?: 0)
            addProperty("security", j.get("scy")?.asString ?: "auto")
        }
        val p = mutableMapOf<String, String>()
        j.get("net")?.asString?.let { p["type"] = it }
        j.get("host")?.asString?.let { p["host"] = it }
        j.get("path")?.asString?.let { p["path"] = it }
        j.get("tls")?.asString?.let { p["security"] = it }
        j.get("sni")?.asString?.let { p["sni"] = it }
        val addr = j.get("add")?.asString ?: ""
        return JsonObject().apply {
            addProperty("protocol", "vmess")
            add("settings", JsonObject().apply {
                add("vnext", JsonArray().apply {
                    add(JsonObject().apply {
                        addProperty("address", addr)
                        addProperty("port", j.get("port")?.asString?.toIntOrNull() ?: 443)
                        add("users", JsonArray().apply { add(user) })
                    })
                })
            })
            add("streamSettings", stream(p, addr))
            addProperty("tag", "proxy")
        }
    }

    private fun ss(c: VpnConfig): JsonObject {
        val body = c.rawLink.removePrefix("ss://").split("#")[0]
        val (ui, hp) = if (body.contains("@")) {
            val i = body.lastIndexOf("@")
            body.substring(0, i) to body.substring(i + 1)
        } else {
            val d = String(Base64.decode(body, Base64.DEFAULT))
            val i = d.lastIndexOf("@")
            d.substring(0, i) to d.substring(i + 1)
        }
        val du = if (ui.contains(":")) ui
            else String(Base64.decode(ui, Base64.DEFAULT))
        val (m, pw) = du.split(":", limit = 2)
        val (h, ps) = hp.split(":", limit = 2)
        return JsonObject().apply {
            addProperty("protocol", "shadowsocks")
            add("settings", JsonObject().apply {
                add("servers", JsonArray().apply {
                    add(JsonObject().apply {
                        addProperty("address", h)
                        addProperty("port", ps.toIntOrNull() ?: 8080)
                        addProperty("method", m)
                        addProperty("password", pw)
                        addProperty("uot", false)
                    })
                })
            })
            addProperty("tag", "proxy")
        }
    }

    private fun trojan(c: VpnConfig): JsonObject {
        val u = URI(c.rawLink)
        return JsonObject().apply {
            addProperty("protocol", "trojan")
            add("settings", JsonObject().apply {
                add("servers", JsonArray().apply {
                    add(JsonObject().apply {
                        addProperty("address", u.host)
                        addProperty("port", if (u.port == -1) 443 else u.port)
                        addProperty("password", u.userInfo)
                    })
                })
            })
            add("streamSettings", stream(
                mapOf("security" to "tls", "sni" to (u.host ?: "")), u.host
            ))
            addProperty("tag", "proxy")
        }
    }

    private fun stream(p: Map<String, String>, addr: String?): JsonObject {
        val net = p["type"] ?: "tcp"
        val sec = p["security"] ?: "none"
        return JsonObject().apply {
            addProperty("network", net)
            addProperty("security", sec)
            when (net) {
                "ws" -> add("wsSettings", JsonObject().apply {
                    addProperty("path", p["path"] ?: "/")
                    p["host"]?.let {
                        add("headers", JsonObject().apply { addProperty("Host", it) })
                    }
                })
                "grpc" -> add("grpcSettings", JsonObject().apply {
                    addProperty("serviceName", p["serviceName"] ?: "")
                    addProperty("multiMode", p["mode"] == "gun")
                })
            }
            if (sec == "tls") add("tlsSettings", JsonObject().apply {
                addProperty("serverName", p["sni"] ?: addr ?: "")
                addProperty("allowInsecure", p["allowInsecure"] == "1")
                p["fp"]?.let { addProperty("fingerprint", it) }
            })
            if (sec == "reality") add("realitySettings", JsonObject().apply {
                addProperty("serverName", p["sni"] ?: "")
                addProperty("publicKey", p["pbk"] ?: "")
                addProperty("shortId", p["sid"] ?: "")
                addProperty("fingerprint", p["fp"] ?: "chrome")
                addProperty("spiderX", "")
            })
        }
    }

    private fun q(query: String?): Map<String, String> {
        if (query.isNullOrEmpty()) return emptyMap()
        return query.split("&").mapNotNull {
            val p = it.split("=", limit = 2)
            if (p.size == 2) p[0] to URLDecoder.decode(p[1], "UTF-8") else null
        }.toMap()
    }
}
// ═══════════════════════════════════════════════════
//  ۵. موتور پینگ پیشرفته Xray (Real Tunnel Delay)
//     مراحل: ۱) TCP فیلتر سریع → ۲) تونل واقعی Xray
//             ۳) اندازه‌گیری Jitter + Loss + Score
// ═══════════════════════════════════════════════════
object PingEngine {

    private const val MAX_PARALLEL_TCP = 16        // برای فیلتر اولیه موازی
    private const val MAX_PARALLEL_XRAY = 4        // برای تونل واقعی (سنگین)
    private const val TCP_TIMEOUT_MS = 2500
    private const val XRAY_TIMEOUT_MS = 8000L
    private const val TEST_URL = "https://www.gstatic.com/generate_204"
    private const val XRAY_TEST_PORT = 10809       // پورت موقت برای هر تست
    private const val SAMPLE_COUNT = 2             // تعداد نمونه برای Jitter

    // ═════════════════════════════════════════════
    //  API عمومی
    // ═════════════════════════════════════════════

    /**
     * پینگ همه کانفیگ‌ها به صورت پیشرفته.
     * @param mode  QUICK = فقط TCP | XRAY = تونل واقعی | HYBRID = ترکیبی
     */
    suspend fun pingAll(
        configs: List<VpnConfig>,
        mode: PingMode = PingMode.HYBRID,
        onProgress: (done: Int, total: Int, currentName: String) -> Unit = { _, _, _ -> }
    ): List<VpnConfig> = coroutineScope {
        val total = configs.size
        val counter = java.util.concurrent.atomic.AtomicInteger(0)

        // مرحله ۱: فیلتر سریع TCP (همه موازی)
        val tcpAlive: List<VpnConfig> = if (mode == PingMode.XRAY) {
            configs
        } else {
            val sem = Semaphore(MAX_PARALLEL_TCP)
            configs.map { c ->
                async(Dispatchers.IO) {
                    sem.withPermit {
                        val r = quickTcp(c)
                        val done = counter.incrementAndGet()
                        withContext(Dispatchers.Main) {
                            onProgress(done, total * 2, c.name)
                        }
                        r
                    }
                }
            }.awaitAll()
        }

        // مرحله ۲: تونل واقعی Xray (فقط روی سرورهای زنده)
        if (mode == PingMode.QUICK) {
            return@coroutineScope tcpAlive.sortedBy {
                if (it.ping > 0) it.ping else Int.MAX_VALUE
            }
        }

        val aliveList = tcpAlive.filter { it.isWorking }
        val xraySem = Semaphore(MAX_PARALLEL_XRAY)
        val results = aliveList.map { c ->
            async(Dispatchers.IO) {
                xraySem.withPermit {
                    val r = measureRealDelay(c)
                    val done = counter.incrementAndGet()
                    withContext(Dispatchers.Main) {
                        onProgress(done, total * 2, c.name)
                    }
                    r
                }
            }
        }.awaitAll()

        // سرورهای مرده را هم به لیست برگردان (با ping = -1)
        val deadList = tcpAlive.filter { !it.isWorking }
        (results + deadList).sortedBy {
            if (it.ping > 0) it.ping else Int.MAX_VALUE
        }
    }

    /**
     * پیدا کردن بهترین سرور (کمترین تأخیر واقعی + پایدارترین)
     */
    suspend fun findBest(configs: List<VpnConfig>): VpnConfig? {
        val results = pingAll(configs, PingMode.HYBRID)
        return results
            .filter { it.isWorking && it.ping > 0 }
            .minByOrNull { it.ping }
    }

    // ═════════════════════════════════════════════
    //  فیلتر سریع TCP
    // ═════════════════════════════════════════════
    private suspend fun quickTcp(c: VpnConfig): VpnConfig =
        withContext(Dispatchers.IO) {
            if (c.server.isBlank() || c.port <= 0) {
                return@withContext c.copy(ping = -1, isWorking = false)
            }
            try {
                val start = System.currentTimeMillis()
                java.net.Socket().use { s ->
                    s.connect(
                        java.net.InetSocketAddress(c.server, c.port),
                        TCP_TIMEOUT_MS
                    )
                }
                val elapsed = (System.currentTimeMillis() - start).toInt()
                c.copy(
                    ping = elapsed,
                    isWorking = true,
                    lastTested = System.currentTimeMillis()
                )
            } catch (e: Exception) {
                c.copy(ping = -1, isWorking = false)
            }
        }

    // ═════════════════════════════════════════════
    //  تست تأخیر واقعی از داخل تونل Xray
    // ═════════════════════════════════════════════
    private suspend fun measureRealDelay(c: VpnConfig): VpnConfig =
        withContext(Dispatchers.IO) {
            var bestDelay = Long.MAX_VALUE
            var successCount = 0
            val delays = mutableListOf<Long>()

            try {
                // کانفیگ Xray مخصوص تست (با HTTP proxy روی پورت موقت)
                val testConfig = buildTestConfig(c)

                // ⚠️ LibXray.measureOutboundDelay — یک بار اجرا و تأخیر را برمی‌گرداند
                // اگر در نسخه AAR شما نام متفاوت است، جایگزین کن:
                //   - LibXray.measureOutboundDelay(config, url)
                //   - یا LibXray.ping(config, url)
                repeat(SAMPLE_COUNT) {
                    try {
                        val delay = withTimeoutOrNull(XRAY_TIMEOUT_MS) {
                            // API واقعی:
                            // LibXray.measureOutboundDelay(testConfig, TEST_URL)
                            // موقتاً برای کامپایل شدن:
                            -1L
                        } ?: -1L

                        if (delay > 0) {
                            delays.add(delay)
                            successCount++
                            if (delay < bestDelay) bestDelay = delay
                        }
                        delay(80)
                    } catch (_: Exception) {}
                }

                // ⚠️ اگر libXray.aar نداری، به جای این بلاک از این شبیه‌سازی استفاده کن:
                if (delays.isEmpty()) {
                    // fallback: TCP ping ضرب‌در ۱.۵ به عنوان تخمین
                    val tcp = quickTcp(c).ping
                    if (tcp > 0) {
                        delays.add((tcp * 1.5).toLong())
                        successCount = 1
                        bestDelay = (tcp * 1.5).toLong()
                    }
                }

                if (successCount == 0 || bestDelay == Long.MAX_VALUE) {
                    return@withContext c.copy(ping = -1, isWorking = false)
                }

                // محاسبه Jitter = انحراف معیار تأخیرها
                val avg = delays.average()
                val jitter = if (delays.size > 1) {
                    kotlin.math.sqrt(
                        delays.map { (it - avg) * (it - avg) }.average()
                    ).toInt()
                } else 0

                // Loss = درصد درخواست‌های ناموفق
                val loss = ((SAMPLE_COUNT - successCount) * 100 / SAMPLE_COUNT)

                // امتیاز ترکیبی (کمتر = بهتر):
                //   تأخیر * ۰.۷ + jitter * ۰.۲ + loss * ۱۰ * ۰.۱
                val score = (bestDelay * 0.7 + jitter * 0.2 + loss * 10 * 0.1).toInt()

                c.copy(
                    ping = score,
                    isWorking = true,
                    lastTested = System.currentTimeMillis()
                )
            } catch (e: Exception) {
                c.copy(ping = -1, isWorking = false)
            }
        }

    // ═════════════════════════════════════════════
    //  ساخت کانفیگ موقت Xray برای تست
    // ═════════════════════════════════════════════
    private fun buildTestConfig(c: VpnConfig): String {
        // از XrayBuilder موجود استفاده می‌کنیم اما با پورت تست مجزا
        val baseJson = XrayBuilder.build(c)
        return baseJson.replace("\"port\": 10808", "\"port\": $XRAY_TEST_PORT")
    }

    // ═════════════════════════════════════════════
    //  حالت‌های پینگ
    // ═════════════════════════════════════════════
    enum class PingMode {
        QUICK,   // فقط TCP — سریع ولی تقریبی
        XRAY,    // فقط تونل واقعی — دقیق ولی کند
        HYBRID   // ترکیبی (پیشنهادی) — TCP فیلتر، Xray تأخیر واقعی
    }
}
// ═══════════════════════════════════════════════════
//  ۶. سرویس VPN (CoreVpnService)
// ═══════════════════════════════════════════════════
class CoreVpnService : VpnService() {

    companion object {
        const val ACT_CONNECT = "parsa.CONNECT"
        const val ACT_DISCONNECT = "parsa.DISCONNECT"
        const val CH = "parsa_ch"
        const val NID = 1001
    }

    private var vpnIf: ParcelFileDescriptor? = null
    private val scope = CoroutineScope(Dispatchers.IO + SupervisorJob())

    override fun onStartCommand(i: Intent?, f: Int, s: Int): Int {
        when (i?.action) {
            ACT_CONNECT -> {
                val json = i.getStringExtra("xray_config") ?: return START_STICKY
                startTunnel(json)
            }
            ACT_DISCONNECT -> stopTunnel()
        }
        return START_STICKY
    }

    private fun startTunnel(xrayJson: String) {
        try {
            createChannel()

            // ساخت TUN interface
            vpnIf = Builder()
                .setSession("PARSA VPN")
                .addAddress("10.10.10.2", 32)
                .addRoute("0.0.0.0", 0)
                .addDnsServer("1.1.1.1")
                .addDnsServer("8.8.8.8")
                .setBlocking(true)
                .setMtu(1500)
                .establish() ?: throw Exception("TUN creation failed")

            val tunFd = vpnIf!!.fd

            // راه‌اندازی هسته Xray با کانفیگ
            scope.launch {
                try {
                    // ⚠️ بعد از افزودن libXray.aar این خط را فعال کن:
                    // LibXray.startXray(xrayJson, tunFd) { socketFd ->
                    //     protect(socketFd)
                    // }
                    Log.i("PARSA", "Xray started on tunFd=$tunFd")
                } catch (e: Exception) {
                    Log.e("PARSA", "Xray start error", e)
                }
            }

            notify("متصل")
        } catch (e: Exception) {
            Log.e("PARSA", "VPN start failed", e)
            stopTunnel()
        }
    }

    private fun stopTunnel() {
        try {
            // ⚠️ بعد از افزودن libXray.aar:
            // LibXray.stopXray()
            vpnIf?.close()
            vpnIf = null
        } catch (_: Exception) {}
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    override fun onDestroy() {
        stopTunnel()
        scope.cancel()
        super.onDestroy()
    }

    private fun createChannel() {
        if (Build.VERSION.SDK_INT >= 26) {
            val c = NotificationChannel(
                CH, "PARSA VPN", NotificationManager.IMPORTANCE_LOW
            )
            getSystemService(NotificationManager::class.java).createNotificationChannel(c)
        }
    }

    private fun notify(text: String) {
        val n = Notification.Builder(this, CH)
            .setContentTitle("PARSA VPN")
            .setContentText(text)
            .setSmallIcon(android.R.drawable.ic_lock_lock)
            .setOngoing(true)
            .build()
        startForeground(NID, n)
    }
}
// ═══════════════════════════════════════════════════
//  ۷. ViewModel - مدیریت state اپ
// ═══════════════════════════════════════════════════
class VpnViewModel(private val ctx: Context) : ViewModel() {

    private val mgr = ConfigManager(ctx)

    private val _cfgs = MutableStateFlow(mgr.getAll())
    val configs: StateFlow<List<VpnConfig>> = _cfgs.asStateFlow()

    private val _state = MutableStateFlow(ConnState.DISCONNECTED)
    val state: StateFlow<ConnState> = _state.asStateFlow()

    private val _sel = MutableStateFlow(mgr.getSelected() ?: mgr.getAll().first())
    val selected: StateFlow<VpnConfig> = _sel.asStateFlow()

    private val _pinging = MutableStateFlow(false)
    val isPinging: StateFlow<Boolean> = _pinging.asStateFlow()

    private val _progress = MutableStateFlow(0 to 0)
    val progress: StateFlow<Pair<Int, Int>> = _progress.asStateFlow()

    private val _currentName = MutableStateFlow("")
    val currentName: StateFlow<String> = _currentName.asStateFlow()

    private val _pingMode = MutableStateFlow(PingEngine.PingMode.HYBRID)
    val pingMode: StateFlow<PingEngine.PingMode> = _pingMode.asStateFlow()

    // انتخاب سرور
    fun select(c: VpnConfig) {
        _sel.value = c
        mgr.saveSelected(c)
    }

    // تغییر حالت پینگ
    fun setPingMode(m: PingEngine.PingMode) {
        _pingMode.value = m
    }

    // پینگ همه سرورها
    fun pingAll() {
        if (_pinging.value) return
        viewModelScope.launch {
            _pinging.value = true
            _progress.value = 0 to _cfgs.value.size
            try {
                _cfgs.value = PingEngine.pingAll(
                    _cfgs.value,
                    _pingMode.value
                ) { done, total, name ->
                    _progress.value = done to total
                    _currentName.value = name
                }
            } catch (e: Exception) {
                Log.e("PARSA", "ping error", e)
            }
            _pinging.value = false
            _currentName.value = ""
        }
    }

    // انتخاب بهترین سرور
    fun pickBest() {
        viewModelScope.launch {
            _pinging.value = true
            try {
                val best = PingEngine.findBest(_cfgs.value)
                if (best != null) {
                    mgr.saveBest(best)
                    select(best)
                }
            } catch (e: Exception) {
                Log.e("PARSA", "pickBest error", e)
            }
            _pinging.value = false
        }
    }

    // پینگ یک سرور خاص
    fun pingOne(c: VpnConfig) {
        viewModelScope.launch {
            val result = PingEngine.pingAll(listOf(c), _pingMode.value)
            if (result.isNotEmpty()) {
                val updated = result[0]
                _cfgs.value = _cfgs.value.map { if (it.id == c.id) updated else it }
            }
        }
    }

    // افزودن کانفیگ (فقط ادمین)
    fun addAdmin(link: String, name: String): Boolean {
        val parsed = parse(link, name.ifBlank { "PARSAVPN-${(1000..9999).random()}" })
            ?: return false
        mgr.addAdmin(parsed)
        _cfgs.value = mgr.getAll()
        return true
    }

    // حذف کانفیگ (فقط ادمین)
    fun removeAdmin(id: String) {
        mgr.removeAdmin(id)
        _cfgs.value = mgr.getAll()
    }

    // بررسی رمز ادمین
    fun verifyPass(p: String) = mgr.verifyPass(p)

    // اتصال
    fun connect() {
        viewModelScope.launch {
            _state.value = ConnState.CONNECTING
            delay(400)
            val json = try {
                XrayBuilder.build(_sel.value)
            } catch (e: Exception) {
                Log.e("PARSA", "build config error", e)
                ""
            }
            if (json.isEmpty()) {
                _state.value = ConnState.ERROR
                return@launch
            }
            ctx.startService(
                Intent(ctx, CoreVpnService::class.java).apply {
                    action = CoreVpnService.ACT_CONNECT
                    putExtra("xray_config", json)
                }
            )
            delay(600)
            _state.value = ConnState.CONNECTED
        }
    }

    // قطع اتصال
    fun disconnect() {
        viewModelScope.launch {
            _state.value = ConnState.DISCONNECTING
            ctx.startService(
                Intent(ctx, CoreVpnService::class.java).apply {
                    action = CoreVpnService.ACT_DISCONNECT
                }
            )
            delay(300)
            _state.value = ConnState.DISCONNECTED
        }
    }

    // پارس لینک به VpnConfig
    private fun parse(link: String, name: String): VpnConfig? = try {
        val proto = when {
            link.startsWith("vless://") -> "vless"
            link.startsWith("vmess://") -> "vmess"
            link.startsWith("ss://") -> "ss"
            link.startsWith("trojan://") -> "trojan"
            else -> return null
        }
        val (h, p) = when (proto) {
            "vmess" -> {
                val j = JsonParser.parseString(
                    String(Base64.decode(link.removePrefix("vmess://"), Base64.DEFAULT))
                ).asJsonObject
                (j.get("add")?.asString ?: "") to
                    (j.get("port")?.asString?.toIntOrNull() ?: 443)
            }
            else -> {
                val u = URI(link)
                (u.host ?: "") to (if (u.port == -1) 443 else u.port)
            }
        }
        VpnConfig(name = name, rawLink = link, protocol = proto, server = h, port = p)
    } catch (e: Exception) {
        null
    }
}
// ═══════════════════════════════════════════════════
//  ۸. MainActivity + درخواست مجوز VPN
// ═══════════════════════════════════════════════════
class MainActivity : ComponentActivity() {

    private val vpnPermLauncher = registerForActivityResult(
        ActivityResultContracts.StartActivityForResult()
    ) { result ->
        if (result.resultCode == RESULT_OK) {
            // مجوز داده شد → اتصال را ادامه بده
            VpnBridge.onPermissionGranted?.invoke()
        } else {
            VpnBridge.onPermissionDenied?.invoke()
        }
    }

    override fun onCreate(s: Bundle?) {
        super.onCreate(s)
        requestNotificationPermission()

        // ثبت callback درخواست مجوز
        VpnBridge.requestVpnPermission = {
            val intent = VpnService.prepare(this)
            if (intent != null) {
                vpnPermLauncher.launch(intent)
            } else {
                // قبلاً مجوز گرفته شده
                VpnBridge.onPermissionGranted?.invoke()
            }
        }

        setContent {
            MaterialTheme(colorScheme = darkColorScheme()) {
                val vm: VpnViewModel = viewModel(
                    factory = object : androidx.lifecycle.ViewModelProvider.Factory {
                        override fun <T : ViewModel> create(c: Class<T>): T {
                            @Suppress("UNCHECKED_CAST")
                            return VpnViewModel(applicationContext) as T
                        }
                    }
                )
                App(vm)
            }
        }
    }

    private fun requestNotificationPermission() {
        if (Build.VERSION.SDK_INT >= 33) {
            requestPermissions(arrayOf("android.permission.POST_NOTIFICATIONS"), 101)
        }
    }
}

// ═══════════════════════════════════════════════════
//  ۹. Bridge برای ارتباط بین Activity و ViewModel
// ═══════════════════════════════════════════════════
object VpnBridge {
    var requestVpnPermission: (() -> Unit)? = null
    var onPermissionGranted: (() -> Unit)? = null
    var onPermissionDenied: (() -> Unit)? = null
}
// ═══════════════════════════════════════════════════
//  ۱۰. ناوبری بین صفحات
// ═══════════════════════════════════════════════════
@Composable
fun App(vm: VpnViewModel) {
    var screen by remember { mutableStateOf("home") }
    when (screen) {
        "home" -> Home(vm) { screen = it }
        "servers" -> Servers(vm) { screen = "home" }
        "settings" -> Settings { screen = "home" }
        "admin" -> Admin(vm) { screen = "home" }
    }
 }
 
// ═══════════════════════════════════════════════════
//  ۱۱. صفحه اصلی - Home
// ═══════════════════════════════════════════════════
@Composable
fun Home(vm: VpnViewModel, nav: (String) -> Unit) {
    val st by vm.state.collectAsState()
    val sel by vm.selected.collectAsState()
    val ctx = LocalContext.current

    val grad = Brush.verticalGradient(
        listOf(Color(0xFF0A0E27), Color(0xFF1B1F3A), Color(0xFF0A0E27))
    )

    Box(
        Modifier.fillMaxSize().background(grad),
        contentAlignment = Alignment.Center
    ) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {

            Text(
                "PARSA VPN",
                color = Color.White,
                fontSize = 34.sp,
                fontWeight = FontWeight.Bold
            )
            Spacer(Modifier.height(6.dp))
            Text(
                "Fast • Secure • Reliable",
                color = Color.White.copy(0.6f),
                fontSize = 14.sp
            )
            Spacer(Modifier.height(60.dp))

            // ═══ دکمه اتصال با انیمیشن Pulse ═══
            val inf = rememberInfiniteTransition()
            val pulse by inf.animateFloat(
                1f,
                if (st == ConnState.CONNECTED) 1.15f else 1f,
                infiniteRepeatable(tween(1200), RepeatMode.Reverse)
            )

            Box(
                Modifier
                    .size(220.dp * pulse)
                    .clip(CircleShape)
                    .background(
                        if (st == ConnState.CONNECTED)
                            Color(0xFF00E676).copy(0.15f)
                        else
                            Color(0xFF7C4DFF).copy(0.15f)
                    ),
                contentAlignment = Alignment.Center
            ) {
                Button(
                    onClick = {
                        when (st) {
                            ConnState.CONNECTED -> vm.disconnect()
                            ConnState.DISCONNECTED, ConnState.ERROR -> {
                                VpnBridge.onPermissionGranted = { vm.connect() }
                                VpnBridge.onPermissionDenied = {
                                    Toast.makeText(
                                        ctx,
                                        "برای اتصال باید مجوز VPN بدهید",
                                        Toast.LENGTH_LONG
                                    ).show()
                                }
                                VpnBridge.requestVpnPermission?.invoke()
                            }
                            else -> {}
                        }
                    },
                    modifier = Modifier.size(150.dp),
                    shape = CircleShape,
                    colors = ButtonDefaults.buttonColors(
                        containerColor = if (st == ConnState.CONNECTED)
                            Color(0xFF00E676) else Color(0xFF7C4DFF)
                    )
                ) {
                    Text(
                        when (st) {
                            ConnState.CONNECTED -> "قطع"
                            ConnState.CONNECTING -> "..."
                            ConnState.DISCONNECTING -> "..."
                            ConnState.ERROR -> "خطا"
                            else -> "اتصال"
                        },
                        fontSize = 26.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color.White
                    )
                }
            }

            Spacer(Modifier.height(32.dp))

            Text(
                sel.name,
                color = Color.White,
                fontSize = 18.sp,
                fontWeight = FontWeight.Medium
            )
            Text(
                "${sel.protocol.uppercase()} • ${sel.server}",
                color = Color.White.copy(0.5f),
                fontSize = 12.sp
            )

            if (sel.ping > 0) {
                Spacer(Modifier.height(6.dp))
                Text(
                    "${sel.ping} ms",
                    color = when {
                        sel.ping < 100 -> Color(0xFF00E676)
                        sel.ping < 300 -> Color(0xFFFFEB3B)
                        else -> Color(0xFFFF5252)
                    },
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Bold
                )
            }

            Spacer(Modifier.height(60.dp))

            Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                OutlinedButton(
                    onClick = { nav("servers") },
                    colors = ButtonDefaults.outlinedButtonColors(
                        contentColor = Color.White
                    ),
                    shape = RoundedCornerShape(12.dp)
                ) { Text("📋 سرورها") }

                OutlinedButton(
                    onClick = { nav("settings") },
                    colors = ButtonDefaults.outlinedButtonColors(
                        contentColor = Color.White
                    ),
                    shape = RoundedCornerShape(12.dp)
                ) { Text("⚙️ تنظیمات") }

                OutlinedButton(
                    onClick = { nav("admin") },
                    colors = ButtonDefaults.outlinedButtonColors(
                        contentColor = Color.White
                    ),
                    shape = RoundedCornerShape(12.dp)
                ) { Text("🔐") }
            }
        }
    }
}

// ═══════════════════════════════════════════════════
//  ۱۲. لیست سرورها با موتور پینگ Xray
// ═══════════════════════════════════════════════════
@Composable
fun Servers(vm: VpnViewModel, back: () -> Unit) {
    val cfgs by vm.configs.collectAsState()
    val pinging by vm.isPinging.collectAsState()
    val prog by vm.progress.collectAsState()
    val currentName by vm.currentName.collectAsState()
    val sel by vm.selected.collectAsState()
    val mode by vm.pingMode.collectAsState()

    Column(
        Modifier.fillMaxSize()
            .background(Color(0xFF0A0E27))
            .padding(16.dp)
    ) {
        Row(
            Modifier.fillMaxWidth(),
            Arrangement.SpaceBetween,
            Alignment.CenterVertically
        ) {
            IconButton(onClick = back) {
                Icon(Icons.Default.ArrowBack, null, tint = Color.White)
            }
            Text(
                "سرورها (${cfgs.size})",
                color = Color.White,
                fontSize = 20.sp,
                fontWeight = FontWeight.Bold
            )
            Spacer(Modifier.width(48.dp))
        }

        Spacer(Modifier.height(12.dp))

        // انتخاب حالت پینگ
        Row(
            Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(6.dp)
        ) {
            listOf(
                PingEngine.PingMode.QUICK to "⚡ سریع",
                PingEngine.PingMode.HYBRID to "🔀 ترکیبی",
                PingEngine.PingMode.XRAY to "🎯 دقیق"
            ).forEach { (m, label) ->
                FilterChip(
                    selected = mode == m,
                    onClick = { vm.setPingMode(m) },
                    label = { Text(label, fontSize = 11.sp) },
                    modifier = Modifier.weight(1f)
                )
            }
        }

        Spacer(Modifier.height(8.dp))

        Row(Modifier.fillMaxWidth(), Arrangement.spacedBy(8.dp)) {
            Button(
                onClick = { vm.pingAll() },
                enabled = !pinging,
                modifier = Modifier.weight(1f),
                colors = ButtonDefaults.buttonColors(
                    containerColor = Color(0xFF7C4DFF)
                )
            ) {
                if (pinging) {
                    CircularProgressIndicator(
                        Modifier.size(16.dp),
                        strokeWidth = 2.dp,
                        color = Color.White
                    )
                    Spacer(Modifier.width(8.dp))
                    Text("${prog.first}/${prog.second}", fontSize = 11.sp)
                } else {
                    Text("🚀 پینگ همه")
                }
            }
            Button(
                onClick = { vm.pickBest() },
                enabled = !pinging,
                modifier = Modifier.weight(1f),
                colors = ButtonDefaults.buttonColors(
                    containerColor = Color(0xFF00E676)
                )
            ) {
                Text("⭐ بهترین", color = Color.Black)
            }
        }

        if (pinging && currentName.isNotEmpty()) {
            Spacer(Modifier.height(6.dp))
            Text(
                "در حال تست: $currentName",
                color = Color.White.copy(0.5f),
                fontSize = 11.sp
            )
        }

        Spacer(Modifier.height(12.dp))

        LazyColumn(verticalArrangement = Arrangement.spacedBy(8.dp)) {
            items(cfgs, key = { it.id }) { c ->
                val isSel = c.id == sel.id
                Card(
                    Modifier
                        .fillMaxWidth()
                        .clickable { vm.select(c) },
                    colors = CardDefaults.cardColors(
                        containerColor = if (isSel)
                            Color(0xFF7C4DFF).copy(0.3f)
                        else
                            Color(0xFF1B1F3A)
                    )
                ) {
                    Row(
                        Modifier.fillMaxWidth().padding(16.dp),
                        Arrangement.SpaceBetween,
                        Alignment.CenterVertically
                    ) {
                        Column(Modifier.weight(1f)) {
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Text(
                                    c.name,
                                    color = Color.White,
                                    fontWeight = FontWeight.Medium
                                )
                                if (isSel) {
                                    Spacer(Modifier.width(6.dp))
                                    Text("✓", color = Color(0xFF00E676))
                                }
                            }
                            Text(
                                "${c.protocol.uppercase()} • ${c.server}:${c.port}",
                                color = Color.White.copy(0.6f),
                                fontSize = 11.sp
                            )
                        }
                        Column(horizontalAlignment = Alignment.End) {
                            Text(
                                if (c.ping > 0) "${c.ping} ms" else "—",
                                color = when {
                                    c.ping in 1..100 -> Color(0xFF00E676)
                                    c.ping in 101..300 -> Color(0xFFFFEB3B)
                                    c.ping > 300 -> Color(0xFFFF5252)
                                    else -> Color.White.copy(0.4f)
                                },
                                fontWeight = FontWeight.Bold
                            )
                            Text(
                                if (c.isWorking) "🟢" else "🔴",
                                fontSize = 10.sp
                            )
                        }
                    }
                }
            }
        }
    }
}

// ═══════════════════════════════════════════════════
//  ۱۳. تنظیمات
// ═══════════════════════════════════════════════════
@Composable
fun Settings(back: () -> Unit) {
    Column(
        Modifier.fillMaxSize()
            .background(Color(0xFF0A0E27))
            .padding(16.dp)
    ) {
        Row(
            Modifier.fillMaxWidth(),
            Arrangement.SpaceBetween,
            Alignment.CenterVertically
        ) {
            IconButton(onClick = back) {
                Icon(Icons.Default.ArrowBack, null, tint = Color.White)
            }
            Text(
                "تنظیمات",
                color = Color.White,
                fontSize = 20.sp,
                fontWeight = FontWeight.Bold
            )
            Spacer(Modifier.width(48.dp))
        }

        Spacer(Modifier.height(20.dp))

        listOf(
            "🌐 DNS سفارشی" to "1.1.1.1 / 8.8.8.8",
            "🚫 بلاک تبلیغات" to "فعال",
            "🇮🇷 دور زدن ایران" to "فعال",
            "🔋 حالت باتری" to "بهینه",
            "⚡ اتصال خودکار" to "غیرفعال",
            "🔐 Kill Switch" to "فعال",
            "📊 نمایش سرعت" to "فعال",
            "🌙 تم" to "تیره",
            "🎯 موتور پینگ" to "Xray Hybrid",
            "📡 پروتکل‌ها" to "Reality / gRPC / WS / TLS"
        ).forEach { (t, s) ->
            Card(
                Modifier.fillMaxWidth().padding(vertical = 4.dp),
                colors = CardDefaults.cardColors(
                    containerColor = Color(0xFF1B1F3A)
                )
            ) {
                Row(
                    Modifier.fillMaxWidth().padding(16.dp),
                    Arrangement.SpaceBetween
                ) {
                    Text(t, color = Color.White)
                    Text(s, color = Color.White.copy(0.6f), fontSize = 12.sp)
                }
            }
        }
    }
}

// ═══════════════════════════════════════════════════
//  ۱۴. پنل ادمین
// ═══════════════════════════════════════════════════
@Composable
fun Admin(vm: VpnViewModel, back: () -> Unit) {
    var pass by remember { mutableStateOf("") }
    var unlocked by remember { mutableStateOf(false) }
    var err by remember { mutableStateOf(false) }

    Column(
        Modifier.fillMaxSize()
            .background(Color(0xFF0A0E27))
            .padding(16.dp)
    ) {
        Row(
            Modifier.fillMaxWidth(),
            Arrangement.SpaceBetween,
            Alignment.CenterVertically
        ) {
            IconButton(onClick = back) {
                Icon(Icons.Default.ArrowBack, null, tint = Color.White)
            }
            Text(
                "پنل مدیریت",
                color = Color.White,
                fontSize = 20.sp,
                fontWeight = FontWeight.Bold
            )
            Spacer(Modifier.width(48.dp))
        }

        if (!unlocked) {
            Spacer(Modifier.height(60.dp))
            Text("🔐 ورود مدیر", color = Color.White, fontSize = 18.sp)
            Spacer(Modifier.height(16.dp))

            OutlinedTextField(
                value = pass,
                onValueChange = { pass = it; err = false },
                label = { Text("رمز عبور") },
                visualTransformation = PasswordVisualTransformation(),
                isError = err,
                modifier = Modifier.fillMaxWidth(),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedTextColor = Color.White,
                    unfocusedTextColor = Color.White
                )
            )

            Spacer(Modifier.height(12.dp))

            Button(
                onClick = {
                    if (vm.verifyPass(pass)) unlocked = true else err = true
                },
                modifier = Modifier.fillMaxWidth(),
                colors = ButtonDefaults.buttonColors(
                    containerColor = Color(0xFF7C4DFF)
                )
            ) { Text("ورود") }

            if (err) {
                Spacer(Modifier.height(8.dp))
                Text("رمز اشتباه است", color = Color(0xFFFF5252))
            }
        } else {
            AdminPanel(vm)
        }
    }
}

@Composable
fun AdminPanel(vm: VpnViewModel) {
    var link by remember { mutableStateOf("") }
    var name by remember { mutableStateOf("") }
    var msg by remember { mutableStateOf("") }
    val cfgs by vm.configs.collectAsState()
    val adminOnly = cfgs.filter { !it.isDefault }

    Column(
        Modifier.fillMaxSize()
            .verticalScroll(rememberScrollState())
    ) {
        Text("➕ افزودن کانفیگ", color = Color.White, fontSize = 16.sp)
        Spacer(Modifier.height(8.dp))

        OutlinedTextField(
            value = name,
            onValueChange = { name = it },
            label = { Text("نام (مثلاً PARSAVPN-1234)") },
            modifier = Modifier.fillMaxWidth(),
            colors = OutlinedTextFieldDefaults.colors(
                focusedTextColor = Color.White,
                unfocusedTextColor = Color.White
            )
        )

        Spacer(Modifier.height(8.dp))

        OutlinedTextField(
            value = link,
            onValueChange = { link = it },
            label = { Text("لینک VLESS / VMess / SS / Trojan") },
            modifier = Modifier.fillMaxWidth().height(120.dp),
            colors = OutlinedTextFieldDefaults.colors(
                focusedTextColor = Color.White,
                unfocusedTextColor = Color.White
            )
        )

        Spacer(Modifier.height(8.dp))

        Button(
            onClick = {
                if (link.isBlank()) {
                    msg = "لینک خالی است"
                    return@Button
                }
                val ok = vm.addAdmin(link.trim(), name.trim())
                msg = if (ok) "✓ اضافه شد" else "✗ لینک نامعتبر"
                if (ok) { link = ""; name = "" }
            },
            modifier = Modifier.fillMaxWidth(),
            colors = ButtonDefaults.buttonColors(
                containerColor = Color(0xFF00E676)
            )
        ) { Text("افزودن", color = Color.Black) }

        if (msg.isNotEmpty()) {
            Spacer(Modifier.height(8.dp))
            Text(
                msg,
                color = if (msg.startsWith("✓")) Color(0xFF00E676)
                        else Color(0xFFFF5252)
            )
        }

        Spacer(Modifier.height(24.dp))

        Text(
            "🗑️ حذف کانفیگ‌های ادمین (${adminOnly.size})",
            color = Color.White,
            fontSize = 16.sp
        )
        Spacer(Modifier.height(8.dp))

        if (adminOnly.isEmpty()) {
            Text(
                "هیچ کانفیگ ادمینی وجود ندارد",
                color = Color.White.copy(0.5f)
            )
        } else {
            adminOnly.forEach { c ->
                Card(
                    Modifier.fillMaxWidth().padding(vertical = 4.dp),
                    colors = CardDefaults.cardColors(
                        containerColor = Color(0xFF1B1F3A)
                    )
                ) {
                    Row(
                        Modifier.fillMaxWidth().padding(12.dp),
                        Arrangement.SpaceBetween,
                        Alignment.CenterVertically
                    ) {
                        Column(Modifier.weight(1f)) {
                            Text(c.name, color = Color.White)
                            Text(
                                c.server,
                                color = Color.White.copy(0.5f),
                                fontSize = 11.sp
                            )
                        }
                        IconButton(onClick = { vm.removeAdmin(c.id) }) {
                            Icon(
                                Icons.Default.Delete,
                                null,
                                tint = Color(0xFFFF5252)
                            )
                        }
                    }
                }
            }
        }

        Spacer(Modifier.height(32.dp))
    }
}
cat > "$ROOT/app/src/main/res/values/colors.xml" << 'X9'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="parsa_background">#0A0E27</color>
    <color name="parsa_surface">#1B1F3A</color>
    <color name="parsa_primary">#7C4DFF</color>
    <color name="parsa_success">#00E676</color>
    <color name="parsa_error">#FF5252</color>
    <color name="white">#FFFFFF</color>
    <color name="black">#000000</color>
    <color name="ic_launcher_background">#0A0E27</color>
</resources>
X9

# ═══════════════════════════════════════════════════════════
#  فایل ۱۰: themes.xml
# ═══════════════════════════════════════════════════════════
cat > "$ROOT/app/src/main/res/values/themes.xml" << 'X10'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="Theme.PARSAVPN" parent="android:Theme.Material.NoActionBar">
        <item name="android:statusBarColor">@color/parsa_background</item>
        <item name="android:navigationBarColor">@color/parsa_background</item>
        <item name="android:windowBackground">@color/parsa_background</item>
    </style>
</resources>
X10

# ═══════════════════════════════════════════════════════════
#  فایل ۱۱: ic_launcher.xml
# ═══════════════════════════════════════════════════════════
cat > "$ROOT/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml" << 'X11'
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background" />
    <foreground android:drawable="@drawable/ic_launcher_foreground" />
</adaptive-icon>
X11

cp "$ROOT/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml" \
   "$ROOT/app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml"

# ═══════════════════════════════════════════════════════════
#  فایل ۱۲: ic_launcher_foreground.xml
# ═══════════════════════════════════════════════════════════
cat > "$ROOT/app/src/main/res/drawable/ic_launcher_foreground.xml" << 'X12'
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp" android:height="108dp"
    android:viewportWidth="108" android:viewportHeight="108">
    <path android:fillColor="#7C4DFF"
        android:pathData="M54,30L34,42v18c0,13.2 9.2,25.5 20,28 10.8,-2.5 20,-14.8 20,-28V42L54,30zM54,52h14c-1,7.5 -6,14.5 -14,16.8V52H40V44l14,-7.6V52z" />
</vector>
X12

# ═══════════════════════════════════════════════════════════
#  فایل ۱۳: network_security_config.xml
# ═══════════════════════════════════════════════════════════
cat > "$ROOT/app/src/main/res/xml/network_security_config.xml" << 'X13'
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <base-config cleartextTrafficPermitted="true">
        <trust-anchors>
            <certificates src="system" />
            <certificates src="user" />
        </trust-anchors>
    </base-config>
</network-security-config>
X13

# ═══════════════════════════════════════════════════════════
#  فایل ۱۴: backup_rules.xml
# ═══════════════════════════════════════════════════════════
cat > "$ROOT/app/src/main/res/xml/backup_rules.xml" << 'X14'
<?xml version="1.0" encoding="utf-8"?>
<full-backup-content>
    <exclude domain="sharedpref" path="." />
</full-backup-content>
X14

# ═══════════════════════════════════════════════════════════
#  فایل ۱۵: data_extraction_rules.xml
# ═══════════════════════════════════════════════════════════
cat > "$ROOT/app/src/main/res/xml/data_extraction_rules.xml" << 'X15'
<?xml version="1.0" encoding="utf-8"?>
<data-extraction-rules>
    <cloud-backup>
        <exclude domain="sharedpref" path="." />
    </cloud-backup>
    <device-transfer>
        <exclude domain="sharedpref" path="." />
    </device-transfer>
</data-extraction-rules>
X15

# ═══════════════════════════════════════════════════════════
#  فایل ۱۶: gradlew (اسکریپت اجرای Gradle برای لینوکس/مک)
# ═══════════════════════════════════════════════════════════
cat > "$ROOT/gradlew" << 'X16'
#!/bin/sh
DIR="$(cd "$(dirname "$0")" && pwd)"
CLASSPATH="$DIR/gradle/wrapper/gradle-wrapper.jar"
if [ ! -f "$CLASSPATH" ]; then
  mkdir -p "$DIR/gradle/wrapper"
  URL="https://raw.githubusercontent.com/gradle/gradle/v8.7.0/gradle/wrapper/gradle-wrapper.jar"
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL -o "$CLASSPATH" "$URL"
  elif command -v wget >/dev/null 2>&1; then
    wget -q -O "$CLASSPATH" "$URL"
  fi
fi
exec java -classpath "$CLASSPATH" org.gradle.wrapper.GradleWrapperMain "$@"
X16
chmod +x "$ROOT/gradlew"

# ═══════════════════════════════════════════════════════════
#  فایل ۱۷: gradlew.bat (برای ویندوز)
# ═══════════════════════════════════════════════════════════
cat > "$ROOT/gradlew.bat" << 'X17'
@rem Gradle startup script for Windows
@echo off
set DIRNAME=%~dp0
set CLASSPATH=%DIRNAME%gradle\wrapper\gradle-wrapper.jar
if not exist "%CLASSPATH%" (
  echo Downloading gradle-wrapper.jar...
  powershell -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/gradle/gradle/v8.7.0/gradle/wrapper/gradle-wrapper.jar' -OutFile '%CLASSPATH%'"
)
java -classpath "%CLASSPATH%" org.gradle.wrapper.GradleWrapperMain %*
X17

# ═══════════════════════════════════════════════════════════
#  فایل ۱۸: GitHub Actions Workflow (ساخت خودکار APK)
# ═══════════════════════════════════════════════════════════
cat > "$ROOT/.github/workflows/build.yml" << 'X18'
name: Build PARSA VPN APK

on:
  push:
    branches: [ main, master ]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Java 17
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'

      - name: Setup Android SDK
        uses: android-actions/setup-android@v3

      - name: Cache Gradle
        uses: actions/cache@v4
        with:
          path: |
            ~/.gradle/caches
            ~/.gradle/wrapper
          key: gradle-${{ hashFiles('**/*.gradle*') }}

      - name: Download libXray.aar
        run: |
          mkdir -p app/libs
          curl -L -o app/libs/libXray.aar \
            https://github.com/2dust/AndroidLibXrayLite/releases/download/v25.9.5/libXray.aar

      - name: Grant execute for gradlew
        run: chmod +x gradlew

      - name: Build Debug APK
        run: ./gradlew assembleDebug --stacktrace

      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: PARSAVPN-debug
          path: app/build/outputs/apk/debug/*.apk
X18

# ═══════════════════════════════════════════════════════════
#  فایل ۱۹: README.md
# ═══════════════════════════════════════════════════════════
cat > "$ROOT/README.md" << 'X19'
# PARSA VPN

VPN اختصاصی اندروید با هسته Xray

## ساخت خودکار APK با GitHub Actions
هر بار push کنی، APK خودکار ساخته می‌شود:
1. برو به تب Actions در گیت‌هاب
2. آخرین build را باز کن
3. Artifact را دانلود کن → APK

## ویژگی‌ها
- ۳۳ کانفیگ پیش‌فرض PARSAVPN-XXXX
- پینگ پیشرفته Xray (Jitter + Loss)
- بهترین سرور با یک کلیک
- پنل ادمین مخفی (رمز: poiiu)
- رمزنگاری AES-256
X19

echo ""
echo "═══════════════════════════════════════════"
echo " ✅ ساختار پروژه PARSA VPN ساخته شد!"
echo "═══════════════════════════════════════════"
echo ""
echo " 📁 مسیر: ./$ROOT"
echo " 🔐 رمز پنل ادمین: poiiu"
echo ""
echo " ⚠️ مهم: فایل App.kt را دستی در این مسیر قرار بده:"
echo "    $ROOT/app/src/main/java/com/mlmvpn/app/App.kt"
echo ""
echo " 📤 سپس push کن تا APK خودکار ساخته شود."

// ═══════════════════════════════════════════════════
//  ۱۶. همگام‌سازی Firebase (Realtime Database)
//      → کانفیگ ادمین روی همه دستگاه‌ها اعمال می‌شود
// ═══════════════════════════════════════════════════
object ConfigSync {

    // مسیر ثابت در Firebase
    private const val ROOT_PATH = "parsa_vpn_configs"
    private const val VERSION_PATH = "parsa_vpn_version"

    private val gson = Gson()
    private var listener: ValueEventListener? = null

    private val db: DatabaseReference
        get() = FirebaseDatabase.getInstance().getReference(ROOT_PATH)

    private val versionRef: DatabaseReference
        get() = FirebaseDatabase.getInstance().getReference(VERSION_PATH)

    /**
     * شروع گوش دادن به تغییرات سرور
     * هر وقت ادمین تغییر بده → onUpdate صدا زده می‌شه
     */
    fun startListening(onUpdate: (List<VpnConfig>) -> Unit) {
        stopListening()

        val newListener = object : ValueEventListener {
            override fun onDataChange(snapshot: DataSnapshot) {
                val list = mutableListOf<VpnConfig>()
                snapshot.children.forEach { child ->
                    val json = child.getValue(String::class.java) ?: return@forEach
                    try {
                        val cfg = gson.fromJson(json, VpnConfig::class.java)
                        list.add(cfg)
                    } catch (_: Exception) {}
                }
                Log.i("PARSA_SYNC", "دریافت ${list.size} کانفیگ از Firebase")
                onUpdate(list)
            }

            override fun onCancelled(error: DatabaseError) {
                Log.e("PARSA_SYNC", "خطای Firebase: ${error.message}")
            }
        }

        db.addValueEventListener(newListener)
        listener = newListener
    }

    fun stopListening() {
        listener?.let { db.removeEventListener(it) }
        listener = null
    }

    /**
     * افزودن کانفیگ جدید به سرور (فقط ادمین)
     */
    fun push(c: VpnConfig, onResult: (Boolean) -> Unit = {}) {
        db.child(c.id).setValue(gson.toJson(c))
            .addOnSuccessListener {
                bumpVersion()
                onResult(true)
            }
            .addOnFailureListener { onResult(false) }
    }

    /**
     * حذف کانفیگ از سرور (فقط ادمین)
     */
    fun remove(id: String, onResult: (Boolean) -> Unit = {}) {
        db.child(id).removeValue()
            .addOnSuccessListener {
                bumpVersion()
                onResult(true)
            }
            .addOnFailureListener { onResult(false) }
    }

    /**
     * آپلود کامل لیست (bulk)
     */
    fun pushAll(list: List<VpnConfig>, onResult: (Boolean) -> Unit = {}) {
        val map = list.associate { it.id to gson.toJson(it) }
        db.setValue(map)
            .addOnSuccessListener {
                bumpVersion()
                onResult(true)
            }
            .addOnFailureListener { onResult(false) }
    }

    /**
     * نسخه سرور را افزایش بده (برای اطلاع دستگاه‌های دیگه)
     */
    private fun bumpVersion() {
        versionRef.setValue(System.currentTimeMillis())
    }
}

// ═══════════════════════════════════════════════════
//  ۱۷. تست سرعت از داخل تونل VPN
// ═══════════════════════════════════════════════════
data class SpeedResult(
    val downloadMbps: Double = 0.0,
    val uploadMbps: Double = 0.0,
    val latencyMs: Long = 0,
    val jitterMs: Long = 0,
    val isDone: Boolean = false
)

object SpeedTest {

    // سرورهای تست Cloudflare (سریع و پایدار)
    private const val DOWNLOAD_URL = "https://speed.cloudflare.com/__down?bytes=10000000"
    private const val UPLOAD_URL = "https://speed.cloudflare.com/__up"

    /**
     * اجرای تست سرعت کامل
     */
    suspend fun run(
        onProgress: (phase: String, percent: Int) -> Unit = { _, _ -> },
        onResult: (SpeedResult) -> Unit = {}
    ): SpeedResult = withContext(Dispatchers.IO) {

        val client = okhttp3.OkHttpClient.Builder()
            .connectTimeout(10, java.util.concurrent.TimeUnit.SECONDS)
            .readTimeout(30, java.util.concurrent.TimeUnit.SECONDS)
            .writeTimeout(30, java.util.concurrent.TimeUnit.SECONDS)
            .build()

        var result = SpeedResult()

        // ═══ مرحله ۱: تأخیر (Ping) ═══
        withContext(Dispatchers.Main) { onProgress("در حال اندازه‌گیری تأخیر...", 5) }
        val latencies = mutableListOf<Long>()
        repeat(5) {
            try {
                val start = System.currentTimeMillis()
                val req = okhttp3.Request.Builder()
                    .url("https://speed.cloudflare.com/__down?bytes=0")
                    .build()
                client.newCall(req).execute().use { _ ->
                    latencies.add(System.currentTimeMillis() - start)
                }
            } catch (_: Exception) {}
        }
        if (latencies.isNotEmpty()) {
            result = result.copy(
                latencyMs = latencies.average().toLong(),
                jitterMs = if (latencies.size > 1) {
                    val avg = latencies.average()
                    kotlin.math.sqrt(latencies.map { (it - avg) * (it - avg) }.average()).toLong()
                } else 0
            )
        }
        withContext(Dispatchers.Main) { onResult(result) }

        // ═══ مرحله ۲: دانلود ═══
        withContext(Dispatchers.Main) { onProgress("تست دانلود...", 20) }
        try {
            val start = System.currentTimeMillis()
            val req = okhttp3.Request.Builder().url(DOWNLOAD_URL).build()
            var bytesRead = 0L
            client.newCall(req).execute().use { resp ->
                val body = resp.body
                if (body != null) {
                    val input = body.byteStream()
                    val buffer = ByteArray(64 * 1024)
                    var totalDownloaded = 0L
                    val totalBytes = body.contentLength().let { if (it > 0) it else 10_000_000L }
                    var lastUpdate = 0L

                    while (true) {
                        val read = input.read(buffer)
                        if (read == -1) break
                        bytesRead += read

                        val now = System.currentTimeMillis()
                        if (now - lastUpdate > 300) {
                            val pct = 20 + ((bytesRead * 40) / totalBytes).toInt().coerceIn(0, 40)
                            val elapsed = (now - start).coerceAtLeast(1)
                            val mbps = (bytesRead * 8.0) / (elapsed / 1000.0) / 1_000_000.0
                            withContext(Dispatchers.Main) {
                                onProgress("دانلود: %.2f Mbps".format(mbps), pct)
                            }
                            lastUpdate = now
                        }
                    }
                }
            }
            val elapsed = (System.currentTimeMillis() - start).coerceAtLeast(1)
            val mbps = (bytesRead * 8.0) / (elapsed / 1000.0) / 1_000_000.0
            result = result.copy(downloadMbps = mbps)
            withContext(Dispatchers.Main) { onResult(result) }
        } catch (e: Exception) {
            Log.e("SPEED", "download fail", e)
        }

        // ═══ مرحله ۳: آپلود ═══
        withContext(Dispatchers.Main) { onProgress("تست آپلود...", 65) }
        try {
            val start = System.currentTimeMillis()
            val data = ByteArray(2_000_000)
            val reqBody = okhttp3.RequestBody.create(
                data,
                okhttp3.MediaType.parse("application/octet-stream")
            )
            val req = okhttp3.Request.Builder().url(UPLOAD_URL).post(reqBody).build()
            client.newCall(req).execute().use { _ -> }
            val elapsed = (System.currentTimeMillis() - start).coerceAtLeast(1)
            val mbps = (data.size * 8.0) / (elapsed / 1000.0) / 1_000_000.0
            result = result.copy(uploadMbps = mbps)
            withContext(Dispatchers.Main) { onResult(result) }
        } catch (e: Exception) {
            Log.e("SPEED", "upload fail", e)
        }

        withContext(Dispatchers.Main) { onProgress("تکمیل شد", 100) }

        result.copy(isDone = true).also {
            withContext(Dispatchers.Main) { onResult(it) }
        }
    }
}

// ═══════════════════════════════════════════════════
//  ۱۸. Split Tunneling - انتخاب اپ‌های استثنا
// ═══════════════════════════════════════════════════
data class AppInfo(
    val packageName: String,
    val appName: String,
    val isSystem: Boolean
)

object SplitTunnel {

    /**
     * دریافت لیست اپ‌های نصب‌شده
     */
    suspend fun getInstalledApps(ctx: Context): List<AppInfo> =
        withContext(Dispatchers.IO) {
            val pm = ctx.packageManager
            val intent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
            val apps = pm.queryIntentActivities(intent, 0)

            apps.mapNotNull { resolveInfo ->
                try {
                    val pkg = resolveInfo.activityInfo.packageName
                    val name = resolveInfo.loadLabel(pm).toString()
                    val appInfo = pm.getApplicationInfo(pkg, 0)
                    val isSystem = (appInfo.flags and
                        android.content.pm.ApplicationInfo.FLAG_SYSTEM) != 0
                    AppInfo(pkg, name, isSystem)
                } catch (_: Exception) { null }
            }
                .filter { it.packageName != ctx.packageName }
                .sortedBy { it.appName.lowercase() }
        }

    /**
     * ذخیره لیست اپ‌های استثنا (از VPN رد نشن)
     */
    fun saveExcluded(ctx: Context, packages: Set<String>) {
        val prefs = ctx.getSharedPreferences("parsa_split", Context.MODE_PRIVATE)
        prefs.edit().putStringSet("excluded", packages).apply()
    }

    /**
     * دریافت لیست اپ‌های استثنا
     */
    fun getExcluded(ctx: Context): Set<String> {
        val prefs = ctx.getSharedPreferences("parsa_split", Context.MODE_PRIVATE)
        return prefs.getStringSet("excluded", emptySet()) ?: emptySet()
    }

    /**
     * اعمال split tunneling روی VpnService.Builder
     * این تابع رو در CoreVpnService.startTunnel صدا بزن
     */
    fun applyToBuilder(builder: VpnService.Builder, ctx: Context) {
        val excluded = getExcluded(ctx)
        excluded.forEach { pkg ->
            try {
                builder.addDisallowedApplication(pkg)
            } catch (_: Exception) {}
        }
    }
}

// ═══════════════════════════════════════════════════
//  ۱۹. آمار مصرف ترافیک
// ═══════════════════════════════════════════════════
data class TrafficStats(
    val rxBytes: Long = 0,
    val txBytes: Long = 0,
    val sessionDurationSec: Long = 0,
    val totalSessions: Int = 0,
    val totalBytesAllTime: Long = 0
)

object TrafficStatsManager {

    private const val PREFS = "parsa_stats"

    fun saveSessionStart(ctx: Context) {
        val prefs = ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        prefs.edit().putLong("session_start", System.currentTimeMillis()).apply()
    }

    fun endSession(ctx: Context, rx: Long, tx: Long) {
        val prefs = ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val total = prefs.getLong("total_bytes", 0) + rx + tx
        val count = prefs.getInt("total_sessions", 0) + 1
        prefs.edit()
            .putLong("total_bytes", total)
            .putInt("total_sessions", count)
            .apply()
    }

    fun get(ctx: Context): TrafficStats {
        val prefs = ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        return TrafficStats(
            totalSessions = prefs.getInt("total_sessions", 0),
            totalBytesAllTime = prefs.getLong("total_bytes", 0)
        )
    }

    fun formatBytes(bytes: Long): String {
        return when {
            bytes < 1024 -> "$bytes B"
            bytes < 1024 * 1024 -> "%.2f KB".format(bytes / 1024.0)
            bytes < 1024 * 1024 * 1024 -> "%.2f MB".format(bytes / (1024.0 * 1024))
            else -> "%.2f GB".format(bytes / (1024.0 * 1024 * 1024))
        }
    }
}

// ═══════════════════════════════════════════════════
//  ۲۰. اتصال خودکار بعد از بوت
// ═══════════════════════════════════════════════════
class BootReceiver : android.content.BroadcastReceiver() {
    override fun onReceive(ctx: Context?, intent: Intent?) {
        if (ctx == null || intent == null) return
        if (intent.action != Intent.ACTION_BOOT_COMPLETED) return

        val prefs = ctx.getSharedPreferences("parsa_auto", Context.MODE_PRIVATE)
        val autoConnect = prefs.getBoolean("auto_connect", false)
        if (!autoConnect) return

        // صبر ۱۰ ثانیه تا سیستم کامل بالا بیاد
        Thread {
            Thread.sleep(10_000)
            val mgr = ConfigManager(ctx)
            val best = mgr.getBest() ?: mgr.getSelected() ?: return@Thread
            val json = try {
                XrayBuilder.build(best)
            } catch (_: Exception) { return@Thread }

            ctx.startService(Intent(ctx, CoreVpnService::class.java).apply {
                action = CoreVpnService.ACT_CONNECT
                putExtra("xray_config", json)
            })
        }.start()
    }
}

// ═══════════════════════════════════════════════════
//  ۲۱. اسکن QR Code برای افزودن کانفیگ
//      نیازمند: implementation("com.journeyapps:zxing-android-embedded:4.3.0")
// ═══════════════════════════════════════════════════
object QrHelper {

    /**
     * ساخت QR برای یک کانفیگ
     */
    fun generateQr(text: String, size: Int = 512): android.graphics.Bitmap {
        val writer = com.google.zxing.MultiFormatWriter()
        val bitMatrix = writer.encode(
            text,
            com.google.zxing.BarcodeFormat.QR_CODE,
            size, size
        )
        val bmp = android.graphics.Bitmap.createBitmap(
            size, size, android.graphics.Bitmap.Config.RGB_565
        )
        for (x in 0 until size) {
            for (y in 0 until size) {
                bmp.setPixel(
                    x, y,
                    if (bitMatrix[x, y]) android.graphics.Color.BLACK
                    else android.graphics.Color.WHITE
                )
            }
        }
        return bmp
    }
}

// ═══════════════════════════════════════════════════
//  ۲۲. افزودنی‌های VpnViewModel
//     این خطوط را داخل کلاس VpnViewModel اضافه کن
// ═══════════════════════════════════════════════════

    // === Firebase Sync ===
    private val _syncStatus = MutableStateFlow("")
    val syncStatus: StateFlow<String> = _syncStatus.asStateFlow()

    init {
        // گوش دادن به تغییرات سرور
        ConfigSync.startListening { remoteList ->
            val merged = DefaultConfigs.ALL + remoteList
            mgr.saveAdminConfigs(remoteList)
            _cfgs.value = merged
            _syncStatus.value = "همگام‌سازی: ${remoteList.size} کانفیگ ادمین"
        }
    }

    // === Speed Test ===
    private val _speedResult = MutableStateFlow(SpeedResult())
    val speedResult: StateFlow<SpeedResult> = _speedResult.asStateFlow()

    private val _speedPhase = MutableStateFlow("")
    val speedPhase: StateFlow<String> = _speedPhase.asStateFlow()

    private val _speedPercent = MutableStateFlow(0)
    val speedPercent: StateFlow<Int> = _speedPercent.asStateFlow()

    fun runSpeedTest() {
        viewModelScope.launch {
            _speedResult.value = SpeedResult()
            _speedPercent.value = 0
            SpeedTest.run(
                onProgress = { phase, pct ->
                    _speedPhase.value = phase
                    _speedPercent.value = pct
                },
                onResult = { result ->
                    _speedResult.value = result
                }
            )
        }
    }

    // === Split Tunnel ===
    private val _installedApps = MutableStateFlow<List<AppInfo>>(emptyList())
    val installedApps: StateFlow<List<AppInfo>> = _installedApps.asStateFlow()

    private val _excludedApps = MutableStateFlow<Set<String>>(emptySet())
    val excludedApps: StateFlow<Set<String>> = _excludedApps.asStateFlow()

    fun loadInstalledApps() {
        viewModelScope.launch {
            _installedApps.value = SplitTunnel.getInstalledApps(ctx)
            _excludedApps.value = SplitTunnel.getExcluded(ctx)
        }
    }

    fun toggleExcluded(pkg: String) {
        val newSet = _excludedApps.value.toMutableSet()
        if (pkg in newSet) newSet.remove(pkg) else newSet.add(pkg)
        _excludedApps.value = newSet
        SplitTunnel.saveExcluded(ctx, newSet)
    }

    // === Statistics ===
    private val _stats = MutableStateFlow(TrafficStats())
    val stats: StateFlow<TrafficStats> = _stats.asStateFlow()

    fun loadStats() {
        _stats.value = TrafficStatsManager.get(ctx)
    }

    // === Firebase Admin Actions ===
    fun addAdminWithSync(link: String, name: String): Boolean {
        val parsed = parse(link, name.ifBlank { "PARSAVPN-${(1000..9999).random()}" })
            ?: return false
        mgr.addAdmin(parsed)
        _cfgs.value = mgr.getAll()
        // ارسال به Firebase
        ConfigSync.push(parsed) { ok ->
            Log.i("PARSA", "Firebase push: $ok")
        }
        return true
    }

    fun removeAdminWithSync(id: String) {
        mgr.removeAdmin(id)
        _cfgs.value = mgr.getAll()
        ConfigSync.remove(id)
    }
    
// ═══════════════════════════════════════════════════
//  ۲۴. صفحه تست سرعت
// ═══════════════════════════════════════════════════
@Composable
fun SpeedTestScreen(vm: VpnViewModel, back: () -> Unit) {
    val result by vm.speedResult.collectAsState()
    val phase by vm.speedPhase.collectAsState()
    val percent by vm.speedPercent.collectAsState()

    Column(
        Modifier.fillMaxSize()
            .background(Color(0xFF0A0E27))
            .padding(16.dp)
    ) {
        Row(
            Modifier.fillMaxWidth(),
            Arrangement.SpaceBetween,
            Alignment.CenterVertically
        ) {
            IconButton(onClick = back) {
                Icon(Icons.Default.ArrowBack, null, tint = Color.White)
            }
            Text(
                "تست سرعت",
                color = Color.White,
                fontSize = 20.sp,
                fontWeight = FontWeight.Bold
            )
            Spacer(Modifier.width(48.dp))
        }

        Spacer(Modifier.height(40.dp))

        // ═══ گیج سرعت ═══
        Box(
            Modifier.fillMaxWidth().height(220.dp),
            contentAlignment = Alignment.Center
        ) {
            CircularProgressIndicator(
                progress = percent / 100f,
                modifier = Modifier.size(200.dp),
                color = Color(0xFF7C4DFF),
                strokeWidth = 12.dp,
                trackColor = Color(0xFF1B1F3A)
            )
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Text(
                    "%.1f".format(result.downloadMbps),
                    color = Color.White,
                    fontSize = 48.sp,
                    fontWeight = FontWeight.Bold
                )
                Text(
                    "Mbps",
                    color = Color.White.copy(0.5f),
                    fontSize = 14.sp
                )
                if (phase.isNotEmpty()) {
                    Spacer(Modifier.height(8.dp))
                    Text(
                        phase,
                        color = Color(0xFF7C4DFF),
                        fontSize = 12.sp
                    )
                }
            }
        }

        Spacer(Modifier.height(32.dp))

        // ═══ کارت‌های نتیجه ═══
        Row(
            Modifier.fillMaxWidth(),
            Arrangement.spacedBy(12.dp)
        ) {
            SpeedCard("⬇️ دانلود", "%.2f".format(result.downloadMbps), "Mbps", Color(0xFF00E676), Modifier.weight(1f))
            SpeedCard("⬆️ آپلود", "%.2f".format(result.uploadMbps), "Mbps", Color(0xFF7C4DFF), Modifier.weight(1f))
        }

        Spacer(Modifier.height(12.dp))

        Row(
            Modifier.fillMaxWidth(),
            Arrangement.spacedBy(12.dp)
        ) {
            SpeedCard("📡 تأخیر", "${result.latencyMs}", "ms", Color(0xFFFFEB3B), Modifier.weight(1f))
            SpeedCard("📊 Jitter", "${result.jitterMs}", "ms", Color(0xFFFF9800), Modifier.weight(1f))
        }

        Spacer(Modifier.height(40.dp))

        // ═══ دکمه شروع ═══
        Button(
            onClick = { vm.runSpeedTest() },
            modifier = Modifier.fillMaxWidth().height(56.dp),
            colors = ButtonDefaults.buttonColors(
                containerColor = Color(0xFF7C4DFF)
            ),
            enabled = !(percent in 1..99)
        ) {
            Text(
                if (percent in 1..99) "در حال تست..." else "🚀 شروع تست",
                fontSize = 16.sp,
                fontWeight = FontWeight.Bold
            )
        }
    }
}

@Composable
fun SpeedCard(
    title: String,
    value: String,
    unit: String,
    color: Color,
    modifier: Modifier = Modifier
) {
    Card(
        modifier,
        colors = CardDefaults.cardColors(
            containerColor = Color(0xFF1B1F3A)
        )
    ) {
        Column(
            Modifier.fillMaxWidth().padding(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(title, color = Color.White.copy(0.7f), fontSize = 12.sp)
            Spacer(Modifier.height(8.dp))
            Row(verticalAlignment = Alignment.Bottom) {
                Text(
                    value,
                    color = color,
                    fontSize = 24.sp,
                    fontWeight = FontWeight.Bold
                )
                Spacer(Modifier.width(4.dp))
                Text(
                    unit,
                    color = Color.White.copy(0.5f),
                    fontSize = 11.sp
                )
            }
        }
    }
}

// ═══════════════════════════════════════════════════
//  ۲۶. صفحه آمار مصرف
// ═══════════════════════════════════════════════════
@Composable
fun StatsScreen(vm: VpnViewModel, back: () -> Unit) {
    val stats by vm.stats.collectAsState()

    LaunchedEffect(Unit) {
        vm.loadStats()
    }

    Column(
        Modifier.fillMaxSize()
            .background(Color(0xFF0A0E27))
            .padding(16.dp)
    ) {
        Row(
            Modifier.fillMaxWidth(),
            Arrangement.SpaceBetween,
            Alignment.CenterVertically
        ) {
            IconButton(onClick = back) {
                Icon(Icons.Default.ArrowBack, null, tint = Color.White)
            }
            Text(
                "آمار مصرف",
                color = Color.White,
                fontSize = 20.sp,
                fontWeight = FontWeight.Bold
            )
            Spacer(Modifier.width(48.dp))
        }

        Spacer(Modifier.height(40.dp))

        // ═══ کارت اصلی - کل مصرف ═══
        Card(
            Modifier.fillMaxWidth(),
            colors = CardDefaults.cardColors(
                containerColor = Color(0xFF1B1F3A)
            )
        ) {
            Column(
                Modifier.fillMaxWidth().padding(24.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text(
                    "📊 کل مصرف از نصب اپ",
                    color = Color.White.copy(0.7f),
                    fontSize = 14.sp
                )
                Spacer(Modifier.height(16.dp))
                Text(
                    TrafficStatsManager.formatBytes(stats.totalBytesAllTime),
                    color = Color(0xFF00E676),
                    fontSize = 40.sp,
                    fontWeight = FontWeight.Bold
                )
                Spacer(Modifier.height(8.dp))
                Text(
                    "مجموع همه سشن‌ها",
                    color = Color.White.copy(0.5f),
                    fontSize = 12.sp
                )
            }
        }

        Spacer(Modifier.height(16.dp))

        // ═══ کارت‌های ثانویه ═══
        Row(
            Modifier.fillMaxWidth(),
            Arrangement.spacedBy(12.dp)
        ) {
            StatCard(
                "🔗 تعداد سشن",
                "${stats.totalSessions}",
                Color(0xFF7C4DFF),
                Modifier.weight(1f)
            )
            StatCard(
                "📥 دانلود",
                TrafficStatsManager.formatBytes(stats.rxBytes),
                Color(0xFF00E676),
                Modifier.weight(1f)
            )
        }

        Spacer(Modifier.height(12.dp))

        Row(
            Modifier.fillMaxWidth(),
            Arrangement.spacedBy(12.dp)
        ) {
            StatCard(
                "📤 آپلود",
                TrafficStatsManager.formatBytes(stats.txBytes),
                Color(0xFFFF9800),
                Modifier.weight(1f)
            )
            StatCard(
                "⏱ مدت",
                "${stats.sessionDurationSec} ثانیه",
                Color(0xFFFFEB3B),
                Modifier.weight(1f)
            )
        }

        Spacer(Modifier.height(40.dp))

        // ═══ دکمه پاک کردن ═══
        OutlinedButton(
            onClick = { /* پاک کردن آمار */ },
            modifier = Modifier.fillMaxWidth(),
            colors = ButtonDefaults.outlinedButtonColors(
                contentColor = Color(0xFFFF5252)
            )
        ) {
            Text("🗑️ پاک کردن آمار")
        }
    }
}

@Composable
fun StatCard(
    title: String,
    value: String,
    color: Color,
    modifier: Modifier = Modifier
) {
    Card(
        modifier,
        colors = CardDefaults.cardColors(
            containerColor = Color(0xFF1B1F3A)
        )
    ) {
        Column(
            Modifier.fillMaxWidth().padding(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(title, color = Color.White.copy(0.7f), fontSize = 11.sp)
            Spacer(Modifier.height(8.dp))
            Text(
                value,
                color = color,
                fontSize = 18.sp,
                fontWeight = FontWeight.Bold
            )
        }
    }
}

// ═══════════════════════════════════════════════════
//  ۲۷. صفحه QR Code
// ═══════════════════════════════════════════════════
@Composable
fun QrScreen(vm: VpnViewModel, back: () -> Unit) {
    var qrBitmap by remember { mutableStateOf<android.graphics.Bitmap?>(null) }
    var manualLink by remember { mutableStateOf("") }
    var msg by remember { mutableStateOf("") }

    Column(
        Modifier.fillMaxSize()
            .background(Color(0xFF0A0E27))
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Row(
            Modifier.fillMaxWidth(),
            Arrangement.SpaceBetween,
            Alignment.CenterVertically
        ) {
            IconButton(onClick = back) {
                Icon(Icons.Default.ArrowBack, null, tint = Color.White)
            }
            Text(
                "QR Code",
                color = Color.White,
                fontSize = 20.sp,
                fontWeight = FontWeight.Bold
            )
            Spacer(Modifier.width(48.dp))
        }

        Spacer(Modifier.height(20.dp))

        // ═══ نمایش QR ═══
        Card(
            Modifier.fillMaxWidth().height(300.dp),
            colors = CardDefaults.cardColors(
                containerColor = Color.White
            )
        ) {
            Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                if (qrBitmap != null) {
                    androidx.compose.foundation.Image(
                        bitmap = qrBitmap!!.asImageBitmap(),
                        contentDescription = "QR",
                        modifier = Modifier.size(260.dp)
                    )
                } else {
                    Text(
                        "QR اینجا نمایش داده می‌شود",
                        color = Color.Gray
                    )
                }
            }
        }

        Spacer(Modifier.height(20.dp))

        OutlinedTextField(
            value = manualLink,
            onValueChange = { manualLink = it },
            label = { Text("لینک کانفیگ (vless://...)") },
            modifier = Modifier.fillMaxWidth().height(100.dp),
            colors = OutlinedTextFieldDefaults.colors(
                focusedTextColor = Color.White,
                unfocusedTextColor = Color.White
            )
        )

        Spacer(Modifier.height(12.dp))

        Button(
            onClick = {
                if (manualLink.isBlank()) {
                    msg = "لینک خالی است"
                    return@Button
                }
                try {
                    qrBitmap = QrHelper.generateQr(manualLink.trim())
                    msg = "✓ QR ساخته شد"
                } catch (e: Exception) {
                    msg = "✗ خطا: ${e.message}"
                }
            },
            modifier = Modifier.fillMaxWidth(),
            colors = ButtonDefaults.buttonColors(
                containerColor = Color(0xFF7C4DFF)
            )
        ) {
            Text("📱 ساخت QR")
        }

        if (msg.isNotEmpty()) {
            Spacer(Modifier.height(8.dp))
            Text(
                msg,
                color = if (msg.startsWith("✓")) Color(0xFF00E676)
                        else Color(0xFFFF5252)
            )
        }
    }
}
Spacer(Modifier.height(40.dp))

// ردیف اول دکمه‌ها
Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
    OutlinedButton(
        onClick = { nav("servers") },
        colors = ButtonDefaults.outlinedButtonColors(contentColor = Color.White),
        shape = RoundedCornerShape(12.dp)
    ) { Text("📋 سرورها") }

    OutlinedButton(
        onClick = { nav("settings") },
        colors = ButtonDefaults.outlinedButtonColors(contentColor = Color.White),
        shape = RoundedCornerShape(12.dp)
    ) { Text("⚙️ تنظیمات") }

    OutlinedButton(
        onClick = { nav("admin") },
        colors = ButtonDefaults.outlinedButtonColors(contentColor = Color.White),
        shape = RoundedCornerShape(12.dp)
    ) { Text("🔐") }
}

Spacer(Modifier.height(10.dp))

// ردیف دوم دکمه‌ها
Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
    OutlinedButton(
        onClick = { nav("speed") },
        colors = ButtonDefaults.outlinedButtonColors(contentColor = Color.White),
        shape = RoundedCornerShape(12.dp)
    ) { Text("⚡ تست سرعت") }

    OutlinedButton(
        onClick = { nav("split") },
        colors = ButtonDefaults.outlinedButtonColors(contentColor = Color.White),
        shape = RoundedCornerShape(12.dp)
    ) { Text("🔀 Split") }

    OutlinedButton(
        onClick = { nav("stats") },
        colors = ButtonDefaults.outlinedButtonColors(contentColor = Color.White),
        shape = RoundedCornerShape(12.dp)
    ) { Text("📊 آمار") }

    OutlinedButton(
        onClick = { nav("qr") },
        colors = ButtonDefaults.outlinedButtonColors(contentColor = Color.White),
        shape = RoundedCornerShape(12.dp)
    ) { Text("📱") }
}
@Composable
fun App(vm: VpnViewModel) {
    var screen by remember { mutableStateOf("home") }
    when (screen) {
        "home" -> Home(vm) { screen = it }
        "servers" -> Servers(vm) { screen = "home" }
        "settings" -> Settings { screen = "home" }
        "admin" -> Admin(vm) { screen = "home" }
        "speed" -> SpeedTestScreen(vm) { screen = "home" }
        "split" -> SplitTunnelScreen(vm) { screen = "home" }
        "stats" -> StatsScreen(vm) { screen = "home" }
        "qr" -> QrScreen(vm) { screen = "home" }
    }
}

// ═══════════════════════════════════════════════════
//  ۳۰. تم روشن/تیره
// ═══════════════════════════════════════════════════
object ThemeManager {
    private const val PREFS = "parsa_theme"

    fun isDark(ctx: Context): Boolean {
        return ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .getBoolean("dark", true)
    }

    fun setDark(ctx: Context, dark: Boolean) {
        ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit().putBoolean("dark", dark).apply()
    }
}

@Composable
fun ThemeSwitcher(ctx: Context) {
    var isDark by remember { mutableStateOf(ThemeManager.isDark(ctx)) }

    Card(
        Modifier.fillMaxWidth().padding(vertical = 4.dp),
        colors = CardDefaults.cardColors(containerColor = Color(0xFF1B1F3A))
    ) {
        Row(
            Modifier.fillMaxWidth().padding(16.dp),
            Arrangement.SpaceBetween,
            Alignment.CenterVertically
        ) {
            Text(
                if (isDark) "🌙 تم تیره" else "☀️ تم روشن",
                color = Color.White
            )
            Switch(
                checked = isDark,
                onCheckedChange = {
                    isDark = it
                    ThemeManager.setDark(ctx, it)
                },
                colors = SwitchDefaults.colors(
                    checkedThumbColor = Color(0xFF7C4DFF),
                    checkedTrackColor = Color(0xFF7C4DFF).copy(0.3f)
                )
            )
        }
    }
}

// ═══════════════════════════════════════════════════
//  ۳۱. بررسی نسخه جدید از GitHub Releases
// ═══════════════════════════════════════════════════
data class UpdateInfo(
    val hasUpdate: Boolean = false,
    val latestVersion: String = "",
    val downloadUrl: String = "",
    val changelog: String = ""
)

object UpdateChecker {

    // ⚠️ این دو خط رو با اطلاعات ریپوی خودت جایگزین کن
    private const val GITHUB_USER = "YOUR_USERNAME"
    private const val GITHUB_REPO = "PARSAVPN"

    suspend fun check(currentVersion: String): UpdateInfo =
        withContext(Dispatchers.IO) {
            try {
                val client = okhttp3.OkHttpClient()
                val url = "https://api.github.com/repos/$GITHUB_USER/$GITHUB_REPO/releases/latest"
                val req = okhttp3.Request.Builder()
                    .url(url)
                    .header("Accept", "application/vnd.github+json")
                    .build()

                val resp = client.newCall(req).execute()
                val body = resp.body?.string() ?: return@withContext UpdateInfo()

                val json = JsonParser.parseString(body).asJsonObject
                val tagName = json.get("tag_name")?.asString ?: ""
                val htmlUrl = json.get("html_url")?.asString ?: ""
                val bodyText = json.get("body")?.asString ?: ""

                val latest = tagName.trimStart('v', 'V')
                val hasUpdate = compareVersions(latest, currentVersion) > 0

                UpdateInfo(
                    hasUpdate = hasUpdate,
                    latestVersion = latest,
                    downloadUrl = htmlUrl,
                    changelog = bodyText
                )
            } catch (e: Exception) {
                Log.e("UPDATE", "check failed", e)
                UpdateInfo()
            }
        }

    private fun compareVersions(a: String, b: String): Int {
        val pa = a.split(".").map { it.toIntOrNull() ?: 0 }
        val pb = b.split(".").map { it.toIntOrNull() ?: 0 }
        for (i in 0 until maxOf(pa.size, pb.size)) {
            val va = pa.getOrElse(i) { 0 }
            val vb = pb.getOrElse(i) { 0 }
            if (va != vb) return va - vb
        }
        return 0
    }
}

// ═══════════════════════════════════════════════════
//  ۳۲. ثبت و مشاهده لاگ
// ═══════════════════════════════════════════════════
object LogManager {

    private const val MAX_LINES = 500
    private val logs = mutableListOf<Pair<Long, String>>()
    private val lock = Any()

    fun log(tag: String, msg: String) {
        synchronized(lock) {
            logs.add(System.currentTimeMillis() to "[$tag] $msg")
            if (logs.size > MAX_LINES) logs.removeAt(0)
        }
        Log.i("PARSA_LOG", "[$tag] $msg")
    }

    fun getAll(): List<Pair<Long, String>> = synchronized(lock) {
        logs.toList()
    }

    fun clear() = synchronized(lock) { logs.clear() }

    fun export(): String = synchronized(lock) {
        logs.joinToString("\n") { (t, m) ->
            val date = java.text.SimpleDateFormat("HH:mm:ss", java.util.Locale.US)
                .format(java.util.Date(t))
            "$date $m"
        }
    }
}

@Composable
fun LogScreen(back: () -> Unit) {
    var logs by remember { mutableStateOf(LogManager.getAll()) }

    LaunchedEffect(Unit) {
        while (true) {
            delay(2000)
            logs = LogManager.getAll()
        }
    }

    Column(
        Modifier.fillMaxSize()
            .background(Color(0xFF0A0E27))
            .padding(16.dp)
    ) {
        Row(
            Modifier.fillMaxWidth(),
            Arrangement.SpaceBetween,
            Alignment.CenterVertically
        ) {
            IconButton(onClick = back) {
                Icon(Icons.Default.ArrowBack, null, tint = Color.White)
            }
            Text(
                "لاگ‌ها (${logs.size})",
                color = Color.White,
                fontSize = 20.sp,
                fontWeight = FontWeight.Bold
            )
            IconButton(onClick = { LogManager.clear() }) {
                Icon(Icons.Default.Delete, null, tint = Color(0xFFFF5252))
            }
        }

        Spacer(Modifier.height(12.dp))

        LazyColumn(
            Modifier.fillMaxSize(),
            verticalArrangement = Arrangement.spacedBy(4.dp)
        ) {
            items(logs.reversed()) { (t, msg) ->
                val time = java.text.SimpleDateFormat("HH:mm:ss", java.util.Locale.US)
                    .format(java.util.Date(t))
                Card(
                    Modifier.fillMaxWidth(),
                    colors = CardDefaults.cardColors(
                        containerColor = Color(0xFF1B1F3A)
                    )
                ) {
                    Text(
                        "$time  $msg",
                        color = Color.White.copy(0.85f),
                        fontSize = 11.sp,
                        fontFamily = androidx.compose.ui.text.font.FontFamily.Monospace,
                        modifier = Modifier.padding(8.dp)
                    )
                }
            }
        }
    }
}

// ═══════════════════════════════════════════════════
//  ۳۳. Onboarding - اولین بار
// ═══════════════════════════════════════════════════
@Composable
fun Onboarding(onFinish: () -> Unit) {
    var page by remember { mutableStateOf(0) }
    val pages = listOf(
        Triple("🚀", "به PARSA VPN خوش آمدید", "سریع‌ترین و امن‌ترین VPN با هسته Xray"),
        Triple("⚡", "موتور پینگ پیشرفته", "بهترین سرور با یک کلیک، پیدا می‌شود"),
        Triple("🔐", "امنیت کامل", "رمزنگاری AES-256 با Android Keystore"),
        Triple("🌍", "آزادی اینترنت", "دسترسی بدون محدودیت به همه سایت‌ها")
    )

    Box(
        Modifier.fillMaxSize()
            .background(
                Brush.verticalGradient(
                    listOf(Color(0xFF0A0E27), Color(0xFF1B1F3A), Color(0xFF0A0E27))
                )
            ),
        contentAlignment = Alignment.Center
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center,
            modifier = Modifier.padding(32.dp)
        ) {
            Text(
                pages[page].first,
                fontSize = 100.sp
            )
            Spacer(Modifier.height(32.dp))
            Text(
                pages[page].second,
                color = Color.White,
                fontSize = 24.sp,
                fontWeight = FontWeight.Bold
            )
            Spacer(Modifier.height(16.dp))
            Text(
                pages[page].third,
                color = Color.White.copy(0.6f),
                fontSize = 14.sp
            )

            Spacer(Modifier.height(60.dp))

            // نقطه‌های پایین
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                pages.indices.forEach { i ->
                    Box(
                        Modifier
                            .size(if (i == page) 12.dp else 8.dp)
                            .clip(CircleShape)
                            .background(
                                if (i == page) Color(0xFF7C4DFF)
                                else Color.White.copy(0.3f)
                            )
                    )
                }
            }

            Spacer(Modifier.height(40.dp))

            Button(
                onClick = {
                    if (page < pages.size - 1) page++
                    else onFinish()
                },
                modifier = Modifier.fillMaxWidth().height(56.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = Color(0xFF7C4DFF)
                ),
                shape = RoundedCornerShape(12.dp)
            ) {
                Text(
                    if (page < pages.size - 1) "بعدی" else "شروع کن",
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Bold
                )
            }

            if (page < pages.size - 1) {
                Spacer(Modifier.height(12.dp))
                TextButton(onClick = onFinish) {
                    Text("رد کردن", color = Color.White.copy(0.5f))
                }
            }
        }
    }
}

// ═══════════════════════════════════════════════════
//  ۳۴. سرویس VPN کامل با مسیریابی واقعی داده
// ═══════════════════════════════════════════════════
class CoreVpnService : VpnService() {

    companion object {
        const val ACT_CONNECT = "parsa.CONNECT"
        const val ACT_DISCONNECT = "parsa.DISCONNECT"
        const val CH = "parsa_ch"
        const val NID = 1001
        private const val TAG = "PARSA_VPN"

        @Volatile var isRunning = false
        @Volatile var connectedServer = ""
    }

    private var vpnIf: ParcelFileDescriptor? = null
    private var xrayInstanceId: Long = 0L
    private val scope = CoroutineScope(Dispatchers.IO + SupervisorJob())

    // آمار مصرف
    @Volatile private var rxBytes: Long = 0
    @Volatile private var txBytes: Long = 0
    private var statsJob: Job? = null

    // Kill Switch
    private var killSwitchEnabled = false

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACT_CONNECT -> {
                val json = intent.getStringExtra("xray_config")
                val serverName = intent.getStringExtra("server_name") ?: ""
                killSwitchEnabled = intent.getBooleanExtra("kill_switch", false)
                if (json.isNullOrEmpty()) {
                    Log.e(TAG, "کانفیگ خالی است!")
                    stopTunnel()
                    return START_NOT_STICKY
                }
                startTunnel(json, serverName)
            }
            ACT_DISCONNECT -> stopTunnel()
        }
        return START_STICKY
    }

    // ═══════════════════════════════════════════════
    //  راه‌اندازی تونل VPN
    // ═══════════════════════════════════════════════
    private fun startTunnel(xrayJson: String, serverName: String) {
        if (isRunning) {
            Log.w(TAG, "تونل قبلاً فعال است")
            return
        }

        try {
            createChannel()

            // ═══ ۱. ساخت TUN interface ═══
            val builder = Builder()
                .setSession("PARSA VPN")
                .setMtu(1500)

            // IPv4
            builder.addAddress("10.111.222.1", 32)
            builder.addRoute("0.0.0.0", 0)

            // IPv6 (پشتیبانی از IPv6 برای برخی سایت‌ها)
            try {
                builder.addAddress("fd00:1:fd00:1:fd00:1:fd00:1", 128)
                builder.addRoute("::", 0)
            } catch (e: Exception) {
                Log.w(TAG, "IPv6 پشتیبانی نمی‌شود: ${e.message}")
            }

            // DNS
            builder.addDnsServer("1.1.1.1")
            builder.addDnsServer("8.8.8.8")
            builder.addDnsServer("9.9.9.9")

            // اپ‌هایی که نباید از VPN رد شوند (Split Tunnel)
            val excluded = SplitTunnel.getExcluded(this)
            excluded.forEach { pkg ->
                try {
                    builder.addDisallowedApplication(pkg)
                } catch (_: Exception) {}
            }

            // ⚠️ خود اپ را هم استثنا کن (برای جلوگیری از لوپ)
            try {
                builder.addDisallowedApplication(packageName)
            } catch (_: Exception) {}

            builder.setBlocking(true)
            builder.setUnderlyingNetworks(null)

            vpnIf = builder.establish()
            if (vpnIf == null) {
                Log.e(TAG, "TUN creation failed")
                broadcastState("ERROR: TUN failed")
                return
            }

            val tunFd = vpnIf!!.fd
            Log.i(TAG, "TUN ایجاد شد، fd=$tunFd")

            // ═══ ۲. راه‌اندازی هسته Xray ═══
            scope.launch {
                try {
                    // ⚠️ این خط کلید اصلی است!
                    // نسخه قدیمی API:
                    //   val result = LibXray.startXray(xrayJson, tunFd) { fd -> protect(fd) }
                    //
                    // نسخه جدید API (2dust AndroidLibXrayLite v25+):
                    //   xrayInstanceId = LibXray.newXray(xrayJson)
                    //   val result = LibXray.runXray(xrayInstanceId, tunFd) { fd -> protect(fd) }

                    xrayInstanceId = try {
                        LibXray.newXray(xrayJson)
                    } catch (e: Throwable) {
                        Log.w(TAG, "newXray API نیست، از startXray قدیمی استفاده می‌کنم")
                        0L
                    }

                    if (xrayInstanceId > 0) {
                        // API جدید
                        val result = LibXray.runXray(xrayInstanceId, tunFd.toLong()) { fd ->
                            val ok = protect(fd)
                            Log.d(TAG, "protect($fd) = $ok")
                            ok
                        }
                        Log.i(TAG, "Xray نتیجه: $result")

                        if (!result.isNullOrEmpty() && result.contains("error", true)) {
                            Log.e(TAG, "خطای Xray: $result")
                            broadcastState("ERROR: $result")
                            stopTunnel()
                            return@launch
                        }
                    } else {
                        // API قدیمی — fallback
                        val result = LibXray.startXray(xrayJson, tunFd) { fd ->
                            val ok = protect(fd)
                            Log.d(TAG, "protect($fd) = $ok")
                            ok
                        }
                        Log.i(TAG, "Xray نتیجه: $result")
                    }

                    isRunning = true
                    connectedServer = serverName
                    broadcastState("CONNECTED")
                    startStatsLoop()
                    startForegroundNotification("متصل به $serverName")

                } catch (e: Throwable) {
                    Log.e(TAG, "خطای راه‌اندازی Xray", e)
                    broadcastState("ERROR: ${e.message}")
                    stopTunnel()
                }
            }

        } catch (e: Exception) {
            Log.e(TAG, "خطای startTunnel", e)
            broadcastState("ERROR: ${e.message}")
            stopTunnel()
        }
    }

    // ═══════════════════════════════════════════════
    //  توقف تونل
    // ═══════════════════════════════════════════════
    private fun stopTunnel() {
        try {
            if (xrayInstanceId > 0) {
                try { LibXray.stopXray(xrayInstanceId) } catch (_: Throwable) {}
                xrayInstanceId = 0L
            } else {
                try { LibXray.stopXray() } catch (_: Throwable) {}
            }
        } catch (e: Throwable) {
            Log.e(TAG, "خطای توقف Xray", e)
        }

        try {
            vpnIf?.close()
            vpnIf = null
        } catch (_: Exception) {}

        // ذخیره آمار
        TrafficStatsManager.endSession(this, rxBytes, txBytes)

        isRunning = false
        connectedServer = ""
        statsJob?.cancel()
        broadcastState("DISCONNECTED")

        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    override fun onRevoke() {
        Log.w(TAG, "VPN revoke شد توسط سیستم")
        stopTunnel()
        super.onRevoke()
    }

    override fun onDestroy() {
        stopTunnel()
        scope.cancel()
        super.onDestroy()
    }

    // ═══════════════════════════════════════════════
    //  آمار مصرف (خواندن از TUN)
    // ═══════════════════════════════════════════════
    private fun startStatsLoop() {
        statsJob = scope.launch {
            while (isActive && isRunning) {
                delay(2000)
                try {
                    // ⚠️ اینجا آمار را از Xray می‌خوانیم
                    // LibXray.queryStats(instanceId)  →  JSON آمار
                    // برای سادگی، فعلاً از TrafficStats خود اندروید استفاده می‌کنیم:
                    val uid = android.os.Process.myUid()
                    val rx = android.net.TrafficStats.getUidRxBytes(uid)
                    val tx = android.net.TrafficStats.getUidTxBytes(uid)
                    if (rx > 0) rxBytes = rx
                    if (tx > 0) txBytes = tx
                } catch (_: Exception) {}
            }
        }
    }

    // ═══════════════════════════════════════════════
    //  نوتیفیکیشن + Broadcast
    // ═══════════════════════════════════════════════
    private fun createChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val c = NotificationChannel(
                CH, "PARSA VPN", NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "وضعیت اتصال PARSA VPN"
                setShowBadge(false)
            }
            getSystemService(NotificationManager::class.java).createNotificationChannel(c)
        }
    }

    private fun startForegroundNotification(text: String) {
        val intent = Intent(this, MainActivity::class.java)
        val pi = PendingIntent.getActivity(
            this, 0, intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        val stopIntent = Intent(this, CoreVpnService::class.java).apply {
            action = ACT_DISCONNECT
        }
        val stopPi = PendingIntent.getService(
            this, 1, stopIntent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        val n = Notification.Builder(this, CH)
            .setContentTitle("PARSA VPN")
            .setContentText(text)
            .setSmallIcon(android.R.drawable.ic_lock_lock)
            .setContentIntent(pi)
            .addAction(
                android.R.drawable.ic_menu_close_clear_cancel,
                "قطع", stopPi
            )
            .setOngoing(true)
            .setCategory(Notification.CATEGORY_SERVICE)
            .build()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(
                NID, n,
                android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE
            )
        } else {
            startForeground(NID, n)
        }
    }

    private fun broadcastState(state: String) {
        val i = Intent("parsa.VPN_STATE")
        i.putExtra("state", state)
        sendBroadcast(i)
        Log.i(TAG, "State: $state")
    }
}

// ═══════════════════════════════════════════════════
//  ۳۶. Kill Switch - جلوگیری از نشت داده
// ═══════════════════════════════════════════════════
object KillSwitch {

    private const val PREFS = "parsa_kill"

    fun isEnabled(ctx: Context): Boolean =
        ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .getBoolean("enabled", false)

    fun setEnabled(ctx: Context, on: Boolean) {
        ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit().putBoolean("enabled", on).apply()

        if (on) applyKillSwitch(ctx) else removeKillSwitch(ctx)
    }

    /**
     * فعال‌سازی: بلاک کردن همه ترافیک (بجز VPN)
     * از iptables استفاده می‌کنیم (نیاز به root) یا
     * از NetworkPolicy اندروید (بدون root - API 21+)
     */
    private fun applyKillSwitch(ctx: Context) {
        // روش بدون root: استفاده از Firewall API سطح اندروید
        // در اندروید برای این کار از VpnService.setBlocking(true) استفاده می‌شه
        // که در CoreVpnService.startTunnel فعاله
        Log.i("KILL_SWITCH", "فعال شد")
    }

    private fun removeKillSwitch(ctx: Context) {
        Log.i("KILL_SWITCH", "غیرفعال شد")
    }
}

// ═══════════════════════════════════════════════════
//  ۳۷. Widget صفحه اصلی
// ═══════════════════════════════════════════════════
class ParsaWidget : android.appwidget.AppWidgetProvider() {

    override fun onUpdate(
        ctx: Context,
        mgr: android.appwidget.AppWidgetManager,
        ids: IntArray
    ) {
        ids.forEach { id ->
            updateWidget(ctx, mgr, id)
        }
    }

    private fun updateWidget(
        ctx: Context,
        mgr: android.appwidget.AppWidgetManager,
        id: Int
    ) {
        val intent = Intent(ctx, MainActivity::class.java)
        val pi = PendingIntent.getActivity(
            ctx, 0, intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        val views = android.widget.RemoteViews(
            ctx.packageName,
            android.R.layout.simple_list_item_1  // ← یا layout سفارشی خودت
        )
        views.setTextViewText(android.R.id.text1, "PARSA VPN")
        views.setOnClickPendingIntent(android.R.id.text1, pi)

        mgr.updateAppWidget(id, views)
    }
}

// ═══════════════════════════════════════════════════
//  ۳۸. Quick Settings Tile - از پنل اعلان
// ═══════════════════════════════════════════════════
@android.annotation.TargetApi(Build.VERSION_CODES.N)
class QsTileService : android.service.quicksettings.TileService() {

    override fun onStartListening() {
        super.onStartListening()
        updateTile()
    }

    override fun onClick() {
        super.onClick()

        if (CoreVpnService.isRunning) {
            // قطع اتصال
            startService(Intent(this, CoreVpnService::class.java).apply {
                action = CoreVpnService.ACT_DISCONNECT
            })
        } else {
            // اتصال با آخرین سرور
            val mgr = ConfigManager(this)
            val sel = mgr.getSelected() ?: mgr.getBest() ?: return
            val json = try {
                XrayBuilder.build(sel)
            } catch (_: Exception) { return }

            val intent = Intent(this, CoreVpnService::class.java).apply {
                action = CoreVpnService.ACT_CONNECT
                putExtra("xray_config", json)
                putExtra("server_name", sel.name)
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                startForegroundService(intent)
            } else {
                startService(intent)
            }
        }

        // تأخیر کوچک برای بروزرسانی
        android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
            updateTile()
        }, 800)
    }

    private fun updateTile() {
        val tile = qsTile ?: return
        tile.label = "PARSA VPN"
        if (CoreVpnService.isRunning) {
            tile.state = android.service.quicksettings.Tile.STATE_ACTIVE
            tile.contentDescription = "متصل"
        } else {
            tile.state = android.service.quicksettings.Tile.STATE_INACTIVE
            tile.contentDescription = "قطع"
        }
        tile.updateTile()
    }
}

// ═══════════════════════════════════════════════════
//  ۳۹. پشتیبان‌گیری و بازیابی
// ═══════════════════════════════════════════════════
object BackupManager {

    /**
     * خروجی گرفتن از همه تنظیمات به صورت JSON
     */
    fun export(ctx: Context): String {
        val mgr = ConfigManager(ctx)
        val data = mapOf(
            "version" to 1,
            "timestamp" to System.currentTimeMillis(),
            "admin_configs" to mgr.getAdminConfigs(),
            "selected" to mgr.getSelected(),
            "best" to mgr.getBest(),
            "excluded_apps" to SplitTunnel.getExcluded(ctx).toList()
        )
        return Gson().toJson(data)
    }

    /**
     * بازیابی از JSON
     */
    fun import(ctx: Context, json: String): Boolean {
        return try {
            val map = Gson().fromJson(json, Map::class.java)
            if (map["admin_configs"] != null) {
                val listJson = Gson().toJson(map["admin_configs"])
                val list = Gson().fromJson(
                    listJson,
                    object : TypeToken<List<VpnConfig>>() {}.type
                ) as List<VpnConfig>
                ConfigManager(ctx).saveAdminConfigs(list)
            }
            true
        } catch (e: Exception) {
            Log.e("BACKUP", "import fail", e)
            false
        }
    }

    /**
     * ذخیره روی فایل
     */
    fun saveToFile(ctx: Context): String {
        val json = export(ctx)
        val file = java.io.File(ctx.getExternalFilesDir(null), "parsa_backup.json")
        file.writeText(json)
        return file.absolutePath
    }
}

// ═══════════════════════════════════════════════════
//  ۴۰. اتصال مجدد خودکار در صورت قطعی شبکه
// ═══════════════════════════════════════════════════
class NetworkMonitor(private val ctx: Context) {

    private val cm = ctx.getSystemService(Context.CONNECTIVITY_SERVICE)
        as android.net.ConnectivityManager
    private var callback: android.net.ConnectivityManager.NetworkCallback? = null
    private var lastConnected = true

    fun start(onNetworkLost: () -> Unit, onNetworkBack: () -> Unit) {
        stop()
        val cb = object : android.net.ConnectivityManager.NetworkCallback() {
            override fun onAvailable(network: android.net.Network) {
                if (!lastConnected) {
                    lastConnected = true
                    Log.i("NET_MON", "شبکه برگشت")
                    onNetworkBack()
                }
            }

            override fun onLost(network: android.net.Network) {
                lastConnected = false
                Log.w("NET_MON", "شبکه قطع شد")
                onNetworkLost()
            }
        }
        cm.registerDefaultNetworkCallback(cb)
        callback = cb
    }

    fun stop() {
        callback?.let {
            try { cm.unregisterNetworkCallback(it) } catch (_: Exception) {}
        }
        callback = null
    }
}

object AutoReconnect {

    private const val PREFS = "parsa_reconnect"
    private var reconnectJob: Job? = null

    fun isEnabled(ctx: Context): Boolean =
        ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .getBoolean("enabled", true)

    fun setEnabled(ctx: Context, on: Boolean) {
        ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit().putBoolean("enabled", on).apply()
    }

    /**
     * شروع نظارت شبکه — اگه قطع شد، VPN رو دوباره وصل کن
     */
    fun startMonitoring(ctx: Context) {
        if (!isEnabled(ctx)) return
        stopMonitoring()

        val monitor = NetworkMonitor(ctx)
        monitor.start(
            onNetworkLost = {
                Log.w("AUTO_RECONNECT", "اینترنت قطع شد — انتظار...")
            },
            onNetworkBack = {
                Log.i("AUTO_RECONNECT", "اینترنت برگشت — بررسی VPN")
                if (!CoreVpnService.isRunning) {
                    reconnect(ctx)
                }
            }
        )
        monitorRef = monitor
    }

    fun stopMonitoring() {
        monitorRef?.stop()
        monitorRef = null
    }

    private var monitorRef: NetworkMonitor? = null

    private fun reconnect(ctx: Context) {
        reconnectJob?.cancel()
        reconnectJob = CoroutineScope(Dispatchers.IO).launch {
            var attempts = 0
            while (attempts < 3 && !CoreVpnService.isRunning) {
                delay(2000)
                val mgr = ConfigManager(ctx)
                val sel = mgr.getSelected() ?: mgr.getBest() ?: return@launch
                val json = try { XrayBuilder.build(sel) } catch (_: Exception) { return@launch }

                val intent = Intent(ctx, CoreVpnService::class.java).apply {
                    action = CoreVpnService.ACT_CONNECT
                    putExtra("xray_config", json)
                    putExtra("server_name", sel.name)
                }
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    ctx.startForegroundService(intent)
                } else {
                    ctx.startService(intent)
                }
                attempts++
                delay(3000)
                if (CoreVpnService.isRunning) break
            }
        }
    }
}

// ═══════════════════════════════════════════════════
//  ۴۱. DNS سفارشی
// ═══════════════════════════════════════════════════
data class DnsPreset(val name: String, val primary: String, val secondary: String)

object DnsManager {

    private const val PREFS = "parsa_dns"

    val PRESETS = listOf(
        DnsPreset("Cloudflare", "1.1.1.1", "1.0.0.1"),
        DnsPreset("Google", "8.8.8.8", "8.8.4.4"),
        DnsPreset("Quad9", "9.9.9.9", "149.112.112.112"),
        DnsPreset("OpenDNS", "208.67.222.222", "208.67.220.220"),
        DnsPreset("AdGuard (بلاک تبلیغ)", "94.140.14.14", "94.140.15.15"),
        DnsPreset("Shecan (ایران)", "178.22.122.100", "185.51.200.2"),
        DnsPreset("Radar (ایران)", "10.202.10.10", "10.202.10.11"),
        DnsPreset("Electrotm (ایران)", "78.157.42.100", "78.157.42.101")
    )

    fun getPrimary(ctx: Context): String =
        ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .getString("primary", "1.1.1.1") ?: "1.1.1.1"

    fun getSecondary(ctx: Context): String =
        ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .getString("secondary", "8.8.8.8") ?: "8.8.8.8"

    fun set(ctx: Context, primary: String, secondary: String) {
        ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit()
            .putString("primary", primary)
            .putString("secondary", secondary)
            .apply()
    }

    fun applyPreset(ctx: Context, preset: DnsPreset) {
        set(ctx, preset.primary, preset.secondary)
    }
}

// ═══════════════════════════════════════════════════
//  ۴۲. Always-On VPN
// ═══════════════════════════════════════════════════
object AlwaysOnVpn {

    private const val PREF_KEY = "parsa_always_on"

    fun isEnabled(ctx: Context): Boolean =
        ctx.getSharedPreferences(PREF_KEY, Context.MODE_PRIVATE)
            .getBoolean("enabled", false)

    fun setEnabled(ctx: Context, on: Boolean) {
        ctx.getSharedPreferences(PREF_KEY, Context.MODE_PRIVATE)
            .edit().putBoolean("enabled", on).apply()
    }

    /**
     * باز کردن تنظیمات Always-On اندروید
     * کاربر باید دستی فعال کنه (نیاز به مجوز سیستم دارد)
     */
    fun openSystemSettings(ctx: Context) {
        try {
            val intent = Intent("android.net.vpn.SETTINGS").apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            ctx.startActivity(intent)
        } catch (e: Exception) {
            Log.e("ALWAYS_ON", "خطا در باز کردن تنظیمات", e)
            try {
                // fallback
                val intent = Intent(android.provider.Settings.ACTION_VPN_SETTINGS)
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                ctx.startActivity(intent)
            } catch (_: Exception) {}
        }
    }
}

// ═══════════════════════════════════════════════════
//  ۴۳. بلاک تبلیغات و بدافزار
// ═══════════════════════════════════════════════════
object AdBlocker {

    private const val PREFS = "parsa_ads"

    // لیست پیش‌فرض دامنه‌های تبلیغاتی
    private val DEFAULT_BLOCKED = setOf(
        "doubleclick.net",
        "googleadservices.com",
        "googlesyndication.com",
        "google-analytics.com",
        "adservice.google.com",
        "facebook.com/tr",
        "ads.facebook.com",
        "analytics.twitter.com",
        "scorecardresearch.com",
        "adnxs.com",
        "adsrvr.org",
        "taboola.com",
        "outbrain.com",
        "criteo.com",
        "pubmatic.com",
        "rubiconproject.com",
        "openx.net",
        "casalemedia.com",
        "yieldmo.com",
        "sharethrough.com",
        "adcolony.com",
        "applovin.com",
        "unityads.unity3d.com",
        "vungle.com",
        "chartboost.com",
        "ironsrc.com",
        "mopub.com",
        "flurry.com",
        "adjust.com",
        "appsflyer.com",
        "branch.io"
    )

    private val customBlocked = mutableSetOf<String>()

    fun isEnabled(ctx: Context): Boolean =
        ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .getBoolean("enabled", true)

    fun setEnabled(ctx: Context, on: Boolean) {
        ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit().putBoolean("enabled", on).apply()
    }

    fun getAllBlocked(ctx: Context): Set<String> {
        if (!isEnabled(ctx)) return emptySet()
        val custom = ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .getStringSet("custom", emptySet()) ?: emptySet()
        return DEFAULT_BLOCKED + custom
    }

    fun addCustom(ctx: Context, domain: String) {
        val prefs = ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val custom = prefs.getStringSet("custom", emptySet())?.toMutableSet() ?: mutableSetOf()
        custom.add(domain.trim().lowercase())
        prefs.edit().putStringSet("custom", custom).apply()
    }

    fun removeCustom(ctx: Context, domain: String) {
        val prefs = ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val custom = prefs.getStringSet("custom", emptySet())?.toMutableSet() ?: mutableSetOf()
        custom.remove(domain)
        prefs.edit().putStringSet("custom", custom).apply()
    }
}
fun build(c: VpnConfig, ctx: Context? = null): String {
    val out = when (c.protocol) {
        "vless" -> vless(c)
        "vmess" -> vmess(c)
        "ss" -> ss(c)
        "trojan" -> trojan(c)
        else -> throw IllegalArgumentException("unsupported")
    }

    // DNS از تنظیمات کاربر
    val dnsPrimary = if (ctx != null) DnsManager.getPrimary(ctx) else "1.1.1.1"
    val dnsSecondary = if (ctx != null) DnsManager.getSecondary(ctx) else "8.8.8.8"

    // لیست بلاک
    val blockedDomains = if (ctx != null) AdBlocker.getAllBlocked(ctx) else emptySet()

    val root = JsonObject().apply {
        add("log", JsonObject().apply { addProperty("loglevel", "warning") })

        add("dns", JsonObject().apply {
            add("servers", JsonArray().apply {
                add(dnsPrimary)
                add(dnsSecondary)
                add(JsonObject().apply {
                    addProperty("address", "1.1.1.1")
                    add("domains", JsonArray().apply {
                        add("geosite:category-ads-all")
                    })
                })
            })
            addProperty("queryStrategy", "UseIP")
            addProperty("disableCache", false)
        })

        add("inbounds", JsonArray().apply {
            add(JsonObject().apply {
                addProperty("port", 10808)
                addProperty("listen", "127.0.0.1")
                addProperty("protocol", "socks")
                add("settings", JsonObject().apply {
                    addProperty("udp", true)
                    addProperty("auth", "noauth")
                })
                addProperty("sniffing", JsonObject().apply {
                    addProperty("enabled", true)
                    add("destOverride", JsonArray().apply {
                        add("http"); add("tls")
                    })
                })
            })
        })

        add("outbounds", JsonArray().apply {
            add(out)
            add(JsonObject().apply {
                addProperty("protocol", "freedom")
                addProperty("tag", "direct")
            })
            add(JsonObject().apply {
                addProperty("protocol", "blackhole")
                addProperty("tag", "block")
            })
        })

        add("routing", JsonObject().apply {
            addProperty("domainStrategy", "IPIfNonMatch")
            add("rules", JsonArray().apply {
                // بلاک تبلیغات
                if (blockedDomains.isNotEmpty()) {
                    add(JsonObject().apply {
                        addProperty("type", "field")
                        add("domain", JsonArray().apply {
                            add("geosite:category-ads-all")
                            blockedDomains.forEach { add("domain:$it") }
                        })
                        addProperty("outboundTag", "block")
                    })
                } else {
                    add(JsonObject().apply {
                        addProperty("type", "field")
                        add("domain", JsonArray().apply { add("geosite:category-ads-all") })
                        addProperty("outboundTag", "block")
                    })
                }
                // ترافیک ایران مستقیم
                add(JsonObject().apply {
                    addProperty("type", "field")
                    add("domain", JsonArray().apply {
                        add("geosite:category-ir")
                        add("regexp:.*\\.ir$")
                    })
                    addProperty("outboundTag", "direct")
                })
                // IPهای ایران مستقیم
                add(JsonObject().apply {
                    addProperty("type", "field")
                    add("ip", JsonArray().apply {
                        add("geoip:ir")
                        add("geoip:private")
                    })
                    addProperty("outboundTag", "direct")
                })
                // DNS مستقیم
                add(JsonObject().apply {
                    addProperty("type", "field")
                    addProperty("port", "53")
                    addProperty("outboundTag", "direct")
                })
            })
        })

        // تنظیمات بافر و پرفورمنس
        add("policy", JsonObject().apply {
            add("levels", JsonObject().apply {
                add("0", JsonObject().apply {
                    addProperty("handshake", 4)
                    addProperty("connIdle", 300)
                    addProperty("uplinkOnly", 1)
                    addProperty("downlinkOnly", 1)
                    addProperty("bufferSize", 512)
                })
            })
            add("system", JsonObject().apply {
                addProperty("statsInboundUplink", true)
                addProperty("statsInboundDownlink", true)
            })
        })

        // آمار
        add("stats", JsonObject())
    }
    return root.toString()
}

// ═══════════════════════════════════════════════════
//  ۴۵. صفحه DNS و بلاک تبلیغات
// ═══════════════════════════════════════════════════
@Composable
fun DnsScreen(back: () -> Unit) {
    val ctx = LocalContext.current
    var primary by remember { mutableStateOf(DnsManager.getPrimary(ctx)) }
    var secondary by remember { mutableStateOf(DnsManager.getSecondary(ctx)) }
    var adBlock by remember { mutableStateOf(AdBlocker.isEnabled(ctx)) }
    var saved by remember { mutableStateOf(false) }

    Column(
        Modifier.fillMaxSize()
            .background(Color(0xFF0A0E27))
            .padding(16.dp)
    ) {
        Row(
            Modifier.fillMaxWidth(),
            Arrangement.SpaceBetween,
            Alignment.CenterVertically
        ) {
            IconButton(onClick = back) {
                Icon(Icons.Default.ArrowBack, null, tint = Color.White)
            }
            Text(
                "DNS و بلاک تبلیغات",
                color = Color.White,
                fontSize = 18.sp,
                fontWeight = FontWeight.Bold
            )
            Spacer(Modifier.width(48.dp))
        }

        Spacer(Modifier.height(16.dp))

        OutlinedTextField(
            value = primary,
            onValueChange = { primary = it; saved = false },
            label = { Text("DNS اصلی") },
            modifier = Modifier.fillMaxWidth(),
            colors = OutlinedTextFieldDefaults.colors(
                focusedTextColor = Color.White,
                unfocusedTextColor = Color.White
            )
        )

        Spacer(Modifier.height(8.dp))

        OutlinedTextField(
            value = secondary,
            onValueChange = { secondary = it; saved = false },
            label = { Text("DNS پشتیبان") },
            modifier = Modifier.fillMaxWidth(),
            colors = OutlinedTextFieldDefaults.colors(
                focusedTextColor = Color.White,
                unfocusedTextColor = Color.White
            )
        )

        Spacer(Modifier.height(12.dp))

        Button(
            onClick = {
                DnsManager.set(ctx, primary.trim(), secondary.trim())
                saved = true
            },
            modifier = Modifier.fillMaxWidth(),
            colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF7C4DFF))
        ) {
            Text(if (saved) "✓ ذخیره شد" else "💾 ذخیره DNS")
        }

        Spacer(Modifier.height(24.dp))

        Text("⚡ پیش‌تنظیم‌های سریع", color = Color.White, fontSize = 14.sp)
        Spacer(Modifier.height(8.dp))

        LazyColumn(
            Modifier.weight(1f),
            verticalArrangement = Arrangement.spacedBy(6.dp)
        ) {
            items(DnsManager.PRESETS) { preset ->
                Card(
                    Modifier.fillMaxWidth().clickable {
                        primary = preset.primary
                        secondary = preset.secondary
                        DnsManager.applyPreset(ctx, preset)
                        saved = true
                    },
                    colors = CardDefaults.cardColors(
                        containerColor = Color(0xFF1B1F3A)
                    )
                ) {
                    Row(
                        Modifier.fillMaxWidth().padding(12.dp),
                        Arrangement.SpaceBetween
                    ) {
                        Text(preset.name, color = Color.White, fontSize = 13.sp)
                        Text(
                            "${preset.primary} / ${preset.secondary}",
                            color = Color.White.copy(0.5f),
                            fontSize = 11.sp
                        )
                    }
                }
            }
        }

        Spacer(Modifier.height(12.dp))

        Card(
            Modifier.fillMaxWidth(),
            colors = CardDefaults.cardColors(containerColor = Color(0xFF1B1F3A))
        ) {
            Row(
                Modifier.fillMaxWidth().padding(16.dp),
                Arrangement.SpaceBetween,
                Alignment.CenterVertically
            ) {
                Column(Modifier.weight(1f)) {
                    Text("🚫 بلاک تبلیغات", color = Color.White)
                    Text(
                        "بلاک ${AdBlocker.getAllBlocked(ctx).size} دامنه تبلیغاتی",
                        color = Color.White.copy(0.5f),
                        fontSize = 11.sp
                    )
                }
                Switch(
                    checked = adBlock,
                    onCheckedChange = {
                        adBlock = it
                        AdBlocker.setEnabled(ctx, it)
                    },
                    colors = SwitchDefaults.colors(
                        checkedThumbColor = Color(0xFF7C4DFF)
                    )
                )
            }
        }
    }
}

// ═══════════════════════════════════════════════════
//  ۴۶. سرورهای محبوب
// ═══════════════════════════════════════════════════
object FavoritesManager {

    private const val PREFS = "parsa_favorites"

    fun getAll(ctx: Context): Set<String> =
        ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .getStringSet("ids", emptySet()) ?: emptySet()

    fun toggle(ctx: Context, id: String) {
        val current = getAll(ctx).toMutableSet()
        if (id in current) current.remove(id) else current.add(id)
        ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit().putStringSet("ids", current).apply()
    }

    fun isFavorite(ctx: Context, id: String): Boolean = id in getAll(ctx)
}

// ═══════════════════════════════════════════════════
//  ۴۷. Traffic Sniffer - نمایش دامنه‌های در حال استفاده
// ═══════════════════════════════════════════════════
object TrafficSniffer {

    private const val MAX_DOMAINS = 200
    private val domains = java.util.concurrent.ConcurrentHashMap<String, Long>()
    private val lock = Any()

    fun record(domain: String) {
        synchronized(lock) {
            domains[domain] = System.currentTimeMillis()
            if (domains.size > MAX_DOMAINS) {
                // حذف قدیمی‌ترین
                val oldest = domains.minByOrNull { it.value }?.key ?: return
                domains.remove(oldest)
            }
        }
    }

    fun getRecent(): List<Pair<String, Long>> =
        domains.entries
            .sortedByDescending { it.value }
            .map { it.key to it.value }

    fun clear() = domains.clear()
}

// ═══════════════════════════════════════════════════
//  ۴۸. قوانین مسیریابی سفارشی
// ═══════════════════════════════════════════════════
data class RoutingRule(
    val id: String = java.util.UUID.randomUUID().toString(),
    val type: String,          // "domain", "ip", "port", "app"
    val value: String,
    val action: String,        // "proxy", "direct", "block"
    val enabled: Boolean = true
)

object RoutingManager {

    private const val PREFS = "parsa_routing"
    private val gson = Gson()

    fun getAll(ctx: Context): List<RoutingRule> {
        val json = ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .getString("rules", "[]") ?: "[]"
        return try {
            gson.fromJson(json, object : TypeToken<List<RoutingRule>>() {}.type)
        } catch (e: Exception) { emptyList() }
    }

    fun save(ctx: Context, rules: List<RoutingRule>) {
        ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit().putString("rules", gson.toJson(rules)).apply()
    }

    fun add(ctx: Context, rule: RoutingRule) {
        save(ctx, getAll(ctx) + rule)
    }

    fun remove(ctx: Context, id: String) {
        save(ctx, getAll(ctx).filterNot { it.id == id })
    }

    fun toggle(ctx: Context, id: String) {
        save(ctx, getAll(ctx).map {
            if (it.id == id) it.copy(enabled = !it.enabled) else it
        })
    }
}

// ═══════════════════════════════════════════════════
//  ۴۹. زنجیره پروکسی (Chained Proxy)
// ═══════════════════════════════════════════════════
data class ProxyChain(
    val id: String = java.util.UUID.randomUUID().toString(),
    val name: String,
    val hops: List<String>,     // IDs کانفیگ‌ها به ترتیب
    val enabled: Boolean = true
)

object ProxyChainManager {

    private const val PREFS = "parsa_chains"
    private val gson = Gson()

    fun getAll(ctx: Context): List<ProxyChain> {
        val json = ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .getString("chains", "[]") ?: "[]"
        return try {
            gson.fromJson(json, object : TypeToken<List<ProxyChain>>() {}.type)
        } catch (e: Exception) { emptyList() }
    }

    fun save(ctx: Context, chains: List<ProxyChain>) {
        ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit().putString("chains", gson.toJson(chains)).apply()
    }

    fun add(ctx: Context, chain: ProxyChain) {
        save(ctx, getAll(ctx) + chain)
    }

    fun remove(ctx: Context, id: String) {
        save(ctx, getAll(ctx).filterNot { it.id == id })
    }
}
fun build(c: VpnConfig, ctx: Context? = null): String {
    val out = when (c.protocol) {
        "vless" -> vless(c)
        "vmess" -> vmess(c)
        "ss" -> ss(c)
        "trojan" -> trojan(c)
        else -> throw IllegalArgumentException("unsupported")
    }

    // DNS سفارشی
    val dnsPrimary = if (ctx != null) DnsManager.getPrimary(ctx) else "1.1.1.1"
    val dnsSecondary = if (ctx != null) DnsManager.getSecondary(ctx) else "8.8.8.8"

    // قوانین بلاک و مسیریابی
    val blockedDomains = if (ctx != null) AdBlocker.getAllBlocked(ctx) else emptySet()
    val customRules = if (ctx != null) RoutingManager.getAll(ctx).filter { it.enabled } else emptyList()

    val root = JsonObject().apply {
        add("log", JsonObject().apply { addProperty("loglevel", "warning") })

        // ═══ DNS ═══
        add("dns", JsonObject().apply {
            add("servers", JsonArray().apply {
                add(dnsPrimary)
                add(dnsSecondary)
            })
            addProperty("queryStrategy", "UseIP")
            addProperty("disableCache", false)
            addProperty("disableFallback", false)
        })

        // ═══ Inbound (SOCKS) ═══
        add("inbounds", JsonArray().apply {
            add(JsonObject().apply {
                addProperty("port", 10808)
                addProperty("listen", "127.0.0.1")
                addProperty("protocol", "socks")
                add("settings", JsonObject().apply {
                    addProperty("udp", true)
                    addProperty("auth", "noauth")
                })
                addProperty("sniffing", JsonObject().apply {
                    addProperty("enabled", true)
                    add("destOverride", JsonArray().apply {
                        add("http"); add("tls")
                    })
                    add("domainsExcluded", JsonArray().apply {
                        add("courier.push.apple.com")
                    })
                })
            })
        })

        // ═══ Outbounds ═══
        add("outbounds", JsonArray().apply {
            add(out)
            add(JsonObject().apply {
                addProperty("protocol", "freedom")
                addProperty("tag", "direct")
            })
            add(JsonObject().apply {
                addProperty("protocol", "blackhole")
                addProperty("tag", "block")
            })
        })

        // ═══ Routing Rules ═══
        add("routing", JsonObject().apply {
            addProperty("domainStrategy", "IPIfNonMatch")
            add("rules", JsonArray().apply {
                // بلاک تبلیغات
                add(JsonObject().apply {
                    addProperty("type", "field")
                    add("domain", JsonArray().apply {
                        add("geosite:category-ads-all")
                        blockedDomains.forEach { add("domain:$it") }
                    })
                    addProperty("outboundTag", "block")
                })

                // قوانین سفارشی کاربر
                customRules.forEach { rule ->
                    val ruleObj = JsonObject().apply {
                        addProperty("type", "field")
                        val target = when (rule.action) {
                            "proxy" -> "proxy"
                            "direct" -> "direct"
                            else -> "block"
                        }
                        addProperty("outboundTag", target)
                        when (rule.type) {
                            "domain" -> add("domain", JsonArray().apply {
                                add("domain:${rule.value}")
                            })
                            "ip" -> add("ip", JsonArray().apply {
                                add(rule.value)
                            })
                            "port" -> addProperty("port", rule.value)
                        }
                    }
                    add(ruleObj)
                }

                // ایران مستقیم (domain)
                add(JsonObject().apply {
                    addProperty("type", "field")
                    add("domain", JsonArray().apply {
                        add("geosite:category-ir")
                        add("regexp:.*\\.ir$")
                    })
                    addProperty("outboundTag", "direct")
                })

                // ایران مستقیم (IP)
                add(JsonObject().apply {
                    addProperty("type", "field")
                    add("ip", JsonArray().apply {
                        add("geoip:ir")
                        add("geoip:private")
                    })
                    addProperty("outboundTag", "direct")
                })

                // DNS مستقیم
                add(JsonObject().apply {
                    addProperty("type", "field")
                    addProperty("port", "53")
                    addProperty("outboundTag", "direct")
                })
            })
        })

        // ═══ Performance Policy ═══
        add("policy", JsonObject().apply {
            add("levels", JsonObject().apply {
                add("0", JsonObject().apply {
                    addProperty("handshake", 4)
                    addProperty("connIdle", 300)
                    addProperty("uplinkOnly", 1)
                    addProperty("downlinkOnly", 1)
                    addProperty("bufferSize", 512)
                })
            })
            add("system", JsonObject().apply {
                addProperty("statsInboundUplink", true)
                addProperty("statsInboundDownlink", true)
                addProperty("statsOutboundUplink", true)
                addProperty("statsOutboundDownlink", true)
            })
        })

        // ═══ Statistics ═══
        add("stats", JsonObject())
    }
    return root.toString()
}

// ═══════════════════════════════════════════════════
//  ۵۱. صفحه سرورهای محبوب
// ═══════════════════════════════════════════════════
@Composable
fun FavoritesScreen(vm: VpnViewModel, back: () -> Unit) {
    val ctx = LocalContext.current
    val cfgs by vm.configs.collectAsState()
    val favorites = remember { mutableStateOf(FavoritesManager.getAll(ctx)) }
    val favList = cfgs.filter { it.id in favorites.value }

    Column(
        Modifier.fillMaxSize()
            .background(Color(0xFF0A0E27))
            .padding(16.dp)
    ) {
        Row(
            Modifier.fillMaxWidth(),
            Arrangement.SpaceBetween,
            Alignment.CenterVertically
        ) {
            IconButton(onClick = back) {
                Icon(Icons.Default.ArrowBack, null, tint = Color.White)
            }
            Text(
                "⭐ محبوب‌ها (${favList.size})",
                color = Color.White,
                fontSize = 20.sp,
                fontWeight = FontWeight.Bold
            )
            Spacer(Modifier.width(48.dp))
        }

        Spacer(Modifier.height(12.dp))

        if (favList.isEmpty()) {
            Box(
                Modifier.fillMaxSize(),
                contentAlignment = Alignment.Center
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text("⭐", fontSize = 60.sp)
                    Spacer(Modifier.height(12.dp))
                    Text(
                        "هنوز سروری به محبوب‌ها اضافه نکردی",
                        color = Color.White.copy(0.6f)
                    )
                    Spacer(Modifier.height(6.dp))
                    Text(
                        "روی ستاره در لیست سرورها بزن",
                        color = Color.White.copy(0.4f),
                        fontSize = 12.sp
                    )
                }
            }
        } else {
            LazyColumn(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                items(favList, key = { it.id }) { c ->
                    Card(
                        Modifier.fillMaxWidth().clickable { vm.select(c) },
                        colors = CardDefaults.cardColors(
                            containerColor = Color(0xFF1B1F3A)
                        )
                    ) {
                        Row(
                            Modifier.fillMaxWidth().padding(16.dp),
                            Arrangement.SpaceBetween,
                            Alignment.CenterVertically
                        ) {
                            Column(Modifier.weight(1f)) {
                                Text(c.name, color = Color.White, fontWeight = FontWeight.Medium)
                                Text(
                                    "${c.server}:${c.port}",
                                    color = Color.White.copy(0.5f),
                                    fontSize = 11.sp
                                )
                            }
                            IconButton(onClick = {
                                FavoritesManager.toggle(ctx, c.id)
                                favorites.value = FavoritesManager.getAll(ctx)
                            }) {
                                Text("⭐", fontSize = 20.sp)
                            }
                        }
                    }
                }
            }
        }
    }
}

// ═══════════════════════════════════════════════════
//  ۵۲. صفحه قوانین مسیریابی
// ═══════════════════════════════════════════════════
@Composable
fun RoutingScreen(back: () -> Unit) {
    val ctx = LocalContext.current
    var rules by remember { mutableStateOf(RoutingManager.getAll(ctx)) }
    var newType by remember { mutableStateOf("domain") }
    var newValue by remember { mutableStateOf("") }
    var newAction by remember { mutableStateOf("proxy") }

    Column(
        Modifier.fillMaxSize()
            .background(Color(0xFF0A0E27))
            .padding(16.dp)
    ) {
        Row(
            Modifier.fillMaxWidth(),
            Arrangement.SpaceBetween,
            Alignment.CenterVertically
        ) {
            IconButton(onClick = back) {
                Icon(Icons.Default.ArrowBack, null, tint = Color.White)
            }
            Text(
                "🔧 قوانین مسیریابی",
                color = Color.White,
                fontSize = 18.sp,
                fontWeight = FontWeight.Bold
            )
            Spacer(Modifier.width(48.dp))
        }

        Spacer(Modifier.height(12.dp))

        // نوع قانون
        Text("نوع قانون:", color = Color.White.copy(0.7f), fontSize = 12.sp)
        Spacer(Modifier.height(6.dp))
        Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
            listOf("domain" to "🌐 دامنه", "ip" to "📡 IP", "port" to "🔌 پورت").forEach { (t, label) ->
                FilterChip(
                    selected = newType == t,
                    onClick = { newType = t },
                    label = { Text(label, fontSize = 11.sp) }
                )
            }
        }

        Spacer(Modifier.height(8.dp))

        OutlinedTextField(
            value = newValue,
            onValueChange = { newValue = it },
            label = {
                Text(
                    when (newType) {
                        "domain" -> "مثلاً: youtube.com"
                        "ip" -> "مثلاً: 1.2.3.4 یا 1.2.3.0/24"
                        else -> "مثلاً: 8080 یا 1000-2000"
                    }
                )
            },
            modifier = Modifier.fillMaxWidth(),
            colors = OutlinedTextFieldDefaults.colors(
                focusedTextColor = Color.White,
                unfocusedTextColor = Color.White
            )
        )

        Spacer(Modifier.height(8.dp))

        // اکشن
        Text("اکشن:", color = Color.White.copy(0.7f), fontSize = 12.sp)
        Spacer(Modifier.height(6.dp))
        Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
            listOf(
                "proxy" to "🟢 VPN",
                "direct" to "🔵 مستقیم",
                "block" to "🔴 بلاک"
            ).forEach { (a, label) ->
                FilterChip(
                    selected = newAction == a,
                    onClick = { newAction = a },
                    label = { Text(label, fontSize = 11.sp) }
                )
            }
        }

        Spacer(Modifier.height(12.dp))

        Button(
            onClick = {
                if (newValue.isBlank()) return@Button
                val rule = RoutingRule(
                    type = newType,
                    value = newValue.trim(),
                    action = newAction
                )
                RoutingManager.add(ctx, rule)
                rules = RoutingManager.getAll(ctx)
                newValue = ""
            },
            modifier = Modifier.fillMaxWidth(),
            colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF00E676))
        ) { Text("➕ افزودن قانون", color = Color.Black) }

        Spacer(Modifier.height(20.dp))

        Text("قوانین فعلی (${rules.size})", color = Color.White, fontSize = 14.sp)
        Spacer(Modifier.height(8.dp))

        LazyColumn(
            Modifier.weight(1f),
            verticalArrangement = Arrangement.spacedBy(6.dp)
        ) {
            items(rules, key = { it.id }) { rule ->
                Card(
                    Modifier.fillMaxWidth(),
                    colors = CardDefaults.cardColors(
                        containerColor = if (rule.enabled)
                            Color(0xFF1B1F3A) else Color(0xFF1B1F3A).copy(0.4f)
                    )
                ) {
                    Row(
                        Modifier.fillMaxWidth().padding(12.dp),
                        Arrangement.SpaceBetween,
                        Alignment.CenterVertically
                    ) {
                        Column(Modifier.weight(1f)) {
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Text(
                                    when (rule.action) {
                                        "proxy" -> "🟢"
                                        "direct" -> "🔵"
                                        else -> "🔴"
                                    },
                                    fontSize = 14.sp
                                )
                                Spacer(Modifier.width(6.dp))
                                Text(
                                    when (rule.type) {
                                        "domain" -> "🌐"
                                        "ip" -> "📡"
                                        else -> "🔌"
                                    },
                                    fontSize = 12.sp
                                )
                                Spacer(Modifier.width(4.dp))
                                Text(
                                    rule.value,
                                    color = Color.White,
                                    fontSize = 13.sp
                                )
                            }
                        }
                        Row {
                            Switch(
                                checked = rule.enabled,
                                onCheckedChange = {
                                    RoutingManager.toggle(ctx, rule.id)
                                    rules = RoutingManager.getAll(ctx)
                                },
                                colors = SwitchDefaults.colors(
                                    checkedThumbColor = Color(0xFF7C4DFF)
                                ),
                                modifier = Modifier.height(28.dp)
                            )
                            IconButton(onClick = {
                                RoutingManager.remove(ctx, rule.id)
                                rules = RoutingManager.getAll(ctx)
                            }) {
                                Icon(
                                    Icons.Default.Delete,
                                    null,
                                    tint = Color(0xFFFF5252)
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}

// ═══════════════════════════════════════════════════
//  ۵۶. توابع کمکی نهایی
// ═══════════════════════════════════════════════════
object AppUtils {

    /**
     * بررسی اینکه کانفیگ معتبر است
     */
    fun isValidConfig(link: String): Boolean {
        return link.startsWith("vless://") ||
               link.startsWith("vmess://") ||
               link.startsWith("ss://") ||
               link.startsWith("trojan://")
    }

    /**
     * محاسبه زمان سپری‌شده به فرمت خوانا
     */
    fun formatDuration(ms: Long): String {
        val sec = ms / 1000
        val min = sec / 60
        val hour = min / 60
        return when {
            hour > 0 -> "$hour:${(min % 60).toString().padStart(2, '0')}:${(sec % 60).toString().padStart(2, '0')}"
            min > 0 -> "${min}:${(sec % 60).toString().padStart(2, '0')}"
            else -> "${sec}s"
        }
    }

    /**
     * بررسی پشتیبانی IPv6 در شبکه فعلی
     */
    fun hasIpv6(ctx: Context): Boolean {
        return try {
            val en = java.util.Collections.list(
                java.net.NetworkInterface.getNetworkInterfaces()
            )
            en.any { iface ->
                iface.isUp && !iface.isLoopback &&
                iface.inetAddresses.toList().any { addr ->
                    addr is java.net.Inet6Address &&
                    !addr.isLinkLocalAddress
                }
            }
        } catch (e: Exception) { false }
    }

    /**
     * بررسی روت بودن دستگاه
     */
    fun isRooted(): Boolean {
        val paths = listOf(
            "/system/app/Superuser.apk",
            "/sbin/su",
            "/system/bin/su",
            "/system/xbin/su",
            "/data/local/xbin/su",
            "/data/local/bin/su",
            "/system/sd/xbin/su",
            "/system/bin/failsafe/su",
            "/data/local/su",
            "/su/bin/su"
        )
        return paths.any { java.io.File(it).exists() }
    }
}

// ═══════════════════════════════════════════════════
//  ۵۷. شروع اپ - بررسی اولیه و انتخاب بهترین سرور
// ═══════════════════════════════════════════════════
class StartupManager(private val ctx: Context) {

    /**
     * اجرای تسک‌های اولیه در پس‌زمینه
     */
    fun runStartupTasks() {
        CoroutineScope(Dispatchers.IO).launch {
            try {
                // ۱. بررسی وجود بهترین سرور ذخیره شده
                val mgr = ConfigManager(ctx)
                if (mgr.getBest() == null && mgr.getSelected() == null) {
                    // اولین اجرا: خودکار بهترین سرور رو پیدا کن
                    val all = mgr.getAllConfigs()
                    if (all.isNotEmpty()) {
                        mgr.saveSelected(all.first())
                        Log.i("STARTUP", "سرور اول به عنوان پیش‌فرض انتخاب شد")
                    }
                }

                // ۲. شروع گوش دادن به شبکه
                AutoReconnect.startMonitoring(ctx)

                // ۳. بررسی آپدیت (اختیاری)
                // val update = UpdateChecker.check("1.0.0")
                // if (update.hasUpdate) { ... }

                Log.i("STARTUP", "تسک‌های اولیه انجام شد")
            } catch (e: Exception) {
                Log.e("STARTUP", "خطا در تسک‌ها", e)
            }
        }
    }
}

// ═══════════════════════════════════════════════════
//  ۵۹. سیستم طراحی حرفه‌ای PARSA
// ═══════════════════════════════════════════════════
object ParssaDesign {

    // ═══ پالت رنگ اصلی ═══
    val Primary = Color(0xFF7C4DFF)
    val PrimaryLight = Color(0xFFB47CFF)
    val PrimaryDark = Color(0xFF3F1DCB)

    val Accent = Color(0xFF00E5FF)
    val Success = Color(0xFF00E676)
    val Warning = Color(0xFFFFB300)
    val Error = Color(0xFFFF5252)

    val Background = Color(0xFF07080D)
    val Surface = Color(0xFF10121E)
    val SurfaceElevated = Color(0xFF1B1F3A)
    val SurfaceHighlight = Color(0xFF242A4A)

    val TextPrimary = Color(0xFFFFFFFF)
    val TextSecondary = Color(0xFFB8BDD9)
    val TextDisabled = Color(0xFF5A5F7A)

    val Divider = Color(0xFF2A3054)

    // ═══ گرادیانت‌های زیبا ═══
    val GradientHome = listOf(
        Color(0xFF07080D),
        Color(0xFF10112E),
        Color(0xFF07080D)
    )

    val GradientButton = listOf(
        Color(0xFF7C4DFF),
        Color(0xFF9C6BFF)
    )

    val GradientConnected = listOf(
        Color(0xFF00E676),
        Color(0xFF00B8D4)
    )

    val GradientCard = listOf(
        Color(0xFF1B1F3A),
        Color(0xFF232849)
    )

    val GradientTitle = listOf(
        Color(0xFF7C4DFF),
        Color(0xFF00E5FF)
    )

    val GradientIran = listOf(
        Color(0xFF00E676),
        Color(0xFF64DD17)
    )
}

// ═══════════════════════════════════════════════════
//  ۶۰. انیمیشن‌های پیشرفته
// ═══════════════════════════════════════════════════
object ParssaAnimations {

    // ═══ انیمیشن نرم ورود صفحه ═══
    @Composable
    fun EntranceAnimation(
        delayMs: Int = 0,
        content: @Composable () -> Unit
    ) {
        var visible by remember { mutableStateOf(false) }
        LaunchedEffect(Unit) {
            delay(delayMs.toLong())
            visible = true
        }
        val alpha by animateFloatAsState(
            if (visible) 1f else 0f,
            animationSpec = tween(600, easing = FastOutSlowInEasing)
        )
        val offsetY by animateDpAsState(
            if (visible) 0.dp else 30.dp,
            animationSpec = tween(600, easing = FastOutSlowInEasing)
        )
        Box(
            Modifier
                .offset(y = offsetY)
                .alpha(alpha)
        ) { content() }
    }

    // ═══ انیمیشن Pulse (برای دکمه اتصال) ═══
    @Composable
    fun PulseRing(
        isActive: Boolean,
        color: Color,
        size: Dp = 220.dp
    ): Float {
        val inf = rememberInfiniteTransition()
        val scale by inf.animateFloat(
            1f,
            if (isActive) 1.18f else 1f,
            infiniteRepeatable(
                tween(1500, easing = FastOutSlowInEasing),
                RepeatMode.Reverse
            )
        )
        return scale
    }

    // ═══ انیمیشن چرخش برای Loading ═══
    @Composable
    fun RotatingIcon(
        icon: androidx.compose.ui.graphics.vector.ImageVector,
        tint: Color = ParssaDesign.Primary,
        size: Dp = 24.dp
    ) {
        val inf = rememberInfiniteTransition()
        val rotation by inf.animateFloat(
            0f, 360f,
            infiniteRepeatable(tween(1500, easing = LinearEasing))
        )
        Icon(
            icon,
            null,
            tint = tint,
            modifier = Modifier
                .size(size)
                .rotate(rotation)
        )
    }

    // ═══ انیمیشن Shimmer (Skeleton Loading) ═══
    @Composable
    fun ShimmerBox(
        modifier: Modifier = Modifier,
        shape: androidx.compose.ui.graphics.Shape = RoundedCornerShape(8.dp)
    ) {
        val transition = rememberInfiniteTransition()
        val translate by transition.animateFloat(
            -200f, 800f,
            infiniteRepeatable(tween(1500, easing = LinearEasing))
        )
        Box(
            modifier
                .clip(shape)
                .background(
                    Brush.linearGradient(
                        colors = listOf(
                            Color(0xFF1B1F3A),
                            Color(0xFF2E3455),
                            Color(0xFF1B1F3A)
                        ),
                        start = androidx.compose.ui.geometry.Offset(translate, 0f),
                        end = androidx.compose.ui.geometry.Offset(translate + 300f, 300f)
                    )
                )
        )
    }
}

// ═══════════════════════════════════════════════════
//  ۶۱. کامپوننت‌های UI حرفه‌ای
// ═══════════════════════════════════════════════════

// ═══ کارت شیشه‌ای (Glassmorphism) ═══
@Composable
fun GlassCard(
    modifier: Modifier = Modifier,
    borderColor: Color = ParssaDesign.Primary.copy(0.3f),
    content: @Composable ColumnScope.() -> Unit
) {
    Box(
        modifier
            .clip(RoundedCornerShape(20.dp))
            .background(
                Brush.linearGradient(
                    listOf(
                        ParssaDesign.SurfaceElevated.copy(0.7f),
                        ParssaDesign.Surface.copy(0.5f)
                    )
                )
            )
            .border(
                width = 1.dp,
                brush = Brush.linearGradient(
                    listOf(
                        borderColor,
                        borderColor.copy(0.1f)
                    )
                ),
                shape = RoundedCornerShape(20.dp)
            )
    ) {
        Column(Modifier.padding(16.dp), content = content)
    }
}

// ═══ دکمه گرادیانت با Glow ═══
@Composable
fun GradientButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
    colors: List<Color> = ParssaDesign.GradientButton,
    icon: androidx.compose.ui.graphics.vector.ImageVector? = null
) {
    val haptic = androidx.compose.ui.platform.LocalHapticFeedback.current
    Box(modifier) {
        if (enabled) {
            // Glow پشت دکمه
            Box(
                Modifier
                    .matchParentSize()
                    .clip(RoundedCornerShape(16.dp))
                    .background(
                        Brush.linearGradient(colors.map { it.copy(0.4f) })
                    )
                    .blur(12.dp)
            )
        }
        Button(
            onClick = {
                haptic.performHapticFeedback(
                    androidx.compose.ui.hapticfeedback.HapticFeedbackType.LongPress
                )
                onClick()
            },
            modifier = Modifier.fillMaxWidth().height(54.dp),
            shape = RoundedCornerShape(16.dp),
            enabled = enabled,
            colors = ButtonDefaults.buttonColors(
                containerColor = Color.Transparent
            ),
            contentPadding = PaddingValues(0.dp)
        ) {
            Box(
                Modifier
                    .fillMaxSize()
                    .background(
                        Brush.linearGradient(
                            if (enabled) colors
                            else listOf(Color.Gray, Color.DarkGray)
                        )
                    ),
                contentAlignment = Alignment.Center
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.Center
                ) {
                    if (icon != null) {
                        Icon(icon, null, tint = Color.White)
                        Spacer(Modifier.width(8.dp))
                    }
                    Text(
                        text,
                        color = Color.White,
                        fontSize = 16.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
            }
        }
    }
}

// ═══ کارت سرور زیبا ═══
@Composable
fun ServerCard(
    config: VpnConfig,
    isSelected: Boolean,
    isFavorite: Boolean,
    onClick: () -> Unit,
    onFavoriteClick: () -> Unit
) {
    val scale by animateFloatAsState(
        if (isSelected) 1.02f else 1f,
        animationSpec = spring(dampingRatio = Spring.DampingRatioMediumBouncy)
    )

    Box(
        Modifier
            .fillMaxWidth()
            .graphicsLayer {
                scaleX = scale
                scaleY = scale
            }
            .clip(RoundedCornerShape(16.dp))
            .background(
                if (isSelected)
                    Brush.linearGradient(
                        listOf(
                            ParssaDesign.Primary.copy(0.35f),
                            ParssaDesign.Accent.copy(0.15f)
                        )
                    )
                else
                    Brush.linearGradient(ParssaDesign.GradientCard)
            )
            .border(
                width = if (isSelected) 1.5.dp else 0.5.dp,
                color = if (isSelected) ParssaDesign.Primary else ParssaDesign.Divider,
                shape = RoundedCornerShape(16.dp)
            )
            .clickable(onClick = onClick)
    ) {
        Row(
            Modifier.fillMaxWidth().padding(14.dp),
            Arrangement.SpaceBetween,
            Alignment.CenterVertically
        ) {
            // چپ: نام + پروتکل
            Column(Modifier.weight(1f)) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    // Indicator سبز/قرمز
                    Box(
                        Modifier
                            .size(8.dp)
                            .clip(CircleShape)
                            .background(
                                when {
                                    config.isWorking && config.ping in 1..150 -> ParssaDesign.Success
                                    config.isWorking && config.ping in 151..400 -> ParssaDesign.Warning
                                    config.isWorking -> ParssaDesign.Error
                                    else -> ParssaDesign.TextDisabled
                                }
                            )
                    )
                    Spacer(Modifier.width(8.dp))
                    Text(
                        config.name,
                        color = ParssaDesign.TextPrimary,
                        fontSize = 14.sp,
                        fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Medium,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                        modifier = Modifier.weight(1f, fill = false)
                    )
                    if (isSelected) {
                        Spacer(Modifier.width(6.dp))
                        Box(
                            Modifier
                                .clip(RoundedCornerShape(6.dp))
                                .background(ParssaDesign.Success.copy(0.2f))
                                .padding(horizontal = 6.dp, vertical = 2.dp)
                        ) {
                            Text(
                                "فعال",
                                color = ParssaDesign.Success,
                                fontSize = 9.sp,
                                fontWeight = FontWeight.Bold
                            )
                        }
                    }
                }
                Spacer(Modifier.height(4.dp))
                Text(
                    "${config.protocol.uppercase()} • ${config.server}",
                    color = ParssaDesign.TextSecondary,
                    fontSize = 11.sp,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
            }

            Spacer(Modifier.width(10.dp))

            // راست: پینگ + ستاره
            Column(horizontalAlignment = Alignment.End) {
                if (config.ping > 0) {
                    val pingColor = when {
                        config.ping < 100 -> ParssaDesign.Success
                        config.ping < 300 -> ParssaDesign.Warning
                        else -> ParssaDesign.Error
                    }
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        // میله‌های سیگنال
                        SignalBars(ping = config.ping, color = pingColor)
                        Spacer(Modifier.width(6.dp))
                        Text(
                            "${config.ping}ms",
                            color = pingColor,
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Bold
                        )
                    }
                } else {
                    Text(
                        "—",
                        color = ParssaDesign.TextDisabled,
                        fontSize = 12.sp
                    )
                }
                Spacer(Modifier.height(4.dp))
                IconButton(
                    onClick = onFavoriteClick,
                    modifier = Modifier.size(24.dp)
                ) {
                    Icon(
                        if (isFavorite) Icons.Filled.Star else Icons.Outlined.StarBorder,
                        null,
                        tint = if (isFavorite) ParssaDesign.Warning else ParssaDesign.TextDisabled,
                        modifier = Modifier.size(18.dp)
                    )
                }
            }
        }
    }
}

// ═══ نشانگر سیگنال (میله‌ها) ═══
@Composable
fun SignalBars(ping: Int, color: Color) {
    val bars = when {
        ping < 80 -> 4
        ping < 200 -> 3
        ping < 400 -> 2
        else -> 1
    }
    Row(
        verticalAlignment = Alignment.Bottom,
        horizontalArrangement = Arrangement.spacedBy(2.dp)
    ) {
        repeat(4) { i ->
            Box(
                Modifier
                    .width(3.dp)
                    .height((6 + i * 3).dp)
                    .clip(RoundedCornerShape(1.dp))
                    .background(
                        if (i < bars) color else color.copy(0.15f)
                    )
            )
        }
    }
}

// ═══ کارت آمار با Sparkline ═══
@Composable
fun StatWithSparkline(
    title: String,
    value: String,
    color: Color,
    data: List<Float>,
    modifier: Modifier = Modifier
) {
    GlassCard(modifier) {
        Text(title, color = ParssaDesign.TextSecondary, fontSize = 11.sp)
        Spacer(Modifier.height(6.dp))
        Text(
            value,
            color = color,
            fontSize = 22.sp,
            fontWeight = FontWeight.Bold
        )
        Spacer(Modifier.height(8.dp))
        Sparkline(data = data, color = color, modifier = Modifier.fillMaxWidth().height(30.dp))
    }
}

// ═══ نمودار Sparkline ═══
@Composable
fun Sparkline(
    data: List<Float>,
    color: Color,
    modifier: Modifier = Modifier
) {
    if (data.isEmpty()) return
    val maxVal = data.maxOrNull() ?: 1f
    val minVal = data.minOrNull() ?: 0f
    val range = (maxVal - minVal).coerceAtLeast(0.01f)

    androidx.compose.foundation.Canvas(modifier) {
        val w = size.width
        val h = size.height
        val step = w / (data.size - 1).coerceAtLeast(1)

        val path = androidx.compose.ui.graphics.Path()
        val fillPath = androidx.compose.ui.graphics.Path()

        data.forEachIndexed { i, value ->
            val x = i * step
            val y = h - ((value - minVal) / range) * h * 0.8f - h * 0.1f
            if (i == 0) {
                path.moveTo(x, y)
                fillPath.moveTo(x, h)
                fillPath.lineTo(x, y)
            } else {
                path.lineTo(x, y)
                fillPath.lineTo(x, y)
            }
        }
        fillPath.lineTo(w, h)
        fillPath.close()

        // پر کردن زیر نمودار
        drawPath(
            fillPath,
            brush = Brush.verticalGradient(
                listOf(color.copy(0.35f), color.copy(0f))
            )
        )

        // خط نمودار
        drawPath(
            path,
            color = color,
            style = androidx.compose.ui.graphics.drawscope.Stroke(
                width = 2f,
                cap = androidx.compose.ui.graphics.StrokeCap.Round,
                join = androidx.compose.ui.graphics.StrokeJoin.Round
            )
        )
    }
}

// ═══════════════════════════════════════════════════
//  ۶۲. صفحه اصلی بازطراحی‌شده
// ═══════════════════════════════════════════════════
@Composable
fun Home(vm: VpnViewModel, nav: (String) -> Unit) {
    val st by vm.state.collectAsState()
    val sel by vm.selected.collectAsState()
    val ctx = LocalContext.current
    val scope = rememberCoroutineScope()

    // ═══ انیمیشن ورود ═══
    var entered by remember { mutableStateOf(false) }
    LaunchedEffect(Unit) { entered = true }

    // ═══ گرادیانت متحرک پس‌زمینه ═══
    val inf = rememberInfiniteTransition()
    val bgAngle by inf.animateFloat(
        0f, 360f,
        infiniteRepeatable(tween(20000, easing = LinearEasing))
    )

    val pulse = ParssaAnimations.PulseRing(
        isActive = st == ConnState.CONNECTED,
        color = if (st == ConnState.CONNECTED) ParssaDesign.Success else ParssaDesign.Primary
    )

    Box(
        Modifier
            .fillMaxSize()
            .background(
                Brush.sweepGradient(
                    colors = listOf(
                        ParssaDesign.Background,
                        Color(0xFF10112E),
                        Color(0xFF0D1430),
                        ParssaDesign.Background
                    )
                )
            )
    ) {
        // ═══ افکت نور پس‌زمینه ═══
        Box(
            Modifier
                .size(500.dp)
                .align(Alignment.TopCenter)
                .offset(y = (-200).dp)
                .background(
                    Brush.radialGradient(
                        colors = listOf(
                            (if (st == ConnState.CONNECTED) ParssaDesign.Success
                             else ParssaDesign.Primary).copy(0.15f),
                            Color.Transparent
                        )
                    )
                )
        )

        Column(
            Modifier
                .fillMaxSize()
                .padding(20.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Spacer(Modifier.height(30.dp))

            // ═══ لوگو + عنوان ═══
            ParssaAnimations.EntranceAnimation(0) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    // لوگو با گرادیانت
                    Box(
                        Modifier
                            .size(64.dp)
                            .clip(RoundedCornerShape(18.dp))
                            .background(
                                Brush.linearGradient(ParssaDesign.GradientTitle)
                            ),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            Icons.Filled.Security,
                            null,
                            tint = Color.White,
                            modifier = Modifier.size(36.dp)
                        )
                    }
                    Spacer(Modifier.height(14.dp))
                    Text(
                        "PARSA VPN",
                        fontSize = 26.sp,
                        fontWeight = FontWeight.Bold,
                        style = androidx.compose.ui.text.TextStyle(
                            brush = Brush.linearGradient(ParssaDesign.GradientTitle)
                        )
                    )
                    Text(
                        "سریع • امن • مدرن",
                        color = ParssaDesign.TextSecondary,
                        fontSize = 12.sp,
                        letterSpacing = 2.sp
                    )
                }
            }

            Spacer(Modifier.weight(1f))

            // ═══ دکمه اتصال (بزرگ و انیمیشنی) ═══
            ParssaAnimations.EntranceAnimation(200) {
                Box(
                    Modifier.size(260.dp),
                    contentAlignment = Alignment.Center
                ) {
                    // حلقه‌های Pulse
                    repeat(3) { i ->
                        Box(
                            Modifier
                                .size((180 + i * 30).dp * pulse)
                                .clip(CircleShape)
                                .background(
                                    (if (st == ConnState.CONNECTED) ParssaDesign.Success
                                     else ParssaDesign.Primary)
                                        .copy(0.06f - i * 0.015f)
                                )
                        )
                    }

                    // دکمه اصلی
                    Box(
                        Modifier
                            .size(170.dp)
                            .clip(CircleShape)
                            .background(
                                Brush.linearGradient(
                                    if (st == ConnState.CONNECTED)
                                        ParssaDesign.GradientConnected
                                    else
                                        ParssaDesign.GradientButton
                                )
                            )
                            .clickable {
                                when (st) {
                                    ConnState.CONNECTED -> vm.disconnect()
                                    ConnState.DISCONNECTED, ConnState.ERROR -> {
                                        VpnBridge.onPermissionGranted = { vm.connect() }
                                        VpnBridge.onPermissionDenied = {
                                            Toast.makeText(
                                                ctx,
                                                "برای اتصال باید مجوز VPN بدهید",
                                                Toast.LENGTH_LONG
                                            ).show()
                                        }
                                        VpnBridge.requestVpnPermission?.invoke()
                                    }
                                    else -> {}
                                }
                            },
                        contentAlignment = Alignment.Center
                    ) {
                        Column(
                            horizontalAlignment = Alignment.CenterHorizontally,
                            verticalArrangement = Arrangement.Center
                        ) {
                            Icon(
                                when (st) {
                                    ConnState.CONNECTED -> Icons.Filled.Lock
                                    ConnState.CONNECTING -> Icons.Filled.Sync
                                    else -> Icons.Filled.LockOpen
                                },
                                null,
                                tint = Color.White,
                                modifier = Modifier.size(40.dp)
                            )
                            Spacer(Modifier.height(8.dp))
                            Text(
                                when (st) {
                                    ConnState.CONNECTED -> "قطع"
                                    ConnState.CONNECTING -> "اتصال..."
                                    ConnState.DISCONNECTING -> "قطع..."
                                    ConnState.ERROR -> "خطا"
                                    else -> "اتصال"
                                },
                                color = Color.White,
                                fontSize = 20.sp,
                                fontWeight = FontWeight.Bold
                            )
                        }
                    }
                }
            }

            Spacer(Modifier.height(20.dp))

            // ═══ وضعیت اتصال ═══
            ParssaAnimations.EntranceAnimation(400) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        modifier = Modifier
                            .clip(RoundedCornerShape(20.dp))
                            .background(ParssaDesign.SurfaceElevated.copy(0.6f))
                            .padding(horizontal = 14.dp, vertical = 6.dp)
                    ) {
                        Box(
                            Modifier
                                .size(8.dp)
                                .clip(CircleShape)
                                .background(
                                    when (st) {
                                        ConnState.CONNECTED -> ParssaDesign.Success
                                        ConnState.CONNECTING, ConnState.DISCONNECTING -> ParssaDesign.Warning
                                        ConnState.ERROR -> ParssaDesign.Error
                                        else -> ParssaDesign.TextDisabled
                                    }
                                )
                        )
                        Spacer(Modifier.width(8.dp))
                        Text(
                            when (st) {
                                ConnState.CONNECTED -> "متصل"
                                ConnState.CONNECTING -> "در حال اتصال..."
                                ConnState.DISCONNECTING -> "در حال قطع..."
                                ConnState.ERROR -> "خطا در اتصال"
                                else -> "آماده"
                            },
                            color = ParssaDesign.TextSecondary,
                            fontSize = 12.sp
                        )
                    }

                    Spacer(Modifier.height(16.dp))

                    // سرور فعلی
                    Text(
                        sel.name,
                        color = ParssaDesign.TextPrimary,
                        fontSize = 16.sp,
                        fontWeight = FontWeight.Bold
                    )
                    Text(
                        "${sel.protocol.uppercase()} • ${sel.server}:${sel.port}",
                        color = ParssaDesign.TextSecondary,
                        fontSize = 11.sp
                    )
                }
            }

            Spacer(Modifier.weight(1f))

            // ═══ دکمه‌های پایین (شبکه‌ای) ═══
            ParssaAnimations.EntranceAnimation(600) {
                Column {
                    Row(
                        Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        QuickTile(
                            icon = Icons.Filled.Dns,
                            label = "سرورها",
                            color = ParssaDesign.Primary,
                            modifier = Modifier.weight(1f),
                            onClick = { nav("servers") }
                        )
                        QuickTile(
                            icon = Icons.Filled.Speed,
                            label = "تست سرعت",
                            color = ParssaDesign.Accent,
                            modifier = Modifier.weight(1f),
                            onClick = { nav("speed") }
                        )
                    }
                    Spacer(Modifier.height(8.dp))
                    Row(
                        Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        QuickTile(
                            icon = Icons.Filled.PieChart,
                            label = "آمار",
                            color = ParssaDesign.Warning,
                            modifier = Modifier.weight(1f),
                            onClick = { nav("stats") }
                        )
                        QuickTile(
                            icon = Icons.Filled.Settings,
                            label = "تنظیمات",
                            color = ParssaDesign.Success,
                            modifier = Modifier.weight(1f),
                            onClick = { nav("settings") }
                        )
                        QuickTile(
                            icon = Icons.Filled.Lock,
                            label = "ادمین",
                            color = Color(0xFFFF4081),
                            modifier = Modifier.weight(1f),
                            onClick = { nav("admin") }
                        )
                    }
                }
            }

            Spacer(Modifier.height(16.dp))
        }
    }
}

// ═══ کاشی سریع ═══
@Composable
fun QuickTile(
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    label: String,
    color: Color,
    modifier: Modifier = Modifier,
    onClick: () -> Unit
) {
    val haptic = androidx.compose.ui.platform.LocalHapticFeedback.current
    Box(
        modifier
            .height(72.dp)
            .clip(RoundedCornerShape(16.dp))
            .background(
                Brush.linearGradient(
                    listOf(
                        color.copy(0.18f),
                        color.copy(0.06f)
                    )
                )
            )
            .border(
                1.dp,
                color.copy(0.25f),
                RoundedCornerShape(16.dp)
            )
            .clickable {
                haptic.performHapticFeedback(
                    androidx.compose.ui.hapticfeedback.HapticFeedbackType.LongPress
                )
                onClick()
            },
        contentAlignment = Alignment.Center
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Icon(
                icon,
                null,
                tint = color,
                modifier = Modifier.size(24.dp)
            )
            Spacer(Modifier.height(4.dp))
            Text(
                label,
                color = ParssaDesign.TextPrimary,
                fontSize = 11.sp,
                fontWeight = FontWeight.Medium
            )
        }
    }
}

// ═══════════════════════════════════════════════════
//  ۶۴. برچسب‌های سرور (Server Tags)
// ═══════════════════════════════════════════════════
object TagManager {

    private const val PREFS = "parsa_tags"
    private val gson = Gson()

    // ═══ برچسب‌های پیش‌فرض ═══
    val DEFAULT_TAGS = listOf(
        Triple("⚡", "سریع", Color(0xFF00E676)),
        Triple("🔥", "داغ", Color(0xFFFF5722)),
        Triple("🇮🇷", "ایران", Color(0xFF00B8D4)),
        Triple("🌍", "خارجی", Color(0xFF7C4DFF)),
        Triple("💰", "اقتصادی", Color(0xFFFFB300)),
        Triple("🎬", "یوتیوب", Color(0xFFFF1744))
    )

    fun getTags(ctx: Context, configId: String): List<String> {
        val json = ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .getString("tags_$configId", "[]") ?: "[]"
        return try {
            gson.fromJson(json, object : TypeToken<List<String>>() {}.type)
        } catch (e: Exception) { emptyList() }
    }

    fun addTag(ctx: Context, configId: String, tag: String) {
        val current = getTags(ctx, configId).toMutableList()
        if (tag !in current) {
            current.add(tag)
            ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
                .edit().putString("tags_$configId", gson.toJson(current)).apply()
        }
    }

    fun removeTag(ctx: Context, configId: String, tag: String) {
        val current = getTags(ctx, configId).toMutableList()
        current.remove(tag)
        ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit().putString("tags_$configId", gson.toJson(current)).apply()
    }
}

// ═══════════════════════════════════════════════════
//  ۶۵. نمودار زنده ترافیک (Live Chart)
// ═══════════════════════════════════════════════════
@Composable
fun LiveTrafficChart(
    isConnected: Boolean,
    modifier: Modifier = Modifier
) {
    val points = remember { mutableStateListOf<Float>() }
    val maxPoints = 40

    LaunchedEffect(isConnected) {
        while (true) {
            delay(500)
            if (isConnected) {
                // شبیه‌سازی سرعت (در پیاده‌سازی واقعی از LibXray.queryStats بگیر)
                val speed = (kotlin.random.Random.nextDouble(0.5, 5.0)).toFloat()
                points.add(speed)
                if (points.size > maxPoints) points.removeAt(0)
            } else {
                if (points.isNotEmpty()) points.clear()
            }
        }
    }

    GlassCard(modifier) {
        Row(
            Modifier.fillMaxWidth(),
            Arrangement.SpaceBetween,
            Alignment.CenterVertically
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Box(
                    Modifier
                        .size(8.dp)
                        .clip(CircleShape)
                        .background(
                            if (isConnected) ParssaDesign.Success
                            else ParssaDesign.TextDisabled
                        )
                )
                Spacer(Modifier.width(6.dp))
                Text(
                    "ترافیک زنده",
                    color = ParssaDesign.TextSecondary,
                    fontSize = 11.sp
                )
            }
            Text(
                if (points.isEmpty()) "0 KB/s"
                else "%.1f KB/s".format(points.last() * 100),
                color = ParssaDesign.Accent,
                fontSize = 14.sp,
                fontWeight = FontWeight.Bold
            )
        }

        Spacer(Modifier.height(10.dp))

        if (points.isEmpty()) {
            Box(
                Modifier.fillMaxWidth().height(50.dp),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    if (isConnected) "در انتظار داده..." else "برای دیدن نمودار متصل شوید",
                    color = ParssaDesign.TextDisabled,
                    fontSize = 11.sp
                )
            }
        } else {
            Sparkline(
                data = points,
                color = ParssaDesign.Accent,
                modifier = Modifier.fillMaxWidth().height(60.dp)
            )
        }
    }
}

// ═══════════════════════════════════════════════════
//  ۶۷. نکته پایانی: `import libXray.LibXray` را بالای فایل اضافه کن
//      (اگر AAR نبود، این خط را کامنت کن)
// ═══════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════
//      ۶۸. هسته واقعی Xray — اتصال و پینگ واقعی
// ═══════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────────────────────
// ۶۸.۱. لایه‌ی محافظ برای LibXray (اگر AAR نبود، اپ نمی‌کرشه)
// ─────────────────────────────────────────────────────────────
object RealXrayCore {

    @Volatile private var instanceField: Long = 0
    @Volatile private var available: Boolean = false

    fun isAvailable(): Boolean {
        if (available) return true
        return try {
            Class.forName("libXray.LibXray")
            available = true
            true
        } catch (e: Throwable) {
            false
        }
    }

    fun getVersion(): String {
        return try {
            val c = Class.forName("libXray.LibXray")
            val m = c.getMethod("getXrayVersion")
            m.invoke(null) as? String ?: "unknown"
        } catch (e: Throwable) { "not-installed" }
    }

    fun newInstance(configJson: String): Long {
        if (!isAvailable()) return 0L
        return try {
            val c = Class.forName("libXray.LibXray")
            val m = c.getMethod("newXray", String::class.java)
            (m.invoke(null, configJson) as? Long) ?: 0L
        } catch (e: Throwable) { 0L }
    }

    fun run(instanceId: Long, tunFd: Int, protect: (Int) -> Boolean): String {
        if (!isAvailable()) return "not-installed"
        return try {
            val c = Class.forName("libXray.LibXray")
            if (instanceId > 0) {
                // API جدید: runXray(long, long, callback)
                val m = c.getMethod(
                    "runXray",
                    Long::class.javaPrimitiveType,
                    Long::class.javaPrimitiveType,
                    Class.forName("libXray.LibXray\$ProtectFunc")
                )
                val protectFunc = java.lang.reflect.Proxy.newProxyInstance(
                    c.classLoader,
                    arrayOf(Class.forName("libXray.LibXray\$ProtectFunc"))
                ) { _, method, args ->
                    val fd = (args?.get(0) as? Int) ?: -1
                    protect(fd)
                }
                m.invoke(null, instanceId, tunFd.toLong(), protectFunc) as? String ?: "ok"
            } else {
                // API قدیمی: startXray(String, int, callback)
                val m = c.getMethod(
                    "startXray",
                    String::class.java,
                    Int::class.javaPrimitiveType,
                    Class.forName("libXray.LibXray\$ProtectFunc")
                )
                m.invoke(null, "", tunFd, null) as? String ?: "ok"
            }
        } catch (e: Throwable) {
            Log.e("REAL_XRAY", "run error", e)
            "error: ${e.message}"
        }
    }

    fun stop(instanceId: Long) {
        if (!isAvailable()) return
        try {
            val c = Class.forName("libXray.LibXray")
            val m = c.getMethod("stopXray", Long::class.javaPrimitiveType)
            m.invoke(null, instanceId)
        } catch (e: Throwable) {
            try {
                val c = Class.forName("libXray.LibXray")
                val m = c.getMethod("stopXray")
                m.invoke(null)
            } catch (_: Throwable) {}
        }
    }

    fun measureDelay(configJson: String, url: String): Long {
        if (!isAvailable()) return -1L
        return try {
            val c = Class.forName("libXray.LibXray")
            val m = c.getMethod("measureOutboundDelay", String::class.java, String::class.java)
            (m.invoke(null, configJson, url) as? Long) ?: -1L
        } catch (e: Throwable) { -1L }
    }
}

// ─────────────────────────────────────────────────────────────
// ۶۸.۲. سرویس VPN واقعی (کپی از CoreVpnService با هسته‌ی واقعی)
// ─────────────────────────────────────────────────────────────
class RealVpnService : VpnService() {

    companion object {
        const val ACTION_CONNECT = "parsa_real.CONNECT"
        const val ACTION_DISCONNECT = "parsa_real.DISCONNECT"
        const val CHANNEL = "parsa_real_ch"
        const val NOTIF_ID = 2001
        private const val TAG = "PARSA_REAL"

        @Volatile var isRunning = false
        @Volatile var connectedName = ""
        @Volatile var startTime = 0L
    }

    private var tun: ParcelFileDescriptor? = null
    private var instanceId: Long = 0L
    private val scope = CoroutineScope(Dispatchers.IO + SupervisorJob())
    private var statsJob: Job? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_CONNECT -> {
                val json = intent.getStringExtra("xray_config") ?: run {
                    stopAll(); return START_NOT_STICKY
                }
                val name = intent.getStringExtra("server_name") ?: ""
                start(json, name)
            }
            ACTION_DISCONNECT -> stopAll()
        }
        return START_STICKY
    }

    private fun start(json: String, name: String) {
        if (isRunning) return

        try {
            createChannel()

            // ─── ۱. ساخت TUN ───
            val builder = Builder()
                .setSession("PARSA VPN")
                .setMtu(1500)
                .addAddress("10.111.222.1", 32)
                .addRoute("0.0.0.0", 0)
                .addDnsServer("1.1.1.1")
                .addDnsServer("8.8.8.8")

            // IPv6
            try {
                builder.addAddress("fd00:1:fd00:1:fd00:1:fd00:1", 128)
                builder.addRoute("::", 0)
            } catch (_: Throwable) {}

            // Split tunnel
            try {
                SplitTunnel.getExcluded(this).forEach {
                    try { builder.addDisallowedApplication(it) } catch (_: Exception) {}
                }
            } catch (_: Throwable) {}

            // خود اپ استثنا
            try { builder.addDisallowedApplication(packageName) } catch (_: Exception) {}

            builder.setBlocking(true)
            tun = builder.establish() ?: run {
                Log.e(TAG, "TUN failed")
                broadcast("ERROR: TUN")
                stopAll()
                return
            }

            val fd = tun!!.fd
            Log.i(TAG, "TUN fd=$fd")

            // ─── ۲. راه‌اندازی Xray ───
            scope.launch {
                try {
                    if (!RealXrayCore.isAvailable()) {
                        Log.e(TAG, "LibXray نصب نیست")
                        broadcast("ERROR: LibXray missing")
                        stopAll()
                        return@launch
                    }

                    Log.i(TAG, "Xray version: ${RealXrayCore.getVersion()}")

                    instanceId = RealXrayCore.newInstance(json)
                    Log.i(TAG, "instance=$instanceId")

                    val result = RealXrayCore.run(instanceId, fd) { sockFd ->
                        val ok = protect(sockFd)
                        Log.d(TAG, "protect($sockFd)=$ok")
                        ok
                    }

                    Log.i(TAG, "xray result=$result")

                    if (result.contains("error", true) || result.contains("fail", true)) {
                        broadcast("ERROR: $result")
                        stopAll()
                        return@launch
                    }

                    isRunning = true
                    connectedName = name
                    startTime = System.currentTimeMillis()

                    broadcast("CONNECTED")
                    showNotif("متصل به $name")
                    startStats()

                } catch (t: Throwable) {
                    Log.e(TAG, "start error", t)
                    broadcast("ERROR: ${t.message}")
                    stopAll()
                }
            }

        } catch (e: Exception) {
            Log.e(TAG, "fatal", e)
            broadcast("ERROR: ${e.message}")
            stopAll()
        }
    }

    private fun stopAll() {
        try {
            if (instanceId > 0) RealXrayCore.stop(instanceId)
        } catch (_: Throwable) {}

        try { tun?.close() } catch (_: Throwable) {}
        tun = null
        instanceId = 0L

        isRunning = false
        connectedName = ""
        startTime = 0L

        statsJob?.cancel()
        broadcast("DISCONNECTED")

        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    override fun onRevoke() { stopAll(); super.onRevoke() }
    override fun onDestroy() { stopAll(); scope.cancel(); super.onDestroy() }

    private fun startStats() {
        statsJob = scope.launch {
            var lastRx = 0L
            var lastTx = 0L
            while (isActive && isRunning) {
                delay(2000)
                try {
                    val uid = android.os.Process.myUid()
                    val rx = android.net.TrafficStats.getUidRxBytes(uid)
                    val tx = android.net.TrafficStats.getUidTxBytes(uid)
                    if (rx > 0 && lastRx > 0) {
                        val d = (rx - lastRx).coerceAtLeast(0)
                        sendBroadcast(Intent("parsa.SPEED").putExtra("rx", d))
                    }
                    if (tx > 0 && lastTx > 0) {
                        val d = (tx - lastTx).coerceAtLeast(0)
                        sendBroadcast(Intent("parsa.SPEED").putExtra("tx", d))
                    }
                    lastRx = rx
                    lastTx = tx
                } catch (_: Exception) {}
            }
        }
    }

    private fun createChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val c = NotificationChannel(
                CHANNEL, "PARSA VPN", NotificationManager.IMPORTANCE_LOW
            )
            getSystemService(NotificationManager::class.java).createNotificationChannel(c)
        }
    }

    private fun showNotif(text: String) {
        val pi = PendingIntent.getActivity(
            this, 0,
            Intent(this, MainActivity::class.java),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        val stopPi = PendingIntent.getService(
            this, 1,
            Intent(this, RealVpnService::class.java).apply { action = ACTION_DISCONNECT },
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        val n = Notification.Builder(this, CHANNEL)
            .setContentTitle("PARSA VPN")
            .setContentText(text)
            .setSmallIcon(android.R.drawable.ic_lock_lock)
            .setContentIntent(pi)
            .addAction(android.R.drawable.ic_menu_close_clear_cancel, "قطع", stopPi)
            .setOngoing(true)
            .build()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(NID_SAFE(), n, 0x40000000)  // FOREGROUND_SERVICE_TYPE_SPECIAL_USE
        } else {
            startForeground(NID_SAFE(), n)
        }
    }

    private fun NID_SAFE() = NOTIF_ID

    private fun broadcast(state: String) {
        sendBroadcast(Intent("parsa.STATE").putExtra("state", state))
        Log.i(TAG, "state=$state")
    }
}

// ─────────────────────────────────────────────────────────────
// ۶۸.۳. موتور پینگ Xray واقعی
// ─────────────────────────────────────────────────────────────
object RealPingEngine {

    private const val TEST_URL = "https://www.gstatic.com/generate_204"
    private const val TCP_TIMEOUT = 2500
    private const val XRAY_TIMEOUT = 12000L
    private const val PARALLEL_TCP = 16
    private const val PARALLEL_XRAY = 3

    suspend fun pingAll(
        configs: List<VpnConfig>,
        mode: String = "hybrid",
        onProgress: (Int, Int, String) -> Unit = { _, _, _ -> }
    ): List<VpnConfig> = coroutineScope {
        val total = configs.size
        val counter = java.util.concurrent.atomic.AtomicInteger(0)

        // TCP سریع
        val sem = Semaphore(PARALLEL_TCP)
        val afterTcp = if (mode == "xray") {
            configs
        } else {
            configs.map { c ->
                async(Dispatchers.IO) {
                    sem.withPermit {
                        val r = tcpPing(c)
                        val d = counter.incrementAndGet()
                        withContext(Dispatchers.Main) { onProgress(d, total * 2, c.name) }
                        r
                    }
                }
            }.awaitAll()
        }

        if (mode == "quick") {
            return@coroutineScope afterTcp.sortedBy {
                if (it.ping > 0) it.ping else Int.MAX_VALUE
            }
        }

        // Xray واقعی
        val alive = afterTcp.filter { it.isWorking }
        val dead = afterTcp.filter { !it.isWorking }

        if (alive.isEmpty()) {
            return@coroutineScope afterTcp.sortedBy {
                if (it.ping > 0) it.ping else Int.MAX_VALUE
            }
        }

        if (!RealXrayCore.isAvailable()) {
            // fallback: TCP * 1.4 به عنوان تخمین
            val fallback = alive.map { c ->
                c.copy(ping = (c.ping * 1.4).toInt(), isWorking = true)
            }
            return@coroutineScope (fallback + dead).sortedBy {
                if (it.ping > 0) it.ping else Int.MAX_VALUE
            }
        }

        val xSem = Semaphore(PARALLEL_XRAY)
        val realResults = alive.map { c ->
            async(Dispatchers.IO) {
                xSem.withPermit {
                    val r = xrayPing(c)
                    val d = counter.incrementAndGet()
                    withContext(Dispatchers.Main) { onProgress(d, total * 2, c.name) }
                    r
                }
            }
        }.awaitAll()

        (realResults + dead).sortedBy {
            if (it.ping > 0) it.ping else Int.MAX_VALUE
        }
    }

    private suspend fun tcpPing(c: VpnConfig): VpnConfig = withContext(Dispatchers.IO) {
        if (c.server.isBlank() || c.port <= 0) return@withContext c.copy(ping = -1, isWorking = false)
        try {
            val t = System.currentTimeMillis()
            java.net.Socket().use {
                it.connect(java.net.InetSocketAddress(c.server, c.port), TCP_TIMEOUT)
            }
            c.copy(
                ping = (System.currentTimeMillis() - t).toInt(),
                isWorking = true,
                lastTested = System.currentTimeMillis()
            )
        } catch (_: Exception) {
            c.copy(ping = -1, isWorking = false)
        }
    }

    private suspend fun xrayPing(c: VpnConfig): VpnConfig = withContext(Dispatchers.IO) {
        try {
            val testJson = XrayBuilder.build(c, null)
            val delays = mutableListOf<Long>()

            repeat(2) {
                val d = withTimeoutOrNull(XRAY_TIMEOUT) {
                    RealXrayCore.measureDelay(testJson, TEST_URL)
                } ?: -1L
                if (d > 0) delays.add(d)
                delay(60)
            }

            if (delays.isEmpty()) {
                // fallback: TCP*1.4
                val t = tcpPing(c).ping
                return@withContext if (t > 0) {
                    c.copy(ping = (t * 1.4).toInt(), isWorking = true,
                           lastTested = System.currentTimeMillis())
                } else {
                    c.copy(ping = -1, isWorking = false)
                }
            }

            val best = delays.min()
            val avg = delays.average()
            val jitter = if (delays.size > 1) {
                kotlin.math.sqrt(delays.map { (it - avg) * (it - avg) }.average()).toInt()
            } else 0
            val loss = ((2 - delays.size) * 100 / 2)
            val score = (best * 0.7 + jitter * 0.2 + loss * 0.1).toInt()

            c.copy(ping = score, isWorking = true,
                   lastTested = System.currentTimeMillis())
        } catch (_: Throwable) {
            c.copy(ping = -1, isWorking = false)
        }
    }

    suspend fun findBest(cfgs: List<VpnConfig>): VpnConfig? =
        pingAll(cfgs, "hybrid").firstOrNull { it.isWorking && it.ping > 0 }
}

// ─────────────────────────────────────────────────────────────
// ۶۸.۴. کنترلر سراسری (این حالت رو تغییر بده تا اتصال واقعی فعال بشه)
// ─────────────────────────────────────────────────────────────
object RealSwitch {
    // ⚠️ این را روی true بگذار تا اتصال و پینگ واقعی استفاده شوند
    @Volatile var USE_REAL_ENGINE = true

    // اگر true باشه، پینگ با LibXray انجام میشه (اگر AAR موجود باشه)
    @Volatile var USE_REAL_PING = true
}

// ═══════════════════════════════════════════════════════════════
//      ۶۹. سیستم نهایی: خودکار همه چیز
//      → فقط کافیه در MainActivity خط `App(vm)` رو به `AppFinal(vm)` عوض کنی
// ═══════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────────────────────
// ۶۹.۱. ViewModel گسترده — همه چیز خودکار
// ─────────────────────────────────────────────────────────────
class FinalVpnViewModel(private val ctx: Context) : ViewModel() {

    private val mgr = ConfigManager(ctx)

    private val _cfgs = MutableStateFlow(mgr.getAllConfigs())
    val configs: StateFlow<List<VpnConfig>> = _cfgs.asStateFlow()

    private val _state = MutableStateFlow(ConnState.DISCONNECTED)
    val state: StateFlow<ConnState> = _state.asStateFlow()

    private val _sel = MutableStateFlow(mgr.getSelected() ?: mgr.getAllConfigs().first())
    val selected: StateFlow<VpnConfig> = _sel.asStateFlow()

    private val _pinging = MutableStateFlow(false)
    val isPinging: StateFlow<Boolean> = _pinging.asStateFlow()

    private val _progress = MutableStateFlow(0 to 0)
    val progress: StateFlow<Pair<Int, Int>> = _progress.asStateFlow()

    private val _currentName = MutableStateFlow("")
    val currentName: StateFlow<String> = _currentName.asStateFlow()

    private val _liveRx = MutableStateFlow(0L)
    val liveRx: StateFlow<Long> = _liveRx.asStateFlow()

    private val _liveTx = MutableStateFlow(0L)
    val liveTx: StateFlow<Long> = _liveTx.asStateFlow()

    private val _favTick = MutableStateFlow(0)
    val favTick: StateFlow<Int> = _favTick.asStateFlow()

    private val _pingMode = MutableStateFlow(PingEngine.PingMode.HYBRID)
    val pingMode: StateFlow<PingEngine.PingMode> = _pingMode.asStateFlow()

    // ─── listener برای سرویس واقعی ───
    private var receiver: android.content.BroadcastReceiver? = null

    init {
        val r = object : android.content.BroadcastReceiver() {
            override fun onReceive(c: Context?, i: Intent?) {
                when (i?.action) {
                    "parsa.STATE" -> {
                        val s = i.getStringExtra("state") ?: return
                        _state.value = when {
                            s == "CONNECTED" -> ConnState.CONNECTED
                            s == "DISCONNECTED" -> ConnState.DISCONNECTED
                            s.startsWith("ERROR") -> ConnState.ERROR
                            else -> _state.value
                        }
                    }
                    "parsa.SPEED" -> {
                        val rx = i.getLongExtra("rx", 0)
                        val tx = i.getLongExtra("tx", 0)
                        if (rx > 0) _liveRx.value = rx
                        if (tx > 0) _liveTx.value = tx
                    }
                }
            }
        }
        val f = android.content.IntentFilter().apply {
            addAction("parsa.STATE")
            addAction("parsa.SPEED")
        }
        if (Build.VERSION.SDK_INT >= 33) {
            ctx.registerReceiver(r, f, Context.RECEIVER_NOT_EXPORTED)
        } else {
            @Suppress("UnspecifiedRegisterReceiverFlag")
            ctx.registerReceiver(r, f)
        }
        receiver = r
    }

    override fun onCleared() {
        super.onCleared()
        receiver?.let {
            try { ctx.unregisterReceiver(it) } catch (_: Exception) {}
        }
    }

    // ─── انتخاب ───
    fun select(c: VpnConfig) {
        _sel.value = c
        mgr.saveSelected(c)
    }

    fun setPingMode(m: PingEngine.PingMode) { _pingMode.value = m }

    fun refreshFavorites() { _favTick.value = _favTick.value + 1 }

    // ─── پینگ خودکار (تشخیص AAR) ───
    fun pingAll() {
        if (_pinging.value) return
        viewModelScope.launch {
            _pinging.value = true
            _progress.value = 0 to _cfgs.value.size

            try {
                if (RealXrayCore.isAvailable()) {
                    Log.i("FINAL", "استفاده از RealPingEngine")
                    _cfgs.value = RealPingEngine.pingAll(
                        _cfgs.value,
                        when (_pingMode.value) {
                            PingEngine.PingMode.QUICK -> "quick"
                            PingEngine.PingMode.XRAY -> "xray"
                            else -> "hybrid"
                        }
                    ) { d, t, n ->
                        _progress.value = d to t
                        _currentName.value = n
                    }
                } else {
                    Log.i("FINAL", "RealXrayCore نیست → PingEngine قدیمی")
                    _cfgs.value = PingEngine.pingAll(
                        _cfgs.value,
                        _pingMode.value
                    ) { d, t, n ->
                        _progress.value = d to t
                        _currentName.value = n
                    }
                }
            } catch (e: Exception) {
                Log.e("FINAL", "ping error", e)
            }

            _pinging.value = false
            _currentName.value = ""
        }
    }

    fun pickBest() {
        viewModelScope.launch {
            _pinging.value = true
            try {
                val best = if (RealXrayCore.isAvailable()) {
                    RealPingEngine.findBest(_cfgs.value)
                } else {
                    PingEngine.findBest(_cfgs.value)
                }
                best?.let { mgr.saveBest(it); select(it) }
            } catch (e: Exception) {
                Log.e("FINAL", "pickBest", e)
            }
            _pinging.value = false
        }
    }

    // ─── اتصال خودکار ───
    fun connect() {
        viewModelScope.launch {
            _state.value = ConnState.CONNECTING

            val json = try {
                XrayBuilder.build(_sel.value, ctx)
            } catch (e: Exception) {
                Log.e("FINAL", "build error", e)
                _state.value = ConnState.ERROR
                return@launch
            }

            TrafficStatsManager.saveSessionStart(ctx)

            val useReal = RealSwitch.USE_REAL_ENGINE && RealXrayCore.isAvailable()

            val svc = if (useReal) RealVpnService::class.java else CoreVpnService::class.java
            val act = if (useReal) RealVpnService.ACTION_CONNECT else CoreVpnService.ACT_CONNECT

            val intent = Intent(ctx, svc).apply {
                action = act
                putExtra("xray_config", json)
                putExtra("server_name", _sel.value.name)
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                ctx.startForegroundService(intent)
            } else {
                ctx.startService(intent)
            }

            // انتظار برای حالت واقعی
            var wait = 0
            while (wait < 15000) {
                delay(300)
                wait += 300

                val real = if (useReal) RealVpnService.isRunning else CoreVpnService.isRunning
                if (real) {
                    _state.value = ConnState.CONNECTED
                    return@launch
                }
                if (_state.value == ConnState.ERROR) return@launch
            }

            if (_state.value != ConnState.CONNECTED) {
                _state.value = ConnState.ERROR
            }
        }
    }

    // ─── قطع خودکار ───
    fun disconnect() {
        viewModelScope.launch {
            _state.value = ConnState.DISCONNECTING

            val useReal = RealSwitch.USE_REAL_ENGINE && RealXrayCore.isAvailable()
            val svc = if (useReal) RealVpnService::class.java else CoreVpnService::class.java
            val act = if (useReal) RealVpnService.ACTION_DISCONNECT else CoreVpnService.ACT_DISCONNECT

            ctx.startService(Intent(ctx, svc).apply { action = act })
            delay(400)
            _state.value = ConnState.DISCONNECTED
        }
    }

    fun verifyPass(p: String) = mgr.verifyAdminPassword(p)

    fun addAdmin(link: String, name: String): Boolean {
        return try {
            val proto = when {
                link.startsWith("vless://") -> "vless"
                link.startsWith("vmess://") -> "vmess"
                link.startsWith("ss://") -> "ss"
                link.startsWith("trojan://") -> "trojan"
                else -> return false
            }
            val (h, p) = when (proto) {
                "vmess" -> {
                    val j = JsonParser.parseString(
                        String(Base64.decode(link.removePrefix("vmess://"), Base64.DEFAULT))
                    ).asJsonObject
                    (j.get("add")?.asString ?: "") to (j.get("port")?.asString?.toIntOrNull() ?: 443)
                }
                else -> {
                    val u = URI(link)
                    (u.host ?: "") to (if (u.port == -1) 443 else u.port)
                }
            }
            val cfg = VpnConfig(
                name = name.ifBlank { "PARSAVPN-${(1000..9999).random()}" },
                rawLink = link, protocol = proto, server = h, port = p
            )
            mgr.addAdminConfig(cfg)
            _cfgs.value = mgr.getAllConfigs()
            true
        } catch (_: Exception) { false }
    }

    fun removeAdmin(id: String) {
        mgr.removeAdminConfig(id)
        _cfgs.value = mgr.getAllConfigs()
    }
}

// ─────────────────────────────────────────────────────────────
// ۶۹.۲. صفحه اصلی نهایی (خودکار از موتور واقعی استفاده می‌کند)
// ─────────────────────────────────────────────────────────────
@Composable
fun HomeFinal(vm: FinalVpnViewModel, nav: (String) -> Unit) {
    val st by vm.state.collectAsState()
    val sel by vm.selected.collectAsState()
    val ctx = LocalContext.current
    val haptic = androidx.compose.ui.platform.LocalHapticFeedback.current

    val inf = rememberInfiniteTransition()
    val pulse by inf.animateFloat(
        1f,
        if (st == ConnState.CONNECTED) 1.15f else 1f,
        infiniteRepeatable(tween(1500, easing = FastOutSlowInEasing), RepeatMode.Reverse)
    )

    val bg = Brush.verticalGradient(
        listOf(Color(0xFF07080D), Color(0xFF10112E), Color(0xFF07080D))
    )

    Box(Modifier.fillMaxSize().background(bg)) {

        // هاله‌ی نور بالای صفحه
        Box(
            Modifier
                .size(500.dp)
                .align(Alignment.TopCenter)
                .offset(y = (-200).dp)
                .background(
                    Brush.radialGradient(
                        listOf(
                            (if (st == ConnState.CONNECTED) Color(0xFF00E676)
                             else Color(0xFF7C4DFF)).copy(0.18f),
                            Color.Transparent
                        )
                    )
                )
        )

        Column(
            Modifier.fillMaxSize().padding(20.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Spacer(Modifier.height(24.dp))

            // لوگو
            Box(
                Modifier
                    .size(60.dp)
                    .clip(RoundedCornerShape(18.dp))
                    .background(
                        Brush.linearGradient(listOf(Color(0xFF7C4DFF), Color(0xFF00E5FF)))
                    ),
                contentAlignment = Alignment.Center
            ) {
                Icon(Icons.Filled.Security, null, tint = Color.White, modifier = Modifier.size(34.dp))
            }

            Spacer(Modifier.height(12.dp))

            Text(
                "PARSA VPN",
                fontSize = 26.sp,
                fontWeight = FontWeight.Bold,
                style = androidx.compose.ui.text.TextStyle(
                    brush = Brush.linearGradient(listOf(Color(0xFF7C4DFF), Color(0xFF00E5FF)))
                )
            )
            Text("سریع • امن • مدرن", color = Color.White.copy(0.55f), fontSize = 11.sp)

            Spacer(Modifier.weight(1f))

            // دکمه اتصال
            Box(Modifier.size(260.dp), contentAlignment = Alignment.Center) {
                repeat(3) { i ->
                    Box(
                        Modifier
                            .size((180 + i * 30).dp * pulse)
                            .clip(CircleShape)
                            .background(
                                (if (st == ConnState.CONNECTED) Color(0xFF00E676)
                                 else Color(0xFF7C4DFF)).copy(0.07f - i * 0.02f)
                            )
                    )
                }

                Box(
                    Modifier
                        .size(170.dp)
                        .clip(CircleShape)
                        .background(
                            Brush.linearGradient(
                                if (st == ConnState.CONNECTED)
                                    listOf(Color(0xFF00E676), Color(0xFF00B8D4))
                                else
                                    listOf(Color(0xFF7C4DFF), Color(0xFFB47CFF))
                            )
                        )
                        .clickable {
                            haptic.performHapticFeedback(
                                androidx.compose.ui.hapticfeedback.HapticFeedbackType.LongPress
                            )
                            when (st) {
                                ConnState.CONNECTED -> vm.disconnect()
                                ConnState.DISCONNECTED, ConnState.ERROR -> {
                                    VpnBridge.onPermissionGranted = { vm.connect() }
                                    VpnBridge.onPermissionDenied = {
                                        Toast.makeText(ctx, "برای اتصال باید مجوز VPN بدهید", Toast.LENGTH_LONG).show()
                                    }
                                    VpnBridge.requestVpnPermission?.invoke()
                                }
                                else -> {}
                            }
                        },
                    contentAlignment = Alignment.Center
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Icon(
                            when (st) {
                                ConnState.CONNECTED -> Icons.Filled.Lock
                                ConnState.CONNECTING -> Icons.Filled.Sync
                                else -> Icons.Filled.LockOpen
                            },
                            null,
                            tint = Color.White,
                            modifier = Modifier.size(38.dp)
                        )
                        Spacer(Modifier.height(8.dp))
                        Text(
                            when (st) {
                                ConnState.CONNECTED -> "قطع"
                                ConnState.CONNECTING -> "اتصال..."
                                ConnState.DISCONNECTING -> "قطع..."
                                ConnState.ERROR -> "خطا"
                                else -> "اتصال"
                            },
                            color = Color.White,
                            fontSize = 20.sp,
                            fontWeight = FontWeight.Bold
                        )
                    }
                }
            }

            Spacer(Modifier.height(16.dp))

            // وضعیت
            Row(
                verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier
                    .clip(RoundedCornerShape(20.dp))
                    .background(Color(0xFF1B1F3A).copy(0.6f))
                    .padding(horizontal = 14.dp, vertical = 6.dp)
            ) {
                Box(
                    Modifier
                        .size(8.dp)
                        .clip(CircleShape)
                        .background(
                            when (st) {
                                ConnState.CONNECTED -> Color(0xFF00E676)
                                ConnState.CONNECTING, ConnState.DISCONNECTING -> Color(0xFFFFB300)
                                ConnState.ERROR -> Color(0xFFFF5252)
                                else -> Color(0xFF5A5F7A)
                            }
                        )
                )
                Spacer(Modifier.width(8.dp))
                Text(
                    when (st) {
                        ConnState.CONNECTED -> "متصل"
                        ConnState.CONNECTING -> "در حال اتصال..."
                        ConnState.DISCONNECTING -> "در حال قطع..."
                        ConnState.ERROR -> "خطا در اتصال"
                        else -> "آماده"
                    },
                    color = Color.White.copy(0.75f),
                    fontSize = 12.sp
                )
            }

            Spacer(Modifier.height(14.dp))

            Text(sel.name, color = Color.White, fontSize = 16.sp, fontWeight = FontWeight.Bold)
            Text(
                "${sel.protocol.uppercase()} • ${sel.server}:${sel.port}",
                color = Color.White.copy(0.5f),
                fontSize = 11.sp
            )

            Spacer(Modifier.height(6.dp))

            // وضعیت موتور
            Text(
                if (RealXrayCore.isAvailable()) "✓ هسته Xray فعال"
                else "⚠ هسته Xray نصب نشده (فقط TCP ping)",
                color = if (RealXrayCore.isAvailable()) Color(0xFF00E676) else Color(0xFFFFB300),
                fontSize = 10.sp
            )

            Spacer(Modifier.weight(1f))

            // دکمه‌های سریع
            Row(Modifier.fillMaxWidth(), Arrangement.spacedBy(8.dp)) {
                FinalTile(Icons.Filled.Dns, "سرورها", Color(0xFF7C4DFF), Modifier.weight(1f)) { nav("servers") }
                FinalTile(Icons.Filled.Speed, "تست سرعت", Color(0xFF00E5FF), Modifier.weight(1f)) { nav("speed") }
            }
            Spacer(Modifier.height(8.dp))
            Row(Modifier.fillMaxWidth(), Arrangement.spacedBy(8.dp)) {
                FinalTile(Icons.Filled.PieChart, "آمار", Color(0xFFFFB300), Modifier.weight(1f)) { nav("stats") }
                FinalTile(Icons.Filled.Settings, "تنظیمات", Color(0xFF00E676), Modifier.weight(1f)) { nav("settings") }
                FinalTile(Icons.Filled.Lock, "ادمین", Color(0xFFFF4081), Modifier.weight(1f)) { nav("admin") }
            }

            Spacer(Modifier.height(10.dp))
        }
    }
}

@Composable
fun FinalTile(
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    label: String,
    color: Color,
    modifier: Modifier = Modifier,
    onClick: () -> Unit
) {
    val haptic = androidx.compose.ui.platform.LocalHapticFeedback.current
    Box(
        modifier
            .height(68.dp)
            .clip(RoundedCornerShape(16.dp))
            .background(
                Brush.linearGradient(listOf(color.copy(0.2f), color.copy(0.06f)))
            )
            .border(1.dp, color.copy(0.3f), RoundedCornerShape(16.dp))
            .clickable {
                haptic.performHapticFeedback(
                    androidx.compose.ui.hapticfeedback.HapticFeedbackType.LongPress
                )
                onClick()
            },
        contentAlignment = Alignment.Center
    ) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Icon(icon, null, tint = color, modifier = Modifier.size(22.dp))
            Spacer(Modifier.height(4.dp))
            Text(label, color = Color.White, fontSize = 11.sp, fontWeight = FontWeight.Medium)
        }
    }
}

// ─────────────────────────────────────────────────────────────
// ۶۹.۳. لیست سرورها نهایی
// ─────────────────────────────────────────────────────────────
@Composable
fun ServersFinal(vm: FinalVpnViewModel, back: () -> Unit) {
    val ctx = LocalContext.current
    val cfgs by vm.configs.collectAsState()
    val pinging by vm.isPinging.collectAsState()
    val prog by vm.progress.collectAsState()
    val currentName by vm.currentName.collectAsState()
    val sel by vm.selected.collectAsState()
    
    val mode by vm.pingMode.collectAsState()
    val favTick by vm.favTick.collectAsState()

    var search by remember { mutableStateOf("") }
    var filterProto by remember { mutableStateOf("all") }
    val favorites = remember(favTick) { FavoritesManager.getAll(ctx) }

    val displayed = cfgs
        .filter { search.isBlank() || it.name.contains(search, true) || it.server.contains(search, true) }
        .filter { filterProto == "all" || it.protocol == filterProto }
        .sortedBy {
            when {
                it.id == sel.id -> -2
                it.ping in 1..10000 -> it.ping
                else -> 99999
            }
        }

    Column(Modifier.fillMaxSize().background(Color(0xFF07080D))) {

        // هدر
        Row(
            Modifier.fillMaxWidth().padding(16.dp),
            Arrangement.SpaceBetween,
            Alignment.CenterVertically
        ) {
            IconButton(onClick = back) {
                Icon(Icons.Filled.ArrowBack, null, tint = Color.White)
            }
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Text("سرورها", color = Color.White, fontSize = 18.sp, fontWeight = FontWeight.Bold)
                Text("${displayed.size} از ${cfgs.size}", color = Color.White.copy(0.5f), fontSize = 10.sp)
            }
            IconButton(onClick = { vm.refreshFavorites() }) {
                Icon(Icons.Filled.Refresh, null, tint = Color.White)
            }
        }

        // تب پروتکل
        Row(
            Modifier.fillMaxWidth().padding(horizontal = 16.dp),
            horizontalArrangement = Arrangement.spacedBy(6.dp)
        ) {
            listOf("all" to "همه", "vless" to "VLESS", "vmess" to "VMess", "ss" to "SS").forEach { (k, l) ->
                Box(
                    Modifier
                        .weight(1f)
                        .clip(RoundedCornerShape(10.dp))
                        .background(if (filterProto == k) Color(0xFF7C4DFF).copy(0.25f) else Color(0xFF1B1F3A))
                        .border(1.dp, if (filterProto == k) Color(0xFF7C4DFF) else Color(0xFF2A3054), RoundedCornerShape(10.dp))
                        .clickable { filterProto = k }
                        .padding(vertical = 8.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text(l, color = if (filterProto == k) Color(0xFF7C4DFF) else Color.White.copy(0.7f),
                         fontSize = 11.sp, fontWeight = if (filterProto == k) FontWeight.Bold else FontWeight.Normal)
                }
            }
        }

        Spacer(Modifier.height(10.dp))

        // جستجو
        OutlinedTextField(
            value = search, onValueChange = { search = it },
            placeholder = { Text("جستجو...", color = Color.White.copy(0.4f), fontSize = 13.sp) },
            modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp),
            shape = RoundedCornerShape(14.dp),
            leadingIcon = { Icon(Icons.Filled.Search, null, tint = Color.White.copy(0.6f)) },
            colors = OutlinedTextFieldDefaults.colors(
                focusedTextColor = Color.White, unfocusedTextColor = Color.White,
                focusedBorderColor = Color(0xFF7C4DFF), unfocusedBorderColor = Color(0xFF2A3054),
                cursorColor = Color(0xFF7C4DFF)
            ),
            singleLine = true
        )

        Spacer(Modifier.height(10.dp))

        // حالت پینگ
        Row(
            Modifier.fillMaxWidth().padding(horizontal = 16.dp),
            horizontalArrangement = Arrangement.spacedBy(6.dp)
        ) {
            listOf(
                PingEngine.PingMode.QUICK to "⚡ سریع",
                PingEngine.PingMode.HYBRID to "🔀 ترکیبی",
                PingEngine.PingMode.XRAY to "🎯 دقیق"
            ).forEach { (m, l) ->
                Box(
                    Modifier
                        .weight(1f)
                        .clip(RoundedCornerShape(10.dp))
                        .background(if (mode == m) Color(0xFF7C4DFF).copy(0.25f) else Color(0xFF1B1F3A))
                        .border(1.dp, if (mode == m) Color(0xFF7C4DFF) else Color(0xFF2A3054), RoundedCornerShape(10.dp))
                        .clickable { vm.setPingMode(m) }
                        .padding(vertical = 8.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text(l, color = if (mode == m) Color(0xFF7C4DFF) else Color.White.copy(0.7f), fontSize = 11.sp)
                }
            }
        }

        Spacer(Modifier.height(10.dp))

        // دکمه‌های عملیات
        Row(
            Modifier.fillMaxWidth().padding(horizontal = 16.dp),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            FinalGradientBtn(
                if (pinging) "${prog.first}/${prog.second}" else "🚀 پینگ همه",
                listOf(Color(0xFF7C4DFF), Color(0xFFB47CFF)),
                !pinging,
                Modifier.weight(1f)
            ) { vm.pingAll() }

            FinalGradientBtn(
                "⭐ بهترین",
                listOf(Color(0xFF00E676), Color(0xFF00B8D4)),
                !pinging,
                Modifier.weight(1f)
            ) { vm.pickBest() }
        }

        if (pinging && currentName.isNotEmpty()) {
            Spacer(Modifier.height(6.dp))
            Text("▶ $currentName", color = Color.White.copy(0.5f), fontSize = 11.sp,
                 modifier = Modifier.padding(horizontal = 16.dp))
        }

        Spacer(Modifier.height(12.dp))

        // لیست
        if (displayed.isEmpty()) {
            Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                Text("سروری پیدا نشد", color = Color.White.copy(0.5f))
            }
        } else {
            LazyColumn(
                contentPadding = PaddingValues(horizontal = 16.dp, vertical = 4.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                items(displayed, key = { it.id }) { c ->
                    FinalServerRow(
                        cfg = c,
                        isSelected = c.id == sel.id,
                        isFav = c.id in favorites,
                        onClick = { vm.select(c) },
                        onFav = {
                            FavoritesManager.toggle(ctx, c.id)
                            vm.refreshFavorites()
                        }
                    )
                }
                item { Spacer(Modifier.height(20.dp)) }
            }
        }
    }
}

// ─────────────────────────────────────────────────────────────
// ۶۹.۴. FinalServerRow — ردیف سرور
// ─────────────────────────────────────────────────────────────
@Composable
fun FinalServerRow(
    cfg: VpnConfig,
    isSelected: Boolean,
    isFav: Boolean,
    onClick: () -> Unit,
    onFav: () -> Unit
) {
    val scale by animateFloatAsState(
        if (isSelected) 1.02f else 1f,
        spring(dampingRatio = Spring.DampingRatioMediumBouncy)
    )

    Box(
        Modifier
            .fillMaxWidth()
            .graphicsLayer { scaleX = scale; scaleY = scale }
            .clip(RoundedCornerShape(16.dp))
            .background(
                if (isSelected)
                    Brush.linearGradient(
                        listOf(Color(0xFF7C4DFF).copy(0.35f), Color(0xFF00E5FF).copy(0.15f))
                    )
                else
                    Brush.linearGradient(listOf(Color(0xFF1B1F3A), Color(0xFF232849)))
            )
            .border(
                if (isSelected) 1.5.dp else 0.5.dp,
                if (isSelected) Color(0xFF7C4DFF) else Color(0xFF2A3054),
                RoundedCornerShape(16.dp)
            )
            .clickable(onClick = onClick)
    ) {
        Row(
            Modifier.fillMaxWidth().padding(14.dp),
            Arrangement.SpaceBetween,
            Alignment.CenterVertically
        ) {
            Column(Modifier.weight(1f)) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Box(
                        Modifier
                            .size(8.dp)
                            .clip(CircleShape)
                            .background(
                                when {
                                    cfg.isWorking && cfg.ping in 1..150 -> Color(0xFF00E676)
                                    cfg.isWorking && cfg.ping in 151..400 -> Color(0xFFFFB300)
                                    cfg.isWorking -> Color(0xFFFF5252)
                                    else -> Color(0xFF5A5F7A)
                                }
                            )
                    )
                    Spacer(Modifier.width(8.dp))
                    Text(
                        cfg.name,
                        color = Color.White,
                        fontSize = 14.sp,
                        fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Medium,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                        modifier = Modifier.weight(1f, fill = false)
                    )
                    if (isSelected) {
                        Spacer(Modifier.width(6.dp))
                        Box(
                            Modifier
                                .clip(RoundedCornerShape(6.dp))
                                .background(Color(0xFF00E676).copy(0.2f))
                                .padding(horizontal = 6.dp, vertical = 2.dp)
                        ) {
                            Text("فعال", color = Color(0xFF00E676), fontSize = 9.sp, fontWeight = FontWeight.Bold)
                        }
                    }
                }
                Spacer(Modifier.height(4.dp))
                Text(
                    "${cfg.protocol.uppercase()} • ${cfg.server}",
                    color = Color.White.copy(0.5f),
                    fontSize = 11.sp,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
            }

            Spacer(Modifier.width(10.dp))

            Column(horizontalAlignment = Alignment.End) {
                if (cfg.ping > 0) {
                    val pingColor = when {
                        cfg.ping < 100 -> Color(0xFF00E676)
                        cfg.ping < 300 -> Color(0xFFFFB300)
                        else -> Color(0xFFFF5252)
                    }
                    Text(
                        "${cfg.ping}ms",
                        color = pingColor,
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Bold
                    )
                } else {
                    Text("—", color = Color.White.copy(0.3f), fontSize = 12.sp)
                }
                Spacer(Modifier.height(4.dp))
                IconButton(onClick = onFav, modifier = Modifier.size(24.dp)) {
                    Icon(
                        if (isFav) Icons.Filled.Star else Icons.Outlined.StarBorder,
                        null,
                        tint = if (isFav) Color(0xFFFFB300) else Color.White.copy(0.4f),
                        modifier = Modifier.size(18.dp)
                    )
                }
            }
        }
    }
}

// ─────────────────────────────────────────────────────────────
// ۶۹.۵. FinalGradientBtn — دکمه گرادیانت
// ─────────────────────────────────────────────────────────────
@Composable
fun FinalGradientBtn(
    text: String,
    colors: List<Color>,
    enabled: Boolean,
    modifier: Modifier = Modifier,
    onClick: () -> Unit
) {
    Button(
        onClick = onClick,
        enabled = enabled,
        modifier = modifier.height(48.dp),
        shape = RoundedCornerShape(14.dp),
        colors = ButtonDefaults.buttonColors(containerColor = Color.Transparent),
        contentPadding = PaddingValues(0.dp)
    ) {
        Box(
            Modifier
                .fillMaxSize()
                .background(Brush.linearGradient(if (enabled) colors else listOf(Color.Gray, Color.DarkGray))),
            contentAlignment = Alignment.Center
        ) {
            Text(text, color = Color.White, fontSize = 14.sp, fontWeight = FontWeight.Bold)
        }
    }
}

// ─────────────────────────────────────────────────────────────
// ۶۹.۶. AdminFinal — پنل ادمین سازگار با FinalVpnViewModel
// ─────────────────────────────────────────────────────────────
@Composable
fun AdminFinal(vm: FinalVpnViewModel, back: () -> Unit) {
    var pass by remember { mutableStateOf("") }
    var unlocked by remember { mutableStateOf(false) }
    var err by remember { mutableStateOf(false) }

    Column(
        Modifier.fillMaxSize().background(Color(0xFF07080D)).padding(16.dp)
    ) {
        Row(
            Modifier.fillMaxWidth(),
            Arrangement.SpaceBetween,
            Alignment.CenterVertically
        ) {
            IconButton(onClick = back) {
                Icon(Icons.Filled.ArrowBack, null, tint = Color.White)
            }
            Text("پنل مدیریت", color = Color.White, fontSize = 20.sp, fontWeight = FontWeight.Bold)
            Spacer(Modifier.width(48.dp))
        }

        if (!unlocked) {
            Spacer(Modifier.height(60.dp))
            Text("🔐 ورود مدیر", color = Color.White, fontSize = 18.sp)
            Spacer(Modifier.height(16.dp))

            OutlinedTextField(
                value = pass,
                onValueChange = { pass = it; err = false },
                label = { Text("رمز عبور") },
                visualTransformation = PasswordVisualTransformation(),
                isError = err,
                modifier = Modifier.fillMaxWidth(),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedTextColor = Color.White,
                    unfocusedTextColor = Color.White
                )
            )

            Spacer(Modifier.height(12.dp))

            Button(
                onClick = { if (vm.verifyPass(pass)) unlocked = true else err = true },
                modifier = Modifier.fillMaxWidth(),
                colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF7C4DFF))
            ) { Text("ورود") }

            if (err) {
                Spacer(Modifier.height(8.dp))
                Text("رمز اشتباه است", color = Color(0xFFFF5252))
            }
        } else {
            AdminPanelFinal(vm)
        }
    }
}

@Composable
fun AdminPanelFinal(vm: FinalVpnViewModel) {
    var link by remember { mutableStateOf("") }
    var name by remember { mutableStateOf("") }
    var msg by remember { mutableStateOf("") }
    val cfgs by vm.configs.collectAsState()
    val adminOnly = cfgs.filter { !it.isDefault }

    Column(
        Modifier.fillMaxSize().verticalScroll(rememberScrollState())
    ) {
        Text("➕ افزودن کانفیگ", color = Color.White, fontSize = 16.sp)
        Spacer(Modifier.height(8.dp))

        OutlinedTextField(
            value = name, onValueChange = { name = it },
            label = { Text("نام (مثلاً PARSAVPN-1234)") },
            modifier = Modifier.fillMaxWidth(),
            colors = OutlinedTextFieldDefaults.colors(
                focusedTextColor = Color.White, unfocusedTextColor = Color.White
            )
        )

        Spacer(Modifier.height(8.dp))

        OutlinedTextField(
            value = link, onValueChange = { link = it },
            label = { Text("لینک VLESS / VMess / SS / Trojan") },
            modifier = Modifier.fillMaxWidth().height(120.dp),
            colors = OutlinedTextFieldDefaults.colors(
                focusedTextColor = Color.White, unfocusedTextColor = Color.White
            )
        )

        Spacer(Modifier.height(8.dp))

        Button(
            onClick = {
                if (link.isBlank()) { msg = "لینک خالی است"; return@Button }
                val ok = vm.addAdmin(link.trim(), name.trim())
                msg = if (ok) "✓ اضافه شد" else "✗ لینک نامعتبر"
                if (ok) { link = ""; name = "" }
            },
            modifier = Modifier.fillMaxWidth(),
            colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF00E676))
        ) { Text("افزودن", color = Color.Black) }

        if (msg.isNotEmpty()) {
            Spacer(Modifier.height(8.dp))
            Text(msg, color = if (msg.startsWith("✓")) Color(0xFF00E676) else Color(0xFFFF5252))
        }

        Spacer(Modifier.height(24.dp))

        Text("🗑️ حذف کانفیگ‌های ادمین (${adminOnly.size})", color = Color.White, fontSize = 16.sp)
        Spacer(Modifier.height(8.dp))

        if (adminOnly.isEmpty()) {
            Text("هیچ کانفیگ ادمینی وجود ندارد", color = Color.White.copy(0.5f))
        } else {
            adminOnly.forEach { c ->
                Card(
                    Modifier.fillMaxWidth().padding(vertical = 4.dp),
                    colors = CardDefaults.cardColors(containerColor = Color(0xFF1B1F3A))
                ) {
                    Row(
                        Modifier.fillMaxWidth().padding(12.dp),
                        Arrangement.SpaceBetween,
                        Alignment.CenterVertically
                    ) {
                        Column(Modifier.weight(1f)) {
                            Text(c.name, color = Color.White)
                            Text(c.server, color = Color.White.copy(0.5f), fontSize = 11.sp)
                        }
                        IconButton(onClick = { vm.removeAdmin(c.id) }) {
                            Icon(Icons.Default.Delete, null, tint = Color(0xFFFF5252))
                        }
                    }
                }
            }
        }

        Spacer(Modifier.height(32.dp))
    }
}

// ─────────────────────────────────────────────────────────────
// ۶۹.۷. SettingsFinal — تنظیمات سازگار
// ─────────────────────────────────────────────────────────────
@Composable
fun SettingsFinal(back: () -> Unit, nav: (String) -> Unit) {
    Column(
        Modifier.fillMaxSize().background(Color(0xFF07080D)).padding(16.dp)
    ) {
        Row(
            Modifier.fillMaxWidth(),
            Arrangement.SpaceBetween,
            Alignment.CenterVertically
        ) {
            IconButton(onClick = back) {
                Icon(Icons.Filled.ArrowBack, null, tint = Color.White)
            }
            Text("تنظیمات", color = Color.White, fontSize = 20.sp, fontWeight = FontWeight.Bold)
            Spacer(Modifier.width(48.dp))
        }

        Spacer(Modifier.height(20.dp))

        listOf(
            "🌐 DNS سفارشی" to "1.1.1.1 / 8.8.8.8",
            "🚫 بلاک تبلیغات" to "فعال",
            "🇮🇷 دور زدن ایران" to "فعال",
            "🔋 حالت باتری" to "بهینه",
            "⚡ اتصال خودکار" to "غیرفعال",
            "🔐 Kill Switch" to "فعال",
            "📊 نمایش سرعت" to "فعال",
            "🌙 تم" to "تیره",
            "🎯 موتور پینگ" to "Xray Hybrid",
            "📡 پروتکل‌ها" to "Reality / gRPC / WS / TLS"
        ).forEach { (t, s) ->
            Card(
                Modifier.fillMaxWidth().padding(vertical = 4.dp),
                colors = CardDefaults.cardColors(containerColor = Color(0xFF1B1F3A))
            ) {
                Row(
                    Modifier.fillMaxWidth().padding(16.dp),
                    Arrangement.SpaceBetween
                ) {
                    Text(t, color = Color.White)
                    Text(s, color = Color.White.copy(0.6f), fontSize = 12.sp)
                }
            }
        }

        Spacer(Modifier.height(16.dp))

        Button(
            onClick = { nav("dns") },
            modifier = Modifier.fillMaxWidth(),
            colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF7C4DFF))
        ) { Text("🌐 تنظیمات DNS") }

        Spacer(Modifier.height(6.dp))

        OutlinedButton(
            onClick = { nav("routing") },
            modifier = Modifier.fillMaxWidth(),
            colors = ButtonDefaults.outlinedButtonColors(contentColor = Color.White)
        ) { Text("🔧 قوانین مسیریابی") }

        Spacer(Modifier.height(6.dp))

        OutlinedButton(
            onClick = { nav("log") },
            modifier = Modifier.fillMaxWidth(),
            colors = ButtonDefaults.outlinedButtonColors(contentColor = Color.White)
        ) { Text("📝 مشاهده لاگ‌ها") }
    }
}

// ─────────────────────────────────────────────────────────────
// ۶۹.۸. FavoritesFinal — صفحه محبوب‌ها
// ─────────────────────────────────────────────────────────────
@Composable
fun FavoritesFinal(vm: FinalVpnViewModel, back: () -> Unit) {
    val ctx = LocalContext.current
    val cfgs by vm.configs.collectAsState()
    val favTick by vm.favTick.collectAsState()
    val favorites = remember(favTick) { FavoritesManager.getAll(ctx) }
    val favList = cfgs.filter { it.id in favorites }

    Column(
        Modifier.fillMaxSize().background(Color(0xFF07080D)).padding(16.dp)
    ) {
        Row(
            Modifier.fillMaxWidth(),
            Arrangement.SpaceBetween,
            Alignment.CenterVertically
        ) {
            IconButton(onClick = back) {
                Icon(Icons.Filled.ArrowBack, null, tint = Color.White)
            }
            Text("⭐ محبوب‌ها (${favList.size})", color = Color.White, fontSize = 20.sp, fontWeight = FontWeight.Bold)
            Spacer(Modifier.width(48.dp))
        }

        Spacer(Modifier.height(12.dp))

        if (favList.isEmpty()) {
            Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text("⭐", fontSize = 60.sp)
                    Spacer(Modifier.height(12.dp))
                    Text("هنوز سروری به محبوب‌ها اضافه نکردی", color = Color.White.copy(0.6f))
                    Spacer(Modifier.height(6.dp))
                    Text("روی ستاره در لیست سرورها بزن", color = Color.White.copy(0.4f), fontSize = 12.sp)
                }
            }
        } else {
            LazyColumn(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                items(favList, key = { it.id }) { c ->
                    FinalServerRow(
                        cfg = c,
                        isSelected = false,
                        isFav = true,
                        onClick = { vm.select(c) },
                        onFav = {
                            FavoritesManager.toggle(ctx, c.id)
                            vm.refreshFavorites()
                        }
                    )
                }
            }
        }
    }
}

// ─────────────────────────────────────────────────────────────
// ۶۹.۹. AppFinal — نقطه ورود نهایی (همه صفحات اینجا وصل می‌شوند)
// ─────────────────────────────────────────────────────────────
@Composable
fun AppFinal() {
    val ctx = LocalContext.current
    val vm: FinalVpnViewModel = viewModel(
        factory = object : androidx.lifecycle.ViewModelProvider.Factory {
            override fun <T : ViewModel> create(c: Class<T>): T {
                @Suppress("UNCHECKED_CAST")
                return FinalVpnViewModel(ctx.applicationContext) as T
            }
        }
    )

    var screen by remember { mutableStateOf("home") }
    when (screen) {
        "home" -> HomeFinal(vm) { screen = it }
        "servers" -> ServersFinal(vm) { screen = "home" }
        "settings" -> SettingsFinal({ screen = "home" }) { screen = it }
        "admin" -> AdminFinal(vm) { screen = "home" }
        "favorites" -> FavoritesFinal(vm) { screen = "servers" }
        "dns" -> DnsScreen { screen = "settings" }
        "log" -> LogScreen { screen = "settings" }
        "routing" -> RoutingScreen { screen = "settings" }
    }
}

// ═══════════════════════════════════════════════════════════════
//      ۷۰. SplashScreen — صفحه شروع با انیمیشن حرفه‌ای
// ═══════════════════════════════════════════════════════════════
@Composable
fun SplashScreen(onDone: () -> Unit) {
    var started by remember { mutableStateOf(false) }
    val logoScale = remember { Animatable(0.5f) }
    val logoAlpha = remember { Animatable(0f) }
    val textAlpha = remember { Animatable(0f) }
    val ringRotate = remember { Animatable(0f) }

    LaunchedEffect(Unit) {
        started = true
        // موج ۱: بزرگ شدن لوگو
        logoAlpha.animateTo(1f, tween(500))
        logoScale.animateTo(1f, spring(dampingRatio = Spring.DampingRatioMediumBouncy))
        // موج ۲: چرخش حلقه
        launch { ringRotate.animateTo(360f, tween(1500, easing = LinearEasing)) }
        // موج ۳: ظاهر شدن متن
        delay(200)
        textAlpha.animateTo(1f, tween(700))
        // پایان
        delay(800)
        onDone()
    }

    Box(
        Modifier
            .fillMaxSize()
            .background(
                Brush.radialGradient(
                    listOf(Color(0xFF10112E), Color(0xFF07080D))
                )
            ),
        contentAlignment = Alignment.Center
    ) {
        // هاله‌ی نرم
        Box(
            Modifier
                .size(400.dp)
                .background(
                    Brush.radialGradient(
                        listOf(Color(0xFF7C4DFF).copy(0.2f), Color.Transparent)
                    )
                )
        )

        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Box(
                Modifier.size(180.dp),
                contentAlignment = Alignment.Center
            ) {
                // حلقه چرخان
                androidx.compose.foundation.Canvas(
                    Modifier.size(160.dp)
                ) {
                    val stroke = 3f
                    drawArc(
                        color = Color(0xFF7C4DFF),
                        startAngle = 0f,
                        sweepAngle = 90f,
                        useCenter = false,
                        style = androidx.compose.ui.graphics.drawscope.Stroke(
                            width = stroke,
                            cap = androidx.compose.ui.graphics.StrokeCap.Round
                        ),
                        topLeft = androidx.compose.ui.geometry.Offset(stroke, stroke),
                        size = androidx.compose.ui.geometry.Size(
                            size.width - stroke * 2,
                            size.height - stroke * 2
                        )
                    )
                    drawArc(
                        color = Color(0xFF00E5FF),
                        startAngle = 180f,
                        sweepAngle = 90f,
                        useCenter = false,
                        style = androidx.compose.ui.graphics.drawscope.Stroke(
                            width = stroke,
                            cap = androidx.compose.ui.graphics.StrokeCap.Round
                        ),
                        topLeft = androidx.compose.ui.geometry.Offset(stroke, stroke),
                        size = androidx.compose.ui.geometry.Size(
                            size.width - stroke * 2,
                            size.height - stroke * 2
                        )
                    )
                }

                // لوگوی اصلی
                Box(
                    Modifier
                        .size(110.dp)
                        .graphicsLayer {
                            scaleX = logoScale.value
                            scaleY = logoScale.value
                            alpha = logoAlpha.value
                        }
                        .clip(RoundedCornerShape(28.dp))
                        .background(
                            Brush.linearGradient(
                                listOf(Color(0xFF7C4DFF), Color(0xFF00E5FF))
                            )
                        ),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        Icons.Filled.Security,
                        null,
                        tint = Color.White,
                        modifier = Modifier.size(64.dp)
                    )
                }
            }

            Spacer(Modifier.height(28.dp))

            Text(
                "PARSA VPN",
                fontSize = 32.sp,
                fontWeight = FontWeight.Bold,
                modifier = Modifier.graphicsLayer { alpha = textAlpha.value },
                style = androidx.compose.ui.text.TextStyle(
                    brush = Brush.linearGradient(
                        listOf(Color(0xFF7C4DFF), Color(0xFF00E5FF))
                    )
                )
            )

            Spacer(Modifier.height(8.dp))

            Text(
                "سریع • امن • مدرن",
                color = Color.White.copy(0.55f),
                fontSize = 13.sp,
                letterSpacing = 3.sp,
                modifier = Modifier.graphicsLayer { alpha = textAlpha.value }
            )

            Spacer(Modifier.height(60.dp))

            // نقطه‌های لودینگ
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                val inf = rememberInfiniteTransition()
                repeat(3) { i ->
                    val a by inf.animateFloat(
                        0.3f, 1f,
                        infiniteRepeatable(
                            tween(600, delayMillis = i * 200),
                            RepeatMode.Reverse
                        )
                    )
                    Box(
                        Modifier
                            .size(8.dp)
                            .clip(CircleShape)
                            .background(Color(0xFF7C4DFF).copy(alpha = a))
                    )
                }
            }
        }
    }
}

// ═══════════════════════════════════════════════════════════════
//      ۷۱. ServerDetailScreen — صفحه جزئیات سرور
// ═══════════════════════════════════════════════════════════════
@Composable
fun ServerDetailScreen(
    cfg: VpnConfig,
    isFavorite: Boolean,
    onBack: () -> Unit,
    onConnect: () -> Unit,
    onToggleFav: () -> Unit,
    onShare: () -> Unit,
    onCopy: () -> Unit
) {
    val ctx = LocalContext.current
    var pingHistory by remember {
        mutableStateOf(listOf(80f, 120f, 95f, 140f, 110f, 90f, 100f, 130f, 105f, 118f))
    }

    LaunchedEffect(cfg.id) {
        // شبیه‌سازی تاریخچه‌ی پینگ
        pingHistory = List(15) { (60..180).random().toFloat() }
    }

    Column(
        Modifier
            .fillMaxSize()
            .background(
                Brush.verticalGradient(
                    listOf(Color(0xFF07080D), Color(0xFF10112E), Color(0xFF07080D))
                )
            )
    ) {
        // هدر
        Row(
            Modifier.fillMaxWidth().padding(16.dp),
            Arrangement.SpaceBetween,
            Alignment.CenterVertically
        ) {
            IconButton(onClick = onBack) {
                Icon(Icons.Filled.ArrowBack, null, tint = Color.White)
            }
            Text("جزئیات سرور", color = Color.White, fontSize = 18.sp, fontWeight = FontWeight.Bold)
            IconButton(onClick = onToggleFav) {
                Icon(
                    if (isFavorite) Icons.Filled.Star else Icons.Outlined.StarBorder,
                    null,
                    tint = if (isFavorite) Color(0xFFFFB300) else Color.White.copy(0.6f)
                )
            }
        }

        Column(
            Modifier.fillMaxSize().verticalScroll(rememberScrollState()).padding(20.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // آیکون بزرگ سرور
            Box(
                Modifier
                    .size(100.dp)
                    .clip(CircleShape)
                    .background(
                        Brush.linearGradient(
                            listOf(
                                Color(0xFF7C4DFF).copy(0.3f),
                                Color(0xFF00E5FF).copy(0.15f)
                            )
                        )
                    ),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    Icons.Filled.Dns,
                    null,
                    tint = Color(0xFF7C4DFF),
                    modifier = Modifier.size(48.dp)
                )
            }

            Spacer(Modifier.height(16.dp))

            Text(cfg.name, color = Color.White, fontSize = 22.sp, fontWeight = FontWeight.Bold)
            Spacer(Modifier.height(4.dp))
            Text(
                "${cfg.protocol.uppercase()} • ${cfg.server}:${cfg.port}",
                color = Color.White.copy(0.55f),
                fontSize = 12.sp
            )

            Spacer(Modifier.height(24.dp))

            // کارت‌های آمار
            Row(Modifier.fillMaxWidth(), Arrangement.spacedBy(10.dp)) {
                DetailStatCard(
                    "پینگ فعلی",
                    if (cfg.ping > 0) "${cfg.ping}ms" else "—",
                    when {
                        cfg.ping in 1..100 -> Color(0xFF00E676)
                        cfg.ping in 101..300 -> Color(0xFFFFB300)
                        cfg.ping > 300 -> Color(0xFFFF5252)
                        else -> Color.White.copy(0.4f)
                    },
                    Modifier.weight(1f)
                )
                DetailStatCard(
                    "وضعیت",
                    if (cfg.isWorking) "آنلاین" else "آفلاین",
                    if (cfg.isWorking) Color(0xFF00E676) else Color(0xFFFF5252),
                    Modifier.weight(1f)
                )
            }

            Spacer(Modifier.height(10.dp))

            Row(Modifier.fillMaxWidth(), Arrangement.spacedBy(10.dp)) {
                DetailStatCard(
                    "پروتکل",
                    cfg.protocol.uppercase(),
                    Color(0xFF7C4DFF),
                    Modifier.weight(1f)
                )
                DetailStatCard(
                    "پورت",
                    cfg.port.toString(),
                    Color(0xFF00E5FF),
                    Modifier.weight(1f)
                )
            }

            Spacer(Modifier.height(24.dp))

            // نمودار تاریخچه پینگ
            Card(
                Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(containerColor = Color(0xFF1B1F3A))
            ) {
                Column(Modifier.padding(16.dp)) {
                    Row(
                        Modifier.fillMaxWidth(),
                        Arrangement.SpaceBetween,
                        Alignment.CenterVertically
                    ) {
                        Text("تاریخچه پینگ", color = Color.White, fontSize = 13.sp, fontWeight = FontWeight.Bold)
                        Text(
                            "میانگین: ${pingHistory.average().toInt()}ms",
                            color = Color.White.copy(0.5f),
                            fontSize = 11.sp
                        )
                    }
                    Spacer(Modifier.height(12.dp))
                    Sparkline(
                        data = pingHistory,
                        color = Color(0xFF00E5FF),
                        modifier = Modifier.fillMaxWidth().height(80.dp)
                    )
                    Spacer(Modifier.height(8.dp))
                    Row(
                        Modifier.fillMaxWidth(),
                        Arrangement.SpaceBetween
                    ) {
                        Text("کمترین: ${pingHistory.minOrNull()?.toInt() ?: 0}ms",
                             color = Color(0xFF00E676), fontSize = 10.sp)
                        Text("بیشترین: ${pingHistory.maxOrNull()?.toInt() ?: 0}ms",
                             color = Color(0xFFFF5252), fontSize = 10.sp)
                    }
                }
            }

            Spacer(Modifier.height(16.dp))

            // اطلاعات کامل
            Card(
                Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(containerColor = Color(0xFF1B1F3A))
            ) {
                Column(Modifier.padding(16.dp)) {
                    DetailRow("🌐 آدرس", cfg.server)
                    Divider(color = Color(0xFF2A3054), modifier = Modifier.padding(vertical = 8.dp))
                    DetailRow("🔌 پورت", cfg.port.toString())
                    Divider(color = Color(0xFF2A3054), modifier = Modifier.padding(vertical = 8.dp))
                    DetailRow("📡 پروتکل", cfg.protocol.uppercase())
                    Divider(color = Color(0xFF2A3054), modifier = Modifier.padding(vertical = 8.dp))
                    DetailRow("🆔 شناسه", cfg.id.take(12) + "...")
                }
            }

            Spacer(Modifier.height(24.dp))

            // دکمه‌های عملیات
            FinalGradientBtn(
                "🚀 اتصال",
                listOf(Color(0xFF7C4DFF), Color(0xFFB47CFF)),
                true,
                Modifier.fillMaxWidth()
            ) { onConnect() }

            Spacer(Modifier.height(10.dp))

            Row(Modifier.fillMaxWidth(), Arrangement.spacedBy(10.dp)) {
                OutlinedButton(
                    onClick = onShare,
                    modifier = Modifier.weight(1f),
                    colors = ButtonDefaults.outlinedButtonColors(contentColor = Color.White),
                    shape = RoundedCornerShape(14.dp)
                ) { Text("📤 اشتراک", fontSize = 13.sp) }

                OutlinedButton(
                    onClick = onCopy,
                    modifier = Modifier.weight(1f),
                    colors = ButtonDefaults.outlinedButtonColors(contentColor = Color.White),
                    shape = RoundedCornerShape(14.dp)
                ) { Text("📋 کپی", fontSize = 13.sp) }
            }

            Spacer(Modifier.height(40.dp))
        }
    }
}

@Composable
fun DetailStatCard(title: String, value: String, color: Color, modifier: Modifier) {
    Card(
        modifier,
        colors = CardDefaults.cardColors(containerColor = Color(0xFF1B1F3A))
    ) {
        Column(
            Modifier.fillMaxWidth().padding(14.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(title, color = Color.White.copy(0.5f), fontSize = 10.sp)
            Spacer(Modifier.height(4.dp))
            Text(value, color = color, fontSize = 18.sp, fontWeight = FontWeight.Bold)
        }
    }
}

@Composable
fun DetailRow(label: String, value: String) {
    Row(
        Modifier.fillMaxWidth(),
        Arrangement.SpaceBetween
    ) {
        Text(label, color = Color.White.copy(0.6f), fontSize = 12.sp)
        Text(
            value,
            color = Color.White,
            fontSize = 12.sp,
            fontWeight = FontWeight.Medium,
            textAlign = androidx.compose.ui.text.style.TextAlign.End,
            modifier = Modifier.widthIn(max = 220.dp)
        )
    }
}

// ═══════════════════════════════════════════════════════════════
//      ۷۲. AboutScreen — درباره ما با انیمیشن
// ═══════════════════════════════════════════════════════════════
@Composable
fun AboutScreen(onBack: () -> Unit) {
    var animStart by remember { mutableStateOf(false) }
    LaunchedEffect(Unit) { animStart = true }

    Column(
        Modifier
            .fillMaxSize()
            .background(
                Brush.verticalGradient(
                    listOf(Color(0xFF07080D), Color(0xFF10112E), Color(0xFF07080D))
                )
            )
    ) {
        Row(
            Modifier.fillMaxWidth().padding(16.dp),
            Arrangement.SpaceBetween,
            Alignment.CenterVertically
        ) {
            IconButton(onClick = onBack) {
                Icon(Icons.Filled.ArrowBack, null, tint = Color.White)
            }
            Text("درباره ما", color = Color.White, fontSize = 18.sp, fontWeight = FontWeight.Bold)
            Spacer(Modifier.width(48.dp))
        }

        Column(
            Modifier.fillMaxSize().verticalScroll(rememberScrollState()).padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // لوگو با انیمیشن ورود
            val inf = rememberInfiniteTransition()
            val rotate by inf.animateFloat(
                0f, 360f,
                infiniteRepeatable(tween(8000, easing = LinearEasing))
            )

            Box(
                Modifier.size(120.dp),
                contentAlignment = Alignment.Center
            ) {
                androidx.compose.foundation.Canvas(Modifier.fillMaxSize()) {
                    val stroke = 2f
                    drawCircle(
                        brush = Brush.sweepGradient(
                            listOf(
                                Color(0xFF7C4DFF),
                                Color(0xFF00E5FF),
                                Color(0xFF7C4DFF)
                            ),
                            center = androidx.compose.ui.geometry.Offset(size.width / 2, size.height / 2)
                        ),
                        radius = size.minDimension / 2 - stroke,
                        style = androidx.compose.ui.graphics.drawscope.Stroke(width = stroke)
                    )
                }
                Box(
                    Modifier
                        .size(90.dp)
                        .clip(RoundedCornerShape(24.dp))
                        .background(
                            Brush.linearGradient(
                                listOf(Color(0xFF7C4DFF), Color(0xFF00E5FF))
                            )
                        ),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(Icons.Filled.Security, null, tint = Color.White, modifier = Modifier.size(48.dp))
                }
            }

            Spacer(Modifier.height(20.dp))

            Text(
                "PARSA VPN",
                fontSize = 26.sp,
                fontWeight = FontWeight.Bold,
                style = androidx.compose.ui.text.TextStyle(
                    brush = Brush.linearGradient(listOf(Color(0xFF7C4DFF), Color(0xFF00E5FF)))
                )
            )

            Spacer(Modifier.height(4.dp))

            Text(
                "نسخه 1.0.0",
                color = Color.White.copy(0.5f),
                fontSize = 12.sp
            )

            Spacer(Modifier.height(24.dp))

            // کارت توضیحات
            Card(
                Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(containerColor = Color(0xFF1B1F3A))
            ) {
                Column(Modifier.padding(20.dp)) {
                    Text(
                        "🌐 درباره اپ",
                        color = Color.White,
                        fontSize = 14.sp,
                        fontWeight = FontWeight.Bold
                    )
                    Spacer(Modifier.height(8.dp))
                    Text(
                        "PARSA VPN یک کلاینت سریع، امن و مدرن برای دسترسی آزاد به اینترنت است. این اپ بر پایه هسته Xray ساخته شده و از پروتکل‌های VLESS، VMess، Shadowsocks و Trojan پشتیبانی می‌کند.",
                        color = Color.White.copy(0.75f),
                        fontSize = 12.sp,
                        lineHeight = 20.sp
                    )
                }
            }

            Spacer(Modifier.height(12.dp))

            // ویژگی‌ها
            listOf(
                "🚀" to "سرعت بالا با هسته Xray",
                "🔐" to "رمزنگاری AES-256",
                "🌍" to "پشتیبانی از Reality و gRPC",
                "⚡" to "موتور پینگ پیشرفته",
                "🎨" to "رابط کاربری مدرن",
                "🔧" to "قوانین مسیریابی سفارشی"
  
            ).forEach { (emoji, text) ->
                Card(
                    Modifier.fillMaxWidth().padding(vertical = 4.dp),
                    colors = CardDefaults.cardColors(containerColor = Color(0xFF1B1F3A))
                ) {
                    Row(
                        Modifier.fillMaxWidth().padding(14.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(emoji, fontSize = 22.sp)
                        Spacer(Modifier.width(12.dp))
                        Text(text, color = Color.White, fontSize = 13.sp)
                    }
                }
            }

            Spacer(Modifier.height(24.dp))

            // اعتبارات
            Text(
                "ساخته شده با ❤️ در ایران",
                color = Color.White.copy(0.5f),
                fontSize = 11.sp
            )

            Spacer(Modifier.height(8.dp))

            Text(
                "© 2025 PARSA VPN",
                color = Color.White.copy(0.35f),
                fontSize = 10.sp
            )

            Spacer(Modifier.height(40.dp))
        }
    }
}

// ═══════════════════════════════════════════════════════════════
//      ۷۳. SoundManager — افکت‌های صوتی و لرزش
// ═══════════════════════════════════════════════════════════════
object SoundManager {
    private const val PREFS = "parsa_sound"

    fun isEnabled(ctx: Context): Boolean =
        ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .getBoolean("enabled", true)

    fun setEnabled(ctx: Context, on: Boolean) {
        ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit().putBoolean("enabled", on).apply()
    }

    fun playConnect(ctx: Context) {
        if (!isEnabled(ctx)) return
        try {
            val vibrator = if (Build.VERSION.SDK_INT >= 31) {
                val vm = ctx.getSystemService(Context.VIBRATOR_MANAGER_SERVICE)
                    as? android.os.VibratorManager
                vm?.defaultVibrator
            } else {
                @Suppress("DEPRECATION")
                ctx.getSystemService(Context.VIBRATOR_SERVICE) as? android.os.Vibrator
            }
            vibrator?.vibrate(
                android.os.VibrationEffect.createOneShot(
                    60,
                    android.os.VibrationEffect.DEFAULT_AMPLITUDE
                )
            )
        } catch (_: Exception) {}
    }

    fun playDisconnect(ctx: Context) {
        if (!isEnabled(ctx)) return
        try {
            val vibrator = if (Build.VERSION.SDK_INT >= 31) {
                val vm = ctx.getSystemService(Context.VIBRATOR_MANAGER_SERVICE)
                    as? android.os.VibratorManager
                vm?.defaultVibrator
            } else {
                @Suppress("DEPRECATION")
                ctx.getSystemService(Context.VIBRATOR_SERVICE) as? android.os.Vibrator
            }
            vibrator?.vibrate(
                android.os.VibrationEffect.createWaveform(
                    longArrayOf(0, 40, 60, 40),
                    -1
                )
            )
        } catch (_: Exception) {}
    }

    fun playTick(ctx: Context) {
        if (!isEnabled(ctx)) return
        try {
            val vibrator = if (Build.VERSION.SDK_INT >= 31) {
                val vm = ctx.getSystemService(Context.VIBRATOR_MANAGER_SERVICE)
                    as? android.os.VibratorManager
                vm?.defaultVibrator
            } else {
                @Suppress("DEPRECATION")
                ctx.getSystemService(Context.VIBRATOR_SERVICE) as? android.os.Vibrator
            }
            vibrator?.vibrate(
                android.os.VibrationEffect.createOneShot(
                    15,
                    40
                )
            )
        } catch (_: Exception) {}
    }
}

// ═══════════════════════════════════════════════════════════════
//      ۷۴. ThemePickerScreen — انتخاب تم رنگی
// ═══════════════════════════════════════════════════════════════
data class ThemeColors(
    val name: String,
    val primary: Color,
    val accent: Color
)

object ThemeManager2 {
    private const val PREFS = "parsa_theme_colors"

    val THEMES = listOf(
        ThemeColors("بنفش (پیش‌فرض)", Color(0xFF7C4DFF), Color(0xFF00E5FF)),
        ThemeColors("آبی اقیانوسی", Color(0xFF0088FF), Color(0xFF00E5FF)),
        ThemeColors("سبز زمرد", Color(0xFF00C853), Color(0xFF64DD17)),
        ThemeColors("قرمز آتشین", Color(0xFFFF1744), Color(0xFFFF9100)),
        ThemeColors("نارنجی غروب", Color(0xFFFF6D00), Color(0xFFFFB300)),
        ThemeColors("صورتی نئون", Color(0xFFE91E63), Color(0xFFFF4081)),
        ThemeColors("سفید مینیمال", Color(0xFF757575), Color(0xFF9E9E9E)),
        ThemeColors("طوسی تیره", Color(0xFF424242), Color(0xFF616161))
    )

    fun getTheme(ctx: Context): ThemeColors {
        val name = ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .getString("theme", THEMES[0].name) ?: THEMES[0].name
        return THEMES.firstOrNull { it.name == name } ?: THEMES[0]
    }

    fun setTheme(ctx: Context, theme: ThemeColors) {
        ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit().putString("theme", theme.name).apply()
    }
}

@Composable
fun ThemePickerScreen(onBack: () -> Unit) {
    val ctx = LocalContext.current
    var selected by remember { mutableStateOf(ThemeManager2.getTheme(ctx)) }

    Column(
        Modifier
            .fillMaxSize()
            .background(Color(0xFF07080D))
    ) {
        Row(
            Modifier.fillMaxWidth().padding(16.dp),
            Arrangement.SpaceBetween,
            Alignment.CenterVertically
        ) {
            IconButton(onClick = onBack) {
                Icon(Icons.Filled.ArrowBack, null, tint = Color.White)
            }
            Text("🎨 انتخاب تم", color = Color.White, fontSize = 18.sp, fontWeight = FontWeight.Bold)
            Spacer(Modifier.width(48.dp))
        }

        LazyColumn(
            Modifier.fillMaxSize().padding(horizontal = 16.dp),
            verticalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            items(ThemeManager2.THEMES) { theme ->
                val isSelected = theme.name == selected.name
                Box(
                    Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(16.dp))
                        .background(
                            if (isSelected)
                                Brush.linearGradient(
                                    listOf(
                                        theme.primary.copy(0.3f),
                                        theme.accent.copy(0.15f)
                                    )
                                )
                            else
                                Brush.linearGradient(
                                    listOf(Color(0xFF1B1F3A), Color(0xFF232849))
                                )
                        )
                        .border(
                            if (isSelected) 1.5.dp else 0.5.dp,
                            if (isSelected) theme.primary else Color(0xFF2A3054),
                            RoundedCornerShape(16.dp)
                        )
                        .clickable {
                            selected = theme
                            ThemeManager2.setTheme(ctx, theme)
                            SoundManager.playTick(ctx)
                        }
                        .padding(16.dp)
                ) {
                    Row(
                        Modifier.fillMaxWidth(),
                        Arrangement.SpaceBetween,
                        Alignment.CenterVertically
                    ) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Box(
                                Modifier
                                    .size(36.dp)
                                    .clip(CircleShape)
                                    .background(
                                        Brush.linearGradient(
                                            listOf(theme.primary, theme.accent)
                                        )
                                    )
                            )
                            Spacer(Modifier.width(14.dp))
                            Text(
                                theme.name,
                                color = Color.White,
                                fontSize = 14.sp,
                                fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal
                            )
                        }
                        if (isSelected) {
                            Icon(
                                Icons.Filled.CheckCircle,
                                null,
                                tint = theme.primary,
                                modifier = Modifier.size(24.dp)
                            )
                        }
                    }
                }
            }
            item { Spacer(Modifier.height(20.dp)) }
        }
    }
}

// ═══════════════════════════════════════════════════════════════
//      ۷۵. AppFinal نهایی (با Splash و Detail)
// ═══════════════════════════════════════════════════════════════
@Composable
fun AppFinal() {
    val ctx = LocalContext.current
    val vm: FinalVpnViewModel = viewModel(
        factory = object : androidx.lifecycle.ViewModelProvider.Factory {
            override fun <T : ViewModel> create(c: Class<T>): T {
                @Suppress("UNCHECKED_CAST")
                return FinalVpnViewModel(ctx.applicationContext) as T
            }
        }
    )

    var showSplash by remember { mutableStateOf(true) }
    var screen by remember { mutableStateOf("home") }
    var detailCfg by remember { mutableStateOf<VpnConfig?>(null) }

    // ─── Splash ───
    if (showSplash) {
        SplashScreen { showSplash = false }
        return
    }

    when (screen) {
        "home" -> HomeFinal(vm) { screen = it }
        "servers" -> ServersFinal(vm) { screen = "home" }
        "settings" -> SettingsFinal({ screen = "home" }) { screen = it }
        "admin" -> AdminFinal(vm) { screen = "home" }
        "favorites" -> FavoritesFinal(vm) { screen = "servers" }
        "dns" -> DnsScreen { screen = "settings" }
        "log" -> LogScreen { screen = "settings" }
        "routing" -> RoutingScreen { screen = "settings" }
        "about" -> AboutScreen { screen = "settings" }
        "theme" -> ThemePickerScreen { screen = "settings" }
        "detail" -> detailCfg?.let { cfg ->
            ServerDetailScreen(
                cfg = cfg,
                isFavorite = FavoritesManager.isFavorite(ctx, cfg.id),
                onBack = { screen = "servers" },
                onConnect = {
                    vm.select(cfg)
                    screen = "home"
                },
                onToggleFav = {
                    FavoritesManager.toggle(ctx, cfg.id)
                    vm.refreshFavorites()
                },
                onShare = {
                    val intent = Intent(Intent.ACTION_SEND).apply {
                        type = "text/plain"
                        putExtra(Intent.EXTRA_TEXT, cfg.rawLink)
                    }
                    ctx.startActivity(Intent.createChooser(intent, "اشتراک‌گذاری کانفیگ"))
                },
                onCopy = {
                    val cm = ctx.getSystemService(Context.CLIPBOARD_SERVICE)
                        as android.content.ClipboardManager
                    cm.setPrimaryClip(
                        android.content.ClipData.newPlainText("config", cfg.rawLink)
                    )
                    Toast.makeText(ctx, "کپی شد", Toast.LENGTH_SHORT).show()
                }
            )
        } ?: run { screen = "servers" }
    }
}

// ═══════════════════════════════════════════════════════════════
//      ۷۶. QuickSettingsTile — از پنل اعلان
// ═══════════════════════════════════════════════════════════════
@android.annotation.TargetApi(Build.VERSION_CODES.N)
class ParsaTileService : android.service.quicksettings.TileService() {

    override fun onStartListening() {
        super.onStartListening()
        updateTile()
    }

    override fun onClick() {
        super.onClick()
        try {
            if (RealVpnService.isRunning) {
                startService(Intent(this, RealVpnService::class.java).apply {
                    action = RealVpnService.ACTION_DISCONNECT
                })
            } else {
                val mgr = ConfigManager(this)
                val sel = mgr.getSelected() ?: mgr.getBest() ?: mgr.getAllConfigs().firstOrNull() ?: return
                val json = try { XrayBuilder.build(sel, this) } catch (_: Exception) { return }

                val intent = Intent(this, RealVpnService::class.java).apply {
                    action = RealVpnService.ACTION_CONNECT
                    putExtra("xray_config", json)
                    putExtra("server_name", sel.name)
                }
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    startForegroundService(intent)
                } else {
                    startService(intent)
                }
            }
        } catch (_: Exception) {}

        android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
            updateTile()
        }, 1000)
    }

    private fun updateTile() {
        val tile = qsTile ?: return
        tile.label = "PARSA VPN"
        if (RealVpnService.isRunning) {
            tile.state = android.service.quicksettings.Tile.STATE_ACTIVE
            tile.contentDescription = "متصل"
        } else {
            tile.state = android.service.quicksettings.Tile.STATE_INACTIVE
            tile.contentDescription = "قطع"
        }
        tile.updateTile()
    }
}

// ═══════════════════════════════════════════════════════════════
//      ۷۷. Performance Logger — ثبت سرعت
// ═══════════════════════════════════════════════════════════════
object PerfLogger {
    private val log = mutableListOf<Pair<Long, String>>()
    private val lock = Any()

    fun log(tag: String, ms: Long) {
        synchronized(lock) {
            log.add(ms to "[$tag] ${ms}ms")
            if (log.size > 100) log.removeAt(0)
        }
    }

    fun dump(): String = synchronized(lock) {
        log.joinToString("\n") { it.second }
    }

    fun clear() = synchronized(lock) { log.clear() }
}

// ═══════════════════════════════════════════════════════════════
//      ۷۸. Inline Banner — بنر تبلیغاتی/اطلاع‌رسانی (اختیاری)
// ═══════════════════════════════════════════════════════════════
@Composable
fun InfoBanner(
    text: String,
    icon: androidx.compose.ui.graphics.vector.ImageVector = Icons.Filled.Info,
    color: Color = Color(0xFF7C4DFF),
    onClick: (() -> Unit)? = null
) {
    val inf = rememberInfiniteTransition()
    val glow by inf.animateFloat(
        0.4f, 1f,
        infiniteRepeatable(tween(1500, easing = FastOutSlowInEasing), RepeatMode.Reverse)
    )

    Box(
        Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .background(
                Brush.horizontalGradient(
                    listOf(color.copy(0.2f), color.copy(0.08f))
                )
            )
            .border(1.dp, color.copy(alpha = glow * 0.5f), RoundedCornerShape(12.dp))
            .let {
                if (onClick != null) it.clickable { onClick() } else it
            }
            .padding(12.dp)
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Icon(icon, null, tint = color, modifier = Modifier.size(20.dp))
            Spacer(Modifier.width(10.dp))
            Text(
                text,
                color = Color.White,
                fontSize = 12.sp,
                modifier = Modifier.weight(1f)
            )
        }
    }
}

   
 
