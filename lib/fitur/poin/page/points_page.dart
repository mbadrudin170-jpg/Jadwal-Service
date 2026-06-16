// path: lib/fitur/poin/page/points_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/order/model/order_model.dart';
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
import 'package:wifi/user/widget/ads/interstitial/interstitial_ad_service.dart';

class PoinPage extends ConsumerStatefulWidget {
  final String customerId;
  final bool showAd;

  const PoinPage({
    super.key,
    required this.customerId,
    this.showAd = false,
  });

  @override
  ConsumerState<PoinPage> createState() => _PointsPageState();
}

class _PointsPageState extends ConsumerState<PoinPage> {
  final _interstitialAdService = InterstitialAdService();
  MenuPoin _selectedMenu = MenuPoin.penukaran;
  late final Widget _appBarTitle;
  bool _isTukarPoin = false;

  @override
  void initState() {
    super.initState();
    final isFirebase = ref.read(appRoleProvider) == AppRole.user;

    Log.info(
        'Initializing PointsPage for customer: ${widget.customerId} with role: ${ref.read(appRoleProvider)}');

    _appBarTitle = Row(
      children: [
        const Text('Poin: '),
        Expanded(
          child: NamaPelangganWidget(
            idPelanggan: widget.customerId,
            useFirebase: isFirebase,
          ),
        ),
      ],
    );

    if (widget.showAd) {
      Log.info('Preloading interstitial ad for PointsPage.');
      unawaited(_interstitialAdService.preloadAd());
    }
  }

