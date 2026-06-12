// path: lib/admin/halaman/detail/transaction_detail.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/admin/halaman/form/form_transaksi.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/export/operation.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/toast_util.dart';

/// Halaman untuk menampilkan detail dari sebuah transaksi.
class DetailTransaksi extends ConsumerStatefulWidget {
  /// Model transaksi yang akan ditampilkan.
  final TransaksiModel transaction;

  /// Konstruktor untuk TransactionDetailPage.
  const DetailTransaksi({super.key, required this.transaction});

  @override
  ConsumerState<DetailTransaksi> createState() => _DetailTransaksistate();
}

class _DetailTransaksistate extends ConsumerState<DetailTransaksi> {
  late final DompetOpSqlite _dompetOpSqlite =
      ref.watch(walletOperationProvider);
  late final CategoryOperation _categoryOperation =
      ref.watch(categoryOperationProvider);
  late final PelangganOpSqlite _customerOperation =
      ref.watch(customerOperationProvider);
  late final PaketOpSqlite _packageOperation =
      ref.watch(packageOperationProvider);
  late final SubKategoriOpSqlite _subKategoriOpSqlite =
      ref.watch(subCategoryOperationProvider);

  late TransaksiModel _currentTransaction;
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
        if (model is PelangganModel) name = model.name;
        if (model is PaketModel) name = model.name;
        return name ?? 'Nama tidak tersedia';
      }
      return 'Data tidak ditemukan';
    } on Exception {
      return 'Error Memuat';
    }
  }

  Future<void> _navigasiKeForm() async {
    Log.info(
        'Membuka FormTransaksiPage dari halaman detail untuk mengedit transaksi: ${_currentTransaction.id}');
    // 1. Ubah tipe data yang diharapkan dari `Navigator.push` menjadi `bool?`
    final isSaved = await Navigator.push<bool?>(
      context,
      MaterialPageRoute(
        builder: (final context) =>
            FormTransaksi(transaksi: _currentTransaction),
      ),
    );

    if (isSaved ?? false) {
      Log.info(
          'Form edit melaporkan keberhasilan penyimpanan. Memuat ulang data transaksi dari database.');
      try {
        final transaksiOpSqlite = ref.read(transactionOperationProvider);
        final updatedTransaction =
            await transaksiOpSqlite.getById(_currentTransaction.id);

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
            e: e, s: s);
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
    final transaksi = _currentTransaction;

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
            onPressed: _navigasiKeForm,
            tooltip: 'Edit Transaksi',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildDetailRow('Keterangan', transaksi.description),
            _buildDetailRow(
              'Tanggal',
              FormatDateTime.formatDateAndTimeCompact(transaksi.date),
            ),
            _buildDetailRow(
                'Jumlah', CurrencyFormat.formatCurrency(transaksi.amount)),
            _buildDetailRow('Tipe', transaksi.type.displayName),
            _buildFutureDetailRow(
              'Dompet',
              _getName(
                _dompetOpSqlite.getById,
                transaksi.walletId,
                'Dompet',
              ),
            ),
            if (transaksi.destinationWalletId != null &&
                transaksi.destinationWalletId!.isNotEmpty)
              _buildFutureDetailRow(
                'Dompet Tujuan',
                _getName(
                  _dompetOpSqlite.getById,
                  transaksi.destinationWalletId!,
                  'Dompet Tujuan',
                ),
              ),
            _buildFutureDetailRow(
              'Kategori',
              _getName(
                _categoryOperation.getCategoryById,
                transaksi.categoryId,
                'Kategori',
              ),
            ),
            if (transaksi.idSubKategori != null &&
                transaksi.idSubKategori!.isNotEmpty)
              _buildFutureDetailRow(
                'Sub Kategori',
                _getName(
                  _subKategoriOpSqlite.getSubCategoryById,
                  transaksi.idSubKategori!,
                  'Sub-Kategori',
                ),
              ),
            if (transaksi.customerId != null &&
                transaksi.customerId!.isNotEmpty)
              _buildFutureDetailRow(
                'Pelanggan',
                _getName(
                  _customerOperation.getById,
                  transaksi.customerId!,
                  'Pelanggan',
                ),
              ),
            if (transaksi.packageId != null && transaksi.packageId!.isNotEmpty)
              _buildFutureDetailRow(
                'Paket',
                _getName(
                  _packageOperation.getById,
                  transaksi.packageId!,
                  'Paket',
                ),
              ),
            _buildDetailRow(
              'Status Pembayaran',
              transaksi.paymentStatus.displayName,
            ),
            _buildDetailRow(
                'Poin Dihasilkan', transaksi.earnedPoints.toString()),
            _buildDetailRow('Poin Digunakan', transaksi.usedPoints.toString()),
            if (transaksi.startDate != null)
              _buildDetailRow(
                'Masa Aktif Mulai',
                FormatDateTime.formatDateAndTimeCompact(transaksi.startDate!),
              ),
            if (transaksi.endDate != null)
              _buildDetailRow(
                'Masa Aktif Berakhir',
                FormatDateTime.formatDateAndTimeCompact(transaksi.endDate!),
              ),
            if (transaksi.durasiBonus! > 0 && transaksi.durasiBonusType != null)
              _buildDetailRow('Bonus',
                  '${transaksi.durasiBonus} ${transaksi.durasiBonusType?.displayName}')
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
