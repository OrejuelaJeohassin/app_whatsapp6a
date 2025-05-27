plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.app_whatsapp6a"
    compileSdk = flutter.compileSdkVersion.toInt()  // Asegúrate de convertirlo a Int
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.app_whatsapp6a"
        minSdk = flutter.minSdkVersion.toInt()  // Conversión a Int
        targetSdk = flutter.targetSdkVersion.toInt()  // Conversión a Int
        versionCode = flutter.versionCode?.toInt() ?: 1  // Manejo de nulo
        versionName = flutter.versionName ?: "1.0.0"  // Manejo de nulo
        
        // Configuración para multidex si es necesario
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // Configuración de ofuscación y optimización
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            
            // Configuración de firma (reemplaza con tus credenciales)
            signingConfig = signingConfigs.getByName("debug")  // Temporal para desarrollo
            // signingConfig = signingConfigs.create("release") // Para producción
        }
        debug {
            isDebuggable = true
        }
    }

    // Configuración para evitar conflictos de arquitectura
    splits {
        abi {
        isEnable = false
      }
    }

}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")  // Necesario si usas multidex
}
