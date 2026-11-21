import 'dart:convert';

import 'package:flutter_clock/src/core/constants/app_constants.dart';
import 'package:flutter_clock/src/core/constants/storage_keys.dart';
import 'package:flutter_clock/src/core/storage/key_value_storage.dart';
import 'package:flutter_clock/src/features/clock/data/datasources/time_api_client.dart';
import 'package:flutter_clock/src/features/clock/data/repositories/clock_repository_impl.dart';
import 'package:flutter_clock/src/features/clock/domain/entities/world_time.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class _InMemoryStorage implements KeyValueStorage {
  final Map<String, String> values = <String, String>{};

  @override
  Future<String?> getString(String key) async => values[key];

  @override
  Future<void> setString(String key, String value) async {
    values[key] = value;
  }
}

void main() {
  group('ClockRepositoryImpl', () {
    test('loads default clock when storage is empty', () async {
      String? requestedZone;
      final MockClient mockClient = MockClient((http.Request request) async {
        requestedZone = request.url.queryParameters['timeZone'];
        return http.Response(
          jsonEncode(<String, Object?>{'dateTime': '2025-05-24T10:15:30'}),
          200,
        );
      });
      final TimeApiClient apiClient = TimeApiClient(client: mockClient);
      addTearDown(apiClient.close);

      final _InMemoryStorage storage = _InMemoryStorage();
      final ClockRepositoryImpl repository = ClockRepositoryImpl(
        apiClient: apiClient,
        storage: storage,
      );

      final WorldTime result = await repository.loadDefaultOrSavedClock();
      expect(requestedZone, equals(AppConstants.defaultTimeZoneId));
      expect(result.location, equals(AppConstants.defaultLocation));
      expect(result.flag, equals(AppConstants.defaultFlagAsset));
      expect(result.date, equals('24-May-2025'));
      expect(result.isDayTime, isTrue);
      expect(result.secondsLeft, equals(30));
    });

    test('migrates legacy flag asset path from saved preferences', () async {
      final MockClient mockClient = MockClient(
        (_) async => http.Response(
          jsonEncode(<String, Object?>{'dateTime': '2025-05-24T22:00:00'}),
          200,
        ),
      );
      final TimeApiClient apiClient = TimeApiClient(client: mockClient);
      addTearDown(apiClient.close);

      final _InMemoryStorage storage = _InMemoryStorage()
        ..values[StorageKeys.selectedLocationName] = 'America, New York'
        ..values[StorageKeys.selectedTimeZoneUrl] = 'America/New_York'
        ..values[StorageKeys.selectedFlagAsset] = 'icons/flags/png/us.png';

      final ClockRepositoryImpl repository = ClockRepositoryImpl(
        apiClient: apiClient,
        storage: storage,
      );

      final WorldTime result = await repository.loadDefaultOrSavedClock();
      expect(result.url, equals('America/New_York'));
      expect(result.location, equals('United States, New York'));
      expect(result.flag, equals('icons/flags/png100px/us.png'));
      expect(result.isDayTime, isFalse);
    });

    test('falls back to default clock when saved timezone is malformed', () async {
      String? requestedZone;
      final MockClient mockClient = MockClient((http.Request request) async {
        requestedZone = request.url.queryParameters['timeZone'];
        return http.Response(
          jsonEncode(<String, Object?>{'dateTime': '2025-05-24T12:00:00'}),
          200,
        );
      });
      final TimeApiClient apiClient = TimeApiClient(client: mockClient);
      addTearDown(apiClient.close);

      final _InMemoryStorage storage = _InMemoryStorage()
        ..values[StorageKeys.selectedLocationName] = 'Evil'
        ..values[StorageKeys.selectedTimeZoneUrl] = '../bad'
        ..values[StorageKeys.selectedFlagAsset] = 'icons/flags/png100px/in.png';

      final ClockRepositoryImpl repository = ClockRepositoryImpl(
        apiClient: apiClient,
        storage: storage,
      );

      final WorldTime result = await repository.loadDefaultOrSavedClock();
      expect(requestedZone, equals(AppConstants.defaultTimeZoneId));
      expect(result.url, equals(AppConstants.defaultTimeZoneId));
    });

    test('loads saved flagless timezone cleanly across restarts', () async {
      final MockClient mockClient = MockClient(
        (_) async => http.Response(
          jsonEncode(<String, Object?>{'dateTime': '2025-05-24T12:00:00'}),
          200,
        ),
      );
      final TimeApiClient apiClient = TimeApiClient(client: mockClient);
      addTearDown(apiClient.close);

      final _InMemoryStorage storage = _InMemoryStorage()
        ..values[StorageKeys.selectedLocationName] = 'Etc, UTC'
        ..values[StorageKeys.selectedTimeZoneUrl] = 'Etc/UTC'
        ..values[StorageKeys.selectedFlagAsset] = '';

      final ClockRepositoryImpl repository = ClockRepositoryImpl(
        apiClient: apiClient,
        storage: storage,
      );

      final WorldTime result = await repository.loadDefaultOrSavedClock();
      expect(result.url, equals('Etc/UTC'));
      expect(result.location, equals('Etc, UTC'));
      expect(result.flag, isEmpty);
    });

    test('saveSelectedClock persists valid selection and skips invalid URL', () async {
      final MockClient mockClient = MockClient(
        (_) async => http.Response('{}', 200),
      );
      final TimeApiClient apiClient = TimeApiClient(client: mockClient);
      addTearDown(apiClient.close);

      final _InMemoryStorage storage = _InMemoryStorage();
      final ClockRepositoryImpl repository = ClockRepositoryImpl(
        apiClient: apiClient,
        storage: storage,
      );

      await repository.saveSelectedClock(
        const WorldTime(
          location: 'Asia, Tokyo',
          url: 'Asia/Tokyo',
          flag: 'icons/flags/png100px/jp.png',
          date: '24-May-2025',
          isDayTime: true,
          time: '3:00 PM',
        ),
      );
      expect(storage.values[StorageKeys.selectedTimeZoneUrl], equals('Asia/Tokyo'));
      expect(storage.values[StorageKeys.selectedLocationName], equals('Asia, Tokyo'));
      expect(
        storage.values[StorageKeys.selectedFlagAsset],
        equals('icons/flags/png100px/jp.png'),
      );

      await repository.saveSelectedClock(
        const WorldTime(
          location: 'Bad',
          url: '../bad',
          flag: 'icons/flags/png100px/jp.png',
          date: '',
          isDayTime: true,
          time: '',
        ),
      );
      expect(storage.values[StorageKeys.selectedTimeZoneUrl], equals('Asia/Tokyo'));
    });

    test('returns fallback WorldTime with empty time/date when API fails', () async {
      final MockClient mockClient = MockClient(
        (_) async => http.Response('Error', 500),
      );
      final TimeApiClient apiClient = TimeApiClient(client: mockClient);
      addTearDown(apiClient.close);

      final ClockRepositoryImpl repository = ClockRepositoryImpl(
        apiClient: apiClient,
        storage: _InMemoryStorage(),
      );

      final WorldTime result = await repository.fetchCurrentTime(
        location: 'Asia, Kolkata',
        url: 'Asia/Kolkata',
        flag: 'icons/flags/png100px/in.png',
      );
      expect(result.time, isEmpty);
      expect(result.date, isEmpty);
      expect(result.isDayTime, isTrue);
      expect(result.location, equals('Asia, Kolkata'));
    });

    test('resolves time instantly offline when preferLocalTimezone is true', () async {
      bool networkCalled = false;
      final MockClient mockClient = MockClient((_) async {
        networkCalled = true;
        return http.Response('Error', 502);
      });
      final TimeApiClient apiClient = TimeApiClient(client: mockClient);
      addTearDown(apiClient.close);

      final ClockRepositoryImpl repository = ClockRepositoryImpl(
        apiClient: apiClient,
        storage: _InMemoryStorage(),
        preferLocalTimezone: true,
      );

      final WorldTime result = await repository.fetchCurrentTime(
        location: 'Asia, Kolkata',
        url: 'Asia/Kolkata',
        flag: 'icons/flags/png100px/in.png',
      );
      expect(networkCalled, isFalse);
      expect(result.time, isNotEmpty);
      expect(result.date, isNotEmpty);
      expect(result.location, equals('Asia, Kolkata'));
    });
  });
}
