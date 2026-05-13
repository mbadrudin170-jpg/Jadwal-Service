// path: lib/user/data/operasi/kritik_saran_operasi_user.dart
// Fitur: Logika Bisnis untuk Kritik dan Saran Pengguna
// Tujuan: Memisahkan operasi data (CRUD) dari UI, mengelola semua interaksi dengan Firestore.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/model/kritik_saran_model.dart';

class KritikSaranOperasiUser {
  final CollectionReference _kritikSaranCollection =
      FirebaseFirestore.instance.collection('kritik_saran');

  Future<void> buatKritikSaranBaru(KritikSaranModel kritikSaran) async {
    try {
      await _kritikSaranCollection.add(kritikSaran.toFirebase());
    } catch (e) {
      throw Exception('Gagal membuat kritik dan saran: $e');
    }
  }

  Stream<List<KritikSaranModel>> bacaSemuaKritikSaran(String userId) {
    return _kritikSaranCollection
        .where('userId', isEqualTo: userId)
        .orderBy('diperbarui', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return KritikSaranModel.fromFirebase(
            doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<void> perbaruiKritikSaran(String docId, String isiBaru) async {
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

  Future<void> hapusKritikSaran(String docId) async {
    try {
      await _kritikSaranCollection.doc(docId).delete();
    } catch (e) {
      throw Exception('Gagal menghapus kritik dan saran: $e');
    }
  }
}
