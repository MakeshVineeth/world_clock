import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Architecture and hygiene invariants', () {
    test('domain layers do not import Flutter UI or platform plugins', () {
      final Directory featuresDir = Directory('lib/src/features');
      expect(featuresDir.existsSync(), isTrue);

      final List<String> forbiddenImportPrefixes = <String>[
        'package:flutter/',
        'package:material_ui/',
        'package:cupertino_ui/',
        'package:http/',
        'package:shared_preferences/',
        'package:url_launcher/',
        'package:google_fonts/',
        'package:country_icons/',
        'dart:io',
      ];

      final List<File> domainFiles = featuresDir
          .listSync(recursive: true)
          .whereType<File>()
          .where(
            (File file) =>
                file.path.endsWith('.dart') &&
                file.path.replaceAll('\\', '/').contains('/domain/'),
          )
          .toList();

      expect(domainFiles, isNotEmpty);

      for (final File file in domainFiles) {
        final String content = file.readAsStringSync();
        for (final String forbidden in forbiddenImportPrefixes) {
          expect(
            content.contains(forbidden),
            isFalse,
            reason:
                'Domain file ${file.path} must not import $forbidden',
          );
        }
      }
    });

    test('lib/ contains zero print() calls', () {
      final Directory libDir = Directory('lib');
      final RegExp printPattern = RegExp(r'(^|[^A-Za-z0-9_])print\s*\(');

      final List<File> dartFiles = libDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((File file) => file.path.endsWith('.dart'))
          .toList();

      expect(dartFiles, isNotEmpty);

      for (final File file in dartFiles) {
        final String content = file.readAsStringSync();
        expect(
          printPattern.hasMatch(content),
          isFalse,
          reason: 'File ${file.path} must use AppLogger instead of print()',
        );
      }
    });
  });
}
