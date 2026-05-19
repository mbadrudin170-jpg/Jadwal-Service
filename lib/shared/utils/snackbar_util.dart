// path: lib/shared/utils/snackbar_util.dart
// diubah: Menambahkan GlobalKey dan metode global untuk menampilkan SnackBar dari mana saja.

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
  ///
  /// Ini harus dihubungkan ke properti `scaffoldMessengerKey` di `MaterialApp`.
  /// Berguna untuk menampilkan SnackBar dari dalam service atau logic bisnis
  /// yang tidak memiliki akses ke `BuildContext`.
  ///
  /// Contoh:
  /// ```dart
  /// // Di MaterialApp
  /// MaterialApp(
  ///   scaffoldMessengerKey: SnackBarUtil.key,
  ///   // ...
  /// )
  ///
  /// // Di mana saja dalam aplikasi
  /// SnackBarUtil.globalError('Operasi gagal!');
  /// ```
  static final GlobalKey<ScaffoldMessengerState> key =
      GlobalKey<ScaffoldMessengerState>();

  /// Menampilkan SnackBar menggunakan [BuildContext].
  static void _show(
    final BuildContext context,
    final String message, {
    final SnackBarType type = SnackBarType.info,
    final Object? logData,
  }) {
    if (!context.mounted) return;
    final snackBar = _createSnackBar(message, type, logData);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Menampilkan SnackBar menggunakan [GlobalKey].
  static void _showGlobal(
    final String message, {
    final SnackBarType type = SnackBarType.info,
    final Object? logData,
  }) {
    final messengerState = key.currentState;
    if (messengerState == null) {
      Log.warning(
        'Gagal menampilkan SnackBar global karena ScaffoldMessengerState null.',
        {'message': message, 'type': type.name},
      );
      return;
    }
    final snackBar = _createSnackBar(message, type, logData);
    messengerState.showSnackBar(snackBar);
  }

  /// Membuat widget SnackBar berdasarkan tipe dan pesan.
  static SnackBar _createSnackBar(
    final String message,
    final SnackBarType type,
    final Object? logData,
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
  }) =>
      _show(context, message, type: SnackBarType.success, logData: logData);

  /// Menampilkan SnackBar error (merah) via BuildContext.
  static void error(
    final BuildContext context,
    final String message, {
    final Object? logData,
  }) =>
      _show(context, message, type: SnackBarType.error, logData: logData);

  /// Menampilkan SnackBar peringatan (oranye) via BuildContext.
  static void warning(
    final BuildContext context,
    final String message, {
    final Object? logData,
  }) =>
      _show(context, message, type: SnackBarType.warning, logData: logData);

  /// Menampilkan SnackBar informasi (biru) via BuildContext.
  static void info(
    final BuildContext context,
    final String message, {
    final Object? logData,
  }) =>
      _show(context, message, logData: logData);

  // --- Metode berbasis GlobalKey ---

  /// Menampilkan SnackBar sukses (hijau) secara global.
  static void globalSuccess(final String message, {final Object? logData}) =>
      _showGlobal(message, type: SnackBarType.success, logData: logData);

  /// Menampilkan SnackBar error (merah) secara global.
  static void globalError(final String message, {final Object? logData}) =>
      _showGlobal(message, type: SnackBarType.error, logData: logData);

  /// Menampilkan SnackBar peringatan (oranye) secara global.
  static void globalWarning(final String message, {final Object? logData}) =>
      _showGlobal(message, type: SnackBarType.warning, logData: logData);

  /// Menampilkan SnackBar informasi (biru) secara global.
  static void globalInfo(final String message, {final Object? logData}) =>
      _showGlobal(message, logData: logData);
}
