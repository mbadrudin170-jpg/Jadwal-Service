// path: lib/shared/services/background_service.dart

import 'package:wifi/shared/data/services/sync_check_service.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:workmanager/workmanager.dart';

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
          // Penting: Pastikan semua dependensi yang dibutuhkan oleh SyncCheckService
          // juga diinisialisasi jika perlu (misal: Firebase, SharedPreferences).
          // Untuk saat ini, kita asumsikan SyncCheckService sudah mandiri
          // dan sudah diinisialisasi di dalam service itu sendiri.
          await SyncCheckService().runSyncCheck();
          Log.info('Background task "$task" selesai dengan sukses.');
          return Future.value(true);
        } catch (e, st) {
          Log.error(
            'Error saat menjalankan background task "$task"',
            e: e,
            st: st,
          );
          return Future.value(false);
        }
      default:
        Log.warning('Task tidak dikenal: $task');
        return Future.value(false);
    }
  });
}

/// Kelas helper untuk mengelola inisialisasi dan pendaftaran background service.
class BackgroundService {
  /// Melakukan inisialisasi Workmanager dengan callback dispatcher.
  /// Panggil ini sekali di main.dart.
  static Future<void> init() async {
    try {
      await Workmanager().initialize(
        callbackDispatcher,
      );
      Log.info("Workmanager berhasil diinisialisasi.");
    } catch (e, st) {
      Log.error("Gagal menginisialisasi Workmanager.", e: e, st: st);
    }
  }

  /// Mendaftarkan tugas sinkronisasi periodik untuk dijalankan.
  /// Panggil ini setelah pengguna login atau saat aplikasi pertama kali dijalankan.
  static Future<void> registerPeriodicSync() async {
    try {
      await Workmanager().registerPeriodicTask(
        syncTaskName,
        syncTaskName,
        // Frekuensi minimal adalah 15 menit.
        // Android mungkin menyesuaikan waktu eksekusi untuk menghemat baterai.
        frequency: const Duration(minutes: 15),
        // Kebijakan ini akan menggantikan task lama jika ada task baru didaftarkan
        // dengan nama unik yang sama.
        existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
        // Menambahkan penundaan awal untuk memastikan aplikasi stabil.
        initialDelay: const Duration(seconds: 30),
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
      );
      Log.info(
        'Tugas sinkronisasi periodik ($syncTaskName) berhasil didaftarkan.',
      );
    } catch (e, st) {
      Log.error(
        "Gagal mendaftarkan tugas periodik.",
        e: e,
        st: st,
      );
    }
  }

  /// Membatalkan semua tugas yang sedang berjalan.
  static Future<void> cancelAllTasks() async {
    await Workmanager().cancelAll();
    Log.info("Semua background tasks telah dibatalkan.");
  }
}
