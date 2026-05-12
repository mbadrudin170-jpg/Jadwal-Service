// path: lib/shared/theme/app_colors.dart
import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';

/// Mendefinisikan palet warna yang konsisten untuk seluruh aplikasi.
///
/// Kelas ini berisi semua warna yang digunakan dalam aplikasi, memastikan
/// konsistensi visual dan memudahkan perubahan tema di masa depan.
/// Setiap warna didefinisikan sebagai konstanta statis untuk akses mudah.
class AppColors {
  // diubah: Menggunakan MaterialColor untuk memungkinkan akses ke shades (cth: shade200)
  static const MaterialColor primaryColor = Colors.deepPurple;
  static const Color secondaryColor = Colors.white;
  static const Color accentColor = Colors.blue;
  static const Color textColor = Colors.black;
  static const Color backgroundColor = Colors.white;
  static const Color log = Color.fromARGB(255, 47, 148, 29);

  static void logColorInitialization() {
    Log.info('Warna tema berhasil diinisialisasi.');
  }
}
