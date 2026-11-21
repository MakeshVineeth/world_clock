/// Pure-Dart input validation and sanitization helpers.
abstract final class InputValidator {
  static const int maxTimeZoneLength = 64;
  static const int maxSearchQueryLength = 64;
  static const int maxFilenameLength = 64;

  static final RegExp _timeZonePattern = RegExp(r'^[A-Za-z0-9_+\-/]{1,64}$');
  static final RegExp _flagAssetPattern = RegExp(
    r'^icons/flags/png(100|250|1000)px/([a-z]{2})\.png$',
  );
  static final RegExp _svgFlagAssetPattern = RegExp(
    r'^icons/flags/svg/([a-z]{2})\.svg$',
  );
  static final RegExp _legacyFlagAssetPattern = RegExp(
    r'^icons/flags/png/([a-z]{2})\.png$',
  );
  static final RegExp _controlCharsPattern = RegExp(r'[\x00-\x1F\x7F]');
  static final RegExp _whitespaceRunPattern = RegExp(r'\s+');
  static final RegExp _unsafeFilenameCharsPattern = RegExp(
    r'[^A-Za-z0-9._-]',
  );

  /// Validates an IANA-style timezone identifier (e.g. `Asia/Kolkata`).
  static bool isValidTimeZoneId(String value) {
    final String trimmed = value.trim();
    if (!_timeZonePattern.hasMatch(trimmed)) {
      return false;
    }
    if (trimmed.startsWith('/') || trimmed.endsWith('/')) {
      return false;
    }
    if (trimmed.contains('..') || trimmed.contains('//')) {
      return false;
    }
    return true;
  }

  /// Strips control characters, collapses whitespace, and clamps length.
  static String sanitizeSearchQuery(String query) {
    final String cleaned = query
        .replaceAll(_controlCharsPattern, '')
        .replaceAll(_whitespaceRunPattern, ' ')
        .trim();
    if (cleaned.length <= maxSearchQueryLength) {
      return cleaned;
    }
    return cleaned.substring(0, maxSearchQueryLength);
  }

  /// Validates and upgrades country flag asset paths to `png100px`.
  ///
  /// Returns an empty string if [rawPath] does not match an expected flag path.
  static String normalizeFlagAssetPath(String rawPath) {
    final String trimmed = rawPath.trim();
    if (trimmed.isEmpty || trimmed.contains('..')) {
      return '';
    }
    final RegExpMatch? directMatch = _flagAssetPattern.firstMatch(trimmed);
    if (directMatch != null) {
      final String? code = directMatch.group(2);
      if (code != null) {
        return 'icons/flags/png100px/$code.png';
      }
    }
    final RegExpMatch? svgMatch = _svgFlagAssetPattern.firstMatch(trimmed);
    if (svgMatch != null) {
      final String? code = svgMatch.group(1);
      if (code != null) {
        return 'icons/flags/png100px/$code.png';
      }
    }
    final RegExpMatch? legacyMatch = _legacyFlagAssetPattern.firstMatch(
      trimmed,
    );
    if (legacyMatch != null) {
      final String? countryCode = legacyMatch.group(1);
      if (countryCode != null) {
        return 'icons/flags/png100px/$countryCode.png';
      }
    }
    return '';
  }

  /// Resolves a validated flag path to its high-definition `png250px` asset.
  static String toHdFlagAssetPath(String rawPath) {
    final String normalized = normalizeFlagAssetPath(rawPath);
    if (normalized.isEmpty) {
      return '';
    }
    return normalized.replaceFirst(
      'icons/flags/png100px/',
      'icons/flags/png250px/',
    );
  }

  /// Resolves a validated flag path to its vector `svg` asset in `country_icons`.
  static String toVectorFlagAssetPath(String rawPath) {
    final String normalized = normalizeFlagAssetPath(rawPath);
    if (normalized.isEmpty) {
      return '';
    }
    return normalized
        .replaceFirst('icons/flags/png100px/', 'icons/flags/svg/')
        .replaceFirst(RegExp(r'\.png$'), '.svg');
  }

  /// Allows only external `https` (with non-empty host, no userinfo) or `market` URIs.
  static bool isAllowedExternalUri(Uri uri) {
    final String scheme = uri.scheme.toLowerCase();
    if (scheme == 'https') {
      return uri.hasAuthority && uri.host.isNotEmpty && uri.userInfo.isEmpty;
    }
    if (scheme == 'market') {
      return uri.host.isNotEmpty || uri.path.isNotEmpty;
    }
    return false;
  }

  /// Sanitizes a temporary filename to prevent path traversal and invalid chars.
  ///
  /// Returns an empty string when no safe filename remains.
  static String sanitizeTempFilename(String filename) {
    final String base = filename.split(RegExp(r'[/\\]')).last;
    final String stripped = base
        .replaceAll('..', '')
        .replaceAll(_unsafeFilenameCharsPattern, '');
    if (stripped.isEmpty || _isDotOnly(stripped)) {
      return '';
    }
    if (stripped.length <= maxFilenameLength) {
      return stripped;
    }
    return stripped.substring(0, maxFilenameLength);
  }

  static bool _isDotOnly(String value) {
    for (int i = 0; i < value.length; i++) {
      if (value.codeUnitAt(i) != 46) {
        return false;
      }
    }
    return true;
  }
}
