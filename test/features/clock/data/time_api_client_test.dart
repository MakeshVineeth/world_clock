import 'dart:convert';

import 'package:flutter_clock/src/features/clock/data/datasources/time_api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('TimeApiClient', () {
    test('fetchAvailableTimeZones parses valid HTTPS list response', () async {
      final MockClient mockClient = MockClient((http.Request request) async {
        expect(request.url.scheme, equals('https'));
        expect(request.url.host, equals('timeapi.io'));
        expect(request.url.path, equals('/api/timezone/availabletimezones'));
        return http.Response(
          jsonEncode(<Object?>[
            'Asia/Kolkata',
            'America/New_York',
            '../bad/zone',
            123,
          ]),
          200,
        );
      });

      final TimeApiClient client = TimeApiClient(client: mockClient);
      addTearDown(client.close);

      final List<String> zones = await client.fetchAvailableTimeZones();
      expect(zones, equals(<String>['Asia/Kolkata', 'America/New_York']));
    });

    test('fetchAvailableTimeZones returns empty list on non-200 status', () async {
      final MockClient mockClient = MockClient(
        (_) async => http.Response('Server Error', 503),
      );

      final TimeApiClient client = TimeApiClient(client: mockClient);
      addTearDown(client.close);

      expect(await client.fetchAvailableTimeZones(), isEmpty);
    });

    test('fetchCurrentDateTime validates zone before calling API', () async {
      bool called = false;
      final MockClient mockClient = MockClient((_) async {
        called = true;
        return http.Response('{}', 200);
      });

      final TimeApiClient client = TimeApiClient(client: mockClient);
      addTearDown(client.close);

      final DateTime? result = await client.fetchCurrentDateTime('../invalid');
      expect(result, isNull);
      expect(called, isFalse);
    });

    test('fetchCurrentDateTime parses dateTime from 200 JSON response', () async {
      final MockClient mockClient = MockClient((http.Request request) async {
        expect(request.url.queryParameters['timeZone'], equals('Asia/Kolkata'));
        return http.Response(
          jsonEncode(<String, Object?>{'dateTime': '2025-05-24T15:05:20'}),
          200,
        );
      });

      final TimeApiClient client = TimeApiClient(client: mockClient);
      addTearDown(client.close);

      final DateTime? parsed = await client.fetchCurrentDateTime(
        'Asia/Kolkata',
      );
      expect(parsed, equals(DateTime(2025, 5, 24, 15, 5, 20)));
    });

    test('fetchCurrentDateTime returns null on malformed JSON', () async {
      final MockClient mockClient = MockClient(
        (_) async => http.Response('{not-json', 200),
      );

      final TimeApiClient client = TimeApiClient(client: mockClient);
      addTearDown(client.close);

      expect(await client.fetchCurrentDateTime('Asia/Kolkata'), isNull);
    });
  });
}
