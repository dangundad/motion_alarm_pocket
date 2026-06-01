import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties =  Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.reader().use { reader ->
        localProperties.load(reader)
    }
}

val flutterMinSdkVersion = localProperties.getProperty("flutter.flutterMinSdkVersion") ?: "24"
val flutterTargetSdkVersion = localProperties.getProperty("flutter.flutterTargetSdkVersion") ?: "36"
val flutterVersionCode = localProperties.getProperty("flutter.versionCode") ?: "3"
val flutterVersionName = localProperties.getProperty("flutter.versionName") ?: "1.0.1"

android {
    namespace = "com.dangundad.motion.alarm.pocket"
    compileSdk = Math.max(flutter.compileSdkVersion, 36)
    ndkVersion = "28.2.13676358"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true 
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        namespace = "com.dangundad.motion.alarm.pocket"
        minSdk = maxOf(flutterMinSdkVersion.toInt(), 24)
        targetSdk = flutterTargetSdkVersion.toInt()
        versionCode = flutterVersionCode.toInt()
        versionName = flutterVersionName.toString()

        multiDexEnabled = true // 멀티덱스를 사용하도록 설정.
    }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("config") {
                keyAlias = keystoreProperties["keyAlias"] as? String ?: ""
                keyPassword = keystoreProperties["keyPassword"] as? String ?: ""
                storeFile = (keystoreProperties["storeFile"] as? String)?.let { file(it) }
                storePassword = keystoreProperties["storePassword"] as? String ?: ""
            }
        }
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = true
            isShrinkResources = true
            signingConfig = if (keystorePropertiesFile.exists()) signingConfigs.getByName("config") else signingConfigs.getByName("debug")
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        getByName("debug") {
            isDebuggable = true
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
    implementation("androidx.work:work-runtime-ktx:2.11.2")
    implementation("com.google.android.gms:play-services-basement:18.10.0")
    implementation(platform("org.jetbrains.kotlin:kotlin-bom:2.2.20"))
    implementation(platform("com.google.firebase:firebase-bom:34.13.0"))
    implementation("com.google.firebase:firebase-crashlytics")
    implementation("com.google.firebase:firebase-analytics")
    implementation("androidx.multidex:multidex:2.0.1")

    implementation("androidx.core:core-ktx:1.18.0")
    implementation("androidx.activity:activity-ktx:1.13.0")
    implementation("androidx.window:window:1.5.1")

    implementation("com.google.android.gms:play-services-ads:25.3.0")
    implementation("com.google.android.ump:user-messaging-platform:4.0.0")
}
