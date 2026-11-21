import 'package:flutter_clock/src/core/security/input_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InputValidator.isValidTimeZoneId', () {
    test('accepts standard IANA timezone identifiers', () {
      expect(InputValidator.isValidTimeZoneId('Asia/Kolkata'), isTrue);
      expect(
        InputValidator.isValidTimeZoneId('America/Argentina/Buenos_Aires'),
        isTrue,
      );
      expect(InputValidator.isValidTimeZoneId('Etc/GMT+5'), isTrue);
      expect(InputValidator.isValidTimeZoneId('UTC'), isTrue);
    });

    test('rejects empty, traversal, and malformed timezone identifiers', () {
      expect(InputValidator.isValidTimeZoneId(''), isFalse);
      expect(InputValidator.isValidTimeZoneId('   '), isFalse);
      expect(InputValidator.isValidTimeZoneId('../etc/passwd'), isFalse);
      expect(InputValidator.isValidTimeZoneId('Asia/../Kolkata'), isFalse);
      expect(InputValidator.isValidTimeZoneId('/Asia/Kolkata'), isFalse);
      expect(InputValidator.isValidTimeZoneId('Asia/Kolkata/'), isFalse);
      expect(InputValidator.isValidTimeZoneId('Asia//Kolkata'), isFalse);
      expect(
        InputValidator.isValidTimeZoneId('Asia/Kolkata?foo=bar'),
        isFalse,
      );
      expect(InputValidator.isValidTimeZoneId('Asia Kolkata'), isFalse);
      expect(InputValidator.isValidTimeZoneId('a' * 65), isFalse);
    });
  });

  group('InputValidator.sanitizeSearchQuery', () {
    test('strips control characters, collapses whitespace, and clamps', () {
      expect(
        InputValidator.sanitizeSearchQuery('  new\x00\n   york\x7F  '),
        equals('new york'),
      );
      final String longInput = 'a' * 100;
      expect(
        InputValidator.sanitizeSearchQuery(longInput).length,
        equals(InputValidator.maxSearchQueryLength),
      );
    });
  });

  group('InputValidator.normalizeFlagAssetPath', () {
    test('accepts png100px paths and migrates legacy png paths', () {
      expect(
        InputValidator.normalizeFlagAssetPath('icons/flags/png100px/in.png'),
        equals('icons/flags/png100px/in.png'),
      );
      expect(
        InputValidator.normalizeFlagAssetPath('icons/flags/png/us.png'),
        equals('icons/flags/png100px/us.png'),
      );
      expect(
        InputValidator.toHdFlagAssetPath('icons/flags/png100px/in.png'),
        equals('icons/flags/png250px/in.png'),
      );
      expect(
        InputValidator.toVectorFlagAssetPath('icons/flags/png100px/in.png'),
        equals('icons/flags/svg/in.svg'),
      );
      expect(
        InputValidator.normalizeFlagAssetPath('icons/flags/svg/in.svg'),
        equals('icons/flags/png100px/in.png'),
      );
    });

    test('rejects invalid or traversal flag paths', () {
      expect(InputValidator.normalizeFlagAssetPath(''), isEmpty);
      expect(
        InputValidator.normalizeFlagAssetPath('icons/flags/png100px/null.png'),
        isEmpty,
      );
      expect(
        InputValidator.normalizeFlagAssetPath('../secrets/key.png'),
        isEmpty,
      );
      expect(
        InputValidator.normalizeFlagAssetPath('https://example.com/in.png'),
        isEmpty,
      );
    });
  });

  group('InputValidator.isAllowedExternalUri', () {
    test('allows https with host and market URIs only', () {
      expect(
        InputValidator.isAllowedExternalUri(
          Uri.parse('https://github.com/MakeshVineeth/world_clock'),
        ),
        isTrue,
      );
      expect(
        InputValidator.isAllowedExternalUri(
          Uri.parse('market://details?id=com.makeshtech.clock'),
        ),
        isTrue,
      );
    });

    test('blocks insecure and dangerous schemes', () {
      expect(
        InputValidator.isAllowedExternalUri(Uri.parse('http://example.com')),
        isFalse,
      );
      expect(
        InputValidator.isAllowedExternalUri(Uri.parse('javascript:alert(1)')),
        isFalse,
      );
      expect(
        InputValidator.isAllowedExternalUri(Uri.parse('file:///etc/passwd')),
        isFalse,
      );
      expect(
        InputValidator.isAllowedExternalUri(Uri.parse('mailto:a@example.com')),
        isFalse,
      );
      expect(
        InputValidator.isAllowedExternalUri(Uri.parse('https:///nohost')),
        isFalse,
      );
      expect(
        InputValidator.isAllowedExternalUri(
          Uri.parse('https://user:pass@example.com'),
        ),
        isFalse,
      );
    });
  });

  group('InputValidator.sanitizeTempFilename', () {
    test('sanitizes unsafe path segments and invalid names', () {
      expect(
        InputValidator.sanitizeTempFilename('../../evil/file name?.txt'),
        equals('filename.txt'),
      );
      expect(InputValidator.sanitizeTempFilename('..'), isEmpty);
      expect(InputValidator.sanitizeTempFilename('...'), isEmpty);
      expect(
        InputValidator.sanitizeTempFilename('a' * 80).length,
        equals(InputValidator.maxFilenameLength),
      );
    });
  });
}
