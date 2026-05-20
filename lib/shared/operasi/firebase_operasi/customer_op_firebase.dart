// path: lib/shared/operasi/firebase_operasi/customer_op_firebase.dart
// diubah: Menggunakan TableNameValue dan ColumnNames untuk semua referensi
//         koleksi dan kolom.
// diperbaiki: Menambahkan logging dan error handling yang lebih konsisten.
// ditambahkan: Fungsi deleteCustomer untuk menghapus pelanggan secara permanen.
// ditambahkan: Fungsi softDeleteCustomer untuk menandai pelanggan sebagai terhapus.

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/model/customer_model.dart';

/// Kelas ini menangani semua operasi terkait data pelanggan di Firestore.
class CustomerOpFirebase {
  final CollectionReference _customerCollection;

  /// Konstruktor untuk inisialisasi dengan instance FirebaseFirestore.
  CustomerOpFirebase({final FirebaseFirestore? firestore})
      : _customerCollection = (firestore ?? FirebaseFirestore.instance)
            .collection(TableNameValue.get(TableName.customer)) {
    Log.info('CustomerOpFirebase diinisialisasi.');
  }

  /// Memperbarui data pelanggan yang ada di Firestore.
  Future<void> updateCustomer(final CustomerModel customer) async {
    Log.info('Memulai pembaruan pelanggan di Firestore: ${customer.id}');
    try {
      final dataToUpdate = customer.toFirebase()
        ..[ColumnNames.updatedAt] = FieldValue.serverTimestamp();

      await _customerCollection.doc(customer.id).update(dataToUpdate);
      Log.info('Pembaruan pelanggan berhasil: ${customer.id}');
    } on FirebaseException catch (e, s) {
      Log.error('Gagal memperbarui pelanggan: ${customer.id}', e: e, st: s);
      rethrow;
    }
  }

  /// Mengambil data pelanggan secara real-time (stream).
  Stream<CustomerModel?> getCustomerStream(final String userId) {
    Log.info('Streaming data pelanggan untuk: $userId');
    return _customerCollection.doc(userId).snapshots().map((final snapshot) {
      if (snapshot.exists) {
        Log.info('Data pelanggan stream diperbarui: $userId');
        return CustomerModel.fromFirebase(
          snapshot.id,
          snapshot.data()! as Map<String, dynamic>,
        );
      }
      Log.warning('Pelanggan $userId tidak ditemukan di stream.');
      return null;
    }).handleError((final Object e, final StackTrace s) {
      Log.error('Error pada stream pelanggan untuk: $userId', e: e, st: s);
    });
  }

  /// Mengambil data pelanggan sekali (one-time fetch).
  Future<CustomerModel?> getCustomerOnce(final String userId) async {
    try {
      Log.info('Mengambil pelanggan sekali untuk ID: $userId');
      final doc = await _customerCollection.doc(userId).get();
      if (doc.exists) {
        Log.info('Pelanggan ditemukan', doc.data());
        return CustomerModel.fromFirebase(
          doc.id,
          doc.data()! as Map<String, dynamic>,
        );
      }
      Log.warning('Pelanggan $userId tidak ditemukan.');
      return null;
    } on Exception catch (e, s) {
      Log.error('Error mengambil pelanggan: $e', e: e, st: s);
      return null;
    }
  }

  /// Menyimpan atau memperbarui token FCM pengguna.
  Future<void> saveFcmToken(final String userId, final String? token) async {
    if (token == null || token.isEmpty) {
      Log.warning('Token FCM kosong, penyimpanan dibatalkan.');
      return;
    }

    Log.info('Menyimpan token FCM untuk: $userId');
    try {
      await _customerCollection.doc(userId).update({'fcmToken': token});
      Log.info('Token FCM berhasil disimpan.');
    } on Exception catch (e, s) {
      Log.error('Gagal menyimpan token FCM untuk $userId', e: e, st: s);
      rethrow;
    }
  }

  /// Menghapus pelanggan dari Firestore secara permanen.
  Future<void> deleteCustomer(final String customerId) async {
    Log.warning('Memulai penghapusan permanen pelanggan di Firestore: $customerId');
    try {
      await _customerCollection.doc(customerId).delete();
      Log.info('Penghapusan permanen pelanggan berhasil: $customerId');
    } on FirebaseException catch (e, s) {
      Log.error('Gagal menghapus pelanggan secara permanen: $customerId', e: e, st: s);
      rethrow;
    }
  }

  /// Melakukan soft delete pada pelanggan di Firestore.
  Future<void> softDeleteCustomer(final String customerId) async {
    Log.info('Memulai soft delete pelanggan di Firestore: $customerId');
    try {
      await _customerCollection.doc(customerId).update({
        ColumnNames.isDeleted: true,
        ColumnNames.archivedAt: FieldValue.serverTimestamp(),
        ColumnNames.updatedAt: FieldValue.serverTimestamp(),
      });
      Log.info('Soft delete pelanggan berhasil: $customerId');
    } on FirebaseException catch (e, s) {
      Log.error('Gagal melakukan soft delete pelanggan: $customerId', e: e, st: s);
      rethrow;
    }
  }
}
