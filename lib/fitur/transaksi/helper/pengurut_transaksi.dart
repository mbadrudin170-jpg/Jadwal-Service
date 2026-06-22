// path lib/fitur/transaksi/helper/pengurut_transaksi.dart

import 'package:flutter_riverpod/legacy.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';

enum SortBy { terbaru, terlama, jumlahTerbesar, jumlahTerkecil }

final pengurutTransaksiProvider = StateProvider<SortBy>(
  (ref) => SortBy.terbaru,
);

class PengurutTransaksi {
  static List<TransaksiModel> urutkan(
    List<TransaksiModel> data,
    SortBy sortBy,
  ) {
    final sorted = List<TransaksiModel>.from(data);
    switch (sortBy) {
      case SortBy.terbaru:
        sorted.sort((a, b) => b.tanggal.compareTo(a.tanggal));
        break;
      case SortBy.terlama:
        sorted.sort((a, b) => a.tanggal.compareTo(b.tanggal));
        break;
      case SortBy.jumlahTerbesar:
        sorted.sort((a, b) => b.jumlah.compareTo(a.jumlah));
        break;
      case SortBy.jumlahTerkecil:
        sorted.sort((a, b) => a.jumlah.compareTo(b.jumlah));
        break;
    }
    return sorted;
  }

  static String ambilTeksUrutan(SortBy option) {
    switch (option) {
      case SortBy.terbaru:
        return 'Terbaru';
      case SortBy.terlama:
        return 'Terlama';
      case SortBy.jumlahTerbesar:
        return 'Jumlah Terbesar';
      case SortBy.jumlahTerkecil:
        return 'Jumlah Terkecil';
    }
  }
}
