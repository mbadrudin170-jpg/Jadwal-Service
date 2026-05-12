// path: lib/shared/theme/app_colors.dart
import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';

/// Mendefinisikan palet warna yang konsisten untuk seluruh aplikasi.
///
/// Kelas ini berisi semua warna yang digunakan dalam aplikasi, memastikan
/// konsistensi visual dan memudahkan perubahan tema di masa depan.
/// Setiap warna didefinisikan sebagai konstanta statis untuk akses mudah.
class AppColors {
  static const Color primaryColor = Colors.deepPurple;
  static const Color secondaryColor = Colors.white;
  static const Color accentColor = Colors.blue;
  static const Color textColor = Colors.black;
  static const Color backgroundColor = Colors.white;
  static const Color log = Color.fromARGB(255, 47, 148, 29);

  // Tambahkan warna lain yang diperlukan di sini

  /// Mencatat log saat palet warna diinisialisasi.
  ///
  /// Sebenarnya tidak ada 'inisialisasi' untuk kelas dengan konstanta statis,
  /// tapi kita bisa memanggil fungsi ini dari titik masuk utama aplikasi
  /// untuk mencatat bahwa palet warna kustom kita sedang digunakan.
  static void logColorInitialization() {
    Log.info('Palet warna dari AppColors telah dimuat.');
  }
}
