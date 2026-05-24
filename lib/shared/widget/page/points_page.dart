// path: lib/shared/widget/page/points_page.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/package_model.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/operasi/poin/points_page_data_source.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/widget/customer_name.dart';
import 'package:wifi/shared/widget/page/poin_page_ui.dart';
import 'package:wifi/user/page/transaction_detail_u.dart';
import 'package:wifi/user/widget/ads/banner/banner_waterfall_widget.dart';
import 'package:wifi/user/widget/ads/interstitial/interstitial_ad_service.dart';

class PointsPage extends StatefulWidget {
  final String customerId;
  final PointsPageDataSource dataSource;
  final bool showAd;

  const PointsPage({
    super.key,
    required this.customerId,
    required this.dataSource,
    this.showAd = false,
  });

  @override
  State<PointsPage> createState() => _PointsPageState();
}

class _PointsPageState extends State<PointsPage> {
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
    Log.info('Initializing PointsPage for customer: ${widget.customerId}');
    _appBarTitle = Row(
      children: [
        const Text('Poin: '),
        Expanded(
          child: CustomerNameWidget(
            customerId: widget.customerId,
            useFirebase: widget.dataSource.isFirebase,
          ),
        ),
      ],
    );

    // Iklan interstitial sekarang di-preload secara global di main.dart.
    // Tidak perlu loadAd() di sini lagi.

    unawaited(_loadPointsData());
  }

  // Tidak perlu dispose service singleton
  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadPointsData() async {
    if (!mounted) return;
    Log.info('Loading points data...');
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final totalPoints =
          await widget.dataSource.getTotalPoints(widget.customerId);
      final rewardList = await widget.dataSource.getPublicPackages();
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
          await widget.dataSource.getPointsTransactions(widget.customerId);
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

  Future<void> _navigateToDetailTransaksi(
      final TransactionModel transaction) async {
    if (!mounted) return;
    Log.info('Navigating to transaction detail for ID: ${transaction.id}');
    PackageModel? package;
    if (transaction.packageId != null && transaction.packageId!.isNotEmpty) {
      try {
        package =
            await widget.dataSource.getPackageById(transaction.packageId!);
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
  Widget build(final BuildContext context) {
    Log.info('Building PointsPage UI, selected menu: $_selectedMenu');
    return PoinPageUi(
      appBarTitle: _appBarTitle,
      totalPoin: _totalPoints,
      menuPilihan: _selectedMenu,
      onSelectionChanged: (final Set<MenuPoin> newSelection) async {
        final selection = newSelection.first;
        Log.info('Points menu changed to: $selection');
        setState(() => _selectedMenu = selection);

        // Tampilkan iklan saat beralih ke Riwayat & jika iklan diizinkan
        if (selection == MenuPoin.riwayat) {
          if (widget.showAd) {
            // Gunakan API baru: tampilkan jika siap, tanpa callback karena
            // _loadTransactionHistory dipanggil setelah ini.
            InterstitialAdService().showAdIfReady();
          }
          // Muat riwayat jika belum ada
          if (_transactionHistory.isEmpty) {
            await _loadTransactionHistory();
          }
        }
      },
      contentView: _selectedMenu == MenuPoin.penukaran
          ? _buildRewardList()
          : _buildPointsHistory(),
      bottomWidget: widget.showAd ? BannerWaterfallWidget() : null,
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
                    Text(
                      '$poinKurang',
                      style: TextStyle(
                        color: enoughPoints ? Colors.green : Colors.red,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                LinearProgressIndicator(value: progress, minHeight: 8),
                Text('Points: $_totalPoints / ${reward.redemptionPoints}',
                    style: TextStyle(
                        fontSize: 12,
                        color: enoughPoints ? Colors.green : Colors.grey)),
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
        return InkWell(
          onTap: () => _navigateToDetailTransaksi(tx),
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: ListTile(
              leading: Icon(
                isAddition ? AppIcons.arrowUp : AppIcons.arrowDown,
                color: isAddition ? Colors.green : Colors.red,
              ),
              title: Text(tx.description),
              subtitle: Text(
                FormatDate.formatDateBasic(tx.date),
              ),
              trailing: Text(pointsStr,
                  style: TextStyle(
                      color: isAddition ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ),
          ),
        );
      },
    );
  }
}
