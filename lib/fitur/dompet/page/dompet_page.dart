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
            onPressed: () {
              ToastUtil.info(context, 'Fitur dalam pengembangan');
            },
            icon: Icon(TIcons.sort),
          ),
          IconButton(
            icon: const Icon(TIcons.delete),
            onPressed: () => _tampilkanDialogSoftDeleteAll(context, ref),
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
        data: (dompetState) {
          Log.info(
            'WalletProvider berhasil memuat ${dompetState.daftarDompet.length} dompet.',
          );
          final daftarDompet = dompetState.daftarDompet;
          if (daftarDompet.isEmpty) {
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
                pemasukan: dompetState.totalSaldoPositif,
                pengeluaran: dompetState.totalSaldoNegatif,
                total: dompetState.totalSaldo,
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: TSizes.p8),
                  itemCount: daftarDompet.length,
                  itemBuilder: (context, index) {
                    final dompet = daftarDompet[index];
                    return WalletCard(
                      dompet: dompet,
                      onTap: () =>
                          _navigasiKeDetailDompet(context, ref, dompet),
                      onLongPress: () =>
                          _tampilkanDialogSoftDelete(context, ref, dompet),
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

  void _navigasiKeForm(BuildContext context, WidgetRef ref) {
    Log.info('Navigasi ke halaman tambah dompet.');
    Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (context) => const FormDompet()),
    );
  }

  void _navigasiKeDetailDompet(
    BuildContext context,
    WidgetRef ref,
    DompetModel dompet,
  ) {
    Log.info('Navigasi ke detail dompet: "${dompet.nama}".');
    Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (context) => DetailDompet(dompet: dompet)),
    );
  }

  Future<void> _tampilkanDialogSoftDeleteAll(
    BuildContext context,
    WidgetRef ref,
  ) async {
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
              child: const Text('Hapus Semua'),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                try {
                  await ref.read(dompetProvider.notifier).softDeleteAll();
                  if (context.mounted) {
                    ToastUtil.success(
                      context,
                      'Semua dompet berhasil dihapus.',
                    );
                  }
                  unawaited(
                    ref
                        .read(layananCekSinkronisasiProvider)
                        .jalankanCekSinkronisasi(),
                  );
                } on Exception catch (e) {
                  if (context.mounted) {
                    ToastUtil.error(context, 'Gagal menghapus dompet: $e');
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _tampilkanDialogSoftDelete(
    BuildContext context,
    WidgetRef ref,
    DompetModel dompet,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text(
            'Apakah Anda yakin ingin menghapus dompet "${dompet.nama}"?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Hapus'),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                try {
                  await ref.read(dompetProvider.notifier).softDelete(dompet.id);
                  if (context.mounted) {
                    ToastUtil.success(context, 'Dompet berhasil dihapus.');
                  }
                  unawaited(
                    ref
                        .read(layananCekSinkronisasiProvider)
                        .jalankanCekSinkronisasi(),
                  );
                } on Exception catch (e) {
                  if (context.mounted) {
                    ToastUtil.error(context, 'Gagal menghapus: $e');
                  }
                }
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
