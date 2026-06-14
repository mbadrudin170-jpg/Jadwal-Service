// path: lib/fitur/poin/page/points_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/order/model/order_model.dart';
import 'package:wifi/fitur/poin/provider/poin_provider.dart';
import 'package:wifi/fitur/poin/widget/poin_page_ui.dart';
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
import 'package:wifi/user/page/transaction_detail_u.dart';
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
            customerId: widget.customerId,
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

      final bool enoughPoints = currentPoints >= reward.redemptionPoints;
      if (!enoughPoints) {
        ToastUtil.warning(
            context, 'Poin Anda tidak mencukupi untuk menukar hadiah ini.');
        return;
      }

      final bool? dikonfirmasi = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Konfirmasi Penukaran'),
          content: Text('Anda yakin ingin menukar poin dengan ${reward.name}?'),
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
        Log.info('Pengguna mengonfirmasi penukaran untuk: ${reward.name}');
        try {
          final dataPelanggan = await ref
              .read(pelangganOpSqliteProvider)
              .getById(widget.customerId);

          final now = DateTime.now();
          final idOrder = const Uuid().v4();

          final orderData = OrderModel(
              id: idOrder,
              customerId: widget.customerId,
              packageId: reward.id,
              date: now);

          final notifikasiData = NotifikasiModel(
              id: const Uuid().v4(),
              startDate: now,
              endDate: now,
              tanggalTampil: now,
              title: 'Order Paket',
              description: 'pelanggan ${dataPelanggan?.name} melakukan order',
              type: TipeNotifikasiEnum.order,
              updatedAt: now,
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
    if (transaction.packageId != null && transaction.packageId!.isNotEmpty) {
      final dataSource = ref.read(pointsDataSourceProvider);
      try {
        package = await dataSource.getPaketByid(transaction.packageId!);
      } on Exception catch (e, st) {
        Log.error('Failed to get package ${transaction.packageId}: $e',
            e: e, s: st);
      }
    }
    if (!mounted) return;
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionDetailPage(
          transaction: transaction,
          package: package,
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
        final enoughPoints = totalPoints >= reward.redemptionPoints;
        final progress = reward.redemptionPoints > 0
            ? (totalPoints / reward.redemptionPoints).clamp(0.0, 1.0)
            : 1.0;
        final poinKurang = totalPoints - reward.redemptionPoints;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            title: Text(reward.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${reward.redemptionPoints} Poin'),
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
                    Text('Poin: $totalPoints / ${reward.redemptionPoints}',
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
            final isAddition = tx.earnedPoints > 0;
            final pointsValue = isAddition ? tx.earnedPoints : tx.usedPoints;
            final pointsStr = isAddition ? '+$pointsValue' : '-$pointsValue';

            final bool isUnpaid = tx.paymentStatus == PaymentStatus.unpaid;
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
                  title: Text(tx.description),
                  subtitle: Text(
                    FormatDate.formatDateBasic(tx.date),
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
