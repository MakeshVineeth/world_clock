# 2. Pure-Flutter UI Replacements, Local IANA Timezone Engine, Vector Graphics, and `material_ui` Migration

Date: 2026-11-21

## Status
Accepted

## Context
1. The legacy `pubspec.yaml` depended on unmaintained or unnecessary third-party packages (`flappy_search_bar_ns` requiring Dart 2 constraints and legacy `flutter_staggered_grid_view: 0.4.1`, `flutter_spinkit`, `fuzzy`, `octo_image`, `transparent_image`, and unused `cupertino_icons`).
2. Flutter `3.51.0` deprecated `package:flutter/material.dart` in favor of the standalone `material_ui` package, requiring `google_fonts: ^9.0.0`.
3. Runtime testing on physical QHD+ Android 16 hardware revealed three UX/performance bottlenecks in the legacy assets and API approach:
   - `timeapi.io` exhibited multi-second latency and intermittent `502 Bad Gateway` errors, and returned ~172 uncurated alias/offset zones lacking entries in `assets/countries.json`.
   - The bundled 8-bit 256-color GIFs (`394x653` dithered `day.gif` and `1366x768` landscape `night.gif`) showed severe 8-bit dithering and landscape cropping on QHD+ portrait displays, and raster `png100px` flags lacked high-DPI sharpness.
   - Default system typography lacked hierarchy, and thin white `Aladin` numerals over the bright sun in `day.gif` reduced readability.

## Decision
1. Remove `cupertino_icons`, `flappy_search_bar_ns`, `flutter_spinkit`, `fuzzy`, `octo_image`, and `transparent_image` from `pubspec.yaml`, replacing them with native Dart 3 implementations (`TimezoneSearchView`, `TimezoneSearchService`, `PulseLoadingIndicator`, `FlagAvatar`).
2. Add the official Dart `timezone: ^0.11.2` package (`LocalTimezoneDataSource`) and preload the curated country-backed IANA catalog (`assets/countries.json` + alias resolution in `TimezoneFormatter`) so clock initialization, location switching, and synchronous search complete in `< 2 ms` with 100% flag coverage, keeping `TimeApiClient` (`https://timeapi.io`) as an HTTPS fallback.
3. Render 24-bit QHD+ native GPU day/night scenes via `HdSceneBackground` (`CustomPainter`), render infinite-DPI vector SVG country flags via `flutter_svg: ^2.5.0` (`icons/flags/svg/<cc>.svg` in `country_icons: ^3.0.0`), and supersample `images/time_zone.png` to `1024x1024`.
4. Migrate UI imports to `material_ui: ^1.11.1` with `google_fonts: ^9.0.0`, using **`Plus Jakarta Sans`** for geometric Google Sans-style UI typography and **`Outfit`** (`60px`, `FontWeight.w800`, tabular figures, 3-layer dark ambient + drop shadow) for high-contrast clock display.

## Consequences
- Eliminates all Dart 2.x transitive dependencies and achieves zero warnings on `flutter analyze` and `flutter pub outdated`.
- Delivers sub-millisecond timezone switching, zero-spinner instant search, vector-sharp flags, and 24-bit QHD+ background scenes.
