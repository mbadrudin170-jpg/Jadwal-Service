// path: lib/shared/services/boot_service.dart
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/firebase_operasi/customer_op_firebase.dart';
import 'package:wifi/shared/services/notifikasi/notifikasi_servis.dart';
import 'package:wifi/shared/services/notifikasi/penjadwal_notifikasi.dart';

class BootService {
  final _customerOp = CustomerOpFirebase();
  final _notificationService = NotifikasiServis();

  /// Menjadwalkan ulang semua notifikasi dan alarm setelah perangkat di-boot ulang.
  Future<void> rescheduleAlarmsOnBoot() async {
    Log.info('[BOOT] Memulai proses penjadwalan ulang alarm setelah boot.');
    try {
      // Inisialisasi service notifikasi terlebih dahulu
      // Nama ikon harus sesuai dengan yang ada di direktori drawable Android.
      await _notificationService.inisialisasi(iconName: 'app_icon');

      // Dapatkan semua pelanggan dari Firebase
      final allCustomers = await _customerOp.getAllCustomers();

      if (allCustomers.isEmpty) {
        Log.warning('[BOOT] Tidak ada pelanggan ditemukan, tidak ada alarm untuk dijadwalkan ulang.');
        return;
      }

      Log.info('[BOOT] Ditemukan ${allCustomers.length} pelanggan. Memeriksa langganan aktif...');

      // Iterasi melalui setiap pelanggan dan atur ulang notifikasi/alarm mereka
      for (final customer in allCustomers) {
        // ID pada CustomerModel dijamin tidak null dari konstruktornya.
        Log.info('[BOOT] Menjadwalkan ulang untuk pelanggan: ${customer.name} (ID: ${customer.id})');
        await PenjadwalNotifikasi.aturNotifikasiLangganan(
          _notificationService,
          customer.id,
        );
      }

      Log.info('[BOOT] Proses penjadwalan ulang alarm setelah boot selesai.');
    } catch (e, st) {
      Log.error('[BOOT] Gagal total saat menjadwalkan ulang alarm setelah boot.', e: e, st: st);
    }
  }
}
