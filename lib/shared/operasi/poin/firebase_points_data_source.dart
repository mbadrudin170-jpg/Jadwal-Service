// path: lib/shared/operasi/poin/firebase_points_data_source.dart

import 'package:wifi/shared/model/package_model.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/package_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/transaction_op_firebase.dart';
import 'package:wifi/shared/operasi/poin/points_page_data_source.dart';

/// Implementasi [PointsPageDataSource] untuk mengambil data dari Firebase.
///
/// Kelas ini sekarang bergantung pada [TransactionOpFirebase] dan [PackageOpFirebase]
/// yang disuntikkan dari luar, alih-alih membuatnya sendiri.
class FirebasePointsDataSource implements PointsPageDataSource {
  final TransactionOpFirebase _transactionOpFirebase;
  final PackageOpFirebase _packageOpFirebase;

  // 1. Konstruktor diperbarui untuk menerima dependensi secara langsung.
  // Tidak ada lagi instance `FirebaseFirestore.instance` atau pembuatan
  // `TransactionOpFirebase` dan `PackageOpFirebase` secara internal.
  FirebasePointsDataSource({
    required TransactionOpFirebase transactionOpFirebase,
    required PackageOpFirebase packageOpFirebase,
  })  : _transactionOpFirebase = transactionOpFirebase,
        _packageOpFirebase = packageOpFirebase;

  @override
  Future<int> getTotalPoints(final String customerId) {
    // 2. Mengambil total poin pelanggan
    return _transactionOpFirebase.getTotalPoints(customerId);
  }

  @override
  Future<List<PackageModel>> getPublicPackages() {
    // 3. Mengambil daftar paket publik
    return _packageOpFirebase.getPublicPackages();
  }

  @override
  Future<List<TransactionModel>> getPointsTransactions(
      final String customerId) async {
    // 4. Mengambil riwayat transaksi poin pelanggan
    final history =
        await _transactionOpFirebase.getTransactionsByCustomerId(customerId);
    return history
        .where((final t) => t.earnedPoints > 0 || t.usedPoints > 0)
        .toList();
  }

  @override
  Future<PackageModel?> getPackageById(final String packageId) {
    // 5. Mengambil detail paket berdasarkan ID
    return _packageOpFirebase.getPackageById(packageId);
  }

  @override
  bool get isFirebase => true;
}
