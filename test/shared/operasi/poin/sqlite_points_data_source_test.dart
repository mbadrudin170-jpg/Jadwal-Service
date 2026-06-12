// path: test/shared/operasi/poin/sqlite_points_data_source_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/shared/enum/duration_type_enum.dart';
import 'package:wifi/shared/enum/transaction_type_enum.dart';
import 'package:wifi/shared/model/package_model.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/fitur/poin/operasi/sqlite_points_data_source.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/paket_Op_Sqlite.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/transaction_operation.dart';

import 'sqlite_points_data_source_test.mocks.dart';

@GenerateMocks([TransactionOperation, PaketOpSqlite])
void main() {
  late MockTransactionOperation mockTransactionOperation;
  late MockPackageOperation mockPackageOperation;
  late SQLitePointsDataSource dataSource;

  setUp(() {
    mockTransactionOperation = MockTransactionOperation();
    mockPackageOperation = MockPackageOperation();
    dataSource = SQLitePointsDataSource(
      transactionOperation: mockTransactionOperation,
      packageOperation: mockPackageOperation,
    );
  });

  group('SQLitePointsDataSource', () {
    const customerId = 'test_customer_id';

    test(
        '1. getTotalPoints harus mengembalikan total poin dari operasi transaksi',
        () async {
      when(mockTransactionOperation.getTotalPoints(customerId))
          .thenAnswer((_) async => 100);

      final result = await dataSource.getTotalPoints(customerId);

      expect(result, 100);
      verify(mockTransactionOperation.getTotalPoints(customerId));
      verifyNoMoreInteractions(mockTransactionOperation);
    });

    test(
        '2. getPublicPackages harus mengembalikan paket publik dari operasi paket',
        () async {
      final packages = [
        PackageModel(
          id: '1',
          name: 'Test Package',
          price: 0,
          duration: 0,
          type: DurationType.hours,
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
        TransactionModel(
          id: '1',
          earnedPoints: 10,
          date: DateTime.now(),
          description: '',
          amount: 0,
          type: TransactionType.income,
          walletId: '',
          categoryId: '',
        ),
        TransactionModel(
          id: '2',
          usedPoints: 5,
          date: DateTime.now(),
          description: '',
          amount: 0,
          type: TransactionType.income,
          walletId: '',
          categoryId: '',
        ),
        TransactionModel(
          id: '3',
          date: DateTime.now(),
          description: '',
          amount: 0,
          type: TransactionType.income,
          walletId: '',
          categoryId: '',
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
      final package = PackageModel(
        id: packageId,
        name: 'Test Package',
        price: 0,
        duration: 0,
        type: DurationType.hours,
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
