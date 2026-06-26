// path lib/fitur/pelanggan_aktif/helper/pengurut_pelanggan_aktif.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/shared/export/model.dart';

part 'pengurut_pelanggan_aktif.g.dart';

enum UrutanPelangganAktif {
  berakhirHariIni('Berakhir Hari Ini'),
  terbaru('Terbaru'),
  terlama('Terlama'),
  tanggalMulai('Tanggal Mulai'),
  tanggalBerakhir('Tanggal Berakhir'),
  lunas('Lunas'),
  belumLunas('Belum Lunas'),
  namaAZ('Nama A-Z'),
  namaZA('Nama Z-A');

  const UrutanPelangganAktif(this.teks);
  final String teks;
}

@riverpod
class UrutanPelangganAktifState extends _$UrutanPelangganAktifState {
  @override
  UrutanPelangganAktif build() {
    return UrutanPelangganAktif.berakhirHariIni;
  }

  void ubahUrutan(UrutanPelangganAktif urutanBaru) {
    state = urutanBaru;
  }
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
    UrutanPelangganAktif sortBy,
  ) {
    final sorted = List<DetailPelangganAktifModel>.from(data);
    final sekarang = DateTime.now();

    sorted.sort((a, b) {
      switch (sortBy) {
        case UrutanPelangganAktif.berakhirHariIni:
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

        case UrutanPelangganAktif.terbaru:
          return _compareNullableDates(
            a.pelangganAktif.diperbaruiPada,
            b.pelangganAktif.diperbaruiPada,
            ascending: false,
          );

        case UrutanPelangganAktif.terlama:
          return _compareNullableDates(
            a.pelangganAktif.diperbaruiPada,
            b.pelangganAktif.diperbaruiPada,
          );

        case UrutanPelangganAktif.tanggalMulai:
          return a.pelangganAktif.tanggalMulai.compareTo(
            b.pelangganAktif.tanggalMulai,
          );

        case UrutanPelangganAktif.tanggalBerakhir:
          return b.pelangganAktif.tanggalBerakhir.compareTo(
            a.pelangganAktif.tanggalBerakhir,
          );

        case UrutanPelangganAktif.lunas:
          return a.pelangganAktif.status.index.compareTo(
            b.pelangganAktif.status.index,
          );

        case UrutanPelangganAktif.belumLunas:
          return b.pelangganAktif.status.index.compareTo(
            a.pelangganAktif.status.index,
          );

        case UrutanPelangganAktif.namaAZ:
          return a.namaPelanggan.toLowerCase().compareTo(
            b.namaPelanggan.toLowerCase(),
          );

        case UrutanPelangganAktif.namaZA:
          return b.namaPelanggan.toLowerCase().compareTo(
            a.namaPelanggan.toLowerCase(),
          );
      }
    });
    return sorted;
  }

  static String ambilTeksUrutan(UrutanPelangganAktif option) => option.teks;
}
