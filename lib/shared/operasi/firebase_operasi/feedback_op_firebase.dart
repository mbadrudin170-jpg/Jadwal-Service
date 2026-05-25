// path: lib/shared/operasi/firebase_operasi/feedback_op_firebase.dart
// direfaktor: Menggunakan BaseOpFirebase untuk semua operasi tulis.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/model/feedback_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/base_op_firebase.dart';

/// Kelas untuk mengelola operasi CRUD terkait data feedback di Firestore.
class FeedbackOpFirebase {
  final FirebaseFirestore _firestore;
  final BaseOpFirebase _baseOp;
  final String _collectionName = TableNameValue.get(TableName.feedback);

  /// Konstruktor untuk inisialisasi.
  FeedbackOpFirebase({FirebaseFirestore? firestore, BaseOpFirebase? baseOp})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _baseOp = baseOp ?? BaseOpFirebase(firestore: firestore) {
    Log.info('FeedbackOpFirebase diinisialisasi.');
  }

  /// Referensi ke koleksi feedback.
  CollectionReference get _collection => _firestore.collection(_collectionName);

  /// Menyimpan feedback baru dengan ID otomatis dari Firestore.
  Future<void> createFeedback(final FeedbackModel feedback) async {
    Log.info('Mendelegasikan pembuatan feedback baru...');
    // Menggunakan base.add() yang tidak memerlukan ID di awal
    await _baseOp.add(_collectionName, feedback.toFirebase());
  }

  /// Memperbarui isi feedback.
  Future<void> updateFeedback(
    final String docId,
    final String newContent,
  ) async {
    Log.info('Mendelegasikan pembaruan feedback: $docId');
    await _baseOp.update(_collectionName, docId, {
      ColumnNames.content: newContent,
    });
  }

  /// Menghapus feedback secara permanen dari Firestore.
  Future<void> deleteFeedback(final String docId) async {
    Log.warning('Mendelegasikan penghapusan permanen feedback: $docId');
    await _baseOp.delete(_collectionName, docId);
  }

  /// Melakukan soft delete pada feedback di Firestore.
  Future<void> softDeleteFeedback(final String docId) async {
    Log.info('Mendelegasikan soft delete feedback: $docId');
    await _baseOp.softDelete(_collectionName, docId);
  }

  // =======================================================================
  // OPERASI BACA (Tidak didelegasikan karena spesifik untuk model)
  // =======================================================================

  /// Membaca semua feedback oleh pengguna tertentu.
  Stream<List<FeedbackModel>> getFeedbacksByUser(final String userId) {
    Log.info('Memuat feedback untuk userId: $userId');
    return _collection
        .where(ColumnNames.userId, isEqualTo: userId)
        .orderBy(ColumnNames.updatedAt, descending: true)
        .snapshots()
        .map((final snapshot) {
      return snapshot.docs.map((final doc) {
        return FeedbackModel.fromFirebase(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    }).handleError((final Object e, final StackTrace s) {
      Log.error('Error pada stream feedback untuk: $userId', e: e, st: s);
    });
  }
}
