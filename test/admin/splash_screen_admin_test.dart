// path: test/admin/splash_screen_admin_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/admin/splash_screen_admin.dart';

void main() {
  group('SplashScreen Widget Test', () {
    testWidgets('menampilkan semua elemen UI dengan pesan default', (final tester) async {
      // Build SplashScreen dengan pesan default.
      await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

      // Verifikasi bahwa gambar logo ditampilkan.
      expect(find.byType(Image), findsOneWidget);

      // Verifikasi bahwa judul "Admin WiFi" ditampilkan.
      expect(find.text('Admin WiFi'), findsOneWidget);

      // Verifikasi bahwa CircularProgressIndicator ditampilkan.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Verifikasi bahwa pesan pemuatan default "Memuat..." ditampilkan.
      expect(find.text('Memuat...'), findsOneWidget);
    });

    testWidgets('menampilkan semua elemen UI dengan pesan khusus', (final tester) async {
      const customMessage = 'Sedang memeriksa pembaruan...';

      // Build SplashScreen dengan pesan khusus.
      await tester.pumpWidget(const MaterialApp(
        home: SplashScreen(loadingMessage: customMessage),
      ));

      // Verifikasi bahwa gambar logo ditampilkan.
      expect(find.byType(Image), findsOneWidget);

      // Verifikasi bahwa judul "Admin WiFi" ditampilkan.
      expect(find.text('Admin WiFi'), findsOneWidget);

      // Verifikasi bahwa CircularProgressIndicator ditampilkan.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Verifikasi bahwa pesan pemuatan khusus ditampilkan.
      expect(find.text(customMessage), findsOneWidget);

      // Pastikan pesan default tidak ada.
      expect(find.text('Memuat...'), findsNothing);
    });
  });
}
