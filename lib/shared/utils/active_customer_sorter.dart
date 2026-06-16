import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/fitur/pelanggan_aktif/model/detail_pelanggan_aktif_model.dart';
import 'package:wifi/shared/utils/perhitungan_util.dart';

enum SortOption {
  tanggalBerakhir,
  tanggalMulai,
  terakhirDiperbarui,
  namaAZ,
  namaZA,
  lunas,
  belumLunas,
  paketAktif,
  inactivePackage,
}

class ActiveCustomerSorter {
  static List<DetailPelangganAktifModel> sort(
    final List<DetailPelangganAktifModel> customers,
    final SortOption sortOption,
  ) {
    Log.info(
      'Mengurutkan ${customers.length} pelanggan berdasarkan: ${sortOption.name}',
    );
    final sortedList = List.of(customers);

    int Function(DetailPelangganAktifModel, DetailPelangganAktifModel)
        comparator;

    switch (sortOption) {
      case SortOption.tanggalBerakhir:
        comparator = (final a, final b) => a.pelangganAktif.tanggalBerakhir
            .compareTo(b.pelangganAktif.tanggalBerakhir);
        break;
      case SortOption.tanggalMulai:
        comparator = (final a, final b) => a.pelangganAktif.tanggalMulai
            .compareTo(b.pelangganAktif.tanggalMulai);
        break;
      case SortOption.terakhirDiperbarui:
        comparator = (final a, final b) {
          final dateA = a.pelangganAktif.diperbaruiPada ??
              a.pelangganAktif.diperbaruiPada;
          final dateB = b.pelangganAktif.diperbaruiPada ??
              b.pelangganAktif.diperbaruiPada;
          return dateB!.compareTo(dateA!);
        };
        break;
      case SortOption.namaAZ:
      case SortOption.namaZA:
        comparator = (final a, final b) {
          final nameA = a.namaPelanggan;
          final nameB = b.namaPelanggan;
          return sortOption == SortOption.namaAZ
              ? nameA.compareTo(nameB)
              : nameB.compareTo(nameA);
        };
        break;
      case SortOption.lunas:
      case SortOption.belumLunas:
        comparator = (final a, final b) {
          final isPaidA = a.pelangganAktif.status == StatusPembayaran.paid;
          final isPaidB = b.pelangganAktif.status == StatusPembayaran.paid;
          if (isPaidA == isPaidB) {
            return a.pelangganAktif.tanggalBerakhir
                .compareTo(b.pelangganAktif.tanggalBerakhir);
          }
          return (sortOption == SortOption.lunas)
              ? (isPaidA ? -1 : 1)
              : (isPaidA ? 1 : -1);
        };
        break;
      case SortOption.paketAktif:
      case SortOption.inactivePackage:
        comparator = (final a, final b) {
          final isActiveA =
              PerhitunganUtil.sisaHari(a.pelangganAktif.tanggalBerakhir) >= 0;
          final isActiveB =
              PerhitunganUtil.sisaHari(b.pelangganAktif.tanggalBerakhir) >= 0;
          if (isActiveA == isActiveB) {
            return a.pelangganAktif.tanggalBerakhir
                .compareTo(b.pelangganAktif.tanggalBerakhir);
          }
          return (sortOption == SortOption.paketAktif)
              ? (isActiveA ? -1 : 1)
              : (isActiveA ? 1 : -1);
        };
        break;
    }

    sortedList.sort(comparator);
    return sortedList;
  }
}
