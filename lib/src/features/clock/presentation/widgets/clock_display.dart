import 'package:flutter_clock/src/core/theme/app_typography.dart';
import 'package:flutter_clock/src/core/widgets/flag_avatar.dart';
import 'package:flutter_clock/src/features/clock/domain/entities/world_time.dart';
import 'package:flutter_clock/src/features/clock/presentation/controllers/clock_controller.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

/// Displays the selected location flag, place name, time, and date.
class ClockDisplay extends StatelessWidget {
  const ClockDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final WorldTime worldTime = context.select<ClockController, WorldTime>(
      (ClockController controller) => controller.currentClock,
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: FlagAvatar(assetPath: worldTime.flag),
              ),
              const SizedBox(width: 8.0),
              Flexible(
                child: Text(
                  worldTime.location,
                  softWrap: true,
                  textAlign: TextAlign.center,
                  style: AppTypography.locationStyle,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              worldTime.time,
              style: AppTypography.clockTimeStyle(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(
            worldTime.date,
            textAlign: TextAlign.center,
            style: AppTypography.dateStyle,
          ),
        ),
      ],
    );
  }
}
