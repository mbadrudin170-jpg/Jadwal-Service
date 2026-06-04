// path: lib/shared/services/background_service.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/shared/data/services/sync_check_service.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/operasi_sqlite_provider/operasi_sqlite_provider.dart';
import 'package:workmanager/workmanager.dart';

/// Nama unik untuk tugas sinkronisasi periodik.
const String syncTaskName = 'syncDataTask';

/// Fungsi top-level yang dijalankan oleh Workmanager di background isolate.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((final task, final inputData) async {
    Log.info('Background task dimulai: $task');

    // Inisialisasi Flutter binding dan Firebase di isolate
    await _initializeBackgroundIsolate();

    // Buat ProviderContainer lokal untuk mengakses provider
    final container = ProviderContainer();

    try {
      switch (task) {
        case syncTaskName:
          try {
            final syncCheckService = container.read(syncCheckServiceProvider);
            await syncCheckService.runSyncCheck();
            Log.info('Background task "$task" selesai dengan sukses.');
            return true;
          } on Object catch (e, st) {
            Log.error(
              'Error saat menjalankan background task "$task"',
              e: e,
              st: st,
            );
            return false;
          }
        default:
          Log.warning('Task tidak dikenal: $task');
          return false;
      }
    } finally {
      // Penting: bersihkan container setelah selesai
      container.dispose();
    }
  });
}

/// Helper untuk inisialisasi di dalam background isolate.
Future<void> _initializeBackgroundIsolate() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Log.info('Firebase berhasil diinisialisasi di background isolate.');
}

/// Kelas helper untuk mengelola inisialisasi dan pendaftaran background service.
class BackgroundService {
  /// Melakukan inisialisasi Workmanager dan mendaftarkan tugas.
  static Future<void> init() async {
    try {
      // Inisialisasi Workmanager
      await Workmanager().initialize(
        callbackDispatcher,
      );
      Log.info('Workmanager berhasil diinisialisasi.');

      // Langsung daftarkan tugas setelah inisialisasi berhasil
      await registerPeriodicSync();
    } on Exception catch (e, st) {
      Log.error('Gagal menginisialisasi background services.', e: e, st: st);
    }
  }

  /// Callback statis untuk dijalankan oleh AndroidAlarmManager saat pelanggan kedaluwarsa.
  @pragma('vm:entry-point')
  static Future<void> checkAndArchiveExpiredCustomers() async {
    Log.info(
        'Alarm terpicu: Memulai pemeriksaan dan pengarsipan pelanggan kedaluwarsa.');
    await _initializeBackgroundIsolate();
    final container = ProviderContainer();
    try {
      final activeCustomerOp = container.read(activeCustomerOperationProvider);
      final count = await activeCustomerOp.archiveExpiredCustomers();
      Log.info(
          'Proses pengarsipan selesai. $count pelanggan kedaluwarsa telah diarsipkan.');
    } on Exception catch (e, st) {
      Log.error(
          'Gagal menjalankan checkAndArchiveExpiredCustomers di background',
          e: e,
          st: st);
    } finally {
      container.dispose();
    }
  }

  /// Mendaftarkan tugas sinkronisasi periodik.
  static Future<void> registerPeriodicSync() async {
    try {
      await Workmanager().registerPeriodicTask(
        syncTaskName,
        syncTaskName,
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
      Log.error('Gagal mendaftarkan tugas periodik.', e: e, st: st);
    }
  }

  /// Membatalkan semua tugas yang sedang berjalan.
  static Future<void> cancelAllTasks() async {
    await Workmanager().cancelAll();
    Log.info('Semua background tasks telah dibatalkan.');
  }
}
