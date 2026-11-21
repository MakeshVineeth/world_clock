import 'package:flutter_clock/src/core/logging/app_logger.dart';
import 'package:flutter_clock/src/core/security/input_validator.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Instant offline IANA timezone resolver backed by the bundled tz database.
class LocalTimezoneDataSource {
  static bool _initialized = false;

  const LocalTimezoneDataSource();

  static void ensureInitialized() {
    if (_initialized) {
      return;
    }
    tz_data.initializeTimeZones();
    _initialized = true;
  }

  DateTime? nowInTimeZone(String timeZoneId) {
    final String sanitized = timeZoneId.trim();
    if (!InputValidator.isValidTimeZoneId(sanitized)) {
      return null;
    }
    ensureInitialized();

    try {
      final tz.Location location = _resolveLocation(sanitized);
      final tz.TZDateTime tzNow = tz.TZDateTime.now(location);
      return DateTime(
        tzNow.year,
        tzNow.month,
        tzNow.day,
        tzNow.hour,
        tzNow.minute,
        tzNow.second,
        tzNow.millisecond,
      );
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Local timezone lookup failed for $sanitized',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  tz.Location _resolveLocation(String zoneId) {
    final Map<String, tz.Location> db = tz.timeZoneDatabase.locations;
    final tz.Location? direct = db[zoneId];
    if (direct != null) {
      return direct;
    }
    final String? canonical = _legacyAliases[zoneId];
    if (canonical != null && db.containsKey(canonical)) {
      return db[canonical]!;
    }
    return tz.getLocation(zoneId);
  }

  static const Map<String, String> _legacyAliases = <String, String>{
    'America/Buenos_Aires': 'America/Argentina/Buenos_Aires',
    'America/Catamarca': 'America/Argentina/Catamarca',
    'America/Cordoba': 'America/Argentina/Cordoba',
    'America/Jujuy': 'America/Argentina/Jujuy',
    'America/Mendoza': 'America/Argentina/Mendoza',
    'America/Godthab': 'America/Nuuk',
    'America/Indianapolis': 'America/Indiana/Indianapolis',
    'America/Louisville': 'America/Kentucky/Louisville',
    'America/Montreal': 'America/Toronto',
    'Asia/Calcutta': 'Asia/Kolkata',
    'Asia/Katmandu': 'Asia/Kathmandu',
    'Asia/Rangoon': 'Asia/Yangon',
    'Asia/Saigon': 'Asia/Ho_Chi_Minh',
    'Australia/Currie': 'Australia/Hobart',
    'Europe/Kiev': 'Europe/Kyiv',
    'Europe/Uzhgorod': 'Europe/Kyiv',
    'Europe/Zaporozhye': 'Europe/Kyiv',
    'Pacific/Enderbury': 'Pacific/Kanton',
    'Pacific/Johnston': 'Pacific/Honolulu',
  };
}
