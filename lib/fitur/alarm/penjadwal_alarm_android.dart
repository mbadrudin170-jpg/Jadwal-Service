// path: lib/shared/services/alarm/android_alarm_scheduler.dart
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/alarm/penjadwal_alarm.dart';

final penjadwalAlarmProvider = Provider<PenjadwalAlarm>((ref) {
  return PenjadwalAlarmAndroid();
});

class PenjadwalAlarmAndroid implements PenjadwalAlarm {
  Future<void> initialize() async {
    await AndroidAlarmManager.initialize();
  }

  @override
  Future<bool> jadwalkanSekali(
    DateTime time,
    int id,
    void Function() callback, {
    bool bangunkan = true,
    bool tepatWaktu = true,
  }) {
    return AndroidAlarmManager.oneShotAt(
      time,
      id,
      callback,
      wakeup: bangunkan,
      exact: tepatWaktu,
    );
  }

  @override
  Future<bool> jadwalkanPeriodik(
    Duration duration,
    int id,
    void Function() callback, {
    DateTime? mulaiPada,
    bool tepatWaktu = false,
    bool bangunkan = false,
    bool jadwalkanUlangSaatBoot = false,
  }) {
    return AndroidAlarmManager.periodic(
      duration,
      id,
      callback,
      startAt: mulaiPada,
      exact: tepatWaktu,
      wakeup: bangunkan,
      rescheduleOnReboot: jadwalkanUlangSaatBoot,
    );
  }

  @override
  Future<bool> jadwalkanSekaliPada(
    DateTime time,
    int id,
    void Function() callback, {
    bool tepatWaktu = false,
    bool bangunkan = false,
    bool jadwalkanUlangSaatBoot = false,
  }) {
    return AndroidAlarmManager.oneShotAt(
      time,
      id,
      callback,
      exact: tepatWaktu,
      wakeup: bangunkan,
      rescheduleOnReboot: jadwalkanUlangSaatBoot,
    );
  }

  @override
  Future<bool> batalkan(int id) {
    return AndroidAlarmManager.cancel(id);
  }
}
