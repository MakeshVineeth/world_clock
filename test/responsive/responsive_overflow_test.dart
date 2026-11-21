import 'package:flutter_clock/src/core/security/external_url_launcher.dart';
import 'package:flutter_clock/src/core/theme/app_theme.dart';
import 'package:flutter_clock/src/features/clock/domain/entities/world_time.dart';
import 'package:flutter_clock/src/features/clock/domain/repositories/clock_repository.dart';
import 'package:flutter_clock/src/features/clock/domain/services/app_lifecycle_service.dart';
import 'package:flutter_clock/src/features/clock/presentation/controllers/clock_controller.dart';
import 'package:flutter_clock/src/features/clock/presentation/screens/home_screen.dart';
import 'package:flutter_clock/src/features/clock/presentation/screens/loader_screen.dart';
import 'package:flutter_clock/src/features/locations/domain/entities/timezone_location.dart';
import 'package:flutter_clock/src/features/locations/domain/repositories/location_repository.dart';
import 'package:flutter_clock/src/features/locations/presentation/controllers/locations_controller.dart';
import 'package:flutter_clock/src/features/locations/presentation/screens/locations_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class _StubClockRepository implements ClockRepository {
  @override
  Future<WorldTime> fetchCurrentTime({
    required String location,
    required String url,
    required String flag,
  }) async => loadDefaultOrSavedClock();

  @override
  Future<WorldTime> loadDefaultOrSavedClock() async => const WorldTime(
    location: 'America, Argentina, Comodoro Rivadavia',
    url: 'America/Argentina/Comodoro_Rivadavia',
    flag: 'icons/flags/png100px/ar.png',
    date: '24-May-2025',
    isDayTime: true,
    time: '12:59 PM',
  );

  @override
  Future<void> saveSelectedClock(WorldTime worldTime) async {}
}

class _StubLocationRepository implements LocationRepository {
  @override
  Future<List<TimezoneLocation>> fetchAvailableLocations() async =>
      const <TimezoneLocation>[
        TimezoneLocation(
          timeZoneId: 'America/Argentina/Comodoro_Rivadavia',
          displayName: 'America, Argentina, Comodoro Rivadavia',
          flagAssetPath: 'icons/flags/png100px/ar.png',
        ),
        TimezoneLocation(
          timeZoneId: 'Asia/Kolkata',
          displayName: 'Asia, Kolkata',
          flagAssetPath: 'icons/flags/png100px/in.png',
        ),
      ];
}

class _NoopUrlLauncher implements ExternalUrlLauncher {
  @override
  Future<bool> openUrl(String rawUrl) async => true;
}

class _NoopLifecycleService implements AppLifecycleService {
  @override
  Future<void> exitApp() async {}
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  const List<Size> viewports = <Size>[
    Size(320, 568),
    Size(390, 844),
    Size(673, 841),
    Size(800, 1280),
    Size(1280, 800),
    Size(1920, 1080),
  ];

  for (final Size viewport in viewports) {
    testWidgets(
      'zero overflow on LoaderScreen, HomeScreen, and LocationsScreen at '
      '${viewport.width.toInt()}x${viewport.height.toInt()}',
      (WidgetTester tester) async {
        tester.view.physicalSize = viewport;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final ClockController uninitializedClock = ClockController(
          repository: _StubClockRepository(),
          enableAutoRefresh: false,
        );
        addTearDown(uninitializedClock.dispose);

        await tester.pumpWidget(
          MultiProvider(
            providers: <SingleChildWidget>[
              ChangeNotifierProvider<ClockController>.value(
                value: uninitializedClock,
              ),
              Provider<ExternalUrlLauncher>.value(value: _NoopUrlLauncher()),
              Provider<AppLifecycleService>.value(
                value: _NoopLifecycleService(),
              ),
              Provider<LocationRepository>.value(
                value: _StubLocationRepository(),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const LoaderScreen(),
            ),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);

        await tester.pumpAndSettle();
        expect(find.byType(HomeScreen), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Open overflow menu and About dialog to verify dialog responsiveness.
        await tester.tap(find.byIcon(Icons.more_vert));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        await tester.tap(find.text('About'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();

        // Render LocationsScreen in idle, active search, and empty states.
        final LocationsController locationsController = LocationsController(
          repository: _StubLocationRepository(),
          debounceDuration: Duration.zero,
        );
        addTearDown(locationsController.dispose);
        await locationsController.loadLocations();

        await tester.pumpWidget(
          MultiProvider(
            providers: <SingleChildWidget>[
              ChangeNotifierProvider<ClockController>.value(
                value: uninitializedClock,
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: LocationsScreen(controller: locationsController),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        await tester.enterText(find.byType(TextField), 'kol');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 20));
        await tester.pumpAndSettle();
        expect(find.text('Cancel'), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.enterText(find.byType(TextField), 'nomatch');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 20));
        await tester.pumpAndSettle();
        expect(find.text('No Results'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
