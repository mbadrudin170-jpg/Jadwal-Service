// path: test/shared/operasi/poin/sqlite_points_data_source_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/fitur/paket/enum/tipe_durasi_paket.dart';
import 'package:wifi/fitur/transaksi/enum/tipe_transaksi.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/poin/operasi/sqlite_points_data_source.dart';
import 'package:wifi/fitur/paket/operasi/paket_op_sqlite.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_sqlite.dart';

import 'sqlite_points_data_source_test.mocks.dart';

@GenerateMocks([TransaksiOpsqlite, PaketOpSqlite])
void main() {
  late MockTransactionOperation mockTransactionOperation;
  late MockPackageOperation mockPackageOperation;
  late SQLitePointsDataSource dataSource;

  setUp(() {
    mockTransactionOperation = MockTransactionOperation();
    mockPackageOperation = MockPackageOperation();
    dataSource = SQLitePointsDataSource(
      transaksiOpSqlite: mockTransactionOperation,
      paketOpSqlite: mockPackageOperation,
    );
  });

  group('SQLitePointsDataSource', () {
    const customerId = 'test_customer_id';

    test(
        '1. getTotalPoints harus mengembalikan total poin dari operasi transaksi',
        () async {
      when(mockTransactionOperation.getTotalPoints(customerId))
          .thenAnswer((_) async => 100);

      final result = await dataSource.ambilTotalPoin(customerId);

      expect(result, 100);
      verify(mockTransactionOperation.getTotalPoints(customerId));
      verifyNoMoreInteractions(mockTransactionOperation);
    });

    test(
        '2. getPublicPackages harus mengembalikan paket publik dari operasi paket',
        () async {
      final packages = [
        PaketModel(
          id: '1',
          nama: 'Test Package',
          harga: 0,
          durasi: 0,
          tipe: TipeDurasiPaket.hours,
        )
      ];
      when(mockPackageOperation.getByIsPublic())
          .thenAnswer((_) async => packages);

      final result = await dataSource.getPublicPackages();

      expect(result, packages);
      verify(mockPackageOperation.getByIsPublic());
      verifyNoMoreInteractions(mockPackageOperation);
    });

    test(
        '3. getPointsTransactions harus mengembalikan transaksi dengan poin dari operasi transaksi',
        () async {
      final transactions = [
        TransaksiModel(
          id: '1',
          poinDidapat: 10,
          tanggal: DateTime.now(),
          deskripsi: '',
          jumlah: 0,
          tipe: TipeTransaksi.income,
          idDompet: '',
          idKategori: '',
        ),
        TransaksiModel(
          id: '2',
          poinDigunakan: 5,
          tanggal: DateTime.now(),
          deskripsi: '',
          jumlah: 0,
          tipe: TipeTransaksi.income,
          idDompet: '',
          idKategori: '',
        ),
        TransaksiModel(
          id: '3',
          tanggal: DateTime.now(),
          deskripsi: '',
          jumlah: 0,
          tipe: TipeTransaksi.income,
          idDompet: '',
          idKategori: '',
        ),
      ];
      when(mockTransactionOperation.getByIdPelanggan(customerId))
          .thenAnswer((_) async => transactions);

      final result = await dataSource.getPointsTransactions(customerId);

      expect(result, hasLength(2));
      expect(result.any((t) => t.id == '1'), isTrue);
      expect(result.any((t) => t.id == '2'), isTrue);
      verify(mockTransactionOperation.getByIdPelanggan(customerId));
      verifyNoMoreInteractions(mockTransactionOperation);
    });

    test('4. getPackageById harus mengembalikan paket dari operasi paket',
        () async {
      const packageId = 'test_package_id';
      final package = PaketModel(
        id: packageId,
        nama: 'Test Package',
        harga: 0,
        durasi: 0,
        tipe: TipeDurasiPaket.hours,
      );
      when(mockPackageOperation.getById(packageId))
          .thenAnswer((_) async => package);

      final result = await dataSource.getPaketByid(packageId);

      expect(result, package);
      verify(mockPackageOperation.getById(packageId));
      verifyNoMoreInteractions(mockPackageOperation);
    });

    test('5. isFirebase harus mengembalikan false', () {
      expect(dataSource.isFirebase, isFalse);
    });
  });
}
