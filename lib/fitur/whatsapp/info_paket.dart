// path: lib/fitur/whatsapp/info_paket.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/active_customer_model.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/paket_op_Sqlite.dart';
import 'package:wifi/shared/utils/format_util.dart';

final pesanInfoPaketProvider = Provider<PesanInfoPaket>((ref) {
  return PesanInfoPaket(
    customerOperation: ref.read(pelangganOpSqliteProvider),
    packageOperation: ref.read(packageOperationProvider),
  );
});

/// Kelas untuk mengirim pesan informasi paket melalui WhatsApp.
class PesanInfoPaket {
  final PelangganOpSqlite _customerOperation;
  final PaketOpSqlite _packageOperation;

  PesanInfoPaket({
    required PelangganOpSqlite customerOperation,
    required PaketOpSqlite packageOperation,
  })  : _customerOperation = customerOperation,
        _packageOperation = packageOperation;

  /// Mengambil detail pelanggan dan paket, membuat pesan,
  /// lalu mengirimkannya melalui WhatsApp.
  Future<void> kirimRincianPaket(PelangganAktifModel activeCustomer) async {
    Log.info(
      'Memulai proses pengiriman rincian paket via WhatsApp untuk pelanggan aktif ID: ${activeCustomer.id}',
    );

    try {
      Log.info(
          'Mengambil data pelanggan dengan ID: ${activeCustomer.customerId}');
      final PelangganModel? customer = await _customerOperation.getById(
        activeCustomer.customerId,
      );
      Log.info('Mengambil data paket dengan ID: ${activeCustomer.packageId}');
      final PaketModel? package = await _packageOperation.getById(
        activeCustomer.packageId,
      );

      if (customer == null) {
        Log.warning(
          'Pengiriman pesan dibatalkan. Pelanggan dengan ID ${activeCustomer.customerId} tidak ditemukan.',
        );
        return;
      }
      if (package == null) {
        Log.warning(
          'Pengiriman pesan dibatalkan. Paket dengan ID ${activeCustomer.packageId} tidak ditemukan.',
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

      await _sendViaWhatsApp(customer.phone, message);
    } on Exception catch (e, s) {
      Log.error(
        'Terjadi kesalahan fatal saat proses kirimRincianPaket.',
        e: e,
        s: s,
      );
    }
  }

  String _buildMessage(
    PelangganModel customer,
    PaketModel package,
    PelangganAktifModel activeCustomer,
    String paymentStatus,
  ) {
    final customerName = customer.name;
    final packageName = package.name;
    final packagePrice =
        CurrencyFormat.formatCurrency(package.price.toDouble());
    final startDate =
        FormatDateTime.formatDateAndTimeCompact(activeCustomer.startDate);
    final endDate =
        FormatDateTime.formatDateAndTimeCompact(activeCustomer.endDate);

    final message = '''
*-- Rincian Aktivasi Paket --*

Halo, *$customerName*.
Terima kasih telah melakukan aktivasi.

Berikut adalah detail paket Anda:
-----------------------------------
📦 *Paket:*
  $packageName

💰 *Harga:*
  $packagePrice

▶️ *Mulai Aktif:*
  $startDate

⏹️ *Berakhir Pada:*
  $endDate

✅ *Status Pembayaran:*
  $paymentStatus
-----------------------------------

Semoga harimu menyenangkan!
''';
    Log.info('Konten pesan berhasil dibuat.');
    return message;
  }

  Future<void> _sendViaWhatsApp(String phoneNumber, String message) async {
    Log.info('Memformat nomor telepon: $phoneNumber');
    String formattedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (formattedNumber.startsWith('0')) {
      formattedNumber = '62${formattedNumber.substring(1)}';
    } else if (!formattedNumber.startsWith('62')) {
      formattedNumber = '62$formattedNumber';
    }
    Log.info('Nomor telepon setelah diformat: $formattedNumber');

    final whatsappUri = Uri(
      scheme: 'https',
      host: 'wa.me',
      path: formattedNumber,
      queryParameters: {'text': message},
    );

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
        Log.info('Berhasil membuka aplikasi WhatsApp.');
      } else {
        Log.error(
          'Tidak dapat membuka URL WhatsApp. Kemungkinan aplikasi WhatsApp tidak terinstal.',
        );
      }
    } on Exception catch (e, s) {
      Log.error('Gagal total saat mencoba meluncurkan URL WhatsApp.',
          e: e, s: s);
    }
  }
}
