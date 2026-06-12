// path: lib/fitur/feedback/operasi/feedback_op_firebase.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/fitur/feedback/model/feedback_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/firebase_operasi/base_op_firebase.dart';

/// Kelas untuk mengelola operasi CRUD terkait data feedback di Firestore.
class FeedbackOpFirebase {
  final FirebaseFirestore _firestore;
  final BaseOpFirebase _baseOp;
  final String _collectionName = NamaTabel.feedback;

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
    data[NamaKolom.date] = FieldValue.serverTimestamp();
    await _baseOp.tambah(_collectionName, data);
  }

  /// Memperbarui isi feedback.
  Future<void> update(String docId, String newContent) async {
    Log.info('Mendelegasikan pembaruan feedback: $docId');
    await _baseOp.update(_collectionName, docId, {
      NamaKolom.content: newContent,
    });
  }

  /// Menghapus feedback secara permanen dari Firestore.
  Future<void> delete(final String docId) async {
    Log.warning('Mendelegasikan penghapusan permanen feedback: $docId');
    await _baseOp.hapusPermanen(_collectionName, docId);
  }

  /// Melakukan soft delete pada feedback di Firestore.
  Future<void> softDeleteFeedback(final String docId) async {
    Log.info('Mendelegasikan soft delete feedback: $docId');
    await _baseOp.hapusSementara(_collectionName, docId);
  }

  // =======================================================================
  // OPERASI BACA (Tidak didelegasikan karena spesifik untuk model)
  // =======================================================================

  /// Membaca semua feedback oleh pengguna tertentu.
  Stream<List<FeedbackModel>> getByUser(String userId) {
    Log.info('Memuat feedback untuk userId: $userId');
    return _collection
        .where(NamaKolom.userId, isEqualTo: userId)
        .where(NamaKolom.isDeleted, isEqualTo: false)
        .orderBy(NamaKolom.date, descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return FeedbackModel.fromFirebase(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    }).handleError((Object e, StackTrace s) {
      Log.error('Error pada stream feedback untuk: $userId', e: e, s: s);
    });
  }
}
