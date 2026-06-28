// path: lib/shared/operasi/firebase_operasi/status_op_firebase.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/status_model.dart';

class StatusOpFirebase {
  final CollectionReference _koleksiStatus;

  StatusOpFirebase({FirebaseFirestore? firestore})
    : _koleksiStatus = (firestore ?? FirebaseFirestore.instance).collection(
        NamaTabel.statusGlobal,
      ) {
    Log.info('StatusOpFirebase diinisialisasi.');
  }

  Future<void> perbaruiStatusGlobal() async {
    Log.info('Memulai pembaruan global status di Firestore.');
    try {
      final docRef = _koleksiStatus.doc(globalStatusId);

      final dataToUpdate = {
        NamaKolom.diperbaruiPada: FieldValue.serverTimestamp(),
      };

      await docRef.set(dataToUpdate, SetOptions(merge: true));

      Log.info('Pembaruan global status berhasil.');
    } on FirebaseException catch (e, s) {
      Log.error('Gagal memperbarui global status.', e: e, s: s);
      rethrow;
    }
  }
}
