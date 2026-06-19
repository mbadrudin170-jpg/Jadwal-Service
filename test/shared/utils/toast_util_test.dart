// path: test/shared/utils/toast_util_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toastification/toastification.dart';
import 'package:wifi/shared/utils/toast_util.dart';

void main() {
  group('ToastUtil Tests', () {
    testWidgets('01. success() harus berjalan tanpa error', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToastificationWrapper(
              child: Builder(
                builder: (context) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    expect(() => ToastUtil.success(context, 'Berhasil'), returnsNormally);
                  });
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      );

      // Lewati frame pertama setelah callback post-frame dieksekusi
      await tester.pump();
      // Paksa simulasi waktu maju melewati batas autoCloseDuration (2 detik) + animationDuration (1 detik)
      await tester.pump(const Duration(seconds: 4));
      // Bersihkan sisa animasi jika ada
      await tester.pumpAndSettle();
    });

    testWidgets('02. error() harus berjalan tanpa error', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToastificationWrapper(
              child: Builder(
                builder: (context) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    expect(() => ToastUtil.error(context, 'Gagal memuat'), returnsNormally);
                  });
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('03. warning() harus berjalan tanpa error', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToastificationWrapper(
              child: Builder(
                builder: (context) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    expect(() => ToastUtil.warning(context, 'Peringatan'), returnsNormally);
                  });
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });
  });
}