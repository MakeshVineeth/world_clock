import 'package:flutter_clock/src/features/locations/domain/entities/timezone_location.dart';
import 'package:flutter_clock/src/features/locations/domain/services/timezone_search_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const TimezoneSearchService service = TimezoneSearchService();
  const List<TimezoneLocation> sampleLocations = <TimezoneLocation>[
    TimezoneLocation(
      timeZoneId: 'Asia/Kolkata',
      displayName: 'Asia, Kolkata',
      flagAssetPath: 'icons/flags/png100px/in.png',
    ),
    TimezoneLocation(
      timeZoneId: 'America/New_York',
      displayName: 'America, New York',
      flagAssetPath: 'icons/flags/png100px/us.png',
    ),
    TimezoneLocation(
      timeZoneId: 'Europe/London',
      displayName: 'Europe, London',
      flagAssetPath: 'icons/flags/png100px/gb.png',
    ),
    TimezoneLocation(
      timeZoneId: 'Asia/Tokyo',
      displayName: 'Asia, Tokyo',
      flagAssetPath: 'icons/flags/png100px/jp.png',
    ),
  ];

  group('TimezoneSearchService', () {
    test('returns empty list when query has fewer than 2 characters', () {
      expect(service.search(sampleLocations, ''), isEmpty);
      expect(service.search(sampleLocations, 'a'), isEmpty);
      expect(service.search(sampleLocations, '  \x00 '), isEmpty);
    });

    test('prioritizes exact and word-prefix matches', () {
      final List<TimezoneLocation> results = service.search(
        sampleLocations,
        'kol',
      );
      expect(results, isNotEmpty);
      expect(results.first.timeZoneId, equals('Asia/Kolkata'));
    });

    test('matches multi-word queries like new york', () {
      final List<TimezoneLocation> results = service.search(
        sampleLocations,
        'new york',
      );
      expect(results.map((TimezoneLocation e) => e.timeZoneId), contains('America/New_York'));
    });

    test('supports fuzzy matching with small typos', () {
      final List<TimezoneLocation> results = service.search(
        sampleLocations,
        'kolkta',
      );
      expect(results, isNotEmpty);
      expect(results.first.timeZoneId, equals('Asia/Kolkata'));
    });

    test('returns empty list when no location matches', () {
      expect(service.search(sampleLocations, 'zzzzzz'), isEmpty);
    });
  });
}
