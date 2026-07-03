// path: test/admin/splash_screen_admin_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/admin/app_admin.dart';
import 'package:wifi/admin/splash_screen_admin.dart';

void main() {
  group('SplashScreen', () {
    testWidgets('01. harus menavigasi ke AppAdmin setelah 2 detik', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

      // Verifikasi bahwa splash screen menampilkan CircularProgressIndicator.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Maju cepat 2 detik.
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verifikasi bahwa kita telah menavigasi ke layar AppAdmin.
      expect(find.byType(AppAdmin), findsOneWidget);
    });
  });
}
