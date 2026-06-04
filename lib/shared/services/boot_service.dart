// path: lib/shared/services/boot_service.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/shared/services/alarm/alarm_scheduler_provider.dart';
import 'package:wifi/shared/services/background_service.dart';

const int archiveExpiredId = 999; // ID unik untuk alarm periodik

class BootService {
  /// Menjadwalkan alarm periodik untuk memeriksa dan mengarsipkan pelanggan yang kedaluwarsa.
  Future<void> schedulePeriodicArchiveTask(ProviderContainer container) async {
    final alarmScheduler = container.read(alarmSchedulerProvider);
    
    // Jalankan setiap 1 jam. Anda bisa menyesuaikan durasi ini.
    await alarmScheduler.schedulePeriodic(
      const Duration(hours: 1),
      archiveExpiredId, // ID unik untuk tugas ini
      BackgroundService.checkAndArchiveExpiredCustomers,
      startAt: DateTime.now().add(const Duration(seconds: 10)), // Mulai setelah 10 detik
      exact: true, // Pastikan alarm berjalan tepat waktu
      wakeup: true, // Bangunkan perangkat jika perlu
      rescheduleOnReboot: true, // Jadwalkan ulang setelah reboot
    );
  }
}
