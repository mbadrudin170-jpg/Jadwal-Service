// path lib/fitur/poin/page/halaman_poin.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/app_role/role_util.dart';
import 'package:wifi/fitur/order/provider/order_provider.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/paket/operasi/paket_op_global.dart';
import 'package:wifi/fitur/paket/provider/paket_provider.dart';
import 'package:wifi/fitur/pelanggan_aktif/provider/pelanggan_aktif_provider.dart';
import 'package:wifi/fitur/poin/poin.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_global.dart';
import 'package:wifi/fitur/transaksi/page/detail_transaksi_a.dart';
import 'package:wifi/fitur/transaksi/page/detail_transaksi_u.dart';
import 'package:wifi/fitur/transaksi/provider/transaksi_provider.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/services/koneksi_internet_service.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/nama_pelanggan_widget.dart';
import 'package:wifi/user/providers/user_provider.dart';
import 'package:wifi/user/widget/ads/banner/banner_ads_widget.dart';
import 'package:wifi/user/widget/ads/interstitial/layanan_iklan_interstisial.dart';

class HalamanPoin extends ConsumerStatefulWidget {
  final String idPelanggan;

  const HalamanPoin({super.key, required this.idPelanggan});

  @override
  ConsumerState<HalamanPoin> createState() => _HalamanPoinState();
}

