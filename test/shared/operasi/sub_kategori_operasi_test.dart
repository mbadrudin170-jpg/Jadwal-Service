// path: test/shared/operasi/sub_kategori_operasi_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/model/sub_kategori_model.dart';
import 'package:wifi/shared/operasi/operasi_dasar.dart';
import 'package:wifi/shared/operasi/sub_kategori_operasi.dart';

// --- Mocks ---
class MockDatabaseHelper extends Mock implements DatabaseHelper {}

class MockOperasiDasar extends Mock implements OperasiDasar {}

class MockDatabase extends Mock implements Database {}

void main() {
  late SubKategoriOperasi subKategoriOperasi;
  late MockDatabaseHelper mockDbHelper;
  late MockOperasiDasar mockOperasiDasar;
  late MockDatabase mockDatabase;

  final tSubKategoriModel = SubKategoriModel(
    id: '1',
    idKategori: 'cat_1',
    nama: 'Sub Test',
  );

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    mockOperasiDasar = MockOperasiDasar();
    mockDatabase = MockDatabase();

    subKategoriOperasi = SubKategoriOperasi();
    subKategoriOperasi.testSetDbHelper(mockDbHelper);
    subKategoriOperasi.testSetOperasiDasar(mockOperasiDasar);

    when(() => mockDbHelper.database).thenAnswer((final _) async => mockDatabase);
  });

  group('SubKategoriOperasi Tests', () {
    test('createSubKategori harus memanggil fungsi sisipkan pada OperasiDasar',
        () async {
      when(
        () => mockOperasiDasar.sisipkan(
          any(),
          any(),
          dariServer: any(named: 'dariServer'),
        ),
      ).thenAnswer((final _) async => 1);

      await subKategoriOperasi.createSubKategori(tSubKategoriModel);

      verify(
        () => mockOperasiDasar.sisipkan(
          'sub_kategori',
          any(that: isA<Map<String, dynamic>>()),
        ),
      ).called(1);
    });

    test(
        'getSubKategoriByKategoriId harus mengembalikan daftar SubKategoriModel',
        () async {
      when(
        () => mockDatabase.query(
          'sub_kategori',
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'),
        ),
      ).thenAnswer(
        (final _) async => [
          {
            'id': '1',
            'id_kategori': 'cat_1',
            'nama': 'Sub Test',
            'isDeleted': 0,
            'diperbarui': DateTime.now().millisecondsSinceEpoch,
          },
        ],
      );

      final result =
          await subKategoriOperasi.getSubKategoriByKategoriId('cat_1');

      expect(result, isA<List<SubKategoriModel>>());
      expect(result.first.id, '1');
      verify(
        () => mockDatabase.query(
          'sub_kategori',
          where: 'id_kategori = ? AND isDeleted = ?',
          whereArgs: ['cat_1', 0],
        ),
      ).called(1);
    });

    test('deleteSubKategori (softDelete) harus memanggil fungsi perbarui',
        () async {
      when(
        () => mockOperasiDasar.perbarui(
          any(),
          any(),
          any(),
          dariServer: any(named: 'dariServer'),
        ),
      ).thenAnswer((final _) async => {});

      await subKategoriOperasi.deleteSubKategori('1');

      verify(
        () => mockOperasiDasar.perbarui(
            'sub_kategori', any(that: isA<Map<String, dynamic>>()), '1',),
      ).called(1);
    });

    test('deleteSubKategori (hard delete) harus memanggil fungsi hapus',
        () async {
      when(
        () => mockOperasiDasar.hapus(
          any(),
          any(),
          dariServer: any(named: 'dariServer'),
        ),
      ).thenAnswer((final _) async => {});

      await subKategoriOperasi.deleteSubKategori('1', softDelete: false);

      verify(() => mockOperasiDasar.hapus('sub_kategori', '1')).called(1);
    });

    test('sisipkanAtauPerbaruiBatch tidak melakukan apa-apa jika list kosong',
        () async {
      await subKategoriOperasi.sisipkanAtauPerbaruiBatch([]);

      verifyNever(() => mockOperasiDasar.sisipkanAtauPerbaruiBatch(any(), any(),
          dariServer: any(named: 'dariServer'),),);
    });

    test('sisipkanAtauPerbaruiBatch harus memanggil operasi dasar', () async {
      when(
        () => mockOperasiDasar.sisipkanAtauPerbaruiBatch(
          any(),
          any(),
          dariServer: any(named: 'dariServer'),
        ),
      ).thenAnswer((final _) async => {});

      await subKategoriOperasi.sisipkanAtauPerbaruiBatch([tSubKategoriModel]);

      verify(
        () => mockOperasiDasar.sisipkanAtauPerbaruiBatch(
          'sub_kategori',
          any(that: isA<List<Map<String, dynamic>>>()),
        ),
      ).called(1);
    });
  });
}
