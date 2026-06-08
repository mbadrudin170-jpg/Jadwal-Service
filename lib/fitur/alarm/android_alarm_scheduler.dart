// path: lib/shared/services/alarm/android_alarm_scheduler.dart
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/alarm/alarm_scheduler.dart';

final alarmSchedulerProvider = Provider<AlarmScheduler>((ref) {
  return AndroidAlarmScheduler();
});

class AndroidAlarmScheduler implements AlarmScheduler {
  Future<void> initialize() async {
    await AndroidAlarmManager.initialize();
  }

  @override
  Future<bool> scheduleOneShot(DateTime time, int id, void Function() callback, {
    bool wakeup = true,
    bool exact = true,
  }) {
    return AndroidAlarmManager.oneShotAt(
      time,
      id,
      callback,
      wakeup: wakeup,
      exact: exact,
    );
  }

  @override
  Future<bool> schedulePeriodic(Duration duration, int id, void Function() callback, {
    DateTime? startAt,
    bool exact = false,
    bool wakeup = false,
    bool rescheduleOnReboot = false,
  }) {
    return AndroidAlarmManager.periodic(
      duration,
      id,
      callback,
      startAt: startAt,
      exact: exact,
      wakeup: wakeup,
      rescheduleOnReboot: rescheduleOnReboot,
    );
  }

  @override
  Future<bool> oneShotAt(DateTime time, int id, void Function() callback, {
    bool exact = false,
    bool wakeup = false,
    bool rescheduleOnReboot = false,
  }) {
    return AndroidAlarmManager.oneShotAt(
      time,
      id,
      callback,
      exact: exact,
      wakeup: wakeup,
      rescheduleOnReboot: rescheduleOnReboot,
    );
  }

  @override
  Future<bool> cancel(int id) {
    return AndroidAlarmManager.cancel(id);
  }
}
