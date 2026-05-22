// path: lib/shared/operasi/firebase_operasi/active_customer_op_firebase.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/export/model.dart';
// import 'package:wifi/shared/model/transaction_model.dart'; // Komentar: Import ini tidak digunakan di dalam kelas.

/// Kelas operasi untuk mengelola data pelanggan aktif dari Firebase.
class ActiveCustomerOpFirebase {
  final FirebaseFirestore _db;

  /// Konstruktor untuk inisialisasi dengan instance FirebaseFirestore.
  ActiveCustomerOpFirebase({final FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance {
    // Perbaikan: Menyesuaikan pesan log dengan nama kelas.
    Log.info('ActiveCustomerOpFirebase diinisialisasi.');
  }

  /// Mendapatkan referensi ke koleksi transaction.
  CollectionReference get _collection =>
      _db.collection(TableNameValue.get(TableName.transactions));

  /// Mengambil data pelanggan aktif berdasarkan ID pelanggan dari Firebase.
  ///
  /// Mengembalikan [ActiveCustomerModel] jika ditemukan, jika tidak `null`.
  Future<ActiveCustomerModel?> getActiveCustomersById(
    final String customerId,
  ) async {
    // Perbaikan: Menggunakan blok try-catch yang benar untuk menangani error.
    try {
      final querySnapshot = await _collection
          .where(ColumnNames.customerId, isEqualTo: customerId)
          .where(ColumnNames.isDeleted, isEqualTo: false)
          .limit(1)
          .get();
      if (querySnapshot.docs.isEmpty) {
        Log.warning(
            'Tidak ada transaksi lunas yang aktif dari Firebase untuk pengguna ID: $customerId');
        return null;
      }

      final doc = querySnapshot.docs.first;
      final data = doc.data() as Map<String, dynamic>;
      Log.info(
          'Transaksi lunas terbaru dari Firebase ditemukan untuk pengguna ID: $customerId');
      return ActiveCustomerModel.fromFirebase(doc.id, data);
    }on Exception catch (e, s) {
      Log.error(
          'Error mengambil transaksi lunas terbaru dari Firebase untuk pengguna ID: $customerId',
          e: e,
          st: s);
      return null;
    }
  }
}
