import 'package:flutter/services.dart';
import 'package:flutter_clock/src/core/security/input_validator.dart';
import 'package:flutter_clock/src/core/theme/app_theme.dart';
import 'package:flutter_clock/src/core/theme/app_typography.dart';
import 'package:flutter_clock/src/core/widgets/pulse_loading_indicator.dart';
import 'package:flutter_clock/src/features/locations/domain/entities/timezone_location.dart';
import 'package:flutter_clock/src/features/locations/presentation/widgets/location_list_item.dart';
import 'package:material_ui/material_ui.dart';

/// Pure-Flutter search bar and list matching the original `flappy_search_bar_ns` UI.
class TimezoneSearchView extends StatefulWidget {
  final List<TimezoneLocation> locations;
  final List<TimezoneLocation> searchResults;
  final bool isSearchActive;
  final bool isSearching;
  final bool hasError;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClear;
  final ValueChanged<TimezoneLocation> onSelectLocation;

  const TimezoneSearchView({
    super.key,
    required this.locations,
    required this.searchResults,
    required this.isSearchActive,
    required this.isSearching,
    required this.hasError,
    required this.onQueryChanged,
    required this.onClear,
    required this.onSelectLocation,
  });

  @override
  State<TimezoneSearchView> createState() => _TimezoneSearchViewState();
}

class _TimezoneSearchViewState extends State<TimezoneSearchView> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (!mounted || _hasFocus == _focusNode.hasFocus) {
      return;
    }
    setState(() => _hasFocus = _focusNode.hasFocus);
  }

  void _handleCancel() {
    _textController.clear();
    _focusNode.unfocus();
    widget.onClear();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildSearchBarRow(),
        Expanded(
          child: _buildBodyContent(),
        ),
      ],
    );
  }

  Widget _buildSearchBarRow() {
    final bool showCancel = widget.isSearchActive || widget.isSearching;
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: SizedBox(
        height: 80.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: AppTheme.circleRadius,
                  color: AppTheme.searchBarFillColor,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    onChanged: widget.onQueryChanged,
                    inputFormatters: <TextInputFormatter>[
                      LengthLimitingTextInputFormatter(
                        InputValidator.maxSearchQueryLength,
                      ),
                    ],
                    style: AppTypography.boldLabelStyle,
                    decoration: InputDecoration(
                      icon: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: Icon(
                          Icons.search,
                          color: _hasFocus ? AppTheme.primaryColor : null,
                        ),
                      ),
                      border: InputBorder.none,
                      hintText: 'Search Timezones',
                      hintStyle: const TextStyle(
                        color: AppTheme.searchHintColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: showCancel
                  ? GestureDetector(
                      onTap: _handleCancel,
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedOpacity(
                        opacity: showCancel ? 1.0 : 0.0,
                        curve: Curves.easeIn,
                        duration: const Duration(milliseconds: 150),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 8.0,
                          ),
                          child: Text(
                            'Cancel',
                            maxLines: 1,
                            style: AppTypography.boldLabelStyle,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyContent() {
    if (widget.hasError) {
      return const Center(
        child: Text(
          'Error',
          style: AppTypography.boldLabelStyle,
        ),
      );
    }
    if (widget.isSearching) {
      return const PulseLoadingIndicator();
    }
    if (!widget.isSearchActive) {
      return _buildLocationList(widget.locations);
    }
    if (widget.searchResults.isNotEmpty) {
      return _buildLocationList(widget.searchResults);
    }
    return const Center(
      child: Text(
        'No Results',
        style: AppTypography.boldLabelStyle,
      ),
    );
  }

  Widget _buildLocationList(List<TimezoneLocation> items) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      itemCount: items.length,
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: 5.0),
      itemBuilder: (BuildContext context, int index) {
        final TimezoneLocation item = items[index];
        return LocationListItem(
          location: item,
          onTap: () => widget.onSelectLocation(item),
        );
      },
    );
  }
}
