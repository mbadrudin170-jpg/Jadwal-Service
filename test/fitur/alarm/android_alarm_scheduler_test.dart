// path: test/fitur/alarm/android_alarm_scheduler_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/fitur/alarm/android_alarm_scheduler.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('AndroidAlarmScheduler', () {
    late AndroidAlarmScheduler scheduler;

    setUp(() {
      scheduler = AndroidAlarmScheduler();
    });

    test('01. initialize should not throw', () async {
      await expectLater(scheduler.initialize(), completes);
    });

    test('02. scheduleOneShot should not throw', () async {
      final time = DateTime.now();
      const id = 1;
      void callback() {}

      await expectLater(
          scheduler.scheduleOneShot(time, id, callback,
              wakeup: true, exact: true),
          completes);
    });

    test('03. schedulePeriodic should not throw', () async {
      const duration = Duration(minutes: 15);
      const id = 2;
      void callback() {}

      await expectLater(
          scheduler.schedulePeriodic(duration, id, callback,
              exact: true, wakeup: true, rescheduleOnReboot: true),
          completes);
    });

    test('04. cancel should not throw', () async {
      const id = 1;
      await expectLater(scheduler.cancel(id), completes);
    });
  });
}
