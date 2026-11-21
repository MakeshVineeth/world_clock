import 'package:flutter_clock/src/core/security/input_validator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

/// Vector SVG circular country flag avatar for infinite-DPI sharpness.
class FlagAvatar extends StatelessWidget {
  final String assetPath;
  final double size;

  const FlagAvatar({
    super.key,
    required this.assetPath,
    this.size = 28.0,
  });

  @override
  Widget build(BuildContext context) {
    final String svgPath = InputValidator.toVectorFlagAssetPath(assetPath);
    if (svgPath.isEmpty) {
      return const SizedBox.square(dimension: 1.0);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0x22000000),
          width: 0.75,
        ),
      ),
      child: ClipOval(
        child: SvgPicture.asset(
          svgPath,
          package: 'country_icons',
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholderBuilder: (_) => SizedBox.square(dimension: size),
        ),
      ),
    );
  }
}
