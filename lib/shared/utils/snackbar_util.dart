// path: lib/shared/utils/snackbar_util.dart

import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';

/// Tipe SnackBar yang tersedia.
enum SnackBarType {
  /// SnackBar sukses dengan latar hijau.
  success,

  /// SnackBar error dengan latar merah.
  error,

  /// SnackBar peringatan dengan latar oranye.
  warning,

  /// SnackBar informasi dengan latar biru.
  info,
}

/// Kelas utilitas untuk menampilkan SnackBar dengan gaya yang konsisten dan logging otomatis.
class SnackBarUtil {
  /// Fungsi internal untuk menampilkan SnackBar dan mencatat log.
  static void _show(
    final BuildContext context,
    final String message, {
    final SnackBarType type = SnackBarType.info,
  }) {
    // Mencatat pesan ke log berdasarkan tipenya
    final logMessage = '[SNACKBAR] Tipe: ${type.name}, Pesan: $message';
    switch (type) {
      case SnackBarType.success:
        Log.info(logMessage);
        break;
      case SnackBarType.error:
        Log.error(logMessage);
        break;
      case SnackBarType.warning:
        Log.warning(logMessage);
        break;
      case SnackBarType.info:
        Log.info(logMessage);
        break;
    }

    // Jangan tampilkan snackbar jika context sudah tidak valid setelah logging
    if (!context.mounted) return;

    // Tentukan warna berdasarkan tipe snackbar
    Color backgroundColor;
    switch (type) {
      case SnackBarType.success:
        backgroundColor = Colors.green;
        break;
      case SnackBarType.error:
        backgroundColor = Colors.red;
        break;
      case SnackBarType.warning:
        backgroundColor = Colors.orange;
        break;
      case SnackBarType.info:
        backgroundColor = Colors.blue;
        break;
    }

    // Buat dan tampilkan SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  /// Menampilkan SnackBar dengan tipe success.
  static void success(final BuildContext context, final String message) {
    _show(context, message, type: SnackBarType.success);
  }

  /// Menampilkan SnackBar dengan tipe error.
  static void error(final BuildContext context, final String message) {
    _show(context, message, type: SnackBarType.error);
  }

  /// Menampilkan SnackBar dengan tipe warning.
  static void warning(final BuildContext context, final String message) {
    _show(context, message, type: SnackBarType.warning);
  }

  /// Menampilkan SnackBar dengan tipe info.
  static void info(final BuildContext context, final String message) {
    _show(context, message);
  }
}
