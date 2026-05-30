// path: lib/admin/halaman/detail/transaction_detail.dart

import 'package:flutter/material.dart';
import 'package:wifi/admin/halaman/form/transaction_form.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/export/operation.dart';
import 'package:wifi/shared/theme/app_sizes.dart';
import 'package:wifi/shared/utils/format_util.dart';

/// Halaman untuk menampilkan detail dari sebuah transaksi.
class TransactionDetailPage extends StatefulWidget {
  /// Model transaksi yang akan ditampilkan.
  final TransactionModel transaction;

  /// Konstruktor untuk TransactionDetailPage.
  const TransactionDetailPage({super.key, required this.transaction});

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  final WalletOperation _walletOperation = WalletOperation();
  final CategoryOperation _categoryOperation = CategoryOperation();
  final CustomerOperation _customerOperation = CustomerOperation();
  final PackageOperation _packageOperation = PackageOperation();
  final SubCategoryOperation _subCategoryOperation = SubCategoryOperation();

  late TransactionModel _currentTransaction;
  bool _diUpdate = false;

  @override
  void initState() {
    super.initState();
    _currentTransaction = widget.transaction;
    Log.info('Membuka halaman Detail Transaksi ID: ${_currentTransaction.id}');
  }

  Future<String?> _getName(
    final Future<dynamic> Function(String) getModel,
    final String id,
    final String label,
  ) async {
    if (id.isEmpty) return null;

    try {
      final model = await getModel(id);
      if (model != null) {
        String? name;
        if (model is WalletModel) name = model.name;
        if (model is CategoryModel) name = model.name;
        if (model is SubCategoryModel) name = model.name;
        if (model is CustomerModel) name = model.name;
        if (model is PackageModel) name = model.name;
        return name ?? 'Nama tidak tersedia';
      }
      return 'Data tidak ditemukan';
    } on Exception {
      return 'Error Memuat';
    }
  }

  Future<void> _openEditForm() async {
    Log.info(
        'Membuka FormTransaksiPage dari halaman detail untuk mengedit transaksi: ${_currentTransaction.id}');
    final updatedTransaction = await Navigator.push<TransactionModel?>(
      context,
      MaterialPageRoute<TransactionModel?>(
        builder: (final context) =>
            FormTransaksiPage(transaction: _currentTransaction),
      ),
    );
    if (updatedTransaction != null) {
      Log.info(
          'Transaksi ${_currentTransaction.id} diperbarui. Memperbarui UI detail dan menandai untuk reload.');
      setState(() {
        _currentTransaction = updatedTransaction;
        _diUpdate = true;
      });
    } else {
      Log.info('Kembali dari form edit tanpa pembaruan.');
    }
  }

  @override
  Widget build(final BuildContext context) {
    final transaction = _currentTransaction;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, _diUpdate),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _openEditForm,
            tooltip: 'Edit Transaksi',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildDetailRow('Keterangan', transaction.description),
            _buildDetailRow(
              'Tanggal',
              FormatDateTime.formatDateAndTimeCompact(transaction.date),
            ),
            _buildDetailRow(
                'Jumlah', CurrencyFormat.formatCurrency(transaction.amount)),
            _buildDetailRow('Tipe', transaction.type.displayName),
            _buildFutureDetailRow(
              'Dompet',
              _getName(
                _walletOperation.getWalletById,
                transaction.walletId,
                'Dompet',
              ),
            ),
            if (transaction.destinationWalletId != null &&
                transaction.destinationWalletId!.isNotEmpty)
              _buildFutureDetailRow(
                'Dompet Tujuan',
                _getName(
                  _walletOperation.getWalletById,
                  transaction.destinationWalletId!,
                  'Dompet Tujuan',
                ),
              ),
            _buildFutureDetailRow(
              'Kategori',
              _getName(
                _categoryOperation.getCategoryById,
                transaction.categoryId,
                'Kategori',
              ),
            ),
            if (transaction.subCategoryId != null &&
                transaction.subCategoryId!.isNotEmpty)
              _buildFutureDetailRow(
                'Sub Kategori',
                _getName(
                  _subCategoryOperation.getSubCategoryById,
                  transaction.subCategoryId!,
                  'Sub-Kategori',
                ),
              ),
            if (transaction.customerId != null &&
                transaction.customerId!.isNotEmpty)
              _buildFutureDetailRow(
                'Pelanggan',
                _getName(
                  _customerOperation.getById,
                  transaction.customerId!,
                  'Pelanggan',
                ),
              ),
            if (transaction.packageId != null &&
                transaction.packageId!.isNotEmpty)
              _buildFutureDetailRow(
                'Paket',
                _getName(
                  _packageOperation.getById,
                  transaction.packageId!,
                  'Paket',
                ),
              ),
            _buildDetailRow(
              'Status Pembayaran',
              transaction.paymentStatus.displayName,
            ),
            _buildDetailRow(
                'Poin Dihasilkan', transaction.earnedPoints.toString()),
            _buildDetailRow(
                'Poin Digunakan', transaction.usedPoints.toString()),
            if (transaction.startDate != null)
              _buildDetailRow(
                'Masa Aktif Mulai',
                FormatDateTime.formatDateAndTimeCompact(transaction.startDate!),
              ),
            if (transaction.endDate != null)
              _buildDetailRow(
                'Masa Aktif Berakhir',
                FormatDateTime.formatDateAndTimeCompact(transaction.endDate!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(final String label, final String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
gapH16,          Flexible(child: Text(value, textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  Widget _buildFutureDetailRow(
      final String label, final Future<String?> future) {
    return FutureBuilder<String?>(
      future: future,
      builder: (final context, final snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildDetailRow(label, 'Memuat...');
        }
        if (snapshot.hasError) {
          return _buildDetailRow(label, 'Error Data');
        }
        return _buildDetailRow(label, snapshot.data ?? '-');
      },
    );
  }
}
