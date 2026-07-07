// path: test/admin/splash_screen_admin_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/admin/app_admin.dart';
import 'package:wifi/admin/splash_screen_admin.dart';

void main() {
  group('SplashScreen', () {
    testWidgets(
      '01. harus menavigasi ke AppAdmin setelah 2 detik',
      (tester) async {
        // Render SplashScreen
        await tester.pumpWidget(
          const MaterialApp(
            home: SplashScreen(
              loadingMessage: 'Memuat...',
            ),
          ),
        );

        // Verifikasi SplashScreen tampil
        expect(find.byType(SplashScreen), findsOneWidget);
        expect(find.text('Admin WiFi'), findsOneWidget);
        expect(find.text('Memuat...'), findsOneWidget);

        // JALANKAN FUTURE DELAY SECARA MANUAL
        // Ini akan menjalankan semua Future yang tertunda
        await tester.runAsync(() async {
          // Tunggu 2 detik secara real
          await Future.delayed(const Duration(seconds: 2));
        });

        // Rebuild widget setelah Future selesai
        await tester.pump();

        // Verifikasi navigasi ke AppAdmin
        expect(find.byType(AppAdmin), findsOneWidget);
      },
    );

    testWidgets(
      '02. harus menampilkan pesan loading yang benar',
      (tester) async {
        const customMessage = 'Sedang memuat data...';
        
        await tester.pumpWidget(
          const MaterialApp(
            home: SplashScreen(
              loadingMessage: customMessage,
            ),
          ),
        );

        expect(find.text(customMessage), findsOneWidget);
        expect(find.text('Admin WiFi'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      '03. harus menampilkan logo aplikasi',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: SplashScreen(),
          ),
        );

        // Verifikasi logo
        expect(find.image(const AssetImage('assets/image/ikon_apk.png')), findsOneWidget);
      },
    );

    testWidgets(
      '04. harus bisa mengganti pesan loading',
      (tester) async {
        const message1 = 'Pesan pertama';
        const message2 = 'Pesan kedua';
        
        // Test dengan pesan pertama
        await tester.pumpWidget(
          const MaterialApp(
            home: SplashScreen(
              loadingMessage: message1,
            ),
          ),
        );
        expect(find.text(message1), findsOneWidget);
        expect(find.text(message2), findsNothing);

        // Rebuild dengan pesan kedua
        await tester.pumpWidget(
          const MaterialApp(
            home: SplashScreen(
              loadingMessage: message2,
            ),
          ),
        );
        expect(find.text(message2), findsOneWidget);
        expect(find.text(message1), findsNothing);
      },
    );
  });
}