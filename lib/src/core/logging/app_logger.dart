import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Debug-only logger avoiding release console leakage and `print` calls.
abstract final class AppLogger {
  static const String _loggerName = 'FlutterClock';

  static void debug(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!kDebugMode) {
      return;
    }
    developer.log(
      message,
      name: _loggerName,
      level: 500,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void warning(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!kDebugMode) {
      return;
    }
    developer.log(
      message,
      name: _loggerName,
      level: 900,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
