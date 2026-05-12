// path: lib/shared/services/cek_langganan_kadaluarsa_service.dart// diubah: Menyederhanakan logika dengan memanggil fungsi arsipkan yang sudah ada.
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/pelanggan_aktif_operasi.dart';

/// Service ini bertanggung jawab untuk memeriksa dan mengarsipkan
/// langganan pelanggan aktif yang telah kedaluwarsa secara berkala.
class CekLanggananKadaluarsaService {
  final PelangganAktifOperasi _pelangganAktifOperasi = PelangganAktifOperasi();

  /// Memproses semua pelanggan aktif, menemukan yang kedaluwarsa,
  /// dan memanggil operasi untuk mengarsipkan mereka.
  Future<void> prosesLanggananKadaluarsa() async {
    Log.info(
      'Memulai siklus pengecekan dan pengarsipan langganan yang telah kedaluwarsa...',
    );

    try {
      Log.info(
        'Menghubungi PelangganAktifOperasi untuk mengeksekusi batch pengarsipan otomatis...',
      );

      // Memanggil satu fungsi yang sudah menangani seluruh logika
      final jumlahDiarsipkan = await _pelangganAktifOperasi
          .arsipkanPelangganKadaluarsa();

      if (jumlahDiarsipkan > 0) {
        Log.info(
          'Operasi berhasil! Sebanyak $jumlahDiarsipkan data pelanggan kedaluwarsa telah dipindahkan ke tabel arsip.',
        );
      } else {
        Log.info(
          'Hasil pengecekan bersih. Tidak ditemukan data pelanggan yang memenuhi kriteria kedaluwarsa saat ini.',
        );
      }

      Log.info(
        'Seluruh rangkaian proses pengecekan langganan kedaluwarsa telah diselesaikan dengan sukses.',
      );
    } catch (e, s) {
      Log.error(
        'Terjadi kesalahan fatal selama proses pengolahan data kedaluwarsa!',
        e: e,
        st: s,
      );
    }
  }
}
