// path: lib/fitur/poin/poin/firebase_points_data_source.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/poin/provider/points_page_data_source.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/shared/operasi/firebase_operasi/paeket_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/transaction_op_firebase.dart';

/// Implementasi [PointsPageDataSource] untuk mengambil data dari Firebase.
class FirebasePointsDataSource implements PointsPageDataSource {
  final TransactionOpFirebase _transactionOpFirebase;
  final PaketOpFirebase _packageOpFirebase;

  FirebasePointsDataSource({
    required TransactionOpFirebase transactionOpFirebase,
    required PaketOpFirebase packageOpFirebase,
  })  : _transactionOpFirebase = transactionOpFirebase,
        _packageOpFirebase = packageOpFirebase;

  @override
  Future<int> getTotalPoints(String customerId) {
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
        .where((t) => t.earnedPoints > 0 || t.usedPoints > 0)
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
    transactionOpFirebase: ref.watch(transactionOpFirebaseProvider),
    packageOpFirebase: ref.watch(packageOpFirebaseProvider),
  );
});
