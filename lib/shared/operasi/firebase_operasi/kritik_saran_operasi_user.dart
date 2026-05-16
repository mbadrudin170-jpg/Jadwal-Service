// path: lib/user/data/operasi/kritik_saran_operasi_user.dart
// Fitur: Logika Bisnis untuk Kritik dan Saran Pengguna
// Tujuan: Memisahkan operasi data (CRUD) dari UI, mengelola semua interaksi dengan Firestore.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/model/feedback_model.dart';

/// Kelas untuk mengelola operasi CRUD (Create, Read, Update, Delete)
/// terkait data kritik dan saran dari pengguna di Firestore.
class KritikSaranOperasiUser {
  /// Instance Firestore yang akan digunakan. Dapat diganti saat pengujian.
  final FirebaseFirestore firestore;

  /// Konstruktor untuk membuat instance [KritikSaranOperasiUser].
  /// Membutuhkan instance [FirebaseFirestore].
  KritikSaranOperasiUser(this.firestore);

  /// Mendapatkan referensi ke koleksi 'kritik_saran'.
  CollectionReference get _kritikSaranCollection =>
      firestore.collection('kritik_saran');

  /// Menyimpan [kritikSaran] baru ke Firestore.
  ///
  /// Melemparkan [Exception] jika terjadi kegagalan.
  Future<void> buatKritikSaranBaru(final FeedbackModel kritikSaran) async {
    try {
      await _kritikSaranCollection.add(kritikSaran.toFirebase());
    } catch (e) {
      throw Exception('Gagal membuat kritik dan saran: $e');
    }
  }

  /// Membaca semua kritik dan saran yang dikirim oleh pengguna tertentu.
  ///
  /// Mengembalikan [Stream] dari daftar [FeedbackModel] yang diurutkan
  /// berdasarkan tanggal pembaruan terbaru.
  Stream<List<FeedbackModel>> bacaSemuaKritikSaran(final String userId) {
    return _kritikSaranCollection
        .where('userId', isEqualTo: userId)
        .orderBy('diperbarui', descending: true)
        .snapshots()
        .map((final snapshot) {
      return snapshot.docs.map((final doc) {
        return FeedbackModel.fromFirebase(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    });
  }

  /// Memperbarui isi dari kritik dan saran yang sudah ada.
  ///
  /// [docId] adalah ID dokumen yang akan diperbarui.
  /// [isiBaru] adalah konten baru dari kritik atau saran.
  Future<void> perbaruiKritikSaran(
      final String docId, final String isiBaru) async {
    try {
      final dataToUpdate = {
        'isi': isiBaru,
        'diperbarui': FieldValue.serverTimestamp(),
      };
      await _kritikSaranCollection.doc(docId).update(dataToUpdate);
    } catch (e) {
      throw Exception('Gagal memperbarui kritik dan saran: $e');
    }
  }

// TODO: rencana selanjutnya adalah merubah hapus kritik saran menjadi shoft deleted dengan merubah isdeleted menjadi 0 dan memperbarui kolom diarsipkan ke tenggal timestamp
  /// Menghapus kritik dan saran dari Firestore berdasarkan [docId].
  Future<void> hapusKritikSaran(final String docId) async {
    try {
      await _kritikSaranCollection.doc(docId).delete();
    } catch (e) {
      throw Exception('Gagal menghapus kritik dan saran: $e');
    }
  }
}
// TODO: rencana selanjutnya adalah memperbarui fungsi hapus agar memperbarui id Deleted true agar terjadi shoft deleted
