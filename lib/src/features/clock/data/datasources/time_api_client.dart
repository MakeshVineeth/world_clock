import 'dart:convert';

import 'package:flutter_clock/src/core/constants/app_constants.dart';
import 'package:flutter_clock/src/core/logging/app_logger.dart';
import 'package:flutter_clock/src/core/security/input_validator.dart';
import 'package:http/http.dart' as http;

/// HTTPS client for `timeapi.io` timezone and current-time endpoints.
class TimeApiClient {
  final http.Client _client;
  final Duration _timeout;

  TimeApiClient({
    http.Client? client,
    this._timeout = AppConstants.apiTimeout,
  }) : _client = client ?? http.Client();

  Future<List<String>> fetchAvailableTimeZones() async {
    final Uri uri = Uri.https(
      AppConstants.timeApiHost,
      AppConstants.availableTimeZonesPath,
    );

    try {
      final http.Response response = await _client
          .get(uri, headers: const <String, String>{'Accept': 'application/json'})
          .timeout(_timeout);

      if (response.statusCode != 200) {
        AppLogger.warning(
          'Timezones request returned status ${response.statusCode}',
        );
        return const <String>[];
      }

      final Object? decoded = jsonDecode(response.body);
      if (decoded is! List<Object?>) {
        return const <String>[];
      }

      return _extractValidZones(decoded);
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Failed to fetch available timezones',
        error: error,
        stackTrace: stackTrace,
      );
      return const <String>[];
    }
  }

  Future<DateTime?> fetchCurrentDateTime(String timeZoneId) async {
    final String sanitizedZone = timeZoneId.trim();
    if (!InputValidator.isValidTimeZoneId(sanitizedZone)) {
      AppLogger.warning('Rejected invalid timezone identifier: $timeZoneId');
      return null;
    }

    final Uri uri = Uri.https(
      AppConstants.timeApiHost,
      AppConstants.currentTimePath,
      <String, String>{'timeZone': sanitizedZone},
    );

    try {
      final http.Response response = await _client
          .get(uri, headers: const <String, String>{'Accept': 'application/json'})
          .timeout(_timeout);

      if (response.statusCode != 200) {
        AppLogger.warning(
          'Current time request returned status ${response.statusCode}',
        );
        return null;
      }

      final Object? decoded = jsonDecode(response.body);
      if (decoded is! Map<String, Object?>) {
        return null;
      }

      final Object? rawDateTime = decoded['dateTime'];
      if (rawDateTime is! String || rawDateTime.trim().isEmpty) {
        return null;
      }
      return DateTime.tryParse(rawDateTime.trim());
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Failed to fetch current time for $sanitizedZone',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  List<String> _extractValidZones(List<Object?> rawItems) {
    final List<String> zones = <String>[];
    for (final Object? item in rawItems) {
      if (item is String && InputValidator.isValidTimeZoneId(item)) {
        zones.add(item);
      }
    }
    return zones;
  }

  void close() {
    _client.close();
  }
}
