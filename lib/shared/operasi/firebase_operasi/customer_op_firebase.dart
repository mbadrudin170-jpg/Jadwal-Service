// path: lib/shared/operasi/firebase_operasi/customer_op_firebase.dart
// direfaktor total: Semua operasi tulis (create, update, delete, soft delete)
//                 sekarang sepenuhnya didelegasikan ke BaseOpFirebase.

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/operasi/firebase_operasi/base_op_firebase.dart';

/// Kelas ini menangani semua operasi terkait data pelanggan di Firestore.
/// Bertindak sebagai lapisan "intent" yang mendelegasikan implementasi
/// ke BaseOpFirebase.
class CustomerOpFirebase {
  final FirebaseFirestore _firestore;
  final BaseOpFirebase _baseOp;
  final String _collectionName = TableNameValue.get(TableName.customer);

  /// Konstruktor untuk inisialisasi.
  CustomerOpFirebase({
    required FirebaseFirestore firestore,
    required BaseOpFirebase baseOp,
  })  : _firestore = firestore,
        _baseOp = baseOp {
    Log.info('CustomerOpFirebase diinisialisasi.');
  }

  /// Referensi ke koleksi pelanggan.
  CollectionReference get _customerCollection =>
      _firestore.collection(_collectionName);

  /// Membuat pelanggan baru di Firestore.
  Future<void> addCustomer(CustomerModel customer) async {
    Log.info('Mendelegasikan pembuatan pelanggan: ${customer.id}');
    await _baseOp.insert(
      _collectionName,
      customer.id,
      customer.toFirebase(),
    );
  }

  /// Memperbarui data pelanggan yang ada di Firestore.
  Future<void> updateCustomer(final CustomerModel customer) async {
    Log.info('Mendelegasikan pembaruan pelanggan: ${customer.id}');
    await _baseOp.update(
      _collectionName,
      customer.id,
      customer.toFirebase(),
    );
  }

  /// Melakukan soft delete pada pelanggan di Firestore.
  Future<void> softDeleteCustomer(final String customerId) async {
    Log.info('Mendelegasikan soft delete pelanggan: $customerId');
    await _baseOp.softDelete(_collectionName, customerId);
  }

  /// Menghapus pelanggan dari Firestore secara permanen.
  /// PERHATIAN: Operasi ini tidak bisa dibatalkan!
  Future<void> deleteCustomer(final String customerId) async {
    Log.warning('Mendelegasikan penghapusan permanen pelanggan: $customerId');
    await _baseOp.delete(_collectionName, customerId);
  }

  /// Memperbarui waktu terakhir pengguna aktif.
  Future<void> updateLastActive(String customerId) async {
    Log.info('Mendelegasikan update last active untuk: $customerId');
    await _baseOp.update(_collectionName, customerId, {
      ColumnNames.lastActiveAt: FieldValue.serverTimestamp(),
    });
  }

  /// Menyimpan atau memperbarui token FCM pengguna.
  Future<void> saveFcmToken(final String userId, final String? token) async {
    if (token == null || token.isEmpty) {
      Log.warning('Token FCM kosong, penyimpanan dibatalkan.');
      return;
    }
    Log.info('Mendelegasikan penyimpanan token FCM untuk: $userId');
    await _baseOp.update(_collectionName, userId, {'fcmToken': token});
  }

  // =======================================================================
  // OPERASI BACA (Tidak didelegasikan karena spesifik untuk model)
  // =======================================================================

  /// Mengambil semua data pelanggan yang tidak di-soft-delete.
  Future<List<CustomerModel>> getAllCustomers() async {
    Log.info('Mengambil semua pelanggan aktif...');
    try {
      final querySnapshot = await _customerCollection
          .where(ColumnNames.isDeleted, isEqualTo: false)
          .get();

      if (querySnapshot.docs.isEmpty) {
        Log.warning('Tidak ada pelanggan aktif yang ditemukan.');
        return [];
      }

      final customers = querySnapshot.docs.map((doc) {
        return CustomerModel.fromFirebase(
          doc.id,
          doc.data()! as Map<String, dynamic>,
        );
      }).toList();

      Log.info('Berhasil mengambil ${customers.length} pelanggan.');
      return customers;
    } on Exception catch (e, s) {
      Log.error('Gagal mengambil semua pelanggan', e: e, st: s);
      return []; // Kembalikan list kosong jika terjadi error
    }
  }

  /// Mengambil data pelanggan secara real-time (stream).
  Stream<CustomerModel?> getCustomerStream(final String userId) {
    Log.info('Streaming data pelanggan untuk: $userId');
    return _customerCollection.doc(userId).snapshots().map((final snapshot) {
      if (snapshot.exists) {
        return CustomerModel.fromFirebase(
          snapshot.id,
          snapshot.data()! as Map<String, dynamic>,
        );
      }
      return null;
    }).handleError((e, StackTrace s) {
      Log.error('Error pada stream pelanggan untuk: $userId', e: e, st: s);
    });
  }

  /// Mengambil data pelanggan sekali (one-time fetch).
  Future<CustomerModel?> ambilBerdasarkanId(String userId) async {
    try {
      final doc = await _customerCollection.doc(userId).get();
      if (doc.exists) {
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
}
