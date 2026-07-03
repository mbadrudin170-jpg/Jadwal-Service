// path: test/fitur/dompet/operasi/dompet_op_sqlite_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/dompet/model/dompet_model.dart';
import 'package:wifi/fitur/dompet/operasi/dompet_op_sqlite.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_op_sqlite.dart';

import 'dompet_op_sqlite_test.mocks.dart';

@GenerateMocks([SqliteDatabase, BaseOpSqlite, Database])
void main() {
  late MockSqliteDatabase mockSqliteDatabase;
  late MockBaseOpSqlite mockBaseOpSqlite;
  late MockDatabase mockDatabase;
  late DompetOpSqlite dompetOpSqlite;

  setUp(() {
    mockSqliteDatabase = MockSqliteDatabase();
    mockBaseOpSqlite = MockBaseOpSqlite();
    mockDatabase = MockDatabase();
    dompetOpSqlite = DompetOpSqlite(
      sqliteDb: mockSqliteDatabase,
      baseOpSqlite: mockBaseOpSqlite,
    );
    when(mockSqliteDatabase.database).thenAnswer((_) async => mockDatabase);
  });

  final dompetModel = DompetModel(
    id: '1',
    nama: 'Dompet Utama',
    saldo: 100000,
    diperbaruiPada: DateTime.now(),
  );

  group('DompetOpSqlite', () {
    test('01. tambahDompet harus memanggil _baseOperation.sisipkan', () async {
      when(
        mockBaseOpSqlite.sisipkan(any, any),
      ).thenAnswer((_) async => Future.value());

      await dompetOpSqlite.tambahDompet(dompetModel);

      verify(mockBaseOpSqlite.sisipkan(NamaTabel.dompet, any)).called(1);
    });

    test('02. ambilSemua harus mengembalikan list dompet', () async {
      final maps = [dompetModel.toSqlite()];
      when(
        mockDatabase.query(NamaTabel.dompet, where: anyNamed('where')),
      ).thenAnswer((_) async => maps);

      final result = await dompetOpSqlite.ambilSemua();

      expect(result, isA<List<DompetModel>>());
      expect(result.length, 1);
      expect(result.first.id, dompetModel.id);
    });

    test('03. ambilBerdasarkanId harus mengembalikan dompet', () async {
      final maps = [dompetModel.toSqlite()];
      when(
        mockDatabase.query(
          NamaTabel.dompet,
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
        ),
      ).thenAnswer((_) async => maps);

      final result = await dompetOpSqlite.ambilBerdasarkanId('1');

      expect(result, isA<DompetModel>());
      expect(result?.id, dompetModel.id);
    });

    test('04. updateDompet harus memanggil _baseOperation.update', () async {
      when(
        mockBaseOpSqlite.update(any, any, any),
      ).thenAnswer((_) async => Future.value());

      await dompetOpSqlite.updateDompet(dompetModel);

      verify(
        mockBaseOpSqlite.update(NamaTabel.dompet, any, dompetModel.id),
      ).called(1);
    });

    test('05. softDelete harus memanggil _baseOperation.softDelete', () async {
      when(
        mockBaseOpSqlite.softDelete(any, any),
      ).thenAnswer((_) async => Future.value());

      await dompetOpSqlite.softDelete('1');

      verify(mockBaseOpSqlite.softDelete(NamaTabel.dompet, '1')).called(1);
    });

    test(
      '06. softDeleteAll harus memanggil _baseOperation.softDeleteAll',
      () async {
        when(
          mockBaseOpSqlite.softDeleteAll(
            any,
            dariServer: anyNamed('dariServer'),
          ),
        ).thenAnswer((_) async => 1);

        await dompetOpSqlite.softDeleteAll();

        verify(mockBaseOpSqlite.softDeleteAll(NamaTabel.dompet)).called(1);
      },
    );

    test('07. ambilTotalsaldo harus mengembalikan total saldo', () async {
      when(mockDatabase.rawQuery(any)).thenAnswer(
        (_) async => [
          {'total': 150000},
        ],
      );

      final result = await dompetOpSqlite.ambilTotalsaldo();

      expect(result, 150000);
    });

    test(
      '08. ambilSaldoPositif harus mengembalikan total saldo positif',
      () async {
        when(mockDatabase.rawQuery(any)).thenAnswer(
          (_) async => [
            {'total': 200000},
          ],
        );

        final result = await dompetOpSqlite.ambilSaldoPositif();

        expect(result, 200000);
      },
    );

    test(
      '09. ambilSaldoNegatif harus mengembalikan total saldo negatif',
      () async {
        when(mockDatabase.rawQuery(any)).thenAnswer(
          (_) async => [
            {'total': -50000},
          ],
        );

        final result = await dompetOpSqlite.ambilSaldoNegatif();

        expect(result, -50000);
      },
    );

    test(
      '10. sisipkanAtauPerbaruiBatch harus memanggil _baseOperation.sisipkanAtauPerbaruiBatch',
      () async {
        final listDompet = <DompetModel>[
          dompetModel,
          dompetModel.copyWith(id: '2'),
        ];

        when(
          mockBaseOpSqlite.sisipkanAtauPerbaruiBatch(
            any,
            any,
            dariServer: anyNamed('dariServer'),
          ),
        ).thenAnswer((_) async => Future.value());

        await dompetOpSqlite.sisipkanAtauPerbaruiBatch(listDompet);

        verify(
          mockBaseOpSqlite.sisipkanAtauPerbaruiBatch(NamaTabel.dompet, any),
        ).called(1);
      },
    );
  });
}
