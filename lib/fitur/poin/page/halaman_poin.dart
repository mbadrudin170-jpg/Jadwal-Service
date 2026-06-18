// path lib/fitur/poin/page/halaman_poin.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/order/model/order_model.dart';
import 'package:wifi/fitur/order/provider/order_provider.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/poin/provider/poin_provider.dart';
import 'package:wifi/fitur/poin/widget/poin_page_ui.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/transaksi/page/detail_transaksi_u.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/shared/providers/shared_providers.dart';
import 'package:wifi/shared/services/koneksi_internet_service.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/nama_pelanggan_widget.dart';
import 'package:wifi/user/widget/ads/banner/banner_ads_widget.dart';
import 'package:wifi/user/widget/ads/interstitial/layanan_iklan_interstisial.dart';

class HalamanPoin extends ConsumerStatefulWidget {
  final String idPelanggan;
  final bool tampilkanIklan;

  const HalamanPoin({
    super.key,
    required this.idPelanggan,
    this.tampilkanIklan = false,
  });

  @override
  ConsumerState<HalamanPoin> createState() => _HalamanPoinState();
}

class _HalamanPoinState extends ConsumerState<HalamanPoin> {
  final _layananIklanInterstisial = LayananIklanInterstisial();
  MenuPoin _menuTerpilih = MenuPoin.penukaran;
  late final Widget _judulAppBar;
  bool _sedangTukarPoin = false;

  @override
  void initState() {
    super.initState();
    final pakaiFirebase = ref.read(appRoleProvider) == AppRole.user;

    Log.info(
      'Initializing PointsPage for customer: ${widget.idPelanggan} with role: ${ref.read(appRoleProvider)}',
    );

    _judulAppBar = Row(
      children: [
        const Text('Poin: '),
        Expanded(
          child: NamaPelangganWidget(
            idPelanggan: widget.idPelanggan,
            pakaiFirebase: pakaiFirebase,
          ),
        ),
      ],
    );

    if (widget.tampilkanIklan) {
      Log.info('Preloading interstitial ad for PointsPage.');
      unawaited(_layananIklanInterstisial.preloadAd());
    }
  }

  Future<void> _tukarPoin(
    BuildContext context,
    WidgetRef ref,
    PaketModel hadiah,
    int poinSaatIni,
  ) async {
    if (_sedangTukarPoin) return;
    setState(() => _sedangTukarPoin = true);
    try {
      final role = ref.read(appRoleProvider);
      if (role == AppRole.admin) {
        Log.warning('Admin mencoba menukar poin, operasi diblokir.');
        ToastUtil.error(
          context,
          'Admin tidak dapat menukar poin dari antarmuka ini.',
        );
        return;
      }

      final isOnline = await ref
          .read(koneksiInternetServiceProvider)
          .cekInternet(ref);
      if (!isOnline) {
        ToastUtil.warning(context, 'Cek koneksi internet Anda');
        return;
      }

      final bool poinCukup = poinSaatIni >= hadiah.poinPenukaran;
      if (!poinCukup) {
        ToastUtil.warning(
          context,
          'Poin Anda tidak mencukupi untuk menukar hadiah ini.',
        );
        return;
      }

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

      if (dikonfirmasi ?? false) {
        Log.info('Pengguna mengonfirmasi penukaran untuk: ${hadiah.nama}');
        try {
          final dataPelanggan = await ref
              .read(pelangganOpSqliteProvider)
              .ambilBerdasarkanId(widget.idPelanggan);

          final sekarang = DateTime.now();
          final idOrder = const Uuid().v4();

          final dataPesanan = OrderModel(
            id: idOrder,
            idPelanggan: widget.idPelanggan,
            idPaket: hadiah.id,
            tanggal: sekarang,
          );

          final notifikasiData = NotifikasiModel(
            id: const Uuid().v4(),
            tanggalMulai: sekarang,
            tanggalBerakhir: sekarang,
            tanggalTampil: sekarang,
            judul: 'Order Paket',
            deskripsi: 'pelanggan ${dataPelanggan?.nama} melakukan order',
            tipe: TipeNotifikasiEnum.order,
            diperbaruiPada: sekarang,
            idTujuan: idOrder,
            userId: widget.idPelanggan,
          );

          ref.read(notifikasiOpFirebaseProvider).addNotifikasi(notifikasiData);
          Log.info(
            'berhasil membuat order baru untuk id pelanggan: ${widget.idPelanggan}',
          );

          await ref.read(orderOpFirebaseProvider).addOrder(dataPesanan);
          Log.info('berhasil membuat notifikasi untuk paket');

          ref.invalidate(pointsPageDataProvider);
          ref.invalidate(pointsHistoryProvider);
          ref.invalidate(orderProvider);
          if (!mounted) return;
          ToastUtil.success(
            context,
            'Order sudah terkirim menunggu konfirmasi Admin',
          );
        } on Exception catch (e, st) {
          Log.error('Gagal menukar poin: $e', e: e, s: st);
          if (!mounted) return;
          ToastUtil.error(context, 'Terjadi kesalahan saat menukar poin.');
        }
      }
    } finally {
      setState(() => _sedangTukarPoin = false);
    }
  }

