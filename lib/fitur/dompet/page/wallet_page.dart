// path: lib/fitur/dompet/page/wallet_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wifi/admin/halaman/detail/detail_dompet.dart';
import 'package:wifi/admin/halaman/form/wallet_form.dart';
import 'package:wifi/fitur/dompet/provider/wallet_provider.dart';
import 'package:wifi/shared/common/text.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/model/wallet_model.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/financial_summary_widget.dart';

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
        error: (err, stack) {
          Log.error('Error saat memuat WalletProvider.', e: err, s: stack);
          return Center(
            child: Text(
              'Terjadi kesalahan: $err',
              style: context.textTheme.bodyMedium,
            ),
          );
        },
        data: (walletState) {
          Log.info(
            'WalletProvider berhasil memuat ${walletState.wallets.length} dompet.',
          );
          final wallets = walletState.wallets;
          if (wallets.isEmpty) {
            return Center(
              child: Text('Tidak ada dompet ditemukan.',
                  style: context.textTheme.bodyMedium),
            );
          }

          return Column(
            children: [
              FinancialSummaryWidget(
                income: walletState.totalSaldoPositif,
                expense: walletState.totalSaldoNegatif,
                total: walletState.totalSaldo,
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: TSizes.p8),
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
      ref.read(walletProvider.notifier).refresh();
    }
  }

  Future<void> _navigateToDetail(
      BuildContext context, WidgetRef ref, WalletModel wallet) async {
    Log.info('Navigasi ke detail dompet: "${wallet.name}".');
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => DetailDompet(dompet: wallet),
      ),
    );
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
                unawaited(
                    ref.read(walletProvider.notifier).softDeleteAll().then((_) {
                  if (context.mounted) {
                    ToastUtil.success(
                        context, 'Semua dompet berhasil dihapus.');
                  }
                }).catchError((Object e, StackTrace s) {
                  Log.error('Gagal menghapus semua dompet.', e: e, s: s);
                  if (context.mounted) {
                    ToastUtil.error(context, 'Gagal menghapus dompet: $e');
                  }
                }));
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
                unawaited(ref
                    .read(walletProvider.notifier)
                    .softDelete(wallet.id)
                    .then((_) {
                  if (context.mounted) {
                    ToastUtil.success(context, 'Dompet berhasil diarsipkan.');
                  }
                }).catchError((Object e, StackTrace st) {
                  Log.error('Gagal mengarsipkan dompet.', e: e, s: st);
                  if (context.mounted) {
                    ToastUtil.error(context, 'Gagal mengarsipkan: $e');
                  }
                }));
              },
            ),
          ],
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
  Widget build(BuildContext context) {
    Log.info('WalletCard build: name=${wallet.name} balance=${wallet.balance}');
    final subtitleColor = wallet.balance < 0
        ? context.colorScheme.error
        : context.textTheme.bodySmall?.color;
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(
          horizontal: TSizes.p16, vertical: TSizes.p8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(TSizes.p16),
        leading: const Icon(
          TIcons.wallet,
          size: 40,
          color: TColors.primaryColor,
        ),
        title: TeksJudulSedang(
          wallet.name,
        ),
        subtitle: TeksIsiSedang(
          'Saldo: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(wallet.balance)}',
          warna: subtitleColor,
        ),
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }
}
