// path: lib/fitur/background/boot_service.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/alarm/android_alarm_scheduler.dart';
import 'package:wifi/fitur/background/background_service.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/shared/debug/log.dart';

const int archiveExpiredId = 999; // ID unik untuk alarm periodik
const int oneShotArchivedId = 998; // ID unik untuk alarm sekali jalan

class BootService {
  /// Menjadwalkan alarm periodik untuk memeriksa dan mengarsipkan pelanggan yang kedaluwarsa.
  Future<void> schedulePeriodicArchiveTask(ProviderContainer container) async {
    final alarmScheduler = container.read(alarmSchedulerProvider);

    // Jalankan setiap 1 jam. Anda bisa menyesuaikan durasi ini.
    await alarmScheduler.schedulePeriodic(
      const Duration(hours: 1),
      archiveExpiredId, // ID unik untuk tugas ini
      BackgroundService.periksaDanArsipkanPelangganKedaluwarsa,
      startAt: DateTime.now()
          .add(const Duration(seconds: 10)), // Mulai setelah 10 detik
      exact: true, // Pastikan alarm berjalan tepat waktu
      wakeup: true, // Bangunkan perangkat jika perlu
      rescheduleOnReboot: true, // Jadwalkan ulang setelah reboot
    );
  }

  /// Menjadwalkan ulang tugas pengarsipan berdasarkan waktu kedaluwarsa pelanggan terdekat.
  Future<void> rescheduleArchivingTask(ProviderContainer container) async {
    Log.info('Memulai penjadwalan ulang tugas pengarsipan...');
    final alarmScheduler = container.read(alarmSchedulerProvider);
    final activeCustomerOp = container.read(pelangganAktifOpSqliteProvider);

    try {
      final activeCustomers =
          await activeCustomerOp.getAllActiveCustomersWithDetails();

      // Batalkan alarm sekali jalan yang mungkin sudah ada
      await alarmScheduler.cancel(oneShotArchivedId);
      Log.info(
          'Alarm sekali jalan (ID: $oneShotArchivedId) berhasil dibatalkan.');

      if (activeCustomers.isEmpty) {
        Log.warning('Tidak ada pelanggan aktif, tidak ada penjadwalan ulang.');
        return;
      }

      // Urutkan untuk menemukan tanggal kedaluwarsa terdekat
      activeCustomers.sort((a, b) =>
          a.pelangganAktif.tanggalBerakhir.compareTo(b.pelangganAktif.tanggalBerakhir));

      final nearestExpiryDate = activeCustomers.first.pelangganAktif.tanggalBerakhir;

      // Jadwalkan alarm sekali jalan
      await alarmScheduler.oneShotAt(
        nearestExpiryDate,
        oneShotArchivedId,
        BackgroundService.periksaDanArsipkanPelangganKedaluwarsa,
        exact: true,
        wakeup: true,
        rescheduleOnReboot: true,
      );

      Log.info(
          'Penjadwalan ulang berhasil. Alarm sekali jalan diatur untuk: $nearestExpiryDate');
    } on Exception catch (e, st) {
      Log.error('Gagal menjadwalkan ulang tugas pengarsipan', e: e, s: st);
      // Pertimbangkan untuk melempar kembali error jika perlu penanganan lebih lanjut
    }
  }
}
