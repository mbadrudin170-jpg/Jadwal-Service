// path: lib/fitur/pelanggan_aktif/page/pelanggan_aktif_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/pelanggan_aktif/helper/pengurut_pelanggan_aktif.dart';
import 'package:wifi/fitur/pelanggan_aktif/model/detail_pelanggan_aktif_model.dart';
import 'package:wifi/fitur/pelanggan_aktif/page/detail_pelanggan_aktif.dart';
import 'package:wifi/fitur/pelanggan_aktif/page/form_pelanggan_aktif.dart';
import 'package:wifi/fitur/pelanggan_aktif/provider/pelanggan_aktif_provider.dart';
import 'package:wifi/fitur/sinkronisasi/layanan_cek_sinkronisasi.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/operation.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/theme/app_sizes.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/perhitungan_util.dart';
import 'package:wifi/shared/utils/toast_util.dart';

enum OpsiLanjutan { softDeleteAll, arsipkanKadaluarsa, batal }

class PelangganAktifPage extends ConsumerStatefulWidget {
  const PelangganAktifPage({super.key});

  @override
  ConsumerState<PelangganAktifPage> createState() => _PelangganAktifPageState();
}

class _PelangganAktifPageState extends ConsumerState<PelangganAktifPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _mencari = false;

  @override
  void initState() {
    super.initState();
    Log.info('ActiveCustomerPage initState');
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(_inisialisasiAwal());
      }
    });
  }

  Future<void> _inisialisasiAwal() async {
    try {
      await _pelangganAktifOpSqlite.arsipkanLanggananKadaluarsa();
    } catch (e) {
      Log.error('Gagal menjalankan arsip otomatis saat aplikasi dibuka', e: e);
    }
    if (mounted) {
      await ref.read(pelangganAktifProvider.notifier).perbaruiData();
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  PelangganAktifOpSqlite get _pelangganAktifOpSqlite =>
      ref.read(pelangganAktifOpSqliteProvider);
  TransaksiOpSqlite get _transaksiOpsqlite =>
      ref.read(transaksiOpSqliteProvider);

  void _onSearchChanged() {
    setState(() {});
  }

  Future<void> refreshData() async {
    try {
      await _pelangganAktifOpSqlite.arsipkanLanggananKadaluarsa();
    } catch (e) {
      Log.error('Gagal arsip otomatis saat refresh', e: e);
    }
  }

  Future<void> _softDeletePelangganAktif(
    final DetailPelangganAktifModel pelanggan,
  ) async {
    final idPelangganAktif = pelanggan.pelangganAktif.id;
    final namaPelanggan = pelanggan.namaPelanggan;
    final idTransaksi = pelanggan.pelangganAktif.idTransaksi;
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Arsipkan'),
        content: Text('Yakin ingin mengarsipkan pelanggan "$namaPelanggan"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (konfirmasi == true) {
      try {
        await _pelangganAktifOpSqlite.softDeletePelangganAktifDanTransaksi(
          idPelangganAktif,
          idTransaksi,
        );
        Log.info('Berhasil soft delete pelanggan ID: $idPelangganAktif');
        if (mounted) {
          ToastUtil.success(
            context,
            'Pelanggan "$namaPelanggan" berhasil diarsipkan.',
          );
        }
      } on Exception catch (e, s) {
        Log.error(
          'Gagal soft delete pelanggan ID: $idPelangganAktif',
          e: e,
          s: s,
        );
        if (mounted) {
          ToastUtil.error(context, 'Gagal mengarsipkan pelanggan: $e');
        }
      }
    } else {
      Log.info(
        'Soft delete pelanggan ID: $idPelangganAktif dibatalkan oleh user',
      );
    }
  }

  Future<void> _tampilkanDialogUrutan() async {
    final currentSort = ref.read(urutanPelangganAktifStateProvider);
    await showDialog<UrutanPelangganAktifEnum>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Urutkan Berdasarkan'),
        contentPadding: const EdgeInsets.only(
          top: TSizes.p12,
          bottom: TSizes.p12,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: UrutanPelangganAktifEnum.values.map((o) {
                    final diPilih = currentSort == o;
                    return ListTile(
                      dense: true,
                      visualDensity: const VisualDensity(vertical: -2),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: TSizes.p24,
                      ),
                      title: Text(
                        ambilTeksUrutanPelangganAktif(o),
                        style: TextStyle(
                          fontSize: TSizes.p16,
                          fontWeight: diPilih
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: diPilih
                              ? Theme.of(context).primaryColor
                              : null,
                        ),
                      ),
                      trailing: diPilih
                          ? Icon(
                              TIcons.check,
                              color: Theme.of(context).primaryColor,
                              size: 18,
                            )
                          : null,
                      onTap: () {
                        Navigator.pop(ctx); // tutup dialog
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          // tunda perubahan state
                          if (mounted) {
                            // pastikan widget masih hidup
                            ref
                                .read(
                                  urutanPelangganAktifStateProvider.notifier,
                                )
                                .ubahUrutan(o);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }

  Future<void> _opsiLanjutan() async {
    Log.info('Membuka opsi lanjutan');
    final selected = await showDialog<OpsiLanjutan>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Opsi Lanjutan'),
        children: [
          SimpleDialogOption(
            onPressed: () =>
                Navigator.pop(ctx, OpsiLanjutan.arsipkanKadaluarsa),
            child: const Text('Arsipkan pelanggan kadaluarsa'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, OpsiLanjutan.softDeleteAll),
            child: const Text(
              'Hapus Semua',
              style: TextStyle(color: Colors.red),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, OpsiLanjutan.batal),
            child: const Text('Batal'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    switch (selected) {
      case OpsiLanjutan.softDeleteAll:
        Log.warning('Opsi arsipkan semua dipilih');
        final konfirmasi = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Konfirmasi Arsipkan Semua'),
            content: const Text(
              'Yakin ingin mengarsipkan SEMUA pelanggan aktif?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Arsipkan Semua'),
              ),
            ],
          ),
        );
        if (konfirmasi == true) {
          try {
            Log.warning('Eksekusi arsipkan semua pelanggan aktif');
            await _pelangganAktifOpSqlite.softDeleteAll();
            await _transaksiOpsqlite.softDeleteAll();
            if (mounted) {
              ToastUtil.success(context, 'Berhasil mengarsipkan  pelanggan.');
            }
            unawaited(
              ref
                  .read(layananCekSinkronisasiProvider)
                  .jalankanCekSinkronisasi(),
            );
            await ref.read(pelangganAktifProvider.notifier).perbaruiData();
          } catch (e, s) {
            Log.error('Gagal mengarsipkan semua pelanggan aktif', e: e, s: s);
            if (mounted) {
              ToastUtil.error(
                context,
                'Gagal mengarsipkan semua pelanggan: $e',
              );
            }
          }
        }
        break;
      case OpsiLanjutan.arsipkanKadaluarsa:
        try {
          Log.info('Mulai arsipkan pelanggan kadaluarsa');
          final count = await _pelangganAktifOpSqlite
              .arsipkanLanggananKadaluarsa();
          Log.info('Selesai arsipkan kadaluarsa, jumlah=$count');
          if (mounted) {
            ToastUtil.success(
              context,
              '$count pelanggan kadaluarsa diarsipkan.',
            );
          }
          await ref.read(pelangganAktifProvider.notifier).perbaruiData();
        } catch (e, s) {
          Log.error('Gagal mengarsipkan pelanggan kadaluarsa', e: e, s: s);
          if (mounted) {
            ToastUtil.error(
              context,
              'Gagal mengarsipkan pelanggan kadaluarsa: $e',
            );
          }
        }
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pelangganAktifAsync = ref.watch(pelangganAktifProvider);
    return Scaffold(
      appBar: AppBar(
        title: _mencari
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Cari data...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
              )
            : const Text('Pelanggan Aktif'),
        actions: _mencari
            ? [
                IconButton(
                  icon: const Icon(TIcons.close),
                  onPressed: () {
                    setState(() => _mencari = false);
                    _searchController.clear();
                  },
                ),
              ]
            : [
                IconButton(
                  icon: const Icon(TIcons.search),
                  onPressed: () => setState(() => _mencari = true),
                ),
                IconButton(
                  icon: const Icon(TIcons.filter),
                  onPressed: _tampilkanDialogUrutan,
                ),
                IconButton(
                  icon: const Icon(TIcons.delete),
                  onPressed: _opsiLanjutan,
                ),
              ],
      ),
      body: RefreshIndicator(
        onRefresh: refreshData,
        child: pelangganAktifAsync.when(
          skipLoadingOnReload: true,
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) {
            Log.error('Error UI Pelanggan Aktif', e: error, s: stack);
            return Center(child: Text('Terjadi kesalahan: $error'));
          },
          data: (state) {
            final sortBy = ref.watch(urutanPelangganAktifStateProvider);
            final urutkan = urutkanPelangganAktif(
              state.daftarPelangganAktif,
              sortBy,
            );
            final query = _searchController.text.toLowerCase();
            final displayedCustomers = urutkan
                .where((c) => c.namaPelanggan.toLowerCase().contains(query))
                .toList();
            if (displayedCustomers.isEmpty) {
              return Center(
                child: Text(
                  query.isNotEmpty
                      ? 'Pelanggan tidak ditemukan.'
                      : 'Tidak ada pelanggan aktif.',
                ),
              );
            }

            return ListView.builder(
              itemCount: displayedCustomers.length,
              itemBuilder: (_, i) {
                final detail = displayedCustomers[i];
                final c = detail.pelangganAktif;
                return Card(
                  margin: const EdgeInsets.only(
                    left: TSizes.p16,
                    right: TSizes.p16,
                    bottom: TSizes.p12,
                  ),
                  child: InkWell(
                    onLongPress: () => _softDeletePelangganAktif(detail),
                    onTap: () async {
                      await Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              DetailPelangganAktif(pelangganAktif: c),
                        ),
                      );
                    },
                    child: ListTile(
                      title: Text(
                        detail.namaPelanggan,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(detail.namaPaket),
                          Text(
                            'Pembayaran: ${c.status.displayName}',
                            style: TextStyle(
                              color: c.status == StatusPembayaran.paid
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Status: ${PerhitunganUtil.cobaAmbilTeksSisaMasaAktif(c.tanggalBerakhir)}',
                            style: TextStyle(
                              color: PerhitunganUtil.ambilWarnaSisaMasaAktif(
                                c.tanggalBerakhir,
                              ),
                            ),
                          ),
                          Text(
                            'Berakhir: ${FormatTanggal.formatDasar(c.tanggalBerakhir)} ${FormatJam.formatJamMenit(c.tanggalBerakhir)}',
                          ),
                        ],
                      ),
                      trailing: const Icon(TIcons.chevronRight),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_active_customer',
        onPressed: () => Navigator.push<void>(
          context,
          MaterialPageRoute<void>(builder: (_) => const FormPelangganAktif()),
        ),
        child: const Icon(TIcons.add),
      ),
    );
  }
}
