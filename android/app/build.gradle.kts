plugins {
    id("com.android.application")
    id("kotlin-android")

    // Flutter plugin
    id("dev.flutter.flutter-gradle-plugin")

    // Google Services
    id("com.google.gms.google-services")
}

dependencies {

    // Core library desugaring
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    // Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:34.14.0"))

    // Firebase Analytics
    implementation("com.google.firebase:firebase-analytics")

    // Tambahin Firebase lain kalau perlu
    // implementation("com.google.firebase:firebase-auth")
    // implementation("com.google.firebase:firebase-messaging")
}

android {
    namespace = "com.example.myorganizationapp"

    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.myorganizationapp"

        minSdk = 23
        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}