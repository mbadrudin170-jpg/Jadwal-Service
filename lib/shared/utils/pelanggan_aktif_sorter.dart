// path: lib/shared/utils/pelanggan_aktif_sorter.dart

import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/status_pembayaran_enum.dart';
import 'package:wifi/shared/model/pelanggan_aktif_model.dart';
import 'package:wifi/shared/utils/perhitungan_util.dart';

/// Opsi pengurutan untuk daftar pelanggan aktif.
enum OpsiUrutkan {
  /// Urutkan berdasarkan tanggal berakhir (ascending).
  tanggalBerakhir,

  /// Urutkan berdasarkan tanggal mulai (ascending).
  tanggalMulai,

  /// Urutkan berdasarkan waktu terakhir diperbarui (descending).
  diPerbarui,

  /// Urutkan berdasarkan nama pelanggan A-Z.
  namaAZ,

  /// Urutkan berdasarkan nama pelanggan Z-A.
  namaZA,

  /// Urutkan dengan pelanggan lunas di atas.
  lunas,

  /// Urutkan dengan pelanggan belum lunas di atas.
  belumLunas,

  /// Urutkan dengan paket aktif di atas.
  paketAktif,

  /// Urutkan dengan paket tidak aktif di atas.
  paketTidakAktif,
}

/// Utility untuk mengurutkan daftar pelanggan aktif.
///
/// Mendukung berbagai opsi pengurutan melalui [OpsiUrutkan].
class PelangganAktifSorter {
  /// Mengurutkan daftar [pelanggan] berdasarkan [urutan] yang dipilih.
  ///
  /// [mapNamaPelanggan] digunakan untuk menerjemahkan ID pelanggan ke nama
  /// saat mengurutkan berdasarkan nama (namaAZ/namaZA).
  ///
  /// Mengembalikan list baru yang sudah terurut.
  static List<PelangganAktifModel> sort(
    List<PelangganAktifModel> pelanggan,
    OpsiUrutkan urutan,
    Map<String, String> mapNamaPelanggan,
  ) {
    Log.info(
      'Mengurutkan ${pelanggan.length} pelanggan berdasarkan: ${urutan.name}',
    );
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
