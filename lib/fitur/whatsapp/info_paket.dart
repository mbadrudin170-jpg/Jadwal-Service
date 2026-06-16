// path: lib/fitur/whatsapp/info_paket.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:wifi/fitur/paket/operasi/paket_op_sqlite.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_sqlite.dart';
import 'package:wifi/shared/utils/format_util.dart';

final pesanInfoPaketProvider = Provider<PesanInfoPaket>((ref) {
  return PesanInfoPaket(
    pelangganAktifOpSqlite: ref.read(pelangganOpSqliteProvider),
    paketOpSqlite: ref.read(paketOpSqliteProvider),
  );
});

/// Kelas untuk mengirim pesan informasi paket melalui WhatsApp.
class PesanInfoPaket {
  final PelangganOpSqlite _pelangganAktifOpSqlite;
  final PaketOpSqlite _paketOpSqlite;

  PesanInfoPaket({
    required PelangganOpSqlite pelangganAktifOpSqlite,
    required PaketOpSqlite paketOpSqlite,
  }) : _pelangganAktifOpSqlite = pelangganAktifOpSqlite,
       _paketOpSqlite = paketOpSqlite;

  /// Mengambil detail pelanggan dan paket, membuat pesan,
  /// lalu mengirimkannya melalui WhatsApp.
  Future<void> kirimRincianPaket(PelangganAktifModel activeCustomer) async {
    Log.info(
      'Memulai proses pengiriman rincian paket via WhatsApp untuk pelanggan aktif ID: ${activeCustomer.id}',
    );

    try {
      Log.info(
        'Mengambil data pelanggan dengan ID: ${activeCustomer.idPelanggan}',
      );
      final PelangganModel? customer = await _pelangganAktifOpSqlite
          .ambilBerdasarkanId(activeCustomer.idPelanggan);
      Log.info('Mengambil data paket dengan ID: ${activeCustomer.idPaket}');
      final PaketModel? package = await _paketOpSqlite.ambilBerdasarkanId(
        activeCustomer.idPaket,
      );

      if (customer == null) {
        Log.warning(
          'Pengiriman pesan dibatalkan. Pelanggan dengan ID ${activeCustomer.idPelanggan} tidak ditemukan.',
        );
        return;
      }
      if (package == null) {
        Log.warning(
          'Pengiriman pesan dibatalkan. Paket dengan ID ${activeCustomer.idPaket} tidak ditemukan.',
        );
        return;
      }

      final String paymentStatus = activeCustomer.status.name;
      final String message = _buildMessage(
        customer,
        package,
        activeCustomer,
        paymentStatus,
      );

      await _sendViaWhatsApp(customer.telepon, message);
    } catch (e, s) {
      Log.error(
        'Terjadi kesalahan fatal saat proses kirimRincianPaket.',
        e: e,
        s: s,
      );
    }
  }

  String _buildMessage(
    PelangganModel pelanggan,
    PaketModel paket,
    PelangganAktifModel pelangganAktif,
    String paymentStatus,
  ) {
    final namaPelanggan = pelanggan.nama;
    final namaPaket = paket.nama;
    final hargaPaket = FormatUang.formatMataUang(paket.harga.toDouble());
    final tanggalMulai = FormatWaktuLengkap.formatSingkat(
      pelangganAktif.tanggalMulai,
    );
    final tanggalBerakhir = FormatWaktuLengkap.formatSingkat(
      pelangganAktif.tanggalBerakhir,
    );

    final pesan =
        '''
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
  $paymentStatus
-----------------------------------

Semoga harimu menyenangkan!
''';
    Log.info('Konten pesan berhasil dibuat.');
    return pesan;
  }

  Future<void> _sendViaWhatsApp(String telepon, String pesan) async {
    Log.info('Memformat nomor telepon: $telepon');
    String formatNomor = telepon.replaceAll(RegExp(r'[^0-9]'), '');
    if (formatNomor.startsWith('0')) {
      formatNomor = '62${formatNomor.substring(1)}';
    } else if (!formatNomor.startsWith('62')) {
      formatNomor = '62$formatNomor';
    }
    Log.info('Nomor telepon setelah diformat: $formatNomor');

    final urlWatsapp = Uri(
      scheme: 'https',
      host: 'wa.me',
      path: formatNomor,
      queryParameters: {'text': pesan},
    );

    try {
      if (await canLaunchUrl(urlWatsapp)) {
        await launchUrl(urlWatsapp, mode: LaunchMode.externalApplication);
        Log.info('Berhasil membuka aplikasi WhatsApp.');
      } else {
        Log.error(
          'Tidak dapat membuka URL WhatsApp. Kemungkinan aplikasi WhatsApp tidak terinstal.',
        );
      }
    } catch (e, s) {
      Log.error(
        'Gagal total saat mencoba meluncurkan URL WhatsApp.',
        e: e,
        s: s,
      );
    }
  }
}
