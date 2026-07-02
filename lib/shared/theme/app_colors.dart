// path: lib/shared/theme/app_colors.dart
// diubah: Menambahkan definisi warna yang hilang untuk tema terang dan gelap.

import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';

/// Kelas yang mendefinisikan palet warna untuk aplikasi.
  // Warna Inti
  /// Warna utama aplikasi.
  const MaterialColor primaryColor = Colors.deepPurple;

  /// Warna sekunder aplikasi.
  const Color secondaryColor = Colors.white;

  /// Warna aksen aplikasi.
  const Color accentColor = Colors.blueAccent;

  /// Warna untuk menunjukkan error.
  const MaterialColor errorColor = Colors.red;

  // Warna Latar & Permukaan
  /// Warna latar belakang untuk tema terang.
  const Color lightBackground = Color(0xFFF8F9FA);

  /// Warna latar belakang untuk tema gelap.
  const Color darkBackground = Color(0xFF121212);

  /// Warna permukaan untuk tema gelap.
  const Color darkSurface = Color(0xFF1E1E1E);

  // Warna Teks (opsional, bisa di-override oleh TextTheme)
  /// Warna teks untuk tema terang.
  const Color textOnLight = Colors.black;

  /// Warna teks untuk tema gelap.
  const Color textOnDark = Colors.white;

  // --- Tambahan Warna Poin ---

  /// Warna utama untuk elemen poin (Orange/Amber memberikan kesan "reward")
  const MaterialColor pointColor = Colors.orange;

  /// Warna latar belakang lembut untuk container poin (setara opacity 0.1)
  Color pointBackground = Colors.orange.withAlpha(26);

  /// Warna teks sekunder di dalam kartu poin
  const Color pointSubtleText = Colors.grey;

  // ---------------------------

  /// Mencatat inisialisasi warna.
  void logColorInitialization() {
    Log.info('Warna tema berhasil diinisialisasi.');
  }

