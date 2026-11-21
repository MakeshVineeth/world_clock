import 'package:flutter_clock/src/core/security/input_validator.dart';
import 'package:intl/intl.dart';

/// Pure-Dart formatting and normalization helpers for timezones and dates.
abstract final class TimezoneFormatter {
  static String sanitizeRawZoneId(String raw) {
    return raw.replaceAll('[', '').replaceAll(' ', '');
  }

  static String formatDisplayLocation(String timeZoneId) {
    return timeZoneId.replaceAll('/', ', ').replaceAll('_', ' ');
  }

  static bool isDaytimeHour(int hour) {
    return hour > 6 && hour < 19;
  }

  static int computeSecondsUntilNextMinute(int currentSecond) {
    final int remaining = 60 - currentSecond;
    return remaining.clamp(1, 60);
  }

  static String formatDate(DateTime dateTime) {
    return DateFormat('dd-MMM-yyyy').format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat.jm().format(dateTime);
  }

  static String flagAssetForCountryCode(String? countryCode) {
    if (countryCode == null) {
      return '';
    }
    final String normalized = countryCode.trim().toLowerCase();
    if (normalized.isEmpty || normalized == 'null') {
      return '';
    }
    return InputValidator.normalizeFlagAssetPath(
      'icons/flags/png100px/$normalized.png',
    );
  }
}
