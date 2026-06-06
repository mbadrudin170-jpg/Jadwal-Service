// path: lib/admin/halaman/tab/transaction_page_a.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/admin/halaman/detail/transaction_detail.dart';
import 'package:wifi/admin/halaman/form/transaction_form.dart';
import 'package:wifi/admin/providers/transaction_provider.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/financial_summary_widget.dart';
import 'package:wifi/shared/widget/transaction_list_widgets.dart';

//===============[ ENUM & EXTENSION ]===============================

/// Mendefinisikan kriteria pengurutan untuk daftar transaksi.
enum SortBy {
  newest,
  oldest,
  highestAmount,
  lowestAmount,
}

/// Extension untuk memberikan fungsionalitas tambahan pada [SortBy].
extension SortByX on SortBy {
  /// Mengembalikan nama yang mudah dibaca untuk setiap kriteria urutan.
  String get name {
    switch (this) {
      case SortBy.newest:
        return 'Terbaru';
      case SortBy.oldest:
        return 'Terlama';
      case SortBy.highestAmount:
        return 'Jumlah Tertinggi';
      case SortBy.lowestAmount:
        return 'Jumlah Terendah';
    }
  }
}

//===============[ REFACTORED WIDGETS ]===============================

/// Halaman utama yang menampilkan daftar transaksi dan ringkasannya.
class TransactionPageA extends ConsumerWidget {
  const TransactionPageA({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(transactionProvider);

    return Scaffold(
      appBar: const _TransactionAppBar(), // Widget AppBar yang diekstrak
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (state) =>
            _TransactionBody(state: state), // Widget Body yang diekstrak
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Log.info('FAB tambah transaksi ditekan.');
          unawaited(_navigateToTransactionForm(context));
        },
        child: const Icon(TIcons.add),
      ),
    );
  }

  /// Navigasi ke halaman form untuk menambah/mengedit transaksi.
  Future<void> _navigateToTransactionForm(
    BuildContext context, {
    TransactionModel? transaction,
  }) async {
    Log.info(
      transaction == null
          ? 'Membuka FormTransaksiPage untuk menambah entri baru.'
          : 'Membuka FormTransaksiPage untuk mengedit transaksi: ${transaction.id}',
    );
    await Navigator.push(
      context,
      MaterialPageRoute<bool>(
        builder: (context) => FormTransaksiPage(transaction: transaction),
      ),
    );
  }
}

/// AppBar khusus untuk Halaman Transaksi, meng-handle semua aksi.
class _TransactionAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const _TransactionAppBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Dapatkan state sorting saat ini langsung dari provider
    final currentSortBy =
        ref.watch(transactionProvider).value?.sortBy ?? SortBy.newest;

    return AppBar(
      title: const Text('Transaksi'),
      actions: [
        // Tombol Sort
        IconButton(
          onPressed: () => _showSortDialog(context, ref, currentSortBy),
          icon: const Icon(TIcons.filter),
          tooltip: 'Urutkan',
        ),
        // Tombol Refresh
        IconButton(
          onPressed: () => ref.read(transactionProvider.notifier).refresh(),
          icon: const Icon(TIcons.refresh),
          tooltip: 'Refresh Data',
        ),
        // Tombol Hapus Semua
        IconButton(
          onPressed: () => _deleteAllTransactions(context, ref),
          icon: const Icon(TIcons.delete),
          tooltip: 'Hapus Semua Transaksi',
        ),
      ],
    );
  }

