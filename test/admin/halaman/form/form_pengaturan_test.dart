// path: test/admin/halaman/form/form_pengaturan_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wifi/admin/halaman/form/form_pengaturan.dart';
import 'package:wifi/shared/model/pengaturan_model.dart';
import 'package:wifi/shared/operasi/pengaturan_operasi.dart';

import 'form_pengaturan_test.mocks.dart';

// Inisialisasi database factory untuk FFI (diperlukan untuk sqflite di tes)
void initializeDbForTest() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}

@GenerateMocks([PengaturanOperasi])
void main() {
  // Panggil inisialisasi di awal
  setUpAll(() {
    initializeDbForTest();
  });

  late MockPengaturanOperasi mockPengaturanOperasi;
  late PengaturanModel pengaturanAwal;

  setUp(() {
    mockPengaturanOperasi = MockPengaturanOperasi();
    pengaturanAwal = PengaturanModel(
      id: 'konfigurasi_global',
      intervalSinkronisasiOtomatis: 12,
      hapusOtomatisDataArsip: 45,
      modePemeliharaan: false,
      infoPemeliharaan: 'Info awal',
      diperbarui: DateTime(2023, 1, 1),
    );
  });

  // Widget wrapper yang menginjeksi mock
  Widget buildTestableWidget(PengaturanModel pengaturan) {
    return MaterialApp(
      home: FormPengaturan(
        pengaturan: pengaturan,
        pengaturanOperasi: mockPengaturanOperasi, // Injeksi mock
      ),
    );
  }

  group('FormPengaturan Widget Tests', () {
    testWidgets('1. Menampilkan nilai awal dengan benar',
        (final tester) async {
      await tester.pumpWidget(buildTestableWidget(pengaturanAwal));

      expect(find.text('12'), findsOneWidget);
      expect(find.text('45'), findsOneWidget);
      expect(find.text('Info awal'), findsOneWidget);
      expect(
          tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
          isFalse);
    });

    testWidgets('2. Memperbarui field dan menyimpan perubahan',
        (final tester) async {
      // Stubbing mock untuk mengembalikan Future kosong
      when(mockPengaturanOperasi.updatePengaturan(any))
          .thenAnswer((_) async {});

      await tester.pumpWidget(buildTestableWidget(pengaturanAwal));

      // Aksi pengguna
      await tester.enterText(find.widgetWithText(TextFormField, 'Interval Sinkronisasi Otomatis (Jam)'), '24');
      await tester.enterText(find.widgetWithText(TextFormField, 'Hapus Arsip Otomatis (Hari)'), '60');
      await tester.tap(find.byType(SwitchListTile));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle(); // Tunggu navigasi

      // Verifikasi bahwa `updatePengaturan` dipanggil dengan data yang benar
      final captured = verify(mockPengaturanOperasi.updatePengaturan(captureAny)).captured;
      final capturedMap = captured.first as Map<String, dynamic>;

      expect(capturedMap['intervalSinkronisasiOtomatis'], 24);
      expect(capturedMap['hapusOtomatisDataArsip'], 60);
      expect(capturedMap['modePemeliharaan'], isTrue);

      // Verifikasi SnackBar dan navigasi (jika diperlukan)
      expect(find.text('Pengaturan berhasil disimpan'), findsOneWidget);
    });

    testWidgets('3. Menampilkan error validasi jika field kosong',
        (final tester) async {
      await tester.pumpWidget(buildTestableWidget(pengaturanAwal));

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Interval Sinkronisasi Otomatis (Jam)'), '');
      await tester.tap(find.byIcon(Icons.save));
      await tester.pump();

      expect(find.text('Harap masukkan interval'), findsOneWidget);
      verifyNever(mockPengaturanOperasi.updatePengaturan(any));
    });

    testWidgets('4. Menampilkan SnackBar error jika penyimpanan gagal',
        (final tester) async {
      when(mockPengaturanOperasi.updatePengaturan(any))
          .thenThrow(Exception('DB Error'));

      await tester.pumpWidget(buildTestableWidget(pengaturanAwal));

      await tester.tap(find.byIcon(Icons.save));
      await tester.pump(); // Pump untuk memproses Future
      await tester.pump(); // Pump lagi untuk SnackBar

      expect(find.text('Gagal menyimpan: Exception: DB Error'), findsOneWidget);
      verify(mockPengaturanOperasi.updatePengaturan(any)).called(1);
    });
  });
}
