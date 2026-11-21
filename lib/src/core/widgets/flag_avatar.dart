import 'package:flutter_clock/src/core/security/input_validator.dart';
import 'package:material_ui/material_ui.dart';

/// Circular HD country flag avatar implemented natively in Flutter.
class FlagAvatar extends StatelessWidget {
  final String assetPath;
  final double size;

  const FlagAvatar({
    super.key,
    required this.assetPath,
    this.size = 25.0,
  });

  @override
  Widget build(BuildContext context) {
    final String hdPath = InputValidator.toHdFlagAssetPath(assetPath);
    if (hdPath.isEmpty) {
      return const SizedBox.square(dimension: 1.0);
    }

    return SizedBox.square(
      dimension: size,
      child: ClipOval(
        child: Image.asset(
          hdPath,
          package: 'country_icons',
          width: size,
          height: size,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          isAntiAlias: true,
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => SizedBox.square(dimension: size),
        ),
      ),
    );
  }
}
