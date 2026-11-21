# 3. Android 16 (API 36), Edge-to-Edge, and Gradle/Kotlin Modernization

Date: 2026-11-21

## Status
Accepted

## Context
Google Play requires targeting Android 16 (API 36), full edge-to-edge rendering with proper display cutout handling, and 16 KB / NDK full debug symbol compatibility. The legacy Gradle configuration (`Gradle 8.12`, `AGP 8.9.0`, deprecated `buildDir` assignments, legacy `lintOptions`, unclosed `FileInputStream` on `key.properties`, `minSdkVersion flutter.minSdkVersion`) also triggered deprecation and cross-drive Windows Kotlin incremental compilation failures (`shared_preferences_android`, `url_launcher_android`).

## Decision
1. Target `compileSdk = 36`, `targetSdk = 36`, and `minSdk = 24`, with `ndk.debugSymbolLevel = "FULL"`, R8 code shrinking (`minifyEnabled true`), and resource shrinking (`shrinkResources true`) in release builds.
2. Upgrade the Android build toolchain to Gradle `9.5.0`, AGP `9.3.1`, and Kotlin Gradle Plugin `2.4.20`. Retain `android.builtInKotlin=false` and `android.newDsl=false` in `android/gradle.properties` for official Flutter plugin compatibility alongside `kotlin.incremental=false` so cross-drive Windows builds (`D:` workspace + `C:` Pub cache) compile reliably with zero warnings, without committing any machine-specific `org.gradle.java.home`.
3. Enable edge-to-edge consistently across native Android and Flutter:
   - `WindowCompat.setDecorFitsSystemWindows(window, false)` in `MainActivity.kt` (replacing deprecated `Handler()` with `Handler(Looper.getMainLooper())`).
   - `SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge)` in `main.dart`.
   - `AnnotatedRegion<SystemUiOverlayStyle>` on `LoaderScreen`, `HomeScreen`, and `LocationsScreen`.
   - `<item name="android:windowLayoutInDisplayCutoutMode">shortEdges</item>` across `values`, `values-night`, `values-v31`, and `values-night-v31` styles without deprecated bar color attributes.

## Consequences
- Release APK and AAB builds produce zero Gradle, AGP, and Kotlin warnings.
- Android 16 edge-to-edge insets, notches, and gesture navigation bars render cleanly without clipping.
- Release builds never silently fall back to `signingConfigs.debug` when `android/key.properties` is absent.
