// path: lib/admin/halaman/tab/transaction_page.dart
// digunakan oleh: lib/admin/halaman/tab/admin_tab_page.dart (sebagai tab Transaksi)
// diubah: Refactor total ke Bahasa Inggris (class, method, variabel) dengan komentar Bahasa Indonesia.
// diubah: Memperbaiki import path yang salah.
// diubah: Menerapkan caching state & memperbaiki peringatan linter.
// diubah: Memperbaiki pemanggilan FormTransaksiPage (nama class asli dari transaction_form.dart).
// diubah: Memperbaiki pemanggilan deleteAllTransactions (method yang tersedia di TransactionOperation).

import 'package:flutter/material.dart';
import 'package:wifi/admin/halaman/form/transaction_form.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/transaction_type_enum.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/operasi/transaction_operation.dart';
import 'package:wifi/shared/utils/snackbar_util.dart';
import 'package:wifi/shared/widget/financial_summary_widget.dart';
import 'package:wifi/shared/widget/transaction_list_widgets.dart';

// === INFORMASI DEPENDENCY ===
// 📂 FILE INI DIGUNAKAN OLEH:
//   - lib/admin/halaman/tab/admin_tab_page.dart (sebagai tab Transaksi)
//
// 📂 FILE INI MENGGUNAKAN:
//   - lib/admin/halaman/form/transaction_form.dart (FormTransaksiPage)
//   - lib/shared/enum/transaction_type_enum.dart (TransactionType)
//   - lib/shared/model/transaction_model.dart (TransactionModel)
//   - lib/shared/operasi/transaction_operation.dart (TransactionOperation)
//   - lib/shared/debug/log.dart (Log)
//   - lib/shared/utils/snackbar_util.dart (SnackBarUtil)
//   - lib/shared/widget/financial_summary_widget.dart (buildFinancialSummaryInfo)
//   - lib/shared/widget/transaction_list_widgets.dart (groupTransactionsByDate, buildSectionHeader, buildTransactionItem)

/// Widget untuk menampilkan ringkasan transaksi (pemasukan, pengeluaran, total).
class TransactionSummary extends StatelessWidget {
  /// Jumlah total pemasukan.
  final double income;

  /// Jumlah total pengeluaran.
  final double expense;

  /// Total selisih antara pemasukan dan pengeluaran.
  final double total;

  /// Konstruktor untuk TransactionSummary.
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

/// Halaman untuk menampilkan dan mengelola daftar transaksi.
class TransactionPage extends StatefulWidget {
  /// Operasi transaksi untuk injeksi dependensi saat testing.
  final TransactionOperation? transactionOperation;

  /// Konstruktor untuk TransactionPage.
  const TransactionPage({super.key, this.transactionOperation});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  late TransactionOperation _transactionOperation;

  // Variabel state untuk caching
  Map<String, dynamic>? _cachedData;
  Object? _error;
  late Future<void> _initialLoadFuture;

  @override
  void initState() {
    super.initState();
    Log.info('Halaman Transaksi sedang diinisialisasi (initState).');
    _transactionOperation =
        widget.transactionOperation ?? TransactionOperation();
    Log.info(
      'TransactionOperation telah disiapkan. Memulai pengambilan data awal.',
    );
    _initialLoadFuture = _loadData();
  }

  /// Mengambil semua data yang diperlukan dari operasi transaksi.
  Future<Map<String, dynamic>> _fetchData() async {
    Log.info(
      'Memulai proses _fetchData untuk mengambil semua data transaksi dan ringkasan.',
    );
    try {
      final results = await Future.wait([
        _transactionOperation.getAllTransactions(),
        _transactionOperation.getTotalIncome(),
        _transactionOperation.getTotalExpense(),
        _transactionOperation.getNetTotal(),
      ]);
      final transactions = results[0] as List<TransactionModel>;
      Log.info(
        'Berhasil mengambil ${transactions.length} item transaksi dari database.',
      );
      return {
        'transactions': transactions,
        'income': (results[1] as num).toDouble(),
        'expense': (results[2] as num).toDouble(),
        'total': (results[3] as num).toDouble(),
      };
    } on Exception catch (e, s) {
      Log.error(
        'Gagal total saat menjalankan _fetchData. Kesalahan terjadi di level Future.wait.',
        e: e,
        st: s,
      );
      rethrow;
    }
  }

