// path lib/fitur/riwayat_aktivasi/page/riwayat_aktivasi_paket.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/riwayat_aktivasi/page/detail_riwayat_aktivasi.dart';
import 'package:wifi/fitur/riwayat_aktivasi/provider/riwayat_aktivasi_paket_provider.dart';
import 'package:wifi/fitur/sinkronisasi/layanan_cek_sinkronisasi.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_global.dart';
import 'package:wifi/fitur/transaksi/page/form_transaksi.dart';
import 'package:wifi/shared/common/teks.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/fitur/paket/widget/nama_paket_widget.dart';

class RiwayatAktivasiPaket extends ConsumerStatefulWidget {
  const RiwayatAktivasiPaket({super.key});
  @override
  ConsumerState<RiwayatAktivasiPaket> createState() =>
      _RiwayatAktivasiPaketState();
}

class _RiwayatAktivasiPaketState extends ConsumerState<RiwayatAktivasiPaket> {
  final ScrollController _pengendaliScroll = ScrollController();
  final TextEditingController _cariController = TextEditingController();
  late final FocusNode _cariFocusNode;
  int _jumlahTampil = 20;
  String _queryCari = '';
  bool _sedangMemuatLebih = false;
  bool _sedangMencari = false; // Perbaikan 1: State khusus untuk mode pencarian

  @override
  void initState() {
    super.initState();
    ref.listenManual(riwayatAktivasiPaketProvider, (prev, next) {
      if (next.hasValue && mounted) {
        setState(() => _jumlahTampil = 20);
      }
    });
    _pengendaliScroll.addListener(_deteksiScroll);
    _cariFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _pengendaliScroll.removeListener(_deteksiScroll);
    _pengendaliScroll.dispose();
    _cariController.dispose();
    _cariFocusNode.dispose();
    super.dispose();
  }

  void _deteksiScroll() {
    if (_sedangMemuatLebih) return;
    if (_pengendaliScroll.position.pixels >=
        _pengendaliScroll.position.maxScrollExtent - 200) {
      final state = ref.read(riwayatAktivasiPaketProvider).value;
      if (state == null) return;

      final itemsFiltered = _filterData(state.items, _queryCari);
      if (_jumlahTampil < itemsFiltered.length) {
        setState(() {
          _sedangMemuatLebih = true;
          _jumlahTampil += 20;
        });
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) setState(() => _sedangMemuatLebih = false);
        });
      }
    }
  }

  List<TransaksiDenganPelanggan> _filterData(
    List<TransaksiDenganPelanggan> items,
    String katakunci,
  ) {
    if (katakunci.trim().isEmpty) return items;

    final katakunciLower = katakunci.toLowerCase().trim();
    return items.where((item) {
      return item.namaPelanggan.toLowerCase().contains(katakunciLower) ||
          item.transaksi.deskripsi.toLowerCase().contains(katakunciLower) ||
          item.transaksi.id.toLowerCase().contains(katakunciLower);
    }).toList();
  }

  Future<void> _dialogOpsi(TransaksiModel transaksi) async {
    final aksiDipilih = await showDialog<String>(
      context: context,
      builder: (context) {
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
      Log.info('Aksi dipilih: $aksiDipilih');

      if (aksiDipilih == 'edit') {
        if (!mounted) return;
        await Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (context) => FormTransaksi(transaksi: transaksi),
          ),
        );
      } else if (aksiDipilih == 'hapus') {
        await _dialogKonfirmasiSoftDelete(transaksi);
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
            onPressed: () async {
              await ref
                  .read(transaksiOpGlobalProvider)
                  .softDelete(transaksi.id);
              unawaited(
                ref
                    .read(layananCekSinkronisasiProvider)
                    .jalankanCekSinkronisasi(),
              );
              ref.invalidate(riwayatAktivasiPaketProvider);
              if (!context.mounted) return;
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

    return Scaffold(
      appBar: AppBar(
        // Perbaikan Utama pada Logika Tampilan AppBar
        title: !_sedangMencari
            ? const TeksJudulBesar('Riwayat Langganan', warna: Colors.white)
            : TextField(
                controller: _cariController,
                focusNode: _cariFocusNode,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Cari data...',
                  hintStyle: const TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                  prefixIcon: const Icon(TIcons.search, color: Colors.white),
                  suffixIcon: IconButton(
                    icon: const Icon(TIcons.close, color: Colors.white),
                    onPressed: () {
                      _cariController.clear();
                      setState(() {
                        _queryCari = '';
                        _jumlahTampil = 20;
                        _sedangMencari = false; // Keluar dari mode pencarian
                      });
                    },
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() {
                    _queryCari = value;
                    _jumlahTampil = 20;
                  });
                },
              ),
        actions: [
          if (!_sedangMencari) ...[
            IconButton(
              onPressed: () {
                setState(() {
                  _sedangMencari = true;
                });
                Future.microtask(() => _cariFocusNode.requestFocus());
              },
              icon: const Icon(TIcons.search),
            ),
            IconButton(
              icon: const Icon(TIcons.filter),
              onPressed: () {
                if (historyAsync.hasValue) {
                  Log.info('Membuka dialog pengurutan riwayat langganan.');
                  _tampilkanDialogUrutan(
                    context,
                    ref,
                    historyAsync.value!.sortBy,
                  );
                }
              },
              tooltip: 'Urutkan',
            ),
          ],
        ],
      ),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (state) {
          final itemsFiltered = _filterData(state.items, _queryCari);
          if (itemsFiltered.isEmpty) {
            return const Center(
              child: Text('Tidak ada riwayat langganan ditemukan.'),
            );
          }
          final itemsTampil = itemsFiltered.take(_jumlahTampil).toList();
          return ListView.builder(
            controller: _pengendaliScroll,
            itemCount:
                itemsTampil.length +
                (_jumlahTampil < itemsFiltered.length ? 1 : 0),
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
                      NamaPaketWidget(
                        idPaket: transaksi.idPaket ?? '',
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

  Future<void> _tampilkanDialogUrutan(
    BuildContext context,
    WidgetRef ref,
    OpsiUrutan currentSort,
  ) async {
    final dipilih = await showDialog<OpsiUrutan>(
      context: context,
      builder: (context) {
        Widget buildOption(String text, OpsiUrutan value) {
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
            // Perbaikan: Pastikan enum beralhirHariIni sudah dibetulkan typo-nya jika diperlukan
            buildOption('Berakhir Hari Ini', OpsiUrutan.berakhirHariIni),
            buildOption('Tanggal Berakhir', OpsiUrutan.tanggalBerakhir),
            buildOption('Nama A-Z', OpsiUrutan.namaAZ),
            buildOption('Nama Z-A', OpsiUrutan.namaZA),
            buildOption('Lunas', OpsiUrutan.lunas),
            buildOption('Belum Lunas', OpsiUrutan.belumLunas),
            buildOption('Update Terbaru', OpsiUrutan.diperbaruiPadaAZ),
            buildOption('Update Terlama', OpsiUrutan.diperbaruiPadaZA),
          ],
        );
      },
    );

    if (dipilih != null) {
      ref.read(riwayatAktivasiPaketProvider.notifier).changeSort(dipilih);
    }
  }
}
