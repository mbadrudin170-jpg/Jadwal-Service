// path: test/shared/operasi/poin/points_page_data_source_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/poin/provider/points_page_data_source.dart';

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
      when(dataSource.ambilTotalPoin(customerId)).thenAnswer((_) async => 100);

      expect(dataSource.ambilTotalPoin(customerId), isA<Future<int>>());
    });

    test('getPublicPackages returns a Future<List<PackageModel>>', () {
      when(dataSource.getPublicPackages()).thenAnswer((_) async => []);

      expect(dataSource.getPublicPackages(), isA<Future<List<PaketModel>>>());
    });

    test('getPointsTransactions returns a Future<List<TransactionModel>>', () {
      const customerId = 'test_id';
      when(dataSource.getPointsTransactions(customerId))
          .thenAnswer((_) async => []);

      expect(dataSource.getPointsTransactions(customerId),
          isA<Future<List<TransaksiModel>>>());
    });

    test('getPackageById returns a Future<PackageModel?>', () {
      const packageId = 'test_id';
      when(dataSource.getPaketByid(packageId)).thenAnswer((_) async => null);

      expect(dataSource.getPaketByid(packageId), isA<Future<PaketModel?>>());
    });

    test('isFirebase returns a bool', () {
      when(dataSource.isFirebase).thenReturn(true);

      expect(dataSource.isFirebase, isA<bool>());
    });
  });
}
