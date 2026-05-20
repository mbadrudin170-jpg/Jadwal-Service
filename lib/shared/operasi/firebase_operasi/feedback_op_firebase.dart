// path: lib/shared/operasi/firebase_operasi/feedback_op_firebase.dart
// Fitur: Logika Bisnis untuk Kritik dan Saran (GLOBAL - Firebase)
// Tujuan: Memisahkan operasi data (CRUD) dari UI, mengelola semua interaksi
//          dengan Firestore untuk koleksi feedback.
//          Digunakan oleh sisi admin maupun user.
// diubah: Menggunakan TableNameValue dan ColumnNames untuk semua referensi
//         koleksi dan kolom.
// diperbaiki: Menambahkan logging dan error handling yang konsisten.
// diubah: Mengubah deleteFeedback menjadi penghapusan permanen (hard delete).
// ditambahkan: Fungsi softDeleteFeedback untuk menandai feedback sebagai terhapus.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/model/feedback_model.dart';

// === INFORMASI DEPENDENCY ===
// 📂 FILE INI DIGUNAKAN OLEH:
//   - Admin: Halaman manajemen kritik saran
//   - User: Halaman pengiriman kritik saran
//
// 📂 FILE INI MENGGUNAKAN:
//   - lib/shared/model/feedback_model.dart (FeedbackModel)
//   - lib/shared/constant/column_names.dart (ColumnNames)
//   - lib/shared/constant/table_name_value.dart (TableNameValue)

/// Kelas untuk mengelola operasi CRUD (Create, Read, Update, Delete)
/// terkait data feedback di Firestore.
class FeedbackOpFirebase {
  /// Instance Firestore yang akan digunakan. Dapat diganti saat pengujian.
  final FirebaseFirestore firestore;

  /// Konstruktor untuk membuat instance [FeedbackOpFirebase].
  FeedbackOpFirebase(this.firestore) {
    Log.info('FeedbackOpFirebase diinisialisasi.');
  }

  /// Mendapatkan referensi ke koleksi feedback.
  CollectionReference get _collection =>
      firestore.collection(TableNameValue.get(TableName.feedback));

  /// Menyimpan [feedback] baru ke Firestore.
  Future<void> createFeedback(final FeedbackModel feedback) async {
    Log.info('Menyimpan feedback baru...');
    try {
      await _collection.add(feedback.toFirebase());
      Log.info('Feedback berhasil disimpan.');
    } on FirebaseException catch (e, s) {
      Log.error('Gagal menyimpan feedback.', e: e, st: s);
      rethrow;
    }
  }

  /// Membaca semua feedback oleh pengguna tertentu.
  Stream<List<FeedbackModel>> getFeedbacksByUser(final String userId) {
    Log.info('Memuat feedback untuk userId: $userId');
    return _collection
        .where(ColumnNames.userId, isEqualTo: userId)
        .orderBy(ColumnNames.updatedAt, descending: true)
        .snapshots()
        .map((final snapshot) {
      final feedbacks = snapshot.docs.map((final doc) {
        return FeedbackModel.fromFirebase(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
      Log.info('Ditemukan ${feedbacks.length} feedback.');
      return feedbacks;
    })
        .handleError((final Object e, final StackTrace s) {
      Log.error('Error pada stream feedback untuk: $userId', e: e, st: s);
    });
  }

  /// Memperbarui isi feedback.
  Future<void> updateFeedback(
    final String docId,
    final String newContent,
  ) async {
    Log.info('Memperbarui feedback: $docId');
    try {
      await _collection.doc(docId).update({
        ColumnNames.content: newContent,
        ColumnNames.updatedAt: FieldValue.serverTimestamp(),
      });
      Log.info('Feedback berhasil diperbarui.');
    } on FirebaseException catch (e, s) {
      Log.error('Gagal memperbarui feedback: $docId', e: e, st: s);
      rethrow;
    }
  }

  /// Menghapus feedback secara permanen dari Firestore.
  Future<void> deleteFeedback(final String docId) async {
    Log.warning('Memulai penghapusan permanen feedback di Firestore: $docId');
    try {
      await _collection.doc(docId).delete();
      Log.info('Penghapusan permanen feedback berhasil: $docId');
    } on FirebaseException catch (e, s) {
      Log.error('Gagal menghapus feedback secara permanen: $docId', e: e, st: s);
      rethrow;
    }
  }

  /// Melakukan soft delete pada feedback di Firestore.
  Future<void> softDeleteFeedback(final String docId) async {
    Log.info('Memulai soft delete feedback di Firestore: $docId');
    try {
      await _collection.doc(docId).update({
        ColumnNames.isDeleted: true,
        ColumnNames.archivedAt: FieldValue.serverTimestamp(),
        ColumnNames.updatedAt: FieldValue.serverTimestamp(),
      });
      Log.info('Soft delete feedback berhasil: $docId');
    } on FirebaseException catch (e, s) {
      Log.error('Gagal melakukan soft delete feedback: $docId', e: e, st: s);
      rethrow;
    }
  }
}
