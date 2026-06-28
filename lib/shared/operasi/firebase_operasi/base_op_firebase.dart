// path: lib/shared/operasi/firebase_operasi/base_op_firebase.dart

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/firebase_operasi/status_op_firebase.dart';

class BaseOpFirebase {
  final FirebaseFirestore firestore;
  final StatusOpFirebase _statusOp;

  BaseOpFirebase({
    final FirebaseFirestore? firestore,
    final StatusOpFirebase? statusOp,
  }) : firestore = firestore ?? FirebaseFirestore.instance,
       _statusOp = statusOp ?? StatusOpFirebase(firestore: firestore) {
    Log.info('BaseOpFirebase diinisialisasi.');
  }

  Future<T> _runInTransaction<T>(
    Future<T> Function(Transaction transaction) action,
  ) async {
    Log.info('[FIRESTORE TRANSAKSI DIMULAI] Memulai proses transaksi.');

    try {
      final result = await firestore.runTransaction((transaction) async {
        Log.info('[FIRESTORE TRANSAKSI AKTIF] Blok transaksi dimulai.');

        try {
          final actionResult = await action(transaction);

          Log.info(
            '[FIRESTORE TRANSAKSI AKTIF] Aksi utama berhasil dieksekusi. '
            'Hasil: ${actionResult.runtimeType}',
          );

          Log.info('[FIRESTORE TRANSAKSI AKTIF] Memperbarui status global...');
          await _statusOp.perbaruiStatusGlobal();
          Log.info('[FIRESTORE TRANSAKSI AKTIF] Status global berhasil diperbarui.');

          return actionResult;
        } catch (e, st) {
          Log.error(
            '[FIRESTORE TRANSAKSI GAGAL DI DALAM] Error di dalam blok transaksi.',
            e: e,
            s: st,
          );
          rethrow;
        }
      });

      Log.info('[FIRESTORE TRANSAKSI COMMIT] Transaksi berhasil di-commit.');
      return result;
    } catch (e, st) {
      Log.error(
        '[FIRESTORE TRANSAKSI GAGAL DI LUAR] Gagal memulai atau menyelesaikan transaksi.',
        e: e,
        s: st,
      );
      rethrow;
    }
  }

  Future<T> operasiKompleks<T>(
    Future<T> Function(Transaction txn) customAction,
  ) async {
    Log.info('[FIRESTORE] Mendelegasikan eksekusi transaksi kompleks.');
    return await _runInTransaction(customAction);
  }

  Future<DocumentReference> tambah(
    final String collectionName,
    final Map<String, dynamic> data,
  ) async {
    Log.info('Base add: Menambah dokumen baru di $collectionName');
    try {
      final collectionRef = firestore.collection(collectionName);
      data[NamaKolom.diperbaruiPada] = FieldValue.serverTimestamp();
      final docRef = await collectionRef.add(data);
      unawaited(_statusOp.perbaruiStatusGlobal());
      Log.info('Base add berhasil: ${docRef.path}');
      return docRef;
    } on FirebaseException catch (e, s) {
      Log.error(
        'Gagal melakukan base add',
        e: e,
        s: s,
        data: {'collection': collectionName},
      );
      rethrow;
    }
  }

  Future<void> sisipkan(
    final String collectionName,
    final String docId,
    final Map<String, dynamic> data,
  ) async {
    Log.info('Base insert: $collectionName/$docId');
    try {
      final docRef = firestore.collection(collectionName).doc(docId);
      data[NamaKolom.diperbaruiPada] = FieldValue.serverTimestamp();
      await docRef.set(data);
      unawaited(_statusOp.perbaruiStatusGlobal());
      Log.info('Base insert berhasil: $collectionName/$docId');
    } on FirebaseException catch (e, s) {
      Log.error(
        'Gagal melakukan base insert',
        e: e,
        s: s,
        data: {'collection': collectionName, 'docId': docId},
      );
      rethrow;
    }
  }

