import 'package:flutter_clock/src/core/constants/app_constants.dart';
import 'package:flutter_clock/src/core/constants/storage_keys.dart';
import 'package:flutter_clock/src/core/security/input_validator.dart';
import 'package:flutter_clock/src/core/storage/key_value_storage.dart';
import 'package:flutter_clock/src/core/utils/timezone_formatter.dart';
import 'package:flutter_clock/src/features/clock/data/datasources/local_timezone_datasource.dart';
import 'package:flutter_clock/src/features/clock/data/datasources/time_api_client.dart';
import 'package:flutter_clock/src/features/clock/domain/entities/world_time.dart';
import 'package:flutter_clock/src/features/clock/domain/repositories/clock_repository.dart';

/// Repository implementation combining instant local IANA resolution, HTTPS API, and preferences.
class ClockRepositoryImpl implements ClockRepository {
  final TimeApiClient _apiClient;
  final KeyValueStorage _storage;
  final LocalTimezoneDataSource _localTimezoneSource;
  final bool _preferLocalTimezone;

  ClockRepositoryImpl({
    required this._apiClient,
    required this._storage,
    this._localTimezoneSource =
        const LocalTimezoneDataSource(),
    this._preferLocalTimezone = false,
  });

  @override
  Future<WorldTime> fetchCurrentTime({
    required String location,
    required String url,
    required String flag,
  }) async {
    final String safeFlag = InputValidator.normalizeFlagAssetPath(flag);
    final String safeUrl = url.trim();
    final DateTime? currentDateTime = await _resolveDateTime(safeUrl);

    if (currentDateTime == null) {
      return WorldTime(
        location: location,
        url: safeUrl,
        flag: safeFlag,
        date: '',
        isDayTime: true,
        time: '',
      );
    }

    return WorldTime(
      location: location,
      url: safeUrl,
      flag: safeFlag,
      date: TimezoneFormatter.formatDate(currentDateTime),
      isDayTime: TimezoneFormatter.isDaytimeHour(currentDateTime.hour),
      time: TimezoneFormatter.formatTime(currentDateTime),
      secondsLeft: TimezoneFormatter.computeSecondsUntilNextMinute(
        currentDateTime.second,
      ),
    );
  }

  Future<DateTime?> _resolveDateTime(String safeUrl) async {
    if (_preferLocalTimezone) {
      final DateTime? localNow = _localTimezoneSource.nowInTimeZone(safeUrl);
      if (localNow != null) {
        return localNow;
      }
    }
    return _apiClient.fetchCurrentDateTime(safeUrl);
  }

  @override
  Future<WorldTime> loadDefaultOrSavedClock() async {
    final List<String?> savedValues = await Future.wait<String?>(<Future<String?>>[
      _storage.getString(StorageKeys.selectedLocationName),
      _storage.getString(StorageKeys.selectedTimeZoneUrl),
      _storage.getString(StorageKeys.selectedFlagAsset),
    ]);

    final String savedLocation = savedValues[0]?.trim() ?? '';
    final String savedUrl = savedValues[1]?.trim() ?? '';
    final String savedFlagRaw = savedValues[2] ?? '';
    final String savedFlag = InputValidator.normalizeFlagAssetPath(
      savedFlagRaw,
    );

    final bool hasValidSavedSelection =
        savedLocation.isNotEmpty &&
        InputValidator.isValidTimeZoneId(savedUrl);

    if (!hasValidSavedSelection) {
      return fetchCurrentTime(
        location: AppConstants.defaultLocation,
        url: AppConstants.defaultTimeZoneId,
        flag: AppConstants.defaultFlagAsset,
      );
    }

    return fetchCurrentTime(
      location: savedLocation,
      url: savedUrl,
      flag: savedFlag,
    );
  }

  @override
  Future<void> saveSelectedClock(WorldTime worldTime) async {
    if (!InputValidator.isValidTimeZoneId(worldTime.url)) {
      return;
    }
    final String safeFlag = InputValidator.normalizeFlagAssetPath(
      worldTime.flag,
    );
    await Future.wait<void>(<Future<void>>[
      _storage.setString(StorageKeys.selectedTimeZoneUrl, worldTime.url.trim()),
      _storage.setString(
        StorageKeys.selectedLocationName,
        worldTime.location.trim(),
      ),
      _storage.setString(StorageKeys.selectedFlagAsset, safeFlag),
    ]);
  }
}
