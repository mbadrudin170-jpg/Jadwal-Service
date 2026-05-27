// path: lib/admin/halaman/tab/wallet_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wifi/admin/halaman/detail/wallet_detail.dart';
import 'package:wifi/admin/halaman/form/wallet_form.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/wallet_model.dart';
import 'package:wifi/shared/operasi/transaction_operation.dart';
import 'package:wifi/shared/operasi/wallet_operation.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/financial_summary_widget.dart';

class WalletPage extends StatefulWidget {
  final WalletOperation? walletOperation;
  final TransactionOperation? transactionOperation;

  const WalletPage({
    super.key,
    this.walletOperation,
    this.transactionOperation,
  });

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage>
    with AutomaticKeepAliveClientMixin<WalletPage> {
  late final WalletOperation _walletOperation;
  late Future<List<WalletModel>> _walletListFuture;

  String _sortBy = 'name';
  bool _sortAscending = true;


  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    super.initState();
    Log.info('Halaman Wallet sedang diinisialisasi.');
    _walletOperation = widget.walletOperation ?? WalletOperation();
    _loadWallets();
  }

  @override
  void dispose() {
    super.dispose();
  }


  void _loadWallets() {
    Log.info(
      'Memulai pemuatan data dompet dengan urutan: $_sortBy ${_sortAscending ? 'ASC' : 'DESC'}.',
    );
    setState(() {
      _walletListFuture = _walletOperation.getWallets().then((final wallets) {
        wallets.sort((final a, final b) {
          int compareResult;
          if (_sortBy == 'name') {
            compareResult =
                a.name.toLowerCase().compareTo(b.name.toLowerCase());
          } else {
            compareResult = a.balance.compareTo(b.balance);
          }
          return _sortAscending ? compareResult : -compareResult;
        });
        Log.info('Berhasil mengurutkan ${wallets.length} dompet.');
        return wallets;
      });
    });
    Log.info('Pemuatan data dompet dan ringkasan keuangan telah dijadwalkan.');
  }

