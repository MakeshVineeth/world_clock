# Repository Engineering Guidelines (`AGENTS.md`)

## Architecture & Layering
- **Feature-First Clean Architecture** under `lib/src/`:
  - `lib/src/app/`: application root wiring (`WorldClockApp`) and `Provider` dependency graph.
  - `lib/src/core/`: shared `constants/`, `logging/`, `security/`, `storage/`, `theme/`, `utils/`, `widgets/`.
  - `lib/src/features/clock/` and `lib/src/features/locations/`:
    - `domain/`: pure-Dart entities, repository contracts (`abstract interface class`), and domain services (`TimezoneSearchService`). **MUST NEVER** import `package:flutter/`, `package:material_ui/`, `package:cupertino_ui/`, `dart:io`, or platform/network plugins.
    - `data/`: HTTP datasources (`TimeApiClient`), asset loaders (`AssetCountryFlagSource`), repository implementations, and platform services (`PlatformAppLifecycleService`).
    - `presentation/`: `ChangeNotifier` controllers, screens, widgets, and dialogs with zero business or network logic in widgets.
- **State Management**: `ChangeNotifier` + `Provider` with narrow listeners (`context.select`, `Consumer`, `context.read`).

## Code Quality & SOLID Rules
- **Complexity Limits**: Keep cyclomatic complexity <= 10 and cognitive complexity <= 15 per method. Extract focused single-purpose helpers with shallow nesting and early returns.
- **Resource Disposal**: Properly dispose every `AnimationController`, `CurvedAnimation`, `TextEditingController`, `FocusNode`, `Timer`, `StreamSubscription`, `http.Client`, and file stream (`.withInputStream` / `.withReader`).
- **Static Analysis**: Strict analyzer mode (`strict-casts`, `strict-inference`, `strict-raw-types`, `unawaited_futures`, `use_build_context_synchronously`, `avoid_print`, `directives_ordering`, `always_declare_return_types`, `avoid_dynamic_calls`). Maintain **0 issues** on `flutter analyze`.
- **Logging**: Zero `print()` calls in `lib/`. Use `kDebugMode`-guarded `AppLogger`.

## Security & OWASP Mobile Top 10 Rules
- **Network Security**: HTTPS-only (`timeapi.io`). Android enforces `cleartextTrafficPermitted="false"` with system trust anchors via `android/app/src/main/res/xml/network_security_config.xml`.
- **Input & URI Validation**: Validate all timezone IDs (`InputValidator.isValidTimeZoneId`), sanitize search queries (`InputValidator.sanitizeSearchQuery`), normalize and allowlist flag asset paths (`InputValidator.normalizeFlagAssetPath`), and restrict external URL launches to `https` / `market` schemes (`InputValidator.isAllowedExternalUri`).
- **Backup & Manifest Least Privilege**: `android:allowBackup="false"`, minimal `<queries>` (`https` `VIEW` only), and release manifest audit stripping unwanted plugin permissions/components in `android/app/src/release/AndroidManifest.xml`. Keep `android.permission.INTERNET` for `timeapi.io` API requests.
- **Build & Signing Hygiene**: Never commit keystores, `key.properties`, `local.properties`, or machine-specific JDK paths in `android/gradle.properties`. Never fall back to `signingConfigs.debug` in `release` builds.

## Visual & UX Fidelity Rules
- Preserve exact visual fidelity, copy, spacing, typography (`Aladin` 50px clock time), colors, corner radii (`20.0`), animated backgrounds (`day.gif`/`night.gif`), 5 overflow menu items, and About dialog wording.
- Never add unrequested screens, settings, search bars on Home, or contact links.

## Verification Commands
```sh
flutter pub get
flutter analyze
flutter test
flutter build apk --release
flutter build appbundle --release --obfuscate --split-debug-info=build/app/outputs/symbols
```
