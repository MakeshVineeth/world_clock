import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_clock/src/core/constants/app_constants.dart';
import 'package:flutter_clock/src/core/theme/app_theme.dart';
import 'package:flutter_clock/src/core/widgets/pulse_loading_indicator.dart';
import 'package:flutter_clock/src/features/clock/presentation/controllers/clock_controller.dart';
import 'package:flutter_clock/src/features/locations/domain/entities/timezone_location.dart';
import 'package:flutter_clock/src/features/locations/domain/repositories/location_repository.dart';
import 'package:flutter_clock/src/features/locations/presentation/controllers/locations_controller.dart';
import 'package:flutter_clock/src/features/locations/presentation/widgets/timezone_search_view.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

/// Timezone picker screen preserving original AppBar, spacing, and animations.
class LocationsScreen extends StatelessWidget {
  final LocationsController? controller;

  const LocationsScreen({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller != null) {
      return ChangeNotifierProvider<LocationsController>.value(
        value: controller!,
        child: const _LocationsView(shouldLoadOnInit: false),
      );
    }

    return ChangeNotifierProvider<LocationsController>(
      create: (BuildContext context) => LocationsController(
        repository: context.read<LocationRepository>(),
      ),
      child: const _LocationsView(shouldLoadOnInit: true),
    );
  }
}

class _LocationsView extends StatefulWidget {
  final bool shouldLoadOnInit;

  const _LocationsView({required this.shouldLoadOnInit});

  @override
  State<_LocationsView> createState() => _LocationsViewState();
}

class _LocationsViewState extends State<_LocationsView> {
  @override
  void initState() {
    super.initState();
    if (widget.shouldLoadOnInit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        unawaited(context.read<LocationsController>().loadLocations());
      });
    }
  }

  Future<void> _handleLocationSelected(TimezoneLocation location) async {
    final LocationsController locationsController = context
        .read<LocationsController>();
    final ClockController clockController = context.read<ClockController>();

    locationsController.setSelecting(true);
    try {
      await clockController.selectTimezone(
        location: location.displayName,
        url: location.timeZoneId,
        flag: location.flagAssetPath,
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        locationsController.setSelecting(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.locationsOverlayStyle,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Choose Location'),
          systemOverlayStyle: AppTheme.locationsOverlayStyle,
        ),
        body: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 5.0,
              vertical: 10.0,
            ),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return Consumer<LocationsController>(
                  builder:
                      (
                        BuildContext context,
                        LocationsController controller,
                        Widget? child,
                      ) {
                        return AnimatedCrossFade(
                          duration: AppConstants.locationsCrossFadeDuration,
                          crossFadeState: controller.showProgressIndicator
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          firstChild: SizedBox(
                            width: constraints.maxWidth,
                            height: constraints.maxHeight,
                            child: TimezoneSearchView(
                              locations: controller.locations,
                              searchResults: controller.searchResults,
                              isSearchActive: controller.isSearchActive,
                              isSearching: controller.isSearching,
                              hasError: controller.hasSearchError,
                              onQueryChanged: controller.onQueryChanged,
                              onClear: controller.clearSearch,
                              onSelectLocation: (TimezoneLocation selected) =>
                                  unawaited(_handleLocationSelected(selected)),
                            ),
                          ),
                          secondChild: SizedBox(
                            width: constraints.maxWidth,
                            height: constraints.maxHeight,
                            child: const PulseLoadingIndicator(),
                          ),
                        );
                      },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
