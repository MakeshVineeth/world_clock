import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_clock/src/core/constants/app_constants.dart';
import 'package:flutter_clock/src/core/security/external_url_launcher.dart';
import 'package:flutter_clock/src/core/theme/app_theme.dart';
import 'package:flutter_clock/src/features/clock/domain/services/app_lifecycle_service.dart';
import 'package:flutter_clock/src/features/clock/presentation/controllers/clock_controller.dart';
import 'package:flutter_clock/src/features/clock/presentation/widgets/clock_display.dart';
import 'package:flutter_clock/src/features/clock/presentation/widgets/hd_scene_background.dart';
import 'package:flutter_clock/src/features/clock/presentation/widgets/home_overflow_menu.dart';
import 'package:flutter_clock/src/features/locations/presentation/screens/locations_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

/// Primary clock screen with 24-bit QHD+ day/night background and overflow menu.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const AssetImage _dayImage = AssetImage(
    AppConstants.dayBackgroundAsset,
  );
  static const AssetImage _nightImage = AssetImage(
    AppConstants.nightBackgroundAsset,
  );

  @override
  Widget build(BuildContext context) {
    final bool isDayTime = context.select<ClockController, bool>(
      (ClockController controller) => controller.currentClock.isDayTime,
    );
    final Size screenSize = MediaQuery.sizeOf(context);
    final AssetImage backgroundAsset = isDayTime ? _dayImage : _nightImage;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.homeOverlayStyle,
      child: Container(
        height: screenSize.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: backgroundAsset,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
          ),
        ),
        child: HdSceneBackground(
          isDayTime: isDayTime,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return RefreshIndicator(
                    onRefresh: () =>
                        context.read<ClockController>().refreshCurrentClock(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: const Center(
                          child: ClockDisplay(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            floatingActionButton: HomeOverflowMenu(
              onSelected: (HomeMenuAction action) =>
                  unawaited(_handleMenuAction(context, action)),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.miniEndTop,
          ),
        ),
      ),
    );
  }

  Future<void> _handleMenuAction(
    BuildContext context,
    HomeMenuAction action,
  ) async {
    switch (action) {
      case HomeMenuAction.changeLocation:
        await _openLocationsScreen(context);
      case HomeMenuAction.playStore:
        await context.read<ExternalUrlLauncher>().openUrl(
          AppConstants.playStoreUrl,
        );
      case HomeMenuAction.github:
        await context.read<ExternalUrlLauncher>().openUrl(
          AppConstants.githubUrl,
        );
      case HomeMenuAction.about:
        _displayAboutDialog(context);
      case HomeMenuAction.exit:
        await context.read<AppLifecycleService>().exitApp();
    }
  }

  Future<void> _openLocationsScreen(BuildContext context) {
    return Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        transitionDuration: AppConstants.routeFadeDuration,
        reverseTransitionDuration: AppConstants.routeFadeDuration,
        pageBuilder:
            (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) => const LocationsScreen(),
        transitionsBuilder:
            (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child,
            ) => FadeTransition(
              opacity: animation,
              child: child,
            ),
      ),
    );
  }

  void _displayAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationIcon: const Padding(
        padding: EdgeInsets.all(6.0),
        child: Image(
          width: 44.0,
          height: 44.0,
          filterQuality: FilterQuality.medium,
          isAntiAlias: true,
          image: AssetImage(AppConstants.appIconAsset),
        ),
      ),
      applicationVersion: AppConstants.appVersion,
      applicationLegalese: AppConstants.appLegalese,
    );
  }
}
