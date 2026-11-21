import 'package:flutter_clock/src/core/theme/app_typography.dart';
import 'package:material_ui/material_ui.dart';

/// Menu actions available in the top-right overflow menu on [HomeScreen].
enum HomeMenuAction {
  changeLocation,
  playStore,
  github,
  about,
  exit,
}

/// Top-right overflow popup menu matching the original five entries.
class HomeOverflowMenu extends StatelessWidget {
  final ValueChanged<HomeMenuAction> onSelected;

  const HomeOverflowMenu({
    super.key,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<HomeMenuAction>(
      itemBuilder: (BuildContext context) => const <PopupMenuEntry<HomeMenuAction>>[
        PopupMenuItem<HomeMenuAction>(
          value: HomeMenuAction.changeLocation,
          child: Text('Change Location', style: AppTypography.menuItemStyle),
        ),
        PopupMenuItem<HomeMenuAction>(
          value: HomeMenuAction.playStore,
          child: Text('Play Store', style: AppTypography.menuItemStyle),
        ),
        PopupMenuItem<HomeMenuAction>(
          value: HomeMenuAction.github,
          child: Text('GitHub', style: AppTypography.menuItemStyle),
        ),
        PopupMenuItem<HomeMenuAction>(
          value: HomeMenuAction.about,
          child: Text('About', style: AppTypography.menuItemStyle),
        ),
        PopupMenuItem<HomeMenuAction>(
          value: HomeMenuAction.exit,
          child: Text('Exit', style: AppTypography.menuItemStyle),
        ),
      ],
      offset: const Offset(0, 50),
      elevation: 5.0,
      color: Colors.white,
      icon: const Icon(
        Icons.more_vert,
        color: Colors.white,
      ),
      onSelected: onSelected,
    );
  }
}
