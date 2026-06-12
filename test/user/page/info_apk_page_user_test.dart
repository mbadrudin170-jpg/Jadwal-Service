
// path: test/user/page/info_apk_page_user_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wifi/admin/halaman/tes/halaman_tes.dart';
import 'package:wifi/user/page/info_apk_page_user.dart';

void main() {
  // Mock data untuk PackageInfo
  final mockPackageInfo = PackageInfo(
    appName: 'wifi',
    packageName: 'com.example.wifi',
    version: '1.0.0-beta',
    buildNumber: '1',
  );

  // Stub untuk PackageInfo.fromPlatform
  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: mockPackageInfo.appName,
      packageName: mockPackageInfo.packageName,
      version: mockPackageInfo.version,
      buildNumber: mockPackageInfo.buildNumber,
      buildSignature: '',
    );
  });

  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: InfoApkPageUser(),
    );
  }

  group('Uji Halaman Info Aplikasi Pengguna', () {
    testWidgets(
        'Test 01: Render awal menampilkan data statis dan versi awal ...',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verifikasi judul AppBar
      expect(find.text('Info Aplikasi'), findsOneWidget);

      // Verifikasi teks statis
      expect(find.text('Aplikasi Pelanggan'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.text('Dibuat dengan Flutter'), findsOneWidget);

      // Verifikasi versi awal
      expect(find.text('Versi ...'), findsOneWidget);

      // Tunggu frame berikutnya untuk _initPackageInfo selesai
      await tester.pumpAndSettle();
    });

    testWidgets('Test 02: Info paket diinisialisasi dan versi diperbarui',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Versi awal adalah '...'
      expect(find.text('Versi ...'), findsOneWidget);

      // Tunggu Future di initState selesai
      await tester.pumpAndSettle();

      // Verifikasi versi sudah diperbarui
      expect(find.text('Versi 1.0.0'), findsOneWidget);
      expect(find.text('Versi ...'), findsNothing);
    });

    testWidgets('Test 03: Tombol \'Lihat Lisensi\' membuka halaman lisensi',
        (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: const InfoApkPageUser(),
        ),
      );
      await tester.pumpAndSettle();

      // Tekan tombol
      await tester.tap(find.text('Lihat Lisensi'));
      await tester.pumpAndSettle(); // Tunggu animasi dialog

      // Verifikasi bahwa LicensePage ditampilkan. Kita cek dari judulnya.
      expect(find.byType(LicensePage), findsOneWidget);
    });

    testWidgets(
        'Test 04: Tombol \'Pergi ke Detail\' menavigasi ke HalamanTes',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tekan tombol
      await tester.tap(find.text('Pergi ke Detail'));
      await tester.pumpAndSettle(); // Tunggu animasi navigasi

      // Verifikasi bahwa HalamanTes ditampilkan
      expect(find.byType(HalamanTes), findsOneWidget);
    });
  });
}
