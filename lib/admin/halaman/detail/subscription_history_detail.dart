// path: lib/admin/halaman/detail/subscription_history_detail.dart
// diubah: Memperbaiki nama class DetailPelangganPage menjadi CustomerDetailPage.
// diubah: Memperbaiki parameter yang dikirimkan ke CustomerDetailPage.
// diubah: Menambahkan dokumentasi untuk mengatasi error public_member_api_docs.
// diubah: Mengurutkan import directives.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wifi/admin/halaman/detail/customer_detail.dart';
import 'package:wifi/admin/halaman/detail/package_detail.dart';
import 'package:wifi/admin/halaman/form/subscription_history_form.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/customer_model.dart';
import 'package:wifi/shared/model/package_model.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/operasi/customer_operation.dart';
import 'package:wifi/shared/operasi/package_operation.dart';
import 'package:wifi/shared/operasi/transaction_operation.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/snackbar_util.dart';

// === INFORMASI DEPENDENCY ===
// 📂 FILE INI DIGUNAKAN OLEH:
//   - lib/admin/halaman/lainnya/package_activation_history.dart (PackageActivationHistoryPage)
//
// 📂 FILE INI MENGGUNAKAN:
//   - lib/admin/halaman/detail/customer_detail.dart (CustomerDetailPage)
//   - lib/admin/halaman/detail/package_detail.dart (PackageDetailPage)
//   - lib/admin/halaman/form/subscription_history_form.dart (SubscriptionHistoryForm)
//   - lib/shared/model/transaction_model.dart (TransactionModel)
//   - lib/shared/model/customer_model.dart (CustomerModel)
//   - lib/shared/model/package_model.dart (PackageModel)
//   - lib/shared/operasi/transaction_operation.dart (TransactionOperation)
//   - lib/shared/operasi/customer_operation.dart (CustomerOperation)
//   - lib/shared/operasi/package_operation.dart (PackageOperation)
//   - lib/shared/utils/format_util.dart (FormatUtil, CurrencyFormat)
//   - lib/shared/utils/snackbar_util.dart (SnackBarUtil)
//   - lib/shared/debug/log.dart (Log)

/// Halaman untuk menampilkan detail transaksi langganan.
class SubscriptionHistoryDetailPage extends StatefulWidget {
  /// ID transaksi yang akan ditampilkan.
  final String transactionId;

  /// Konstruktor untuk SubscriptionHistoryDetailPage.
  const SubscriptionHistoryDetailPage({super.key, required this.transactionId});

  @override
  State<SubscriptionHistoryDetailPage> createState() =>
      _SubscriptionHistoryDetailPageState();
}

