// path: lib/shared/utils/toast_util.dart

import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'package:wifi/shared/debug/log.dart';

enum ToastType { success, error, warning, info }

class ToastUtil {
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
      animationDuration: const Duration(seconds: 1),
      closeButton: const ToastCloseButton(showType: CloseButtonShowType.none),
    );
  }

  static void success(
    final BuildContext context,
    final String message, {
    final Duration? duration,
    final Object? logData,
  }) => _show(
    context,
    message,
    type: ToastType.success,
    duration: duration,
    logData: logData,
  );

  static void error(
    final BuildContext context,
    final String message, {
    final Duration? duration,
    final Object? logData,
  }) => _show(
    context,
    message,
    type: ToastType.error,
    duration: duration,
    logData: logData,
  );

  static void warning(
    final BuildContext context,
    final String message, {
    final Duration? duration,
    final Object? logData,
  }) => _show(
    context,
    message,
    type: ToastType.warning,
    duration: duration,
    logData: logData,
  );

  static void info(
    final BuildContext context,
    final String message, {
    final Duration? duration,
    final Object? logData,
  }) => _show(context, message, duration: duration, logData: logData);
}
