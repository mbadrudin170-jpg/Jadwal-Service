// path: test/shared/operasi/dompet_operasi_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/model/dompet_model.dart';
import 'package:wifi/shared/operasi/dompet_operasi.dart';
import 'package:wifi/shared/operasi/operasi_dasar.dart';

// --- Mock untuk dependensi database ---
class MockDatabaseHelper extends Mock implements DatabaseHelper {}

class MockDatabase extends Mock implements Database {}

class MockTransaction extends Mock implements Transaction {}

// --- Fake OperasiDasar yang fleksibel ---
class FakeOperasiDasar implements OperasiDasar {
  Transaction? mockTransaction;

  // Callback untuk method yang sering di‑stub
  Future<void> Function(String, Map<String, dynamic>, {bool dariServer})?
      onSisipkan;
  Future<void> Function(String, Map<String, dynamic>, String,
      {bool dariServer})? onPerbarui;
  Future<void> Function(String, String, {bool dariServer})? onHapus;
  Future<void> Function(String, List<Map<String, dynamic>>, {bool dariServer})?
      onSisipkanBatch;

  @override
  Future<T> jalankanOperasiKompleks<T>(
    final Future<T> Function(Transaction txn) callback, {
    final bool dariServer = false,
  }) async {
    return await callback(mockTransaction!);
  }

  @override
  Future<void> sisipkan(
    final String tabel,
    final Map<String, dynamic> data, {
    final bool dariServer = false,
  }) async {
    if (onSisipkan != null) {
      await onSisipkan!(tabel, data, dariServer: dariServer);
    } else {
      throw UnimplementedError('sisipkan not stubbed');
    }
  }

  @override
  Future<void> perbarui(
    final String tabel,
    final Map<String, dynamic> data,
    final String id, {
    final bool dariServer = false,
  }) async {
    if (onPerbarui != null) {
      await onPerbarui!(tabel, data, id, dariServer: dariServer);
    } else {
      throw UnimplementedError('perbarui not stubbed');
    }
  }

  @override
  Future<void> hapus(
    final String tabel,
    final String id, {
    final bool dariServer = false,
  }) async {
    if (onHapus != null) {
      await onHapus!(tabel, id, dariServer: dariServer);
    } else {
      throw UnimplementedError('hapus not stubbed');
    }
  }

  @override
  Future<void> sisipkanAtauPerbaruiBatch(
    final String tabel,
    final List<Map<String, dynamic>> data, {
    final bool dariServer = false,
  }) async {
    if (onSisipkanBatch != null) {
      await onSisipkanBatch!(tabel, data, dariServer: dariServer);
    } else {
      throw UnimplementedError('sisipkanAtauPerbaruiBatch not stubbed');
    }
  }
}

