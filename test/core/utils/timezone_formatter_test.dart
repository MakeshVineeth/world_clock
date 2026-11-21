import 'package:flutter_clock/src/core/utils/timezone_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TimezoneFormatter', () {
    test('sanitizes and formats timezone identifiers', () {
      expect(
        TimezoneFormatter.sanitizeRawZoneId('[America/New_York '),
        equals('America/New_York'),
      );
      expect(
        TimezoneFormatter.formatDisplayLocation('America/New_York'),
        equals('America, New York'),
      );
      expect(
        TimezoneFormatter.formatDisplayLocation(
          'America/Argentina/Buenos_Aires',
        ),
        equals('America, Argentina, Buenos Aires'),
      );
    });

    test('computes daytime hours matching original 7..18 boundary', () {
      expect(TimezoneFormatter.isDaytimeHour(6), isFalse);
      expect(TimezoneFormatter.isDaytimeHour(7), isTrue);
      expect(TimezoneFormatter.isDaytimeHour(18), isTrue);
      expect(TimezoneFormatter.isDaytimeHour(19), isFalse);
    });

    test('computes clamped seconds until next minute', () {
      expect(TimezoneFormatter.computeSecondsUntilNextMinute(0), equals(60));
      expect(TimezoneFormatter.computeSecondsUntilNextMinute(45), equals(15));
      expect(TimezoneFormatter.computeSecondsUntilNextMinute(60), equals(1));
    });

    test('formats dates and times consistently', () {
      final DateTime sample = DateTime(2025, 5, 24, 15, 5, 20);
      expect(TimezoneFormatter.formatDate(sample), equals('24-May-2025'));
      expect(TimezoneFormatter.formatTime(sample), contains('3:05'));
    });

    test('builds valid country flag asset paths', () {
      expect(
        TimezoneFormatter.flagAssetForCountryCode('IN'),
        equals('icons/flags/png100px/in.png'),
      );
      expect(TimezoneFormatter.flagAssetForCountryCode(null), isEmpty);
      expect(TimezoneFormatter.flagAssetForCountryCode('null'), isEmpty);
      expect(TimezoneFormatter.flagAssetForCountryCode('invalid'), isEmpty);
    });
  });
}
