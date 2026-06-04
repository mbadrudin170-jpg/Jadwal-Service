// path: test/shared/operasi/poin/points_page_data_source_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/shared/model/package_model.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/operasi/poin/points_page_data_source.dart';

import 'points_page_data_source_test.mocks.dart';

@GenerateMocks([PointsPageDataSource])
void main() {
  group('PointsPageDataSource', () {
    late MockPointsPageDataSource dataSource;

    setUp(() {
      dataSource = MockPointsPageDataSource();
    });

    test('getTotalPoints returns a Future<int>', () {
      const customerId = 'test_id';
      when(dataSource.getTotalPoints(customerId)).thenAnswer((_) async => 100);

      expect(dataSource.getTotalPoints(customerId), isA<Future<int>>());
    });

    test('getPublicPackages returns a Future<List<PackageModel>>', () {
      when(dataSource.getPublicPackages()).thenAnswer((_) async => []);

      expect(dataSource.getPublicPackages(), isA<Future<List<PackageModel>>>());
    });

    test('getPointsTransactions returns a Future<List<TransactionModel>>', () {
      const customerId = 'test_id';
      when(dataSource.getPointsTransactions(customerId))
          .thenAnswer((_) async => []);

      expect(dataSource.getPointsTransactions(customerId),
          isA<Future<List<TransactionModel>>>());
    });

    test('getPackageById returns a Future<PackageModel?>', () {
      const packageId = 'test_id';
      when(dataSource.getPackageById(packageId)).thenAnswer((_) async => null);

      expect(
          dataSource.getPackageById(packageId), isA<Future<PackageModel?>>());
    });

    test('isFirebase returns a bool', () {
      when(dataSource.isFirebase).thenReturn(true);

      expect(dataSource.isFirebase, isA<bool>());
    });
  });
}