//
  /// Menampilkan dialog untuk memilih metode pengurutan.
  Future<void> _showSortDialog(
      BuildContext context, WidgetRef ref, SortBy currentSortBy) async {
    Log.info('Membuka dialog pengurutan transaksi.');

    final newSort = await showDialog<SortBy>(
        context: context,
        builder: (context) => SimpleDialog(
              title: const Text('Urutkan Berdasarkan'),
              children: [
                RadioGroup<SortBy>(
                  groupValue: currentSortBy,
                  onChanged: (value) => Navigator.pop(context, value),
                  child: Column(
                    children: SortBy.values
                        .map((sortBy) => RadioListTile<SortBy>(
                              title: Text(sortBy.name),
                              value: sortBy,
                            ))
                        .toList(),
                  ),
                ),
              ],
            ));

    if (newSort != null) {
      // Memanggil method di notifier untuk mengubah urutan
      ref.read(transactionProvider.notifier).sortTransactions(newSort);
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Menampilkan dialog konfirmasi untuk menghapus semua transaksi.
Future<void> _deleteAllTransactions(BuildContext context, WidgetRef ref) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Konfirmasi'),
      content: const Text(
        'Anda yakin ingin menghapus semua transaksi? Tindakan ini tidak dapat diurungkan.',
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal')),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Hapus'),
        ),
      ],
    ),
  );

  if ((confirmed ?? false) && context.mounted) {
    try {
      await ref.read(transactionProvider.notifier).softDeleteAll();
      ToastUtil.success(context, 'Semua transaksi berhasil dihapus.');
    } on Exception catch (e, s) {
      Log.error('Gagal menghapus semua transaksi.', e: e, st: s);
      ToastUtil.error(context, 'Gagal menghapus transaksi: $e');
    }
  }
}

/// Body utama Halaman Transaksi.
class _TransactionBody extends ConsumerWidget {
  final TransactionState state;

  const _TransactionBody({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () => ref.read(transactionProvider.notifier).refresh(),
      child: Column(
        children: [
          // Ringkasan Keuangan (selalu ditampilkan)
          TransactionSummary(
            income: state.totalIncome,
            expense: state.totalExpense,
            total: state.netTotal,
          ),
          // Bagian ini akan berganti antara list dan pesan kosong
          Expanded(
            child: state.transactions.isEmpty
                ? const Center(child: Text('Tidak ada transaksi'))
                : _TransactionListView(transactions: state.transactions),
          ),
        ],
      ),
    );
  }
}

/// Widget yang bertanggung jawab untuk membangun ListView dari transaksi.
class _TransactionListView extends ConsumerWidget {
  final List<TransactionModel> transactions;

  const _TransactionListView({required this.transactions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupedTransactions = groupTransactionsByDate(transactions);

    return ListView.builder(
      key: const PageStorageKey('transaction_list_key'),
      itemCount: groupedTransactions.length,
      itemBuilder: (context, index) {
        final date = groupedTransactions.keys.elementAt(index);
        final transactionsOnDate = groupedTransactions[date]!;
        final dailyTotal = transactionsOnDate.fold<double>(
          0.0,
          (sum, item) =>
              sum +
              (item.type == TransactionType.income
                  ? item.amount
                  : -item.amount),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSectionHeader(date, dailyTotal),
            ...transactionsOnDate.map((transaction) => buildTransactionItem(
                  context,
                  transaction,
                  onTap: () =>
                      _navigateToTransactionDetail(context, transaction),
                  onEdit: () => _navigateToTransactionForm(context,
                      transaction: transaction),
                  onDelete: () => ref
                      .read(transactionProvider.notifier)
                      .softDelete(transaction.id),
                )),
          ],
        );
      },
    );
  }

  /// Navigasi ke halaman detail transaksi.
  Future<void> _navigateToTransactionDetail(
      BuildContext context, TransactionModel transaction) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => TransactionDetailPage(transaction: transaction),
      ),
    );
  }

  /// Navigasi ke halaman form (dibutuhkan di sini untuk action onEdit).
  Future<void> _navigateToTransactionForm(
    BuildContext context, {
    TransactionModel? transaction,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute<bool>(
        builder: (context) => FormTransaksiPage(transaction: transaction),
      ),
    );
  }
}

//===============[ UNCHANGED WIDGETS ]===============================
// Widget TransactionSummary dan buildFinancialSummaryInfo tidak perlu diubah
// karena sudah cukup baik dan bisa digunakan kembali.

class TransactionSummary extends StatelessWidget {
  final double income;
  final double expense;
  final double total;

  const TransactionSummary({
    super.key,
    required this.income,
    required this.expense,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            buildFinancialSummaryInfo(
              context: context,
              label: 'Pemasukan',
              amount: income,
              color: Colors.green,
            ),
            buildFinancialSummaryInfo(
              context: context,
              label: 'Pengeluaran',
              amount: expense,
              color: Colors.red,
            ),
            buildFinancialSummaryInfo(
              context: context,
              label: 'Total',
              amount: total,
              color: total >= 0 ? Colors.blue : Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}
