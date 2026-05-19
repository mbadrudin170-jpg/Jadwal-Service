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

/// Kelas utilitas untuk menampilkan SnackBar dengan gaya yang konsisten
/// sekaligus mencatat log otomatis menggunakan [Log].
class SnackBarUtil {
  /// Menampilkan SnackBar dan mencatat log berdasarkan [type].
  ///
  /// [message] akan tampil di UI, sedangkan [logData] hanya direkam
  /// di console debug sebagai konteks tambahan (tidak tampil ke pengguna).
  static void _show(
    final BuildContext context,
    final String message, {
    final SnackBarType type = SnackBarType.info,
    final Object? logData,
  }) {
    // Pesan log pendek, kaya informasi
    final shortLog = '[SNACKBAR] type=${type.name} msg="$message"';
    switch (type) {
      case SnackBarType.success:
        Log.info(shortLog, logData);
        break;
      case SnackBarType.error:
        Log.error(shortLog, data: logData);
        break;
      case SnackBarType.warning:
        Log.warning(shortLog, logData);
        break;
      case SnackBarType.info:
        Log.info(shortLog, logData);
        break;
    }

    if (!context.mounted) return;

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

  /// Menampilkan SnackBar sukses (hijau).
  static void success(
    final BuildContext context,
    final String message, {
    final Object? logData,
  }) =>
      _show(context, message, type: SnackBarType.success, logData: logData);

  /// Menampilkan SnackBar error (merah).
  static void error(
    final BuildContext context,
    final String message, {
    final Object? logData,
  }) =>
      _show(context, message, type: SnackBarType.error, logData: logData);

  /// Menampilkan SnackBar peringatan (oranye).
  static void warning(
    final BuildContext context,
    final String message, {
    final Object? logData,
  }) =>
      _show(context, message, type: SnackBarType.warning, logData: logData);

  /// Menampilkan SnackBar informasi (biru).
  ///
  /// Karena [SnackBarType.info] sudah menjadi nilai default di `_show`,
  /// pemanggilan tidak perlu menyertakan argumen `type`.
  static void info(
    final BuildContext context,
    final String message, {
    final Object? logData,
  }) =>
      _show(context, message, logData: logData);
}
