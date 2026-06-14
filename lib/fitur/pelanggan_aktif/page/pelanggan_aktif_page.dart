// path: lib/fitur/pelanggan_aktif/page/pelanggan_aktif_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/admin/halaman/detail/detail_pelanggan_aktif.dart';
import 'package:wifi/admin/halaman/form/form_pelanggan_aktif.dart';
import 'package:wifi/admin/providers/pelanggan_aktif_provider.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/payment_status_enum.dart';
import 'package:wifi/shared/export/operation.dart';
import 'package:wifi/shared/model/active_customer_detail_model.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/theme/app_sizes.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/perhitungan_util.dart';
import 'package:wifi/shared/utils/toast_util.dart';

enum AdvancedOption {
  softDeleteAll,
  archiveExpired,
  cancel,
}

String _getSortLabel(SortOption option) {
  switch (option) {
    case SortOption.berakhirHariIni:
      return 'Berakhir Hari Ini';
    case SortOption.tanggalBerakhir:
      return 'Tanggal Berakhir';
    case SortOption.tanggalMulai:
      return 'Tanggal Mulai';
    case SortOption.lunas:
      return 'Lunas';
    case SortOption.belumLunas:
      return 'Belum Lunas';
    case SortOption.namaAZ:
      return 'Nama A-Z';
    case SortOption.namaZA:
      return 'Nama Z-A';
    case SortOption.terbaru:
      return 'Terbaru';
    case SortOption.terlama:
      return 'Terlama';
  }
}

class PelangganAktifPage extends ConsumerStatefulWidget {
  const PelangganAktifPage({super.key});

  @override
  ActiveCustomerPageState createState() => ActiveCustomerPageState();
}

