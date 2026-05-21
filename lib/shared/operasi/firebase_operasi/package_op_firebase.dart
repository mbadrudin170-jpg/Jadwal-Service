// path: lib/shared/operasi/firebase_operasi/package_op_firebase.dart
// diubah: Menambahkan getPublicPackages dan memperbaiki konstruktor.
// diperbaiki: Menambahkan logging inisialisasi dan filter isDeleted.
// ditambahkan: Fungsi deletePackage untuk menghapus paket secara permanen.
// ditambahkan: Fungsi softDeletePackage untuk menandai paket sebagai terhapus.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/model/package_model.dart';

/// Kelas untuk mengelola operasi terkait data paket di Firestore.
class PackageOpFirebase {
  /// Instance dari [FirebaseFirestore] untuk berinteraksi dengan database.
  final FirebaseFirestore db;

  /// Konstruktor untuk PackageOpFirebase.
  PackageOpFirebase({final FirebaseFirestore? firestore})
      : db = firestore ?? FirebaseFirestore.instance {
    Log.info('PackageOpFirebase diinisialisasi.');
  }

  /// Mendapatkan referensi ke koleksi package.
  CollectionReference get _collection =>
      db.collection(TableNameValue.get(TableName.package));

  /// Mengambil paket publik yang bisa ditukar dengan poin.
  Future<List<PackageModel>> getPublicPackages() async {
    try {
      Log.info('Mengambil paket publik untuk penukaran poin.');
      final querySnapshot = await _collection
          .where(ColumnNames.isPublic, isEqualTo: true)
          .where(ColumnNames.redemptionPoints, isGreaterThan: 0)
          .where(ColumnNames.isDeleted, isEqualTo: false)
          .get();
      Log.info(
          'Menemukan ${querySnapshot.docs.length} paket publik yang tidak dihapus.');
      return querySnapshot.docs.map((final doc) {
        final data = doc.data() as Map<String, dynamic>;
        return PackageModel.fromFirebase(doc.id, data);
      }).toList();
    } on Exception catch (e, s) {
      Log.error('Error mengambil paket publik: $e', e: e, st: s);
      return [];
    }
  }

  /// Mengambil model [PackageModel] lengkap berdasarkan ID paket.
  Future<PackageModel?> getPackageById(final String packageId) async {
    try {
      Log.info('Mengambil model paket untuk ID: $packageId');
      final doc = await _collection.doc(packageId).get();
      if (doc.exists) {
        final data = doc.data()! as Map<String, dynamic>;
        final package = PackageModel.fromFirebase(doc.id, data);
        Log.info('Model paket ditemukan');
        return package;
      }
      Log.warning('Paket dengan ID $packageId tidak ditemukan.');
      return null;
    } on Exception catch (e, s) {
      Log.error('Error mengambil model paket: $e', e: e, st: s);
      return null;
    }
  }

  /// Menghapus paket dari Firestore secara permanen.
  Future<void> deletePackage(final String packageId) async {
    Log.warning('Memulai penghapusan permanen paket di Firestore: $packageId');
    try {
      await _collection.doc(packageId).delete();
      Log.info('Penghapusan permanen paket berhasil: $packageId');
    } on FirebaseException catch (e, s) {
      Log.error('Gagal menghapus paket secara permanen: $packageId',
          e: e, st: s);
      rethrow;
    }
  }

  /// Melakukan soft delete pada paket di Firestore.
  Future<void> softDeletePackage(final String packageId) async {
    Log.info('Memulai soft delete paket di Firestore: $packageId');
    try {
      await _collection.doc(packageId).update({
        ColumnNames.isDeleted: true,
        ColumnNames.archivedAt: FieldValue.serverTimestamp(),
        ColumnNames.updatedAt: FieldValue.serverTimestamp(),
      });
      Log.info('Soft delete paket berhasil: $packageId');
    } on FirebaseException catch (e, s) {
      Log.error('Gagal melakukan soft delete paket: $packageId', e: e, st: s);
      rethrow;
    }
  }
}
