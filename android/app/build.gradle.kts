plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.myapp"
    compileSdk = Integer.parseInt(findProperty("android.compileSdkVersion").toString())
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    flavorDimensions += listOf("app", "environment")

    defaultConfig {
        applicationId = "com.example.myapp"
        minSdk = Integer.parseInt(findProperty("android.minSdkVersion").toString())
        targetSdk = Integer.parseInt(findProperty("android.targetSdkVersion").toString())
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    productFlavors {
        create("dev") {
            dimension = "environment"
        }

        create("prod") {
            dimension = "environment"
        }

        create("admin") {
            dimension = "app"
            applicationId = "com.wifi.admin"
            versionNameSuffix = "-admin"
            resValue("string", "app_name", "Admin Wifi")
        }

        create("user") {
            dimension = "app"
            applicationId = "com.wifi.user"
            versionNameSuffix = "-user"
            resValue("string", "app_name", "User Wifi")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}