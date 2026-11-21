import 'package:flutter_clock/src/core/security/input_validator.dart';
import 'package:flutter_clock/src/core/utils/timezone_formatter.dart';
import 'package:flutter_clock/src/features/clock/data/datasources/time_api_client.dart';
import 'package:flutter_clock/src/features/locations/data/datasources/country_flag_asset_source.dart';
import 'package:flutter_clock/src/features/locations/domain/entities/timezone_location.dart';
import 'package:flutter_clock/src/features/locations/domain/repositories/location_repository.dart';

/// Fetches IANA timezones over HTTPS and enriches them with bundled country flags.
class LocationRepositoryImpl implements LocationRepository {
  final TimeApiClient _apiClient;
  final CountryFlagAssetSource _countryFlagSource;

  LocationRepositoryImpl({
    required this._apiClient,
    required this._countryFlagSource,
  });

  @override
  Future<List<TimezoneLocation>> fetchAvailableLocations() async {
    final List<String> zoneIds = await _apiClient.fetchAvailableTimeZones();
    if (zoneIds.isEmpty) {
      return const <TimezoneLocation>[];
    }

    final Map<String, String> countryCodes = await _countryFlagSource
        .loadCountryCodes();

    final List<TimezoneLocation> locations = <TimezoneLocation>[];
    for (final String rawId in zoneIds) {
      final String zoneId = TimezoneFormatter.sanitizeRawZoneId(rawId);
      if (!InputValidator.isValidTimeZoneId(zoneId)) {
        continue;
      }

      locations.add(
        TimezoneLocation(
          timeZoneId: zoneId,
          displayName: TimezoneFormatter.formatDisplayLocation(zoneId),
          flagAssetPath: TimezoneFormatter.flagAssetForCountryCode(
            countryCodes[rawId] ?? countryCodes[zoneId],
          ),
        ),
      );
    }
    return locations;
  }
}
