import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_clock/src/features/clock/domain/entities/world_time.dart';
import 'package:flutter_clock/src/features/clock/domain/repositories/clock_repository.dart';

/// Presentation controller managing current world clock state and refresh timer.
class ClockController extends ChangeNotifier {
  final ClockRepository _repository;
  final bool _enableAutoRefresh;

  WorldTime _currentClock = WorldTime.initialPlaceholder;
  bool _isInitialized = false;
  bool _isRefreshing = false;
  bool _isDisposed = false;
  Timer? _refreshTimer;

  ClockController({
    required this._repository,
    this._enableAutoRefresh = true,
  });

  WorldTime get currentClock => _currentClock;
  bool get isInitialized => _isInitialized;
  bool get isRefreshing => _isRefreshing;

  Future<void> initialize() async {
    if (_isInitialized || _isDisposed) {
      return;
    }

    final WorldTime initialClock = await _repository.loadDefaultOrSavedClock();
    if (_isDisposed) {
      return;
    }

    _currentClock = initialClock;
    _isInitialized = true;
    _scheduleNextRefresh();
    notifyListeners();
  }

  Future<bool> refreshCurrentClock() async {
    if (_isDisposed || _currentClock.url.trim().isEmpty) {
      return false;
    }

    _isRefreshing = true;
    try {
      final WorldTime updated = await _repository.fetchCurrentTime(
        location: _currentClock.location,
        url: _currentClock.url,
        flag: _currentClock.flag,
      );
      if (_isDisposed) {
        return false;
      }
      _currentClock = updated;
      _scheduleNextRefresh();
      notifyListeners();
      return true;
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> selectTimezone({
    required String location,
    required String url,
    required String flag,
  }) async {
    final WorldTime updated = await _repository.fetchCurrentTime(
      location: location,
      url: url,
      flag: flag,
    );
    if (_isDisposed) {
      return;
    }

    _currentClock = updated;
    _isInitialized = true;
    _scheduleNextRefresh();
    notifyListeners();
    await _repository.saveSelectedClock(updated);
  }

  void _scheduleNextRefresh() {
    _refreshTimer?.cancel();
    if (!_enableAutoRefresh || _isDisposed) {
      return;
    }

    final int delaySeconds = _currentClock.secondsLeft.clamp(1, 60);
    _refreshTimer = Timer(
      Duration(seconds: delaySeconds),
      () => unawaited(_handleScheduledTick()),
    );
  }

  Future<void> _handleScheduledTick() async {
    if (_isDisposed) {
      return;
    }
    await refreshCurrentClock();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _refreshTimer?.cancel();
    _refreshTimer = null;
    super.dispose();
  }
}
