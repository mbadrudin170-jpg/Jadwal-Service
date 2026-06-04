// path: lib/shared/services/alarm/alarm_scheduler.dart

/// Abstract class untuk menjadwalkan alarm.
/// Ini memungkinkan untuk menukar implementasi (misalnya, untuk pengujian).
abstract class AlarmScheduler {
  /// Menjadwalkan alarm satu kali pada waktu yang ditentukan.
  Future<bool> scheduleOneShot(
    DateTime time,
    int id,
    void Function() callback, {
    bool wakeup,
    bool exact,
  });

  /// Menjadwalkan alarm periodik.
  Future<bool> schedulePeriodic(
    Duration duration,
    int id,
    void Function() callback, {
    DateTime? startAt,
    bool exact,
    bool wakeup,
    bool rescheduleOnReboot,
  });

  /// Menjadwalkan alarm sekali jalan pada waktu yang ditentukan.
  Future<bool> oneShotAt(
    DateTime time,
    int id,
    void Function() callback, {
    bool exact = false,
    bool wakeup = false,
    bool rescheduleOnReboot = false,
  });

  /// Membatalkan alarm dengan ID yang diberikan.
  Future<bool> cancel(int id);
}
