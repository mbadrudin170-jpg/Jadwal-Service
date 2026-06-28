// path: lib/fitur/dompet/page/dompet_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wifi/fitur/dompet/model/dompet_model.dart';
import 'package:wifi/fitur/dompet/page/detail_dompet.dart';
import 'package:wifi/fitur/dompet/page/form_dompet.dart';
import 'package:wifi/fitur/dompet/provider/dompet_provider.dart';
import 'package:wifi/fitur/sinkronisasi/layanan_cek_sinkronisasi.dart';
import 'package:wifi/shared/common/teks.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/ringkasan_keuangan_widget.dart';

class DompetPage extends ConsumerWidget {
  const DompetPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Log.info('Membangun UI untuk Halaman Wallet (ConsumerWidget).');
    final dompetStateAsync = ref.watch(dompetProvider);
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
      body: dompetStateAsync.when(
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
            'WalletProvider berhasil memuat ${walletState.daftarDompet.length} dompet.',
          );
          final wallets = walletState.daftarDompet;
          if (wallets.isEmpty) {
            return Center(
              child: Text(
                'Tidak ada dompet ditemukan.',
                style: context.textTheme.bodyMedium,
              ),
            );
          }

          return Column(
            children: [
              RingkasanKeuanganWidget(
                pemasukan: walletState.totalSaldoPositif,
                pengeluaran: walletState.totalSaldoNegatif,
                total: walletState.totalSaldo,
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: TSizes.p8),
                  itemCount: wallets.length,
                  itemBuilder: (context, index) {
                    final wallet = wallets[index];
                    return WalletCard(
                      dompet: wallet,
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
        onPressed: () => _navigasiKeForm(context, ref),
        tooltip: 'Tambah Dompet',
        child: const Icon(TIcons.add),
      ),
    );
  }

  Future<void> _navigasiKeForm(BuildContext context, WidgetRef ref) async {
    Log.info('Navigasi ke halaman tambah dompet.');
    final hasil = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(builder: (context) => const FormDompet()),
    );
    if (hasil ?? false) {
      Log.info('Berhasil menambahkan dompet baru, memicu refresh.');
      await ref.read(dompetProvider.notifier).refresh();
    }
  }

  Future<void> _navigateToDetail(
    BuildContext context,
    WidgetRef ref,
    DompetModel dompet,
  ) async {
    Log.info('Navigasi ke detail dompet: "${dompet.nama}".');
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => DetailDompet(dompet: dompet),
      ),
    );
    Log.info('Kembali dari detail dompet, memicu refresh.');
    await ref.read(dompetProvider.notifier).refresh();
  }

  Future<void> _showDeleteAllDialog(BuildContext context, WidgetRef ref) async {
    Log.info('Menampilkan dialog konfirmasi hapus semua dompet.');
    final daftarDompet = ref.read(dompetProvider).value?.daftarDompet ?? [];
    if (daftarDompet.isEmpty) {
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
            'Apakah Anda yakin ingin menghapus semua dompet? Aksi ini tidak dapat diurungkan.',
          ),
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
                  ref
                      .read(dompetProvider.notifier)
                      .softDeleteAll()
                      .then((_) {
                        if (context.mounted) {
                          ToastUtil.success(
                            context,
                            'Semua dompet berhasil dihapus.',
                          );
                        }
                      })
                      .catchError((Object e, StackTrace s) {
                        Log.error('Gagal menghapus semua dompet.', e: e, s: s);
                        if (context.mounted) {
                          ToastUtil.error(
                            context,
                            'Gagal menghapus dompet: $e',
                          );
                        }
                      }),
                );
                ref
                    .read(layananCekSinkronisasiProvider)
                    .jalankanCekSinkronisasi();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showArchiveOneDialog(
    BuildContext context,
    WidgetRef ref,
    DompetModel dompet,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Arsip'),
          content: Text(
            'Apakah Anda yakin ingin mengarsipkan dompet "${dompet.nama}"?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Arsipkan'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                unawaited(
                  ref
                      .read(dompetProvider.notifier)
                      .softDelete(dompet.id)
                      .then((_) {
                        if (context.mounted) {
                          ToastUtil.success(
                            context,
                            'Dompet berhasil diarsipkan.',
                          );
                        }
                      })
                      .catchError((Object e, StackTrace st) {
                        Log.error('Gagal mengarsipkan dompet.', e: e, s: st);
                        if (context.mounted) {
                          ToastUtil.error(context, 'Gagal mengarsipkan: $e');
                        }
                      }),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class WalletCard extends StatelessWidget {
  final DompetModel dompet;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const WalletCard({
    super.key,
    required this.dompet,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    Log.info('WalletCard build: name=${dompet.nama} balance=${dompet.saldo}');
    final subtitleColor = dompet.saldo < 0
        ? context.colorScheme.error
        : context.textTheme.bodySmall?.color;
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(
        horizontal: TSizes.p16,
        vertical: TSizes.p8,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(TSizes.p16),
        leading: const Icon(
          TIcons.wallet,
          size: 40,
          color: TColors.primaryColor,
        ),
        title: TeksJudulSedang(dompet.nama),
        subtitle: TeksIsiSedang(
          'Saldo: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(dompet.saldo)}',
          warna: subtitleColor,
        ),
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }
}
