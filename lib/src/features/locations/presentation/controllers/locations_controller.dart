import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_clock/src/core/constants/app_constants.dart';
import 'package:flutter_clock/src/core/security/input_validator.dart';
import 'package:flutter_clock/src/features/locations/domain/entities/timezone_location.dart';
import 'package:flutter_clock/src/features/locations/domain/repositories/location_repository.dart';
import 'package:flutter_clock/src/features/locations/domain/services/timezone_search_service.dart';

/// Controller managing timezone list loading, debounced search, and selection state.
class LocationsController extends ChangeNotifier {
  final LocationRepository _repository;
  final TimezoneSearchService _searchService;
  final Duration _debounceDuration;

  List<TimezoneLocation> _locations = const <TimezoneLocation>[];
  List<TimezoneLocation> _searchResults = const <TimezoneLocation>[];
  String _query = '';
  bool _isLoading = true;
  bool _isSearching = false;
  bool _hasSearchError = false;
  bool _isSelecting = false;
  bool _isDisposed = false;
  Timer? _debounceTimer;

  LocationsController({
    required this._repository,
    this._searchService = const TimezoneSearchService(),
    this._debounceDuration = AppConstants.searchDebounceDuration,
  });

  List<TimezoneLocation> get locations => _locations;
  List<TimezoneLocation> get searchResults => _searchResults;
  String get query => _query;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  bool get hasSearchError => _hasSearchError;
  bool get isSelecting => _isSelecting;
  bool get isSearchActive =>
      _query.length >= TimezoneSearchService.minQueryLength;
  bool get showProgressIndicator => _isLoading || _isSelecting;

  Future<void> loadLocations() async {
    if (_isDisposed) {
      return;
    }
    _isLoading = true;
    notifyListeners();

    try {
      final List<TimezoneLocation> loaded = await _repository
          .fetchAvailableLocations();
      if (_isDisposed) {
        return;
      }
      _locations = List<TimezoneLocation>.unmodifiable(loaded);
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void onQueryChanged(String rawQuery) {
    if (_isDisposed) {
      return;
    }
    _debounceTimer?.cancel();

    final String sanitized = InputValidator.sanitizeSearchQuery(rawQuery);
    _query = sanitized;

    if (sanitized.length < TimezoneSearchService.minQueryLength) {
      _searchResults = const <TimezoneLocation>[];
      _isSearching = false;
      _hasSearchError = false;
      notifyListeners();
      return;
    }

    _isSearching = true;
    _hasSearchError = false;
    notifyListeners();

    _debounceTimer = Timer(_debounceDuration, () => _executeSearch(sanitized));
  }

  void clearSearch() {
    if (_isDisposed) {
      return;
    }
    _debounceTimer?.cancel();
    _query = '';
    _searchResults = const <TimezoneLocation>[];
    _isSearching = false;
    _hasSearchError = false;
    notifyListeners();
  }

  void setSelecting(bool selecting) {
    if (_isDisposed || _isSelecting == selecting) {
      return;
    }
    _isSelecting = selecting;
    notifyListeners();
  }

  void _executeSearch(String sanitizedQuery) {
    if (_isDisposed) {
      return;
    }

    try {
      final List<TimezoneLocation> results = _searchService.search(
        _locations,
        sanitizedQuery,
      );
      if (_isDisposed) {
        return;
      }
      _searchResults = List<TimezoneLocation>.unmodifiable(results);
      _hasSearchError = false;
    } catch (_) {
      if (_isDisposed) {
        return;
      }
      _searchResults = const <TimezoneLocation>[];
      _hasSearchError = true;
    } finally {
      if (!_isDisposed) {
        _isSearching = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _debounceTimer?.cancel();
    _debounceTimer = null;
    super.dispose();
  }
}
