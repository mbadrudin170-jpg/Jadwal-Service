// path: lib/shared/model/active_customer_detail_model.dart

import 'package:wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';

/// Model ini adalah struktur data gabungan untuk menampilkan detail pelanggan aktif.
/// Ini bukan tabel database, melainkan hasil dari query JOIN yang efisien.
class DetailPelangganAktifModel {
  /// Data inti pelanggan aktif.
  final PelangganAktifModel pelangganAktif;

  /// Nama lengkap pelanggan, diambil dari tabel `customer`.
  final String namaPelanggan;

  /// Nama paket, diambil dari tabel `package`.
  final String namaPaket;

  /// Konstruktor untuk membuat instance [DetailPelangganAktifModel].
  DetailPelangganAktifModel({
    required this.pelangganAktif,
    required this.namaPelanggan,
    required this.namaPaket,
  });
}
