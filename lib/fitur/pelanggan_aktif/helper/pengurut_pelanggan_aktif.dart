// path lib/fitur/pelanggan_aktif/helper/pengurut_pelanggan_aktif.dart

import 'package:wifi/shared/export/model.dart';

enum OpsiUrutkan {
  berakhirHariIni,
  terbaru,
  terlama,
  tanggalMulai,
  tanggalBerakhir,
  lunas,
  belumLunas,
  namaAZ,
  namaZA,
}

class PengurutPelangganAktif {
  static int _compareNullableDates(
    DateTime? a,
    DateTime? b, {
    bool ascending = true,
  }) {
    if (a == null && b == null) return 0;
    if (a == null) return 1; // null dianggap paling besar/lama
    if (b == null) return -1; // non-null dianggap lebih kecil/baru
    return ascending ? a.compareTo(b) : b.compareTo(a);
  }

  static List<DetailPelangganAktifModel> urutkan(
    List<DetailPelangganAktifModel> data,
    OpsiUrutkan sortBy,
  ) {
    final sorted = List<DetailPelangganAktifModel>.from(data);
    final sekarang = DateTime.now();

    sorted.sort((a, b) {
      switch (sortBy) {
        case OpsiUrutkan.berakhirHariIni:
          final sisaHariA = a.pelangganAktif.tanggalBerakhir
              .difference(sekarang)
              .inMilliseconds;
          final sisaHariB = b.pelangganAktif.tanggalBerakhir
              .difference(sekarang)
              .inMilliseconds;

          final lewatA = sisaHariA < 0;
          final lewatB = sisaHariB < 0;

          if (!lewatA && lewatB) return -1;
          if (lewatA && !lewatB) return 1;
          if (!lewatA) {
            return sisaHariA.compareTo(sisaHariB);
          }
          return sisaHariB.compareTo(sisaHariA);

        case OpsiUrutkan.terbaru:
          return _compareNullableDates(
            a.pelangganAktif.diperbaruiPada,
            b.pelangganAktif.diperbaruiPada,
            ascending: false,
          );

        case OpsiUrutkan.terlama:
          return _compareNullableDates(
            a.pelangganAktif.diperbaruiPada,
            b.pelangganAktif.diperbaruiPada,
          );

        case OpsiUrutkan.tanggalMulai:
          return a.pelangganAktif.tanggalMulai.compareTo(
            b.pelangganAktif.tanggalMulai,
          );

        case OpsiUrutkan.tanggalBerakhir:
          return b.pelangganAktif.tanggalBerakhir.compareTo(
            a.pelangganAktif.tanggalBerakhir,
          );

        case OpsiUrutkan.lunas:
          return a.pelangganAktif.status.index.compareTo(
            b.pelangganAktif.status.index,
          );

        case OpsiUrutkan.belumLunas:
          return b.pelangganAktif.status.index.compareTo(
            a.pelangganAktif.status.index,
          );

        case OpsiUrutkan.namaAZ:
          return a.namaPelanggan.toLowerCase().compareTo(
            b.namaPelanggan.toLowerCase(),
          );

        case OpsiUrutkan.namaZA:
          return b.namaPelanggan.toLowerCase().compareTo(
            a.namaPelanggan.toLowerCase(),
          );
      }
    });
    return sorted;
  }

  static String ambilLabelUrutan(OpsiUrutkan option) {
    switch (option) {
      case OpsiUrutkan.berakhirHariIni:
        return 'Berakhir Hari Ini';
      case OpsiUrutkan.tanggalBerakhir:
        return 'Tanggal Berakhir';
      case OpsiUrutkan.tanggalMulai:
        return 'Tanggal Mulai';
      case OpsiUrutkan.lunas:
        return 'Lunas';
      case OpsiUrutkan.belumLunas:
        return 'Belum Lunas';
      case OpsiUrutkan.namaAZ:
        return 'Nama A-Z';
      case OpsiUrutkan.namaZA:
        return 'Nama Z-A';
      case OpsiUrutkan.terbaru:
        return 'Terbaru';
      case OpsiUrutkan.terlama:
        return 'Terlama';
    }
  }
}
