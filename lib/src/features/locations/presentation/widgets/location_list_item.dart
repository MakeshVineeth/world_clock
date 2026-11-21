import 'package:flutter_clock/src/core/theme/app_theme.dart';
import 'package:flutter_clock/src/core/theme/app_typography.dart';
import 'package:flutter_clock/src/core/widgets/flag_avatar.dart';
import 'package:flutter_clock/src/features/locations/domain/entities/timezone_location.dart';
import 'package:material_ui/material_ui.dart';

/// List row displaying a country flag avatar and formatted timezone name.
class LocationListItem extends StatelessWidget {
  final TimezoneLocation location;
  final VoidCallback onTap;

  const LocationListItem({
    super.key,
    required this.location,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: AppTheme.circleRadius),
        leading: FlagAvatar(assetPath: location.flagAssetPath),
        title: Text(
          location.displayName,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.boldLabelStyle,
        ),
      ),
    );
  }
}