class _SubscriptionHistoryDetailPageState
    extends State<SubscriptionHistoryDetailPage> {
  final TransactionOperation _transactionOperation = TransactionOperation();
  final PackageOperation _packageOperation = PackageOperation();
  final CustomerOperation _customerOperation = CustomerOperation();

  late Future<TransactionModel?> _transactionFuture;

  @override
  void initState() {
    super.initState();
    _loadTransactionDetails();
  }

  /// Mengambil detail transaksi dari database.
  void _loadTransactionDetails() {
    Log.info(
      'Memuat detail transaksi untuk ID: ${widget.transactionId}.',
    );
    setState(() {
      _transactionFuture =
          _transactionOperation.getTransactionById(widget.transactionId);
    });
  }

  /// Menavigasi ke halaman edit dan memuat ulang data jika ada perubahan.
  Future<void> _navigateToEditForm(final TransactionModel transaction) async {
    Log.info('Navigasi ke form edit untuk transaksi ID: ${transaction.id}');
    if (!mounted) return;
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (final context) =>
            SubscriptionHistoryForm(transaction: transaction),
      ),
    );

    if (result ?? false) {
      Log.info(
          'Form edit mengembalikan berhasil, memuat ulang detail transaksi.');
      if (mounted) {
        SnackBarUtil.success(context, 'Detail transaksi berhasil diperbarui.');
      }
      _loadTransactionDetails();
    }
  }

  @override
  Widget build(final BuildContext context) {
    Log.info('Membangun UI halaman detail langganan transaksi.');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Langganan'),
        actions: [
          FutureBuilder<TransactionModel?>(
            future: _transactionFuture,
            builder: (final context, final snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit Langganan',
                  onPressed: () =>
                      _navigateToEditForm(snapshot.data!),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: FutureBuilder<TransactionModel?>(
        future: _transactionFuture,
        builder: (final context, final snapshot) {
          Log.info(
            'FutureBuilder transaksi dijalankan dengan state: ${snapshot.connectionState}.',
          );

          if (snapshot.connectionState == ConnectionState.waiting) {
            Log.info('Data transaksi masih dalam proses loading.');
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            Log.error(
              'Terjadi kesalahan saat mengambil data transaksi.',
              e: snapshot.error,
            );
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final transaction = snapshot.data;

          if (transaction == null) {
            Log.warning('Data transaksi tidak ditemukan di database.');
            return const Center(child: Text('Transaksi tidak ditemukan'));
          }

          Log.info(
            'Berhasil memuat data transaksi dengan ID: ${transaction.id}.',
          );

          return RefreshIndicator(
            onRefresh: () async => _loadTransactionDetails(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: <Widget>[
                  if (transaction.customerId != null)
                    _buildFutureInfoCard<CustomerModel>(
                      'Informasi Pelanggan',
                      _customerOperation.getCustomerById(transaction.customerId!),
                      'Pelanggan',
                      (final customer) => [
                        _buildDetailRow(
                          'Nama Pelanggan',
                          customer?.name ?? 'Tidak Diketahui',
                        ),
                      ],
                      onTap: (final customer) {
                        if (customer != null) {
                           if (!mounted) return;
                          unawaited(Navigator.push<void>(
                            context,
                            MaterialPageRoute<void>(
                              builder: (final context) => CustomerDetailPage(
                                customerId: customer.id,
                              ),
                            ),
                          ));
                        }
                      },
                    ),
                  const SizedBox(height: 16),
                  if (transaction.packageId != null)
                    _buildFutureInfoCard<PackageModel>(
                      'Informasi Paket',
                      _packageOperation.getPackageById(transaction.packageId!),
                      'Paket',
                      (final package) => [
                        _buildDetailRow(
                          'Nama Paket',
                          package?.name ?? 'Tidak Diketahui',
                        ),
                        _buildDetailRow(
                          'Harga',
                          CurrencyFormat.formatCurrency(
                              (package?.price ?? 0).toDouble()),
                        ),
                        _buildDetailRow(
                          'Durasi',
                          '${package?.duration ?? 0} ${package?.type.name ?? ""}',
                        ),
                      ],
                      onTap: (final package) {
                        if (package != null) {
                          if (!mounted) return;
                          unawaited(Navigator.push<void>(
                            context,
                            MaterialPageRoute<void>(
                              builder: (final context) => PackageDetailPage(
                                package: package,
                              ),
                            ),
                          ));
                        }
                      },
                    ),
                  const SizedBox(height: 16),
                  _buildInfoPoints(transaction),
                  const SizedBox(height: 16),
                  if (transaction.startDate != null &&
                      transaction.endDate != null)
                    _buildInfoCard('Waktu Langganan', [
                      _buildDetailRow(
                        'Tanggal Mulai',
                        FormatUtil.formatDateAndTime(transaction.startDate!),
                      ),
                      _buildDetailRow(
                        'Tanggal Berakhir',
                        FormatUtil.formatDateAndTime(transaction.endDate!),
                      ),
                    ]),
                  const SizedBox(height: 16),
                  _buildInfoCard('Status', [
                    _buildDetailRow(
                      'Status Pembayaran',
                      transaction.paymentStatus.name.toUpperCase(),
                    ),
                  ]),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoPoints(final TransactionModel transaction) {
    Log.info('Membangun widget informasi poin transaksi.');

    if (transaction.earnedPoints == 0 && transaction.usedPoints == 0) {
      Log.info('Tidak ada perubahan poin pada transaksi ini.');
      return const SizedBox.shrink();
    }

    final isAddition = transaction.earnedPoints > transaction.usedPoints;
    final pointDifference = transaction.earnedPoints - transaction.usedPoints;

    Log.info(
      'Poin dihasilkan: ${transaction.earnedPoints}, '
      'Poin digunakan: ${transaction.usedPoints}, '
      'Selisih: $pointDifference poin (${isAddition ? "PENAMBAHAN" : "PENGURANGAN"}).',
    );

    return _buildInfoCard('Informasi Poin', [
      _buildDetailRowWithColor(
        'Poin Dihasilkan',
        '+${transaction.earnedPoints} Poin',
        transaction.earnedPoints > 0 ? Colors.green : null,
        transaction.earnedPoints > 0 ? FontWeight.bold : FontWeight.normal,
      ),
      _buildDetailRowWithColor(
        'Poin Digunakan',
        '-${transaction.usedPoints} Poin',
        transaction.usedPoints > 0 ? Colors.red : null,
        transaction.usedPoints > 0 ? FontWeight.bold : FontWeight.normal,
      ),
      const Divider(height: 16),
      _buildDetailRowWithColor(
        isAddition ? 'Total Poin Bertambah' : 'Total Poin Berkurang',
        '${pointDifference >= 0 ? "+" : ""}$pointDifference Poin',
        isAddition ? Colors.green : Colors.red,
        FontWeight.bold,
        fontSize: 16,
      ),
    ]);
  }

  Widget _buildInfoCard(final String title, final List<Widget> children,
      {final VoidCallback? onTap}) {
    Log.info('Membangun info card dengan judul: $title.');

    final cardContent = Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20, thickness: 1),
            ...children,
          ],
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: cardContent,
      );
    } else {
      return cardContent;
    }
  }

  Widget _buildFutureInfoCard<T>(
    final String title,
    final Future<T?> future,
    final String tag,
    final List<Widget> Function(T? data) builder, {
    final void Function(T? data)? onTap,
  }) {
    Log.info('Membangun Future info card untuk data $tag.');

    return FutureBuilder<T?>(
      future: future,
      builder: (final context, final snapshot) {
        Log.info(
          'FutureBuilder $tag dijalankan dengan state: ${snapshot.connectionState}.',
        );

        VoidCallback? resolvedOnTap;
        if (onTap != null &&
            snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasError &&
            snapshot.hasData) {
          resolvedOnTap = () => onTap(snapshot.data);
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          Log.info('Data $tag masih dalam proses loading.');
          return _buildInfoCard(title, [
            const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            ),
          ]);
        }

        if (snapshot.hasError) {
          Log.error('Gagal memuat data $tag.', e: snapshot.error);
          return _buildInfoCard(title, [const Text('Gagal memuat data')]);
        }

        if (snapshot.hasData) {
          Log.info('Data $tag berhasil dimuat secara asynchronous.');
        } else {
          Log.warning('Data $tag tidak ditemukan.');
        }

        return _buildInfoCard(title, builder(snapshot.data),
            onTap: resolvedOnTap);
      },
    );
  }

  Widget _buildDetailRow(final String label, final String value) {
    Log.info('Membangun detail row dengan label: $label dan value: $value.');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRowWithColor(
    final String label,
    final String value,
    final Color? valueColor,
    final FontWeight fontWeight, {
    final double fontSize = 14,
  }) {
    Log.info(
      'Membangun detail row berwarna dengan label: $label dan value: $value.',
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: fontWeight,
                color: valueColor,
                fontSize: fontSize,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
