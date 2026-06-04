// path: test/shared/operasi/poin/sqlite_points_data_source_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/shared/model/package_model.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/package_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/transaction_operation.dart';
import 'package:wifi/shared/operasi/poin/sqlite_points_data_source.dart';

import 'sqlite_points_data_source_test.mocks.dart';

@GenerateMocks([TransactionOperation, PackageOperation])
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

    test('getTotalPoints should return total points from transaction operation',
        () async {
      when(mockTransactionOperation.getTotalPoints(customerId))
          .thenAnswer((_) async => 100);

      final result = await dataSource.getTotalPoints(customerId);

      expect(result, 100);
      verify(mockTransactionOperation.getTotalPoints(customerId));
      verifyNoMoreInteractions(mockTransactionOperation);
    });

    test('getPublicPackages should return public packages from package operation',
        () async {
      final packages = [PackageModel(id: '1', name: 'Test Package')];
      when(mockPackageOperation.getByIsPublic())
          .thenAnswer((_) async => packages);

      final result = await dataSource.getPublicPackages();

      expect(result, packages);
      verify(mockPackageOperation.getByIsPublic());
      verifyNoMoreInteractions(mockPackageOperation);
    });

    test(
        'getPointsTransactions should return transactions with points from transaction operation',
        () async {
      final transactions = [
        TransactionModel(id: '1', earnedPoints: 10),
        TransactionModel(id: '2', usedPoints: 5),
        TransactionModel(id: '3'),
      ];
      when(mockTransactionOperation.getTransactionsByCustomerId(customerId))
          .thenAnswer((_) async => transactions);

      final result = await dataSource.getPointsTransactions(customerId);

      expect(result, hasLength(2));
      expect(result.any((t) => t.id == '1'), isTrue);
      expect(result.any((t) => t.id == '2'), isTrue);
      verify(mockTransactionOperation.getTransactionsByCustomerId(customerId));
      verifyNoMoreInteractions(mockTransactionOperation);
    });

    test('getPackageById should return package from package operation',
        () async {
      const packageId = 'test_package_id';
      final package = PackageModel(id: packageId, name: 'Test Package');
      when(mockPackageOperation.getById(packageId))
          .thenAnswer((_) async => package);

      final result = await dataSource.getPackageById(packageId);

      expect(result, package);
      verify(mockPackageOperation.getById(packageId));
      verifyNoMoreInteractions(mockPackageOperation);
    });

    test('isFirebase should return false', () {
      expect(dataSource.isFirebase, isFalse);
    });
  });
}