  /// Memuat atau memuat ulang data dan memperbarui state.
  Future<void> _loadData({final bool reload = false}) async {
    Log.info(reload ? 'Memicu pemuatan ulang data...' : 'Memuat data awal...');

    if (reload && mounted) {
      setState(() {
        // Hapus cache untuk menampilkan indikator loading
        _cachedData = null;
        _error = null;
      });
    }

    try {
      final data = await _fetchData();
      if (mounted) {
        setState(() {
          _cachedData = data;
        });
      }
    } on Exception catch (e, s) {
      Log.error('Gagal memuat data.', e: e, st: s);
      if (mounted) {
        setState(() {
          _error = e;
        });
      }
    }
  }

  /// Membuka halaman form untuk menambah transaksi baru.
  Future<void> _addTransaction() async {
    Log.info('Membuka FormTransaksiPage untuk menambah entri baru.');
    // PERBAIKAN: Menggunakan nama class asli FormTransaksiPage
    final result = await Navigator.push(
      context,
      MaterialPageRoute<bool>(
        builder: (final context) => const FormTransaksiPage(),
      ),
    );
    if (result ?? false) {
      Log.info(
        'Form ditutup dengan hasil sukses (true). Memuat ulang data transaksi.',
      );
      await _loadData(reload: true);
    } else {
      Log.info(
        'Form ditutup tanpa hasil (false/null). Tidak ada data yang dimuat ulang.',
      );
    }
  }

  /// Menampilkan dialog konfirmasi dan menghapus semua transaksi jika disetujui.
  Future<void> _deleteAllTransactions() async {
    try {
      final bool? confirmed = await showDialog<bool>(
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
        Log.warning('Pengguna mengkonfirmasi penghapusan semua transaksi.');
        // PERBAIKAN: Menggunakan method yang tersedia (archiveAllTransactions)
        await _transactionOperation.archiveAllTransactions();
        if (!mounted) return;
        SnackBarUtil.success(context, 'Semua transaksi berhasil dihapus.');
        await _loadData(reload: true);
      }
    } on Exception catch (e, s) {
      Log.error('Gagal menghapus semua transaksi.', e: e, st: s);
      if (!mounted) return;
      SnackBarUtil.error(context, 'Gagal menghapus transaksi: $e');
    }
  }

  @override
  Widget build(final BuildContext context) {
    Log.info('Membangun UI utama Halaman Transaksi (build method).');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi'),
        actions: [
          IconButton(
            onPressed: _deleteAllTransactions,
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Hapus Semua Transaksi',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTransaction,
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Membangun body utama berdasarkan state data (cached, error, atau loading awal).
  Widget _buildBody() {
    // Jika data ada di cache, langsung tampilkan
    if (_cachedData != null) {
      final data = _cachedData!;
      final income = (data['income'] as num?)?.toDouble() ?? 0.0;
      final expense = (data['expense'] as num?)?.toDouble() ?? 0.0;
      final total = (data['total'] as num?)?.toDouble() ?? 0.0;
      final transactionsData = data['transactions'] as List<TransactionModel>;
      Log.info(
        'Membangun UI dari cache. Memiliki ${transactionsData.length} transaksi.',
      );

      return Column(
        children: [
          TransactionSummary(
            key: const Key('transaction_summary'),
            income: income,
            expense: expense,
            total: total,
          ),
          Expanded(
            child: transactionsData.isEmpty
                ? const Center(
                    child: Text('Tidak ada transaksi ditemukan.'),
                  )
                : _buildTransactionList(transactionsData),
          ),
        ],
      );
    }

    // Jika ada error, tampilkan pesan error
    if (_error != null) {
      Log.error('Membangun UI Error: $_error');
      return Center(child: Text('Terjadi Kesalahan: $_error'));
    }

    // Jika tidak, tampilkan FutureBuilder untuk loading awal
    return FutureBuilder<void>(
      future: _initialLoadFuture,
      builder: (final context, final snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          Log.info(
            'FutureBuilder: Menunggu hasil dari _loadData (awal). Menampilkan CircularProgressIndicator.',
          );
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          Log.error(
            'FutureBuilder: Menangkap error saat loading awal.',
            e: snapshot.error,
            st: snapshot.stackTrace,
          );
          return Center(child: Text('Terjadi Kesalahan: ${snapshot.error}'));
        }
        Log.warning('FutureBuilder selesai tapi _cachedData masih null.');
        return const Center(child: Text('Tidak ada data ditemukan.'));
      },
    );
  }

  /// Membangun daftar transaksi yang dikelompokkan berdasarkan tanggal.
  Widget _buildTransactionList(final List<TransactionModel> transactionsData) {
    Log.info(
      'Membangun daftar transaksi (_buildTransactionList) dengan ${transactionsData.length} item.',
    );
    final groupedTransactions = groupTransactionsByDate(transactionsData);

    return ListView.builder(
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
                () => _loadData(reload: true),
                _transactionOperation,
              ),
            ),
          ],
        );
      },
    );
  }
}
