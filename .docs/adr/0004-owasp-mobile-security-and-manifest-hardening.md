# 4. OWASP Mobile Top 10 and Merged Release Manifest Hardening

Date: 2026-11-21

## Status
Accepted

## Context
Preparing an existing Play Store app for modern security expectations requires eliminating implicit backup exposure, enforcing HTTPS-only transport, validating untrusted API/storage/navigation inputs, constraining external URL launching, and auditing the final merged release manifest for plugin-injected permissions or exported components.

## Decision
1. **Network & Data Protection**:
   - Configure `android/app/src/main/res/xml/network_security_config.xml` with `cleartextTrafficPermitted="false"` and system certificate trust anchors only.
   - Set `android:allowBackup="false"` in `android/app/src/main/AndroidManifest.xml`.
   - Keep `android.permission.INTERNET` for `https://timeapi.io` fallback requests and Google Fonts (`Plus Jakarta Sans` / `Outfit`) CDN delivery.
2. **Input Validation & URI Hardening**:
   - Validate timezone IDs, sanitize search queries, allowlist vector SVG and PNG flag asset paths (`icons/flags/svg/[a-z]{2}.svg` and `icons/flags/png(100|250|1000)px/[a-z]{2}.png`), and restrict external links to `https` (non-empty host, empty `userInfo`) and `market` schemes via `InputValidator` and `UrlLauncherService` (launching in `LaunchMode.externalApplication` with no embedded JS WebView).
   - Restrict Android `<queries>` to `android.intent.action.VIEW` with `android:scheme="https"`.
3. **Merged Release Manifest & Repo Hygiene**:
   - Inspect `build/app/intermediates/merged_manifest/release/processReleaseMainManifest/AndroidManifest.xml` and maintain `android/app/src/release/AndroidManifest.xml` to strip any unnecessary plugin-injected permissions or exported components.
   - Exclude all keystores, `key.properties`, `local.properties`, symbol/obfuscation maps, and temporary screenshots in `.gitignore`.

## Consequences
- Mitigates insecure communication (M5), inadequate supply chain/manifest exposure (M2/M8), and improper input validation (M4).
- Prevents accidental inclusion of signing secrets or debug permissions in Play Store artifacts.
