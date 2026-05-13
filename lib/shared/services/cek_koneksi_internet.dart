// path: lib/shared/services/cek_koneksi_internet.dart
// File ini menyediakan layanan terpusat untuk memeriksa status koneksi internet.

// ditambah: Menambahkan Log yang lebih detail untuk setiap langkah.
// diperbaiki: Memperbaiki sintaks pemanggilan Log.error yang salah.
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:wifi/shared/debug/log.dart';

class KoneksiInternetService {
  // Fungsi untuk memeriksa apakah perangkat terhubung ke internet (WiFi atau Mobile).
  // Mengembalikan Future<bool> yang bernilai true jika online, dan false jika offline.
  Future<bool> cekKoneksi() async {
    Log.info('[Koneksi] Memulai pemeriksaan status koneksi perangkat...');

    try {
      // ditambah: Log sebelum memanggil plugin.
      Log.info('[Koneksi] Memanggil Connectivity().checkConnectivity().');
      final connectivityResult = await Connectivity().checkConnectivity();

      Log.info('[Koneksi] Hasil mentah konektivitas diterima: $connectivityResult');

      // ditambah: Log sebelum melakukan pengecekan logika.
      Log.info('[Koneksi] Menganalisa hasil untuk koneksi mobile atau wifi.');
      final isOnline =
          connectivityResult.contains(ConnectivityResult.mobile) ||
              connectivityResult.contains(ConnectivityResult.wifi);

      if (isOnline) {
        Log.info('[Koneksi] ✅ Sukses: Perangkat terdeteksi online (terhubung ke WiFi atau Mobile Data).');
      } else if (connectivityResult.contains(ConnectivityResult.none)) {
        // ditambah: Log spesifik untuk kasus tidak ada koneksi sama sekali.
        Log.warning('[Koneksi] ❌ Gagal: Tidak ada koneksi jaringan yang terdeteksi (ConnectivityResult.none).');
      } else {
        // ditambah: Log untuk kasus lain yang mungkin (misal: bluetooth, ethernet)
        Log.warning('[Koneksi] ⚠️ Peringatan: Jenis koneksi yang terdeteksi bukan WiFi atau Mobile Data ($connectivityResult). Dianggap offline.');
      }

      Log.info('[Koneksi] Pemeriksaan selesai, mengembalikan nilai: $isOnline.');
      return isOnline;
    } catch (e, st) {
      // diperbaiki: Memperbaiki pemanggilan Log.error sesuai dengan definisinya.
      Log.error(
        '[Koneksi] ❌ Fatal: Terjadi kesalahan saat menggunakan plugin connectivity_plus.',
        e: e,
        st: st,
      );
      // Mengembalikan false sebagai fallback aman jika terjadi error pada plugin
      Log.info('[Koneksi] Mengembalikan nilai fallback '"false"' karena terjadi exception.');
      return false;
    }
  }
}
