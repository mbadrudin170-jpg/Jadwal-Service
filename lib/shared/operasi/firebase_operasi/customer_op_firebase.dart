// path: lib/shared/operasi/firebase_operasi/customer_op_firebase.dart

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/customer_model.dart';

/// Kelas ini menangani semua operasi terkait data pelanggan di Firestore.
class CustomerOpFirebase {
  final CollectionReference _customerCollection;

  /// Konstruktor untuk inisialisasi dengan instance FirebaseFirestore.
  /// Memungkinkan injeksi instance palsu untuk pengujian.
  CustomerOpFirebase({final FirebaseFirestore? firestore})
      : _customerCollection =
            (firestore ?? FirebaseFirestore.instance).collection('pelanggan');

  /// Memperbarui data pelanggan yang ada di Firestore berdasarkan ID-nya.
  ///
  /// [customer]: Objek [CustomerModel] yang berisi data baru.
  /// ID dari objek ini akan digunakan untuk menemukan dokumen yang akan diperbarui.
  Future<void> updateCustomer(final CustomerModel customer) async {
    Log.info(
      'Memulai pembaruan data pelanggan di Firestore untuk ID: ${customer.id}',
    );
    try {
      final dataToUpdate = customer.toFirebase()
        ..['diperbarui'] = FieldValue.serverTimestamp();

      await _customerCollection.doc(customer.id).update(dataToUpdate);

      Log.info(
        'Pembaruan data pelanggan di Firestore untuk ID: ${customer.id} berhasil.',
      );
    } on FirebaseException catch (e, s) {
      Log.error(
        'Gagal memperbarui data pelanggan di Firestore untuk ID: ${customer.id}',
        e: e,
        st: s,
      );
      rethrow;
    }
  }

  /// Mengambil data pelanggan secara real-time (stream) berdasarkan ID pengguna.
  Stream<CustomerModel?> getCustomerStream(final String userId) {
    Log.info('Streaming data pelanggan untuk: $userId');
    return _customerCollection.doc(userId).snapshots().map((final snapshot) {
      if (snapshot.exists) {
        Log.info('Data pelanggan stream diperbarui untuk ID: $userId');
        return CustomerModel.fromFirebase(
          snapshot.id,
          snapshot.data()! as Map<String, dynamic>,
        );
      } else {
        Log.warning('Pelanggan dengan ID $userId tidak ditemukan di stream.');
        return null;
      }
    });
  }

  /// Mengambil data pelanggan sekali (one-time fetch) berdasarkan ID pengguna.
  Future<CustomerModel?> getCustomerOnce(final String userId) async {
    try {
      Log.info('Mengambil data pelanggan sekali untuk ID: $userId');
      final doc = await _customerCollection.doc(userId).get();
      if (doc.exists) {
        Log.info('Pelanggan ditemukan', doc.data());
        return CustomerModel.fromFirebase(
          doc.id,
          doc.data()! as Map<String, dynamic>,
        );
      }
      Log.warning('Pelanggan dengan ID $userId tidak ditemukan.');
      return null;
    } on Exception catch (e, s) {
      Log.error(
        'Error mengambil pelanggan sekali: $e',
        e: e,
        st: s,
      );
      return null;
    }
  }

  /// Menyimpan atau memperbarui token FCM (Firebase Cloud Messaging) pengguna.
  Future<void> saveFcmToken(final String userId, final String? token) async {
    if (token == null || token.isEmpty) {
      Log.warning('Token FCM null atau kosong, proses penyimpanan dibatalkan.');
      return;
    }

    Log.info('Menyimpan token FCM untuk pengguna: $userId');
    try {
      await _customerCollection.doc(userId).update({'fcmToken': token});
      Log.info('Token FCM berhasil disimpan ke Firestore.');
    } on Exception catch (e, s) {
      Log.error(
        'Gagal menyimpan token FCM ke Firestore untuk pengguna $userId',
        e: e,
        st: s,
      );
    }
  }
}
