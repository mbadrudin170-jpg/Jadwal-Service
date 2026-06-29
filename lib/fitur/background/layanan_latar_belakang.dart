// path: lib/fitur/background/background_service.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/notifikasi/pengingat_paket_belum_lunas.dart';
import 'package:wifi/fitur/sinkronisasi/layanan_cek_sinkronisasi.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:workmanager/workmanager.dart';

const String namaTugasSinkronisasi = 'syncDataTask';
const String namaTugasJadwalUlangNotifikasi = 'rescheduleNotificationsTask';
const String namaTugasPengingatTagihan = 'reminder_unpaid_packages';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((tugas, dataMasukan) async {
    Log.info('Background task dimulai: $tugas');

    await _inisialisasiIsolatLatarBelakang();

    final container = ProviderContainer();

    try {
      switch (tugas) {
        case namaTugasSinkronisasi:
          try {
            final layananCekSinkronisasi = container.read(
              layananCekSinkronisasiProvider,
            );
            await layananCekSinkronisasi.jalankanCekSinkronisasi();
            Log.info('Background task "$tugas" selesai dengan sukses.');
            return true;
          } catch (e, st) {
            Log.error(
              'Error saat menjalankan background task "$tugas"',
              e: e,
              s: st,
            );
            return false;
          }
        case namaTugasJadwalUlangNotifikasi:
          try {
            final pelangganAktifOpSqlite = container.read(
              pelangganAktifOpSqliteProvider,
            );
            await pelangganAktifOpSqlite.jadwalkanUlangSemuaNotifikasi();
            Log.info(
              'Background task "$tugas" (reschedule) selesai dengan sukses.',
            );
            return true;
          } on Object catch (e, st) {
            Log.error(
              'Error saat menjalankan background task "$tugas" (reschedule)',
              e: e,
              s: st,
            );
            return false;
          }

        case namaTugasPengingatTagihan:
          final pengingatService = container.read(pengingatServiceProvider);
          await pengingatService.cekDanTampilkanPengingatTagihan();
          Log.info('Background task "$tugas" selesai dengan sukses.');
          return true;

        default:
          Log.warning('Task tidak dikenal: $tugas');
          return false;
      }
    } finally {
      container.dispose();
      Log.info(
        'ProviderContainer berhasil di-dispose untuk mencegah kebocoran memori.',
      );
    }
  });
}

/// Helper untuk inisialisasi di dalam background isolate.
Future<void> _inisialisasiIsolatLatarBelakang() async {
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

class LayananLatarBelakang {
  static Future<void> inisialisasi() async {
    try {
      await Workmanager().initialize(callbackDispatcher);
      Log.info('Workmanager berhasil diinisialisasi.');

      await daftarTugasSinkronisasiPeriodik();
      await daftarTugasJadwalUlangPeriodik();
      await daftarTugasPengingatTagihanPeriodik();
    } on Exception catch (e, st) {
      Log.error('Gagal menginisialisasi background services.', e: e, s: st);
    }
  }

  @pragma('vm:entry-point')
  static Future<void> periksaDanArsipkanPelangganKedaluwarsa() async {
    Log.info(
      'Alarm terpicu: Memulai pemeriksaan dan pengarsipan pelanggan kedaluwarsa.',
    );
    await _inisialisasiIsolatLatarBelakang();
    final container = ProviderContainer();
    try {
      final pelangganAktifOpsqlite = container.read(
        pelangganAktifOpSqliteProvider,
      );
      final jumlah = await pelangganAktifOpsqlite.arsipkanLanggananKadaluarsa();
      Log.info(
        'Proses pengarsipan selesai. $jumlah pelanggan kedaluwarsa telah diarsipkan.',
      );
    } on Exception catch (e, st) {
      Log.error(
        'Gagal menjalankan periksaDanArsipkanPelangganKedaluwarsa di background',
        e: e,
        s: st,
      );
    } finally {
      container.dispose();
      Log.info('ProviderContainer (Alarm) berhasil di-dispose.');
    }
  }

  static Future<void> daftarTugasSinkronisasiPeriodik() async {
    try {
      await Workmanager().registerPeriodicTask(
        namaTugasSinkronisasi,
        namaTugasSinkronisasi,
        frequency: const Duration(minutes: 15),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
        initialDelay: const Duration(minutes: 1),
        constraints: Constraints(networkType: NetworkType.connected),
      );
      Log.info(
        'Tugas sinkronisasi periodik ($namaTugasSinkronisasi) berhasil didaftarkan.',
      );
    } on Exception catch (e, st) {
      Log.error('Gagal mendaftarkan tugas periodik sync.', e: e, s: st);
    }
  }

  static Future<void> daftarTugasJadwalUlangPeriodik() async {
    try {
      await Workmanager().registerPeriodicTask(
        namaTugasJadwalUlangNotifikasi,
        namaTugasJadwalUlangNotifikasi,
        frequency: const Duration(hours: 24),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
        initialDelay: const Duration(minutes: 5),
        constraints: Constraints(networkType: NetworkType.notRequired),
      );
      Log.info(
        'Tugas penjadwalan ulang notifikasi ($namaTugasJadwalUlangNotifikasi) berhasil didaftarkan.',
      );
    } on Exception catch (e, st) {
      Log.error(
        'Gagal mendaftarkan tugas penjadwalan ulang notifikasi.',
        e: e,
        s: st,
      );
    }
  }

  static Future<void> daftarTugasPengingatTagihanPeriodik() async {
    try {
      await Workmanager().registerPeriodicTask(
        namaTugasPengingatTagihan,
        namaTugasPengingatTagihan,
        frequency: const Duration(hours: 24),
        initialDelay: const Duration(hours: 1),
        constraints: Constraints(networkType: NetworkType.notRequired),
      );
    } on Exception catch (e, s) {
      Log.error('Gagal medaftarkan tugas pengingat tagihan', e: e, s: s);
    }
  }

  static Future<void> batalkanSemuaTugas() async {
    await Workmanager().cancelAll();
    Log.info('Semua background tasks telah dibatalkan.');
  }
}
