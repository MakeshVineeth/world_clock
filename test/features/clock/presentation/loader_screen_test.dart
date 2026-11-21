import 'dart:async';

import 'package:flutter_clock/src/app/world_clock_app.dart';
import 'package:flutter_clock/src/core/security/external_url_launcher.dart';
import 'package:flutter_clock/src/core/widgets/pulse_loading_indicator.dart';
import 'package:flutter_clock/src/features/clock/domain/entities/world_time.dart';
import 'package:flutter_clock/src/features/clock/domain/repositories/clock_repository.dart';
import 'package:flutter_clock/src/features/clock/domain/services/app_lifecycle_service.dart';
import 'package:flutter_clock/src/features/locations/domain/entities/timezone_location.dart';
import 'package:flutter_clock/src/features/locations/domain/repositories/location_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

class _DelayedClockRepository implements ClockRepository {
  final Completer<WorldTime> completer = Completer<WorldTime>();

  @override
  Future<WorldTime> fetchCurrentTime({
    required String location,
    required String url,
    required String flag,
  }) async => completer.future;

  @override
  Future<WorldTime> loadDefaultOrSavedClock() => completer.future;

  @override
  Future<void> saveSelectedClock(WorldTime worldTime) async {}
}

class _StubLocationRepository implements LocationRepository {
  @override
  Future<List<TimezoneLocation>> fetchAvailableLocations() async =>
      const <TimezoneLocation>[];
}

class _StubUrlLauncher implements ExternalUrlLauncher {
  @override
  Future<bool> openUrl(String rawUrl) async => true;
}

class _StubLifecycleService implements AppLifecycleService {
  @override
  Future<void> exitApp() async {}
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('LoaderScreen displays pulse loader then transitions to HomeScreen', (
    WidgetTester tester,
  ) async {
    final _DelayedClockRepository repository = _DelayedClockRepository();

    await tester.pumpWidget(
      WorldClockApp(
        clockRepository: repository,
        locationRepository: _StubLocationRepository(),
        urlLauncher: _StubUrlLauncher(),
        lifecycleService: _StubLifecycleService(),
        enableAutoRefresh: false,
      ),
    );
    await tester.pump();

    expect(find.byType(PulseLoadingIndicator), findsOneWidget);
    final Scaffold loaderScaffold = tester.widget<Scaffold>(
      find.byType(Scaffold),
    );
    expect(loaderScaffold.backgroundColor, equals(Colors.blueAccent));

    repository.completer.complete(
      const WorldTime(
        location: 'Asia, Kolkata',
        url: 'Asia/Kolkata',
        flag: 'icons/flags/png100px/in.png',
        date: '24-May-2025',
        isDayTime: true,
        secondsLeft: 20,
        time: '3:00 PM',
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Asia, Kolkata'), findsOneWidget);
    expect(find.text('3:00 PM'), findsOneWidget);
    expect(find.text('24-May-2025'), findsOneWidget);
    expect(find.byType(PulseLoadingIndicator), findsNothing);
  });
}
