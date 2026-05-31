// path: lib/shared/services/boot_service.dart
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/operation.dart';
import 'package:wifi/shared/utils/alarm_utils.dart'; // import callback

final bootServiceProvider = Provider((ref) => BootService());

class BootService {
  // Anda bisa menambahkan 'final Ref ref;' dan constructor jika ingin
  // mengakses provider lain di masa depan.
  BootService();

  Future<void> rescheduleAlarmsOnBoot(ProviderContainer container) async {
    Log.info('[BOOT] Memulai proses penjadwalan ulang alarm setelah boot.');
    try {
      // Gunakan data LOKAL (SQLite) karena internet mungkin belum siap saat boot
      final activeCustomerOp = container.read(activeCustomerOperationProvider);
      final activeCustomers = await activeCustomerOp.getAllActiveCustomers();

      if (activeCustomers.isEmpty) {
        Log.warning(
            '[BOOT] Tidak ada pelanggan aktif untuk dijadwalkan ulang.');
        return;
      }

      int scheduledCount = 0;
      for (final customer in activeCustomers) {
        if (customer.endDate.isAfter(DateTime.now())) {
          final alarmId = customer.id.hashCode;
          final scheduledTime = customer.endDate;

          // BATALKAN alarm lama dengan ID yang sama sebelum menjadwalkan ulang
          await AndroidAlarmManager.cancel(alarmId);

          await AndroidAlarmManager.oneShotAt(
            scheduledTime,
            alarmId,
            alarmCallback, // ← perbaiki nama callback
            exact: true,
            wakeup: true,
          );
          Log.info(
              '[BOOT] Alarm dijadwalkan untuk customer ${customer} pada $scheduledTime');
          scheduledCount++;
        }
      }
      Log.info('[BOOT] Selesai menjadwalkan $scheduledCount alarm.');
    } catch (e, st) {
      Log.error('[BOOT] Gagal saat menjadwalkan ulang alarm.', e: e, st: st);
    }
  }
}
