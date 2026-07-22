// path: lib/fitur/pelanggan_aktif/operasi/pelanggan_aktif_abstrak.dart

import 'package:wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';

abstract class PelangganAktifAbstrak {
  Future<List<PelangganAktifModel>> ambilSemua();
  Future<int> tambahPelangganAktif(PelangganAktifModel pelangganAktif);
  Future<int> updatePelangganAktif(PelangganAktifModel pelangganAktif);
  Future<int> softDelete(String id);
  Future<int> softDeleteAll();
}
