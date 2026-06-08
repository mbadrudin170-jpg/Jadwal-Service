// path: lib/admin/halaman/detail/active_customer_detail.dart

import 'dart:async';

import 'package:collection/collection.dart'; // Import untuk firstWhereOrNull
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wifi/admin/halaman/detail/customer_detail.dart';
import 'package:wifi/admin/halaman/detail/package_detail.dart';
import 'package:wifi/admin/halaman/form/active_customer_form.dart';
import 'package:wifi/admin/providers/active_customer_provider.dart'; // Import activeCustomerProvider
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/active_customer_model.dart';
import 'package:wifi/shared/model/customer_model.dart';
import 'package:wifi/shared/model/package_model.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/operasi_sqlite_provider/operasi_sqlite_provider.dart';
import 'package:wifi/shared/theme/app_sizes.dart';
import 'package:wifi/shared/utils/calculation_util.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/whatsapp/info_paket.dart';

/// Provider untuk memuat detail lengkap pelanggan aktif secara asinkron.
final activeCustomerDetailProvider = FutureProvider.family<
    ({
      CustomerModel? customer,
      PackageModel? package,
      TransactionModel? transaction,
      ActiveCustomerModel activeCustomer,
    }),
    String>((ref, id) async {
  // 1. Ambil daftar pelanggan aktif dari activeCustomerProvider
  final activeCustomerState = await ref.watch(activeCustomerProvider.future);
  final activeCustomerDetails = activeCustomerState.activeCustomers;

  // 2. Cari ActiveCustomerDetailModel yang sesuai dengan ID
  final detailModel = activeCustomerDetails.firstWhereOrNull(
    (detail) => detail.activeCustomer.id == id,
  );

  if (detailModel == null) {
    throw Exception('Data pelanggan aktif tidak ditemukan dalam daftar.');
  }

  final activeCustomer = detailModel.activeCustomer;

  // 3. Fetch detail tambahan menggunakan operasi individual
  final customerOp = ref.watch(customerOperationProvider);
  final packageOp = ref.watch(packageOperationProvider);
  final transactionOp = ref.watch(transactionOperationProvider);
  final results = await Future.wait([
    customerOp.getById(activeCustomer.customerId),
    activeCustomer.packageId.isNotEmpty
        ? packageOp.getById(activeCustomer.packageId)
        : Future.value(),
    (activeCustomer.transactionId != null &&
            activeCustomer.transactionId!.isNotEmpty)
        ? transactionOp.getTransactionById(activeCustomer.transactionId!)
        : Future.value(),
  ]);

  return (
    customer: results[0] as CustomerModel?,
    package: results[1] as PackageModel?,
    transaction: results[2] as TransactionModel?,
    activeCustomer: activeCustomer,
  );
});

class ActiveCustomerDetailPage extends ConsumerStatefulWidget {
  final ActiveCustomerModel activeCustomer;
  const ActiveCustomerDetailPage({super.key, required this.activeCustomer});
  @override
  ConsumerState<ActiveCustomerDetailPage> createState() =>
      _ActiveCustomerDetailPageState();
}

