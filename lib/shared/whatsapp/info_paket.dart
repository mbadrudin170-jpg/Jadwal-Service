// path: lib/shared/whatsapp/info_paket.dart
//
// 📂 FILE INI DIGUNAKAN OLEH:
//   - lib/admin/halaman/detail/active_customer_detail.dart
//   - lib/admin/halaman/form/active_customer_form.dart
//
// 📂 FILE INI MENGGUNAKAN:
//   - lib/shared/model/active_customer_model.dart (ActiveCustomerModel)
//   - lib/shared/model/customer_model.dart (CustomerModel)
//   - lib/shared/model/package_model.dart (PackageModel)
//   - lib/shared/operasi/customer_operation.dart (CustomerOperation)
//   - lib/shared/operasi/package_operation.dart (PackageOperation)
//   - lib/shared/utils/format_util.dart (FormatUtil, CurrencyFormat)
//   - lib/shared/debug/log.dart (Log)

import 'package:url_launcher/url_launcher.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/active_customer_model.dart';
import 'package:wifi/shared/model/customer_model.dart';
import 'package:wifi/shared/model/package_model.dart';
import 'package:wifi/shared/operasi/customer_operation.dart';
import 'package:wifi/shared/operasi/package_operation.dart';
import 'package:wifi/shared/utils/format_util.dart';

/// Kelas utilitas untuk membuat dan mengirim pesan informasi paket.
class PesanInfoPaket {
  /// Mengambil detail pelanggan dan paket, membuat pesan,
  /// lalu secara otomatis mengirimkannya melalui WhatsApp.
  ///
  /// [activeCustomer]: Objek ActiveCustomerModel yang baru saja dibuat atau diperbarui.
  static Future<void> kirimRincianPaket(
    final ActiveCustomerModel activeCustomer,
  ) async {
    Log.info(
      'Memulai proses pengiriman rincian paket via WhatsApp untuk pelanggan aktif ID: ${activeCustomer.id}',
    );
    final customerOperation = CustomerOperation();
    final packageOperation = PackageOperation();

    try {
      Log.info(
        'Mengambil data pelanggan dengan ID: ${activeCustomer.customerId}',
      );
      final CustomerModel? customer = await customerOperation.getById(
        activeCustomer.customerId,
      );
      Log.info('Mengambil data paket dengan ID: ${activeCustomer.packageId}');
      final PackageModel? package = await packageOperation.getById(
        activeCustomer.packageId,
      );

      if (customer == null) {
        Log.warning(
          'Pengiriman pesan dibatalkan. Pelanggan dengan ID ${activeCustomer.customerId} tidak ditemukan di database lokal.',
        );
        return;
      }
      if (package == null) {
        Log.warning(
          'Pengiriman pesan dibatalkan. Paket dengan ID ${activeCustomer.packageId} tidak ditemukan di database lokal.',
        );
        return;
      }

      Log.info(
        'Berhasil menemukan data pelanggan: ${customer.name} dan paket: ${package.name}',
      );

      final String paymentStatus = activeCustomer.status.name;
      Log.info('Status pembayaran yang akan dikirim: $paymentStatus');

      Log.info('Membuat konten pesan WhatsApp.');
      final String message = _buildMessage(
        customer,
        package,
        activeCustomer,
        paymentStatus,
      );

      Log.info('Memulai proses pengiriman ke nomor: ${customer.phone}.');
      await _sendViaWhatsApp(customer.phone, message);
    } on Exception catch (e, s) {
      Log.error(
        'Terjadi kesalahan fatal saat proses kirimRincianPaket.',
        e: e,
        st: s,
      );
    }
  }

  static String _buildMessage(
    final CustomerModel customer,
    final PackageModel package,
    final ActiveCustomerModel activeCustomer,
    final String paymentStatus,
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
    Log.info('Konten pesan berhasil dibuat:\n$message');
    return message;
  }

  static Future<void> _sendViaWhatsApp(
    final String phoneNumber,
    final String message,
  ) async {
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
    Log.info('Membuat URI WhatsApp: $whatsappUri');

    try {
      if (await canLaunchUrl(whatsappUri)) {
        Log.info('Membuka WhatsApp dengan URL...');
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
        Log.info('Berhasil membuka aplikasi WhatsApp.');
      } else {
        Log.error(
          'Tidak dapat membuka URL WhatsApp. Kemungkinan aplikasi WhatsApp tidak terinstal.',
        );
      }
    } on Exception catch (e, s) {
      Log.error(
        'Gagal total saat mencoba meluncurkan URL WhatsApp.',
        e: e,
        st: s,
      );
    }
  }
}
