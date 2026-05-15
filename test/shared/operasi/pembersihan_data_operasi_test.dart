// path: test/shared/operasi/pembersihan_data_operasi_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/operasi/pembersihan_data_operasi.dart';

// --- Mocks ---
class MockDatabaseHelper extends Mock implements DatabaseHelper {}

class MockDatabase extends Mock implements Database {}

void main() {
  late MockDatabaseHelper mockDbHelper;
  late MockDatabase mockDatabase;
  late PembersihanDataOperasi pembersihanDataOperasi;

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    mockDatabase = MockDatabase();
    pembersihanDataOperasi = PembersihanDataOperasi(dbHelper: mockDbHelper);

    when(() => mockDbHelper.database).thenAnswer((final _) async => mockDatabase);
  });

  group('hapusSemuaDataArsipKadaluarsa', () {
    test('harus menghapus data arsip kadaluarsa dari semua tabel', () async {
      when(() => mockDatabase.rawDelete(any(), any())).thenAnswer((final _) async => 1);

      final result = await pembersihanDataOperasi.hapusSemuaDataArsipKadaluarsa(
        batasHari: 30,
      );

      // 10 tabel menjadi target penghapusan, jadi total 10 baris terhapus
      expect(result, 10);

      verify(() => mockDatabase.rawDelete(any(), any())).called(10);
    });

    test('harus mengembalikan 0 jika tidak ada data yang dihapus', () async {
      when(() => mockDatabase.rawDelete(any(), any())).thenAnswer((final _) async => 0);

      final result = await pembersihanDataOperasi.hapusSemuaDataArsipKadaluarsa(
        batasHari: 30,
      );

      expect(result, 0);
    });

    test('harus tetap lanjut meski satu tabel gagal', () async {
      var callCount = 0;
      when(() => mockDatabase.rawDelete(any(), any()))
          .thenAnswer((final invocation) async {
        callCount++;
        final query = invocation.positionalArguments.first as String;
        // diubah: Menggunakan startsWith untuk memastikan hanya tabel 'pelanggan' yang gagal,
        // bukan 'pelanggan_aktif' juga.
        if (query.startsWith('DELETE FROM pelanggan ')) {
          throw Exception('DB Error');
        }
        return 1;
      });

      final result = await pembersihanDataOperasi.hapusSemuaDataArsipKadaluarsa(
        batasHari: 30,
      );

      // Harus 9 karena satu tabel (dari 10) gagal
      expect(result, 9);
      // Proses harus tetap dipanggil untuk semua 10 tabel
      expect(callCount, 10);
    });
  });
}
