// path: test/shared/operasi/transaksi_operasi_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/model/transaksi_model.dart';
import 'package:wifi/shared/operasi/operasi_dasar.dart';
import 'package:wifi/shared/operasi/transaksi_operasi.dart';

// --- Mock untuk dependensi database ---
class MockDatabaseHelper extends Mock implements DatabaseHelper {}

class MockDatabase extends Mock implements Database {}

class MockTransaction extends Mock implements Transaction {}

class MockBatch extends Mock implements Batch {}

// --- Fake OperasiDasar untuk pengujian ---
/// Implementasi palsu [OperasiDasar] yang mengeksekusi callback transaksi
/// tanpa benar‑benar membuka transaksi database asli.
class FakeOperasiDasar implements OperasiDasar {
  /// Transaction mock yang akan diberikan ke callback.
  Transaction? mockTransaction;

  /// Jika tidak null, exception ini akan dilempar saat [jalankanOperasiKompleks] dipanggil.
  Exception? exceptionToThrow;

  @override
  Future<T> jalankanOperasiKompleks<T>(
    final Future<T> Function(Transaction txn) callback, {
    final bool dariServer = false,
  }) async {
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
    return await callback(mockTransaction!);
  }

  @override
  Future<void> sisipkan(
    final String tabel,
    final Map<String, dynamic> data, {
    final bool dariServer = false,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> perbarui(
    final String tabel,
    final Map<String, dynamic> data,
    final String id, {
    final bool dariServer = false,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> hapus(
    final String tabel,
    final String id, {
    final bool dariServer = false,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> sisipkanAtauPerbaruiBatch(
    final String tabel,
    final List<Map<String, dynamic>> data, {
    final bool dariServer = false,
  }) =>
      throw UnimplementedError();
}

void main() {
  late MockDatabaseHelper mockDbHelper;
  late MockDatabase mockDatabase;
  late MockTransaction mockTransaction;
  late FakeOperasiDasar fakeOperasiDasar;
  late TransaksiOperasi transaksiOperasi;

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    mockDatabase = MockDatabase();
    mockTransaction = MockTransaction();
    fakeOperasiDasar = FakeOperasiDasar();

    // Hubungkan mockTransaction ke fakeOperasiDasar
    fakeOperasiDasar.mockTransaction = mockTransaction;

    when(() => mockDbHelper.database)
        .thenAnswer((final _) async => mockDatabase);

    // Setup default mockTransaction
    when(
      () => mockTransaction.insert(
        any(),
        any(),
        conflictAlgorithm: any(named: 'conflictAlgorithm'),
      ),
    ).thenAnswer((final _) async => 1);
    when(
      () => mockTransaction.update(
        any(),
        any(),
        where: any(named: 'where'),
        whereArgs: any(named: 'whereArgs'),
      ),
    ).thenAnswer((final _) async => 1);
    when(
      () => mockTransaction.query(
        any(),
        where: any(named: 'where'),
        whereArgs: any(named: 'whereArgs'),
      ),
    ).thenAnswer((final _) async => <Map<String, dynamic>>[]);
    when(() => mockTransaction.rawQuery(any(), any())).thenAnswer(
      (final _) async => [
        {'total': 0.0},
      ],
    );

    transaksiOperasi = TransaksiOperasi(
      dbHelper: mockDbHelper,
      operasiDasar: fakeOperasiDasar,
    );
  });

  // Helper dummy
  TransactionModel dummyTransaksi(
    final String id, {
    final TipeTransaksiEnum tipe = TipeTransaksiEnum.pemasukan,
  }) =>
      TransactionModel(
        id: id,
        idPelanggan: 'pel-$id',
        idDompet: 'dompet-$id',
        jumlah: 10000,
        tanggal: DateTime(2024, 8, 17),
        diperbarui: DateTime(2024),
        keterangan: 'Transaksi $id',
        tipe: tipe,
        idKategori: 'kat-$id',
        idDompetTujuan:
            tipe == TipeTransaksiEnum.transfer ? 'dompet-tujuan-$id' : null,
      );

  Map<String, dynamic> dummyMap(final TransactionModel t) => t.toSqlite();

  // ============ tambahTransaksi ============
  group('tambahTransaksi', () {
    test('berhasil menambah transaksi dan update saldo dompet', () async {
      final transaksi = dummyTransaksi('t1');
      final id = await transaksiOperasi.tambahTransaksi(transaksi);
      expect(id, 1);
      verify(
        () => mockTransaction.insert(
          'transaksi',
          any(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        ),
      ).called(1);
      verify(() => mockTransaction.rawQuery(any(), any())).called(1);
    });

    test('melempar error jika operasi gagal', () {
      // Atur fakeOperasiDasar agar melempar exception
      fakeOperasiDasar.exceptionToThrow = Exception('DB Error');
      expect(
        () => transaksiOperasi.tambahTransaksi(dummyTransaksi('e')),
        throwsException,
      );
      // Kembalikan ke normal
      fakeOperasiDasar.exceptionToThrow = null;
    });
  });

  // ============ ambilSemuaTransaksi ============
  group('ambilSemuaTransaksi', () {
    test('mengembalikan daftar transaksi aktif', () async {
      final maps = [
        dummyMap(dummyTransaksi('1')),
        dummyMap(dummyTransaksi('2')),
      ];
      when(
        () => mockDatabase.query(
          'transaksi',
          where: 'isDeleted = ?',
          whereArgs: [0],
          orderBy: 'tanggal DESC',
        ),
      ).thenAnswer((final _) async => maps);
      final result = await transaksiOperasi.ambilSemuaTransaksi();
      expect(result.length, 2);
      expect(result[0].id, '1');
    });

    test('mengembalikan list kosong jika error', () async {
      when(
        () => mockDatabase.query(
          any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'),
          orderBy: any(named: 'orderBy'),
        ),
      ).thenThrow(Exception('DB Error'));
      final result = await transaksiOperasi.ambilSemuaTransaksi();
      expect(result, isEmpty);
    });
  });

  // ============ getTransaksiById ============
  group('getTransaksiById', () {
    test('mengembalikan transaksi jika ditemukan', () async {
      when(
        () => mockDatabase.query(
          'transaksi',
          where: 'id = ?',
          whereArgs: ['123'],
          limit: 1,
        ),
      ).thenAnswer((final _) async => [dummyMap(dummyTransaksi('123'))]);
      final result = await transaksiOperasi.getTransaksiById('123');
      expect(result, isNotNull);
      expect(result!.id, '123');
    });

    test('mengembalikan null jika tidak ditemukan', () async {
      when(
        () => mockDatabase.query(
          'transaksi',
          where: 'id = ?',
          whereArgs: ['x'],
          limit: 1,
        ),
      ).thenAnswer((final _) async => []);
      final result = await transaksiOperasi.getTransaksiById('x');
      expect(result, isNull);
    });

    test('mengembalikan null saat error', () async {
      when(
        () => mockDatabase.query(
          any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(Exception('Error'));
      final result = await transaksiOperasi.getTransaksiById('err');
      expect(result, isNull);
    });
  });

  // ============ ambilTransaksiByPelangganId ============
  group('ambilTransaksiByPelangganId', () {
    test('mengembalikan transaksi milik pelanggan', () async {
      when(
        () => mockDatabase.query(
          'transaksi',
          where: 'id_pelanggan = ? AND isDeleted = ?',
          whereArgs: ['p1', 0],
          orderBy: 'tanggal DESC',
        ),
      ).thenAnswer((final _) async => [dummyMap(dummyTransaksi('t1'))]);
      final result = await transaksiOperasi.ambilTransaksiByPelangganId('p1');
      expect(result.length, 1);
      expect(result.first.idPelanggan, 'pel-t1');
    });

    test('mengembalikan list kosong saat error', () async {
      when(
        () => mockDatabase.query(
          any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'),
          orderBy: any(named: 'orderBy'),
        ),
      ).thenThrow(Exception('Error'));
      final result = await transaksiOperasi.ambilTransaksiByPelangganId('p1');
      expect(result, isEmpty);
    });
  });

  // ============ ambilTransaksiByDompetId ============
  group('ambilTransaksiByDompetId', () {
    test('mengembalikan transaksi terkait dompet', () async {
      when(
        () => mockDatabase.query(
          'transaksi',
          where: '(id_dompet = ? OR id_dompet_tujuan = ?) AND isDeleted = ?',
          whereArgs: ['d1', 'd1', 0],
          orderBy: 'tanggal DESC',
        ),
      ).thenAnswer((final _) async => [dummyMap(dummyTransaksi('t1'))]);
      final result = await transaksiOperasi.ambilTransaksiByDompetId('d1');
      expect(result.length, 1);
    });
  });

  // ============ getTransaksiByAktivasiPaket ============
  group('getTransaksiByAktivasiPaket', () {
    test('mengembalikan transaksi aktivasi paket', () async {
      when(
        () => mockDatabase.query(
          'transaksi',
          where: 'aktivasi_paket = ? AND isDeleted = ?',
          whereArgs: [1, 0],
          orderBy: 'tanggal DESC',
        ),
      ).thenAnswer((final _) async => [dummyMap(dummyTransaksi('t1'))]);
      final result = await transaksiOperasi.getTransaksiByAktivasiPaket();
      expect(result.length, 1);
    });
  });

  // ============ updateTransaksi ============
  group('updateTransaksi', () {
    test('berhasil update dan perbarui saldo dompet', () async {
      final transaksiBaru = dummyTransaksi('t1');
      when(
        () => mockTransaction.query(
          'transaksi',
          where: 'id = ?',
          whereArgs: ['t1'],
        ),
      ).thenAnswer((final _) async => [dummyMap(dummyTransaksi('t1'))]);

      await transaksiOperasi.updateTransaksi('t1', transaksiBaru);

      verify(
        () => mockTransaction.update(
          'transaksi',
          any(),
          where: 'id = ?',
          whereArgs: ['t1'],
        ),
      ).called(1);
      verify(() => mockTransaction.rawQuery(any(), any()))
          .called(greaterThanOrEqualTo(1));
    });

    test('tidak update jika id tidak ditemukan', () async {
      when(
        () => mockTransaction.query(
          'transaksi',
          where: 'id = ?',
          whereArgs: ['x'],
        ),
      ).thenAnswer((final _) async => []);
      await transaksiOperasi.updateTransaksi('x', dummyTransaksi('x'));
      verifyNever(
        () => mockTransaction.update(
          any(),
          any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'),
        ),
      );
    });
  });

  // ============ arsipkanTransaksi ============
  group('arsipkanTransaksi', () {
    test('berhasil mengarsipkan dan update saldo', () async {
      final transaksiLama =
          dummyTransaksi('t1', tipe: TipeTransaksiEnum.transfer);
      when(
        () => mockTransaction.query(
          'transaksi',
          where: 'id = ?',
          whereArgs: ['t1'],
        ),
      ).thenAnswer((final _) async => [dummyMap(transaksiLama)]);

      await transaksiOperasi.arsipkanTransaksi('t1');

      verify(
        () => mockTransaction.update(
          'transaksi',
          any(that: containsPair('isDeleted', 1)),
          where: 'id = ?',
          whereArgs: ['t1'],
        ),
      ).called(1);
      verify(() => mockTransaction.rawQuery(any(), any())).called(2);
    });

    test('tidak melakukan apa-apa jika id tidak ditemukan', () async {
      when(
        () => mockTransaction.query(
          'transaksi',
          where: 'id = ?',
          whereArgs: ['x'],
        ),
      ).thenAnswer((final _) async => []);
      await transaksiOperasi.arsipkanTransaksi('x');
      verifyNever(
        () => mockTransaction.update(
          any(),
          any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'),
        ),
      );
    });
  });

  // ============ getTotalPemasukan ============
  group('getTotalPemasukan', () {
    test('mengembalikan total pemasukan', () async {
      when(
        () => mockDatabase.rawQuery(
          "SELECT SUM(jumlah) as jumlah FROM transaksi WHERE tipe = 'pemasukan' AND isDeleted = 0",
        ),
      ).thenAnswer(
        (final _) async => [
          {'jumlah': 50000.0},
        ],
      );
      final total = await transaksiOperasi.getTotalPemasukan();
      expect(total, 50000.0);
    });

    test('mengembalikan 0.0 jika error', () async {
      when(() => mockDatabase.rawQuery(any())).thenThrow(Exception('Error'));
      final total = await transaksiOperasi.getTotalPemasukan();
      expect(total, 0.0);
    });
  });

  // ============ getTotalPengeluaran ============
  group('getTotalPengeluaran', () {
    test('mengembalikan total pengeluaran', () async {
      when(
        () => mockDatabase.rawQuery(
          "SELECT SUM(jumlah) as jumlah FROM transaksi WHERE tipe = 'pengeluaran' AND isDeleted = 0",
        ),
      ).thenAnswer(
        (final _) async => [
          {'jumlah': 20000.0},
        ],
      );
      final total = await transaksiOperasi.getTotalPengeluaran();
      expect(total, 20000.0);
    });
  });

  // ============ getNetTotal ============
  group('getNetTotal', () {
    test('menghitung net total dengan benar', () async {
      when(
        () => mockDatabase.rawQuery(
          "SELECT SUM(jumlah) as jumlah FROM transaksi WHERE tipe = 'pemasukan' AND isDeleted = 0",
        ),
      ).thenAnswer(
        (final _) async => [
          {'jumlah': 50000.0},
        ],
      );
      when(
        () => mockDatabase.rawQuery(
          "SELECT SUM(jumlah) as jumlah FROM transaksi WHERE tipe = 'pengeluaran' AND isDeleted = 0",
        ),
      ).thenAnswer(
        (final _) async => [
          {'jumlah': 20000.0},
        ],
      );
      final net = await transaksiOperasi.getNetTotal();
      expect(net, 30000.0);
    });
  });

  // ============ Poin ============
  group('getPoinYangDihasilkan', () {
    test('mengembalikan total poin dihasilkan', () async {
      when(
        () => mockDatabase.rawQuery(
          'SELECT SUM(poin_yang_dihasilkan) as total FROM transaksi WHERE id_pelanggan = ? AND isDeleted = 0',
          ['p1'],
        ),
      ).thenAnswer(
        (final _) async => [
          {'total': 100},
        ],
      );
      final poin = await transaksiOperasi.getPoinYangDihasilkan('p1');
      expect(poin, 100);
    });

    test('mengembalikan 0 saat error', () async {
      when(() => mockDatabase.rawQuery(any(), any()))
          .thenThrow(Exception('Error'));
      final poin = await transaksiOperasi.getPoinYangDihasilkan('p1');
      expect(poin, 0);
    });
  });

  group('getPoinYangDigunakan', () {
    test('mengembalikan total poin digunakan', () async {
      when(
        () => mockDatabase.rawQuery(
          'SELECT SUM(poin_yang_digunakan) as total FROM transaksi WHERE id_pelanggan = ? AND isDeleted = 0',
          ['p1'],
        ),
      ).thenAnswer(
        (final _) async => [
          {'total': 50},
        ],
      );
      final poin = await transaksiOperasi.getPoinYangDigunakan('p1');
      expect(poin, 50);
    });
  });

  group('getTotalPoin', () {
    test('menghitung saldo poin', () async {
      when(
        () => mockDatabase.rawQuery(
          'SELECT SUM(poin_yang_dihasilkan) as total FROM transaksi WHERE id_pelanggan = ? AND isDeleted = 0',
          any(),
        ),
      ).thenAnswer(
        (final _) async => [
          {'total': 100},
        ],
      );
      when(
        () => mockDatabase.rawQuery(
          'SELECT SUM(poin_yang_digunakan) as total FROM transaksi WHERE id_pelanggan = ? AND isDeleted = 0',
          any(),
        ),
      ).thenAnswer(
        (final _) async => [
          {'total': 30},
        ],
      );
      final saldo = await transaksiOperasi.getTotalPoin('p1');
      expect(saldo, 70);
    });
  });

  // ============ sisipkanAtauPerbaruiBatch ============
  group('sisipkanAtauPerbaruiBatch', () {
    test('batch insert dan update saldo', () async {
      final items = [
        dummyTransaksi('1'),
        dummyTransaksi('2', tipe: TipeTransaksiEnum.transfer),
      ];
      final mockBatch = MockBatch();
      when(() => mockTransaction.batch()).thenReturn(mockBatch);
      when(
        () => mockBatch.insert(
          any(),
          any(),
          conflictAlgorithm: any(named: 'conflictAlgorithm'),
        ),
      ).thenAnswer((final _) {});
      when(() => mockBatch.commit(noResult: any(named: 'noResult')))
          .thenAnswer((final _) async => []);

      await transaksiOperasi.sisipkanAtauPerbaruiBatch(items);
      verify(
        () => mockBatch.insert(
          'transaksi',
          any(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        ),
      ).called(2);
      verify(() => mockTransaction.rawQuery(any(), any()))
          .called(greaterThanOrEqualTo(1));
    });
  });

  // ============ getTransaksiByIds ============
  group('getTransaksiByIds', () {
    test('mengembalikan transaksi sesuai id', () async {
      when(
        () => mockDatabase.query(
          'transaksi',
          where: 'id IN (?,?)',
          whereArgs: ['1', '2'],
        ),
      ).thenAnswer(
        (final _) async =>
            [dummyMap(dummyTransaksi('1')), dummyMap(dummyTransaksi('2'))],
      );
      final result = await transaksiOperasi.getTransaksiByIds(['1', '2']);
      expect(result.length, 2);
    });

    test('mengembalikan list kosong jika ids kosong', () async {
      final result = await transaksiOperasi.getTransaksiByIds([]);
      expect(result, isEmpty);
    });
  });
}
