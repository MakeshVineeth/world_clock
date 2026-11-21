# 1. Feature-First Clean Architecture with Strict Domain Isolation

Date: 2026-11-21

## Status
Accepted

## Context
The original application mixed HTTP network calls, `SharedPreferences` reads/writes, `Timer` lifecycle management, and UI widgets inside `lib/home.dart`, `lib/display_date.dart`, `lib/loader.dart`, `lib/locations_list/locations.dart`, and `lib/services/data_methods.dart`. This tight coupling prevented deterministic unit testing, risked memory/timer leaks, and blocked UI rendering on slow network calls.

## Decision
Reorganize the codebase under `lib/src/` into Feature-First Clean Architecture (`core/`, `app/`, `features/clock/`, `features/locations/`) split into `domain/`, `data/`, and `presentation/` layers:
- `domain/` contains pure-Dart immutable entities (`WorldTime`, `TimezoneLocation`), repository contracts (`ClockRepository`, `LocationRepository`), service contracts (`AppLifecycleService`), and domain services (`TimezoneSearchService`) with zero imports from `package:flutter/`, `package:material_ui/`, `package:cupertino_ui/`, `dart:io`, or third-party platform/HTTP plugins.
- `data/` implements instant offline IANA timezone calculation (`LocalTimezoneDataSource` using `package:timezone`), HTTPS fallback communication (`TimeApiClient`), JSON asset loading (`AssetCountryFlagSource`), `SharedPreferences` storage (`SharedPreferencesStorage`), and Android/desktop exit channels (`PlatformAppLifecycleService`).
- `presentation/` uses `ChangeNotifier` controllers (`ClockController`, `LocationsController`) wired via `MultiProvider` and consumed narrowly via `context.select`, `Consumer`, and `context.read`.

## Consequences
- Automated tests enforce domain layer purity (`test/architecture/domain_layer_isolation_test.dart`).
- Startup, timezone switching, and search operate in `< 2 ms` locally without blocking on remote HTTP latency, while preserving `TimeApiClient` as a tested HTTPS fallback.
- Timer and controller lifecycles are centralized in controllers with deterministic disposal.
