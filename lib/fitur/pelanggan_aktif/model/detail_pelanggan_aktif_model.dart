// path lib/fitur/pelanggan_aktif/model/detail_pelanggan_aktif_model.dart

import 'package:wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';

class DetailPelangganAktifModel {
  final PelangganAktifModel pelangganAktif;

  final String namaPelanggan;

  final String namaPaket;

  DetailPelangganAktifModel({
    required this.pelangganAktif,
    required this.namaPelanggan,
    required this.namaPaket,
  });
}
