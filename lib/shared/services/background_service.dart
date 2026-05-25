// path: lib/shared/services/background_service.dart

import 'package:workmanager/workmanager.dart';
import 'package:wifi/shared/data/services/sync_check_service.dart';
import 'package:wifi/shared/debug/log.dart';

/// Nama unik untuk tugas sinkronisasi periodik.
const String syncTaskName = "syncDataTask";

/// Fungsi top-level yang dijalankan oleh Workmanager di background isolate.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    Log.info('Background task dimulai: $task');

    switch (task) {
      case syncTaskName:
        try {
          // Inisialisasi service dan jalankan sinkronisasi.
          // Penting: Pastikan semua dependensi yang dibutuhkan oleh SyncCheckService
          // juga diinisialisasi jika perlu (misal: Firebase).
          // Untuk saat ini, kita asumsikan SyncCheckService sudah mandiri.
          await SyncCheckService().runSyncCheck();
          Log.info('Background sync berhasil diselesaikan.');
          return Future.value(true);
        } catch (e, s) {
          Log.error('Error saat menjalankan background sync', e: e, st: s);
          return Future.value(false);
        }
      default:
        Log.warning('Tugas background tidak dikenali: \$task');
        return Future.value(false);
    }
  });
}
