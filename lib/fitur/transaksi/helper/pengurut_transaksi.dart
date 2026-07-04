// path lib/fitur/transaksi/helper/pengurut_transaksi.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi_provider.dart/operasi_provider.dart';

part 'pengurut_transaksi.g.dart';

enum UrutanTransaksi {
  terbaru('Terbaru'),
  terlama('Terlama'),
  jumlahTerbesar('Jumlah Terbesar'),
  jumlahTerkecil('Jumlah Terkecil');

  const UrutanTransaksi(this.teks);
  final String teks;
}

@riverpod
class UrutanTransaksiState extends _$UrutanTransaksiState {
  @override
  UrutanTransaksi build() => UrutanTransaksi.terbaru;
  void ubahUrutan(UrutanTransaksi urutanBaru) => state = urutanBaru;
}

extension PengurutTransaksiX on List<TransaksiModel> {
  List<TransaksiModel> urutkan(UrutanTransaksi opsi) {
    final sorted = List<TransaksiModel>.from(this);
    switch (opsi) {
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
}

@riverpod
Future<List<TransaksiModel>> sortedTransaksi(Ref ref) async {
  final transaksiState = await ref.watch(operasiProviderProvider.future);
  final urutanAktif = ref.watch(urutanTransaksiStateProvider);
  return transaksiState.transaksi.urutkan(urutanAktif);
}
