// path: lib/shared/operasi/firebase_operasi/feedback_op_firebase.dart
// Fitur: Logika Bisnis untuk Kritik dan Saran (GLOBAL - Firebase)
// Tujuan: Memisahkan operasi data (CRUD) dari UI, mengelola semua interaksi
//          dengan Firestore untuk koleksi kritik_saran.
//          Digunakan oleh sisi admin maupun user.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/feedback_model.dart';

// === INFORMASI DEPENDENCY ===
// 📂 FILE INI DIGUNAKAN OLEH:
//   - Admin: Halaman manajemen kritik saran
//   - User: Halaman pengiriman kritik saran
//
// 📂 FILE INI MENGGUNAKAN:
//   - lib/shared/model/feedback_model.dart (FeedbackModel)

/// Kelas untuk mengelola operasi CRUD (Create, Read, Update, Delete)
/// terkait data kritik dan saran di Firestore.
class FeedbackOpFirebase {
  /// Instance Firestore yang akan digunakan. Dapat diganti saat pengujian.
  final FirebaseFirestore firestore;

  /// Konstruktor untuk membuat instance [FeedbackOpFirebase].
  /// Membutuhkan instance [FeedbackOpFirebase].
  FeedbackOpFirebase(this.firestore);

  /// Mendapatkan referensi ke koleksi 'kritik_saran'.
  CollectionReference get _feedbackCollection =>
      firestore.collection('kritik_saran');

  /// Menyimpan [feedback] baru ke Firestore.
  ///
  /// Melemparkan [Exception] jika terjadi kegagalan.
  Future<void> createFeedback(final FeedbackModel feedback) async {
    Log.info('[FeedbackOpFirebase] Menyimpan kritik saran baru...');
    try {
      await _feedbackCollection.add(feedback.toFirebase());
      Log.info('[FeedbackOpFirebase] Kritik saran berhasil disimpan.');
    } catch (e) {
      Log.error('[FeedbackOpFirebase] Gagal menyimpan kritik saran.', e: e);
      throw Exception('Gagal membuat kritik dan saran: $e');
    }
  }

  /// Membaca semua kritik dan saran yang dikirim oleh pengguna tertentu.
  ///
  /// Mengembalikan [Stream] dari daftar [FeedbackModel] yang diurutkan
  /// berdasarkan tanggal pembaruan terbaru.
  Stream<List<FeedbackModel>> getFeedbacksByUser(final String userId) {
    Log.info(
      '[FeedbackOpFirebase] Memuat kritik saran untuk userId: $userId',
    );
    return _feedbackCollection
        .where('userId', isEqualTo: userId)
        .orderBy('diperbarui', descending: true)
        .snapshots()
        .map((final snapshot) {
      final feedbacks = snapshot.docs.map((final doc) {
        return FeedbackModel.fromFirebase(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
      Log.info(
        '[FeedbackOpFirebase] Ditemukan ${feedbacks.length} kritik saran.',
      );
      return feedbacks;
    });
  }

  /// Memperbarui isi dari kritik dan saran yang sudah ada.
  ///
  /// [docId] adalah ID dokumen yang akan diperbarui.
  /// [newContent] adalah konten baru dari kritik atau saran.
  Future<void> updateFeedback(
    final String docId,
    final String newContent,
  ) async {
    Log.info('[FeedbackOpFirebase] Memperbarui kritik saran: $docId');
    try {
      final dataToUpdate = {
        'isi': newContent,
        'diperbarui': FieldValue.serverTimestamp(),
      };
      await _feedbackCollection.doc(docId).update(dataToUpdate);
      Log.info('[FeedbackOpFirebase] Kritik saran berhasil diperbarui.');
    } catch (e) {
      Log.error(
        '[FeedbackOpFirebase] Gagal memperbarui kritik saran.',
        e: e,
      );
      throw Exception('Gagal memperbarui kritik dan saran: $e');
    }
  }

  // TODO: rencana selanjutnya adalah merubah hapus kritik saran menjadi soft
  //       delete dengan mengubah isDeleted menjadi true dan memperbarui kolom
  //       archivedAt ke timestamp saat ini.
  /// Menghapus kritik dan saran dari Firestore berdasarkan [docId].
  Future<void> deleteFeedback(final String docId) async {
    Log.info('[FeedbackOpFirebase] Menghapus kritik saran: $docId');
    try {
      await _feedbackCollection.doc(docId).delete();
      Log.info('[FeedbackOpFirebase] Kritik saran berhasil dihapus.');
    } catch (e) {
      Log.error('[FeedbackOpFirebase] Gagal menghapus kritik saran.', e: e);
      throw Exception('Gagal menghapus kritik dan saran: $e');
    }
  }
}