class _ActiveCustomerDetailPageState
    extends ConsumerState<ActiveCustomerDetailPage> {
  // 1. Meluncurkan aplikasi WhatsApp
  Future<void> _launchWhatsApp(final String phoneNumber) async {
    String formattedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

    if (formattedNumber.startsWith('0')) {
      formattedNumber = '62${formattedNumber.substring(1)}';
    } else if (!formattedNumber.startsWith('62')) {
      formattedNumber = '62$formattedNumber';
    }

    final Uri whatsappUri = Uri.parse('https://wa.me/$formattedNumber');

    try {
      Log.info('Mencoba membuka WhatsApp: $formattedNumber');
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
        Log.info('Berhasil membuka WhatsApp.');
      } else {
        throw Exception('Could not launch $whatsappUri');
      }
    } on Exception catch (e, s) {
      Log.error('Gagal membuka WhatsApp', e: e, st: s);
      if (context.mounted) {
        ToastUtil.error(
          context,
          'Tidak dapat membuka WhatsApp. Pastikan sudah terinstal.',
        );
      }
    }
  }

  // 2. Navigasi ke halaman edit pelanggan aktif
  Future<void> _navigateToEdit(ActiveCustomerModel model) async {
    Log.info('Navigasi ke form edit pelanggan aktif ID: ${model.id}');
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => FormPelangganAktif(pelangganAktif: model),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Log.info('Membuka halaman Detail Pelanggan Aktif');
    Log.info('  - ID Pelanggan Aktif: ${widget.activeCustomer.id}');
  }

  @override
  Widget build(BuildContext context) {
    Log.info(
        'Membangun UI detail pelanggan aktif untuk ID: ${widget.activeCustomer.id}.');
    final detailAsync =
        ref.watch(activeCustomerDetailProvider(widget.activeCustomer.id));
    return detailAsync.when(
      data: (data) => _buildScaffold(context, data),
      loading: () => const Scaffold(body: Center(child: Text(''))),
      error: (e, s) =>
          Scaffold(body: Center(child: Text('Terjadi kesalahan: $e'))),
    );
  }

  // 3. Membangun Scaffold utama halaman detail
  Widget _buildScaffold(
    BuildContext context,
    ({
      CustomerModel? customer,
      PackageModel? package,
      TransactionModel? transaction,
      ActiveCustomerModel activeCustomer
    }) data,
  ) {
    final activeCustomer = data.activeCustomer;
    final customer = data.customer;
    final package = data.package;
    final transaction = data.transaction;

    return Scaffold(
      appBar: AppBar(
        title: Text(customer?.name ?? 'Detail Pelanggan'),
        actions: [
          // 4. Tombol edit di AppBar
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEdit(activeCustomer),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 5. Kartu informasi utama
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    // 6. Nama pelanggan (bisa diklik)
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: TextButton(
                          onPressed: () {
                            if (customer != null) {
                              Log.info(
                                  'Navigasi ke detail pelanggan: ${customer.name}');
                              unawaited(Navigator.push<void>(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (final context) =>
                                      CustomerDetailPage(
                                    customerId: customer.id,
                                  ),
                                ),
                              ));
                            }
                          },
                          child: Text(
                            customer?.name ?? activeCustomer.customerId,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(color: Colors.blue),
                          ),
                        ),
                      ),
                      gapH16, // 7. Divider
                      const Divider(), // 8. Baris info WhatsApp
                      _buildWhatsAppInfoRow(
                        // 9. Baris info paket (bisa diklik)
                        context,
                        'No HP',
                        customer?.phone ??
                            'Tidak ditemukan', // 10. Baris info status
                      ),
                      InkWell(
                        onTap: () {
                          if (package != null) {
                            Log.info(
                                'Navigasi ke detail paket: ${package.name}');
                            unawaited(Navigator.push<void>(
                              context,
                              MaterialPageRoute<void>(
                                builder: (final context) =>
                                    PackageDetailPage(package: package),
                              ),
                            ));
                          }
                        },
                        child: _buildInfoRow(
                          context,
                          'Paket',
                          package?.name ?? ' (ID: ${activeCustomer.packageId})',
                        ),
                      ),
                      _buildInfoRow(
                        context,
                        'Status',
                        activeCustomer.status.displayName,
                      ),
                      if (package != null)
                        _buildInfoRow(
                          context,
                          'Poin Diperoleh',
                          '${package.rewardPoints} Poin',
                        ),
                      if (transaction != null &&
                          (transaction.durasiBonus ?? 0) > 0)
                        _buildInfoRow(
                          context,
                          'Bonus',
                          '${transaction.durasiBonus} ${transaction.durasiBonusType?.displayName ?? ""}',
                        ),
                      _buildInfoRow(
                        context,
                        'Mulai',
                        FormatDateTime.formatDateAndTimeCompact(
                            activeCustomer.startDate),
                      ),
                      _buildInfoRow(
                        context,
                        'Berakhir',
                        FormatDateTime.formatDateAndTimeCompact(
                            activeCustomer.endDate),
                      ),
                      const Divider(),
                      gapH16,
                      Text(
                        CalculationUtil.getRemainingActivePeriodText(
                          activeCustomer.endDate,
                        ),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color:
                                  CalculationUtil.getRemainingActivePeriodColor(
                                activeCustomer.endDate,
                              ),
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      gapH24,
                      ElevatedButton.icon(
                        icon: const Icon(Icons.send_to_mobile),
                        label: const Text('Kirim Info via WhatsApp'),
                        onPressed: () {
                          Log.info('Tombol kirim info WhatsApp ditekan.');
                          final pesanInfoPaket =
                              ref.read(pesanInfoPaketProvider);
                          unawaited(
                              pesanInfoPaket.kirimRincianPaket(activeCustomer));
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ], // 33. Label tombol
                  ), // 34. Fungsi onPressed
                ), // 35. Logika untuk mengirim info paket via WhatsApp
              ), // 36. Menggunakan pesanInfoPaketProvider
            ], // 37. Logika untuk tombol
          ),
        ),
      ),
    );
  } // 38. Style tombol

  Widget _buildInfoRow(
      // 39. Padding tombol
      BuildContext context,
      final String label,
      final String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          gapH8,
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  // 40. Warna tombol
  Widget _buildWhatsAppInfoRow(
      BuildContext context, final String label, final String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          InkWell(
            onTap: () => _launchWhatsApp(value),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              child: Row(
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                  ),
                  gapH8,
                  FaIcon(
                    FontAwesomeIcons.whatsapp,
                    color: Colors.green.shade700,
                    size: TSizes.p20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} // 41. Warna teks tombol
