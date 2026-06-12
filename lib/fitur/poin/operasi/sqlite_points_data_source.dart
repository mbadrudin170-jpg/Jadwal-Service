// path: lib/fitur/poin/operasi/sqlite_points_data_source.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/poin/provider/points_page_data_source.dart';
import 'package:wifi/shared/model/package_model.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/paket_Op_Sqlite.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/transaction_operation.dart';

class SQLitePointsDataSource implements PointsPageDataSource {
  final TransactionOperation _transactionOperation;
  final PaketOpSqlite _packageOperation;

  SQLitePointsDataSource({
    required TransactionOperation transactionOperation,
    required PaketOpSqlite packageOperation,
  })  : _transactionOperation = transactionOperation,
        _packageOperation = packageOperation;

  @override
  Future<int> getTotalPoints(String customerId) {
    return _transactionOperation.getTotalPoints(customerId);
  }

  @override
  Future<List<PackageModel>> getPublicPackages() {
    return _packageOperation.getPaketPublic();
  }

  @override
  Future<List<TransactionModel>> getPointsTransactions(
      final String customerId) async {
    final history = await _transactionOperation.getByIdPelanggan(customerId);
    return history
        .where((t) => t.earnedPoints > 0 || t.usedPoints > 0)
        .toList();
  }

  @override
  Future<PackageModel?> getPaketByid(String packageId) {
    return _packageOperation.ambilBerdasarkanId(packageId);
  }

  @override
  bool get isFirebase => false;
}

final sqlitePointsDataSourceProvider = Provider<SQLitePointsDataSource>((ref) {
  return SQLitePointsDataSource(
    transactionOperation: ref.watch(transactionOperationProvider),
    packageOperation: ref.watch(packageOperationProvider),
  );
});
