// path: lib/fitur/background/background_service.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/shared/data/services/sync_check_service.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/operasi_sqlite_provider/operasi_sqlite_provider.dart';
import 'package:workmanager/workmanager.dart';

const String syncTaskName = 'syncDataTask';
const String rescheduleNotificationsTaskName = 'rescheduleNotificationsTask';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((final task, final inputData) async {
    Log.info('Background task dimulai: $task');

    await _initializeBackgroundIsolate();

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
            Log.info(
                'Background task "$task" (reschedule) selesai dengan sukses.');
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
      container.dispose();
      Log.info('$container sudah dispos penting agar memori tidak leak');
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

class BackgroundService {
  static Future<void> init() async {
    try {
      await Workmanager().initialize(
        callbackDispatcher,
      );
      Log.info('Workmanager berhasil diinisialisasi.');

      await daftarSinkronisasiPeriodik();
      await daftarPenjadwalanUlangPeriodik();
    } on Exception catch (e, st) {
      Log.error('Gagal menginisialisasi background services.', e: e, st: st);
    }
  }

  @pragma('vm:entry-point')
  static Future<void> periksaDanArsipkanPelangganKedaluwarsa() async {
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
        'Gagal menjalankan periksaDanArsipkanPelangganKedaluwarsa di background',
        e: e,
        st: st,
      );
    } finally {
      container.dispose();
      Log.info('$container sudah dispose agar memori tidak leak');
    }
  }

  static Future<void> daftarSinkronisasiPeriodik() async {
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

  static Future<void> daftarPenjadwalanUlangPeriodik() async {
    try {
      await Workmanager().registerPeriodicTask(
        rescheduleNotificationsTaskName,
        rescheduleNotificationsTaskName,
        frequency: const Duration(hours: 24),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
        initialDelay: const Duration(minutes: 5),
        constraints: Constraints(
          networkType: NetworkType.notRequired,
        ),
      );
      Log.info(
        'Tugas penjadwalan ulang notifikasi ($rescheduleNotificationsTaskName) berhasil didaftarkan.',
      );
    } on Exception catch (e, st) {
      Log.error('Gagal mendaftarkan tugas penjadwalan ulang notifikasi.',
          e: e, st: st);
    }
  }

  static Future<void> batalkanSemuaTugas() async {
    await Workmanager().cancelAll();
    Log.info('Semua background tasks telah dibatalkan.');
  }
}
