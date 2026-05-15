
// path: test/shared/utils/snackbar_util_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/shared/utils/snackbar_util.dart';

void main() {
  // Kunci global untuk mengakses ScaffoldMessengerState tanpa BuildContext
  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  // Widget pembungkus untuk menyediakan MaterialApp dan ScaffoldMessenger
  Widget createTestWidget(final Widget child) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('SnackBarUtil Tests', () {
    testWidgets('showSuccess menampilkan SnackBar berwarna hijau dengan pesan yang benar',
        (final tester) async {
      const message = 'Operasi berhasil';

      // Bangun widget dan panggil showSuccess
      await tester.pumpWidget(createTestWidget(
        Builder(
          builder: (final context) {
            // Panggil setelah frame pertama selesai dibangun
            WidgetsBinding.instance.addPostFrameCallback((final _) {
              SnackBarUtil.showSuccess(context, message);
            });
            return Container();
          },
        ),
      ));

      // Pump sekali lagi untuk memproses pemanggilan showSnackBar
      await tester.pump();

      // Verifikasi bahwa SnackBar muncul
      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar, isNotNull);

      // Verifikasi warna latar belakang
      expect(snackBar.backgroundColor, Colors.green);

      // Verifikasi konten pesan
      final textWidget = snackBar.content as Text;
      expect(textWidget.data, message);
    });

    testWidgets('showError menampilkan SnackBar berwarna merah dengan pesan yang benar',
        (final tester) async {
      const message = 'Terjadi kesalahan';

      await tester.pumpWidget(createTestWidget(
        Builder(
          builder: (final context) {
            WidgetsBinding.instance.addPostFrameCallback((final _) {
              SnackBarUtil.showError(context, message);
            });
            return Container();
          },
        ),
      ));

      await tester.pump();

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar, isNotNull);
      expect(snackBar.backgroundColor, Colors.red);
      final textWidget = snackBar.content as Text;
      expect(textWidget.data, message);
    });

    testWidgets('showWarning menampilkan SnackBar berwarna oranye dengan pesan yang benar',
        (final tester) async {
      const message = 'Peringatan, harap periksa kembali';

      await tester.pumpWidget(createTestWidget(
        Builder(
          builder: (final context) {
            WidgetsBinding.instance.addPostFrameCallback((final _) {
              SnackBarUtil.showWarning(context, message);
            });
            return Container();
          },
        ),
      ));

      await tester.pump();

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar, isNotNull);
      expect(snackBar.backgroundColor, Colors.orange);
      final textWidget = snackBar.content as Text;
      expect(textWidget.data, message);
    });

    testWidgets('showInfo menampilkan SnackBar berwarna biru dengan pesan yang benar',
        (final tester) async {
      const message = 'Informasi penting untuk Anda';

      await tester.pumpWidget(createTestWidget(
        Builder(
          builder: (final context) {
            WidgetsBinding.instance.addPostFrameCallback((final _) {
              SnackBarUtil.showInfo(context, message);
            });
            return Container();
          },
        ),
      ));

      await tester.pump();

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar, isNotNull);
      expect(snackBar.backgroundColor, Colors.blue);
      final textWidget = snackBar.content as Text;
      expect(textWidget.data, message);
    });
  });
}
