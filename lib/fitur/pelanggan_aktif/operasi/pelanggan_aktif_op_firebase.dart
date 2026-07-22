// path lib/fitur/pelanggan_aktif/operasi/pelanggan_aktif_op_firebase.dart

import 'package:wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:wifi/fitur/pelanggan_aktif/operasi/pelanggan_aktif_abstrak.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/firebase_operasi/base_op_firebase.dart';

class PelangganAktifOpFirebase extends BaseOpFirebase
    implements PelangganAktifAbstrak {
  final BaseOpFirebase _baseOp;
  final String _namaKoleksi = NamaTabel.pelangganAktif;

  PelangganAktifOpFirebase({required BaseOpFirebase baseOp}) : _baseOp = baseOp {
    Log.info('OrderOpFirebase diinisialisasi.');
  }

  @override
  Future<void> tambahPelangganAktif(PelangganAktifModel pelangganAktif) async {
    Log.info('Menambahkan pesanan baru: ${pelangganAktif.id}');
    await _baseOp.sisipkan(
      _namaKoleksi,
      pelangganAktif.id,
      pelangganAktif.toFirebase(),
    );
  }

  @override
  Future<List<PelangganAktifModel>> ambilSemua() {
    // TODO: implement ambilSemua
    throw UnimplementedError();
  }

  @override
  Future<int> softDelete(String id) {
    // TODO: implement softDelete
    throw UnimplementedError();
  }

  @override
  Future<int> softDeleteAll() {
    // TODO: implement softDeleteAll
    throw UnimplementedError();
  }

  @override
  Future<int> updatePelangganAktif(PelangganAktifModel pelangganAktif) {
    // TODO: implement updatePelangganAktif
    throw UnimplementedError();
  }
}