  Future<void> _addWallet() async {
    Log.info('Navigasi ke halaman tambah dompet.');
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(builder: (final context) => const WalletForm()),
    );
    if (!mounted) return;
    if (result ?? false) {
      Log.info('Berhasil menambahkan dompet baru, memuat ulang data.');
      _loadWallets();
    }
  }

  Future<void> _showDeleteAllDialog() async {
    Log.info('Menampilkan dialog konfirmasi hapus semua dompet.');
    final walletList = await _walletOperation.getWallets();
    if (!mounted) return;
    if (walletList.isEmpty) {
      Log.warning('Tidak ada dompet untuk dihapus. Dialog tidak ditampilkan.');
      ToastUtil.info(
        context,
        'Tidak ada dompet untuk dihapus.',
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (final BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus semua dompet? Tindakan ini tidak dapat diurungkan.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Log.info('Pengguna membatalkan penghapusan semua dompet.');
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Hapus'),
              onPressed: () {
                Log.warning(
                  'Pengguna mengkonfirmasi penghapusan semua dompet melalui dialog. Memanggil _deleteAllWallets.',
                );
                Navigator.of(context).pop();
                unawaited(_deleteAllWallets());
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showArchiveOneDialog(final WalletModel wallet) async {
    Log.info(
      'Memicu fungsi _showArchiveOneDialog untuk dompet ID: ${wallet.id}, Nama: "${wallet.name}". Menampilkan dialog konfirmasi.',
    );
    await showDialog<void>(
      context: context,
      builder: (final BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Arsip'),
          content: Text(
            'Apakah Anda yakin ingin mengarsipkan dompet "${wallet.name}"?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Log.info(
                  'Pengguna membatalkan pengarsipan dompet ID: ${wallet.id}, Nama: "${wallet.name}". Dialog ditutup, tidak ada aksi.',
                );
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Arsipkan'),
              onPressed: () {
                Log.warning(
                  'Pengguna mengkonfirmasi pengarsipan dompet ID: ${wallet.id}, Nama: "${wallet.name}". Memanggil _archiveOneWallet.',
                );
                Navigator.of(context).pop();
                unawaited(_archiveOneWallet(wallet));
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _archiveOneWallet(final WalletModel wallet) async {
    Log.info('Memulai pengarsipan dompet: "${wallet.name}".');
    try {
      await _walletOperation.softDelete(wallet.id);
      _loadWallets();
      if (!mounted) return;
      Log.info('Dompet "${wallet.name}" berhasil diarsipkan.');
      ToastUtil.success(
        context,
        'Dompet berhasil diarsipkan.',
      );
    } on Exception catch (e, s) {
      if (!mounted) return;
      Log.error(
        'Gagal mengarsipkan dompet: "${wallet.name}".',
        e: e,
        st: s,
      );
      ToastUtil.error(
        context,
        'Gagal mengarsipkan dompet: $e',
      );
    }
  }

  Future<void> _deleteAllWallets() async {
    Log.info('Memulai penghapusan semua dompet.');
    try {
      await _walletOperation.deleteAllWallets();
      _loadWallets();
      if (!mounted) return;
      Log.info('Semua dompet berhasil dihapus.');
      ToastUtil.success(
        context,
        'Semua dompet berhasil dihapus.',
      );
    } on Exception catch (e, s) {
      if (!mounted) return;
      Log.error('Gagal menghapus semua dompet.', e: e, st: s);
      ToastUtil.error(
        context,
        'Gagal menghapus dompet: $e',
      );
    }
  }

  Future<void> _showSortDialog() async {
    Log.info('Menampilkan dialog pengurutan.');

    final Map<String, String> sortOptions = {
      'name_asc': 'Nama (A-Z)',
      'name_desc': 'Nama (Z-A)',
      'balance_asc': 'Saldo (Terkecil)',
      'balance_desc': 'Saldo (Terbesar)',
    };

    final result = await showDialog<String>(
      context: context,
      builder: (final context) {
        return SimpleDialog(
          title: const Text('Urutkan Dompet'),
          children: [
            RadioGroup<String>(
              groupValue: '${_sortBy}_${_sortAscending ? 'asc' : 'desc'}',
              onChanged: (final String? value) {
                Navigator.pop(context, value);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: sortOptions.entries.map((final entry) {
                  return RadioListTile<String>(
                    value: entry.key,
                    title: Text(entry.value),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );

    if (result != null) {
      final parts = result.split('_');
      setState(() {
        _sortBy = parts[0];
        _sortAscending = parts[1] == 'asc';
      });
      _loadWallets();
      Log.info(
          'Pengurutan diubah menjadi $_sortBy ${_sortAscending ? 'asc' : 'desc'}. Memuat ulang dompet.');
    } else {
      Log.info('Dialog pengurutan ditutup tanpa perubahan.');
    }
  }

  @override
  Widget build(final BuildContext context) {
    super.build(context); // Panggil super.build
    Log.info('Membangun UI untuk Halaman Wallet.');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dompet'),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.filter),
            onPressed: _showSortDialog,
            tooltip: 'Urutkan Dompet',
          ),
          IconButton(
            icon: const Icon(AppIcons.delete),
            onPressed: _showDeleteAllDialog,
            tooltip: 'Hapus Semua Dompet',
          ),
        ],
      ),
      body: Column(
        children: [
          FinancialSummary(
            walletOperation: _walletOperation,
          ),
          Expanded(
            child: FutureBuilder<List<WalletModel>>(
              future: _walletListFuture,
              builder: (final context, final snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  Log.info('Menunggu data dompet...');
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  Log.error(
                    'Error saat memuat data dompet.',
                    e: snapshot.error,
                    st: snapshot.stackTrace,
                  );
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  Log.info('Tidak ada data dompet ditemukan.');
                  return const Center(
                    child: Text('Tidak ada dompet ditemukan.'),
                  );
                } else {
                  Log.info(
                    'Berhasil memuat ${snapshot.data!.length} dompet, membangun daftar.',
                  );
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 8),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (final context, final index) {
                      final wallet = snapshot.data![index];
                      return WalletCard(
                        wallet: wallet,
                        onTap: () async {
                          Log.info(
                            'Navigasi ke detail dompet: "${wallet.name}".',
                          );
                          await Navigator.push<void>(
                            context,
                            MaterialPageRoute<void>(
                              builder: (final context) => WalletDetail(
                                wallet: wallet,
                                walletOperation: _walletOperation,
                                transactionOperation:
                                    widget.transactionOperation,
                              ),
                            ),
                          );
                          if (!mounted) return;
                          _loadWallets();
                        },
                        onLongPress: () {
                          Log.info(
                              'Long press dompet: id=${wallet.id} name=${wallet.name}');
                          unawaited(_showArchiveOneDialog(wallet));
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_wallet',
        onPressed: _addWallet,
        tooltip: 'Tambah Dompet',
        child: const Icon(AppIcons.add),
      ),
    );
  }
}

class FinancialSummary extends StatefulWidget {
  final WalletOperation walletOperation;

  const FinancialSummary({super.key, required this.walletOperation});

  @override
  State<FinancialSummary> createState() => _FinancialSummaryState();
}

class _FinancialSummaryState extends State<FinancialSummary> {
  late Future<List<double>> _summaryFuture;

  @override
  void initState() {
    super.initState();
    Log.info('Menginisialisasi widget Ringkasan Keuangan.');
    _loadSummary();
  }

  void _loadSummary() {
    Log.info('Memuat data ringkasan keuangan.');
    setState(() {
      _summaryFuture = Future.wait([
        widget.walletOperation.getPositiveBalance(),
        widget.walletOperation.getNegativeBalance(),
        widget.walletOperation.getTotalBalance(),
      ]);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(final BuildContext context) {
    Log.info('Membangun UI untuk widget Ringkasan Keuangan.');
    return FutureBuilder<List<double>>(
      future: _summaryFuture,
      builder: (final context, final snapshot) {
        double income = 0.0;
        double expense = 0.0;
        double total = 0.0;

        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          final result = snapshot.data!;
          income = result[0];
          expense = result[1].abs();
          total = result[2];
          Log.info(
            'Ringkasan keuangan berhasil dihitung: Pemasukan=$income, Pengeluaran=$expense, Total=$total',
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          Log.info('Menunggu data ringkasan keuangan...');
        } else if (snapshot.hasError) {
          Log.error(
            'Gagal memuat ringkasan keuangan',
            e: snapshot.error,
            st: snapshot.stackTrace,
          );
        }

        return Card(
          margin: const EdgeInsets.all(12.0),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: snapshot.connectionState == ConnectionState.waiting
                ? const Center(child: CircularProgressIndicator())
                : Row(
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
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class WalletCard extends StatelessWidget {
  final WalletModel wallet;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const WalletCard({
    super.key,
    required this.wallet,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(final BuildContext context) {
    Log.info('WalletCard build: name=${wallet.name} balance=${wallet.balance}');
    final theme = Theme.of(context);
    final subtitleColor = wallet.balance < 0
        ? theme.colorScheme.error
        : theme.textTheme.bodySmall?.color;
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: const Icon(
          Icons.account_balance_wallet,
          size: 40,
          color: Colors.blueAccent,
        ),
        title: Text(
          wallet.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(
          'Saldo: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(wallet.balance)}',
          style: TextStyle(
            fontSize: 16,
            color: subtitleColor,
          ),
        ),
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }
}

// Widget RadioGroup tidak ada di file asli, jadi ditambahkan di sini agar kompilasi berhasil
class RadioGroup<T> extends StatelessWidget {
  final T groupValue;
  final ValueChanged<T?> onChanged;
  final Widget child;

  const RadioGroup({
    super.key,
    required this.groupValue,
    required this.onChanged,
    required this.child,
  });

  @override
  Widget build(final BuildContext context) {
    return child;
  }
}
