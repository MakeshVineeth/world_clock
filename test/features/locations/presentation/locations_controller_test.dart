import 'package:flutter_clock/src/features/locations/domain/entities/timezone_location.dart';
import 'package:flutter_clock/src/features/locations/domain/repositories/location_repository.dart';
import 'package:flutter_clock/src/features/locations/presentation/controllers/locations_controller.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeLocationRepository implements LocationRepository {
  final List<TimezoneLocation> items;

  _FakeLocationRepository(this.items);

  @override
  Future<List<TimezoneLocation>> fetchAvailableLocations() async => items;
}

void main() {
  const List<TimezoneLocation> sampleLocations = <TimezoneLocation>[
    TimezoneLocation(
      timeZoneId: 'Asia/Kolkata',
      displayName: 'Asia, Kolkata',
      flagAssetPath: 'icons/flags/png100px/in.png',
    ),
    TimezoneLocation(
      timeZoneId: 'Europe/London',
      displayName: 'Europe, London',
      flagAssetPath: 'icons/flags/png100px/gb.png',
    ),
  ];

  group('LocationsController', () {
    test('loads available locations and updates loading state', () async {
      final LocationsController controller = LocationsController(
        repository: _FakeLocationRepository(sampleLocations),
        debounceDuration: Duration.zero,
      );
      addTearDown(controller.dispose);

      expect(controller.isLoading, isTrue);
      await controller.loadLocations();

      expect(controller.isLoading, isFalse);
      expect(controller.locations, hasLength(2));
    });

    test('debounces queries >= 2 chars and clears cleanly below 2 chars', () async {
      final LocationsController controller = LocationsController(
        repository: _FakeLocationRepository(sampleLocations),
        debounceDuration: const Duration(milliseconds: 20),
      );
      addTearDown(controller.dispose);

      await controller.loadLocations();

      controller.onQueryChanged('k');
      expect(controller.isSearchActive, isFalse);
      expect(controller.isSearching, isFalse);

      controller.onQueryChanged('kol');
      expect(controller.isSearchActive, isTrue);
      expect(controller.isSearching, isTrue);

      await Future<void>.delayed(const Duration(milliseconds: 40));
      expect(controller.isSearching, isFalse);
      expect(controller.searchResults, hasLength(1));
      expect(controller.searchResults.first.timeZoneId, equals('Asia/Kolkata'));

      controller.clearSearch();
      expect(controller.query, isEmpty);
      expect(controller.isSearchActive, isFalse);
      expect(controller.searchResults, isEmpty);
    });
  });
}
