// path: lib/admin/halaman/tab/transaction_page_a.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/admin/halaman/detail/transaction_detail.dart';
import 'package:wifi/admin/halaman/form/transaction_form.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/providers/transaction_provider.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/financial_summary_widget.dart';
import 'package:wifi/shared/widget/transaction_list_widgets.dart';

// Enum SortBy tetap sama
enum SortBy {
  newest,
  oldest,
  highestAmount,
  lowestAmount,
}

// Widget TransactionSummary tetap sama
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
  Widget build(final BuildContext context) {
    Log.info(
      'Membangun UI TransactionSummary dengan data: Pemasukan=${income.toStringAsFixed(2)}, Pengeluaran=${expense.toStringAsFixed(2)}, Total=${total.toStringAsFixed(2)}',
    );
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

class TransactionPage extends ConsumerStatefulWidget {
  const TransactionPage({super.key});

  @override
  ConsumerState<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends ConsumerState<TransactionPage> {
  SortBy _currentSortBy = SortBy.newest;

  @override
  void initState() {
    super.initState();
    Log.info('Halaman Transaksi sedang diinisialisasi (initState).');
  }

  void _sortTransactions(final List<TransactionModel> transactions) {
    Log.info('Mengurutkan daftar transaksi berdasarkan: $_currentSortBy');
    switch (_currentSortBy) {
      case SortBy.newest:
        transactions.sort((final a, final b) => b.date.compareTo(a.date));
        break;
      case SortBy.oldest:
        transactions.sort((final a, final b) => a.date.compareTo(b.date));
        break;
      case SortBy.highestAmount:
        transactions.sort((final a, final b) => b.amount.compareTo(a.amount));
        break;
      case SortBy.lowestAmount:
        transactions.sort((final a, final b) => a.amount.compareTo(b.amount));
        break;
    }
  }

  Future<void> _navigateToTransactionDetail(
      final TransactionModel transaction) async {
    Log.info(
      'Navigasi ke TransactionDetailPage untuk transaksi ID: ${transaction.id}',
    );
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (final context) =>
            TransactionDetailPage(transaction: transaction),
      ),
    );
  }

  Future<void> _navigateToTransactionForm({
    final TransactionModel? transaction,
  }) async {
    Log.info(
      transaction == null
          ? 'Membuka FormTransaksiPage untuk menambah entri baru.'
          : 'Membuka FormTransaksiPage untuk mengedit transaksi: ${transaction.id}',
    );
    await Navigator.push(
      context,
      MaterialPageRoute<bool>(
        builder: (final context) => FormTransaksiPage(transaction: transaction),
      ),
    );
  }

  Future<void> _deleteAllTransactions() async {
    Log.info(
        'Tombol hapus semua transaksi ditekan, menampilkan dialog konfirmasi.');
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (final context) {
          return AlertDialog(
            title: const Text('Konfirmasi'),
            content: const Text(
              'Apakah Anda yakin ingin menghapus semua transaksi? Tindakan ini tidak dapat diurungkan.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Hapus'),
              ),
            ],
          );
        },
      );

      if (confirmed ?? false) {
        // Panggil method dari notifier
        await ref.read(transactionProvider.notifier).softDeleteAll();
        if (!mounted) return;
        ToastUtil.success(context, 'Semua transaksi berhasil dihapus.');
      } else {
        Log.info('Penghapusan semua transaksi dibatalkan oleh pengguna.');
      }
    } on Exception catch (e, s) {
      Log.error('Gagal menghapus semua transaksi.', e: e, st: s);
      if (!mounted) return;
      ToastUtil.error(context, 'Gagal menghapus transaksi: $e');
    }
  }

  String _getSortByName(final SortBy sort) {
    switch (sort) {
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

  Future<void> _showSortDialog() async {
    Log.info('Menampilkan dialog pengurutan. Sort aktif: $_currentSortBy');
    final newSort = await showDialog<SortBy>(
      context: context,
      builder: (final context) {
        return SimpleDialog(
          title: const Text('Urutkan Berdasarkan'),
          children: [
            RadioGroup<SortBy>(
              groupValue: _currentSortBy,
              onChanged: (final value) {
                Navigator.pop(context, value);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: SortBy.values
                    .map(
                      (final sort) => RadioListTile<SortBy>(
                        title: Text(_getSortByName(sort)),
                        value: sort,
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        );
      },
    );

    if (newSort != null && newSort != _currentSortBy) {
      Log.info('Opsi urutan diubah ke: $newSort. Memperbarui UI.');
      setState(() {
        _currentSortBy = newSort;
      });
    } else {
      Log.info('Dialog pengurutan ditutup tanpa perubahan.');
    }
  }

  @override
  Widget build(final BuildContext context) {
    final asyncState = ref.watch(transactionProvider);
    Log.info('Membangun UI utama Halaman Transaksi (build method).');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi'),
        actions: [
          IconButton(
            onPressed: _showSortDialog,
            icon: const Icon(TIcons.filter),
            tooltip: 'Urutkan',
          ),
          IconButton(
            onPressed: () {
              unawaited(ref.read(transactionProvider.notifier).refresh());
            },
            icon: const Icon(TIcons.refresh),
            tooltip: 'Refresh Data',
          ),
          IconButton(
            onPressed: _deleteAllTransactions,
            icon: const Icon(TIcons.delete),
            tooltip: 'Hapus Semua Transaksi',
          ),
        ],
      ),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (final err, final stack) => Center(child: Text('Error: $err')),
        data: _buildBody, // Perbaikan: Menggunakan tear-off
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Log.info('FAB tambah transaksi ditekan.');
          // Perbaikan: Menambahkan unawaited
          unawaited(_navigateToTransactionForm());
        },
        child: const Icon(TIcons.add),
      ),
    );
  }

  Widget _buildBody(final TransactionState state) {
    if (state.transactions.isEmpty) {
      return const Center(child: Text('Tidak ada transaksi'));
    }
    final transactions = List<TransactionModel>.from(state.transactions);
    _sortTransactions(transactions);

    return RefreshIndicator(
      onRefresh: () => ref.read(transactionProvider.notifier).refresh(),
      child: Column(
        children: [
          TransactionSummary(
            key: const Key('transaction_summary'),
            income: state.totalIncome,
            expense: state.totalExpense,
            total: state.netTotal,
          ),
          Expanded(
            child: _buildTransactionList(transactions),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(final List<TransactionModel> transactionsData) {
    Log.info(
      'Membangun daftar transaksi (_buildTransactionList) dengan ${transactionsData.length} item.',
    );
    final groupedTransactions = groupTransactionsByDate(transactionsData);

    return ListView.builder(
      key: const PageStorageKey('transaction_list_key'),
      itemCount: groupedTransactions.length,
      itemBuilder: (final context, final index) {
        final date = groupedTransactions.keys.elementAt(index);
        final transactionsOnDate = groupedTransactions[date]!;
        final dailyTotal = transactionsOnDate.fold<double>(
          0.0,
          (final double sum, final TransactionModel item) =>
              sum +
              (item.type == TransactionType.income
                  ? item.amount
                  : -item.amount),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSectionHeader(date, dailyTotal),
            ...transactionsOnDate.map(
              (final transaction) => buildTransactionItem(
                context,
                transaction,
                onTap: () {
                  Log.info('Transaksi di-tap: id=${transaction.id}');
                  unawaited(_navigateToTransactionDetail(transaction));
                },
                onEdit: () {
                  Log.info('Edit transaksi: id=${transaction.id}');
                  unawaited(
                    _navigateToTransactionForm(transaction: transaction),
                  );
                },
                onDelete: () async {
                  Log.info('Hapus transaksi: id=${transaction.id}');
                  await ref
                      .read(transactionProvider.notifier)
                      .softDelete(transaction.id);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
