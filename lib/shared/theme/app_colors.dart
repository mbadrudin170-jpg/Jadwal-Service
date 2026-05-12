// path: lib/shared/theme/app_colors.dart
// diubah: Menambahkan definisi warna yang hilang untuk tema terang dan gelap.

import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';

class AppColors {
  // Warna Inti
  static const MaterialColor primaryColor = Colors.deepPurple;
  static const Color secondaryColor = Colors.white;
  static const Color accentColor = Colors.blueAccent;
  static const MaterialColor errorColor = Colors.red;

  // Warna Latar & Permukaan
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);

  // Warna Teks (opsional, bisa di-override oleh TextTheme)
  static const Color textOnLight = Colors.black;
  static const Color textOnDark = Colors.white;

  // --- Tambahan Warna Poin ---

  /// Warna utama untuk elemen poin (Orange/Amber memberikan kesan "reward")
  static const MaterialColor pointColor = Colors.orange;

  /// Warna latar belakang lembut untuk container poin (setara opacity 0.1)
  static Color pointBackground = Colors.orange.withAlpha(26);

  /// Warna teks sekunder di dalam kartu poin
  static const Color pointSubtleText = Colors.grey;

  // ---------------------------

  static void logColorInitialization() {
    Log.info('Warna tema berhasil diinisialisasi.');
  }
}
