// path: lib/shared/utils/snackbar_util.dart
// diubah: Menambahkan parameter durasi opsional ke semua metode.

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
  /// Kunci global untuk mengakses ScaffoldMessenger dari mana saja di aplikasi.
  static final GlobalKey<ScaffoldMessengerState> key =
      GlobalKey<ScaffoldMessengerState>();

  /// Menampilkan SnackBar menggunakan [BuildContext].
  static void _show(
    final BuildContext context,
    final String message, {
    final SnackBarType type = SnackBarType.info,
    final Object? logData,
    final Duration? duration,
  }) {
    if (!context.mounted) return;
    final snackBar = _createSnackBar(message, type, logData, duration);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Menampilkan SnackBar menggunakan [GlobalKey].
  static void _showGlobal(
    final String message, {
    final SnackBarType type = SnackBarType.info,
    final Object? logData,
    final Duration? duration,
  }) {
    final messengerState = key.currentState;
    if (messengerState == null) {
      Log.warning(
        'Gagal menampilkan SnackBar global karena ScaffoldMessengerState null.',
        {'message': message, 'type': type.name},
      );
      return;
    }
    final snackBar = _createSnackBar(message, type, logData, duration);
    messengerState.showSnackBar(snackBar);
  }

  /// Membuat widget SnackBar berdasarkan tipe dan pesan.
  static SnackBar _createSnackBar(
    final String message,
    final SnackBarType type,
    final Object? logData,
    final Duration? duration,
  ) {
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

    return SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      // Gunakan durasi yang diberikan, atau default 4 detik jika null.
      duration: duration ?? const Duration(seconds: 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }

  // --- Metode berbasis BuildContext ---

  /// Menampilkan SnackBar sukses (hijau) via BuildContext.
  static void success(
    final BuildContext context,
    final String message, {
    final Object? logData,
    final Duration? duration,
  }) =>
      _show(
        context,
        message,
        type: SnackBarType.success,
        logData: logData,
        duration: duration,
      );

  /// Menampilkan SnackBar error (merah) via BuildContext.
  static void error(
    final BuildContext context,
    final String message, {
    final Object? logData,
    final Duration? duration,
  }) =>
      _show(
        context,
        message,
        type: SnackBarType.error,
        logData: logData,
        duration: duration,
      );

  /// Menampilkan SnackBar peringatan (oranye) via BuildContext.
  static void warning(
    final BuildContext context,
    final String message, {
    final Object? logData,
    final Duration? duration,
  }) =>
      _show(
        context,
        message,
        type: SnackBarType.warning,
        logData: logData,
        duration: duration,
      );

  /// Menampilkan SnackBar informasi (biru) via BuildContext.
  static void info(
    final BuildContext context,
    final String message, {
    final Object? logData,
    final Duration? duration,
  }) =>
      _show(
        context,
        message,
        logData: logData,
        duration: duration,
      );

  // --- Metode berbasis GlobalKey ---

  /// Menampilkan SnackBar sukses (hijau) secara global.
  static void globalSuccess(
    final String message, {
    final Object? logData,
    final Duration? duration,
  }) =>
      _showGlobal(
        message,
        type: SnackBarType.success,
        logData: logData,
        duration: duration,
      );

  /// Menampilkan SnackBar error (merah) secara global.
  static void globalError(
    final String message, {
    final Object? logData,
    final Duration? duration,
  }) =>
      _showGlobal(
        message,
        type: SnackBarType.error,
        logData: logData,
        duration: duration,
      );

  /// Menampilkan SnackBar peringatan (oranye) secara global.
  static void globalWarning(
    final String message, {
    final Object? logData,
    final Duration? duration,
  }) =>
      _showGlobal(
        message,
        type: SnackBarType.warning,
        logData: logData,
        duration: duration,
      );

  /// Menampilkan SnackBar informasi (biru) secara global.
  static void globalInfo(
    final String message, {
    final Object? logData,
    final Duration? duration,
  }) =>
      _showGlobal(
        message,
        logData: logData,
        duration: duration,
      );
}
