// path: lib/fitur/feedback/operasi/feedback_op_firebase.dart

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/fitur/feedback/model/feedback_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/firebase_operasi/base_op_firebase.dart';

/// Kelas untuk mengelola operasi CRUD terkait data feedback di Firestore.
class FeedbackOpFirebase {
  final FirebaseFirestore _firestore;
  final BaseOpFirebase _baseOpFirebase;
  final String _namaKoleksi = NamaTabel.feedback;

  /// Konstruktor untuk inisialisasi.
  FeedbackOpFirebase({
    required FirebaseFirestore firestore,
    required BaseOpFirebase baseOpFirebase,
  })  : _firestore = firestore,
        _baseOpFirebase = baseOpFirebase {
    Log.info('FeedbackOpFirebase diinisialisasi.');
  }

  /// Referensi ke koleksi feedback.
  CollectionReference get _koleksi => _firestore.collection(_namaKoleksi);

  /// Menyimpan feedback baru dengan ID otomatis dari Firestore.
  Future<void> tambahFeedback(FeedbackModel feedback) async {
    Log.info('Mendelegasikan pembuatan feedback baru...');

    // 1. Ambil data dasar dari model
    final data = feedback.toFirebase();
    data[NamaKolom.tanggal] = FieldValue.serverTimestamp();
    await _baseOpFirebase.tambah(_namaKoleksi, data);
  }

  /// Memperbarui isi feedback.
  Future<void> perbaruiFeedback(String docId, String newContent) async {
    Log.info('Mendelegasikan pembaruan feedback: $docId');
    await _baseOpFirebase.update(_namaKoleksi, docId, {
      NamaKolom.pesan: newContent,
    });
  }

  /// Menghapus feedback secara permanen dari Firestore.
  Future<void> delete(final String docId) async {
    Log.warning('Mendelegasikan penghapusan permanen feedback: $docId');
    await _baseOpFirebase.hapusPermanen(_namaKoleksi, docId);
  }

  /// Melakukan soft delete pada feedback di Firestore.
  Future<void> softDeleteFeedback(final String docId) async {
    Log.info('Mendelegasikan soft delete feedback: $docId');
    await _baseOpFirebase.hapusSementara(_namaKoleksi, docId);
  }

  // =======================================================================
  // OPERASI BACA (Tidak didelegasikan karena spesifik untuk model)
  // =======================================================================

  /// Membaca semua feedback oleh pengguna tertentu.
  Stream<List<FeedbackModel>> ambilBerdasarkanUser(String userId) {
    try {
      Log.info('Memuat feedback untuk userId: $userId');
      return _koleksi
          .where(NamaKolom.userId, isEqualTo: userId)
          .where(NamaKolom.dihapus, isEqualTo: false)
          .orderBy(NamaKolom.tanggal, descending: true)
          .snapshots()
          .map((snapshot) {
        try {
          return snapshot.docs.map((doc) {
            return FeedbackModel.fromFirebase(
              doc.id,
              doc.data() as Map<String, dynamic>,
            );
          }).toList();
        } catch (e, s) {
          Log.error('Error saat mem-parsing data feedback', e: e, s: s);
          // Melempar kembali error untuk ditangani oleh handleError
          throw Exception('Gagal mem-parsing data feedback: $e');
        }
      }).handleError((Object e, StackTrace s) {
        Log.error('Error pada stream feedback untuk: $userId', e: e, s: s);
        // Buat StreamController untuk memancarkan error
        final controller = StreamController<List<FeedbackModel>>();
        controller.addError(e, s);
        controller.close();
        return controller.stream;
      });
    } catch (e, s) {
      Log.error('Gagal membuat query feedback untuk userId: $userId',
          e: e, s: s);
      return Stream.error(e, s);
    }
  }
}
