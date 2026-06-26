// path lib/fitur/transaksi/helper/pengurut_transaksi.dart

import 'package:flutter_riverpod/legacy.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';

enum UrutanTransaksi { terbaru, terlama, jumlahTerbesar, jumlahTerkecil }

final pengurutTransaksiProvider = StateProvider<UrutanTransaksi>(
  (ref) => UrutanTransaksi.terbaru,
);

class PengurutTransaksi {
  static List<TransaksiModel> urutkan(
    List<TransaksiModel> data,
    UrutanTransaksi sortBy,
  ) {
    final sorted = List<TransaksiModel>.from(data);
    switch (sortBy) {
      case UrutanTransaksi.terbaru:
        sorted.sort((a, b) => b.tanggal.compareTo(a.tanggal));
        break;
      case UrutanTransaksi.terlama:
        sorted.sort((a, b) => a.tanggal.compareTo(b.tanggal));
        break;
      case UrutanTransaksi.jumlahTerbesar:
        sorted.sort((a, b) => b.jumlah.compareTo(a.jumlah));
        break;
      case UrutanTransaksi.jumlahTerkecil:
        sorted.sort((a, b) => a.jumlah.compareTo(b.jumlah));
        break;
    }
    return sorted;
  }

  static String ambilTeksUrutan(UrutanTransaksi option) {
    switch (option) {
      case UrutanTransaksi.terbaru:
        return 'Terbaru';
      case UrutanTransaksi.terlama:
        return 'Terlama';
      case UrutanTransaksi.jumlahTerbesar:
        return 'Jumlah Terbesar';
      case UrutanTransaksi.jumlahTerkecil:
        return 'Jumlah Terkecil';
    }
  }
}
