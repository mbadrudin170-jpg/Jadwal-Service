// path: lib/shared/services/boot_service.dart
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/firebase_operasi/customer_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/transaction_op_firebase.dart';
import 'package:wifi/shared/utils/alarm_utils.dart'; // import callback

class BootService {
  final _customerOp = CustomerOpFirebase();
  final _transactionOp = TransactionOpFirebase();

  Future<void> rescheduleAlarmsOnBoot() async {
    Log.info('[BOOT] Memulai proses penjadwalan ulang alarm setelah boot.');
    try {
      final allCustomers = await _customerOp.getAllCustomers();
      if (allCustomers.isEmpty) {
        Log.warning('[BOOT] Tidak ada pelanggan ditemukan.');
        return;
      }
      int scheduledCount = 0;
      for (final customer in allCustomers) {
        final transaction =
            await _transactionOp.getLatestPaidTransactionByUserId(customer.id);
        if (transaction != null &&
            transaction.startDate != null &&
            transaction.endDate != null &&
            transaction.endDate!.isAfter(DateTime.now())) {
          final alarmId = customer.id.hashCode;
          final scheduledTime = transaction.endDate!;
          await AndroidAlarmManager.oneShotAt(
            scheduledTime,
            alarmId,
            alarmCallback, // ← perbaiki nama callback
            exact: true,
            wakeup: true,
          );
          Log.info(
              '[BOOT] Alarm dijadwalkan untuk customer ${customer.name} pada $scheduledTime');
          scheduledCount++;
        }
      }
      Log.info('[BOOT] Selesai menjadwalkan $scheduledCount alarm.');
    } catch (e, st) {
      Log.error('[BOOT] Gagal saat menjadwalkan ulang alarm.', e: e, st: st);
    }
  }
}
