import 'package:flutter_clock/src/core/theme/app_theme.dart';
import 'package:flutter_clock/src/features/clock/domain/entities/world_time.dart';
import 'package:flutter_clock/src/features/clock/domain/repositories/clock_repository.dart';
import 'package:flutter_clock/src/features/clock/presentation/controllers/clock_controller.dart';
import 'package:flutter_clock/src/features/locations/domain/entities/timezone_location.dart';
import 'package:flutter_clock/src/features/locations/domain/repositories/location_repository.dart';
import 'package:flutter_clock/src/features/locations/presentation/controllers/locations_controller.dart';
import 'package:flutter_clock/src/features/locations/presentation/screens/locations_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class _FakeClockRepository implements ClockRepository {
  String? selectedUrl;

  @override
  Future<WorldTime> fetchCurrentTime({
    required String location,
    required String url,
    required String flag,
  }) async {
    selectedUrl = url;
    return WorldTime(
      location: location,
      url: url,
      flag: flag,
      date: '24-May-2025',
      isDayTime: true,
      time: '4:30 PM',
    );
  }

  @override
  Future<WorldTime> loadDefaultOrSavedClock() async => const WorldTime(
    location: 'Asia, Kolkata',
    url: 'Asia/Kolkata',
    flag: 'icons/flags/png100px/in.png',
    date: '24-May-2025',
    isDayTime: true,
    time: '3:00 PM',
  );

  @override
  Future<void> saveSelectedClock(WorldTime worldTime) async {}
}

class _FakeLocationRepository implements LocationRepository {
  final List<TimezoneLocation> items;

  _FakeLocationRepository(this.items);

  @override
  Future<List<TimezoneLocation>> fetchAvailableLocations() async => items;
}

void main() {
  const List<TimezoneLocation> sampleLocations = <TimezoneLocation>[
    TimezoneLocation(
      timeZoneId: 'Asia/Kolkata',
      displayName: 'Asia, Kolkata',
      flagAssetPath: 'icons/flags/png100px/in.png',
    ),
    TimezoneLocation(
      timeZoneId: 'America/New_York',
      displayName: 'America, New York',
      flagAssetPath: 'icons/flags/png100px/us.png',
    ),
  ];

  group('LocationsScreen', () {
    testWidgets('displays suggestions, handles search/cancel/no results, and excludes unrequested UI', (
      WidgetTester tester,
    ) async {
      final _FakeClockRepository clockRepo = _FakeClockRepository();
      final ClockController clockController = ClockController(
        repository: clockRepo,
        enableAutoRefresh: false,
      );
      addTearDown(clockController.dispose);
      await clockController.initialize();

      final LocationsController locationsController = LocationsController(
        repository: _FakeLocationRepository(sampleLocations),
        debounceDuration: const Duration(milliseconds: 50),
      );
      addTearDown(locationsController.dispose);
      await locationsController.loadLocations();

      await tester.pumpWidget(
        MultiProvider(
          providers: <SingleChildWidget>[
            ChangeNotifierProvider<ClockController>.value(
              value: clockController,
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: LocationsScreen(controller: locationsController),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Choose Location'), findsOneWidget);
      expect(find.text('Search Timezones'), findsOneWidget);
      expect(find.text('Asia, Kolkata'), findsOneWidget);
      expect(find.text('America, New York'), findsOneWidget);
      expect(find.text('Cancel'), findsNothing);

      // Negative assertions: ensure zero unrequested UI elements exist.
      expect(find.textContaining('Mail', findRichText: true), findsNothing);
      expect(find.textContaining('Battery', findRichText: true), findsNothing);
      expect(find.text('Settings'), findsNothing);
      expect(find.byType(BottomNavigationBar), findsNothing);

      // Fewer than 2 characters stays on full list.
      await tester.enterText(find.byType(TextField), 'k');
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Asia, Kolkata'), findsOneWidget);
      expect(find.text('America, New York'), findsOneWidget);
      expect(find.text('Cancel'), findsNothing);

      // >= 2 characters filters list and displays Cancel.
      await tester.enterText(find.byType(TextField), 'kol');
      await tester.pump();
      expect(find.text('Cancel'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 80));
      await tester.pumpAndSettle();

      expect(find.text('Asia, Kolkata'), findsOneWidget);
      expect(find.text('America, New York'), findsNothing);

      // Non-matching query displays No Results.
      await tester.enterText(find.byType(TextField), 'zzzz');
      await tester.pump(const Duration(milliseconds: 80));
      await tester.pumpAndSettle();
      expect(find.text('No Results'), findsOneWidget);

      // Cancel clears query and restores suggestions.
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('America, New York'), findsOneWidget);
      expect(find.text('Cancel'), findsNothing);
    });

    testWidgets('selecting a location updates ClockController and pops route', (
      WidgetTester tester,
    ) async {
      final _FakeClockRepository clockRepo = _FakeClockRepository();
      final ClockController clockController = ClockController(
        repository: clockRepo,
        enableAutoRefresh: false,
      );
      addTearDown(clockController.dispose);
      await clockController.initialize();

      final LocationsController locationsController = LocationsController(
        repository: _FakeLocationRepository(sampleLocations),
        debounceDuration: Duration.zero,
      );
      addTearDown(locationsController.dispose);
      await locationsController.loadLocations();

      await tester.pumpWidget(
        MultiProvider(
          providers: <SingleChildWidget>[
            ChangeNotifierProvider<ClockController>.value(
              value: clockController,
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Builder(
              builder: (BuildContext context) => ElevatedButton(
                onPressed: () => Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        LocationsScreen(controller: locationsController),
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Choose Location'), findsOneWidget);

      await tester.tap(find.text('America, New York'));
      await tester.pumpAndSettle();

      expect(clockRepo.selectedUrl, equals('America/New_York'));
      expect(clockController.currentClock.location, equals('America, New York'));
      expect(find.text('Open'), findsOneWidget);
    });
  });
}
