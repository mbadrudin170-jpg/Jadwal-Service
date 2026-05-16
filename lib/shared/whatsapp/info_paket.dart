// path: lib/shared/whatsapp/info_paket.dart

import 'package:url_launcher/url_launcher.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/paket_model.dart';
import 'package:wifi/shared/model/pelanggan_aktif_model.dart';
import 'package:wifi/shared/model/pelanggan_model.dart';
import 'package:wifi/shared/operasi/package_operation.dart';
import 'package:wifi/shared/operasi/customer_operation.dart';
import 'package:wifi/shared/utils/format_util.dart';

/// Kelas utilitas untuk membuat dan mengirim pesan informasi paket.
class PesanInfoPaket {
  /// Mengambil detail pelanggan dan paket, membuat pesan,
  /// lalu secara otomatis mengirimkannya melalui WhatsApp.
  ///
  /// [pelangganAktif]: Objek PelangganAktifModel yang baru saja dibuat atau diperbarui.
  static Future<void> kirimRincianPaket(
    final PelangganAktifModel pelangganAktif,
  ) async {
    Log.info(
      'Memulai proses pengiriman rincian paket via WhatsApp untuk pelanggan aktif ID: ${pelangganAktif.id}',
    );
    final pelangganOperasi = PelangganOperasi();
    final paketOperasi = PaketOperasi();

    try {
      // 1. Ambil data lengkap pelanggan dan paket dari database lokal.
      Log.info(
        'Mengambil data pelanggan dengan ID: ${pelangganAktif.idPelanggan}',
      );
      final PelangganModel? pelanggan = await pelangganOperasi.getPelangganById(
        pelangganAktif.idPelanggan,
      );
      Log.info('Mengambil data paket dengan ID: ${pelangganAktif.idPaket}');
      final PaketModel? paket = await paketOperasi.getPaketById(
        pelangganAktif.idPaket,
      );

      if (pelanggan == null) {
        Log.warning(
          'Pengiriman pesan dibatalkan. Pelanggan dengan ID ${pelangganAktif.idPelanggan} tidak ditemukan di database lokal.',
        );
        return;
      }
      if (paket == null) {
        Log.warning(
          'Pengiriman pesan dibatalkan. Paket dengan ID ${pelangganAktif.idPaket} tidak ditemukan di database lokal.',
        );
        return;
      }

      Log.info(
        'Berhasil menemukan data pelanggan: ${pelanggan.nama} dan paket: ${paket.nama}',
      );

      // 2. Dapatkan status pembayaran langsung dari model PelangganAktif.
      final String statusPembayaran = pelangganAktif.status.displayName;
      Log.info('Status pembayaran yang akan dikirim: $statusPembayaran');

      // 3. Buat string pesan yang akan dikirim.
      Log.info('Membuat konten pesan WhatsApp.');
      final String pesan = _buatPesan(
        pelanggan,
        paket,
        pelangganAktif,
        statusPembayaran,
      );

      // 4. Kirim pesan yang sudah diformat ke nomor telepon pelanggan via WhatsApp.
      Log.info('Memulai proses pengiriman ke nomor: ${pelanggan.telepon}.');
      await _kirimViaWhatsApp(pelanggan.telepon, pesan);
    } on Exception catch  (e, s) {
      Log.error(
        'Terjadi kesalahan fatal saat proses kirimRincianPaket.',
        e: e,
        st: s,
      );
    }
  }

  static String _buatPesan(
    final PelangganModel pelanggan,
    final PaketModel paket,
    final PelangganAktifModel pelangganAktif,
    final String statusPembayaran,
  ) {
    final namaPelanggan = pelanggan.nama;
    final namaPaket = paket.nama;
    final hargaPaket = FormatUang.formatMataUang(paket.harga.toDouble());
    final tanggalMulai = FormatTanggal.formatTanggalDanJam(
      pelangganAktif.tanggalMulai,
    );
    final tanggalBerakhir = FormatTanggal.formatTanggalDanJam(
      pelangganAktif.tanggalBerakhir,
    );

    final pesanDibuat = '''
*-- Rincian Aktivasi Paket --*

Halo, *$namaPelanggan*.
Terima kasih telah melakukan aktivasi.

Berikut adalah detail paket Anda:
-----------------------------------
📦 *Paket:*
  $namaPaket

💰 *Harga:*
  $hargaPaket

▶️ *Mulai Aktif:*
  $tanggalMulai

⏹️ *Berakhir Pada:*
  $tanggalBerakhir

✅ *Status Pembayaran:*
  $statusPembayaran
-----------------------------------

Semoga harimu menyenangkan!
''';
    Log.info('Konten pesan berhasil dibuat:\n$pesanDibuat');
    return pesanDibuat;
  }

  static Future<void> _kirimViaWhatsApp(
    final String nomorTelepon,
    final String pesan,
  ) async {
    // 1. Format nomor telepon ke standar internasional (misal: 62812...)
    Log.info('Memformat nomor telepon: $nomorTelepon');
    String formattedNumber = nomorTelepon.replaceAll(RegExp(r'[^0-9]'), '');
    if (formattedNumber.startsWith('0')) {
      formattedNumber = '62${formattedNumber.substring(1)}';
    } else if (!formattedNumber.startsWith('62')) {
      formattedNumber = '62$formattedNumber';
    }
    Log.info('Nomor telepon setelah diformat: $formattedNumber');

    // 2. Buat URI untuk WhatsApp
    final whatsappUri = Uri(
      scheme: 'https',
      host: 'wa.me',
      path: formattedNumber,
      queryParameters: {'text': pesan},
    );
    Log.info('Membuat URI WhatsApp: $whatsappUri');

    // 3. Coba luncurkan URL dengan penanganan error
    try {
      if (await canLaunchUrl(whatsappUri)) {
        Log.info('Membuka WhatsApp dengan URL...');
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
        Log.info('Berhasil membuka aplikasi WhatsApp.');
      } else {
        Log.error(
          'Tidak dapat membuka URL WhatsApp. Kemungkinan aplikasi WhatsApp tidak terinstal atau ada masalah konfigurasi di AndroidManifest.xml (queries).',
        );
      }
    } on Exception catch  (e, s) {
      Log.error(
        'Gagal total saat mencoba meluncurkan URL WhatsApp.',
        e: e,
        st: s,
      );
    }
  }
}
