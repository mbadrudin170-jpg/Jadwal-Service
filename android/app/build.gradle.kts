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
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    // diubah: Menambahkan dimensi 'environment' untuk memisahkan dev dan prod.
    flavorDimensions += listOf("app", "environment")

    defaultConfig {
        applicationId = "com.example.myapp"
        minSdk = Integer.parseInt(findProperty("android.minSdkVersion").toString())
        targetSdk = Integer.parseInt(findProperty("android.targetSdkVersion").toString())
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    // diubah: Mengkonfigurasi productFlavors untuk menjadi multi-dimensi.
    productFlavors {
        // Lingkungan Pengembangan (dev)
        create("dev") {
            dimension = "environment"
        }

        // Lingkungan Produksi (prod)
        create("prod") {
            dimension = "environment"
        }

        // Aplikasi Admin
        create("admin") {
            dimension = "app"
            applicationId = "com.wifi.admin"
            versionNameSuffix = "-admin"
        }

        // Aplikasi User
        create("user") {
            dimension = "app"
            applicationId = "com.wifi.user"
            versionNameSuffix = "-user"
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
