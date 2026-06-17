
// path: test/fitur/pelanggan/operasi/pelanggan_op_sqlite_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_sqlite.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_op_sqlite.dart';

import 'pelanggan_op_sqlite_test.mocks.dart';

@GenerateMocks([BaseOpSqlite])
void main() {
  late PelangganOpSqlite pelangganOpSqlite;
  late MockBaseOpSqlite mockBaseOpSqlite;
  late SqliteDatabase sqliteDatabase;

  setUp(() async {
    sqfliteFfiInit();
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await db.execute('''
      CREATE TABLE pelanggan (
        id TEXT PRIMARY KEY,
        nama TEXT,
        telepon TEXT,
        alamat TEXT,
        kataSandi TEXT,
        macAddress TEXT,
        diperbaruiPada INTEGER,
        diHapus INTEGER DEFAULT 0,
        diarsipkanPada INTEGER,
        terkahirAktif INTEGER
      )
      ''');
    sqliteDatabase = SqliteDatabase(db: db);
    mockBaseOpSqlite = MockBaseOpSqlite();
    pelangganOpSqlite = PelangganOpSqlite(
      sqliteDb: sqliteDatabase,
      baseOpSqlite: mockBaseOpSqlite,
    );
  });

  tearDown(() async {
    final db = await sqliteDatabase.database;
    await db.close();
  });

  final pelangganModel = PelangganModel(
    id: '1',
    nama: 'Pelanggan Uji',
    telepon: '08123',
    alamat: 'Jl. Uji',
    kataSandi: '123',
    macAddress: '00:00:00:00:00:00',
  );

  group('PelangganOpSqlite', () {
    test('01. harus memanggil baseOpSqlite.sisipkan saat tambahPelanggan',
        () async {
      when(mockBaseOpSqlite.sisipkan(any, any)).thenAnswer((_) async => 1);

      await pelangganOpSqlite.tambahPelanggan(pelangganModel);

      verify(mockBaseOpSqlite.sisipkan(
        'pelanggan',
        any, // Tidak bisa memprediksi timestamp, jadi gunakan any
      )).called(1);
    });

    test('02. harus mengembalikan list pelanggan saat ambilSemua', () async {
      final db = await sqliteDatabase.database;
      await db.insert('pelanggan', pelangganModel.toSqlite());

      final hasil = await pelangganOpSqlite.ambilSemua();

      expect(hasil, isA<List<PelangganModel>>());
      expect(hasil.length, 1);
      expect(hasil.first.id, '1');
    });

    test('03. harus mengembalikan pelanggan berdasarkan ID', () async {
      final db = await sqliteDatabase.database;
      await db.insert('pelanggan', pelangganModel.toSqlite());

      final hasil = await pelangganOpSqlite.ambilBerdasarkanId('1');

      expect(hasil, isA<PelangganModel>());
      expect(hasil?.id, '1');
    });

    test('04. harus memanggil baseOpSqlite.update saat perbaruiPelanggan',
        () async {
      when(mockBaseOpSqlite.update(any, any, any))
          .thenAnswer((_) async => 1);

      await pelangganOpSqlite.perbaruiPelanggan(pelangganModel);

      verify(mockBaseOpSqlite.update(
        'pelanggan',
        any, // Tidak bisa memprediksi timestamp, jadi gunakan any
        '1',
      )).called(1);
    });

    test('05. harus memanggil baseOpSqlite.softDelete saat softDelete',
        () async {
      when(mockBaseOpSqlite.softDelete(any, any))
          .thenAnswer((_) async => 1);

      await pelangganOpSqlite.softDelete('1');

      verify(mockBaseOpSqlite.softDelete('pelanggan', '1')).called(1);
    });

    test(
        '06. harus memanggil baseOpSqlite.softDeleteAll saat softDeleteSemua',
        () async {
      when(mockBaseOpSqlite.softDeleteAll(any)).thenAnswer((_) async => 1);

      await pelangganOpSqlite.softDeleteSemua();

      verify(mockBaseOpSqlite.softDeleteAll('pelanggan')).called(1);
    });

    test('07. harus mengembalikan perubahan sejak waktu tertentu', () async {
      final now = DateTime.now();
      final oldData = pelangganModel
          .copyWith(
            id: '2',
            diperbaruiPada: now.subtract(const Duration(days: 1)),
          )
          .toSqlite();
      final newData = pelangganModel
          .copyWith(id: '3', diperbaruiPada: now)
          .toSqlite();

      final db = await sqliteDatabase.database;
      await db.insert('pelanggan', oldData);
      await db.insert('pelanggan', newData);

      final hasil = await pelangganOpSqlite
          .ambilPerubahanSejak(now.subtract(const Duration(hours: 1)));

      expect(hasil.length, 1);
      expect(hasil.first.id, '3');
    });

    test(
        '08. harus memanggil sisipkanAtauPerbaruiBatch saat list tidak kosong',
        () async {
      when(mockBaseOpSqlite.sisipkanAtauPerbaruiBatch(any, any))
          .thenAnswer((_) async {});

      await pelangganOpSqlite.sisipkanAtauPerbaruiBatch([pelangganModel]);

      verify(mockBaseOpSqlite.sisipkanAtauPerbaruiBatch('pelanggan', any))
          .called(1);
    });

    test(
        '09. tidak boleh memanggil sisipkanAtauPerbaruiBatch saat list kosong',
        () async {
      await pelangganOpSqlite.sisipkanAtauPerbaruiBatch([]);

      verifyNever(mockBaseOpSqlite.sisipkanAtauPerbaruiBatch(any, any));
    });

    test('10. harus mengembalikan pelanggan berdasarkan list ID', () async {
      final pelanggan2 = pelangganModel.copyWith(id: '2');
      final db = await sqliteDatabase.database;
      await db.insert('pelanggan', pelangganModel.toSqlite());
      await db.insert('pelanggan', pelanggan2.toSqlite());

      final hasil = await pelangganOpSqlite.ambilPelangganBerdasarkanId(['1', '2']);

      expect(hasil.length, 2);
    });

    test(
        '11. harus mengembalikan list kosong jika list ID untuk diambil kosong',
        () async {
      final hasil = await pelangganOpSqlite.ambilPelangganBerdasarkanId([]);

      expect(hasil, isEmpty);
    });
  });
}
