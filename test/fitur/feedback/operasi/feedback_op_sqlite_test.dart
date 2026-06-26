// path: test/fitur/feedback/operasi/feedback_op_sqlite_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/feedback/model/feedback_model.dart';
import 'package:wifi/fitur/feedback/operasi/feedback_op_sqlite.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_op_sqlite.dart';

import 'feedback_op_sqlite_test.mocks.dart';

@GenerateMocks([SqliteDatabase, BaseOpSqlite, Database, Transaction])
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

    when(mockSqliteDb.database).thenAnswer((_) async => mockDb);
    // Atur default stub untuk runComplexOperation
    when(
      mockBaseOpSqlite.runComplexOperation<void>(
        any,
      ),
    ).thenAnswer((_) async {});
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
      when(
        mockBaseOpSqlite.sisipkan(namaTabel, any),
      ).thenAnswer((_) async => 1);

      await feedbackOpSqlite.tambahFeedback(feedback);

      verify(
        mockBaseOpSqlite.sisipkan(
          namaTabel,
          argThat(isA<Map<String, dynamic>>()),
        ),
      ).called(1);
    });

    test('02. delete harus memanggil baseOpSqlite.delete', () async {
      when(
        mockBaseOpSqlite.delete(namaTabel, 'fb1'),
      ).thenAnswer((_) async => 1);

      await feedbackOpSqlite.delete('fb1');

      verify(
        mockBaseOpSqlite.delete(namaTabel, 'fb1'),
      ).called(1);
    });

    test('03. softDelete harus memanggil baseOpSqlite.softDelete', () async {
      when(
        mockBaseOpSqlite.softDelete(namaTabel, 'fb1'),
      ).thenAnswer((_) async => 1);

      await feedbackOpSqlite.softDelete('fb1');

      verify(
        mockBaseOpSqlite.softDelete(namaTabel, 'fb1'),
      ).called(1);
    });

    test(
      '04. sisipkanAtauPerbaruiBanyak harus memanggil baseOpSqlite.sisipkanAtauPerbaruiBanyak',
      () async {
        when(
          mockBaseOpSqlite.sisipkanAtauPerbaruiBanyak(
            namaTabel,
            any,
          ),
        ).thenAnswer((_) async => []);

        await feedbackOpSqlite.sisipkanAtauPerbaruiBanyak([feedback]);

        verify(
          mockBaseOpSqlite.sisipkanAtauPerbaruiBanyak(
            namaTabel,
            argThat(isA<List<Map<String, dynamic>>>()),
          ),
        ).called(1);
      },
    );

    test(
      '05. sisipkanAtauPerbaruiBanyak tidak melakukan apa-apa jika list kosong',
      () async {
        await feedbackOpSqlite.sisipkanAtauPerbaruiBanyak([]);

        verifyNever(
          mockBaseOpSqlite.sisipkanAtauPerbaruiBanyak(
            any,
            any,
          ),
        );
      },
    );

    test(
      '06. deleteAll harus menjalankan delete dalam runComplexOperation',
      () async {
        final mockTxn = MockTransaction();
        // Konfigurasi ulang mock untuk mengembalikan hasil dari action
        when(
          mockBaseOpSqlite.runComplexOperation<int>(
            any,
          ),
        ).thenAnswer((invocation) async {
          final action =
              invocation.positionalArguments[0] as Future<int> Function(Transaction);
          return action(mockTxn);
        });

        when(mockTxn.delete(namaTabel)).thenAnswer((_) async => 5);

        await feedbackOpSqlite.deleteAll();

        // Verifikasi bahwa runComplexOperation dipanggil
        verify(
          mockBaseOpSqlite.runComplexOperation<int>(any),
        ).called(1);
      },
    );
  });

  group('Operasi Baca (Query Langsung)', () {
    final feedbackMap = feedback.toSqlite();

    test('07. getAll harus mengembalikan list FeedbackModel', () async {
      when(
        mockDb.query(namaTabel, orderBy: anyNamed('orderBy')),
      ).thenAnswer((_) async => [feedbackMap]);

      final result = await feedbackOpSqlite.ambilSemua();

      expect(result, isA<List<FeedbackModel>>());
      expect(result.length, 1);
      expect(result.first.id, feedback.id);
    });

    test(
      '08. getAllActiveFeedback harus query dengan where isDeleted = 0',
      () async {
        when(
          mockDb.query(
            namaTabel,
            where: anyNamed('where'),
            orderBy: anyNamed('orderBy'),
          ),
        ).thenAnswer((_) async => [feedbackMap]);

        await feedbackOpSqlite.ambilSemuaFeedback();

        verify(
          mockDb.query(
            namaTabel,
            where: '${NamaKolom.dihapus} = 0',
            orderBy: '${NamaKolom.tanggal} DESC',
          ),
        ).called(1);
      },
    );

    test(
      '09. getById harus mengembalikan FeedbackModel jika ditemukan',
      () async {
        when(
          mockDb.query(
            any,
            where: anyNamed('where'),
            whereArgs: anyNamed('whereArgs'),
          ),
        ).thenAnswer((_) async => [feedbackMap]);

        final result = await feedbackOpSqlite.ambilBerdasarkanId('fb1');

        expect(result?.id, 'fb1');
        verify(
          mockDb.query(namaTabel, where: 'id = ?', whereArgs: ['fb1']),
        ).called(1);
      },
    );

    test('10. getById harus mengembalikan null jika tidak ditemukan', () async {
      when(
        mockDb.query(
          any,
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
        ),
      ).thenAnswer((_) async => []); // List kosong

      final result = await feedbackOpSqlite.ambilBerdasarkanId('tidak-ada');

      expect(result, isNull);
    });

    test(
      '11. getChanges harus query dengan where diperbaruiPada > ?',
      () async {
        final lastSync = DateTime(2023);
        when(
          mockDb.query(
            any,
            where: anyNamed('where'),
            whereArgs: anyNamed('whereArgs'),
          ),
        ).thenAnswer((_) async => [feedbackMap]);

        await feedbackOpSqlite.ambilPerubahan(lastSync);

        verify(
          mockDb.query(
            namaTabel,
            where: '${NamaKolom.diperbaruiPada} > ?',
            whereArgs: [lastSync.millisecondsSinceEpoch],
          ),
        ).called(1);
      },
    );

    test('12. getByIds harus query dengan klausa IN (...)', () async {
      final ids = ['fb1', 'fb2'];
      when(
        mockDb.query(
          any,
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
        ),
      ).thenAnswer((_) async => [feedbackMap]);

      await feedbackOpSqlite.ambilBerdasarkanIds(ids);

      verify(
        mockDb.query(namaTabel, where: 'id IN (?,?)', whereArgs: ids),
      ).called(1);
    });

    test(
      '13. getByIds harus mengembalikan list kosong jika input kosong',
      () async {
        final result = await feedbackOpSqlite.ambilBerdasarkanIds([]);
        expect(result, isEmpty);
        verifyNever(
          mockDb.query(
            any,
            where: anyNamed('where'),
            whereArgs: anyNamed('whereArgs'),
          ),
        );
      },
    );

    test(
      '14. softDeleteAll harus memanggil baseOpSqlite.softDeleteAll',
      () async {
        when(
          mockBaseOpSqlite.softDeleteAll(namaTabel),
        ).thenAnswer((_) async => 5);

        final count = await feedbackOpSqlite.softDeleteAll();

        expect(count, 5);
        verify(
          mockBaseOpSqlite.softDeleteAll(namaTabel),
        ).called(1);
      },
    );
  });
}
