import 'package:flutter_clock/src/core/constants/app_constants.dart';
import 'package:flutter_clock/src/core/constants/storage_keys.dart';
import 'package:flutter_clock/src/core/security/input_validator.dart';
import 'package:flutter_clock/src/core/storage/key_value_storage.dart';
import 'package:flutter_clock/src/core/utils/timezone_formatter.dart';
import 'package:flutter_clock/src/features/clock/data/datasources/time_api_client.dart';
import 'package:flutter_clock/src/features/clock/domain/entities/world_time.dart';
import 'package:flutter_clock/src/features/clock/domain/repositories/clock_repository.dart';

/// Repository implementation combining HTTPS API calls and local preferences.
class ClockRepositoryImpl implements ClockRepository {
  final TimeApiClient _apiClient;
  final KeyValueStorage _storage;

  ClockRepositoryImpl({
    required this._apiClient,
    required this._storage,
  });

  @override
  Future<WorldTime> fetchCurrentTime({
    required String location,
    required String url,
    required String flag,
  }) async {
    final String safeFlag = InputValidator.normalizeFlagAssetPath(flag);
    final String safeUrl = url.trim();
    final DateTime? currentDateTime = await _apiClient.fetchCurrentDateTime(
      safeUrl,
    );

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

  @override
  Future<WorldTime> loadDefaultOrSavedClock() async {
    final String savedLocation =
        (await _storage.getString(StorageKeys.selectedLocationName))?.trim() ??
        '';
    final String savedUrl =
        (await _storage.getString(StorageKeys.selectedTimeZoneUrl))?.trim() ??
        '';
    final String savedFlagRaw =
        (await _storage.getString(StorageKeys.selectedFlagAsset)) ?? '';
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
    await _storage.setString(
      StorageKeys.selectedTimeZoneUrl,
      worldTime.url.trim(),
    );
    await _storage.setString(
      StorageKeys.selectedLocationName,
      worldTime.location.trim(),
    );
    await _storage.setString(StorageKeys.selectedFlagAsset, safeFlag);
  }
}
