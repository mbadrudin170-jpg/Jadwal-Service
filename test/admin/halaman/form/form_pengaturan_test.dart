// path: test/admin/halaman/form/form_pengaturan_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wifi/admin/halaman/form/settings_form.dart';
import 'package:wifi/shared/model/settings_model.dart';
import 'package:wifi/shared/operasi/settings_operation.dart';

import 'form_pengaturan_test.mocks.dart';

// Inisialisasi database factory untuk FFI (diperlukan untuk sqflite di tes)
void initializeDbForTest() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}

@GenerateMocks([SettingsOperation])
void main() {
  // Panggil inisialisasi di awal
  setUpAll(initializeDbForTest);

  late MockSettingsOperation mockSettingsOperation;
  late SettingsModel pengaturanAwal;

  setUp(() {
    mockSettingsOperation = MockSettingsOperation();
    pengaturanAwal = SettingsModel(
      autoSyncInterval: 12,
      autoDeleteArchive: 45,
      maintenanceInfo: 'Info awal',
      updatedAt: DateTime(2023),
    );
  });

  // Widget wrapper yang menginjeksi mock
  Widget buildTestableWidget(final SettingsModel pengaturan) {
    return MaterialApp(
      home: SettingsForm(
        settings: pengaturan,
        settingsOperation: mockSettingsOperation, // Injeksi mock
      ),
    );
  }

  group('SettingsForm Widget Tests', () {
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
      when(mockSettingsOperation.updateSettings(any))
          .thenAnswer((final _) async {});

      await tester.pumpWidget(buildTestableWidget(pengaturanAwal));

      // Aksi pengguna
      await tester.enterText(find.widgetWithText(TextFormField, 'Interval Sinkronisasi Otomatis (Jam)'), '24');
      await tester.enterText(find.widgetWithText(TextFormField, 'Hapus Arsip Otomatis (Hari)'), '60');
      await tester.tap(find.byType(SwitchListTile));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle(); // Tunggu navigasi

      // Verifikasi bahwa `updateSettings` dipanggil dengan data yang benar
      final captured = verify(mockSettingsOperation.updateSettings(captureAny)).captured;
      final capturedMap = captured.first as Map<String, dynamic>;

      expect(capturedMap['autoSyncInterval'], 24);
      expect(capturedMap['autoDeleteArchive'], 60);
      expect(capturedMap['maintenanceMode'], isTrue);

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
      verifyNever(mockSettingsOperation.updateSettings(any));
    });

    testWidgets('4. Menampilkan SnackBar error jika penyimpanan gagal',
        (final tester) async {
      when(mockSettingsOperation.updateSettings(any))
          .thenThrow(Exception('DB Error'));

      await tester.pumpWidget(buildTestableWidget(pengaturanAwal));

      await tester.tap(find.byIcon(Icons.save));
      await tester.pump(); // Pump untuk memproses Future
      await tester.pump(); // Pump lagi untuk SnackBar

      expect(find.text('Gagal menyimpan: Exception: DB Error'), findsOneWidget);
      verify(mockSettingsOperation.updateSettings(any)).called(1);
    });
  });
}
