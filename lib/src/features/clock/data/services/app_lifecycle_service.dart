import 'dart:io' show Platform, exit;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_clock/src/core/constants/app_constants.dart';
import 'package:flutter_clock/src/core/logging/app_logger.dart';
import 'package:flutter_clock/src/features/clock/domain/services/app_lifecycle_service.dart';

/// Platform implementation preserving original Android/desktop exit behavior.
class PlatformAppLifecycleService implements AppLifecycleService {
  final MethodChannel _channel;

  PlatformAppLifecycleService({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(AppConstants.exitMethodChannel);

  @override
  Future<void> exitApp() async {
    if (kIsWeb) {
      return;
    }

    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod<void>(AppConstants.exitMethodName);
      } catch (error, stackTrace) {
        AppLogger.warning(
          'Failed to send Android app to background',
          error: error,
          stackTrace: stackTrace,
        );
      }
      return;
    }

    if (!Platform.isIOS) {
      exit(0);
    }
  }
}
