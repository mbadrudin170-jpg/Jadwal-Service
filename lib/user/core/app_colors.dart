/*
 * File: app_colors.dart
 * Tujuan: Menyentralisasikan semua warna yang digunakan dalam aplikasi.
 *
 * Deskripsi:
 * Kelas `AppColors` ini berisi daftar konstanta warna statis.
 * Dengan memusatkan warna di sini, kita dapat dengan mudah mengelola dan
 * memperbarui tema visual aplikasi secara konsisten tanpa harus mengubahnya
 * di banyak tempat.
 */

import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const Color primary = Colors.deepPurple;

  // Status
  static const Color success = Colors.green;
  static const Color warning = Colors.orange;
  static const Color error = Colors.red;
}
