// path: lib/shared/theme/app_colors.dart
import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';

class AppColors {
  static const MaterialColor primaryColor = Colors.deepPurple;
  static const Color secondaryColor = Colors.white;
  static const Color accentColor = Colors.blue;
  static const Color textColor = Colors.black;
  static const Color backgroundColor = Color(0xFFF8F9FA);

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