  Future<void> update(
    final String collectionName,
    final String docId,
    final Map<String, dynamic> data,
  ) async {
    Log.info('Base update: $collectionName/$docId');
    try {
      final docRef = firestore.collection(collectionName).doc(docId);
      data[NamaKolom.diperbaruiPada] = FieldValue.serverTimestamp();
      await docRef.update(data);
      unawaited(_statusOp.perbaruiStatusGlobal());
      Log.info('Base update berhasil: $collectionName/$docId');
    } on FirebaseException catch (e, s) {
      Log.error(
        'Gagal melakukan base update',
        e: e,
        s: s,
        data: {'collection': collectionName, 'docId': docId},
      );
      rethrow;
    }
  }

  Future<void> softDelete(String collectionName, String docId) async {
    Log.info('Base softDelete: $collectionName/$docId');
    try {
      final docRef = firestore.collection(collectionName).doc(docId);
      await docRef.update({
        NamaKolom.dihapus: true,
        NamaKolom.diperbaruiPada: FieldValue.serverTimestamp(),
        NamaKolom.diarsipkanPada: FieldValue.serverTimestamp(),
      });
      unawaited(_statusOp.perbaruiStatusGlobal());
      Log.info('Base softDelete berhasil: $collectionName/$docId');
    } on FirebaseException catch (e, s) {
      Log.error(
        'Gagal melakukan base softDelete',
        e: e,
        s: s,
        data: {'collection': collectionName, 'docId': docId},
      );
      rethrow;
    }
  }

  Future<void> hapusPermanen(
    final String collectionName,
    final String docId,
  ) async {
    Log.warning('Base delete (permanen): $collectionName/$docId');
    try {
      final docRef = firestore.collection(collectionName).doc(docId);
      await docRef.delete();
      unawaited(_statusOp.perbaruiStatusGlobal());
      Log.info('Base delete (permanen) berhasil: $collectionName/$docId');
    } on FirebaseException catch (e, s) {
      Log.error(
        'Gagal melakukan base delete (permanen)',
        e: e,
        s: s,
        data: {'collection': collectionName, 'docId': docId},
      );
      rethrow;
    }
  }

  Future<int> hapusSementaraSemua(final String collectionName) async {
    Log.info('Base softDeleteAll: Memulai untuk koleksi $collectionName');
    try {
      final querySnapshot = await firestore
          .collection(collectionName)
          .where(NamaKolom.dihapus, isEqualTo: false)
          .get();

      if (querySnapshot.docs.isEmpty) {
        Log.info('Base softDeleteAll: Tidak ada dokumen untuk di-soft-delete.');
        return 0;
      }

      final batch = firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {
          NamaKolom.dihapus: true,
          NamaKolom.diarsipkanPada: FieldValue.serverTimestamp(),
          NamaKolom.diperbaruiPada: FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      unawaited(_statusOp.perbaruiStatusGlobal());

      final count = querySnapshot.docs.length;
      Log.info(
        'Base softDeleteAll berhasil: $count dokumen di $collectionName telah di-soft-delete.',
      );
      return count;
    } on FirebaseException catch (e, s) {
      Log.error(
        'Gagal melakukan base softDeleteAll',
        e: e,
        s: s,
        data: {'collection': collectionName},
      );
      rethrow;
    }
  }

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
      'Base insertOrUpdateBatch: Memulai untuk ${items.length} item di $collectionName',
    );
    try {
      final batch = firestore.batch();
      for (final item in items) {
        final docId = item[idKey] as String?;
        if (docId != null) {
          final docRef = firestore.collection(collectionName).doc(docId);
          item[NamaKolom.diperbaruiPada] = FieldValue.serverTimestamp();
          batch.set(docRef, item, SetOptions(merge: true));
        }
      }
      await batch.commit();
      unawaited(_statusOp.perbaruiStatusGlobal());
      Log.info('Base insertOrUpdateBatch berhasil.');
    } on FirebaseException catch (e, s) {
      Log.error(
        'Gagal melakukan base insertOrUpdateBatch',
        e: e,
        s: s,
        data: {'collection': collectionName},
      );
      rethrow;
    }
  }
}