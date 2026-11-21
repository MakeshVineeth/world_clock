import 'package:flutter_clock/src/features/clock/domain/entities/world_time.dart';
import 'package:flutter_clock/src/features/clock/domain/repositories/clock_repository.dart';
import 'package:flutter_clock/src/features/clock/presentation/controllers/clock_controller.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeClockRepository implements ClockRepository {
  WorldTime defaultClock = const WorldTime(
    location: 'Asia, Kolkata',
    url: 'Asia/Kolkata',
    flag: 'icons/flags/png100px/in.png',
    date: '24-May-2025',
    isDayTime: true,
    secondsLeft: 25,
    time: '3:00 PM',
  );

  WorldTime? lastSaved;
  int fetchCount = 0;

  @override
  Future<WorldTime> fetchCurrentTime({
    required String location,
    required String url,
    required String flag,
  }) async {
    fetchCount++;
    return WorldTime(
      location: location,
      url: url,
      flag: flag,
      date: '24-May-2025',
      isDayTime: url != 'America/New_York',
      secondsLeft: 30,
      time: '4:00 PM',
    );
  }

  @override
  Future<WorldTime> loadDefaultOrSavedClock() async => defaultClock;

  @override
  Future<void> saveSelectedClock(WorldTime worldTime) async {
    lastSaved = worldTime;
  }
}

void main() {
  group('ClockController', () {
    test('initializes once and updates state with default clock', () async {
      final _FakeClockRepository repository = _FakeClockRepository();
      final ClockController controller = ClockController(
        repository: repository,
        enableAutoRefresh: false,
      );
      addTearDown(controller.dispose);

      expect(controller.isInitialized, isFalse);
      await controller.initialize();
      await controller.initialize();

      expect(controller.isInitialized, isTrue);
      expect(controller.currentClock.location, equals('Asia, Kolkata'));
    });

    test('selectTimezone fetches, saves, and notifies listeners', () async {
      final _FakeClockRepository repository = _FakeClockRepository();
      final ClockController controller = ClockController(
        repository: repository,
        enableAutoRefresh: false,
      );
      addTearDown(controller.dispose);

      await controller.initialize();
      int notifications = 0;
      controller.addListener(() => notifications++);

      await controller.selectTimezone(
        location: 'America, New York',
        url: 'America/New_York',
        flag: 'icons/flags/png100px/us.png',
      );

      expect(notifications, equals(1));
      expect(controller.currentClock.url, equals('America/New_York'));
      expect(controller.currentClock.isDayTime, isFalse);
      expect(repository.lastSaved?.url, equals('America/New_York'));
    });

    test('refreshCurrentClock updates clock and cancels timer on dispose', () async {
      final _FakeClockRepository repository = _FakeClockRepository();
      final ClockController controller = ClockController(
        repository: repository,
        enableAutoRefresh: true,
      );

      await controller.initialize();
      final bool refreshed = await controller.refreshCurrentClock();

      expect(refreshed, isTrue);
      expect(repository.fetchCount, equals(1));
      expect(controller.currentClock.time, equals('4:00 PM'));

      controller.dispose();
    });
  });
}
