
plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

import java.util.Properties
import java.io.FileInputStream

// load key.properties if it exists (key.properties should be at project root)
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}


android {
    namespace = "com.Vgotec.timesheet"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.Vgotec.timesheet"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // ---------- ADD THIS signingConfigs BLOCK ----------
    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            } else {
                // keep release unset when key.properties not present (prevents build failure if you intentionally don't have keystore)
            }
        }
    }

buildTypes {
    release {
        // use the release signing config if key.properties exists
        if (keystorePropertiesFile.exists()) {
            signingConfig = signingConfigs.getByName("release")
        } else {
            signingConfig = signingConfigs.getByName("debug")
        }

        isMinifyEnabled = false            // enable code shrinking (R8)
        isShrinkResources = false          // remove unused resources
        isDebuggable = false

        // ProGuard/R8 config files
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
    }
}

}


flutter {
    source = "../.."
}
