// path: lib/shared/operasi/poin/points_page_data_source.dart

import 'package:wifi/shared/model/package_model.dart';
import 'package:wifi/shared/model/transaction_model.dart';

/// Abstract class to define the data source contract for the points page.
/// This allows the UI to be independent of the data source (Firebase or SQLite).
abstract class PointsPageDataSource {
  /// Fetches the total points for a given customer.
  Future<int> getTotalPoints(final String customerId);

  /// Fetches the list of public packages available for redemption.
  Future<List<PackageModel>> getPublicPackages();

  /// Fetches the transaction history related to points (earned or used).
  Future<List<TransactionModel>> getPointsTransactions(final String customerId);

  /// Fetches a single package by its ID.
  Future<PackageModel?> getPackageById(final String packageId);

  /// A boolean to indicate if the data source is Firebase.
  /// This can be used for UI variations if needed.
  bool get isFirebase;
}
