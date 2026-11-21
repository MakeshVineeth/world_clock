/// Application-wide constants for Flutter Clock.
abstract final class AppConstants {
  static const String appName = 'Flutter Clock';
  static const String appVersion = '3.2.0';
  static const String appLegalese =
      'A modern World Clock app built with Flutter. '
      'Resolves global timezones instantly using the embedded IANA Time Zone '
      'Database with timeapi.io HTTPS fallback.';

  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.makeshtech.clock';
  static const String githubUrl =
      'https://github.com/MakeshVineeth/world_clock';

  static const String timeApiHost = 'timeapi.io';
  static const String availableTimeZonesPath =
      '/api/timezone/availabletimezones';
  static const String currentTimePath = '/api/time/current/zone';
  static const Duration apiTimeout = Duration(seconds: 4);

  static const String defaultLocation = 'Asia, Kolkata';
  static const String defaultTimeZoneId = 'Asia/Kolkata';
  static const String defaultFlagAsset = 'icons/flags/png100px/in.png';

  static const String dayBackgroundAsset = 'images/day.gif';
  static const String nightBackgroundAsset = 'images/night.gif';
  static const String appIconAsset = 'images/time_zone.png';
  static const String countriesAssetPath = 'assets/countries.json';

  static const String exitMethodChannel = 'android_app_exit';
  static const String exitMethodName = 'sendToBackground';

  static const Duration routeFadeDuration = Duration(milliseconds: 200);
  static const Duration loaderSwitchDuration = Duration(milliseconds: 250);
  static const Duration locationsCrossFadeDuration = Duration(
    milliseconds: 200,
  );
  static const Duration searchDebounceDuration = Duration.zero;
}
