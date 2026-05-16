// path: test/shared/operasi/pelanggan_operasi_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/model/pelanggan_model.dart';
import 'package:wifi/shared/operasi/base_operation.dart';
import 'package:wifi/shared/operasi/customer_operation.dart';

import 'pelanggan_operasi_test.mocks.dart';

@GenerateMocks([DatabaseHelper, OperasiDasar, Database])
void main() {
  late MockDatabaseHelper mockDbHelper;
  late MockOperasiDasar mockOperasiDasar;
  late MockDatabase mockDatabase;
  late PelangganOperasi pelangganOperasi;

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    mockOperasiDasar = MockOperasiDasar();
    mockDatabase = MockDatabase();
    pelangganOperasi = PelangganOperasi(
      dbHelper: mockDbHelper,
      operasiDasar: mockOperasiDasar,
    );

    when(mockDbHelper.database).thenAnswer((final _) async => mockDatabase);
  });

  final tPelanggan = PelangganModel(
    id: '1',
    nama: 'John Doe',
    telepon: '081234567890',
    alamat: 'Jl. Pahlawan No. 1',
    password: 'password123',
  );

  final tPelangganMap = {
    'id': '1',
    'nama': 'John Doe',
    'telepon': '081234567890',
    'alamat': 'Jl. Pahlawan No. 1',
    'password': 'password123',
    'isDeleted': 0,
    'diarsipkan': null,
    'diperbarui': DateTime.now().millisecondsSinceEpoch,
  };

  group('createPelanggan', () {
    test('should call sisipkan on operasiDasar with correct data', () async {
      when(mockOperasiDasar.sisipkan(any, any))
          .thenAnswer((final _) async => 1);

      await pelangganOperasi.createPelanggan(tPelanggan);

      verify(
        mockOperasiDasar.sisipkan(
          'pelanggan',
          any,
        ),
      ).called(1);
    });
  });

  group('getPelangganById', () {
    test('should return PelangganModel when data is found', () async {
      when(mockDatabase.query(any,
              where: anyNamed('where'), whereArgs: anyNamed('whereArgs'),),)
          .thenAnswer((final _) async => [tPelangganMap]);

      final result = await pelangganOperasi.getPelangganById('1');

      expect(result, isA<PelangganModel>());
      expect(result!.id, '1');
    });

    test('should return null when data is not found', () async {
      when(mockDatabase.query(any,
              where: anyNamed('where'), whereArgs: anyNamed('whereArgs'),),)
          .thenAnswer((final _) async => []);

      final result = await pelangganOperasi.getPelangganById('1');

      expect(result, isNull);
    });
  });

  group('getPelanggan', () {
    test('should return a list of active PelangganModel', () async {
      when(
        mockDatabase.query(
          any,
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
        ),
      ).thenAnswer((final _) async => [tPelangganMap]);

      final result = await pelangganOperasi.getPelanggan();

      expect(result, isA<List<PelangganModel>>());
      expect(result.length, 1);
      expect(result.first.isDeleted, false);
      expect(result.first.diarsipkan, isNull);
    });
  });

  group('getAllPelanggan', () {
    test('should return all PelangganModel', () async {
      when(mockDatabase.query(any))
          .thenAnswer((final _) async => [tPelangganMap]);

      final result = await pelangganOperasi.getAllPelanggan();

      expect(result, isA<List<PelangganModel>>());
      expect(result.length, 1);
    });
  });

  group('updatePelanggan', () {
    test('should call perbarui on operasiDasar with correct data', () async {
      when(mockOperasiDasar.perbarui(any, any, any))
          .thenAnswer((final _) async => 1);

      await pelangganOperasi.updatePelanggan(tPelanggan);

      verify(
        mockOperasiDasar.perbarui(
          'pelanggan',
          any,
          '1',
        ),
      ).called(1);
    });
  });

  group('deletePelanggan', () {
    test('should call perbarui for soft delete', () async {
      when(mockOperasiDasar.perbarui(any, any, any))
          .thenAnswer((final _) async => 1);

      await pelangganOperasi.deletePelanggan('1');

      verify(
        mockOperasiDasar.perbarui(
          'pelanggan',
          any,
          '1',
        ),
      ).called(1);
    });

    test('should call hapus for hard delete', () async {
      when(mockOperasiDasar.hapus(any, any)).thenAnswer((final _) async => 1);

      await pelangganOperasi.deletePelanggan('1', softDelete: false);

      verify(mockOperasiDasar.hapus('pelanggan', '1')).called(1);
    });
  });
}
