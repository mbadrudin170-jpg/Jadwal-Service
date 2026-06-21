// path lib/fitur/notfikasi/operasi/notifikasi_op_firebase.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/fitur/notfikasi/model/notifikasi_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/base_op_firebase.dart';

class NotifikasiOpFirebase {
  final FirebaseFirestore _firestore;
  final BaseOpFirebase _baseOp;
  final String _koleksi = NamaTabel.notifikasi;

  NotifikasiOpFirebase({
    required FirebaseFirestore firestore,
    required BaseOpFirebase baseOp,
  })  : _firestore = firestore,
        _baseOp = baseOp;

  Stream<List<NotifikasiModel>> getNotifAktif() {
    /// Mengambil notifikasi yang sedang aktif.
    final now = DateTime.now();
    return _firestore
        .collection(_koleksi)
        .where(NamaKolom.dihapus, isEqualTo: false)
        .where(NamaKolom.setatusDibaca, isEqualTo: false)
        .where(NamaKolom.tanggalTampil,
            isLessThanOrEqualTo: Timestamp.fromDate(now))
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return NotifikasiModel.fromFirebase(doc.id, doc.data());
      }).toList();
    });
  }

  /// Mendapatkan stream notifikasi aktif untuk user tertentu (belum dibaca & belum dihapus)
  Stream<List<NotifikasiModel>> getByUserId(String userId) {
    return _firestore
        .collection(_koleksi)
        .where(NamaKolom.userId,
            isEqualTo: userId) // Diperbaiki dari idTujuan ke userId
        .where(NamaKolom.dihapus, isEqualTo: false)
        .where(NamaKolom.setatusDibaca, isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotifikasiModel.fromFirebase(doc.id, doc.data()))
            .toList());
  }

  Stream<List<NotifikasiModel>> getById(String id) {
    return _firestore
        .collection(_koleksi)
        .doc(id)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return [];
      final data = snapshot.data()!;
      if (data[NamaKolom.dihapus] == true ||
          data[NamaKolom.setatusDibaca] == true) {
        return [];
      }
      return [NotifikasiModel.fromFirebase(snapshot.id, data)];
    });
  }

// TODO : tambahkan unit test
  Stream<List<NotifikasiModel>> getKhususAdmin() {
    return _firestore
        .collection(_koleksi)
        .where(NamaKolom.tipe, whereIn: [
          TipeNotifikasiEnum.order.name,
          TipeNotifikasiEnum.transaksi.name
        ])
        .where(NamaKolom.setatusDibaca, isEqualTo: false)
        .where(NamaKolom.dihapus, isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotifikasiModel.fromFirebase(doc.id, doc.data()))
            .toList());
  }

  Future<void> addNotifikasi(NotifikasiModel notifikasi) async {
    try {
      Log.info('Saving notification to Firebase via BaseOp: ${notifikasi.id}');
      await _baseOp.sisipkan(
        _koleksi,
        notifikasi.id,
        notifikasi.toFirebase(),
      );
    } catch (e) {
      Log.error('Error saving notification: $e');
      rethrow;
    }
  }

  Future<void> updateNotif(NotifikasiModel notifikasi) async {
    try {
      Log.info(
          'Updating notification in Firebase via BaseOp: ${notifikasi.id}');
      await _baseOp.update(
        _koleksi,
        notifikasi.id,
        notifikasi.toFirebase(),
      );
    } catch (e) {
      Log.error('Error updating notification: $e');
      rethrow;
    }
  }

  Future<void> deleteNotif(String id) async {
    try {
      Log.info('Deleting notification from Firebase via BaseOp: $id');
      await _baseOp.hapusPermanen(_koleksi, id);
    } catch (e) {
      Log.error('Error deleting notification: $e');
      rethrow;
    }
  }

  Future<void> deleteByTransactionId(String transactionId) async {
    try {
      Log.info(
          'Menghapus notifikasi berdasarkan idTujuan (transactionId): $transactionId');
      final querySnapshot = await _firestore
          .collection(_koleksi)
          .where(NamaKolom.idTujuan, isEqualTo: transactionId)
          .get();

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      Log.info('Berhasil menghapus ${querySnapshot.docs.length} notifikasi.');
    } catch (e, st) {
      Log.error('Gagal menghapus notifikasi berdasarkan transactionId',
          e: e, s: st);
      rethrow;
    }
  }

  /// Menandai notifikasi sebagai sudah dibaca.
  Future<void> tandaiSudahDibaca(String id) async {
    try {
      Log.info('Marking notification as read via BaseOp: $id');
      await _baseOp.update(_koleksi, id, {
        NamaKolom.setatusDibaca: true,
      });
    } catch (e) {
      Log.error('Error marking notification as read: $e');
      rethrow;
    }
  }
}
