// path lib/fitur/pelanggan_aktif/helper/pengurut_pelanggan_aktif.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/shared/export/model.dart';

part 'pengurut_pelanggan_aktif.g.dart';

enum UrutanPelangganAktifEnum {
  berakhirHariIni('Berakhir Hari Ini'),
  terbaru('Terbaru'),
  terlama('Terlama'),
  tanggalMulai('Tanggal Mulai'),
  tanggalBerakhir('Tanggal Berakhir'),
  lunas('Lunas'),
  belumLunas('Belum Lunas'),
  namaAZ('Nama A-Z'),
  namaZA('Nama Z-A');

  const UrutanPelangganAktifEnum(this.teks);
  final String teks;
}

@riverpod
class UrutanPelangganAktifState extends _$UrutanPelangganAktifState {
  @override
  UrutanPelangganAktifEnum build() {
    return UrutanPelangganAktifEnum.berakhirHariIni;
  }

  void ubahUrutan(UrutanPelangganAktifEnum urutanBaru) {
    state = urutanBaru;
  }
}

int _compareNullableDates(DateTime? a, DateTime? b, {bool ascending = true}) {
  if (a == null && b == null) return 0;
  if (a == null) return 1; // null dianggap paling besar/lama
  if (b == null) return -1; // non-null dianggap lebih kecil/baru
  return ascending ? a.compareTo(b) : b.compareTo(a);
}

List<DetailPelangganAktifModel> urutkanPelangganAktif(
  List<DetailPelangganAktifModel> data,
  UrutanPelangganAktifEnum sortBy,
) {
  final sorted = List<DetailPelangganAktifModel>.from(data);
  final sekarang = DateTime.now();

  sorted.sort((a, b) {
    switch (sortBy) {
      case UrutanPelangganAktifEnum.berakhirHariIni:
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

      case UrutanPelangganAktifEnum.terbaru:
        return _compareNullableDates(
          a.pelangganAktif.diperbaruiPada,
          b.pelangganAktif.diperbaruiPada,
          ascending: false,
        );

      case UrutanPelangganAktifEnum.terlama:
        return _compareNullableDates(
          a.pelangganAktif.diperbaruiPada,
          b.pelangganAktif.diperbaruiPada,
        );

      case UrutanPelangganAktifEnum.tanggalMulai:
        return a.pelangganAktif.tanggalMulai.compareTo(
          b.pelangganAktif.tanggalMulai,
        );

      case UrutanPelangganAktifEnum.tanggalBerakhir:
        return b.pelangganAktif.tanggalBerakhir.compareTo(
          a.pelangganAktif.tanggalBerakhir,
        );

      case UrutanPelangganAktifEnum.lunas:
        return a.pelangganAktif.status.index.compareTo(
          b.pelangganAktif.status.index,
        );

      case UrutanPelangganAktifEnum.belumLunas:
        return b.pelangganAktif.status.index.compareTo(
          a.pelangganAktif.status.index,
        );

      case UrutanPelangganAktifEnum.namaAZ:
        return a.namaPelanggan.toLowerCase().compareTo(
          b.namaPelanggan.toLowerCase(),
        );

      case UrutanPelangganAktifEnum.namaZA:
        return b.namaPelanggan.toLowerCase().compareTo(
          a.namaPelanggan.toLowerCase(),
        );
    }
  });
  return sorted;
}

String ambilTeksUrutanPelangganAktif(UrutanPelangganAktifEnum option) =>
    option.teks;
