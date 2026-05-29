// path: lib/shared/operasi/firebase_operasi/base_op_firebase.dart

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/firebase_operasi/status_op_firebase.dart';

/// Kelas dasar untuk operasi CRUD umum di Firestore.
///
/// Kelas ini mengabstraksi operasi tulis umum dan secara otomatis
/// memanggil `StatusOpFirebase` untuk memperbarui timestamp global
/// setiap kali ada perubahan data.
class BaseOpFirebase {
  final FirebaseFirestore _firestore;
  final StatusOpFirebase _statusOp;

  /// Konstruktor dengan injeksi dependensi untuk pengujian.
  BaseOpFirebase(
      {final FirebaseFirestore? firestore, final StatusOpFirebase? statusOp})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _statusOp = statusOp ?? StatusOpFirebase(firestore: firestore) {
    Log.info('BaseOpFirebase diinisialisasi.');
  }

  /// Menyisipkan dokumen baru dengan ID yang dibuat otomatis oleh Firestore.
  ///
  /// [collectionName]: Nama koleksi target.
  /// [data]: Map data yang akan disimpan.
  /// Mengembalikan [DocumentReference] dari dokumen yang baru dibuat.
  Future<DocumentReference> add(
    final String collectionName,
    final Map<String, dynamic> data,
  ) async {
    Log.info('Base add: Menambah dokumen baru di $collectionName');
    try {
      final collectionRef = _firestore.collection(collectionName);
      data[ColumnNames.updatedAt] = FieldValue.serverTimestamp();
      final docRef = await collectionRef.add(data);
      _statusOp.updateGlobalStatus();
      Log.info('Base add berhasil: ${docRef.path}');
      return docRef;
    } on FirebaseException catch (e, s) {
      Log.error('Gagal melakukan base add',
          e: e, st: s, data: {'collection': collectionName});
      rethrow;
    }
  }

  /// Menyisipkan dokumen baru ke dalam koleksi.
  ///
  /// [collectionName]: Nama koleksi target.
  /// [docId]: ID dokumen yang akan dibuat.
  /// [data]: Map data yang akan disimpan.
  Future<void> insert(
    final String collectionName,
    final String docId,
    final Map<String, dynamic> data,
  ) async {
    Log.info('Base insert: $collectionName/$docId');
    try {
      final docRef = _firestore.collection(collectionName).doc(docId);
      data[ColumnNames.updatedAt] = FieldValue.serverTimestamp();
      await docRef.set(data);
      unawaited(_statusOp.updateGlobalStatus());
      Log.info('Base insert berhasil: $collectionName/$docId');
    } on FirebaseException catch (e, s) {
      Log.error('Gagal melakukan base insert',
          e: e, st: s, data: {'collection': collectionName, 'docId': docId});
      rethrow;
    }
  }

  /// Memperbarui dokumen yang ada.
  ///
  /// [collectionName]: Nama koleksi target.
  /// [docId]: ID dokumen yang akan diperbarui.
  /// [data]: Map data yang akan diperbarui.
  Future<void> update(
    final String collectionName,
    final String docId,
    final Map<String, dynamic> data,
  ) async {
    Log.info('Base update: $collectionName/$docId');
    try {
      final docRef = _firestore.collection(collectionName).doc(docId);
      data[ColumnNames.updatedAt] = FieldValue.serverTimestamp();
      await docRef.update(data);
      _statusOp.updateGlobalStatus();
      Log.info('Base update berhasil: $collectionName/$docId');
    } on FirebaseException catch (e, s) {
      Log.error('Gagal melakukan base update',
          e: e, st: s, data: {'collection': collectionName, 'docId': docId});
      rethrow;
    }
  }

