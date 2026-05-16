// path: test/shared/operasi/operasi_dasar_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/operasi/base_operation.dart';
import 'package:wifi/shared/operasi/upload_status_operasi.dart';

import 'operasi_dasar_test.mocks.dart';

@GenerateMocks([DatabaseHelper, Transaction, StatusUnggahOperasi])
void main() {
  late MockDatabaseHelper mockDbHelper;
  late FakeDatabase fakeDatabase;
  late MockTransaction mockTransaction;
  late MockStatusUnggahOperasi mockStatusUnggah;
  late OperasiDasar operasiDasar;

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    mockTransaction = MockTransaction();
    mockStatusUnggah = MockStatusUnggahOperasi();

    // FakeDatabase untuk mensimulasikan transaksi
    fakeDatabase = FakeDatabase(mockTransaction);

    operasiDasar = OperasiDasar(
      dbHelper: mockDbHelper,
      statusUnggahOperasi: mockStatusUnggah,
    );

    when(mockDbHelper.database).thenAnswer((final _) async => fakeDatabase);
  });

  group('sisipkan', () {
    test('memasukkan data dan menandai perlu unggah jika dariServer false',
        () async {
      final data = {'nama': 'Test'};
      when(
        mockTransaction.insert(
          any,
          any,
          conflictAlgorithm: anyNamed('conflictAlgorithm'),
        ),
      ).thenAnswer((final _) async => 1);
      when(
        mockStatusUnggah.setPerluUnggah(
          any,
          transaction: anyNamed('transaction'),
        ),
      ).thenAnswer((final _) async {});

      await operasiDasar.sisipkan('tabel_test', data);

      verify(
        mockTransaction.insert(
          'tabel_test',
          data,
          conflictAlgorithm: ConflictAlgorithm.replace,
        ),
      ).called(1);
      verify(
        mockStatusUnggah.setPerluUnggah(
          true,
          transaction: mockTransaction,
        ),
      ).called(1);
    });

    test('tidak menandai perlu unggah jika dariServer true', () async {
      final data = {'nama': 'Test'};
      when(
        mockTransaction.insert(
          any,
          any,
          conflictAlgorithm: anyNamed('conflictAlgorithm'),
        ),
      ).thenAnswer((final _) async => 1);

      await operasiDasar.sisipkan('tabel_test', data, dariServer: true);

      verify(
        mockTransaction.insert(
          'tabel_test',
          data,
          conflictAlgorithm: ConflictAlgorithm.replace,
        ),
      ).called(1);
      verifyNever(
        mockStatusUnggah.setPerluUnggah(
          true,
          transaction: mockTransaction,
        ),
      );
    });
  });

  group('perbarui', () {
    final dataUpdate = {'nama': 'Updated'};
    const id = '123';

    test('berhasil update dan tandai perlu unggah jika lokal', () async {
      when(
        mockTransaction.update(
          any,
          any,
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
        ),
      ).thenAnswer((final _) async => 1);
      when(
        mockStatusUnggah.setPerluUnggah(
          any,
          transaction: anyNamed('transaction'),
        ),
      ).thenAnswer((final _) async {});

      await operasiDasar.perbarui('tabel', dataUpdate, id);

      verify(
        mockTransaction.update(
          'tabel',
          dataUpdate,
          where: 'id = ?',
          whereArgs: [id],
        ),
      ).called(1);
      verify(
        mockStatusUnggah.setPerluUnggah(
          true,
          transaction: mockTransaction,
        ),
      ).called(1);
    });

    test('tidak menandai perlu unggah jika dariServer true', () async {
      when(
        mockTransaction.update(
          any,
          any,
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
        ),
      ).thenAnswer((final _) async => 1);

      await operasiDasar.perbarui('tabel', dataUpdate, id, dariServer: true);

      verify(
        mockTransaction.update(
          'tabel',
          dataUpdate,
          where: 'id = ?',
          whereArgs: [id],
        ),
      ).called(1);
      verifyNever(
        mockStatusUnggah.setPerluUnggah(
          true,
          transaction: mockTransaction,
        ),
      );
    });
  });

  group('hapus', () {
    const id = '123';

    test('berhasil hapus dan tandai perlu unggah jika lokal', () async {
      when(
        mockTransaction.delete(
          any,
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
        ),
      ).thenAnswer((final _) async => 1);
      when(
        mockStatusUnggah.setPerluUnggah(
          any,
          transaction: anyNamed('transaction'),
        ),
      ).thenAnswer((final _) async {});

      await operasiDasar.hapus('tabel', id);

      verify(
        mockTransaction.delete(
          'tabel',
          where: 'id = ?',
          whereArgs: [id],
        ),
      ).called(1);
      verify(
        mockStatusUnggah.setPerluUnggah(
          true,
          transaction: mockTransaction,
        ),
      ).called(1);
    });

    test('tidak menandai perlu unggah jika dariServer true', () async {
      when(
        mockTransaction.delete(
          any,
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
        ),
      ).thenAnswer((final _) async => 1);

      await operasiDasar.hapus('tabel', id, dariServer: true);

      verify(
        mockTransaction.delete(
          'tabel',
          where: 'id = ?',
          whereArgs: [id],
        ),
      ).called(1);
      verifyNever(
        mockStatusUnggah.setPerluUnggah(
          true,
          transaction: mockTransaction,
        ),
      );
    });
  });
}

// --- Fake Database ---
/// Implementasi palsu dari [Database] yang hanya menjalankan callback transaksi
/// dengan [mockTransaction] yang telah disediakan, tanpa membuka koneksi database asli.
class FakeDatabase implements Database {
  final Transaction mockTransaction;

  FakeDatabase(this.mockTransaction);

  @override
  Future<T> transaction<T>(
    final Future<T> Function(Transaction txn) action, {
    final bool? exclusive,
  }) async {
    return await action(mockTransaction);
  }

  // Method lain tidak digunakan, lempar UnimplementedError.
  @override
  dynamic noSuchMethod(final Invocation invocation) =>
      super.noSuchMethod(invocation);
}
