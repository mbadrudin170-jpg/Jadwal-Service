// path: lib/shared/operasi/firebase_operasi/transaction_op_firebase.dart
// diubah: Menambahkan getLatestPaidTransactionByUserId.
// diperbaiki: Menambahkan logging inisialisasi dan menerjemahkan komentar.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/payment_status_enum.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/model/transaction_model.dart';

/// Kelas untuk mengelola operasi terkait data transaksi di Firestore.
class TransactionOpFirebase {
  final FirebaseFirestore _db;

  /// Konstruktor untuk inisialisasi dengan instance FirebaseFirestore.
  TransactionOpFirebase({final FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance {
    Log.info('TransactionOpFirebase diinisialisasi.');
  }

  /// Mendapatkan referensi ke koleksi transaction.
  CollectionReference get _collection =>
      _db.collection(TableNameValue.get(TableName.transactions));

  /// Mengambil transaksi lunas terbaru dari seorang pengguna berdasarkan tanggal akhir.
  /// Digunakan untuk menentukan status langganan aktif di sisi user.
  Future<TransactionModel?> getLatestPaidTransactionByUserId(
    final String customerId,
  ) async {
    try {
      Log.info(
          'Mencari transaksi lunas terbaru dari Firebase untuk pengguna ID: $customerId');
      final querySnapshot = await _collection
          .where(ColumnNames.customerId, isEqualTo: customerId)
          .where(ColumnNames.paymentStatus, isEqualTo: PaymentStatus.paid.name)
          .orderBy(ColumnNames.endDate, descending: true)
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
      return TransactionModel.fromFirebase(doc.id, data);
    } on Exception catch (e, s) {
      Log.error(
          'Error mengambil transaksi lunas terbaru dari Firebase untuk pengguna ID: $customerId',
          e: e,
          st: s);
      return null;
    }
  }

  /// Mengambil semua transaksi untuk seorang pelanggan.
  Future<List<TransactionModel>> getTransactionsByCustomerId(
    final String customerId,
  ) async {
    try {
      Log.info('Mengambil semua transaksi untuk: $customerId');
      final querySnapshot = await _collection
          .where(ColumnNames.customerId, isEqualTo: customerId)
          .orderBy(ColumnNames.date, descending: true)
          .get();

      Log.info('Menemukan ${querySnapshot.docs.length} transaksi.');
      return querySnapshot.docs.map((final doc) {
        final data = doc.data() as Map<String, dynamic>;
        return TransactionModel.fromFirebase(doc.id, data);
      }).toList();
    } on Exception catch (e, s) {
      Log.error('Error mengambil transaksi: $e', e: e, st: s);
      return [];
    }
  }

  /// Menghitung total poin yang dimiliki oleh pelanggan.
  Future<int> getTotalPoints(final String customerId) async {
    try {
      Log.info('Menghitung total poin untuk: $customerId');
      final querySnapshot = await _collection
          .where(ColumnNames.customerId, isEqualTo: customerId)
          .get();

      int totalPoints = 0;
      for (final doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        totalPoints += (data[ColumnNames.earnedPoints] as int? ?? 0);
        totalPoints -= (data[ColumnNames.usedPoints] as int? ?? 0);
      }

      Log.info('Total poin untuk $customerId adalah $totalPoints');
      return totalPoints;
    } on Exception catch (e, s) {
      Log.error('Error menghitung total poin: $e', e: e, st: s);
      return 0;
    }
  }

  /// Mengambil riwayat langganan untuk seorang pelanggan.
  Future<List<TransactionModel>> getSubscriptionHistory(
    final String customerId,
  ) {
    return getTransactionsByCustomerId(customerId);
  }

  /// Mengambil riwayat langganan lengkap untuk seorang pelanggan.
  Future<List<TransactionModel>> getFullSubscriptionHistory(
    final String customerId,
  ) {
    return getSubscriptionHistory(customerId);
  }
}