  /// Melakukan soft delete pada sebuah dokumen.
  ///
  /// Ini akan mengatur `isDeleted` menjadi true dan memperbarui `updatedAt`.
  /// [collectionName]: Nama koleksi target.
  /// [docId]: ID dokumen yang akan di-soft-delete.
  Future<void> softDelete(
      final String collectionName, final String docId) async {
    Log.info('Base softDelete: $collectionName/$docId');
    try {
      final docRef = _firestore.collection(collectionName).doc(docId);
      await docRef.update({
        ColumnNames.isDeleted: true,
        ColumnNames.updatedAt: FieldValue.serverTimestamp(),
        ColumnNames.archivedAt: FieldValue.serverTimestamp(),
      });
      unawaited(_statusOp.updateGlobalStatus());
      Log.info('Base softDelete berhasil: $collectionName/$docId');
    } on FirebaseException catch (e, s) {
      Log.error('Gagal melakukan base softDelete',
          e: e, st: s, data: {'collection': collectionName, 'docId': docId});
      rethrow;
    }
  }

  /// Menghapus dokumen dari Firestore secara permanen.
  ///
  /// [collectionName]: Nama koleksi target.
  /// [docId]: ID dokumen yang akan dihapus.
  Future<void> delete(final String collectionName, final String docId) async {
    Log.warning('Base delete (permanen): $collectionName/$docId');
    try {
      final docRef = _firestore.collection(collectionName).doc(docId);
      await docRef.delete();
      unawaited(_statusOp.updateGlobalStatus());
      Log.info('Base delete (permanen) berhasil: $collectionName/$docId');
    } on FirebaseException catch (e, s) {
      Log.error('Gagal melakukan base delete (permanen)',
          e: e, st: s, data: {'collection': collectionName, 'docId': docId});
      rethrow;
    }
  }

  /// Melakukan soft delete pada semua dokumen di sebuah koleksi.
  ///
  /// Fungsi ini akan mengambil semua dokumen yang belum di-soft-delete
  /// lalu memperbaruinya dalam satu batch.
  /// Mengembalikan jumlah dokumen yang berhasil di-soft-delete.
  Future<int> softDeleteAll(final String collectionName) async {
    Log.info('Base softDeleteAll: Memulai untuk koleksi $collectionName');
    try {
      final querySnapshot = await _firestore
          .collection(collectionName)
          .where(ColumnNames.isDeleted, isEqualTo: false)
          .get();

      if (querySnapshot.docs.isEmpty) {
        Log.info('Base softDeleteAll: Tidak ada dokumen untuk di-soft-delete.');
        return 0;
      }

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {
          ColumnNames.isDeleted: true,
          ColumnNames.archivedAt: FieldValue.serverTimestamp(),
          ColumnNames.updatedAt: FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      unawaited(_statusOp.updateGlobalStatus());

      final count = querySnapshot.docs.length;
      Log.info(
          'Base softDeleteAll berhasil: $count dokumen di $collectionName telah di-soft-delete.');
      return count;
    } on FirebaseException catch (e, s) {
      Log.error('Gagal melakukan base softDeleteAll',
          e: e, st: s, data: {'collection': collectionName});
      rethrow;
    }
  }

  /// Melakukan operasi sisip atau perbarui secara batch (upsert).
  ///
  /// [collectionName]: Nama koleksi target.
  /// [items]: Daftar Map data yang akan diproses.
  /// [idKey]: Kunci di dalam setiap map yang berisi ID dokumen.
  Future<void> insertOrUpdateBatch(
    final String collectionName,
    final List<Map<String, dynamic>> items,
    final String idKey,
  ) async {
    if (items.isEmpty) {
      Log.info('Base insertOrUpdateBatch: Tidak ada item untuk diproses.');
      return;
    }
    Log.info(
        'Base insertOrUpdateBatch: Memulai untuk ${items.length} item di $collectionName');
    try {
      final batch = _firestore.batch();
      for (final item in items) {
        final docId = item[idKey] as String?;
        if (docId != null) {
          final docRef = _firestore.collection(collectionName).doc(docId);
          item[ColumnNames.updatedAt] = FieldValue.serverTimestamp();
          // Menggunakan set dengan merge: true untuk perilaku upsert
          batch.set(docRef, item, SetOptions(merge: true));
        }
      }
      await batch.commit();
      unawaited(_statusOp.updateGlobalStatus());
      Log.info('Base insertOrUpdateBatch berhasil.');
    } on FirebaseException catch (e, s) {
      Log.error('Gagal melakukan base insertOrUpdateBatch',
          e: e, st: s, data: {'collection': collectionName});
      rethrow;
    }
  }
}
