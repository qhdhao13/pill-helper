plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.pill_helper"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // 启用 core library desugaring（支持新版本API）
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.pill_helper"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // 只支持必要架构（可节省 70MB）
        ndk {
            abiFilters.addAll(listOf("arm64-v8a", "armeabi-v7a"))
        }
    }

    buildTypes {
        release {
            // 启用代码压缩和资源缩减（优化APK大小）
            isMinifyEnabled = true
            isShrinkResources = true
            
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            
            // TODO: Add your own signing config for the release build.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
    
    // 打包选项：移除调试库
    packaging {
        jniLibs {
            excludes += listOf(
                "lib/arm64-v8a/libVkLayer_khronos_validation.so",
                "lib/armeabi-v7a/libVkLayer_khronos_validation.so"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // 添加 core library desugaring 依赖
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
