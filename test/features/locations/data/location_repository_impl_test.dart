import 'dart:convert';

import 'package:flutter_clock/src/features/clock/data/datasources/time_api_client.dart';
import 'package:flutter_clock/src/features/locations/data/datasources/country_flag_asset_source.dart';
import 'package:flutter_clock/src/features/locations/data/repositories/location_repository_impl.dart';
import 'package:flutter_clock/src/features/locations/domain/entities/timezone_location.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class _FakeCountryFlagSource implements CountryFlagAssetSource {
  final Map<String, String> codes;

  _FakeCountryFlagSource(this.codes);

  @override
  Future<Map<String, String>> loadCountryCodes() async => codes;
}

void main() {
  group('LocationRepositoryImpl', () {
    test('maps timezones to display locations and normalized flag assets', () async {
      final MockClient mockClient = MockClient(
        (_) async => http.Response(
          jsonEncode(<String>[
            'Asia/Kolkata',
            'America/New_York',
            'Etc/UTC',
          ]),
          200,
        ),
      );
      final TimeApiClient apiClient = TimeApiClient(client: mockClient);
      addTearDown(apiClient.close);

      final LocationRepositoryImpl repository = LocationRepositoryImpl(
        apiClient: apiClient,
        countryFlagSource: _FakeCountryFlagSource(<String, String>{
          'Asia/Kolkata': 'IN',
          'America/New_York': 'US',
        }),
      );

      final List<TimezoneLocation> locations = await repository
          .fetchAvailableLocations();

      expect(locations, hasLength(3));
      expect(locations[0].displayName, equals('Asia, Kolkata'));
      expect(locations[0].flagAssetPath, equals('icons/flags/png100px/in.png'));
      expect(locations[1].displayName, equals('America, New York'));
      expect(locations[1].flagAssetPath, equals('icons/flags/png100px/us.png'));
      expect(locations[2].displayName, equals('Etc, UTC'));
      expect(locations[2].flagAssetPath, isEmpty);
    });

    test('returns empty list when API returns empty or fails', () async {
      final MockClient mockClient = MockClient(
        (_) async => http.Response('error', 500),
      );
      final TimeApiClient apiClient = TimeApiClient(client: mockClient);
      addTearDown(apiClient.close);

      final LocationRepositoryImpl repository = LocationRepositoryImpl(
        apiClient: apiClient,
        countryFlagSource: _FakeCountryFlagSource(<String, String>{}),
      );

      expect(await repository.fetchAvailableLocations(), isEmpty);
    });
  });
}
