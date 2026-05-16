// path: test/shared/operasi/paket_operasi_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/model/paket_model.dart';
import 'package:wifi/shared/operasi/base_operation.dart';
import 'package:wifi/shared/operasi/package_operation.dart';

import 'paket_operasi_test.mocks.dart';

// info: jalankan `flutter pub run build_runner build --delete-conflicting-outputs` untuk membuat file .mocks.dart
@GenerateMocks([DatabaseHelper, OperasiDasar, Database])
void main() {
  // TODO: ada duplikasi nama method 'getPaket' di kelas PaketOperasi,
  // Pengujian untuk method tersebut tidak dapat dituliskan saat ini.
  // Harap perbaiki implementasi di 'lib/shared/operasi/paket_operasi.dart' terlebih dahulu.
  // Saya akan menuliskan pengujian untuk method lainnya.

  late MockDatabaseHelper mockDbHelper;
  late MockOperasiDasar mockOperasiDasar;
  late MockDatabase mockDatabase;
  late PaketOperasi paketOperasi;

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    mockOperasiDasar = MockOperasiDasar();
    mockDatabase = MockDatabase();
    paketOperasi = PaketOperasi(
      dbHelper: mockDbHelper,
      operasiDasar: mockOperasiDasar,
    );

    when(mockDbHelper.database).thenAnswer((final _) async => mockDatabase);
  });

  group('PaketOperasi', () {
    final paketContoh = PaketModel(
      id: 'paket-1',
      nama: 'Paket 1 Jam',
      harga: 2000,
      durasi: 1,
      tipe: TipeDurasi.jam,
      diperbarui: DateTime.now(),
    );

    test('createPaket harus memanggil sisipkan pada operasiDasar', () async {
      // Arrange
      when(mockOperasiDasar.sisipkan(any, any, dariServer: anyNamed('dariServer')))
          .thenAnswer((final _) async => 1);

      // Act
      await paketOperasi.createPaket(paketContoh);

      // Assert
      verify(mockOperasiDasar.sisipkan(
        'paket',
        any, // We can be more specific here if needed
      )).called(1);
    });

    test('getPaketById harus mengembalikan PaketModel ketika ditemukan', () async {
      // Arrange
      final map = paketContoh.toSqlite();
      when(mockDatabase.query(
        'paket',
        where: 'id = ?',
        whereArgs: [paketContoh.id],
      )).thenAnswer((final _) async => [map]);

      // Act
      final result = await paketOperasi.getPaketById(paketContoh.id);

      // Assert
      expect(result, isA<PaketModel>());
      expect(result?.id, paketContoh.id);
    });
    
    test('getPaketById harus mengembalikan null ketika tidak ditemukan', () async {
      // Arrange
      when(mockDatabase.query(
        'paket',
        where: 'id = ?',
        whereArgs: ['not-found'],
      )).thenAnswer((final _) async => []);

      // Act
      final result = await paketOperasi.getPaketById('not-found');

      // Assert
      expect(result, isNull);
    });

    test('updatePaket harus memanggil perbarui pada operasiDasar', () async {
      // Arrange
      when(mockOperasiDasar.perbarui(any, any, any, dariServer: anyNamed('dariServer')))
          .thenAnswer((final _) async => 1);

      // Act
      await paketOperasi.updatePaket(paketContoh);

      // Assert
      verify(mockOperasiDasar.perbarui(
        'paket',
        any,
        paketContoh.id,
      )).called(1);
    });

    test('hapusPaket harus memanggil hapus pada operasiDasar', () async {
      // Arrange
      when(mockOperasiDasar.hapus(any, any, dariServer: anyNamed('dariServer'))).thenAnswer((final _) async => 1);

      // Act
      await paketOperasi.hapusPaket(paketContoh.id);

      // Assert
      verify(mockOperasiDasar.hapus('paket', paketContoh.id)).called(1);
    });

    // TODO: Tambahkan test untuk method lainnya seperti getAllPaket, getPaketByIsPublic, dll.
    // Pengujian untuk method 'getPaket' dan 'getPaketAktif' tidak dapat dibuat
    // karena adanya duplikasi nama di file implementasi.
  });
}
