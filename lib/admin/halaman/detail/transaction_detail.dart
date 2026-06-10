// path: lib/admin/halaman/detail/transaction_detail.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/admin/halaman/form/transaction_form.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/export/operation.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/toast_util.dart';

/// Halaman untuk menampilkan detail dari sebuah transaksi.
class TransactionDetailPage extends ConsumerStatefulWidget {
  /// Model transaksi yang akan ditampilkan.
  final TransactionModel transaction;

  /// Konstruktor untuk TransactionDetailPage.
  const TransactionDetailPage({super.key, required this.transaction});

  @override
  ConsumerState<TransactionDetailPage> createState() =>
      _TransactionDetailPageState();
}

class _TransactionDetailPageState extends ConsumerState<TransactionDetailPage> {
  late final WalletOperation _walletOperation =
      ref.watch(walletOperationProvider);
  late final CategoryOperation _categoryOperation =
      ref.watch(categoryOperationProvider);
  late final CustomerOperation _customerOperation =
      ref.watch(customerOperationProvider);
  late final PackageOperation _packageOperation =
      ref.watch(packageOperationProvider);
  late final SubCategoryOperation _subCategoryOperation =
      ref.watch(subCategoryOperationProvider);

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
    // 1. Ubah tipe data yang diharapkan dari `Navigator.push` menjadi `bool?`
    final isSaved = await Navigator.push<bool?>(
      context,
      MaterialPageRoute(
        builder: (final context) =>
            FormTransaksiPage(transaction: _currentTransaction),
      ),
    );

    if (isSaved ?? false) {
      Log.info(
          'Form edit melaporkan keberhasilan penyimpanan. Memuat ulang data transaksi dari database.');
      try {
        final transactionOp = ref.read(transactionOperationProvider);
        final updatedTransaction =
            await transactionOp.getTransactionById(_currentTransaction.id);

        if (updatedTransaction != null) {
          Log.info('Berhasil memuat data transaksi terbaru. Memperbarui UI.');
          // 4. Perbarui state dengan data baru.
          setState(() {
            _currentTransaction = updatedTransaction;
            _diUpdate = true;
          });
        } else {
          Log.warning(
              'Gagal memuat ulang transaksi: data tidak ditemukan setelah update.');
          // Mungkin transaksi dihapus? Kembali saja.
          if (mounted) Navigator.pop(context, true);
        }
      } catch (e, s) {
        Log.error('Gagal memuat ulang data transaksi setelah edit.',
            e: e, st: s);
        if (mounted) {
          ToastUtil.error(context, 'Gagal memuat data terbaru.');
        }
      }
    } else {
      Log.info('Kembali dari form edit tanpa pembaruan atau gagal disimpan.');
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
            icon: const Icon(TIcons.edit),
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
            if (transaction.durasiBonus! > 0 &&
                transaction.durasiBonusType != null)
              _buildDetailRow('Bonus',
                  '${transaction.durasiBonus} ${transaction.durasiBonusType?.displayName}')
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
          gapH16,
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
