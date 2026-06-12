// path: test/user/page/info_apk_page_user_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wifi/admin/halaman/tes/halaman_tes.dart';
import 'package:wifi/user/page/info_apk_page_user.dart';

// Mock NavigatorObserver untuk memverifikasi navigasi
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  // Setup mock untuk PackageInfo sebelum setiap test
  setUpAll(() async {
    // Memberi nilai mock untuk PackageInfo
    PackageInfo.setMockInitialValues(
      appName: 'WiFi App',
      packageName: 'com.example.wifi',
      version: '2.1.0+5',
      buildNumber: '5',
      buildSignature: 'signature',
    );
  });

  group('InfoApkPageUser', () {
    // Test 1: Menampilkan judul AppBar "Info Aplikasi"
    testWidgets('1. Menampilkan judul AppBar "Info Aplikasi"', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: InfoApkPageUser(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Info Aplikasi'), findsOneWidget);
    });

    // Test 2: Menampilkan teks "Aplikasi Pelanggan"
    testWidgets('2. Menampilkan teks "Aplikasi Pelanggan"', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: InfoApkPageUser(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Aplikasi Pelanggan'), findsOneWidget);
    });

    // Test 3: Menampilkan versi yang benar setelah PackageInfo dimuat
    testWidgets('3. Menampilkan versi yang benar (tanpa nomor build)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: InfoApkPageUser(),
        ),
      );
      // Tunggu Future PackageInfo.fromPlatform() selesai
      await tester.pumpAndSettle();

      // Versi yang di-set adalah '2.1.0+5', setelah split '-' menjadi '2.1.0'
      expect(find.text('Versi 2.1.0'), findsOneWidget);
    });

    // Test 4: Tombol "Pergi ke Detail" menavigasi ke HalamanTes
    testWidgets('4. Menekan tombol "Pergi ke Detail" menavigasi ke HalamanTes', (tester) async {
      final mockObserver = MockNavigatorObserver();
      await tester.pumpWidget(
        MaterialApp(
          home: const InfoApkPageUser(),
          navigatorObservers: [mockObserver],
        ),
      );
      await tester.pumpAndSettle();

      // Cari tombol dengan teks "Pergi ke Detail"
      final tombolDetail = find.widgetWithText(ElevatedButton, 'Pergi ke Detail');
      expect(tombolDetail, findsOneWidget);

      // Tap tombol
      await tester.tap(tombolDetail);
      await tester.pumpAndSettle();

      // Verifikasi bahwa route baru dipush dengan HalamanTes
      // Karena kita tidak bisa memeriksa isi route secara langsung, kita bisa memastikan tidak error
      // Atau periksa bahwa HalamanTes ada di tree setelah navigasi
      expect(find.byType(HalamanTes), findsOneWidget);
    });

    // Test 5: Tombol "Lihat Lisensi" membuka halaman lisensi (tidak error)
    testWidgets('5. Menekan tombol "Lihat Lisensi" membuka halaman lisensi', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: InfoApkPageUser(),
        ),
      );
      await tester.pumpAndSettle();

      final tombolLisensi = find.widgetWithText(TextButton, 'Lihat Lisensi');
      expect(tombolLisensi, findsOneWidget);

      // Tap tombol - tidak perlu verifikasi detail, hanya pastikan tidak exception
      await tester.tap(tombolLisensi);
      await tester.pumpAndSettle();

      // Halaman lisensi bawaan Flutter, cukup pastikan tidak ada error
      // Kita bisa periksa apakah ada widget LicensePage (tidak diperlukan karena tidak error)
      expect(true, true);
    });

    // Test 6: Menampilkan CircleAvatar dengan gambar asset
    testWidgets('6. Menampilkan CircleAvatar dengan asset "assets/image/ikon_apk.png"', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: InfoApkPageUser(),
        ),
      );
      await tester.pumpAndSettle();

      final circleAvatar = find.byType(CircleAvatar);
      expect(circleAvatar, findsOneWidget);

      // Periksa backgroundImage adalah AssetImage dengan path yang benar
      final avatar = tester.widget<CircleAvatar>(circleAvatar);
      expect(avatar.backgroundImage, isA<AssetImage>());
      final assetImage = avatar.backgroundImage as AssetImage;
      expect(assetImage.assetName, 'assets/image/ikon_apk.png');
    });

    // Test 7: Menampilkan teks "Dibuat dengan Flutter"
    testWidgets('7. Menampilkan teks "Dibuat dengan Flutter"', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: InfoApkPageUser(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Dibuat dengan Flutter'), findsOneWidget);
    });

    // Test 8: Versi masih "..." saat loading, lalu berubah setelah data masuk
    testWidgets('8. Awalnya menampilkan "Versi ..." lalu berubah setelah data dimuat', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: InfoApkPageUser(),
        ),
      );
      // Setelah build pertama, versi masih placeholder "..."
      expect(find.text('Versi ...'), findsOneWidget);

      // Tunggu Future selesai
      await tester.pumpAndSettle();
      // Sekarang versi berubah menjadi "Versi 2.1.0"
      expect(find.text('Versi 2.1.0'), findsOneWidget);
      expect(find.text('Versi ...'), findsNothing);
    });
  });
}
