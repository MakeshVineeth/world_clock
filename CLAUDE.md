# Claude Code & Agent Instructions (`CLAUDE.md`)

This project follows the architecture, security, visual fidelity, and verification rules defined in [AGENTS.md](./AGENTS.md).

## Mandatory Pre-Commit Checks
1. **Static Analysis**: `flutter analyze` must report **0 issues**.
2. **Automated Tests**: `flutter test` must pass **100%** (domain isolation test, unit tests, widget tests with negative assertions, and cross-device overflow tests across `320x568`, `390x844`, `673x841`, `800x1280`, `1280x800`, and `1920x1080`).
3. **Android Release Build**: `flutter build apk --release` and `flutter build appbundle --release --obfuscate --split-debug-info=build/app/outputs/symbols` must complete with **0 Gradle, AGP, and Kotlin warnings**.
4. **Merged Release Manifest Check**: Inspect `build/app/intermediates/merged_manifest/release/processReleaseMainManifest/AndroidManifest.xml` after plugin or Android manifest updates.
5. **Secrets & Hygiene**: Confirm no keystores, `key.properties`, `local.properties`, stray screenshots, or credentials are staged before committing.
