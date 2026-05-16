// path: lib/shared/operasi/firebase_operasi/transaction_op_firebase.dart
// diubah: Memperbaiki cast doc.data() ke Map<String, dynamic>.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/model/transaction_model.dart';

/// Kelas untuk mengelola operasi terkait data transaksi di Firestore.
class TransactionOpFirebase {
  final FirebaseFirestore _db;

  /// Konstruktor untuk inisialisasi dengan instance FirebaseFirestore.
  TransactionOpFirebase({final FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  /// Mendapatkan referensi ke koleksi transaction.
  CollectionReference get _collection =>
      _db.collection(TableNameValue.get(TableName.transaction));

  /// Mengambil riwayat langganan untuk seorang pelanggan.
  Future<List<TransactionModel>> getSubscriptionHistory(
    final String customerId,
  ) async {
    try {
      Log.info('Mengambil riwayat langganan untuk: $customerId');
      final querySnapshot = await _collection
          .where(ColumnNames.customerId, isEqualTo: customerId)
          .orderBy(ColumnNames.date, descending: true)
          .get();

      Log.info('Menemukan ${querySnapshot.docs.length} riwayat transaksi.');
      return querySnapshot.docs.map((final doc) {
        final data = doc.data() as Map<String, dynamic>;
        return TransactionModel.fromFirebase(doc.id, data);
      }).toList();
    } on Exception catch (e, s) {
      Log.error('Error mengambil riwayat langganan: $e', e: e, st: s);
      return [];
    }
  }

  /// Mengambil riwayat langganan lengkap untuk seorang pelanggan.
  Future<List<TransactionModel>> getFullSubscriptionHistory(
    final String customerId,
  ) {
    return getSubscriptionHistory(customerId);
  }
}
