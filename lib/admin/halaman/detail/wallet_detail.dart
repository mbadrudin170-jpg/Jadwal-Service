// path: lib/admin/halaman/detail/wallet_detail.dart
// digunakan oleh: lib/admin/halaman/tab/wallet.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wifi/admin/halaman/detail/transaction_detail.dart';
import 'package:wifi/admin/halaman/form/transaction_form.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/transaction_type_enum.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/model/wallet_model.dart';
import 'package:wifi/shared/operasi/transaction_operation.dart';
import 'package:wifi/shared/operasi/wallet_operation.dart';
import 'package:wifi/shared/widget/summary_info_widget.dart';
import 'package:wifi/shared/widget/transaction_list_widgets.dart';

/// Kelas data untuk detail dompet.
class WalletDetailData {
  /// Model dompet yang sedang ditampilkan.
  final WalletModel wallet;

  /// Daftar transaksi yang terkait dengan dompet.
  final List<TransactionModel> transactions;

  /// Total pendapatan dari transaksi.
  final double totalIncome;

  /// Total pengeluaran dari transaksi.
  final double totalExpense;

  /// Membuat instance [WalletDetailData].
  WalletDetailData({
    required this.wallet,
    required this.transactions,
    required this.totalIncome,
    required this.totalExpense,
  });
}

/// Halaman yang menampilkan detail dari sebuah dompet,
/// termasuk ringkasan saldo dan daftar transaksinya.
class WalletDetail extends StatefulWidget {
  /// Model dompet yang akan ditampilkan.
  final WalletModel wallet;

  /// Operasi untuk mengelola data dompet.
  final WalletOperation? walletOperation;

  /// Operasi untuk mengelola data transaksi.
  final TransactionOperation? transactionOperation;

  /// Membuat instance [WalletDetail].
  const WalletDetail({
    super.key,
    required this.wallet,
    this.walletOperation,
    this.transactionOperation,
  });

  @override
  State<WalletDetail> createState() => _WalletDetailState();
}

class _WalletDetailState extends State<WalletDetail> {
  late Future<WalletDetailData> _futureDetailData;
  late final WalletOperation _walletOperation;
  late final TransactionOperation _transactionOperation;
  String? _latestWalletName;

  @override
  void initState() {
    super.initState();
    Log.info('Membuat state untuk WalletDetail. ID: ${widget.wallet.id}');
    _walletOperation = widget.walletOperation ?? WalletOperation();
    _transactionOperation =
        widget.transactionOperation ?? TransactionOperation();
    _futureDetailData = _loadData();
  }

  Future<WalletDetailData> _loadData() async {
    Log.info('Memuat data detail dompet ID: ${widget.wallet.id}');

    try {
      final results = await Future.wait([
        _walletOperation.getWalletById(widget.wallet.id),
        _transactionOperation.getTransactionsByWalletId(widget.wallet.id),
      ]);

      final latestWallet = results[0] as WalletModel?;
      final transactionList = results[1] as List<TransactionModel>;

      if (latestWallet == null) {
        throw Exception('Dompet tidak ditemukan.');
      }

      if (mounted) {
        setState(() {
          _latestWalletName = latestWallet.name;
        });
      }

      double income = 0;
      double expense = 0;

      for (final trx in transactionList) {
        if (trx.type == TransactionType.income) {
          income += trx.amount;
        } else if (trx.type == TransactionType.expense) {
          expense += trx.amount;
        }
      }

      return WalletDetailData(
        wallet: latestWallet,
        transactions: transactionList,
        totalIncome: income,
        totalExpense: expense,
      );
    } catch (e, s) {
      Log.error('Gagal memuat data detail dompet.', e: e, st: s);
      rethrow;
    }
  }

  void _reloadData() {
    Log.info('Memicu pemuatan ulang data untuk WalletDetail.');
    setState(() {
      _futureDetailData = _loadData();
    });
  }

  Future<void> _navigateToTransactionDetail(
      final TransactionModel transaction) async {
    Log.info(
      'Navigasi ke TransactionDetailPage dari WalletDetail untuk transaksi ID: ${transaction.id}',
    );
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (final context) => TransactionDetailPage(transaction: transaction),
      ),
    );

    if (result ?? false) {
      Log.info(
        'Kembali dari halaman detail transaksi dengan sinyal reload. Memuat ulang data dompet.',
      );
      _reloadData();
    } else {
      Log.info('Kembali dari halaman detail transaksi tanpa perubahan.');
    }
  }

  Future<void> _navigateToTransactionForm(
      {final TransactionModel? transaction}) async {
    Log.info(
      'Membuka FormTransaksiPage untuk mengedit transaksi ID: ${transaction?.id} dari WalletDetail.',
    );
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (final context) => FormTransaksiPage(transaction: transaction),
      ),
    );

    if (result ?? false) {
      Log.info(
        'Kembali dari form edit dengan sinyal reload. Memuat ulang data dompet.',
      );
      _reloadData();
    } else {
      Log.info('Kembali dari form edit tanpa perubahan.');
    }
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_latestWalletName ?? widget.wallet.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, true),
        ),
      ),
      body: FutureBuilder<WalletDetailData>(
        future: _futureDetailData,
        builder: (final context, final snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Data Kosong'));
          }

          final data = snapshot.data!;

          return Column(
            children: [
              Container(
                color: Theme.of(context).primaryColor.withAlpha(13),
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    buildSummaryInfo(
                      context: context,
                      label: 'Pemasukan',
                      amount: data.totalIncome,
                      color: Colors.green,
                    ),
                    buildSummaryInfo(
                      context: context,
                      label: 'Pengeluaran',
                      amount: data.totalExpense,
                      color: Colors.red,
                    ),
                    buildSummaryInfo(
                      context: context,
                      label: 'Saldo',
                      amount: data.wallet.balance,
                      color:
                          data.wallet.balance >= 0 ? Colors.blue : Colors.red,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: data.transactions.isEmpty
                    ? const Center(child: Text('Belum ada transaksi.'))
                    : _buildTransactionList(data.transactions),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTransactionList(final List<TransactionModel> transactionData) {
    final groupedTransactions = groupTransactionsByDate(transactionData);

    return ListView.builder(
      itemCount: groupedTransactions.length,
      itemBuilder: (final context, final index) {
        final date = groupedTransactions.keys.elementAt(index);
        final transactionsOnDate = groupedTransactions[date]!;

        final dailyTotal = transactionsOnDate.fold<double>(
          0.0,
          (final sum, final item) =>
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
                  unawaited(_navigateToTransactionDetail(transaction));
                },
                onEdit: () {
                  unawaited(
                      _navigateToTransactionForm(transaction: transaction));
                },
                onDelete: () async {
                  Log.info('Hapus transaksi: ${transaction.id}');
                  await _transactionOperation.archiveTransaction(transaction.id);
                  _reloadData();
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
