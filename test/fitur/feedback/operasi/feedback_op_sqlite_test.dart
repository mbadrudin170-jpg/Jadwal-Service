// path: test/fitur/feedback/operasi/feedback_op_sqlite_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/feedback/model/feedback_model.dart';
import 'package:wifi/fitur/feedback/operasi/feedback_op_sqlite.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_op_sqlite.dart';

// Mocks
class MockSqliteDatabase extends Mock implements SqliteDatabase {}

class MockBaseOpSqlite extends Mock implements BaseOpSqlite {}

class MockDatabase extends Mock implements Database {}

class MockTransaction extends Mock implements Transaction {}

void main() {
  late FeedbackOpSqlite feedbackOpSqlite;
  late MockSqliteDatabase mockSqliteDb;
  late MockBaseOpSqlite mockBaseOpSqlite;
  late MockDatabase mockDb;

  setUp(() {
    mockSqliteDb = MockSqliteDatabase();
    mockBaseOpSqlite = MockBaseOpSqlite();
    mockDb = MockDatabase();
    feedbackOpSqlite = FeedbackOpSqlite(
      sqliteDb: mockSqliteDb,
      baseOpSqlite: mockBaseOpSqlite,
    );

    when(() => mockSqliteDb.database).thenAnswer((_) async => mockDb);
  });

  const namaTabel = NamaTabel.feedback;
  final feedback = FeedbackModel(
    id: 'fb1',
    pesan: 'Ini pesan',
    userId: 'user1',
    tanggal: DateTime.now(),
  );

  group('Operasi Tulis (Delegasi ke BaseOpSqlite)', () {
    test('01. add harus memanggil baseOpSqlite.sisipkan', () async {
      when(() => mockBaseOpSqlite.sisipkan(any(), any())).thenAnswer((_) async {});

      await feedbackOpSqlite.add(feedback);

      verify(() => mockBaseOpSqlite.sisipkan(
            namaTabel,
            any(that: isA<Map<String, dynamic>>()),
          )).called(1);
    });

    test('02. delete harus memanggil baseOpSqlite.delete', () async {
      when(() => mockBaseOpSqlite.delete(any(), any())).thenAnswer((_) async {});

      await feedbackOpSqlite.delete('fb1');

      verify(() => mockBaseOpSqlite.delete(namaTabel, 'fb1')).called(1);
    });

    test('03. softDelete harus memanggil baseOpSqlite.softDelete', () async {
      when(() => mockBaseOpSqlite.softDelete(any(), any())).thenAnswer((_) async {});

      await feedbackOpSqlite.softDelete('fb1');

      verify(() => mockBaseOpSqlite.softDelete(namaTabel, 'fb1')).called(1);
    });

    test(
        '04. sisipkanAtauPerbaruiBatch harus memanggil baseOpSqlite.sisipkanAtauPerbaruiBatch',
        () async {
      when(() => mockBaseOpSqlite.sisipkanAtauPerbaruiBatch(any(), any()))
          .thenAnswer((_) async {});

      await feedbackOpSqlite.sisipkanAtauPerbaruiBatch([feedback]);

      verify(() => mockBaseOpSqlite.sisipkanAtauPerbaruiBatch(
            namaTabel,
            any(that: isA<List<Map<String, dynamic>>>()),
          )).called(1);
    });

    test(
        '05. sisipkanAtauPerbaruiBatch tidak melakukan apa-apa jika list kosong',
        () async {
      await feedbackOpSqlite.sisipkanAtauPerbaruiBatch([]);

      verifyNever(() => mockBaseOpSqlite.sisipkanAtauPerbaruiBatch(any(), any()));
    });

    test(
        '06. deleteAll harus menjalankan delete dalam runComplexOperation',
        () async {
      final mockTxn = MockTransaction();
      when(() => mockBaseOpSqlite.runComplexOperation<dynamic>(any()))
          .thenAnswer((invocation) async {
        final action = invocation.positionalArguments[0]
            as Future<dynamic> Function(Transaction);
        await action(mockTxn);
      });
      when(() => mockTxn.delete(namaTabel)).thenAnswer((_) async => 1);

      await feedbackOpSqlite.deleteAll();

      verify(() => mockTxn.delete(namaTabel)).called(1);
    });
  });

  group('Operasi Baca (Query Langsung)', () {
    final feedbackMap = feedback.toSqlite();

    test('07. getAll harus mengembalikan list FeedbackModel', () async {
      when(() => mockDb.query(namaTabel, orderBy: any(named: 'orderBy')))
          .thenAnswer((_) async => [feedbackMap]);

      final result = await feedbackOpSqlite.getAll();

      expect(result, isA<List<FeedbackModel>>());
      expect(result.length, 1);
      expect(result.first.id, feedback.id);
    });

    test(
        '08. getAllActiveFeedback harus query dengan where isDeleted = 0',
        () async {
      when(() => mockDb.query(
            namaTabel,
            where: any(named: 'where'),
            orderBy: any(named: 'orderBy'),
          )).thenAnswer((_) async => [feedbackMap]);

      await feedbackOpSqlite.getAllActiveFeedback();

      verify(() => mockDb.query(
            namaTabel,
            where: '${NamaKolom.dihapus} = 0',
            orderBy: '${NamaKolom.tanggal} DESC',
          )).called(1);
    });

    test('09. getById harus mengembalikan FeedbackModel jika ditemukan', () async {
      when(() => mockDb.query(
            any(),
            where: any(named: 'where'),
            whereArgs: any(named: 'whereArgs'),
          )).thenAnswer((_) async => [feedbackMap]);

      final result = await feedbackOpSqlite.getById('fb1');

      expect(result.id, 'fb1');
      verify(() =>
              mockDb.query(namaTabel, where: 'id = ?', whereArgs: ['fb1']))
          .called(1);
    });

    test('10. getById harus melempar Exception jika tidak ditemukan', () async {
      when(() => mockDb.query(
            any(),
            where: any(named: 'where'),
            whereArgs: any(named: 'whereArgs'),
          )).thenAnswer((_) async => []); // List kosong

      expect(
        () => feedbackOpSqlite.getById('tidak-ada'),
        throwsA(isA<Exception>()),
      );
    });

    test('11. getChanges harus query dengan where diperbaruiPada > ?', () async {
      final lastSync = DateTime(2023);
      when(() => mockDb.query(
            any(),
            where: any(named: 'where'),
            whereArgs: any(named: 'whereArgs'),
          )).thenAnswer((_) async => [feedbackMap]);

      await feedbackOpSqlite.getChanges(lastSync);

      verify(() => mockDb.query(
            namaTabel,
            where: '${NamaKolom.diperbaruiPada} > ?',
            whereArgs: [lastSync.millisecondsSinceEpoch],
          )).called(1);
    });

    test('12. getByIds harus query dengan klausa IN (...)', () async {
      final ids = ['fb1', 'fb2'];
      when(() => mockDb.query(
            any(),
            where: any(named: 'where'),
            whereArgs: any(named: 'whereArgs'),
          )).thenAnswer((_) async => [feedbackMap]);

      await feedbackOpSqlite.getByIds(ids);

      verify(() => mockDb.query(
            namaTabel,
            where: 'id IN (?,?)',
            whereArgs: ids,
          )).called(1);
    });

    test('13. getByIds harus mengembalikan list kosong jika input kosong', () async {
      final result = await feedbackOpSqlite.getByIds([]);
      expect(result, isEmpty);
      verifyNever(() => mockDb.query(
            any(),
            where: any(named: 'where'),
            whereArgs: any(named: 'whereArgs'),
          ));
    });
  });
}
