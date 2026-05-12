// path: lib/shared/services/cek_koneksi_internet.dart// File ini menyediakan layanan terpusat untuk memeriksa status koneksi internet.

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:wifi/shared/debug/log.dart';

class KoneksiInternetService {
  // Fungsi untuk memeriksa apakah perangkat terhubung ke internet (WiFi atau Mobile).
  // Mengembalikan Future<bool> yang bernilai true jika online, dan false jika offline.
  // diubah: dihapus keyword static agar bisa di-mock untuk testing
  Future<bool> cekKoneksi() async {
    Log.info('Memulai pemeriksaan status koneksi perangkat...');

    try {
      final connectivityResult = await Connectivity().checkConnectivity();

      Log.info('Hasil mentah konektivitas diterima:', connectivityResult);

      // Memeriksa apakah hasil konektivitas mengandung koneksi seluler atau WiFi.
      final isOnline =
          connectivityResult.contains(ConnectivityResult.mobile) ||
              connectivityResult.contains(ConnectivityResult.wifi);

      if (isOnline) {
        Log.info('Perangkat terhubung ke internet (WiFi/Mobile Data)');
      } else {
        Log.warning('Perangkat tidak memiliki koneksi internet aktif (Offline)');
      }

      return isOnline;
    } catch (e, stackTrace) {
      Log.error(
        'Terjadi kesalahan fatal saat memeriksa koneksi',
        error: e,
        stackTrace: stackTrace,
      );
      // Mengembalikan false sebagai fallback aman jika terjadi error pada plugin
      return false;
    }
  }
}
