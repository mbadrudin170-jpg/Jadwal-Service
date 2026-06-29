// path: lib/fitur/feedback/operasi/feedback_op_firebase.dart

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/fitur/feedback/model/feedback_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/firebase_operasi/base_op_firebase.dart';

class FeedbackOpFirebase {
  final FirebaseFirestore _firestore;
  final BaseOpFirebase _baseOpFirebase;
  final String _namaKoleksi = NamaTabel.feedback;

  FeedbackOpFirebase({
    required FirebaseFirestore firestore,
    required BaseOpFirebase baseOpFirebase,
  }) : _firestore = firestore,
       _baseOpFirebase = baseOpFirebase {
    Log.info('FeedbackOpFirebase diinisialisasi.');
  }

  CollectionReference get _koleksi => _firestore.collection(_namaKoleksi);

  Future<void> tambah(FeedbackModel feedback) async {
    Log.info('Mendelegasikan pembuatan feedback baru...');

    final data = feedback.toFirebase();
    data[NamaKolom.tanggal] = FieldValue.serverTimestamp();
    await _baseOpFirebase.tambah(_namaKoleksi, data);
  }

  Future<void> perbarui(FeedbackModel feedback) async {
    Log.info('Mendelegasikan pembaruan feedback: ${feedback.id}');

    final data = feedback.toFirebase();
    data.remove(NamaKolom.id);
    data.remove(NamaKolom.tanggal);
    await _baseOpFirebase.update(_namaKoleksi, feedback.id, data);
    Log.info('Berhasil memperbarui feedback ID: ${feedback.id}');
  }

  Future<void> delete(final String id) async {
    Log.warning('Mendelegasikan penghapusan permanen feedback: $id');
    await _baseOpFirebase.hapusPermanen(_namaKoleksi, id);
  }

  Future<void> softDelete(String id) async {
    Log.info('Mendelegasikan soft delete feedback: $id');
    await _baseOpFirebase.softDelete(_namaKoleksi, id);
  }

  Future<List<FeedbackModel>> ambilSemua() async {
    try {
      Log.info('Mengambil semua feedback aktif dari Firestore');
      final querySnapshot = await _koleksi
          .where(NamaKolom.dihapus, isEqualTo: false)
          .orderBy(NamaKolom.tanggal, descending: true)
          .get();

      Log.info('Berhasil mengambil ${querySnapshot.docs.length} feedback');
      return querySnapshot.docs.map((doc) {
        return FeedbackModel.fromFirebase(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    } on FirebaseException catch (e, s) {
      Log.error('Gagal mengambil semua feedback dari Firestore', e: e, s: s);
      rethrow;
    } on Exception catch (e, s) {
      Log.error('Error umum saat mengambil semua feedback', e: e, s: s);
      rethrow;
    }
  }

  Future<FeedbackModel?> ambilBerdasarkanId(String id) async {
    try {
      Log.info('Mengambil feedback berdasarkan ID: $id');
      final doc = await _koleksi.doc(id).get();
      if (doc.exists) {
        return FeedbackModel.fromFirebase(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }
      return null;
    } on FirebaseException catch (e, s) {
      Log.error('Gagal mengambil feedback berdasarkan ID: $id', e: e, s: s);
      rethrow;
    } on Exception catch (e, s) {
      Log.error(
        'Error umum saat mengambil feedback berdasarkan ID: $id',
        e: e,
        s: s,
      );
      rethrow;
    }
  }

  Future<List<FeedbackModel>> ambilBerdasarkanUser(String userId) async {
    try {
      Log.info('Memuat feedback untuk userId: $userId');

      final querySnapshot = await _koleksi
          .where(NamaKolom.userId, isEqualTo: userId)
          .where(NamaKolom.dihapus, isEqualTo: false)
          .orderBy(NamaKolom.tanggal, descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return FeedbackModel.fromFirebase(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    } on FirebaseException catch (e, s) {
      Log.error(
        'Gagal mengambil feedback berdasarkan userId: $userId',
        e: e,
        s: s,
      );
      rethrow;
    } on Exception catch (e, s) {
      Log.error(
        'Error umum saat mengambil feedback berdasarkan userId: $userId',
        e: e,
        s: s,
      );
      rethrow;
    }
  }
}
