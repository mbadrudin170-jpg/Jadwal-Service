// path lib/fitur/transaksi/page/riwayat_aktivasi_paket.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:wifi/admin/providers/riwayat_aktivasi_paket_provider.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/riwayat_aktivasi/page/detail_riwayat_aktivasi.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/page/form_transaksi.dart';
import 'package:wifi/fitur/transaksi/provider/transaksi_provider.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/widget/package_name.dart';

class RiwayatAktivasiPaket extends ConsumerStatefulWidget {
  const RiwayatAktivasiPaket({super.key});
  @override
  ConsumerState<RiwayatAktivasiPaket> createState() =>
      _RiwayatAktivasiPaketState();
}

class _RiwayatAktivasiPaketState extends ConsumerState<RiwayatAktivasiPaket> {
  final ScrollController _pengendaliScroll = ScrollController();
  int _jumlahTampil = 20;

  @override
  void initState() {
    super.initState();
    _pengendaliScroll.addListener(_deteksiScroll);
  }

  @override
  void dispose() {
    _pengendaliScroll.removeListener(_deteksiScroll);
    _pengendaliScroll.dispose();
    super.dispose();
  }

  void _deteksiScroll() {
    // Menambah data jika scroll mencapai batas bawah
    if (_pengendaliScroll.position.pixels >=
        _pengendaliScroll.position.maxScrollExtent - 200) {
      final state = ref.read(riwayatAktivasiPaketProvider).value;
      if (state != null && _jumlahTampil < state.items.length) {
        setState(() {
          _jumlahTampil += 20;
        });
      }
    }
  }

  Future<void> _dialogOpsi(TransaksiModel transaksi) async {
    final aksiDipilih = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Pilih Aksi'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'edit'),
              child: const Text('Edit'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'hapus'),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (aksiDipilih != null) {
      // Lakukan sesuatu berdasarkan aksi yang dipilih
      Log.info('Aksi dipilih: $aksiDipilih');

      if (aksiDipilih == 'edit') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FormTransaksi(transaksi: transaksi),
          ),
        );
      } else if (aksiDipilih == 'hapus') {
        // Panggil fungsi hapus
        _dialogKonfirmasiSoftDelete(transaksi);
      }
    }
  }

  Future<void> _dialogKonfirmasiSoftDelete(TransaksiModel transaksi) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin menghapus transaksi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              ref.read(transaksiProvider.notifier).softDelete(transaksi.id);
              Navigator.pop(context);
            },
            child: const Text('Iya', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          final itemsTampil = state.items.take(_jumlahTampil).toList();
          return ListView.builder(
            controller: _pengendaliScroll,
            itemCount:
                state.items.length +
                (_jumlahTampil < state.items.length ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == itemsTampil.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              final item = itemsTampil[index];
              final transaksi = item.transaksi;
              final warnaStatusPembayaran =
                  transaksi.statusPembayaran == StatusPembayaran.paid
                  ? Colors.green
                  : Colors.red;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                child: ListTile(
                  onTap: () async {
                    Log.info('Melihat detail riwayat langganan.', {
                      'transactionId': transaksi.id,
                    });
                    await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailRiwayatAktivasiPage(
                          idTransaksi: transaksi.id,
                        ),
                      ),
                    );
                  },
                  onLongPress: () => _dialogOpsi(transaksi),
                  title: Text(
                    item.namaPelanggan,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PackageNameWidget(
                        paketFuture: paketOpSqlite.ambilBerdasarkanId(
                          transaksi.idPaket ?? '',
                        ),
                        style: TextStyle(color: warnaStatusPembayaran),
                      ),
                      gapH4,
                      Text(
                        'Status: ${transaksi.statusPembayaran.displayName}',
                        style: TextStyle(
                          color: warnaStatusPembayaran,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      gapH4,
                      if (transaksi.tanggalMulai != null &&
                          transaksi.tanggalBerakhir != null)
                        Text(
                          'Aktif: ${FormatTanggal.formatDasar(transaksi.tanggalMulai!)} - ${FormatTanggal.formatDasar(transaksi.tanggalBerakhir!)}',
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
