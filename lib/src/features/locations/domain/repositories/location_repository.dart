import 'package:flutter_clock/src/features/locations/domain/entities/timezone_location.dart';

/// Domain contract for fetching selectable world clock timezones.
abstract interface class LocationRepository {
  Future<List<TimezoneLocation>> fetchAvailableLocations();
}
