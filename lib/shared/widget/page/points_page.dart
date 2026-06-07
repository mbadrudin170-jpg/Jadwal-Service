// path: lib/shared/widget/page/points_page.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/shared/operasi/poin/points_page_data_source.dart';
import 'package:wifi/shared/operasi/poin/sqlite_points_data_source.dart';
import 'package:wifi/shared/providers/shared_providers.dart';
import 'package:wifi/shared/utils/calculation_util.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/customer_name.dart';
import 'package:wifi/shared/widget/page/poin_page_ui.dart';
import 'package:wifi/user/page/transaction_detail_u.dart';
import 'package:wifi/user/widget/ads/banner/banner_ads_widget.dart';
import 'package:wifi/user/widget/ads/interstitial/interstitial_ad_service.dart';

class PointsPage extends ConsumerStatefulWidget {
  final String customerId;
  final bool showAd;

  const PointsPage({
    super.key,
    required this.customerId,
    this.showAd = false,
  });

  @override
  ConsumerState<PointsPage> createState() => _PointsPageState();
}

class _PointsPageState extends ConsumerState<PointsPage> {
  late final PointsPageDataSource _dataSource;
  final _interstitialAdService = InterstitialAdService();
  MenuPoin _selectedMenu = MenuPoin.penukaran;
  int _totalPoints = 0;
  List<PackageModel> _rewardList = [];
  List<TransactionModel> _transactionHistory = [];
  bool _isLoading = false;
  bool _isLoadingHistory = false;
  String? _errorMessage;
  late final Widget _appBarTitle;

  @override
  void initState() {
    super.initState();
    final role = ref.read(appRoleProvider);

    if (role == AppRole.admin) {
      _dataSource = ref.read(sqlitePointsDataSourceProvider);
    } else {
      _dataSource = ref.read(firebasePointsDataSourceProvider);
    }

    Log.info(
        'Initializing PointsPage for customer: ${widget.customerId} with role: $role');
    _appBarTitle = Row(
      children: [
        const Text('Poin: '),
        Expanded(
          child: CustomerNameWidget(
            customerId: widget.customerId,
            useFirebase: _dataSource.isFirebase,
          ),
        ),
      ],
    );

    if (widget.showAd) {
      Log.info('Preloading interstitial ad for PointsPage.');
      unawaited(_interstitialAdService.preloadAd());
    }
    unawaited(_loadPointsData());
  }

