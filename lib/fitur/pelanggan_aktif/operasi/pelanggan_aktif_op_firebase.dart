// path lib/fitur/pelanggan_aktif/operasi/pelanggan_aktif_op_firebase.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/firebase_operasi/base_op_firebase.dart';

class PelangganAktifOpFirebase extends BaseOpFirebase {
  final BaseOpFirebase _baseOp;
  final FirebaseFirestore _firestore;
  final String _namaKoleksi = NamaTabel.pelangganAktif;

  PelangganAktifOpFirebase({
    required FirebaseFirestore firestore,
    required BaseOpFirebase baseOp,
  }) : _firestore = firestore,
       _baseOp = baseOp,
       super(firestore: firestore) {
    Log.info('OrderOpFirebase diinisialisasi.');
  }

  /// 1. Menambahkan pesanan baru
  Future<void> tambahPelangganAktif(PelangganAktifModel pelangganAktif) async {
    Log.info('Menambahkan pesanan baru: ${pelangganAktif.id}');
    await _baseOp.sisipkan(
      _namaKoleksi,
      pelangganAktif.id,
      pelangganAktif.toFirebase(),
    );
  }
}
