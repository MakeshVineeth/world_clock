import 'package:flutter_clock/src/core/security/input_validator.dart';
import 'package:flutter_clock/src/core/utils/timezone_formatter.dart';
import 'package:flutter_clock/src/features/clock/data/datasources/time_api_client.dart';
import 'package:flutter_clock/src/features/locations/data/datasources/country_flag_asset_source.dart';
import 'package:flutter_clock/src/features/locations/domain/entities/timezone_location.dart';
import 'package:flutter_clock/src/features/locations/domain/repositories/location_repository.dart';

/// Resolves IANA timezones and enriches them with bundled HD country flags.
class LocationRepositoryImpl implements LocationRepository {
  final TimeApiClient _apiClient;
  final CountryFlagAssetSource _countryFlagSource;
  final bool _preferBundledLocations;
  List<TimezoneLocation>? _cachedLocations;

  LocationRepositoryImpl({
    required this._apiClient,
    required this._countryFlagSource,
    this._preferBundledLocations = false,
  });

  @override
  Future<List<TimezoneLocation>> fetchAvailableLocations() async {
    if (_cachedLocations != null) {
      return _cachedLocations!;
    }

    final Map<String, String> countryCodes = await _countryFlagSource
        .loadCountryCodes();

    if (_preferBundledLocations && countryCodes.isNotEmpty) {
      final List<TimezoneLocation> bundled = _buildFromBundledCountryCodes(
        countryCodes,
      );
      _cachedLocations = List<TimezoneLocation>.unmodifiable(bundled);
      return _cachedLocations!;
    }

    final List<String> zoneIds = await _apiClient.fetchAvailableTimeZones();
    if (zoneIds.isEmpty) {
      if (_preferBundledLocations && countryCodes.isNotEmpty) {
        final List<TimezoneLocation> fallback = _buildFromBundledCountryCodes(
          countryCodes,
        );
        _cachedLocations = List<TimezoneLocation>.unmodifiable(fallback);
        return _cachedLocations!;
      }
      return const <TimezoneLocation>[];
    }

    final List<TimezoneLocation> locations = <TimezoneLocation>[];
    for (final String rawId in zoneIds) {
      final String zoneId = TimezoneFormatter.sanitizeRawZoneId(rawId);
      if (!InputValidator.isValidTimeZoneId(zoneId)) {
        continue;
      }

      final String? resolvedCode =
          TimezoneFormatter.resolveCountryCode(rawId, countryCodes) ??
          TimezoneFormatter.resolveCountryCode(zoneId, countryCodes);

      locations.add(
        TimezoneLocation(
          timeZoneId: zoneId,
          displayName: TimezoneFormatter.formatDisplayLocation(
            zoneId,
            countryCode: resolvedCode,
          ),
          flagAssetPath: TimezoneFormatter.flagAssetForCountryCode(
            resolvedCode,
          ),
        ),
      );
    }

    locations.sort(_compareByDisplayName);
    _cachedLocations = List<TimezoneLocation>.unmodifiable(locations);
    return _cachedLocations!;
  }

  List<TimezoneLocation> _buildFromBundledCountryCodes(
    Map<String, String> countryCodes,
  ) {
    final List<String> sortedZones = countryCodes.keys.toList();
    final List<TimezoneLocation> locations = <TimezoneLocation>[];

    for (final String rawId in sortedZones) {
      final String zoneId = TimezoneFormatter.sanitizeRawZoneId(rawId);
      if (!InputValidator.isValidTimeZoneId(zoneId)) {
        continue;
      }
      final String? resolvedCode = TimezoneFormatter.resolveCountryCode(
        zoneId,
        countryCodes,
      );
      final String flagPath = TimezoneFormatter.flagAssetForCountryCode(
        resolvedCode,
      );
      if (flagPath.isEmpty) {
        continue;
      }
      locations.add(
        TimezoneLocation(
          timeZoneId: zoneId,
          displayName: TimezoneFormatter.formatDisplayLocation(
            zoneId,
            countryCode: resolvedCode,
          ),
          flagAssetPath: flagPath,
        ),
      );
    }
    locations.sort(_compareByDisplayName);
    return locations;
  }

  static int _compareByDisplayName(TimezoneLocation a, TimezoneLocation b) {
    return a.displayName.compareTo(b.displayName);
  }
}
