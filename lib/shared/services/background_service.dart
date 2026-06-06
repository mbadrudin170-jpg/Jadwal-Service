// path: lib/shared/services/background_service.dart
// KOREKSI: Memperbaiki kesalahan ketik dari NetworkType.not_required menjadi NetworkType.notRequired.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/shared/data/services/sync_check_service.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/operasi_sqlite_provider/operasi_sqlite_provider.dart';
import 'package:workmanager/workmanager.dart';

/// Nama unik untuk tugas sinkronisasi periodik.
const String syncTaskName = 'syncDataTask';

/// Nama unik untuk tugas penjadwalan ulang notifikasi.
const String rescheduleNotificationsTaskName = 'rescheduleNotificationsTask';

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

        case rescheduleNotificationsTaskName:
          try {
            final activeCustomerOp =
                container.read(activeCustomerOperationProvider);
            await activeCustomerOp.rescheduleAllNotifications();
            Log.info('Background task "$task" (reschedule) selesai dengan sukses.');
            return true;
          } on Object catch (e, st) {
            Log.error(
              'Error saat menjalankan background task "$task" (reschedule)',
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
  try {
    WidgetsFlutterBinding.ensureInitialized();
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
      Log.info('Firebase berhasil diinisialisasi di background isolate.');
    }
  } catch (e) {
    Log.warning('Gagal menginisialisasi background isolate: $e');
  }
}

/// Kelas helper untuk mengelola inisialisasi dan pendaftaran background service.
class BackgroundService {
  /// Melakukan inisialisasi Workmanager dan mendaftarkan semua tugas.
  static Future<void> init() async {
    try {
      await Workmanager().initialize(
        callbackDispatcher,
      );
      Log.info('Workmanager berhasil diinisialisasi.');

      await registerPeriodicSync();
      await registerPeriodicReschedule();
    } on Exception catch (e, st) {
      Log.error('Gagal menginisialisasi background services.', e: e, st: st);
    }
  }

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
      Log.error('Gagal mendaftarkan tugas periodik sync.', e: e, st: st);
    }
  }

  /// Mendaftarkan tugas penjadwalan ulang notifikasi secara periodik.
  static Future<void> registerPeriodicReschedule() async {
    try {
      await Workmanager().registerPeriodicTask(
        rescheduleNotificationsTaskName, // ID Unik
        rescheduleNotificationsTaskName, // Nama tugas
        frequency: const Duration(hours: 24), // Jalankan setiap 24 jam
        existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
        initialDelay: const Duration(minutes: 5), // Mulai 5 menit setelah init
        constraints: Constraints(
          // TIDAK PERLU KONEKSI INTERNET UNTUK TUGAS INI (KODE SUDAH DIPERBAIKI)
          networkType: NetworkType.notRequired, 
        ),
      );
      Log.info(
        'Tugas penjadwalan ulang notifikasi ($rescheduleNotificationsTaskName) berhasil didaftarkan.',
      );
    } on Exception catch (e, st) {
      Log.error('Gagal mendaftarkan tugas penjadwalan ulang notifikasi.', e: e, st: st);
    }
  }

  /// Membatalkan semua tugas yang sedang berjalan.
  static Future<void> cancelAllTasks() async {
    await Workmanager().cancelAll();
    Log.info('Semua background tasks telah dibatalkan.');
  }
}
