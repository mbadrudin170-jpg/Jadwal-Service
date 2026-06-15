// path: lib/shared/operasi/firebase_operasi/active_customer_op_firebase.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/firebase_operasi/base_op_firebase.dart';

class PelangganAktifOpFirebase extends BaseOpFirebase {
  final FirebaseFirestore _firestore;

  PelangganAktifOpFirebase({super.firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance {
    Log.info('ActiveCustomerOpFirebase diinisialisasi.');
  }

  CollectionReference get _koleksi =>
      _firestore.collection(NamaTabel.pelangganAktif);

  Future<void> tambahPelangganAktif(
      final PelangganAktifModel pelangganAktif) async {
    Log.info(
        'Menambah/memperbarui pelanggan aktif: ${pelangganAktif.idPelanggan}');
    try {
      await sisipkan(
        NamaTabel.pelangganAktif,
        pelangganAktif.idPelanggan,
        pelangganAktif.toFirebase(),
      );
      Log.info(
          'Berhasil menambah/memperbarui pelanggan aktif: ${pelangganAktif.idPelanggan}');
    } on FirebaseException catch (e, s) {
      Log.error(
          'Gagal menambah/memperbarui pelanggan aktif: ${pelangganAktif.idPelanggan}',
          e: e,
          s: s);
      rethrow;
    }
  }

  Future<PelangganAktifModel?> ambilBerdasarkanId(
    final String idPelanggan,
  ) async {
    try {
      final doc = await _koleksi.doc(idPelanggan).get();

      if (!doc.exists) {
        Log.warning(
            'Tidak ada data pelanggan aktif ditemukan untuk ID: $idPelanggan');
        return null;
      }

      final data = doc.data() as Map<String, dynamic>;
      Log.info('Data pelanggan aktif ditemukan untuk ID: $idPelanggan');
      return PelangganAktifModel.fromFirebase(doc.id, data);
    } on Exception catch (e, s) {
      Log.error('Error mengambil data pelanggan aktif untuk ID: $idPelanggan',
          e: e, s: s);
      return null;
    }
  }
}