  Future<void> _navigasiKeDetailTransaksi(TransaksiModel transaksi) async {
    if (!mounted) return;
    Log.info('Navigating to transaction detail for ID: ${transaksi.id}');
    PaketModel? paket;
    if (transaksi.idPaket != null && transaksi.idPaket!.isNotEmpty) {
      final dataSource = ref.read(pointsDataSourceProvider);
      try {
        paket = await dataSource.getPaketByid(transaksi.idPaket!);
      } on Exception catch (e, st) {
        Log.error(
          'Failed to get package ${transaksi.idPaket}: $e',
          e: e,
          s: st,
        );
      }
    }
    if (!mounted) return;
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DetailTransaksiU(transaksi: transaksi, paket: paket),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Log.info('Building PointsPage UI, selected menu: $_menuTerpilih');
    // Tonton provider data utama.
    final dataAsync = ref.watch(pointsPageDataProvider(widget.idPelanggan));

    return dataAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: _judulAppBar),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(title: _judulAppBar),
        body: Center(child: Text('Error: $err')),
      ),
      data: (dataHalaman) {
        return PoinPageUi(
          appBarTitle: _judulAppBar,
          totalPoin: dataHalaman.totalPoin,
          menuPilihan: _menuTerpilih,
          onSelectionChanged: (newSelection) async {
            final selection = newSelection.first;
            Log.info('Points menu changed to: $selection');
            setState(() => _menuTerpilih = selection);

            if (selection == MenuPoin.riwayat && widget.tampilkanIklan) {
              await _layananIklanInterstisial.show();
            }
          },
          contentView: _menuTerpilih == MenuPoin.penukaran
              ? _bangunDaftarHadiah(dataHalaman.hadiah, dataHalaman.totalPoin)
              : _bangunRiwayatPoin(),
          bottomWidget: widget.tampilkanIklan ? const BannerAdsWidget() : null,
        );
      },
    );
  }

  Widget _bangunDaftarHadiah(List<PaketModel> daftarHadiah, int totalPoin) {
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
                      onPressed: _sedangTukarPoin
                          ? null
                          : () => _tukarPoin(context, ref, hadiah, totalPoin),
                      child: _sedangTukarPoin
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

  Widget _bangunRiwayatPoin() {
    Log.info('Building points history.');
    final riwayatAsync = ref.watch(pointsHistoryProvider(widget.idPelanggan));

    return riwayatAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (history) {
        if (history.isEmpty) {
          return const Center(child: Text('Belum ada riwayat poin'));
        }
        return ListView.builder(
          itemCount: history.length,
          itemBuilder: (context, index) {
            final transaksi = history[index];
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
