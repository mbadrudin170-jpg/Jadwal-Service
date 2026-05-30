// path: lib/shared/theme/app_colors.dart
// diubah: Menambahkan definisi warna yang hilang untuk tema terang dan gelap.

import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';

/// Kelas yang mendefinisikan palet warna untuk aplikasi.
class TColors {
  // Warna Inti
  /// Warna utama aplikasi.
  static const MaterialColor primaryColor = Colors.deepPurple;

  /// Warna sekunder aplikasi.
  static const Color secondaryColor = Colors.white;

  /// Warna aksen aplikasi.
  static const Color accentColor = Colors.blueAccent;

  /// Warna untuk menunjukkan error.
  static const MaterialColor errorColor = Colors.red;

  // Warna Latar & Permukaan
  /// Warna latar belakang untuk tema terang.
  static const Color lightBackground = Color(0xFFF8F9FA);

  /// Warna latar belakang untuk tema gelap.
  static const Color darkBackground = Color(0xFF121212);

  /// Warna permukaan untuk tema gelap.
  static const Color darkSurface = Color(0xFF1E1E1E);

  // Warna Teks (opsional, bisa di-override oleh TextTheme)
  /// Warna teks untuk tema terang.
  static const Color textOnLight = Colors.black;

  /// Warna teks untuk tema gelap.
  static const Color textOnDark = Colors.white;

  // --- Tambahan Warna Poin ---

  /// Warna utama untuk elemen poin (Orange/Amber memberikan kesan "reward")
  static const MaterialColor pointColor = Colors.orange;

  /// Warna latar belakang lembut untuk container poin (setara opacity 0.1)
  static Color pointBackground = Colors.orange.withAlpha(26);

  /// Warna teks sekunder di dalam kartu poin
  static const Color pointSubtleText = Colors.grey;

  // ---------------------------

  /// Mencatat inisialisasi warna.
  static void logColorInitialization() {
    Log.info('Warna tema berhasil diinisialisasi.');
  }
}
