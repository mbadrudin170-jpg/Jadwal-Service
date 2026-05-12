// path: lib/shared/utils/pelanggan_aktif_sorter.dart

import '../debug/log.dart';
import '../enum/status_pembayaran_enum.dart';
import '../model/pelanggan_aktif_model.dart';
import 'perhitungan_util.dart';

enum OpsiUrutkan {
  tanggalBerakhir,
  tanggalMulai,
  diPerbarui,
  namaAZ,
  namaZA,
  lunas,
  belumLunas,
  paketAktif,
  paketTidakAktif,
}

class PelangganAktifSorter {
  static List<PelangganAktifModel> sort(
    List<PelangganAktifModel> pelanggan,
    OpsiUrutkan urutan,
    Map<String, String> mapNamaPelanggan,
  ) {
    Log.info('Mengurutkan ${pelanggan.length} pelanggan berdasarkan: ${urutan.name}');
    final sortedList = List.of(pelanggan);

    int Function(PelangganAktifModel, PelangganAktifModel) comparator;

    switch (urutan) {
      case OpsiUrutkan.tanggalBerakhir:
        comparator = (a, b) => a.tanggalBerakhir.compareTo(b.tanggalBerakhir);
        break;
      case OpsiUrutkan.tanggalMulai:
        comparator = (a, b) => a.tanggalMulai.compareTo(b.tanggalMulai);
        break;
      case OpsiUrutkan.diPerbarui:
        comparator = (a, b) {
          final dateA = a.diperbarui ?? a.tanggalMulai;
          final dateB = b.diperbarui ?? b.tanggalMulai;
          return dateB.compareTo(dateA);
        };
        break;
      case OpsiUrutkan.namaAZ:
      case OpsiUrutkan.namaZA:
        comparator = (a, b) {
          final namaA = mapNamaPelanggan[a.idPelanggan] ?? '';
          final namaB = mapNamaPelanggan[b.idPelanggan] ?? '';
          return urutan == OpsiUrutkan.namaAZ
              ? namaA.compareTo(namaB)
              : namaB.compareTo(namaA);
        };
        break;
      case OpsiUrutkan.lunas:
      case OpsiUrutkan.belumLunas:
        comparator = (a, b) {
          final isLunasA = a.status == StatusPembayaranEnum.lunas;
          final isLunasB = b.status == StatusPembayaranEnum.lunas;
          if (isLunasA == isLunasB) {
            return a.tanggalBerakhir.compareTo(b.tanggalBerakhir);
          } 
          return (urutan == OpsiUrutkan.lunas)
              ? (isLunasA ? -1 : 1)
              : (isLunasA ? 1 : -1);
        };
        break;
      case OpsiUrutkan.paketAktif:
      case OpsiUrutkan.paketTidakAktif:
        comparator = (a, b) {
          final isAktifA = PerhitunganUtil.sisaHari(a.tanggalBerakhir) >= 0;
          final isAktifB = PerhitunganUtil.sisaHari(b.tanggalBerakhir) >= 0;
          if (isAktifA == isAktifB) {
            return a.tanggalBerakhir.compareTo(b.tanggalBerakhir);
          }
          return (urutan == OpsiUrutkan.paketAktif)
              ? (isAktifA ? -1 : 1)
              : (isAktifA ? 1 : -1);
        };
        break;
    }

    sortedList.sort(comparator);
    return sortedList;
  }
}
