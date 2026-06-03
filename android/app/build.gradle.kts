plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.wifi.admin"
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
        applicationId = "com.wifi.admin"
        minSdk = Integer.parseInt(findProperty("android.minSdkVersion").toString())
        targetSdk = Integer.parseInt(findProperty("android.targetSdkVersion").toString())
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
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

    sourceSets {
        getByName("admin") {
            res.srcDirs("src/admin/res")
        }
        getByName("user") {
            res.srcDirs("src/user/res")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
           
        }
    }
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("com.google.android.gms:play-services-ads:23.0.0")
}

flutter {
    source = "../.."
}
