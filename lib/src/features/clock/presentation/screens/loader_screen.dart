import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_clock/src/core/constants/app_constants.dart';
import 'package:flutter_clock/src/core/theme/app_theme.dart';
import 'package:flutter_clock/src/core/widgets/pulse_loading_indicator.dart';
import 'package:flutter_clock/src/features/clock/presentation/controllers/clock_controller.dart';
import 'package:flutter_clock/src/features/clock/presentation/screens/home_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

/// Initial splash/loading screen that transitions smoothly into [HomeScreen].
class LoaderScreen extends StatefulWidget {
  const LoaderScreen({super.key});

  @override
  State<LoaderScreen> createState() => _LoaderScreenState();
}

class _LoaderScreenState extends State<LoaderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      unawaited(context.read<ClockController>().initialize());
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isInitialized = context.select<ClockController, bool>(
      (ClockController controller) => controller.isInitialized,
    );

    return AnimatedSwitcher(
      duration: AppConstants.loaderSwitchDuration,
      child: isInitialized
          ? const HomeScreen(key: ValueKey<String>('home_screen'))
          : const _LoadingScaffold(key: ValueKey<String>('loading_screen')),
    );
  }
}

class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return const AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.homeOverlayStyle,
      child: Scaffold(
        backgroundColor: AppTheme.loaderBackgroundColor,
        body: PulseLoadingIndicator(color: Colors.white),
      ),
    );
  }
}
