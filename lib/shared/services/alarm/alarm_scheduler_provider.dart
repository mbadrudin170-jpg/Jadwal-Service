// path: lib/shared/services/alarm/alarm_scheduler_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/shared/services/alarm/alarm_scheduler.dart';
import 'package:wifi/shared/services/alarm/android_alarm_scheduler.dart';

/// Provider yang menyediakan instance dari [AlarmScheduler].
final alarmSchedulerProvider = Provider<AlarmScheduler>((ref) {
  return AndroidAlarmScheduler();
});
