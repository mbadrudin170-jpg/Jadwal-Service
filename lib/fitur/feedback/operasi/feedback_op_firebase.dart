// path: lib/fitur/feedback/operasi/feedback_op_firebase.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/fitur/feedback/model/feedback_model.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/operasi/firebase_operasi/base_op_firebase.dart';

/// Kelas untuk mengelola operasi CRUD terkait data feedback di Firestore.
class FeedbackOpFirebase {
  final FirebaseFirestore _firestore;
  final BaseOpFirebase _baseOp;
  final String _collectionName = TableNameValue.get(TableName.feedback);

  /// Konstruktor untuk inisialisasi.
  FeedbackOpFirebase({
    required FirebaseFirestore firestore,
    required BaseOpFirebase baseOp,
  })  : _firestore = firestore,
        _baseOp = baseOp {
    Log.info('FeedbackOpFirebase diinisialisasi.');
  }

  /// Referensi ke koleksi feedback.
  CollectionReference get _collection => _firestore.collection(_collectionName);

  /// Menyimpan feedback baru dengan ID otomatis dari Firestore.
  Future<void> create(FeedbackModel feedback) async {
    Log.info('Mendelegasikan pembuatan feedback baru...');

    // 1. Ambil data dasar dari model
    final data = feedback.toFirebase();
    data[ColumnNames.date] = FieldValue.serverTimestamp();
    await _baseOp.add(_collectionName, data);
  }

  /// Memperbarui isi feedback.
  Future<void> update(String docId, String newContent) async {
    Log.info('Mendelegasikan pembaruan feedback: $docId');
    await _baseOp.update(_collectionName, docId, {
      ColumnNames.content: newContent,
    });
  }

  /// Menghapus feedback secara permanen dari Firestore.
  Future<void> delete(final String docId) async {
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
  Stream<List<FeedbackModel>> getByUser(String userId) {
    Log.info('Memuat feedback untuk userId: $userId');
    return _collection
        .where(ColumnNames.userId, isEqualTo: userId)
        .where(ColumnNames.isDeleted, isEqualTo: false)
        .orderBy(ColumnNames.date, descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return FeedbackModel.fromFirebase(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    }).handleError((e, StackTrace s) {
      Log.error('Error pada stream feedback untuk: $userId', e: e, st: s);
    });
  }
}
