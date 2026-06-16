// path: test/fitur/alarm/android_alarm_scheduler_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:wifi/fitur/alarm/android_alarm_scheduler.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// Mocks
class MockAndroidAlarmManager extends Mock
    with MockPlatformInterfaceMixin
    implements AndroidAlarmManager {}

void main() {
  group('AndroidAlarmScheduler', () {
    late AndroidAlarmScheduler scheduler;
    late MockAndroidAlarmManager mockAlarmManager;

    setUp(() {
      scheduler = AndroidAlarmScheduler();
      mockAlarmManager = MockAndroidAlarmManager();
      AndroidAlarmManager.instance = mockAlarmManager;
    });

    test('01. initialize should call AndroidAlarmManager.initialize', () async {
      when(() => mockAlarmManager.initialize()).thenAnswer((_) async => true);
      await scheduler.initialize();
      verify(() => mockAlarmManager.initialize()).called(1);
    });

    test('02. scheduleOneShot should call AndroidAlarmManager.oneShotAt',
        () async {
      final time = DateTime.now();
      const id = 1;
      void callback() {}
      when(() => mockAlarmManager.oneShotAt(any(), any(), any(),
              alarmClock: any(named: 'alarmClock'),
              allowWhileIdle: any(named: 'allowWhileIdle'),
              exact: any(named: 'exact'),
              wakeup: any(named: 'wakeup'),
              rescheduleOnReboot: any(named: 'rescheduleOnReboot')))
          .thenAnswer((_) async => true);

      await scheduler.scheduleOneShot(time, id, callback,
          wakeup: true, exact: true);

      verify(() => mockAlarmManager.oneShotAt(time, id, callback,
          exact: true,
          wakeup: true,
          allowWhileIdle: false,
          alarmClock: false,
          rescheduleOnReboot: false)).called(1);
    });

    test('03. schedulePeriodic should call AndroidAlarmManager.periodic',
        () async {
      const duration = Duration(minutes: 15);
      const id = 2;
      void callback() {}
      when(() => mockAlarmManager.periodic(any(), any(), any(),
              startAt: any(named: 'startAt'),
              exact: any(named: 'exact'),
              wakeup: any(named: 'wakeup'),
              rescheduleOnReboot: any(named: 'rescheduleOnReboot')))
          .thenAnswer((_) async => true);

      await scheduler.schedulePeriodic(duration, id, callback,
          exact: true, wakeup: true, rescheduleOnReboot: true);

      verify(() => mockAlarmManager.periodic(duration, id, callback,
          startAt: null,
          exact: true,
          wakeup: true,
          rescheduleOnReboot: true)).called(1);
    });

    test('04. cancel should call AndroidAlarmManager.cancel', () async {
      const id = 1;
      when(() => mockAlarmManager.cancel(any())).thenAnswer((_) async => true);
      await scheduler.cancel(id);
      verify(() => mockAlarmManager.cancel(id)).called(1);
    });
  });
}
