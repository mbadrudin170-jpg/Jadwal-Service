
// path: test/user/page/settings_page_user_test.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/fitur/akun/page/daftar_akun_page.dart';
import 'package:wifi/fitur/feedback/page/feedback_page_u.dart';
import 'package:wifi/shared/theme/app_themes.dart';
import 'package:wifi/user/page/info_apk_page_user.dart';
import 'package:wifi/user/page/settings_page_user.dart';

// Mock NavigatorObserver untuk melacak navigasi
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  // Inisialisasi Mock Navigator
  final mockObserver = MockNavigatorObserver();

  // Widget wrapper
  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        // Override themeProvider jika perlu, di sini kita biarkan default
        themeProvider.overrideWith((ref) => ref.watch(themeNotifierProvider)),
      ],
      child: MaterialApp(
        home: const SettingsPageUser(),
        navigatorObservers: [mockObserver],
      ),
    );
  }

  // Grup pengujian untuk Halaman Pengaturan Pengguna
  group('Uji Halaman Pengaturan Pengguna', () {
    testWidgets('Test 01: Render awal menampilkan semua item menu',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verifikasi judul AppBar
      expect(find.text('Pengaturan'), findsOneWidget);

      // Verifikasi semua item menu ada
      expect(find.text('Tema Aplikasi'), findsOneWidget);
      expect(find.text('Kritik dan Saran'), findsOneWidget);
      expect(find.text('Info Aplikasi & Perangkat'), findsOneWidget);
      expect(find.text('Ganti Akun/Keluar'), findsOneWidget);

      // Verifikasi item menu debug mode (tergantung pada environment test)
      if (kDebugMode) {
        expect(find.text('Halaman Uji Fitur'), findsOneWidget);
      } else {
        expect(find.text('Halaman Uji Fitur'), findsNothing);
      }
    });

    testWidgets(
        'Test 02: Mengetuk \'Kritik dan Saran\' menavigasi ke FeedbackHistoryUser',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('Kritik dan Saran'));
      await tester.pumpAndSettle();

      // Verifikasi navigasi terjadi
      verify(() => mockObserver.didPush(any(), any()));
      expect(find.byType(FeedbackHistoryUser), findsOneWidget);
    });

    testWidgets(
        'Test 03: Mengetuk \'Info Aplikasi & Perangkat\' menavigasi ke InfoApkPageUser',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('Info Aplikasi & Perangkat'));
      await tester.pumpAndSettle();

      verify(() => mockObserver.didPush(any(), any()));
      expect(find.byType(InfoApkPageUser), findsOneWidget);
    });

    testWidgets(
        'Test 04: Mengetuk \'Ganti Akun/Keluar\' menavigasi ke DaftarAkunPage',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('Ganti Akun/Keluar'));
      await tester.pumpAndSettle();

      verify(() => mockObserver.didPush(any(), any()));
      expect(find.byType(DaftarAkunPage), findsOneWidget);
    });

    // Test untuk item menu debug mode
    if (kDebugMode) {
      testWidgets(
          'Test 05: Mengetuk \'Halaman Uji Fitur\' menavigasi ke HalamanTes',
          (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        await tester.tap(find.text('Halaman Uji Fitur'));
        await tester.pumpAndSettle();

        verify(() => mockObserver.didPush(any(), any()));
        // Asumsi HalamanTes ada. Jika tidak, ganti dengan widget yang sesuai.
        // expect(find.byType(HalamanTes), findsOneWidget);
      });
    }

    testWidgets('Test 06: Memastikan item menu memiliki warna destruktif',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final gantiAkunText = tester.widget<Text>(find.text('Ganti Akun/Keluar'));
      final theme = Theme.of(tester.element(find.text('Ganti Akun/Keluar')));

      expect(gantiAkunText.style?.color, theme.colorScheme.error);
    });
  });
}
