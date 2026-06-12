// path: lib/shared/operasi/firebase_operasi/active_customer_op_firebase.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/base_op_firebase.dart';

/// Kelas operasi untuk mengelola data pelanggan aktif dari Firebase.
/// Koleksi ini berfungsi sebagai cache atau ringkasan untuk mempermudah
/// dan mempercepat query data pelanggan yang sedang aktif berlangganan.
class ActiveCustomerOpFirebase extends BaseOpFirebase {
  final FirebaseFirestore _firestore;

  /// Konstruktor untuk inisialisasi dengan instance FirebaseFirestore.
  ActiveCustomerOpFirebase({super.firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance {
    Log.info('ActiveCustomerOpFirebase diinisialisasi.');
  }

  /// Mendapatkan referensi ke koleksi active_customers.
  CollectionReference get _collection =>
      _firestore.collection(NamaTabel.activeCustomer); // Diperbaiki: Menggunakan properti statis NamaTabel

  /// Menambah atau memperbarui data pelanggan aktif.
  /// Fungsi ini menggunakan ID pelanggan sebagai ID dokumen untuk memastikan
  /// setiap pelanggan hanya memiliki satu entri di koleksi active_customers.
  Future<void> setActiveCustomer(
      final ActiveCustomerModel activeCustomer) async {
    Log.info(
        'Menambah/memperbarui pelanggan aktif: ${activeCustomer.customerId}');
    try {
      // ID dokumen di koleksi active_customers adalah ID pelanggan itu sendiri.
      await sisipkan(
        NamaTabel.activeCustomer, // Diperbaiki: Menggunakan properti statis NamaTabel
        activeCustomer.customerId,
        activeCustomer.toFirebase(),
      );
      Log.info(
          'Berhasil menambah/memperbarui pelanggan aktif: ${activeCustomer.customerId}');
    } on FirebaseException catch (e, s) {
      Log.error(
          'Gagal menambah/memperbarui pelanggan aktif: ${activeCustomer.customerId}',
          e: e,
          st: s);
      rethrow;
    }
  }

  /// Mengambil data pelanggan aktif berdasarkan ID pelanggan dari Firebase.
  ///
  /// Mengembalikan [ActiveCustomerModel] jika ditemukan, jika tidak `null`.
  Future<ActiveCustomerModel?> getActiveCustomersById(
    final String customerId,
  ) async {
    try {
      final doc = await _collection.doc(customerId).get();

      if (!doc.exists) {
        Log.warning(
            'Tidak ada data pelanggan aktif ditemukan untuk ID: $customerId');
        return null;
      }

      final data = doc.data() as Map<String, dynamic>;
      Log.info('Data pelanggan aktif ditemukan untuk ID: $customerId');
      return ActiveCustomerModel.fromFirebase(doc.id, data);
    } on Exception catch (e, s) {
      Log.error('Error mengambil data pelanggan aktif untuk ID: $customerId',
          e: e, st: s);
      return null;
    }
  }

  /// Menghapus data pelanggan aktif, biasanya ketika langganan berakhir.
  Future<void> deleteActiveCustomer(final String customerId) async {
    Log.warning('Memulai penghapusan pelanggan aktif: $customerId');
    try {
      // Menggunakan fungsi delete dari BaseOpFirebase
      await hapusPermanen(NamaTabel.activeCustomer, customerId); // Diperbaiki: Menggunakan properti statis NamaTabel
      Log.info('Berhasil menghapus pelanggan aktif: $customerId');
    } on FirebaseException catch (e, s) {
      Log.error('Gagal menghapus pelanggan aktif: $customerId', e: e, st: s);
      rethrow;
    }
  }
}
