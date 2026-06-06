// path: lib/shared/operasi/poin/sqlite_points_data_source.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/shared/model/package_model.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/operasi/poin/points_page_data_source.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/operasi_sqlite_provider/operasi_sqlite_provider.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/package_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/transaction_operation.dart';

/// Implementasi [PointsPageDataSource] untuk mengambil data dari database SQLite lokal.
class SQLitePointsDataSource implements PointsPageDataSource {
  final TransactionOperation _transactionOperation;
  final PackageOperation _packageOperation;

  /// Konstruktor dengan injeksi dependensi.
  SQLitePointsDataSource({
    required TransactionOperation transactionOperation,
    required PackageOperation packageOperation,
  })  : _transactionOperation = transactionOperation,
        _packageOperation = packageOperation;

  @override
  Future<int> getTotalPoints(final String customerId) {
    return _transactionOperation.getTotalPoints(customerId);
  }

  @override
  Future<List<PackageModel>> getPublicPackages() {
    return _packageOperation.getByIsPublic();
  }

  @override
  Future<List<TransactionModel>> getPointsTransactions(
      final String customerId) async {
    final history =
        await _transactionOperation.getTransactionsByCustomerId(customerId);
    return history
        .where((final t) => t.earnedPoints > 0 || t.usedPoints > 0)
        .toList();
  }

  @override
  Future<PackageModel?> getPackageById(final String packageId) {
    return _packageOperation.getById(packageId);
  }

  @override
  bool get isFirebase => false;
}

// ============================================================
// Provider Riverpod untuk SQLitePointsDataSource
// ============================================================
final sqlitePointsDataSourceProvider = Provider<SQLitePointsDataSource>((ref) {
  return SQLitePointsDataSource(
    transactionOperation: ref.watch(transactionOperationProvider),
    packageOperation: ref.watch(packageOperationProvider),
  );
});
