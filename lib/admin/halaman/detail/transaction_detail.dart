// path: lib/admin/halaman/detail/transaction_detail.dart
//
// 📂 FILE INI DIGUNAKAN OLEH:
//   - Digunakan sebagai halaman detail transaksi dari daftar transaksi.
//
// 📂 FILE INI MENGGUNAKAN:
//   - lib/admin/halaman/form/transaction_form.dart (FormTransaksiPage)
//   - lib/shared/model/category_model.dart (CategoryModel)
//   - lib/shared/model/customer_model.dart (CustomerModel)
//   - lib/shared/model/package_model.dart (PackageModel)
//   - lib/shared/model/sub_category_model.dart (SubCategoryModel)
//   - lib/shared/model/transaction_model.dart (TransactionModel)
//   - lib/shared/model/wallet_model.dart (WalletModel)
//   - lib/shared/operasi/category_operation.dart (CategoryOperation)
//   - lib/shared/operasi/customer_operation.dart (CustomerOperation)
//   - lib/shared/operasi/package_operation.dart (PackageOperation)
//   - lib/shared/operasi/sub_category_operation.dart (SubCategoryOperation)
//   - lib/shared/operasi/wallet_operation.dart (WalletOperation)
//   - lib/shared/utils/format_util.dart (FormatUtil)
//   - lib/shared/debug/log.dart (Log)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wifi/admin/halaman/form/transaction_form.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/category_model.dart';
import 'package:wifi/shared/model/customer_model.dart';
import 'package:wifi/shared/model/package_model.dart';
import 'package:wifi/shared/model/sub_category_model.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/model/wallet_model.dart';
import 'package:wifi/shared/operasi/category_operation.dart';
import 'package:wifi/shared/operasi/customer_operation.dart';
import 'package:wifi/shared/operasi/package_operation.dart';
import 'package:wifi/shared/operasi/sub_category_operation.dart';
import 'package:wifi/shared/operasi/wallet_operation.dart';
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
    final updatedTransaction = await Navigator.push<TransactionModel?>(
      context,
      MaterialPageRoute<TransactionModel?>(
        builder: (final context) =>
            FormTransaksiPage(transaksi: _currentTransaction),
      ),
    );
    if (updatedTransaction != null) {
      setState(() => _currentTransaction = updatedTransaction);
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
          onPressed: () => Navigator.pop(context),
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
              FormatUtil.formatDateAndTime(transaction.date),
            ),
            _buildDetailRow(
              'Jumlah',
              NumberFormat.currency(
                locale: 'id_ID',
                symbol: 'Rp ',
              ).format(transaction.amount),
            ),
            _buildDetailRow('Tipe', transaction.type.name.toUpperCase()),
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
                  _customerOperation.getCustomerById,
                  transaction.customerId!,
                  'Pelanggan',
                ),
              ),
            if (transaction.packageId != null &&
                transaction.packageId!.isNotEmpty)
              _buildFutureDetailRow(
                'Paket',
                _getName(
                  _packageOperation.getPackageById,
                  transaction.packageId!,
                  'Paket',
                ),
              ),
            _buildDetailRow(
              'Status Pembayaran',
              transaction.paymentStatus.name.toUpperCase(),
            ),
            _buildDetailRow(
                'Poin Dihasilkan', transaction.earnedPoints.toString()),
            _buildDetailRow(
                'Poin Digunakan', transaction.usedPoints.toString()),
            if (transaction.startDate != null)
              _buildDetailRow(
                'Masa Aktif Mulai',
                FormatUtil.formatDateAndTime(transaction.startDate!),
              ),
            if (transaction.endDate != null)
              _buildDetailRow(
                'Masa Aktif Berakhir',
                FormatUtil.formatDateAndTime(transaction.endDate!),
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
          const SizedBox(width: 16),
          Flexible(child: Text(value, textAlign: TextAlign.end)),
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