class ActiveCustomerPageState extends ConsumerState<PelangganAktifPage>
    with AutomaticKeepAliveClientMixin<PelangganAktifPage> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  Future<void> initState() async {
    super.initState();
    Log.info('ActiveCustomerPage initState');
    _searchController.addListener(_onSearchChanged);

    Future.microtask(() async {
      try {
        await _pelangganAktifOpSqlite.arsipkanLanggananKadaluarsa();
      } catch (e) {
        Log.error('Gagal menjalankan arsip otomatis saat aplikasi dibuka',
            e: e);
      }
      await ref.read(pelangganAktifProvider.notifier).fetchActiveCustomers();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  PelangganAktifOpSqlite get _pelangganAktifOpSqlite =>
      ref.read(pelangganAktifOpSqliteProvider);
  TransaksiOpsqlite get _transaksiOpsqlite =>
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
    await ref.read(pelangganAktifProvider.notifier).fetchActiveCustomers();
  }

  Future<void> _softDeleteCustomer(
      final DetailPelangganAktifModel customer) async {
    final customerId = customer.pelangganAktif.id;
    final customerName = customer.customerName;
    final transactionId = customer.pelangganAktif.transactionId;
    final bool? konfirmasi = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Arsipkan'),
        content: Text('Yakin ingin mengarsipkan pelanggan "$customerName"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'hapus',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (konfirmasi ?? false) {
      try {
        await _pelangganAktifOpSqlite.softDelete(customerId);
        if (transactionId != null) {
          await _transaksiOpsqlite.softDelete(transactionId);
        }
        Log.info('Berhasil soft delete pelanggan ID: $customerId');
        if (mounted) {
          ToastUtil.success(
              context, 'Pelanggan "$customerName" berhasil diarsipkan.');
        }
        await ref.read(pelangganAktifProvider.notifier).fetchActiveCustomers();
      } on Exception catch (e, s) {
        Log.error('Gagal soft delete pelanggan ID: $customerId', e: e, s: s);
        if (mounted) {
          ToastUtil.error(context, 'Gagal mengarsipkan pelanggan: $e');
        }
      }
    } else {
      Log.info('Soft delete pelanggan ID: $customerId dibatalkan oleh user');
    }
  }

  Future<void> _showSortDialog() async {
    final currentState = ref.read(pelangganAktifProvider).value;
    if (currentState == null) {
      ToastUtil.info(context, 'Data sedang dimuat, coba sesaat lagi.');
      return;
    }

    await showDialog<SortOption>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Urutkan Berdasarkan'),
        contentPadding:
            const EdgeInsets.only(top: TSizes.p12, bottom: TSizes.p12),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: SortOption.values.map((o) {
                    final diPilih = currentState.sortBy == o;
                    return ListTile(
                      dense: true,
                      visualDensity: const VisualDensity(vertical: -2),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: TSizes.p24,
                      ),
                      title: Text(
                        _getSortLabel(o),
                        style: TextStyle(
                          fontSize: TSizes.p16,
                          fontWeight:
                              diPilih ? FontWeight.bold : FontWeight.normal,
                          color:
                              diPilih ? Theme.of(context).primaryColor : null,
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
                        ref.read(pelangganAktifProvider.notifier).setSortBy(o);
                        Navigator.pop(ctx);
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

  Future<void> _addActiveCustomer() async {
    Log.info('Navigasi ke form tambah pelanggan aktif');
    await Navigator.push<bool>(
        context, MaterialPageRoute(builder: (_) => const FormPelangganAktif()));
  }

  Future<void> _advancedOptions() async {
    Log.info('Membuka opsi lanjutan');
    final AdvancedOption? selected = await showDialog<AdvancedOption>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Opsi Lanjutan'),
        children: [
          SimpleDialogOption(
              onPressed: () =>
                  Navigator.pop(ctx, AdvancedOption.archiveExpired),
              child: const Text('Arsipkan pelanggan kadaluarsa')),
          SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, AdvancedOption.softDeleteAll),
              child: const Text('Hapus Semua',
                  style: TextStyle(color: Colors.red))),
          SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, AdvancedOption.cancel),
              child: const Text('Batal')),
        ],
      ),
    );

    if (!mounted) return;
    switch (selected) {
      case AdvancedOption.softDeleteAll:
        Log.warning('Opsi arsipkan semua dipilih');
        final bool? confirm = await showDialog<bool>(
          context: context,
          builder: (final ctx) => AlertDialog(
            title: const Text('Konfirmasi Arsipkan Semua'),
            content:
                const Text('Yakin ingin mengarsipkan SEMUA pelanggan aktif?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Batal')),
              TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Arsipkan Semua')),
            ],
          ),
        );
        if (confirm ?? false) {
          try {
            Log.warning('Eksekusi arsipkan semua pelanggan aktif');
            await _pelangganAktifOpSqlite.softDeleteAll();
            await _transaksiOpsqlite.softDeleteAll();
            if (mounted) {
              ToastUtil.success(context, 'Berhasil mengarsipkan  pelanggan.');
            }
            await ref
                .read(pelangganAktifProvider.notifier)
                .fetchActiveCustomers();
          } on Exception catch (e, s) {
            Log.error('Gagal mengarsipkan semua pelanggan aktif', e: e, s: s);
            if (mounted) {
              ToastUtil.error(
                  context, 'Gagal mengarsipkan semua pelanggan: $e');
            }
          }
        }
        break;
      case AdvancedOption.archiveExpired:
        try {
          Log.info('Mulai arsipkan pelanggan kadaluarsa');
          final count =
              await _pelangganAktifOpSqlite.arsipkanLanggananKadaluarsa();
          Log.info('Selesai arsipkan kadaluarsa, jumlah=$count');
          if (mounted) {
            ToastUtil.success(
                context, '$count pelanggan kadaluarsa diarsipkan.');
          }
          await ref
              .read(pelangganAktifProvider.notifier)
              .fetchActiveCustomers();
        } on Exception catch (e, s) {
          Log.error('Gagal mengarsipkan pelanggan kadaluarsa', e: e, s: s);
          if (mounted) {
            ToastUtil.error(
                context, 'Gagal mengarsipkan pelanggan kadaluarsa: $e');
          }
        }
        break;
      default:
        break;
    }
  }

  @override
  Widget build(final BuildContext context) {
    super.build(context);
    final activeCustomerAsync = ref.watch(pelangganAktifProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                    hintText: 'Cari nama...', border: InputBorder.none))
            : const Text('Pelanggan Aktif'),
        actions: _isSearching
            ? [
                IconButton(
                    icon: const Icon(TIcons.close),
                    onPressed: () {
                      setState(() => _isSearching = false);
                      _searchController.clear();
                    })
              ]
            : [
                IconButton(
                    icon: const Icon(TIcons.search),
                    onPressed: () => setState(() => _isSearching = true)),
                IconButton(
                    icon: const Icon(TIcons.filter),
                    onPressed: _showSortDialog),
                IconButton(
                    icon: const Icon(TIcons.delete),
                    onPressed: _advancedOptions),
              ],
      ),
      body: RefreshIndicator(
        onRefresh: refreshData,
        child: activeCustomerAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) {
            Log.error('Error UI Pelanggan Aktif', e: error, s: stack);
            return Center(child: Text('Terjadi kesalahan: $error'));
          },
          data: (state) {
            final customersFromProvider = state.daftarPelangganAktif;
            final query = _searchController.text.toLowerCase();
            final displayedCustomers = customersFromProvider
                .where((c) => c.customerName.toLowerCase().contains(query))
                .toList();

            if (displayedCustomers.isEmpty) {
              return Center(
                  child: Text(query.isNotEmpty
                      ? 'Pelanggan tidak ditemukan.'
                      : 'Tidak ada pelanggan aktif.'));
            }

            return ListView.builder(
              itemCount: displayedCustomers.length,
              itemBuilder: (_, i) {
                final detail = displayedCustomers[i];
                final c = detail.pelangganAktif;
                return Card(
                  margin: const EdgeInsets.only(
                      left: TSizes.p16, right: TSizes.p16, bottom: TSizes.p12),
                  child: InkWell(
                    onLongPress: () => _softDeleteCustomer(detail),
                    onTap: () async {
                      await Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                              builder: (_) =>
                                  DetailPelangganAktif(pelangganAktif: c)));
                    },
                    child: ListTile(
                      title: Text(
                        detail.customerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(detail.packageName),
                          Text('Pembayaran: ${c.status.displayName}',
                              style: TextStyle(
                                  color: c.status == PaymentStatus.paid
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold)),
                          Text(
                              'Status: ${PerhitunganUtil.ambilTeksSisaMasaAktif(c.endDate)}',
                              style: TextStyle(
                                  color:
                                      PerhitunganUtil.ambilWarnaSisaMasaAktif(
                                          c.endDate))),
                          Text(
                              'Berakhir: ${FormatTanggal.formatDasar(c.endDate)} ${FormatJam.formatJamMenit(c.endDate)}'),
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
          onPressed: _addActiveCustomer,
          child: const Icon(TIcons.add)),
    );
  }
}