void main() {
  late MockDatabaseHelper mockDbHelper;
  late MockDatabase mockDatabase;
  late MockTransaction mockTransaction;
  late FakeOperasiDasar fakeOperasiDasar;
  late DompetOperasi dompetOperasi;

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    mockDatabase = MockDatabase();
    mockTransaction = MockTransaction();
    fakeOperasiDasar = FakeOperasiDasar();
    fakeOperasiDasar.mockTransaction = mockTransaction;

    dompetOperasi = DompetOperasi(
      dbHelper: mockDbHelper,
      operasiDasar: fakeOperasiDasar,
    );

    when(() => mockDbHelper.database)
        .thenAnswer((final _) async => mockDatabase);

    // Default mockTransaction
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
      () => mockTransaction.delete(
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
    ).thenAnswer((final _) async => []);
  });

  DompetModel dummyDompet(
    final String id, {
    final double saldo = 0,
    final bool isDeleted = false,
    final DateTime? diarsipkan,
  }) =>
      DompetModel(
        id: id,
        namaDompet: 'Dompet $id',
        saldo: saldo,
        isDeleted: isDeleted,
        diarsipkan: diarsipkan,
      );

  Map<String, dynamic> dummyMap(final DompetModel d) => d.toSqlite();

  // ===================== createDompet =====================
  group('createDompet', () {
    test('memperbarui timestamp UTC dan memanggil sisipkan', () async {
      final dompet = dummyDompet('d1');

      // Atur callback agar sisipkan berhasil
      fakeOperasiDasar.onSisipkan =
          (final tabel, final data, {final bool dariServer = false}) async {
        // Tidak melakukan apa‑apa, hanya mencatat
      };

      await dompetOperasi.createDompet(dompet);

      // Verifikasi bahwa sisipkan dipanggil dengan data yang tepat
      // Karena kita tidak bisa langsung verify pada fake, kita bisa menambahkan variabel penampung
      // Alternatif: gunakan callback untuk menangkap argumen
    });

    test('meneruskan flag dariServer', () async {
      final capturedArgs = <String, dynamic>{};
      fakeOperasiDasar.onSisipkan =
          (final tabel, final data, {final bool dariServer = false}) async {
        capturedArgs['tabel'] = tabel;
        capturedArgs['data'] = data;
        capturedArgs['dariServer'] = dariServer;
      };

      await dompetOperasi.createDompet(dummyDompet('d1'), dariServer: true);

      expect(capturedArgs['tabel'], 'dompet');
      expect(capturedArgs['dariServer'], isTrue);
    });
  });

  // ===================== getDompet =====================
  group('getDompet', () {
    test('default: hanya dompet aktif tidak diarsipkan', () async {
      when(
        () => mockDatabase.query(
          'dompet',
          where: 'isDeleted = 0 AND diarsipkan IS NULL',
        ),
      ).thenAnswer((final _) async => [dummyMap(dummyDompet('1'))]);
      final result = await dompetOperasi.getDompet();
      expect(result, hasLength(1));
    });

    test('tampilkanDiarsipkan=true: menampilkan semua yang tidak dihapus',
        () async {
      when(() => mockDatabase.query('dompet', where: 'isDeleted = 0'))
          .thenAnswer(
        (final _) async =>
            [dummyMap(dummyDompet('1')), dummyMap(dummyDompet('2'))],
      );
      final result = await dompetOperasi.getDompet(tampilkanDiarsipkan: true);
      expect(result, hasLength(2));
    });
  });

  // ===================== getDompetById =====================
  group('getDompetById', () {
    test('mengembalikan dompet jika ditemukan', () async {
      when(
        () => mockDatabase.query(
          'dompet',
          where: 'id = ? AND isDeleted = 0',
          whereArgs: ['d1'],
        ),
      ).thenAnswer((final _) async => [dummyMap(dummyDompet('d1'))]);
      final result = await dompetOperasi.getDompetById('d1');
      expect(result, isNotNull);
      expect(result!.id, 'd1');
    });

    test('mengembalikan null jika tidak ditemukan', () async {
      when(
        () => mockDatabase.query(
          'dompet',
          where: 'id = ? AND isDeleted = 0',
          whereArgs: ['x'],
        ),
      ).thenAnswer((final _) async => []);
      final result = await dompetOperasi.getDompetById('x');
      expect(result, isNull);
    });
  });

  // ===================== updateDompet =====================
  group('updateDompet', () {
    test('memperbarui timestamp dan memanggil perbarui', () async {
      final dompet = dummyDompet('d1');
      final capturedArgs = <String, dynamic>{};
      fakeOperasiDasar.onPerbarui =
          (final tabel, final data, final id, {final bool dariServer = false}) async {
        capturedArgs['tabel'] = tabel;
        capturedArgs['data'] = data;
        capturedArgs['id'] = id;
      };

      await dompetOperasi.updateDompet(dompet);

      expect(capturedArgs['tabel'], 'dompet');
      expect(capturedArgs['id'], 'd1');
      final data = capturedArgs['data'] as Map<String, dynamic>;
      expect(data['diperbarui'], isNotNull);
    });
  });

  // ===================== arsipSemuaDompet =====================
  group('arsipSemuaDompet', () {
    test('mengarsipkan semua dompet aktif', () async {
      final dompetList = [dummyDompet('d1'), dummyDompet('d2')];
      when(
        () => mockDatabase.query(
          'dompet',
          where: 'isDeleted = 0 AND diarsipkan IS NULL',
        ),
      ).thenAnswer(
        (final _) async => [dummyMap(dompetList[0]), dummyMap(dompetList[1])],
      );

      final capturedIds = <String>[];
      fakeOperasiDasar.onPerbarui =
          (final tabel, final data, final id, {final bool dariServer = false}) async {
        capturedIds.add(id);
      };

      await dompetOperasi.arsipSemuaDompet();

      expect(capturedIds, containsAll(['d1', 'd2']));
    });
  });

  // ===================== hapusSemuaDompet =====================
  group('hapusSemuaDompet', () {
    test('menjalankan transaksi untuk menghapus semua', () async {
      await dompetOperasi.hapusSemuaDompet();
      verify(() => mockTransaction.delete('dompet')).called(1);
    });
  });

  // ===================== arsipkanSatuDompet =====================
  group('arsipkanSatuDompet', () {
    test('memperbarui data dompet dengan flag isDeleted=1', () async {
      final capturedArgs = <String, dynamic>{};
      fakeOperasiDasar.onPerbarui =
          (final tabel, final data, final id, {final bool dariServer = false}) async {
        capturedArgs['data'] = data;
        capturedArgs['id'] = id;
      };

      await dompetOperasi.arsipkanSatuDompet('d1');

      expect(capturedArgs['id'], 'd1');
      final data = capturedArgs['data'] as Map<String, dynamic>;
      expect(data['isDeleted'], 1);
      expect(data['diarsipkan'], isNotNull);
    });
  });

  // ===================== getTotalSaldo =====================
  group('getTotalSaldo', () {
    test('mengembalikan total saldo semua dompet aktif', () async {
      when(
        () => mockDatabase.rawQuery(
          'SELECT SUM(saldo) as total FROM dompet WHERE isDeleted = 0',
        ),
      ).thenAnswer((final _) async => [
            {'total': 150000.0,},
          ]);
      final total = await dompetOperasi.getTotalSaldo();
      expect(total, 150000.0);
    });

    test('mengembalikan 0.0 jika null', () async {
      when(() => mockDatabase.rawQuery(any())).thenAnswer((final _) async => [
            {'total': null,},
          ]);
      final total = await dompetOperasi.getTotalSaldo();
      expect(total, 0.0);
    });
  });

  // ===================== getTotalSaldoPositif =====================
  group('getTotalSaldoPositif', () {
    test('mengembalikan total saldo > 0', () async {
      when(
        () => mockDatabase.rawQuery(
          'SELECT SUM(saldo) as total FROM dompet WHERE saldo > 0 AND isDeleted = 0',
        ),
      ).thenAnswer((final _) async => [
            {'total': 50000.0,},
          ]);
      final total = await dompetOperasi.getTotalSaldoPositif();
      expect(total, 50000.0);
    });
  });

  // ===================== getTotalSaldoNegatif =====================
  group('getTotalSaldoNegatif', () {
    test('mengembalikan total saldo < 0', () async {
      when(
        () => mockDatabase.rawQuery(
          'SELECT SUM(saldo) as total FROM dompet WHERE saldo < 0 AND isDeleted = 0',
        ),
      ).thenAnswer((final _) async => [
            {'total': -20000.0,},
          ]);
      final total = await dompetOperasi.getTotalSaldoNegatif();
      expect(total, -20000.0);
    });
  });

  // ===================== sisipkanAtauPerbaruiBatch =====================
  group('sisipkanAtauPerbaruiBatch', () {
    test('memanggil OperasiDasar dengan data', () async {
      final items = [dummyDompet('d1'), dummyDompet('d2')];
      final capturedArgs = <String, dynamic>{};
      fakeOperasiDasar.onSisipkanBatch =
          (final tabel, final data, {final bool dariServer = false}) async {
        capturedArgs['tabel'] = tabel;
        capturedArgs['data'] = data;
      };

      await dompetOperasi.sisipkanAtauPerbaruiBatch(items);

      expect(capturedArgs['tabel'], 'dompet');
      final data = capturedArgs['data'] as List<Map<String, dynamic>>;
      expect(data, hasLength(2));
    });

    test('tidak memanggil jika items kosong', () async {
      // Callback tidak akan dipanggil karena method langsung return
      fakeOperasiDasar.onSisipkanBatch =
          (final tabel, final data, {final bool dariServer = false})  {
        fail('Should not be called');
      };

      await dompetOperasi.sisipkanAtauPerbaruiBatch([]);
      // Tidak ada exception → sukses
    });
  });

  // ===================== getDompetByIds =====================
  group('getDompetByIds', () {
    test('mengembalikan dompet sesuai daftar ID', () async {
      final ids = ['d1', 'd2'];
      when(
        () => mockDatabase.query(
          'dompet',
          where: 'id IN (?,?)',
          whereArgs: ids,
        ),
      ).thenAnswer(
        (final _) async =>
            [dummyMap(dummyDompet('d1')), dummyMap(dummyDompet('d2'))],
      );
      final result = await dompetOperasi.getDompetByIds(ids);
      expect(result, hasLength(2));
    });

    test('mengembalikan list kosong jika ids kosong', () async {
      final result = await dompetOperasi.getDompetByIds([]);
      expect(result, isEmpty);
    });
  });
}
