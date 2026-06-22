// path lib/fitur/transaksi/page/riwayat_aktivasi_paket.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/admin/providers/riwayat_aktivasi_paket_provider.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/riwayat_aktivasi/page/detail_riwayat_aktivasi.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/page/form_transaksi.dart';
import 'package:wifi/fitur/transaksi/provider/transaksi_provider.dart';
import 'package:wifi/shared/common/teks.dart';
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
  final TextEditingController _cariController = TextEditingController();
  late final FocusNode _cariFocusNode;
  int _jumlahTampil = 20;
  String _kataKunciCari = '';

  @override
  void initState() {
    super.initState();
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

  /// Filter data berdasarkan kata kunci cari
  List<TransactionWithCustomer> _filterData(
    List<TransactionWithCustomer> items,
    String katakunci,
  ) {
    if (katakunci.isEmpty) return items;

    final katakunciLower = katakunci.toLowerCase();
    return items.where((item) {
      // Cari di nama pelanggan
      if (item.namaPelanggan.toLowerCase().contains(katakunciLower)) {
        return true;
      }
      // Cari di deskripsi/keterangan
      if (item.transaksi.deskripsi.toLowerCase().contains(katakunciLower)) {
        return true;
      }
      // Cari di ID transaksi
      if (item.transaksi.id.toLowerCase().contains(katakunciLower)) {
        return true;
      }
      return false;
    }).toList();
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
        if (!mounted) return;
        await Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (context) => FormTransaksi(transaksi: transaksi),
          ),
        );
      } else if (aksiDipilih == 'hapus') {
        // Panggil fungsi hapus
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
        title: _kataKunciCari.isEmpty
            ? const TeksJudulBesar('Riwayat Langganan', warna: Colors.white)
            : TextField(
                controller: _cariController,
                focusNode: _cariFocusNode,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Cari data',
                  hintStyle: const TextStyle(color: Colors.white),
                  border: InputBorder.none,
                  suffixIcon: _kataKunciCari.isNotEmpty
                      ? IconButton(
                          icon: const Icon(TIcons.close, color: Colors.white),
                          onPressed: () {
                            _cariController.clear();
                            setState(() {
                              _kataKunciCari = '';
                              _jumlahTampil = 20;
                            });
                          },
                        )
                      : null,
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() {
                    _kataKunciCari = value;
                    _jumlahTampil = 20;
                  });
                },
              ),
        actions: [
          if (_kataKunciCari.isEmpty)
            IconButton(
              onPressed: () {
                setState(() {
                  _kataKunciCari = ' ';
                });
                Future.microtask(() => _cariFocusNode.requestFocus());
              },
              icon: const Icon(TIcons.search),
            ),
          if (_kataKunciCari.isEmpty)
            IconButton(
              icon: const Icon(TIcons.filter),
              onPressed: () {
                if (historyAsync.hasValue) {
                  Log.info('Membuka dialog pengurutan riwayat langganan.');
                  _tampilkanDialogUrutan(context, ref, historyAsync.value!.sortBy);
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
          final itemsFiltered = _filterData(state.items, _kataKunciCari);
          if (itemsFiltered.isEmpty) {
            return const Center(
              child: Text('Tidak ada riwayat langganan ditemukan.'),
            );
          }
          final itemsTampil = itemsFiltered.take(_jumlahTampil).toList();
          return ListView.builder(
            controller: _pengendaliScroll,
            itemCount:
                itemsFiltered.length + (_jumlahTampil < itemsFiltered.length ? 1 : 0),
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

  Future<void> _tampilkanDialogUrutan(
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
