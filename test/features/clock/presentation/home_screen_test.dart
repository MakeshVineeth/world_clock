import 'package:flutter_clock/src/core/constants/app_constants.dart';
import 'package:flutter_clock/src/core/security/external_url_launcher.dart';
import 'package:flutter_clock/src/core/theme/app_theme.dart';
import 'package:flutter_clock/src/core/widgets/flag_avatar.dart';
import 'package:flutter_clock/src/features/clock/domain/entities/world_time.dart';
import 'package:flutter_clock/src/features/clock/domain/repositories/clock_repository.dart';
import 'package:flutter_clock/src/features/clock/domain/services/app_lifecycle_service.dart';
import 'package:flutter_clock/src/features/clock/presentation/controllers/clock_controller.dart';
import 'package:flutter_clock/src/features/clock/presentation/screens/home_screen.dart';
import 'package:flutter_clock/src/features/clock/presentation/widgets/home_overflow_menu.dart';
import 'package:flutter_clock/src/features/locations/domain/entities/timezone_location.dart';
import 'package:flutter_clock/src/features/locations/domain/repositories/location_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class _FakeClockRepository implements ClockRepository {
  WorldTime current = const WorldTime(
    location: 'Asia, Kolkata',
    url: 'Asia/Kolkata',
    flag: 'icons/flags/png100px/in.png',
    date: '24-May-2025',
    isDayTime: true,
    secondsLeft: 30,
    time: '3:00 PM',
  );

  WorldTime refreshedResult = const WorldTime(
    location: 'Asia, Kolkata',
    url: 'Asia/Kolkata',
    flag: 'icons/flags/png100px/in.png',
    date: '24-May-2025',
    isDayTime: false,
    secondsLeft: 30,
    time: '9:15 PM',
  );

  int fetchCount = 0;

  @override
  Future<WorldTime> fetchCurrentTime({
    required String location,
    required String url,
    required String flag,
  }) async {
    fetchCount++;
    return refreshedResult;
  }

  @override
  Future<WorldTime> loadDefaultOrSavedClock() async => current;

  @override
  Future<void> saveSelectedClock(WorldTime worldTime) async {}
}

class _FakeLocationRepository implements LocationRepository {
  @override
  Future<List<TimezoneLocation>> fetchAvailableLocations() async =>
      const <TimezoneLocation>[
        TimezoneLocation(
          timeZoneId: 'Asia/Kolkata',
          displayName: 'Asia, Kolkata',
          flagAssetPath: 'icons/flags/png100px/in.png',
        ),
      ];
}

class _RecordingUrlLauncher implements ExternalUrlLauncher {
  final List<String> launchedUrls = <String>[];

  @override
  Future<bool> openUrl(String rawUrl) async {
    launchedUrls.add(rawUrl);
    return true;
  }
}

class _RecordingLifecycleService implements AppLifecycleService {
  int exitCalls = 0;

  @override
  Future<void> exitApp() async {
    exitCalls++;
  }
}

Future<void> _pumpHome(
  WidgetTester tester, {
  required ClockController clockController,
  _RecordingUrlLauncher? urlLauncher,
  _RecordingLifecycleService? lifecycleService,
  LocationRepository? locationRepository,
}) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<ClockController>.value(value: clockController),
        Provider<ExternalUrlLauncher>.value(
          value: urlLauncher ?? _RecordingUrlLauncher(),
        ),
        Provider<AppLifecycleService>.value(
          value: lifecycleService ?? _RecordingLifecycleService(),
        ),
        Provider<LocationRepository>.value(
          value: locationRepository ?? _FakeLocationRepository(),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('HomeScreen', () {
    testWidgets('renders location, time, date, flag, day/night GIF, and no forbidden UI', (
      WidgetTester tester,
    ) async {
      final _FakeClockRepository repo = _FakeClockRepository();
      final ClockController controller = ClockController(
        repository: repo,
        enableAutoRefresh: false,
      );
      addTearDown(controller.dispose);
      await controller.initialize();

      await _pumpHome(tester, clockController: controller);

      expect(find.text('Asia, Kolkata'), findsOneWidget);
      expect(find.text('3:00 PM'), findsOneWidget);
      expect(find.text('24-May-2025'), findsOneWidget);
      expect(find.byType(FlagAvatar), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);

      // Negative assertions: ensure zero unrequested UI elements exist.
      expect(find.byType(TextField), findsNothing);
      expect(find.textContaining('Mail', findRichText: true), findsNothing);
      expect(find.textContaining('Battery', findRichText: true), findsNothing);
      expect(
        find.textContaining('DontKillMyApp', findRichText: true),
        findsNothing,
      );
      expect(find.text('Settings'), findsNothing);

      final Container bgContainer = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(HomeScreen),
              matching: find.byType(Container),
            )
            .first,
      );
      final BoxDecoration decoration = bgContainer.decoration! as BoxDecoration;
      final AssetImage dayAsset = decoration.image!.image as AssetImage;
      expect(dayAsset.assetName, equals(AppConstants.dayBackgroundAsset));

      // Pull to refresh switches to night background & updated time.
      await tester.fling(
        find.byType(SingleChildScrollView),
        const Offset(0, 300),
        1000,
      );
      await tester.pumpAndSettle();

      expect(repo.fetchCount, equals(1));
      expect(find.text('9:15 PM'), findsOneWidget);

      final Container nightContainer = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(HomeScreen),
              matching: find.byType(Container),
            )
            .first,
      );
      final BoxDecoration nightDecoration =
          nightContainer.decoration! as BoxDecoration;
      final AssetImage nightAsset = nightDecoration.image!.image as AssetImage;
      expect(nightAsset.assetName, equals(AppConstants.nightBackgroundAsset));
    });

    testWidgets('overflow menu contains exact 5 items and dispatches actions', (
      WidgetTester tester,
    ) async {
      final _FakeClockRepository repo = _FakeClockRepository();
      final ClockController controller = ClockController(
        repository: repo,
        enableAutoRefresh: false,
      );
      addTearDown(controller.dispose);
      await controller.initialize();

      final _RecordingUrlLauncher launcher = _RecordingUrlLauncher();
      final _RecordingLifecycleService lifecycle = _RecordingLifecycleService();

      await _pumpHome(
        tester,
        clockController: controller,
        urlLauncher: launcher,
        lifecycleService: lifecycle,
      );

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.byType(PopupMenuItem<HomeMenuAction>), findsNWidgets(5));
      expect(find.text('Change Location'), findsOneWidget);
      expect(find.text('Play Store'), findsOneWidget);
      expect(find.text('GitHub'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
      expect(find.text('Exit'), findsOneWidget);
      expect(find.textContaining('Mail', findRichText: true), findsNothing);
      expect(find.text('Settings'), findsNothing);

      // Play Store
      await tester.tap(find.text('Play Store'));
      await tester.pumpAndSettle();
      expect(launcher.launchedUrls, contains(AppConstants.playStoreUrl));

      // GitHub
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('GitHub'));
      await tester.pumpAndSettle();
      expect(launcher.launchedUrls, contains(AppConstants.githubUrl));

      // About
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('About'));
      await tester.pumpAndSettle();
      expect(find.text(AppConstants.appName), findsOneWidget);
      expect(find.text(AppConstants.appVersion), findsOneWidget);
      expect(find.text(AppConstants.appLegalese), findsOneWidget);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      // Exit
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Exit'));
      await tester.pumpAndSettle();
      expect(lifecycle.exitCalls, equals(1));

      // Change Location navigation
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Change Location'));
      await tester.pumpAndSettle();
      expect(find.text('Choose Location'), findsOneWidget);
    });
  });
}
