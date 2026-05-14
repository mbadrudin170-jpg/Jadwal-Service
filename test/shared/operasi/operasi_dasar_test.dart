// path: test/shared/operasi/operasi_dasar_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/operasi/operasi_dasar.dart';
import 'package:wifi/shared/operasi/status_unggah_operasi.dart';

// --- Mock classes ---
class MockDatabaseHelper extends Mock implements DatabaseHelper {}

class MockDatabase extends Mock implements Database {}

class MockTransaction extends Mock implements Transaction {}

class MockStatusUnggahOperasi extends Mock implements StatusUnggahOperasi {}

void main() {
  late MockDatabaseHelper mockDbHelper;
  late MockDatabase mockDatabase;
  late MockTransaction mockTransaction;
  late MockStatusUnggahOperasi mockStatusUnggah;
  late OperasiDasar operasiDasar;

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    mockDatabase = MockDatabase();
    mockTransaction = MockTransaction();
    mockStatusUnggah = MockStatusUnggahOperasi();

    // Injeksi mock ke OperasiDasar
    operasiDasar = OperasiDasar(
      dbHelper: mockDbHelper,
      statusUnggahOperasi: mockStatusUnggah,
    );

    // Setup dasar: dbHelper mengembalikan database
    when(() => mockDbHelper.database).thenAnswer((_) async => mockDatabase);

    // Setup transaksi: jalankan callback dan berikan mockTransaction
    when(() => mockDatabase.transaction(any())).thenAnswer((invocation) async {
      final callback = invocation.positionalArguments[0] as Future<dynamic>
          Function(Transaction);
      return await callback(mockTransaction);
    });

    // Setup default untuk mockTransaction methods (insert, update, delete)
    when(() => mockTransaction.insert(any(), any(),
            conflictAlgorithm: any(named: 'conflictAlgorithm')))
        .thenAnswer((_) async => 1); // return rowId dummy
    when(() => mockTransaction.update(any(), any(),
            where: any(named: 'where'), whereArgs: any(named: 'whereArgs')))
        .thenAnswer((_) async => 1); // rows affected
    when(() => mockTransaction.delete(any(),
        where: any(named: 'where'),
        whereArgs: any(named: 'whereArgs'))).thenAnswer((_) async => 1);

    // mock statusUnggah.setPerluUnggah
    when(() => mockStatusUnggah.setPerluUnggah(true,
        transaction: any(named: 'transaction'))).thenAnswer((_) async {});
  });

  // ---------- sisipkan ----------
  group('sisipkan', () {
    test('memasukkan data dan menandai perlu unggah jika dariServer false',
        () async {
      final data = {'nama': 'Test'};
      await operasiDasar.sisipkan('tabel_test', data, dariServer: false);

      // Verifikasi insert dipanggil
      verify(() => mockTransaction.insert('tabel_test', data,
          conflictAlgorithm: ConflictAlgorithm.replace)).called(1);
      // Verifikasi status unggah diset
      verify(() => mockStatusUnggah.setPerluUnggah(true,
          transaction: mockTransaction)).called(1);
    });

    test('tidak menandai perlu unggah jika dariServer true', () async {
      await operasiDasar.sisipkan('tabel_test', {}, dariServer: true);
      verifyNever(() => mockStatusUnggah.setPerluUnggah(true,
          transaction: any(named: 'transaction')));
    });

    test('melempar error jika insert gagal', () async {
      when(() => mockTransaction.insert(any(), any(),
              conflictAlgorithm: any(named: 'conflictAlgorithm')))
          .thenThrow(DatabaseException('Gagal insert'));

      expect(
        () => operasiDasar.sisipkan('tabel', {}),
        throwsA(isA<DatabaseException>()),
      );
    });
  });

  // ---------- perbarui ----------
  group('perbarui', () {
    final dataUpdate = {'nama': 'Updated'};
    const id = '123';

    test('berhasil update dan tandai perlu unggah jika lokal', () async {
      await operasiDasar.perbarui('tabel', dataUpdate, id, dariServer: false);

      verify(() => mockTransaction.update(
            'tabel',
            dataUpdate,
            where: 'id = ?',
            whereArgs: [id],
          )).called(1);
      verify(() => mockSta