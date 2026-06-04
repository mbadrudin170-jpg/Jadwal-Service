// path: lib/shared/operasi/poin/firebase_points_data_source.dart

import 'package:wifi/shared/model/package_model.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/package_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/transaction_op_firebase.dart';
import 'package:wifi/shared/operasi/poin/points_page_data_source.dart';

/// Implementasi [PointsPageDataSource] untuk mengambil data dari Firebase.
class FirebasePointsDataSource implements PointsPageDataSource {
  final TransactionOpFirebase _transactionOpFirebase;
  final PackageOpFirebase _packageOpFirebase;

  FirebasePointsDataSource({
    final TransactionOpFirebase? transactionOpFirebase,
    final PackageOpFirebase? packageOpFirebase,
  })  : _transactionOpFirebase = transactionOpFirebase ?? TransactionOpFirebase(),
        _packageOpFirebase = packageOpFirebase ?? PackageOpFirebase();


  @override
  Future<int> getTotalPoints(final String customerId) {
    return _transactionOpFirebase.getTotalPoints(customerId);
  }

  @override
  Future<List<PackageModel>> getPublicPackages() {
    return _packageOpFirebase.getPublicPackages();
  }

  @override
  Future<List<TransactionModel>> getPointsTransactions(
      final String customerId) async {
    final history =
        await _transactionOpFirebase.getTransactionsByCustomerId(customerId);
    return history
        .where((final t) => t.earnedPoints > 0 || t.usedPoints > 0)
        .toList();
  }

  @override
  Future<PackageModel?> getPackageById(final String packageId) {
    return _packageOpFirebase.getPackageById(packageId);
  }

  @override
  bool get isFirebase => true;
}
