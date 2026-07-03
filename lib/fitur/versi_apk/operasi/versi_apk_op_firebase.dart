// path: lib/fitur/versi_apk/operasi/versi_apk_op_firebase.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/fitur/versi_apk/model/versi_apk_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';

class VersiApkOpFirebase {
  final FirebaseFirestore _firestore;

  VersiApkOpFirebase({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  late final CollectionReference<VersiApkModel> _koleksi = _firestore
      .collection(NamaTabel.versiApkUser)
      .withConverter<VersiApkModel>(
        fromFirestore: (snapshot, _) =>
            VersiApkModel.fromFirebase(snapshot.id, snapshot.data()!),
        toFirestore: (model, _) => model.toFirebase(),
      );

  Future<VersiApkModel?> ambilVersiTerbaru() async {
    Log.info('Memulai mengambil versi APK terbaru');
    try {
      final query = await _koleksi
          .where(NamaKolom.dihapus, isEqualTo: false)
          .where(NamaKolom.diarsipkanPada, isNull: true)
          .orderBy(NamaKolom.diperbaruiPada, descending: true)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data();
        Log.info('Versi APK terbaru berhasil diambil', data.toFirebase());
        return data;
      }
      Log.warning('Tidak ada versi APK aktif yang ditemukan');
      return null;
    } catch (e, st) {
      Log.error('Error saat mengambil versi APK', e: e, s: st);
      rethrow;
    }
  }
}
