// path: lib/shared/services/background_service.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:wifi/shared/data/services/sync_check_service.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:workmanager/workmanager.dart';

/// Nama unik untuk tugas sinkronisasi periodik.
const String syncTaskName = 'syncDataTask';

/// Fungsi top-level yang dijalankan oleh Workmanager di background isolate.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((final task, final inputData) async {
    Log.info('Background task dimulai: $task');

    // SOLUSI: Inisialisasi Firebase di dalam background isolate
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    Log.info('Firebase berhasil diinisialisasi di background isolate.');

    switch (task) {
      case syncTaskName:
        try {
          await SyncCheckService().runSyncCheck();
          Log.info('Background task "$task" selesai dengan sukses.');
          return Future.value(true);
        } on Object catch (e, st) {
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
      Log.info('Workmanager berhasil diinisialisasi.');

      // Langsung daftarkan tugas setelah inisialisasi berhasil
      await registerPeriodicSync();
    } on Exception catch (e, st) {
      Log.error('Gagal menginisialisasi Workmanager.', e: e, st: st);
    }
  }

  /// Mendaftarkan tugas sinkronisasi periodik untuk dijalankan.
  /// Metode ini dipanggil secara otomatis oleh `init`.
  static Future<void> registerPeriodicSync() async {
    try {
      await Workmanager().registerPeriodicTask(
        syncTaskName, // Unique name
        syncTaskName, // Task name
        frequency: const Duration(minutes: 15),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
        initialDelay: const Duration(minutes: 1),
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
      );
      Log.info(
        'Tugas sinkronisasi periodik ($syncTaskName) berhasil didaftarkan.',
      );
    } on Exception catch (e, st) {
      Log.error(
        'Gagal mendaftarkan tugas periodik.',
        e: e,
        st: st,
      );
    }
  }

  /// Membatalkan semua tugas yang sedang berjalan.
  static Future<void> cancelAllTasks() async {
    await Workmanager().cancelAll();
    Log.info('Semua background tasks telah dibatalkan.');
  }
}
