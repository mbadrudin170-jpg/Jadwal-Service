// path: lib/admin/halaman/tab/wallet_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wifi/admin/halaman/detail/wallet_detail.dart';
import 'package:wifi/admin/halaman/form/wallet_form.dart';
import 'package:wifi/admin/providers/wallet_provider.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/wallet_model.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/financial_summary_widget.dart';

// Mengubah dari StatefulWidget menjadi ConsumerWidget agar bisa mengakses provider
class WalletPage extends ConsumerWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Log.info('Membangun UI untuk Halaman Wallet (ConsumerWidget).');
    final walletStateAsync = ref.watch(walletProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dompet'),
        actions: [
          IconButton(
            icon: const Icon(TIcons.refresh),
            onPressed: () {
              Log.info('[Aksi Pengguna] Tombol refresh ditekan.');
              unawaited(ref.read(walletProvider.notifier).refresh());
              ToastUtil.info(context, 'Menyegarkan data dompet...');
            },
            tooltip: 'Segarkan Data',
          ),
          // Aksi lain tetap sama
          IconButton(
            icon: const Icon(TIcons.delete),
            onPressed: () => _showDeleteAllDialog(context, ref),
            tooltip: 'Hapus Semua Dompet',
          ),
        ],
      ),
      body: walletStateAsync.when(
        loading: () {
          Log.info('WalletProvider sedang loading.');
          return const Center(child: CircularProgressIndicator());
        },
        // Menampilkan pesan error jika terjadi kesalahan
        error: (err, stack) {
          Log.error('Error saat memuat WalletProvider.', e: err, st: stack);
          return Center(
            child: Text('Terjadi kesalahan: $err'),
          );
        },
        // Menampilkan data jika berhasil dimuat
        data: (walletState) {
          Log.info(
            'WalletProvider berhasil memuat ${walletState.wallets.length} dompet.',
          );
          final wallets = walletState.wallets;
          if (wallets.isEmpty) {
            return const Center(child: Text('Tidak ada dompet ditemukan.'));
          }

          return Column(
            children: [
              FinancialSummary(
                totalPositiveBalance: walletState.totalPositiveBalance,
                totalNegativeBalance: walletState.totalNegativeBalance,
                totalBalance: walletState.totalBalance,
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 8),
                  itemCount: wallets.length,
                  itemBuilder: (context, index) {
                    final wallet = wallets[index];
                    return WalletCard(
                      wallet: wallet,
                      onTap: () => _navigateToDetail(context, ref, wallet),
                      onLongPress: () =>
                          _showArchiveOneDialog(context, ref, wallet),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_wallet',
        onPressed: () => _navigateToAddForm(context, ref),
        tooltip: 'Tambah Dompet',
        child: const Icon(TIcons.add),
      ),
    );
  }

  Future<void> _navigateToAddForm(BuildContext context, WidgetRef ref) async {
    Log.info('Navigasi ke halaman tambah dompet.');
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(builder: (context) => const WalletForm()),
    );
    if (result ?? false) {
      Log.info('Berhasil menambahkan dompet baru, memicu refresh.');
      // Tidak perlu setState, cukup panggil notifier
      ref.read(walletProvider.notifier).refresh();
    }
  }

  Future<void> _navigateToDetail(
      BuildContext context, WidgetRef ref, WalletModel wallet) async {
    Log.info('Navigasi ke detail dompet: "${wallet.name}".');
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => WalletDetail(wallet: wallet),
      ),
    );
    // Setelah kembali dari detail, refresh data untuk jaga-jaga ada perubahan
    Log.info('Kembali dari detail dompet, memicu refresh.');
    ref.read(walletProvider.notifier).refresh();
  }

  Future<void> _showDeleteAllDialog(BuildContext context, WidgetRef ref) async {
    Log.info('Menampilkan dialog konfirmasi hapus semua dompet.');
    final wallets = ref.read(walletProvider).value?.wallets ?? [];

    if (wallets.isEmpty) {
      Log.warning('Tidak ada dompet untuk dihapus.');
      ToastUtil.info(context, 'Tidak ada dompet untuk dihapus.');
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text(
              'Apakah Anda yakin ingin menghapus semua dompet? Aksi ini tidak dapat diurungkan.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Hapus'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                ref.read(walletProvider.notifier).deleteAllWallets().then((_) {
                  ToastUtil.success(context, 'Semua dompet berhasil dihapus.');
                }).catchError((e, st) {
                  Log.error('Gagal menghapus semua dompet.', e: e, st: st as StackTrace?);
                  ToastUtil.error(context, 'Gagal menghapus dompet: $e');
                });
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showArchiveOneDialog(
      BuildContext context, WidgetRef ref, WalletModel wallet) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Arsip'),
          content: Text(
              'Apakah Anda yakin ingin mengarsipkan dompet "${wallet.name}"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Arsipkan'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                ref
                    .read(walletProvider.notifier)
                    .softDelete(wallet.id)
                    .then((_) {
                  ToastUtil.success(context, 'Dompet berhasil diarsipkan.');
                }).catchError((Object e, StackTrace st) {
                  Log.error('Gagal mengarsipkan dompet.', e: e, st: st);
                  ToastUtil.error(context, 'Gagal mengarsipkan: $e');
                });
              },
            ),
          ],
        );
      },
    );
  }
}

// Widget FinancialSummary disederhanakan menjadi StatelessWidget karena datanya
// kini dipasok dari parent.
class FinancialSummary extends StatelessWidget {
  final double totalPositiveBalance;
  final double totalNegativeBalance;
  final double totalBalance;

  const FinancialSummary({
    super.key,
    required this.totalPositiveBalance,
    required this.totalNegativeBalance,
    required this.totalBalance,
  });

  @override
  Widget build(BuildContext context) {
    Log.info('Membangun UI untuk widget Ringkasan Keuangan.');
    return Card(
      margin: const EdgeInsets.all(12.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            buildFinancialSummaryInfo(
              context: context,
              label: 'Pemasukan',
              amount: totalPositiveBalance,
              color: Colors.green,
            ),
            buildFinancialSummaryInfo(
              context: context,
              label: 'Pengeluaran',
              amount: totalNegativeBalance,
              color: Colors.red,
            ),
            buildFinancialSummaryInfo(
              context: context,
              label: 'Total',
              amount: totalBalance,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
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
  Widget build(BuildContext context) {
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