  Future<void> _tukarPoin(BuildContext context, WidgetRef ref,
      PaketModel reward, int currentPoints) async {
    if (_isTukarPoin) return;
    setState(() => _isTukarPoin = true);
    try {
      final role = ref.read(appRoleProvider);
      if (role == AppRole.admin) {
        Log.warning('Admin mencoba menukar poin, operasi diblokir.');
        ToastUtil.error(
            context, 'Admin tidak dapat menukar poin dari antarmuka ini.');
        return;
      }

      final isOnline =
          await ref.read(koneksiInternetServiceProvider).cekInternet(ref);
      if (!isOnline) {
        ToastUtil.warning(context, 'Cek koneksi internet Anda');
        return;
      }

      final bool enoughPoints = currentPoints >= reward.poinPenukaran;
      if (!enoughPoints) {
        ToastUtil.warning(
            context, 'Poin Anda tidak mencukupi untuk menukar hadiah ini.');
        return;
      }

      final bool? dikonfirmasi = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Konfirmasi Penukaran'),
          content: Text('Anda yakin ingin menukar poin dengan ${reward.nama}?'),
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
        Log.info('Pengguna mengonfirmasi penukaran untuk: ${reward.nama}');
        try {
          final dataPelanggan = await ref
              .read(pelangganOpSqliteProvider)
              .ambilBerdasarkanId(widget.customerId);

          final now = DateTime.now();
          final idOrder = const Uuid().v4();

          final orderData = OrderModel(
              id: idOrder,
              idPelanggan: widget.customerId,
              idPaket: reward.id,
              tanggal: now);

          final notifikasiData = NotifikasiModel(
              id: const Uuid().v4(),
              tanggalMulai: now,
              tanggalBerakhir: now,
              tanggalTampil: now,
              judul: 'Order Paket',
              deskripsi: 'pelanggan ${dataPelanggan?.nama} melakukan order',
              tipe: TipeNotifikasiEnum.order,
              diperbaruiPada: now,
              idTujuan: idOrder,
              userId: widget.customerId);

          ref.read(notifikasiOpFirebaseProvider).addNotifikasi(notifikasiData);
          Log.info(
              'berhasil membuat order baru untuk id pelanggan: ${widget.customerId}');

          await ref.read(orderOpFirebaseProvider).addOrder(orderData);
          Log.info('berhasil membuat notifikasi untuk paket');

          ref.invalidate(pointsPageDataProvider);
          ref.invalidate(pointsHistoryProvider);

          if (!mounted) return;
          ToastUtil.success(
              context, 'Order sudah terkirim menunggu konfirmasi Admin');
        } on Exception catch (e, st) {
          Log.error('Gagal menukar poin: $e', e: e, s: st);
          if (!mounted) return;
          ToastUtil.error(context, 'Terjadi kesalahan saat menukar poin.');
        }
      }
    } finally {
      setState(() => _isTukarPoin = false);
    }
  }

  Future<void> _navigasiKeDetailtransaksi(TransaksiModel transaction) async {
    if (!mounted) return;
    Log.info('Navigating to transaction detail for ID: ${transaction.id}');
    PaketModel? package;
    if (transaction.idPaket != null && transaction.idPaket!.isNotEmpty) {
      final dataSource = ref.read(pointsDataSourceProvider);
      try {
        package = await dataSource.getPaketByid(transaction.idPaket!);
      } on Exception catch (e, st) {
        Log.error('Failed to get package ${transaction.idPaket}: $e',
            e: e, s: st);
      }
    }
    if (!mounted) return;
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => DetailTransaksiU(
          transaksi: transaction,
          paket: package,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Log.info('Building PointsPage UI, selected menu: $_selectedMenu');
    // Tonton provider data utama.
    final asyncData = ref.watch(pointsPageDataProvider(widget.customerId));

    return asyncData.when(
      loading: () => Scaffold(
        appBar: AppBar(title: _appBarTitle),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(title: _appBarTitle),
        body: Center(
          child: Text('Error: $err'),
        ),
      ),
      data: (pageData) {
        return PoinPageUi(
          appBarTitle: _appBarTitle,
          totalPoin: pageData.totalPoints,
          menuPilihan: _selectedMenu,
          onSelectionChanged: (newSelection) async {
            final selection = newSelection.first;
            Log.info('Points menu changed to: $selection');
            setState(() => _selectedMenu = selection);

            if (selection == MenuPoin.riwayat && widget.showAd) {
              await _interstitialAdService.show();
            }
          },
          contentView: _selectedMenu == MenuPoin.penukaran
              ? _buildRewardList(pageData.rewards, pageData.totalPoints)
              : _buildPointsHistory(),
          bottomWidget: widget.showAd ? const BannerAdsWidget() : null,
        );
      },
    );
  }

  Widget _buildRewardList(List<PaketModel> rewardList, int totalPoints) {
    Log.info('Building reward list.');
    if (rewardList.isEmpty) {
      return const Center(child: Text('Belum ada hadiah yang tersedia'));
    }
    return ListView.builder(
      itemCount: rewardList.length,
      itemBuilder: (context, index) {
        final reward = rewardList[index];
        final enoughPoints = totalPoints >= reward.poinPenukaran;
        final progress = reward.poinPenukaran > 0
            ? (totalPoints / reward.poinPenukaran).clamp(0.0, 1.0)
            : 1.0;
        final poinKurang = totalPoints - reward.poinPenukaran;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            title: Text(reward.nama),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${reward.poinPenukaran} Poin'),
                    ElevatedButton(
                      onPressed: _isTukarPoin
                          ? null
                          : () => _tukarPoin(context, ref, reward, totalPoints),
                      child: _isTukarPoin
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
                    Text('Poin: $totalPoints / ${reward.poinPenukaran}',
                        style: TextStyle(
                            fontSize: 12,
                            color: enoughPoints ? Colors.green : Colors.grey)),
                    Text(
                      '$poinKurang',
                      style: TextStyle(
                        color: enoughPoints ? Colors.green : Colors.red,
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

  Widget _buildPointsHistory() {
    Log.info('Building points history.');
    final asyncHistory = ref.watch(pointsHistoryProvider(widget.customerId));

    return asyncHistory.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (history) {
        if (history.isEmpty) {
          return const Center(child: Text('Belum ada riwayat poin'));
        }
        return ListView.builder(
          itemCount: history.length,
          itemBuilder: (context, index) {
            final tx = history[index];
            final isAddition = tx.poinDidapat > 0;
            final pointsValue = isAddition ? tx.poinDidapat : tx.poinDigunakan;
            final pointsStr = isAddition ? '+$pointsValue' : '-$pointsValue';

            final bool isUnpaid =
                tx.statusPembayaran == StatusPembayaran.unpaid;
            final Color pointColor = isUnpaid
                ? Colors.grey
                : isAddition
                    ? Colors.green
                    : Colors.red;
            return InkWell(
              onTap: () => _navigasiKeDetailtransaksi(tx),
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: Icon(
                    isUnpaid
                        ? TIcons.hourglass
                        : isAddition
                            ? TIcons.arrowUp
                            : TIcons.arrowDown,
                    color: pointColor,
                  ),
                  title: Text(tx.deskripsi),
                  subtitle: Text(
                    FormatTanggal.formatDasar(tx.tanggal),
                  ),
                  trailing: Text(
                    pointsStr,
                    style: TextStyle(
                      color: pointColor,
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
