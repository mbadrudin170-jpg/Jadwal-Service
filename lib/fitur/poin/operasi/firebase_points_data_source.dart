// path: lib/fitur/poin/poin/firebase_points_data_source.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/poin/provider/points_page_data_source.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/fitur/paket/operasi/paket_op_firebase.dart';

/// Implementasi [PointsPageDataSource] untuk mengambil data dari Firebase.
class FirebasePointsDataSource implements PointsPageDataSource {
  final TransaksiOpFirebase _transactionOpFirebase;
  final PaketOpFirebase _packageOpFirebase;

  FirebasePointsDataSource({
    required TransaksiOpFirebase transactionOpFirebase,
    required PaketOpFirebase packageOpFirebase,
  })  : _transactionOpFirebase = transactionOpFirebase,
        _packageOpFirebase = packageOpFirebase;

  @override
  Future<int> ambilTotalPoin(String customerId) {
    return _transactionOpFirebase.ambilTotalPoin(customerId);
  }

  @override
  Future<List<PaketModel>> getPublicPackages() {
    return _packageOpFirebase.ambilPaketPublik();
  }

  @override
  Future<List<TransaksiModel>> getPointsTransactions(String customerId) async {
    final history =
        await _transactionOpFirebase.ambilBerdasarkanIdPelanggan(customerId);
    return history
        .where((t) => t.poinDidapat > 0 || t.poinDigunakan > 0)
        .toList();
  }

  @override
  Future<PaketModel?> getPaketByid(String packageId) {
    return _packageOpFirebase.ambilBerdasarkanId(packageId);
  }

  @override
  bool get isFirebase => true;
}

final firebasePointsDataSourceProvider =
    Provider<FirebasePointsDataSource>((ref) {
  return FirebasePointsDataSource(
    transactionOpFirebase: ref.watch(transaksiOpFirebaseProvider),
    packageOpFirebase: ref.watch(paketOpFirebaseProvider),
  );
});
