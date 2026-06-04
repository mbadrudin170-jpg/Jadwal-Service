// path: test/shared/operasi/poin/firebase_points_data_source_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/shared/enum/duration_type_enum.dart';
import 'package:wifi/shared/enum/transaction_type_enum.dart';
import 'package:wifi/shared/model/package_model.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/package_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/transaction_op_firebase.dart';
import 'package:wifi/shared/operasi/poin/firebase_points_data_source.dart';

import 'firebase_points_data_source_test.mocks.dart';

@GenerateMocks([TransactionOpFirebase, PackageOpFirebase])
void main() {
  late MockTransactionOpFirebase mockTransactionOpFirebase;
  late MockPackageOpFirebase mockPackageOpFirebase;
  late FirebasePointsDataSource dataSource;

  setUp(() {
    mockTransactionOpFirebase = MockTransactionOpFirebase();
    mockPackageOpFirebase = MockPackageOpFirebase();
    dataSource = FirebasePointsDataSource(
      transactionOpFirebase: mockTransactionOpFirebase,
      packageOpFirebase: mockPackageOpFirebase,
    );
  });

  group('FirebasePointsDataSource', () {
    const customerId = 'test_customer_id';

    test('getTotalPoints should return total points from transaction operation',
        () async {
      when(mockTransactionOpFirebase.getTotalPoints(customerId))
          .thenAnswer((_) async => 100);

      final result = await dataSource.getTotalPoints(customerId);

      expect(result, 100);
      verify(mockTransactionOpFirebase.getTotalPoints(customerId));
      verifyNoMoreInteractions(mockTransactionOpFirebase);
    });

    test(
        'getPublicPackages should return public packages from package operation',
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
      when(mockPackageOpFirebase.getPublicPackages())
          .thenAnswer((_) async => packages);

      final result = await dataSource.getPublicPackages();

      expect(result, packages);
      verify(mockPackageOpFirebase.getPublicPackages());
      verifyNoMoreInteractions(mockPackageOpFirebase);
    });

    test(
        'getPointsTransactions should return transactions with points from transaction operation',
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
      when(mockTransactionOpFirebase.getTransactionsByCustomerId(customerId))
          .thenAnswer((_) async => transactions);

      final result = await dataSource.getPointsTransactions(customerId);

      expect(result, hasLength(2));
      expect(result.any((t) => t.id == '1'), isTrue);
      expect(result.any((t) => t.id == '2'), isTrue);
      verify(mockTransactionOpFirebase.getTransactionsByCustomerId(customerId));
      verifyNoMoreInteractions(mockTransactionOpFirebase);
    });

    test('getPackageById should return package from package operation',
        () async {
      const packageId = 'test_package_id';
      final package = PackageModel(
        id: packageId,
        name: 'Test Package',
        price: 0,
        duration: 0,
        type: DurationType.hours,
      );
      when(mockPackageOpFirebase.getPackageById(packageId))
          .thenAnswer((_) async => package);

      final result = await dataSource.getPackageById(packageId);

      expect(result, package);
      verify(mockPackageOpFirebase.getPackageById(packageId));
      verifyNoMoreInteractions(mockPackageOpFirebase);
    });

    test('isFirebase should return true', () {
      expect(dataSource.isFirebase, isTrue);
    });
  });
}
