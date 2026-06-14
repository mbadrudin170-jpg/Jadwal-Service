// path: lib/fitur/poin/operasi/sqlite_points_data_source.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/poin/provider/points_page_data_source.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/paket/operasi/paket_op_Sqlite.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_sqlite.dart';

class SQLitePointsDataSource implements PointsPageDataSource {
  final TransaksiOpsqlite _transaksiOpSqlite;
  final PaketOpSqlite _paketOpSqlite;

  SQLitePointsDataSource({
    required TransaksiOpsqlite transaksiOpSqlite,
    required PaketOpSqlite paketOpSqlite,
  })  : _transaksiOpSqlite = transaksiOpSqlite,
        _paketOpSqlite = paketOpSqlite;

  @override
  Future<int> ambilTotalPoin(String customerId) {
    return _transaksiOpSqlite.ambilTotalPoin(customerId);
  }

  @override
  Future<List<PaketModel>> getPublicPackages() {
    return _paketOpSqlite.ambilPaketPublik();
  }

  @override
  Future<List<TransaksiModel>> getPointsTransactions(
      final String customerId) async {
    final history = await _transaksiOpSqlite.getByIdPelanggan(customerId);
    return history
        .where((t) => t.poinDidapat > 0 || t.poinDigunakan > 0)
        .toList();
  }

  @override
  Future<PaketModel?> getPaketByid(String packageId) {
    return _paketOpSqlite.ambilBerdasarkanId(packageId);
  }

  @override
  bool get isFirebase => false;
}

final sqlitePointsDataSourceProvider = Provider<SQLitePointsDataSource>((ref) {
  return SQLitePointsDataSource(
    transaksiOpSqlite: ref.watch(transaksiOpSqliteProvider),
    paketOpSqlite: ref.watch(paketOpSqliteProvider),
  );
});
