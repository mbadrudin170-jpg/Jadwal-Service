// path: test/shared/operasi/pesanan_operasi_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/model/pesanan_model.dart';
import 'package:wifi/shared/operasi/base_operation.dart';
import 'package:wifi/shared/operasi/order_operation.dart';

import 'pesanan_operasi_test.mocks.dart';

@GenerateMocks([DatabaseHelper, OperasiDasar, Database])
void main() {
  late PesananOperasi pesananOperasi;
  late MockDatabaseHelper mockDbHelper;
  late MockOperasiDasar mockOperasiDasar;
  late MockDatabase mockDatabase;

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    mockOperasiDasar = MockOperasiDasar();
    mockDatabase = MockDatabase();
    pesananOperasi = PesananOperasi(
      dbHelper: mockDbHelper,
      operasiDasar: mockOperasiDasar,
    );

    when(mockDbHelper.database).thenAnswer((final _) async => mockDatabase);
  });

  // Data dummy yang sesuai dengan model PesananModel
  final tPesanan = PesananModel(
    id: '1',
    idPelanggan: 'p1',
    idPaket: 'pkt1',
    tanggal: DateTime.now(),
    status: 'pending',
  );

  // Map yang merepresentasikan data SQLite (sesuai toSqlite())
  final tPesananMap = {
    'id': '1',
    'id_pelanggan': 'p1',
    'id_paket': 'pkt1',
    'tanggal': DateTime.now().millisecondsSinceEpoch,
    'status': 'pending',
    'diperbarui': DateTime.now().millisecondsSinceEpoch,
    'isDeleted': 0,
    'diarsipkan': null,
  };

  group('simpanPesanan', () {
    test('should call sisipkan on OperasiDasar', () async {
      when(mockOperasiDasar.sisipkan(any, any))
          .thenAnswer((final _) async => 1);

      await pesananOperasi.simpanPesanan(tPesanan);

      verify(mockOperasiDasar.sisipkan('pesanan', any)).called(1);
    });
  });

  group('ambilSemuaPesanan', () {
    test('should return a list of PesananModel', () async {
      when(mockDatabase.query(any, orderBy: anyNamed('orderBy')))
          .thenAnswer((final _) async => [tPesananMap]);

      final result = await pesananOperasi.ambilSemuaPesanan();

      expect(result, isA<List<PesananModel>>());
      expect(result.length, 1);
    });
  });

  group('ambilPesananByStatus', () {
    test('should return a list of PesananModel with matching status', () async {
      when(
        mockDatabase.query(
          any,
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
          orderBy: anyNamed('orderBy'),
        ),
      ).thenAnswer((final _) async => [tPesananMap]);

      final result = await pesananOperasi.ambilPesananByStatus('pending');

      expect(result, isA<List<PesananModel>>());
      expect(result.first.status, 'pending');
    });
  });

  group('updateStatusPesanan', () {
    test('should call perbarui on OperasiDasar', () async {
      when(
        mockDatabase.query(
          any,
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
        ),
      ).thenAnswer((final _) async => [tPesananMap]);
      when(mockOperasiDasar.perbarui(any, any, any))
          .thenAnswer((final _) async => 1);

      await pesananOperasi.updateStatusPesanan('1', 'selesai');

      verify(mockOperasiDasar.perbarui('pesanan', any, '1')).called(1);
    });

    test('should not call perbarui if pesanan not found', () async {
      when(
        mockDatabase.query(
          any,
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
        ),
      ).thenAnswer((final _) async => []);

      await pesananOperasi.updateStatusPesanan('1', 'selesai');

      verifyNever(mockOperasiDasar.perbarui(any, any, any));
    });
  });

  group('hapusPesanan', () {
    test('should call hapus on OperasiDasar', () async {
      when(mockOperasiDasar.hapus(any, any)).thenAnswer((final _) async => 1);

      await pesananOperasi.hapusPesanan('1');

      verify(mockOperasiDasar.hapus('pesanan', '1')).called(1);
    });
  });

  group('sisipkanAtauPerbaruiBatch', () {
    test('should call sisipkanAtauPerbaruiBatch on OperasiDasar', () async {
      when(mockOperasiDasar.sisipkanAtauPerbaruiBatch(any, any))
          .thenAnswer((final _) async => {});

      await pesananOperasi.sisipkanAtauPerbaruiBatch([tPesanan]);

      verify(mockOperasiDasar.sisipkanAtauPerbaruiBatch('pesanan', any))
          .called(1);
    });

    test('should not call if items list is empty', () async {
      await pesananOperasi.sisipkanAtauPerbaruiBatch([]);

      verifyNever(mockOperasiDasar.sisipkanAtauPerbaruiBatch(any, any));
    });
  });

  group('getPesananByIds', () {
    test('should return list of PesananModel for given ids', () async {
      when(
        mockDatabase.query(
          any,
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
        ),
      ).thenAnswer((final _) async => [tPesananMap]);

      final result = await pesananOperasi.getPesananByIds(['1']);

      expect(result.length, 1);
      expect(result.first.id, '1');
    });

    test('should return empty list if ids list is empty', () async {
      final result = await pesananOperasi.getPesananByIds([]);

      expect(result.isEmpty, isTrue);
      verifyNever(mockDatabase.query(any));
    });
  });
}
