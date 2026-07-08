// path: test/fitur/investasi/operasi/investasi_op_sqlite_test.dart

import 'package:mocktail/mocktail.dart';
import 'package:sqflite/sqflite.dart';
import 'package:test/test.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/investasi/model/dividen_model.dart';
import 'package:wifi/fitur/investasi/model/investasi_model.dart';
import 'package:wifi/fitur/investasi/operasi/investasi_op_sqlite.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_op_sqlite.dart';

// ============================================================
// MOCK CLASS (Mocktail - tanpa generator)
// ============================================================

class MockSqliteDatabase extends Mock implements SqliteDatabase {}

class MockDatabase extends Mock implements Database {}

class MockBaseOpSqlite extends Mock implements BaseOpSqlite {}

// ============================================================
// MAIN TEST
// ============================================================

void main() {
  // ============================================================
  // VARIABEL
  // ============================================================

  late InvestasiOpSqlite investasiOp;
  late MockSqliteDatabase mockSqliteDb;
  late MockDatabase mockDatabase;
  late MockBaseOpSqlite mockBaseOp;

  // ============================================================
  // DATA DUMMY
  // ============================================================

  final dummyInvestasi = InvestasiModel(
    id: 'inv-001',
    idInvestor: 'investor-001',
    idTransaksi: 'trx-001',
    jumlahModal: 5000000,
    jumlahLembar: 50,
    tanggalInvestasi: DateTime(2024, 1, 15),
  );

  final dummyDividen = DividenModel(
    id: 'div-001',
    idInvestasi: 'inv-001',
    idInvestor: 'investor-001',
    jumlahDividen: 500000,
    tanggalPembagian: DateTime(2024, 2, 15),
    sudahDibayar: false,
  );

  // ============================================================
  // SETUP
  // ============================================================

  setUp(() {
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(<Map<String, dynamic>>[]);

    mockSqliteDb = MockSqliteDatabase();
    mockDatabase = MockDatabase();
    mockBaseOp = MockBaseOpSqlite();

    when(() => mockSqliteDb.database).thenAnswer((_) async => mockDatabase);

    investasiOp = InvestasiOpSqlite(
      sqliteDb: mockSqliteDb,
      baseOpSqlite: mockBaseOp,
    );
  });

  // ============================================================
  // TEST TAMBAH INVESTASI
  // ============================================================

  group('InvestasiOpSqlite - tambahInvestasi', () {
    test('harus berhasil menambahkan investasi baru', () async {
      when(
        () => mockBaseOp.sisipkan(
          any(),
          any(),
          dariServer: any(named: 'dariServer'),
        ),
      ).thenAnswer((_) async => Future.value());

      await expectLater(
        investasiOp.tambahInvestasi(dummyInvestasi),
        completes,
      );

      verify(
        () => mockBaseOp.sisipkan(
          any(),
          any(),
          dariServer: any(named: 'dariServer'),
        ),
      ).called(1);
    });

    test('harus melempar error jika gagal menambahkan', () async {
      when(
        () => mockBaseOp.sisipkan(
          any(),
          any(),
          dariServer: any(named: 'dariServer'),
        ),
      ).thenThrow(Exception('Database error'));

      await expectLater(
        investasiOp.tambahInvestasi(dummyInvestasi),
        throwsA(isA<Exception>()),
      );
    });
  });

  // ============================================================
  // TEST AMBIL SEMUA INVESTASI
  // ============================================================

  group('InvestasiOpSqlite - ambilSemuaInvestasi', () {
    test('harus mengembalikan list investasi jika ada data', () async {
      final mockMaps = [
        {
          'id': 'inv-001',
          'id_investor': 'investor-001',
          'id_transaksi': 'trx-001',
          'jumlah_modal': 5000000,
          'jumlah_lembar': 50,
          'tanggal_investasi': 1705315200000,
          'is_deleted': 0,
        },
      ];

      when(() => mockDatabase.query(
            any(),
            where: any(named: 'where'),
            orderBy: any(named: 'orderBy'),
          )).thenAnswer((_) async => mockMaps);

      final result = await investasiOp.ambilSemuaInvestasi();

      expect(result, isNotEmpty);
      expect(result.first.id, equals('inv-001'));
      expect(result.first.jumlahModal, equals(5000000));
    });

    test('harus mengembalikan list kosong jika tidak ada data', () async {
      when(() => mockDatabase.query(
            any(),
            where: any(named: 'where'),
            orderBy: any(named: 'orderBy'),
          )).thenAnswer((_) async => []);

      final result = await investasiOp.ambilSemuaInvestasi();

      expect(result, isEmpty);
    });

    test('harus melempar error jika query gagal', () async {
      when(() => mockDatabase.query(
            any(),
            where: any(named: 'where'),
            orderBy: any(named: 'orderBy'),
          )).thenThrow(Exception('Query error'));

      await expectLater(
        investasiOp.ambilSemuaInvestasi(),
        throwsA(isA<Exception>()),
      );
    });
  });

  // ============================================================
  // TEST AMBIL INVESTASI BERDASARKAN ID
  // ============================================================

  group('InvestasiOpSqlite - ambilInvestasiById', () {
    test('harus mengembalikan investasi jika ditemukan', () async {
      final mockMaps = [
        {
          'id': 'inv-001',
          'id_investor': 'investor-001',
          'id_transaksi': 'trx-001',
          'jumlah_modal': 5000000,
          'jumlah_lembar': 50,
          'tanggal_investasi': 1705315200000,
          'is_deleted': 0,
        },
      ];

      when(() => mockDatabase.query(
            any(),
            where: any(named: 'where'),
            whereArgs: any(named: 'whereArgs'),
          )).thenAnswer((_) async => mockMaps);

      final result = await investasiOp.ambilInvestasiById('inv-001');

      expect(result, isNotNull);
      expect(result!.id, equals('inv-001'));
    });

    test('harus mengembalikan null jika tidak ditemukan', () async {
      when(() => mockDatabase.query(
            any(),
            where: any(named: 'where'),
            whereArgs: any(named: 'whereArgs'),
          )).thenAnswer((_) async => []);

      final result = await investasiOp.ambilInvestasiById('inv-999');

      expect(result, isNull);
    });
  });

  // ============================================================
  // TEST AMBIL INVESTASI BERDASARKAN ID INVESTOR
  // ============================================================

  group('InvestasiOpSqlite - ambilInvestasiByIdInvestor', () {
    test('harus mengembalikan list investasi untuk investor tertentu', () async {
      final mockMaps = [
        {
          'id': 'inv-001',
          'id_investor': 'investor-001',
          'id_transaksi': 'trx-001',
          'jumlah_modal': 5000000,
          'jumlah_lembar': 50,
          'tanggal_investasi': 1705315200000,
          'is_deleted': 0,
        },
        {
          'id': 'inv-002',
          'id_investor': 'investor-001',
          'id_transaksi': 'trx-002',
          'jumlah_modal': 3000000,
          'jumlah_lembar': 30,
          'tanggal_investasi': 1707907200000,
          'is_deleted': 0,
        },
      ];

      when(() => mockDatabase.query(
            any(),
            where: any(named: 'where'),
            whereArgs: any(named: 'whereArgs'),
            orderBy: any(named: 'orderBy'),
          )).thenAnswer((_) async => mockMaps);

      final result = await investasiOp.ambilInvestasiByIdInvestor('investor-001');

      expect(result.length, equals(2));
      expect(result.every((i) => i.idInvestor == 'investor-001'), isTrue);
    });

    test('harus mengembalikan list kosong jika investor tidak punya investasi',
        () async {
      when(() => mockDatabase.query(
            any(),
            where: any(named: 'where'),
            whereArgs: any(named: 'whereArgs'),
            orderBy: any(named: 'orderBy'),
          )).thenAnswer((_) async => []);

      final result = await investasiOp.ambilInvestasiByIdInvestor('investor-999');

      expect(result, isEmpty);
    });
  });

  // ============================================================
  // TEST PERBARUI INVESTASI
  // ============================================================

  group('InvestasiOpSqlite - perbaruiInvestasi', () {
    test('harus berhasil memperbarui investasi', () async {
      when(
        () => mockBaseOp.update(
          any(),
          any(),
          any(),
          dariServer: any(named: 'dariServer'),
        ),
      ).thenAnswer((_) async => Future.value());

      await expectLater(
        investasiOp.perbaruiInvestasi(dummyInvestasi),
        completes,
      );

      verify(
        () => mockBaseOp.update(
          any(),
          any(),
          any(),
          dariServer: any(named: 'dariServer'),
        ),
      ).called(1);
    });

    test('harus melempar error jika gagal memperbarui', () async {
      when(
        () => mockBaseOp.update(
          any(),
          any(),
          any(),
          dariServer: any(named: 'dariServer'),
        ),
      ).thenThrow(Exception('Update error'));

      await expectLater(
        investasiOp.perbaruiInvestasi(dummyInvestasi),
        throwsA(isA<Exception>()),
      );
    });
  });

  // ============================================================
  // TEST SOFT DELETE INVESTASI
  // ============================================================

  group('InvestasiOpSqlite - softDeleteInvestasi', () {
    test('harus berhasil melakukan soft delete investasi', () async {
      when(
        () => mockBaseOp.softDelete(
          any(),
          any(),
          dariServer: any(named: 'dariServer'),
        ),
      ).thenAnswer((_) async => Future.value());

      await expectLater(
        investasiOp.softDeleteInvestasi('inv-001'),
        completes,
      );

      verify(
        () => mockBaseOp.softDelete(
          any(),
          any(),
          dariServer: any(named: 'dariServer'),
        ),
      ).called(1);
    });
  });

  // ============================================================
  // TEST DIVIDEN
  // ============================================================

  group('InvestasiOpSqlite - operasi dividen', () {
    test('tambahDividen - harus berhasil menambahkan dividen', () async {
      when(
        () => mockBaseOp.sisipkan(
          any(),
          any(),
          dariServer: any(named: 'dariServer'),
        ),
      ).thenAnswer((_) async => Future.value());

      await expectLater(
        investasiOp.tambahDividen(dummyDividen),
        completes,
      );
    });

    test('ambilSemuaDividen - harus mengembalikan list dividen', () async {
      final mockMaps = [
        {
          'id': 'div-001',
          'id_investasi': 'inv-001',
          'id_investor': 'investor-001',
          'jumlah_dividen': 500000,
          'tanggal_pembagian': 1707907200000,
          'sudah_dibayar': 0,
          'is_deleted': 0,
        },
      ];

      when(() => mockDatabase.query(
            any(),
            where: any(named: 'where'),
            orderBy: any(named: 'orderBy'),
          )).thenAnswer((_) async => mockMaps);

      final result = await investasiOp.ambilSemuaDividen();

      expect(result, isNotEmpty);
      expect(result.first.id, equals('div-001'));
    });

    test('ambilDividenByIdInvestor - harus mengembalikan dividen untuk investor',
        () async {
      final mockMaps = [
        {
          'id': 'div-001',
          'id_investasi': 'inv-001',
          'id_investor': 'investor-001',
          'jumlah_dividen': 500000,
          'tanggal_pembagian': 1707907200000,
          'sudah_dibayar': 0,
          'is_deleted': 0,
        },
      ];

      when(() => mockDatabase.query(
            any(),
            where: any(named: 'where'),
            whereArgs: any(named: 'whereArgs'),
            orderBy: any(named: 'orderBy'),
          )).thenAnswer((_) async => mockMaps);

      final result = await investasiOp.ambilDividenByIdInvestor('investor-001');

      expect(result, isNotEmpty);
    });

    test('tandaiDividenDibayar - harus berhasil menandai dividen dibayar',
        () async {
      when(
        () => mockBaseOp.update(
          any(),
          any(),
          any(),
          dariServer: any(named: 'dariServer'),
        ),
      ).thenAnswer((_) async => Future.value());

      await expectLater(
        investasiOp.tandaiDividenDibayar('div-001'),
        completes,
      );
    });

    test('softDeleteDividen - harus berhasil soft delete dividen', () async {
      when(
        () => mockBaseOp.softDelete(
          any(),
          any(),
          dariServer: any(named: 'dariServer'),
        ),
      ).thenAnswer((_) async => Future.value());

      await expectLater(
        investasiOp.softDeleteDividen('div-001'),
        completes,
      );
    });
  });

  // ============================================================
  // TEST BATCH OPERATION
  // ============================================================

  group('InvestasiOpSqlite - batch operation', () {
    test('sisipkanAtauPerbaruiBatch - harus berhasil untuk list tidak kosong',
        () async {
      when(
        () => mockBaseOp.sisipkanAtauPerbaruiBatch(
          any(),
          any(),
          dariServer: any(named: 'dariServer'),
        ),
      ).thenAnswer((_) async => Future.value());

      await expectLater(
        investasiOp.sisipkanAtauPerbaruiBatch([dummyInvestasi]),
        completes,
      );
    });

    test('sisipkanAtauPerbaruiBatch - harus skip untuk list kosong', () async {
      await expectLater(
        investasiOp.sisipkanAtauPerbaruiBatch([]),
        completes,
      );

      verifyNever(
        () => mockBaseOp.sisipkanAtauPerbaruiBatch(
          any(),
          any(),
          dariServer: any(named: 'dariServer'),
        ),
      );
    });

    test('sisipkanAtauPerbaruiBatchDividen - harus berhasil untuk list tidak kosong',
        () async {
      when(
        () => mockBaseOp.sisipkanAtauPerbaruiBatch(
          any(),
          any(),
          dariServer: any(named: 'dariServer'),
        ),
      ).thenAnswer((_) async => Future.value());

      await expectLater(
        investasiOp.sisipkanAtauPerbaruiBatchDividen([dummyDividen]),
        completes,
      );
    });

    test('sisipkanAtauPerbaruiBatchDividen - harus skip untuk list kosong',
        () async {
      await expectLater(
        investasiOp.sisipkanAtauPerbaruiBatchDividen([]),
        completes,
      );

      verifyNever(
        () => mockBaseOp.sisipkanAtauPerbaruiBatch(
          any(),
          any(),
          dariServer: any(named: 'dariServer'),
        ),
      );
    });
  });
}