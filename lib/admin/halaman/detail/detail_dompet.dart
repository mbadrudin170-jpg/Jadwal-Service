// path: lib/admin/halaman/detail/wallet_detail.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/admin/halaman/detail/detail_transaksi.dart';
import 'package:wifi/admin/halaman/form/form_transaksi.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/dompet/operasi/dompet_op_sqlite.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/transaction_type_enum.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/model/wallet_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/transaction_operation.dart';
import 'package:wifi/shared/widget/summary_info_widget.dart';
import 'package:wifi/shared/widget/transaction_list_widgets.dart';

/// Kelas data untuk detail dompet.
class DetailDompetData {
  /// Model dompet yang sedang ditampilkan.
  final WalletModel wallet;

  /// Daftar transaksi yang terkait dengan dompet.
  final List<TransaksiModel> transactions;

  /// Total pendapatan dari transaksi.
  final double totalIncome;

  /// Total pengeluaran dari transaksi.
  final double totalExpense;

  /// Membuat instance [DetailDompetData].
  DetailDompetData({
    required this.wallet,
    required this.transactions,
    required this.totalIncome,
    required this.totalExpense,
  });
}

/// Halaman yang menampilkan detail dari sebuah dompet,
/// termasuk ringkasan saldo dan daftar transaksinya.
class DetailDompet extends ConsumerStatefulWidget {
  /// Model dompet yang akan ditampilkan.
  final WalletModel dompet;

  /// Operasi untuk mengelola data dompet.
  final DompetOpSqlite? walletOperation;

  /// Operasi untuk mengelola data transaksi.
  final TransaksiOpsqlite? transactionOperation;

  /// Membuat instance [DetailDompet].
  const DetailDompet({
    super.key,
    required this.dompet,
    this.walletOperation,
    this.transactionOperation,
  });

  @override
  ConsumerState<DetailDompet> createState() => _WalletDetailState();
}

class _WalletDetailState extends ConsumerState<DetailDompet> {
  late Future<DetailDompetData> _futureDetailData;
  String? _latestWalletName;

  @override
  void initState() {
    super.initState();
    Log.info('Membuat state untuk WalletDetail. ID: ${widget.dompet.id}');
    _futureDetailData = _loadData();
  }

  Future<DetailDompetData> _loadData() async {
    Log.info('Memuat data detail dompet ID: ${widget.dompet.id}');
    final walletOperation = ref.read(dompetOpSqliteProvider);
    final transactionOperation = ref.read(transactionOperationProvider);

    try {
      final results = await Future.wait([
        walletOperation.getById(widget.dompet.id),
        transactionOperation.getTransactionsByWalletId(widget.dompet.id),
      ]);

      final latestWallet = results[0] as WalletModel?;
      final transactionList = results[1] as List<TransaksiModel>;

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

      return DetailDompetData(
        wallet: latestWallet,
        transactions: transactionList,
        totalIncome: income,
        totalExpense: expense,
      );
    } catch (e, s) {
      Log.error('Gagal memuat data detail dompet.', e: e, s: s);
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
      final TransaksiModel transaction) async {
    Log.info(
      'Navigasi ke TransactionDetailPage dari WalletDetail untuk transaksi ID: ${transaction.id}',
    );
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (final context) => DetailTransaksi(transaction: transaction),
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
      {final TransaksiModel? transaction}) async {
    Log.info(
      'Membuka FormTransaksiPage untuk mengedit transaksi ID: ${transaction?.id} dari WalletDetail.',
    );
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => FormTransaksi(transaksi: transaction),
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
        title: Text(_latestWalletName ?? widget.dompet.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, true),
        ),
      ),
      body: FutureBuilder<DetailDompetData>(
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

  Widget _buildTransactionList(final List<TransaksiModel> transactionData) {
    final groupedTransactions = groupTransactionsByDate(transactionData);
    final transactionOperation = ref.read(transactionOperationProvider);
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
                  await transactionOperation.softDelete(transaction.id);
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
