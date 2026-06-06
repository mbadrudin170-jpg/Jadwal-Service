// path: lib/shared/operasi/firebase_operasi/notifikasi_op_firebase.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/model/notifikasi_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/base_op_firebase.dart';

/// Operasi Firebase untuk model Notifikasi.
class NotifikasiOpFirebase {
  final FirebaseFirestore _firestore;
  final BaseOpFirebase _baseOp;
  static final String _collection = TableNameValue.get(TableName.notifikasi);

  NotifikasiOpFirebase({
    required FirebaseFirestore firestore,
    required BaseOpFirebase baseOp,
  })  : _firestore = firestore,
        _baseOp = baseOp;

  /// Mendapatkan stream daftar notifikasi yang masih berlaku (berdasarkan endDate).
  /// Catatan: Jika query dibatasi per-user, disarankan menambah filter ColumnNames.idTujuan
  Stream<List<NotifikasiModel>> getActiveNotifications() {
    final now = DateTime.now().toUtc();
    return _firestore
        .collection(_collection)
        .where(ColumnNames.isDeleted, isEqualTo: false)
        .where(ColumnNames.endDate,
            isGreaterThanOrEqualTo: Timestamp.fromDate(now))
        .where(ColumnNames.isRead, isEqualTo: false)
        .where(ColumnNames.tanggalTampil, )
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return NotifikasiModel.fromFirebase(doc.id, doc.data());
      }).toList();
    });
  }

  /// Menambahkan atau memperbarui notifikasi secara aman via BaseOp.
  Future<void> add(NotifikasiModel notifikasi) async {
    try {
      Log.info('Saving notification to Firebase via BaseOp: ${notifikasi.id}');

      // Gunakan 'insert' karena di dalamnya memakai docRef.set(data),
      // yang aman untuk data baru maupun update total data lama.
      await _baseOp.insert(
        _collection,
        notifikasi.id,
        notifikasi.toFirebase(),
      );
    } catch (e) {
      Log.error('Error saving notification: $e');
      rethrow;
    }
  }

  /// Menghapus notifikasi berdasarkan ID secara permanen (Hard Delete).
  /// Jika ingin soft delete, Anda bisa membuat metode memanggil _baseOp.softDelete.
  Future<void> delete(String id) async {
    try {
      Log.info('Deleting notification from Firebase via BaseOp: $id');
      await _baseOp.delete(_collection, id);
    } catch (e) {
      Log.error('Error deleting notification: $e');
      rethrow;
    }
  }

  /// Menandai notifikasi sebagai sudah dibaca.
  Future<void> tandaiSudahDibaca(String id) async {
    try {
      Log.info('Marking notification as read via BaseOp: $id');
      await _baseOp.update(_collection, id, {
        ColumnNames.isRead: true,
      });
    } catch (e) {
      Log.error('Error marking notification as read: $e');
      rethrow;
    }
  }
}
