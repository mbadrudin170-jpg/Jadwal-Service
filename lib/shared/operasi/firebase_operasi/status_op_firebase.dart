// path: lib/shared/operasi/firebase_operasi/status_op_firebase.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/status_model.dart';

/// Kelas untuk operasi terkait data status di Firestore.
class StatusOpFirebase {
  final CollectionReference _koleksiStatus;

  /// Konstruktor untuk inisialisasi dengan instance FirebaseFirestore.
  StatusOpFirebase({FirebaseFirestore? firestore})
      : _koleksiStatus = (firestore ?? FirebaseFirestore.instance)
            .collection(NamaTabel.statusGlobal) {
    Log.info('StatusOpFirebase diinisialisasi.');
  }

  /// Memperbarui atau membuat status global dengan timestamp server.
  ///
  /// Fungsi ini akan mengatur `updatedAt` ke waktu server saat ini di Firestore.
  /// Jika dokumen 'global_status' belum ada, dokumen itu akan dibuat.
  Future<void> perbaruiStatusGlobal() async {
    Log.info('Memulai pembaruan global status di Firestore.');
    try {
      // Menggunakan ID 'global_status' yang sudah didefinisikan di model.
      final docRef = _koleksiStatus.doc(globalStatusId);

      final dataToUpdate = {
        NamaKolom.updatedAt: FieldValue.serverTimestamp(),
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
