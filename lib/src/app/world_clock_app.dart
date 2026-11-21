import 'package:flutter_clock/src/core/constants/app_constants.dart';
import 'package:flutter_clock/src/core/security/external_url_launcher.dart';
import 'package:flutter_clock/src/core/storage/key_value_storage.dart';
import 'package:flutter_clock/src/core/theme/app_theme.dart';
import 'package:flutter_clock/src/features/clock/data/datasources/time_api_client.dart';
import 'package:flutter_clock/src/features/clock/data/repositories/clock_repository_impl.dart';
import 'package:flutter_clock/src/features/clock/data/services/app_lifecycle_service.dart';
import 'package:flutter_clock/src/features/clock/domain/repositories/clock_repository.dart';
import 'package:flutter_clock/src/features/clock/domain/services/app_lifecycle_service.dart';
import 'package:flutter_clock/src/features/clock/presentation/controllers/clock_controller.dart';
import 'package:flutter_clock/src/features/clock/presentation/screens/home_screen.dart';
import 'package:flutter_clock/src/features/clock/presentation/screens/loader_screen.dart';
import 'package:flutter_clock/src/features/locations/data/datasources/country_flag_asset_source.dart';
import 'package:flutter_clock/src/features/locations/data/repositories/location_repository_impl.dart';
import 'package:flutter_clock/src/features/locations/domain/repositories/location_repository.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// Root widget wiring Clean Architecture dependencies and navigation routes.
class WorldClockApp extends StatelessWidget {
  final ClockRepository? clockRepository;
  final LocationRepository? locationRepository;
  final ExternalUrlLauncher? urlLauncher;
  final AppLifecycleService? lifecycleService;
  final bool enableAutoRefresh;

  const WorldClockApp({
    super.key,
    this.clockRepository,
    this.locationRepository,
    this.urlLauncher,
    this.lifecycleService,
    this.enableAutoRefresh = true,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <SingleChildWidget>[
        Provider<TimeApiClient>(
          create: (_) => TimeApiClient(),
          dispose: (_, TimeApiClient client) => client.close(),
        ),
        Provider<KeyValueStorage>(
          create: (_) => SharedPreferencesStorage(),
        ),
        Provider<CountryFlagAssetSource>(
          create: (_) => AssetCountryFlagSource(),
        ),
        Provider<ExternalUrlLauncher>.value(
          value: urlLauncher ?? const UrlLauncherService(),
        ),
        Provider<AppLifecycleService>(
          create: (_) => lifecycleService ?? PlatformAppLifecycleService(),
        ),
        Provider<ClockRepository>(
          create: (BuildContext context) =>
              clockRepository ??
              ClockRepositoryImpl(
                apiClient: context.read<TimeApiClient>(),
                storage: context.read<KeyValueStorage>(),
              ),
        ),
        Provider<LocationRepository>(
          create: (BuildContext context) =>
              locationRepository ??
              LocationRepositoryImpl(
                apiClient: context.read<TimeApiClient>(),
                countryFlagSource: context.read<CountryFlagAssetSource>(),
              ),
        ),
        ChangeNotifierProvider<ClockController>(
          create: (BuildContext context) => ClockController(
            repository: context.read<ClockRepository>(),
            enableAutoRefresh: enableAutoRefresh,
          ),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.light,
        routes: <String, WidgetBuilder>{
          '/': (_) => const LoaderScreen(),
          '/home': (_) => const HomeScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
