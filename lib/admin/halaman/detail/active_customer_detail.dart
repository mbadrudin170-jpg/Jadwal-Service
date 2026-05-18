// path: lib/admin/halaman/detail/active_customer_detail.dart
//
// 📂 FILE INI DIGUNAKAN OLEH:
//   - Digunakan sebagai halaman detail pelanggan aktif dari daftar pelanggan aktif.
//
// 📂 FILE INI MENGGUNAKAN:
//   - lib/admin/halaman/detail/customer_detail.dart (CustomerDetailPage)
//   - lib/admin/halaman/detail/package_detail.dart (PackageDetailPage)
//   - lib/admin/halaman/form/active_customer_form.dart (FormPelangganAktif)
//   - lib/shared/model/active_customer_model.dart (ActiveCustomerModel)
//   - lib/shared/model/customer_model.dart (CustomerModel)
//   - lib/shared/model/package_model.dart (PackageModel)
//   - lib/shared/operasi/active_customer_operation.dart (ActiveCustomerOperation)
//   - lib/shared/operasi/customer_operation.dart (CustomerOperation)
//   - lib/shared/operasi/package_operation.dart (PackageOperation)
//   - lib/shared/utils/calculation_util.dart (CalculationUtil)
//   - lib/shared/utils/format_util.dart (FormatUtil, TimeFormat)
//   - lib/shared/utils/snackbar_util.dart (SnackBarUtil)
//   - lib/shared/whatsapp/info_paket.dart (PesanInfoPaket)
//   - lib/shared/debug/log.dart (Log)

import 'dart:async';

import 'package:flutter/material.dart';
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
import 'package:wifi/shared/utils/calculation_util.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/snackbar_util.dart';
import 'package:wifi/shared/whatsapp/info_paket.dart';

/// Halaman untuk menampilkan detail pelanggan aktif.
class ActiveCustomerDetailPage extends StatefulWidget {
  /// Model pelanggan aktif yang akan ditampilkan.
  final ActiveCustomerModel activeCustomer;

  /// Konstruktor untuk ActiveCustomerDetailPage.
  const ActiveCustomerDetailPage({super.key, required this.activeCustomer});

  @override
  State<ActiveCustomerDetailPage> createState() =>
      _ActiveCustomerDetailPageState();
}

class _ActiveCustomerDetailPageState extends State<ActiveCustomerDetailPage> {
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
    Log.info('  - Status: ${widget.activeCustomer.status.name}');

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
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch $whatsappUri');
      }
    } on Exception catch (e, s) {
      Log.error('Gagal membuka WhatsApp', e: e, st: s);
      if (mounted) {
        SnackBarUtil.error(
          context,
          'Tidak dapat membuka WhatsApp. Pastikan sudah terinstal.',
        );
      }
    }
  }

  Future<void> _loadDetails() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final customerOperation = CustomerOperation();
    final packageOperation = PackageOperation();
    final packageId = _activeCustomer.packageId;

    try {
      final results = await Future.wait<dynamic>([
        customerOperation.getCustomerById(_activeCustomer.customerId),
        if (packageId.isNotEmpty)
          packageOperation.getPackageById(packageId)
        else
          Future<PackageModel?>.value(),
      ]);

      if (mounted) {
        setState(() {
          _customer = results[0] as CustomerModel?;
          _package = results.length > 1 ? results[1] as PackageModel? : null;
          _isLoading = false;
        });
      }
    } on Exception catch (e, s) {
      Log.error('Gagal memuat detail pelanggan aktif', e: e, st: s);
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _navigateToEdit() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (final context) =>
            FormPelangganAktif(pelangganAktif: _activeCustomer),
      ),
    );

    if (result ?? false) {
      final operation = ActiveCustomerOperation();
      final updatedActiveCustomer =
          await operation.getActiveCustomerById(_activeCustomer.id);

      if (mounted && updatedActiveCustomer != null) {
        setState(() {
          _activeCustomer = updatedActiveCustomer;
        });
        await _loadDetails();
      }
    }
  }

  @override
  Widget build(final BuildContext context) {
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
                            const SizedBox(height: 16),
                            const Divider(),
                            _buildWhatsAppInfoRow(
                              'No HP',
                              _customer?.phone ?? 'Tidak ditemukan',
                            ),
                            InkWell(
                              onTap: () {
                                final pkg = _package;
                                if (pkg != null) {
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
                              _activeCustomer.status.name,
                            ),
                            if (_package != null)
                              _buildInfoRow(
                                'Poin Diperoleh',
                                '${_package!.rewardPoints} Poin',
                              ),
                            _buildInfoRow(
                              'Mulai',
                              '${FormatDateTime.formatDateAndTimeCompact(_activeCustomer.startDate)} - ${TimeFormat.formatHourMinute(_activeCustomer.startDate)}',
                            ),
                            _buildInfoRow(
                              'Berakhir',
                              '${FormatDateTime.formatDateAndTimeCompact(_activeCustomer.endDate)} - ${TimeFormat.formatHourMinute(_activeCustomer.endDate)}',
                            ),
                            const Divider(),
                            const SizedBox(height: 16),
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
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.send_to_mobile),
                              label: const Text('Kirim Info via WhatsApp'),
                              onPressed: () {
                                unawaited(PesanInfoPaket.kirimRincianPaket(
                                    _activeCustomer));
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
          const SizedBox(width: 8),
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
                  const SizedBox(width: 8),
                  FaIcon(
                    FontAwesomeIcons.whatsapp,
                    color: Colors.green.shade700,
                    size: 20,
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
