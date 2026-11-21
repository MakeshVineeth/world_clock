# 2. Pure-Flutter UI Replacements and `material_ui` Migration

Date: 2026-11-21

## Status
Accepted

## Context
The legacy `pubspec.yaml` depended on unmaintained or unnecessary third-party packages (`flappy_search_bar_ns` requiring Dart 2 constraints and legacy `flutter_staggered_grid_view: 0.4.1`, `flutter_spinkit`, `fuzzy`, `octo_image`, `transparent_image`, and unused `cupertino_icons`). In addition, Flutter `3.51.0` deprecated `package:flutter/material.dart` in favor of the standalone `material_ui` package, requiring `google_fonts: ^9.0.0` for type compatibility.

## Decision
1. Remove `cupertino_icons`, `flappy_search_bar_ns`, `flutter_spinkit`, `fuzzy`, `octo_image`, and `transparent_image` from `pubspec.yaml`.
2. Replace them with native, zero-dependency Dart 3 / Flutter implementations preserving exact original visuals and interactions:
   - `TimezoneSearchView` + `TimezoneSearchService` replacing `flappy_search_bar_ns` + `fuzzy`.
   - `PulseLoadingIndicator` replacing `SpinKitPulse`.
   - `FlagAvatar` replacing `OctoImage.fromSet(OctoSet.circleAvatar)` + `kTransparentImage`.
3. Add `material_ui: ^1.11.1`, upgrade `google_fonts` to `^9.0.0`, and migrate UI imports from `package:flutter/material.dart` to `package:material_ui/material_ui.dart` alongside current official/community packages (`http: ^1.6.0`, `provider: ^6.1.5+1`, `shared_preferences: ^2.5.6`, `url_launcher: ^6.3.3`, `intl: ^0.20.2`, `country_icons: ^3.0.0`, `flutter_lints: ^6.0.0`).

## Consequences
- Eliminates all Dart 2.x transitive dependencies (`flutter_staggered_grid_view`, `stringr`) and reduces third-party surface area.
- Achieves zero deprecation warnings under Flutter `3.51.0` / Dart `3.15.0`.
- All UI replacements match original layout, animation timing, colors, and typography (`Aladin` 50px).
