// path: lib/shared/services/internet_connection_check.dart
// File ini menyediakan layanan terpusat untuk memeriksa status koneksi internet.

// ditambah: Menerapkan Dependency Injection agar kelas ini dapat diuji.
// ditambah: Menambahkan Log yang lebih detail untuk setiap langkah.
// diperbaiki: Memperbaiki sintaks pemanggilan Log.error yang salah.
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:wifi/shared/debug/log.dart';

/// Kelas layanan untuk memeriksa status koneksi internet.
class InternetConnectionService {
  // ditambah: Variabel final untuk menyimpan instance Connectivity.
  final Connectivity _connectivity;

  /// Konstruktor untuk `InternetConnectionService`.
  ///
  /// Memungkinkan injeksi `Connectivity` untuk keperluan pengujian.
  InternetConnectionService({final Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  /// Memeriksa apakah perangkat terhubung ke internet (WiFi atau Mobile).
  /// Mengembalikan `true` jika online, dan `false` jika offline.
  Future<bool> checkConnection() async {
    Log.info('[Koneksi] Memulai pemeriksaan status koneksi perangkat...');

    try {
      // ditambah: Log sebelum memanggil plugin.
      Log.info('[Koneksi] Memanggil _connectivity.checkConnectivity().');
      // diubah: Menggunakan instance _connectivity yang sudah diinjeksi/dibuat.
      final connectivityResult = await _connectivity.checkConnectivity();

      Log.info(
        '[Koneksi] Hasil mentah konektivitas diterima: $connectivityResult',
      );

      // ditambah: Log sebelum melakukan pengecekan logika.
      Log.info('[Koneksi] Menganalisa hasil untuk koneksi mobile atau wifi.');
      final isOnline = connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi);

      if (isOnline) {
        Log.info(
          '[Koneksi] ✅ Sukses: Perangkat terdeteksi online (terhubung ke WiFi atau Mobile Data).',
        );
      } else if (connectivityResult.contains(ConnectivityResult.none)) {
        // ditambah: Log spesifik untuk kasus tidak ada koneksi sama sekali.
        Log.warning(
          '[Koneksi] ❌ Gagal: Tidak ada koneksi jaringan yang terdeteksi (ConnectivityResult.none).',
        );
      } else {
        // ditambah: Log untuk kasus lain yang mungkin (misal: bluetooth, ethernet)
        Log.warning(
          '[Koneksi] ⚠️ Peringatan: Jenis koneksi yang terdeteksi bukan WiFi atau Mobile Data ($connectivityResult). Dianggap offline.',
        );
      }

      Log.info(
        '[Koneksi] Pemeriksaan selesai, mengembalikan nilai: $isOnline.',
      );
      return isOnline;
    } on Exception catch  (e, st) {
      // diperbaiki: Memperbaiki pemanggilan Log.error sesuai dengan definisinya.
      Log.error(
        '[Koneksi] ❌ Fatal: Terjadi kesalahan saat menggunakan plugin connectivity_plus.',
        e: e,
        st: st,
      );
      // Mengembalikan false sebagai fallback aman jika terjadi error pada plugin
      Log.info('[Koneksi] Mengembalikan nilai fallback '
          'false'
          ' karena terjadi exception.');
      return false;
    }
  }
}
