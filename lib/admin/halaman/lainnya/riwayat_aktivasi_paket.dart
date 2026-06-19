// path: lib/admin/halaman/lainnya/riwayat_aktivasi_paket.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:wifi/admin/providers/riwayat_aktivasi_paket_provider.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/riwayat_aktivasi/page/detail_riwayat_aktivasi.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/widget/package_name.dart';

class RiwayatAktivasiPaket extends ConsumerWidget {
  const RiwayatAktivasiPaket({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(riwayatAktivasiPaketProvider);
    final paketOpSqlite = ref.watch(paketOpSqliteProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Langganan'),
        actions: [
          IconButton(
            icon: const Icon(TIcons.filter),
            onPressed: () {
              if (historyAsync.hasValue) {
                Log.info('Membuka dialog pengurutan riwayat langganan.');
                unawaited(
                  _showSortDialog(context, ref, historyAsync.value!.sortBy),
                );
              }
            },
            tooltip: 'Urutkan',
          ),
        ],
      ),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (state) {
          if (state.items.isEmpty) {
            return const Center(
              child: Text('Tidak ada riwayat langganan ditemukan.'),
            );
          }
          return ListView.builder(
            itemCount: state.items.length,
            itemBuilder: (context, index) {
              final item = state.items[index];
              final transaction = item.transaksi;
              final paymentStatusColor =
                  transaction.statusPembayaran == StatusPembayaran.paid
                  ? Colors.green
                  : Colors.red;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                child: ListTile(
                  onTap: () async {
                    Log.info('Melihat detail riwayat langganan.', {
                      'transactionId': transaction.id,
                    });
                    await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailRiwayatAktivasiPage(
                          transactionId: transaction.id,
                        ),
                      ),
                    );
                  },
                  title: Text(
                    item.customerName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PackageNameWidget(
                        paketFuture: paketOpSqlite.ambilBerdasarkanId(
                          transaction.idPaket ?? '',
                        ),
                        style: TextStyle(color: paymentStatusColor),
                      ),
                      gapH4,
                      Text(
                        'Status: ${transaction.statusPembayaran.displayName}',
                        style: TextStyle(
                          color: paymentStatusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      gapH4,
                      if (transaction.tanggalMulai != null &&
                          transaction.tanggalBerakhir != null)
                        Text(
                          'Aktif: ${FormatTanggal.formatDasar(transaction.tanggalMulai!)} - ${FormatTanggal.formatDasar(transaction.tanggalBerakhir!)}',
                        ),
                    ],
                  ),
                  trailing: const Icon(TIcons.chevronRight),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showSortDialog(
    BuildContext context,
    WidgetRef ref,
    SortOption currentSort,
  ) async {
    final SortOption? selected = await showDialog<SortOption>(
      context: context,
      builder: (BuildContext context) {
        Widget buildOption(String text, SortOption value) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, value),
            child: Text(
              text,
              style: TextStyle(
                fontWeight: currentSort == value
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          );
        }

        return SimpleDialog(
          title: const Text('Urutkan Berdasarkan'),
          children: <Widget>[
            buildOption('Berakhir Hari Ini', SortOption.beralhirHariIni),
            buildOption('Tanggal Berakhir', SortOption.tanggalBerakhir),
            buildOption('Nama A-Z', SortOption.namaAZ),
            buildOption('Nama Z-A', SortOption.namaZA),
            buildOption('Lunas', SortOption.lunas),
            buildOption('Belum Lunas', SortOption.belumLunas),
            buildOption('Update Terbaru', SortOption.diperbaruiPadaAZ),
            buildOption('Update Terlama', SortOption.diperbaruiPadaZA),
          ],
        );
      },
    );

    if (selected != null) {
      ref.read(riwayatAktivasiPaketProvider.notifier).changeSort(selected);
    }
  }
}
