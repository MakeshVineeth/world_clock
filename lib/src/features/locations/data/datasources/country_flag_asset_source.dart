import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_clock/src/core/constants/app_constants.dart';
import 'package:flutter_clock/src/core/logging/app_logger.dart';

/// Abstraction for loading timezone-to-ISO-country-code mappings.
abstract interface class CountryFlagAssetSource {
  Future<Map<String, String>> loadCountryCodes();
}

/// Loads `assets/countries.json` from the bundled Flutter [AssetBundle].
class AssetCountryFlagSource implements CountryFlagAssetSource {
  final AssetBundle _bundle;
  final String _assetPath;
  Map<String, String>? _cached;

  AssetCountryFlagSource({
    AssetBundle? bundle,
    this._assetPath = AppConstants.countriesAssetPath,
  }) : _bundle = bundle ?? rootBundle;

  @override
  Future<Map<String, String>> loadCountryCodes() async {
    if (_cached != null) {
      return _cached!;
    }

    try {
      final String rawJson = await _bundle.loadString(_assetPath);
      final Object? decoded = jsonDecode(rawJson);
      if (decoded is! Map<String, Object?>) {
        return const <String, String>{};
      }

      final Map<String, String> parsed = <String, String>{};
      for (final MapEntry<String, Object?> entry in decoded.entries) {
        final Object? value = entry.value;
        if (value is String && value.trim().isNotEmpty) {
          parsed[entry.key] = value.trim();
        }
      }
      _cached = parsed;
      return parsed;
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Failed to load country flag mapping asset',
        error: error,
        stackTrace: stackTrace,
      );
      return const <String, String>{};
    }
  }
}
