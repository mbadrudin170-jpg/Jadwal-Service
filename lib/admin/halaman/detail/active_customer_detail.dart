// path: lib/admin/halaman/detail/active_customer_detail.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wifi/admin/halaman/detail/customer_detail.dart';
import 'package:wifi/admin/halaman/detail/package_detail.dart';
import 'package:wifi/admin/halaman/form/active_customer_form.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/active_customer_model.dart';
import 'package:wifi/shared/model/customer_model.dart';
import 'package:wifi/shared/model/package_model.dart';
import 'package:wifi/shared/operasi/active_customer_operation.dart';
import 'package:wifi/shared/operasi/customer_operation.dart';
import 'package:wifi/shared/operasi/package_operation.dart';
import 'package:wifi/shared/theme/app_sizes.dart';
import 'package:wifi/shared/utils/calculation_util.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/whatsapp/info_paket.dart';

/// Halaman untuk menampilkan detail pelanggan aktif.
class ActiveCustomerDetailPage extends ConsumerStatefulWidget {
  /// Model pelanggan aktif yang akan ditampilkan.
  final ActiveCustomerModel activeCustomer;

  /// Konstruktor untuk ActiveCustomerDetailPage.
  const ActiveCustomerDetailPage({super.key, required this.activeCustomer});

  @override
  ConsumerState<ActiveCustomerDetailPage> createState() =>
      _ActiveCustomerDetailPageState();
}

class _ActiveCustomerDetailPageState
    extends ConsumerState<ActiveCustomerDetailPage> {
  late ActiveCustomerModel _activeCustomer;
  CustomerModel? _customer;
  PackageModel? _package;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Log.info('Membuka halaman Detail Pelanggan Aktif');
    Log.info('  - ID Pelanggan Aktif: ${widget.activeCustomer.id}');
    Log.info('  - ID Pelanggan: ${widget.activeCustomer.customerId}');
    Log.info('  - ID Paket: ${widget.activeCustomer.packageId}');
    Log.info('  - Status: ${widget.activeCustomer.status.displayName}');

    _activeCustomer = widget.activeCustomer;
    unawaited(_loadDetails());
  }

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
      if (mounted) {
        ToastUtil.error(
          context,
          'Tidak dapat membuka WhatsApp. Pastikan sudah terinstal.',
        );
      }
    }
  }

  Future<void> _loadDetails() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    Log.info('Memuat detail pelanggan dan paket...');

    final customerOperation = ref.read(customerOperationProvider);
    final packageOperation = ref.read(packageOperationProvider);
    final packageId = _activeCustomer.packageId;

    try {
      final results = await Future.wait<dynamic>([
        customerOperation.getById(_activeCustomer.customerId),
        if (packageId.isNotEmpty)
          packageOperation.getById(packageId)
        else
          Future<PackageModel?>.value(),
      ]);

      if (mounted) {
        setState(() {
          _customer = results[0] as CustomerModel?;
          _package = results.length > 1 ? results[1] as PackageModel? : null;
          _isLoading = false;
        });
        Log.info(
            'Detail pelanggan berhasil dimuat. Customer: ${_customer?.name}, Paket: ${_package?.name}');
      }
    } on Exception catch (e, s) {
      Log.error('Gagal memuat detail pelanggan aktif', e: e, st: s);
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _navigateToEdit() async {
    Log.info('Navigasi ke form edit pelanggan aktif ID: ${_activeCustomer.id}');
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (final context) =>
            FormPelangganAktif(pelangganAktif: _activeCustomer),
      ),
    );

    if (result ?? false) {
      Log.info('Kembali dari edit dengan perubahan. Memuat ulang data.');
      final operation = ref.read(activeCustomerOperationProvider);
      final updatedActiveCustomer =
          await operation.getActiveCustomerById(_activeCustomer.id);
      if (mounted && updatedActiveCustomer != null) {
        setState(() {
          _activeCustomer = updatedActiveCustomer;
        });
        await _loadDetails();
      }
    } else {
      Log.info('Kembali dari edit tanpa perubahan.');
    }
  }

  @override
  Widget build(final BuildContext context) {
    Log.info('Membangun UI detail pelanggan aktif.');
    return Scaffold(
      appBar: AppBar(
        title: Text(_customer?.name ?? 'Detail Pelanggan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, true),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _navigateToEdit,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  final customer = _customer;
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
                                  _customer?.name ?? _activeCustomer.customerId,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(color: Colors.blue),
                                ),
                              ),
                            ),
                            gapH16,
                            const Divider(),
                            _buildWhatsAppInfoRow(
                              'No HP',
                              _customer?.phone ?? 'Tidak ditemukan',
                            ),
                            InkWell(
                              onTap: () {
                                final pkg = _package;
                                if (pkg != null) {
                                  Log.info(
                                      'Navigasi ke detail paket: ${pkg.name}');
                                  unawaited(Navigator.push<void>(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (final context) =>
                                          PackageDetailPage(package: pkg),
                                    ),
                                  ));
                                }
                              },
                              child: _buildInfoRow(
                                'Paket',
                                _package?.name ??
                                    ' (ID: ${_activeCustomer.packageId})',
                              ),
                            ),
                            _buildInfoRow(
                              'Status',
                              _activeCustomer.status.displayName,
                            ),
                            if (_package != null)
                              _buildInfoRow(
                                'Poin Diperoleh',
                                '${_package!.rewardPoints} Poin',
                              ),
                            _buildInfoRow(
                              'Mulai',
                              FormatDateTime.formatDateAndTimeCompact(
                                  _activeCustomer.startDate),
                            ),
                            _buildInfoRow(
                              'Berakhir',
                              FormatDateTime.formatDateAndTimeCompact(
                                  _activeCustomer.endDate),
                            ),
                            const Divider(),
                            gapH16,
                            Text(
                              CalculationUtil.getRemainingActivePeriodText(
                                _activeCustomer.endDate,
                              ),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: CalculationUtil
                                        .getRemainingActivePeriodColor(
                                      _activeCustomer.endDate,
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
                                unawaited(pesanInfoPaket
                                    .kirimRincianPaket(_activeCustomer));
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
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoRow(final String label, final String value) {
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

  Widget _buildWhatsAppInfoRow(final String label, final String value) {
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
}