class _HalamanPoinState extends ConsumerState<HalamanPoin> {
  late final LayananIklanInterstisial _layananIklanInterstisial;
  OpsiMenuPoin _menuAktif = OpsiMenuPoin.penukaran;
  late final Widget _judulAppBar;
  bool _sedangTukarPoin = false;
  String? _idRewardYangDiproses;
  @override
  void initState() {
    super.initState();
    _layananIklanInterstisial = LayananIklanInterstisial();
    _judulAppBar = Row(
      children: [
        Expanded(child: NamaPelangganWidget(idPelanggan: widget.idPelanggan)),
      ],
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userId = await ref.read(userIdProvider.future);
      if (userId != null && userId.isNotEmpty) {
        Log.info('Preloading interstitial ad for PointsPage.');
        unawaited(
          _layananIklanInterstisial.preloadAd().catchError((Object e) {
            Log.warning('Failed to preload interstitial ad: $e');
          }),
        );
      }
    });
  }

  Future<void> _tukarPoin(PaketModel hadiah, int poinSaatIni) async {
    if (_sedangTukarPoin) return;

    setState(() {
      _sedangTukarPoin = true;
      _idRewardYangDiproses = hadiah.id;
    });

    try {
      if (ref.isAdmin) {
        Log.warning('Admin mencoba menukar poin, operasi diblokir.');
        ToastUtil.error(
          context,
          'Admin tidak dapat menukar poin dari antarmuka ini.',
        );
        return;
      }

      final isOnline = await ref
          .read(koneksiInternetServiceProvider)
          .cekInternet();
      if (!mounted) return;
      if (!isOnline) {
        ToastUtil.warning(context, 'Cek koneksi internet Anda');
        return;
      }

      // 3. Validasi Poin
      final bool poinCukup = poinSaatIni >= hadiah.poinPenukaran;
      if (!poinCukup) {
        ToastUtil.warning(
          context,
          'Poin Anda tidak mencukupi untuk menukar hadiah ini.',
        );
        return;
      }

      // 4. Konfirmasi User
      final bool? dikonfirmasi = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Konfirmasi Penukaran'),
          content: Text('Anda yakin ingin menukar poin dengan ${hadiah.nama}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Ya, Tukar'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      if (!(dikonfirmasi == true)) {
        Log.info('Penukaran dibatalkan oleh user');
        return;
      }
      Log.info('Pengguna mengonfirmasi penukaran untuk: ${hadiah.nama}');
      if (mounted) {
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );
      }
      try {
        final transactionService = ref.read(poinTransactionServiceProvider);
        await transactionService.tukarPoin(
          idPelanggan: widget.idPelanggan,
          paket: hadiah,
          poinSaatIni: poinSaatIni,
        );
        if (mounted) {
          _invalidateProviderTerkait(null);
          ToastUtil.success(
            context,
            'Order sudah terkirim menunggu konfirmasi Admin',
          );
        }
      } catch (e, st) {
        Log.error(
          'Gagal menukar poin',
          e: e,
          s: st,
          data: {'customerId': widget.idPelanggan, 'packageId': hadiah.id},
        );
        if (mounted) {
          ToastUtil.error(
            context,
            'Terjadi kesalahan saat menukar poin: ${e.toString()}',
          );
        }
      } finally {
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _sedangTukarPoin = false;
          _idRewardYangDiproses = null;
        });
      }
    }
  }

  Future<void> _navigasiKeDetailTransaksi(TransaksiModel transaksi) async {
    if (!mounted) return;
    Log.info('Navigating to transaction detail for ID: ${transaksi.id}');
    PaketModel? paket;
    if (transaksi.idPaket != null && transaksi.idPaket!.isNotEmpty) {
      try {
        final paketOp = ref.read(paketOpGlobalProvider);
        paket = await paketOp.ambilBerdasarkanId(transaksi.idPaket!);
      } on Exception catch (e, st) {
        Log.error(
          'Failed to get package ${transaksi.idPaket}: $e',
          e: e,
          s: st,
        );
      }
    }

    if (!mounted) return;
    if (ref.isUser) {
      await Navigator.push<void>(
        context,
        MaterialPageRoute(
          builder: (context) =>
              DetailTransaksiU(transaksi: transaksi, paket: paket),
        ),
      );
    } else {
      await Navigator.push<void>(
        context,
        MaterialPageRoute(
          builder: (context) => DetailTransaksiA(transaksi: transaksi),
        ),
      );
    }
  }

  void _invalidateProviderTerkait(String? idDompet) {
    ref.read(transaksiOpGlobalProvider).invalidate(idDompet);
    ref.read(orderProvider.notifier).invalidateOrderProvider();
    if (ref.isAdmin) {
      ref.read(pelangganAktifProvider.notifier).invalidatePelangganAktif();
    }
  }

  @override
  Widget build(BuildContext context) {
    Log.info('Building PointsPage UI, selected menu: $_menuAktif');
    final dataAsync = ref.watch(
      riwayatTransaksiPelangganProvider(widget.idPelanggan),
    );
    final daftarHadiah = ref.watch(paketProvider);
    return dataAsync.when(
      skipLoadingOnReload: true,
      loading: () => Scaffold(
        appBar: AppBar(title: _judulAppBar),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) => Scaffold(
        appBar: AppBar(title: _judulAppBar),
        body: Center(child: Text('Error: $e')),
      ),
      data: (dataHalaman) {
        return UiHalamanPoin(
          appBarTitle: _judulAppBar,
          totalPoin: dataHalaman.totalPoin,
          menuPilihan: _menuAktif,
          onSelectionChanged: (newSelection) async {
            final selection = newSelection.first;
            Log.info('Points menu changed to: $selection');
            setState(() => _menuAktif = selection);

            if (selection == OpsiMenuPoin.riwayat && ref.isUser) {
              await _layananIklanInterstisial.show();
            }
          },
          contentView: _menuAktif == OpsiMenuPoin.penukaran
              ? daftarHadiah.when(
                  skipLoadingOnReload: true,
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                  data: (state) => _buildDaftarHadiah(
                    state.daftarPaketPublik,
                    dataHalaman.totalPoin,
                  ),
                )
              : _buildRiwayatPoin(),
          bottomWidget: ref.isUser ? const BannerAdsWidget() : null,
        );
      },
    );
  }

  Widget _buildDaftarHadiah(List<PaketModel> daftarHadiah, int totalPoin) {
    Log.info('Building reward list.');
    if (daftarHadiah.isEmpty) {
      return const Center(child: Text('Belum ada hadiah yang tersedia'));
    }
    return ListView.builder(
      itemCount: daftarHadiah.length,
      itemBuilder: (context, index) {
        final hadiah = daftarHadiah[index];
        final poinCukup = totalPoin >= hadiah.poinPenukaran;
        final progress = hadiah.poinPenukaran > 0
            ? (totalPoin / hadiah.poinPenukaran).clamp(0.0, 1.0)
            : 1.0;
        final selisihPoin = totalPoin - hadiah.poinPenukaran;
        final bool sedangMemprosesRewardIni =
            _sedangTukarPoin && _idRewardYangDiproses == hadiah.id;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            title: Text(hadiah.nama),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${hadiah.poinPenukaran} Poin'),
                    ElevatedButton(
                      onPressed: sedangMemprosesRewardIni
                          ? null
                          : () => _tukarPoin(hadiah, totalPoin),
                      child: sedangMemprosesRewardIni
                          ? const CircularProgressIndicator()
                          : const Text('Tukar'),
                    ),
                  ],
                ),
                gapH4,
                LinearProgressIndicator(value: progress, minHeight: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Poin: $totalPoin / ${hadiah.poinPenukaran}',
                      style: TextStyle(
                        fontSize: 12,
                        color: poinCukup ? Colors.green : Colors.grey,
                      ),
                    ),
                    Text(
                      '$selisihPoin',
                      style: TextStyle(
                        color: poinCukup ? Colors.green : Colors.red,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRiwayatPoin() {
    Log.info('Building points history.');
    final riwayatAsync = ref.watch(
      riwayatTransaksiPelangganProvider(widget.idPelanggan),
    );
    return riwayatAsync.when(
      skipLoadingOnReload: true,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (data) {
        final semuaTransaksi = data.transaksi;
        final riwayatPoin = semuaTransaksi
            .where((t) => t.poinDidapat > 0 || t.poinDigunakan > 0)
            .toList();
        if (riwayatPoin.isEmpty) {
          return const Center(child: Text('Belum ada riwayat poin'));
        }
        return ListView.builder(
          itemCount: riwayatPoin.length,
          itemBuilder: (context, index) {
            final transaksi = riwayatPoin[index];
            final apakahPenambahan = transaksi.poinDidapat > 0;
            final nilaiPoin = apakahPenambahan
                ? transaksi.poinDidapat
                : transaksi.poinDigunakan;
            final teksPoin = apakahPenambahan ? '+$nilaiPoin' : '-$nilaiPoin';
            final bool apakahBelumBayar =
                transaksi.statusPembayaran == StatusPembayaran.unpaid;
            final Color warnaPoin = apakahBelumBayar
                ? Colors.grey
                : apakahPenambahan
                ? Colors.green
                : Colors.red;
            return InkWell(
              onTap: () => _navigasiKeDetailTransaksi(transaksi),
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: Icon(
                    apakahBelumBayar
                        ? TIcons.hourglass
                        : apakahPenambahan
                        ? TIcons.arrowUp
                        : TIcons.arrowDown,
                    color: warnaPoin,
                  ),
                  title: Text(transaksi.deskripsi),
                  subtitle: Text(FormatTanggal.formatDasar(transaksi.tanggal)),
                  trailing: Text(
                    teksPoin,
                    style: TextStyle(
                      color: warnaPoin,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
