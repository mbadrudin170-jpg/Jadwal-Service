// path: lib/shared/operasi/firebase_operasi/status_op_firebase.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/model/status_model.dart';

/// Kelas untuk operasi terkait data status di Firestore.
class StatusOpFirebase {
  final CollectionReference _statusCollection;

  /// Konstruktor untuk inisialisasi dengan instance FirebaseFirestore.
  StatusOpFirebase({final FirebaseFirestore? firestore})
      : _statusCollection = (firestore ?? FirebaseFirestore.instance)
            .collection(TableNameValue.get(TableName.statusGlobal)) {
    Log.info('StatusOpFirebase diinisialisasi.');
  }

  /// Memperbarui atau membuat status global dengan timestamp server.
  ///
  /// Fungsi ini akan mengatur `updatedAt` ke waktu server saat ini di Firestore.
  /// Jika dokumen 'global_status' belum ada, dokumen itu akan dibuat.
  Future<void> updateGlobalStatus() async {
    Log.info('Memulai pembaruan global status di Firestore.');
    try {
      // Menggunakan ID 'global_status' yang sudah didefinisikan di model.
      final docRef = _statusCollection.doc(globalStatusId);

      final dataToUpdate = {
        ColumnNames.updatedAt: FieldValue.serverTimestamp(),
      };

      // Menggunakan `set` dengan `SetOptions(merge: true)` agar bisa
      // membuat dokumen jika belum ada, atau memperbarui jika sudah ada.
      await docRef.set(dataToUpdate, SetOptions(merge: true));

      Log.info('Pembaruan global status berhasil.');
    } on FirebaseException catch (e, s) {
      Log.error('Gagal memperbarui global status.', e: e, st: s);
      // Melempar ulang error agar bisa ditangani di lapisan atas jika perlu.
      rethrow;
    }
  }
}