  Future<void> _loadPointsData() async {
    if (!mounted) return;
    Log.info('Loading points data...');
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final totalPoints = await _dataSource.getTotalPoints(widget.customerId);
      final rewardList = await _dataSource.getPublicPackages();
      if (!mounted) return;
      setState(() {
        _totalPoints = totalPoints;
        _rewardList = rewardList;
        _isLoading = false;
      });
      Log.info('Successfully loaded points data and rewards.');
      if (_selectedMenu == MenuPoin.riwayat) {
        await _loadTransactionHistory();
      }
    } on Exception catch (e, st) {
      Log.error('Failed to load points data: $e', e: e, st: st);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load data: $e';
      });
    }
  }

  Future<void> _loadTransactionHistory() async {
    if (!mounted) return;
    Log.info('Loading points transaction history...');
    setState(() => _isLoadingHistory = true);
    try {
      final history =
          await _dataSource.getPointsTransactions(widget.customerId);
      if (!mounted) return;
      setState(() {
        _transactionHistory = history;
        _isLoadingHistory = false;
      });
      Log.info('Successfully loaded points transaction history.');
    } on Exception catch (e, st) {
      Log.error('Failed to load history: $e', e: e, st: st);
      if (!mounted) return;
      setState(() {
        _isLoadingHistory = false;
        _transactionHistory = [];
      });
    }
  }

  Future<void> _redeemReward(final PackageModel reward) async {
    final role = ref.read(appRoleProvider);
    if (role == AppRole.admin) {
      Log.warning('Admin mencoba menukar poin, operasi diblokir.');
      if (!mounted) return;
      ToastUtil.error(
          context, 'Admin tidak dapat menukar poin dari antarmuka ini.');
      return;
    }
    if (!mounted) return;
    final bool enoughPoints = _totalPoints >= reward.redemptionPoints;
    if (!enoughPoints) {
      ToastUtil.warning(
          context, 'Poin Anda tidak mencukupi untuk menukar hadiah ini.');
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (final dialogContext) => AlertDialog(
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

    if (confirmed ?? false) {
      Log.info('Pengguna mengonfirmasi penukaran untuk: ${reward.name}');
      try {
        final now = DateTime.now();
        final endDate = CalculationUtil.hitungTanggalBerakhir(now, reward);

        final transactionId = const Uuid().v4();
        final activeCustomerId = const Uuid().v4();

        final activeCustomer = ActiveCustomerModel(
          id: activeCustomerId,
          customerId: widget.customerId,
          packageId: reward.id,
          startDate: now,
          endDate: endDate,
          status: PaymentStatus.paid,
          transactionId: transactionId,
        );

        final transaction = TransactionModel(
          id: transactionId,
          description: 'Tukar Poin: ${reward.name}',
          type: TransactionType.income,
          date: DateTime.now(),
          packageId: reward.id,
          walletId: '',
          categoryId: '',
          amount: reward.price.toDouble(),
          customerId: widget.customerId,
          durationType: reward.type,
          packageDuration: reward.duration,
          startDate: DateTime.now(),
          paymentStatus: PaymentStatus.paid,
          subCategoryId: '',
          usedPoints: reward.redemptionPoints,
          endDate: endDate,
        );
        final transactionOp = ref.read(transactionOpFirebaseProvider);
        final activeCustomerOp = ref.read(activeCustomerOpFirebaseProvider);
        await activeCustomerOp.setActiveCustomer(activeCustomer);
        Log.info('menyimpan transaksi baru untuk tukar poin', transaction);
        await transactionOp.addTransaction(transaction);
        Log.info(
            'menyimpan active customer  baru untuk tukar poin', activeCustomer);
        final _ = ref.refresh(transactionOpFirebaseProvider);
        if (!mounted) return;
        ToastUtil.success(context, '${reward.name} berhasil ditukar!');
        // await _loadPointsData(); // Muat ulang data poin
      } on Exception catch (e, st) {
        Log.error('Gagal menukar poin: $e', e: e, st: st);
        if (!mounted) return;
        ToastUtil.error(context, 'Terjadi kesalahan saat menukar poin.');
      }
    }
  }

  Future<void> _navigateToDetailTransaksi(
      final TransactionModel transaction) async {
    if (!mounted) return;
    Log.info('Navigating to transaction detail for ID: ${transaction.id}');
    PackageModel? package;
    if (transaction.packageId != null && transaction.packageId!.isNotEmpty) {
      try {
        package = await _dataSource.getPackageById(transaction.packageId!);
      } on Exception catch (e, st) {
        Log.error('Failed to get package ${transaction.packageId}: $e',
            e: e, st: st);
      }
    }
    if (!mounted) return;
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (final context) => TransactionDetailPage(
          transaction: transaction,
          package: package,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Log.info('Building PointsPage UI, selected menu: $_selectedMenu');
    return PoinPageUi(
      appBarTitle: _appBarTitle,
      totalPoin: _totalPoints,
      menuPilihan: _selectedMenu,
      onSelectionChanged: (final Set<MenuPoin> newSelection) async {
        final selection = newSelection.first;
        Log.info('Points menu changed to: $selection');
        setState(() => _selectedMenu = selection);

        if (selection == MenuPoin.riwayat) {
          if (widget.showAd) {
            await _interstitialAdService.show();
          }
          if (_transactionHistory.isEmpty) {
            await _loadTransactionHistory();
          }
        }
      },
      contentView: _selectedMenu == MenuPoin.penukaran
          ? _buildRewardList()
          : _buildPointsHistory(),
      bottomWidget: widget.showAd
          ? const BannerAdsWidget() // DIUBAH
          : null,
    );
  }

  Widget _buildRewardList() {
    Log.info('Building reward list.');
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }
    if (_rewardList.isEmpty) {
      return const Center(child: Text('No rewards available yet'));
    }
    return ListView.builder(
      itemCount: _rewardList.length,
      itemBuilder: (final context, final index) {
        final reward = _rewardList[index];
        final enoughPoints = _totalPoints >= reward.redemptionPoints;
        final progress = reward.redemptionPoints > 0
            ? (_totalPoints / reward.redemptionPoints).clamp(0.0, 1.0)
            : 1.0;
        final poinKurang = _totalPoints - reward.redemptionPoints;
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
                    Text('${reward.redemptionPoints} Points'),
                    ElevatedButton(
                      onPressed: () => _redeemReward(reward),
                      child: const Text('Tukar'),
                    ),
                  ],
                ),
                gapH4,
                LinearProgressIndicator(value: progress, minHeight: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Points: $_totalPoints / ${reward.redemptionPoints}',
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
    if (_isLoadingHistory) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_transactionHistory.isEmpty) {
      return const Center(child: Text('No points history yet'));
    }
    return ListView.builder(
      itemCount: _transactionHistory.length,
      itemBuilder: (final context, final index) {
        final tx = _transactionHistory[index];
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
          onTap: () => _navigateToDetailTransaksi(tx),
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
  }
}
