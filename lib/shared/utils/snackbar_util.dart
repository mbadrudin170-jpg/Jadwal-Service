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
  /// Menampilkan SnackBar berdasarkan tipe yang ditentukan dan mencatatnya ke log.
  ///
  /// [context] adalah BuildContext dari widget yang memanggil.
  /// [message] adalah pesan yang akan ditampilkan di dalam SnackBar dan dicatat di log.
  /// [type] adalah tipe dari SnackBar (success, error, warning, info),
  /// yang akan menentukan warna latar belakang dan level log.
  static void show(
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

  /// Metode pintas untuk menampilkan SnackBar dengan tipe success.
  static void showSuccess(final BuildContext context, final String message) {
    show(context, message, type: SnackBarType.success);
  }

  /// Metode pintas untuk menampilkan SnackBar dengan tipe error.
  static void showError(final BuildContext context, final String message) {
    show(context, message, type: SnackBarType.error);
  }

  /// Metode pintas untuk menampilkan SnackBar dengan tipe warning.
  static void showWarning(final BuildContext context, final String message) {
    show(context, message, type: SnackBarType.warning);
  }

  /// Metode pintas untuk menampilkan SnackBar dengan tipe info.
  static void showInfo(final BuildContext context, final String message) {
    show(context, message);
  }
}
