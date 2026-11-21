import 'package:flutter_clock/src/features/clock/domain/entities/world_time.dart';

/// Domain contract for fetching and persisting world clock data.
abstract interface class ClockRepository {
  Future<WorldTime> fetchCurrentTime({
    required String location,
    required String url,
    required String flag,
  });

  Future<WorldTime> loadDefaultOrSavedClock();

  Future<void> saveSelectedClock(WorldTime worldTime);
}
