// path: lib/shared/utils/toast_util.dart
// diubah: Mempercepat animasi agar tidak terasa delay.

import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'package:wifi/shared/debug/log.dart';

/// Tipe Toast yang tersedia.
enum ToastType {
  /// Toast sukses.
  success,

  /// Toast error.
  error,

  /// Toast peringatan.
  warning,

  /// Toast informasi.
  info,
}

/// Kelas utilitas untuk menampilkan Toast dengan gaya yang konsisten
/// sekaligus mencatat log otomatis menggunakan [Log].
class ToastUtil {
  /// Menampilkan Toast.
  static void _show(
    final BuildContext context,
    final String message, {
    final ToastType type = ToastType.info,
    final Duration? duration,
    final Object? logData,
  }) {
    if (!context.mounted) return;
    _createToast(context, message, type, logData, duration);
  }

  /// Membuat dan menampilkan Toast berdasarkan tipe dan pesan.
  static void _createToast(
    final BuildContext context,
    final String message,
    final ToastType type,
    final Object? logData,
    final Duration? duration,
  ) {
    final shortLog = '[TOAST] type=${type.name} msg="$message"';
    switch (type) {
      case ToastType.success:
        Log.info(shortLog, logData);
        break;
      case ToastType.error:
        Log.error(shortLog, data: logData);
        break;
      case ToastType.warning:
        Log.warning(shortLog, logData);
        break;
      case ToastType.info:
        Log.info(shortLog, logData);
        break;
    }

    ToastificationType toastType;
    switch (type) {
      case ToastType.success:
        toastType = ToastificationType.success;
        break;
      case ToastType.error:
        toastType = ToastificationType.error;
        break;
      case ToastType.warning:
        toastType = ToastificationType.warning;
        break;
      case ToastType.info:
        toastType = ToastificationType.info;
        break;
    }

    toastification.show(
      context: context,
      type: toastType,
      title: Text(message),
      autoCloseDuration: duration ?? const Duration(seconds: 2),
      alignment: Alignment.topCenter,
      // Perkecil durasi animasi agar toast muncul lebih cepat.
      animationDuration: const Duration(milliseconds: 200),
      closeButton: const ToastCloseButton(showType: CloseButtonShowType.none),
    );
  }

  // --- Metode berbasis BuildContext ---

  /// Menampilkan Toast sukses via BuildContext.
  static void success(
    final BuildContext context,
    final String message, {
    final Duration? duration,
    final Object? logData,
  }) =>
      _show(
        context,
        message,
        type: ToastType.success,
        duration: duration,
        logData: logData,
      );

  /// Menampilkan Toast error via BuildContext.
  static void error(
    final BuildContext context,
    final String message, {
    final Duration? duration,
    final Object? logData,
  }) =>
      _show(
        context,
        message,
        type: ToastType.error,
        duration: duration,
        logData: logData,
      );

  /// Menampilkan Toast peringatan via BuildContext.
  static void warning(
    final BuildContext context,
    final String message, {
    final Duration? duration,
    final Object? logData,
  }) =>
      _show(
        context,
        message,
        type: ToastType.warning,
        duration: duration,
        logData: logData,
      );

  /// Menampilkan Toast informasi via BuildContext.
  static void info(
    final BuildContext context,
    final String message, {
    final Duration? duration,
    final Object? logData,
  }) =>
      _show(
        context,
        message,
        duration: duration,
        logData: logData,
      );
}
