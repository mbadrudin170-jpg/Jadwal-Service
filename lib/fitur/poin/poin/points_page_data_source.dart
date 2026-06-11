// path: lib/fitur/poin/poin/points_page_data_source.dart

import 'package:wifi/shared/model/package_model.dart';
import 'package:wifi/shared/model/transaction_model.dart';

abstract class PointsPageDataSource {
  Future<int> getTotalPoints(String customerId);

  Future<List<PackageModel>> getPublicPackages();

  Future<List<TransactionModel>> getPointsTransactions(String customerId);

  Future<PackageModel?> getPackageById(String packageId);

  bool get isFirebase;
}
