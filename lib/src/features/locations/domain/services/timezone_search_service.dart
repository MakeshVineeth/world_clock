import 'dart:math' as math;

import 'package:flutter_clock/src/core/security/input_validator.dart';
import 'package:flutter_clock/src/features/locations/domain/entities/timezone_location.dart';

/// Pure-Dart fuzzy and token search service replacing legacy `fuzzy`.
class TimezoneSearchService {
  static const int minQueryLength = 2;

  const TimezoneSearchService();

  List<TimezoneLocation> search(
    List<TimezoneLocation> locations,
    String rawQuery,
  ) {
    final String sanitized = InputValidator.sanitizeSearchQuery(rawQuery);
    if (sanitized.length < minQueryLength || locations.isEmpty) {
      return const <TimezoneLocation>[];
    }

    final String normalizedQuery = _normalize(sanitized);
    if (normalizedQuery.length < minQueryLength) {
      return const <TimezoneLocation>[];
    }

    final List<String> queryTokens = normalizedQuery
        .split(' ')
        .where((String token) => token.isNotEmpty)
        .toList(growable: false);

    final List<_ScoredLocation> scored = <_ScoredLocation>[];
    for (final TimezoneLocation location in locations) {
      final int score = _scoreLocation(location, normalizedQuery, queryTokens);
      if (score > 0) {
        scored.add(_ScoredLocation(location: location, score: score));
      }
    }

    scored.sort(_compareScored);
    return scored
        .map((_ScoredLocation entry) => entry.location)
        .toList(growable: false);
  }

  int _compareScored(_ScoredLocation a, _ScoredLocation b) {
    final int byScore = b.score.compareTo(a.score);
    if (byScore != 0) {
      return byScore;
    }
    return a.location.displayName.compareTo(b.location.displayName);
  }

  int _scoreLocation(
    TimezoneLocation location,
    String normalizedQuery,
    List<String> queryTokens,
  ) {
    final String candidate = _normalize(
      '${location.displayName} ${location.timeZoneId}',
    );
    final List<String> candidateWords = candidate
        .split(' ')
        .where((String word) => word.isNotEmpty)
        .toList(growable: false);

    if (candidate.startsWith(normalizedQuery)) {
      return 100;
    }
    if (candidateWords.any((String w) => w.startsWith(normalizedQuery))) {
      return 85;
    }
    if (candidate.contains(normalizedQuery)) {
      return 70;
    }
    if (_allTokensMatchSubstring(candidate, queryTokens)) {
      return 55;
    }
    final int fuzzyScore = _scoreTokensFuzzy(candidateWords, queryTokens);
    if (fuzzyScore > 0) {
      return fuzzyScore;
    }
    if (_isSubsequence(normalizedQuery.replaceAll(' ', ''), candidate)) {
      return 20;
    }
    return 0;
  }

  bool _allTokensMatchSubstring(String candidate, List<String> queryTokens) {
    if (queryTokens.isEmpty) {
      return false;
    }
    return queryTokens.every(candidate.contains);
  }

  int _scoreTokensFuzzy(
    List<String> candidateWords,
    List<String> queryTokens,
  ) {
    if (candidateWords.isEmpty || queryTokens.isEmpty) {
      return 0;
    }

    int totalScore = 0;
    for (final String token in queryTokens) {
      final int tokenBest = _bestWordFuzzyScore(candidateWords, token);
      if (tokenBest == 0) {
        return 0;
      }
      totalScore += tokenBest;
    }
    return (totalScore / queryTokens.length).round();
  }

  int _bestWordFuzzyScore(List<String> candidateWords, String token) {
    final int maxAllowedDistance = token.length <= 2
        ? 0
        : (token.length <= 4 ? 1 : 2);
    int best = 0;

    for (final String word in candidateWords) {
      if (word.startsWith(token)) {
        return 50;
      }
      if (word.contains(token)) {
        best = math.max(best, 42);
        continue;
      }
      if (maxAllowedDistance > 0 &&
          (word.length - token.length).abs() <= maxAllowedDistance) {
        final int distance = _levenshteinDistance(token, word);
        if (distance <= maxAllowedDistance) {
          best = math.max(best, 40 - (distance * 10));
        }
      }
    }
    return best;
  }

  bool _isSubsequence(String needle, String haystack) {
    if (needle.isEmpty) {
      return false;
    }
    int needleIndex = 0;
    for (
      int i = 0;
      i < haystack.length && needleIndex < needle.length;
      i++
    ) {
      if (haystack.codeUnitAt(i) == needle.codeUnitAt(needleIndex)) {
        needleIndex++;
      }
    }
    return needleIndex == needle.length;
  }

  int _levenshteinDistance(String source, String target) {
    final int m = source.length;
    final int n = target.length;
    if (m == 0) {
      return n;
    }
    if (n == 0) {
      return m;
    }

    List<int> previous = List<int>.generate(n + 1, (int j) => j);
    List<int> current = List<int>.filled(n + 1, 0);

    for (int i = 1; i <= m; i++) {
      current[0] = i;
      final int sourceChar = source.codeUnitAt(i - 1);
      for (int j = 1; j <= n; j++) {
        final int substitutionCost = sourceChar == target.codeUnitAt(j - 1)
            ? 0
            : 1;
        current[j] = math.min(
          math.min(current[j - 1] + 1, previous[j] + 1),
          previous[j - 1] + substitutionCost,
        );
      }
      final List<int> swap = previous;
      previous = current;
      current = swap;
    }
    return previous[n];
  }

  String _normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[/,_,-]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

class _ScoredLocation {
  final TimezoneLocation location;
  final int score;

  const _ScoredLocation({
    required this.location,
    required this.score,
  });
}
