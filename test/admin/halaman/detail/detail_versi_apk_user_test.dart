// path: test/admin/halaman/detail/detail_versi_apk_user_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:wifi/admin/halaman/detail/detail_versi_apk_user.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/model/versi_apk_user_model.dart';

void main() async {
  // Inisialisasi lokalisasi untuk konsistensi tes
  await initializeDateFormatting('id_ID');

  // Data model tiruan untuk pengujian
  final model = VersiApkUserModel(
    id: 'v1.0.0',
    versiTerbaru: '1.0.0',
    catatanRilis: 'Rilis awal aplikasi.',
    wajibUpdate: true,
    youtubeTutorial: 'https://youtube.com/tutorial',
    nomorBuildTerbaru: {
      ArsitekturApkEnum.universal: 10,
    },
    tautanUnduhan: {
      ArsitekturApkEnum.universal: 'https://example.com/app.apk',
    },
  );

  // Grup tes untuk halaman DetailVersiApkUser
  group('Halaman DetailVersiApkUser', () {
    // Fungsi helper untuk membangun widget dalam MaterialApp
    Future<void> pumpWidget(
      final WidgetTester tester,
      final VersiApkUserModel versiApk,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DetailVersiApkUser(versiApk: versiApk),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('Menampilkan semua detail data VersiApkUserModel dengan benar',
        (final tester) async {
      // Me-render widget dengan data model
      await pumpWidget(tester, model);

      // Verifikasi judul AppBar
      expect(find.text('Detail Versi APK'), findsOneWidget);

      // Verifikasi label dan nilai utama
      expect(find.text('Versi Terbaru'), findsOneWidget);
      expect(find.text('1.0.0'), findsOneWidget);

      expect(find.text('Wajib Update'), findsOneWidget);
      expect(find.text('Ya'), findsOneWidget);

      expect(find.text('Catatan Rilis'), findsOneWidget);
      expect(find.text('Rilis awal aplikasi.'), findsOneWidget);

      expect(find.text('Youtube Tutorial'), findsOneWidget);
      expect(find.text('https://youtube.com/tutorial'), findsOneWidget);

      // Verifikasi judul dan konten dari Map
      expect(find.text('Nomor Build Terbaru'), findsOneWidget);
      expect(find.text('Tautan Unduhan'), findsOneWidget);

      // Karena 'universal' digunakan sebagai key di kedua map, kita harus menemukan 2 widget
      expect(find.text('universal'), findsNWidgets(2));
      expect(find.text('10'), findsOneWidget);
      expect(find.text('https://example.com/app.apk'), findsOneWidget);
    });

    testWidgets('Menampilkan "Tidak" untuk wajibUpdate bernilai false',
        (final tester) async {
      // Membuat model dengan wajibUpdate = false
      final modelTidakWajib = model.copyWith(wajibUpdate: false);

      // Me-render widget
      await pumpWidget(tester, modelTidakWajib);

      // Verifikasi 'wajibUpdate' menampilkan "Tidak"
      expect(find.text('Wajib Update'), findsOneWidget);
      expect(find.text('Tidak'), findsOneWidget);
    });
  });
}
