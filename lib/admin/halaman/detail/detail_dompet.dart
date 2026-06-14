// path: lib/admin/halaman/detail/detail_dompet.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:wifi/fitur/transaksi/page/detail_transaksi.dart';
import 'package:wifi/fitur/transaksi/page/form_transaksi.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/dompet/operasi/dompet_op_sqlite.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/fitur/transaksi/enum/tipe_transaksi.dart';
import 'package:wifi/fitur/dompet/model/dompet_model.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_sqlite.dart';
import 'package:wifi/shared/widget/daftar_transaksi_widget.dart';
import 'package:wifi/shared/widget/summary_info_widget.dart';

/// Kelas data untuk detail dompet.
class DetailDompetData {
  /// Model dompet yang sedang ditampilkan.
  final DompetModel dompet;

  /// Daftar transaksi yang terkait dengan dompet.
  final List<TransaksiModel> transaksi;

  /// Total pendapatan dari transaksi.
  final double totalIncome;

  /// Total pengeluaran dari transaksi.
  final double totalExpense;

  /// Membuat instance [DetailDompetData].
  DetailDompetData({
    required this.dompet,
    required this.transaksi,
    required this.totalIncome,
    required this.totalExpense,
  });
}

/// Halaman yang menampilkan detail dari sebuah dompet,
/// termasuk ringkasan saldo dan daftar transaksinya.
class DetailDompet extends ConsumerStatefulWidget {
  /// Model dompet yang akan ditampilkan.
  final DompetModel dompet;

  /// Operasi untuk mengelola data dompet.
  final DompetOpSqlite? dompetOpSqlite;

  /// Operasi untuk mengelola data transaksi.
  final TransaksiOpsqlite? transaksiOpSqlite;

  /// Membuat instance [DetailDompet].
  const DetailDompet({
    super.key,
    required this.dompet,
    this.dompetOpSqlite,
    this.transaksiOpSqlite,
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
    _futureDetailData = _muatData();
  }

  Future<DetailDompetData> _muatData() async {
    Log.info('Memuat data detail dompet ID: ${widget.dompet.id}');
    final dompetOpSqlite = ref.read(dompetOpSqliteProvider);
    final transaksiOpsqlite = ref.read(transaksiOpSqliteProvider);

    try {
      final results = await Future.wait([
        dompetOpSqlite.ambilBerdasarkanId(widget.dompet.id),
        transaksiOpsqlite.getTransactionsByWalletId(widget.dompet.id),
      ]);

      final dompet = results[0] as DompetModel?;
      final daftarTransaksi = results[1] as List<TransaksiModel>;

      if (dompet == null) {
        throw Exception('Dompet tidak ditemukan.');
      }

      if (mounted) {
        setState(() {
          _latestWalletName = dompet.nama;
        });
      }

      double income = 0;
      double expense = 0;

      for (final trx in daftarTransaksi) {
        if (trx.tipe == TipeTransaksi.income) {
          income += trx.jumlah;
        } else if (trx.tipe == TipeTransaksi.expense) {
          expense += trx.jumlah;
        }
      }

      return DetailDompetData(
        dompet: dompet,
        transaksi: daftarTransaksi,
        totalIncome: income,
        totalExpense: expense,
      );
    } catch (e, s) {
      Log.error('Gagal memuat data detail dompet.', e: e, s: s);
      rethrow;
    }
  }

  void _muatUlangData() {
    Log.info('Memicu pemuatan ulang data untuk WalletDetail.');
    setState(() {
      _futureDetailData = _muatData();
    });
  }

  Future<void> _navigasiKeDetailTransaksi(
    TransaksiModel transaction,
  ) async {
    Log.info(
      'Navigasi ke TransactionDetailPage dari WalletDetail untuk transaksi ID: ${transaction.id}',
    );
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => DetailTransaksi(transaksi: transaction),
      ),
    );

    if (result ?? false) {
      Log.info(
        'Kembali dari halaman detail transaksi dengan sinyal reload. Memuat ulang data dompet.',
      );
      _muatUlangData();
    } else {
      Log.info('Kembali dari halaman detail transaksi tanpa perubahan.');
    }
  }

  Future<void> _navigasiKeFormTransaksi({
    TransaksiModel? transaction,
  }) async {
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
      _muatUlangData();
    } else {
      Log.info('Kembali dari form edit tanpa perubahan.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_latestWalletName ?? widget.dompet.nama),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, true),
        ),
      ),
      body: FutureBuilder<DetailDompetData>(
        future: _futureDetailData,
        builder: (context, snapshot) {
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
                      amount: data.dompet.saldo,
                      color: data.dompet.saldo >= 0 ? Colors.blue : Colors.red,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: data.transaksi.isEmpty
                    ? const Center(child: Text('Belum ada transaksi.'))
                    : _bangunDaftarTransaksi(data.transaksi),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _bangunDaftarTransaksi(List<TransaksiModel> transactionData) {
    final groupedTransactions = groupTransactionsByDate(transactionData);
    final transactionOperation = ref.read(transaksiOpSqliteProvider);
    return ListView.builder(
      itemCount: groupedTransactions.length,
      itemBuilder: (context, index) {
        final date = groupedTransactions.keys.elementAt(index);
        final transactionsOnDate = groupedTransactions[date]!;

        final dailyTotal = transactionsOnDate.fold<double>(
          0.0,
          (sum, item) =>
              sum +
              (item.tipe == TipeTransaksi.income ? item.jumlah : -item.jumlah),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSectionHeader(date, dailyTotal),
            ...transactionsOnDate.map(
              (transaction) => buildTransactionItem(
                context,
                transaction,
                onTap: () {
                  unawaited(_navigasiKeDetailTransaksi(transaction));
                },
                onEdit: () {
                  unawaited(_navigasiKeFormTransaksi(transaction: transaction));
                },
                onDelete: () async {
                  Log.info('Hapus transaksi: ${transaction.id}');
                  await transactionOperation.softDelete(transaction.id);
                  _muatUlangData();
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
