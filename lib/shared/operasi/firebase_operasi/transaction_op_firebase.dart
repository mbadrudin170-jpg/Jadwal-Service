// path: lib/shared/operasi/firebase_operasi/transaction_op_firebase.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/transaction_model.dart';

/// Kelas untuk mengelola operasi terkait data transaksi di Firestore.
class TransactionOpFirebase {
  final FirebaseFirestore _db;

  /// Konstruktor untuk inisialisasi dengan instance FirebaseFirestore.
  /// Memungkinkan injeksi instance palsu untuk pengujian.
  TransactionOpFirebase({final FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  /// Mengambil riwayat langganan (transaksi) untuk seorang pelanggan.
  ///
  /// [customerId]: ID dari pelanggan yang ingin dicari riwayatnya.
  /// Mengembalikan daftar [TransactionModel].
  Future<List<TransactionModel>> getSubscriptionHistory(
      final String customerId) async {
    try {
      Log.info('Mengambil riwayat langganan untuk pelanggan ID: $customerId');
      final querySnapshot = await _db
          .collection('transaksi')
          .where('id_pelanggan', isEqualTo: customerId)
          .orderBy('tanggal', descending: true)
          .get();

      Log.info('Menemukan ${querySnapshot.docs.length} riwayat transaksi.');
      return querySnapshot.docs
          .map((final doc) => TransactionModel.fromFirebase(doc.id, doc.data()))
          .toList();
    } on Exception catch (e, s) {
      Log.error(
        'Error mengambil riwayat langganan: $e',
        e: e,
        st: s,
      );
      return [];
    }
  }

  /// Mengambil riwayat langganan lengkap untuk seorang pelanggan.
  ///
  /// [customerId]: ID dari pelanggan yang ingin dicari riwayatnya.
  /// Saat ini, fungsi ini hanya memanggil `getSubscriptionHistory`.
  Future<List<TransactionModel>> getFullSubscriptionHistory(
    final String customerId,
  ) {
    // TODO: Implementasi mungkin perlu dibedakan dari getSubscriptionHistory
    //       jika ada kebutuhan untuk mengambil data yang lebih detail.
    return getSubscriptionHistory(customerId);
  }
}
