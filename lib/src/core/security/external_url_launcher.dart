import 'package:flutter_clock/src/core/logging/app_logger.dart';
import 'package:flutter_clock/src/core/security/input_validator.dart';
import 'package:url_launcher/url_launcher.dart';

/// Contract for launching validated external URLs.
abstract interface class ExternalUrlLauncher {
  Future<bool> openUrl(String rawUrl);
}

/// Launches external URLs after strict URI scheme validation.
class UrlLauncherService implements ExternalUrlLauncher {
  const UrlLauncherService();

  @override
  Future<bool> openUrl(String rawUrl) async {
    final Uri? parsed = Uri.tryParse(rawUrl.trim());
    if (parsed == null || !InputValidator.isAllowedExternalUri(parsed)) {
      AppLogger.warning('Blocked disallowed external URL: $rawUrl');
      return false;
    }

    try {
      return await launchUrl(parsed, mode: LaunchMode.externalApplication);
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Failed to launch external URL',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }
}
