// path: lib/admin/halaman/pembantu/admin_points_page.dart
//
// 📂 FILE INI DIGUNAKAN OLEH:
//   - lib/admin/halaman/detail/customer_detail.dart
//
// 📂 FILE INI MENGGUNAKAN:
//   - lib/shared/model/package_model.dart (PackageModel)
//   - lib/shared/model/transaction_model.dart (TransactionModel)
//   - lib/shared/operasi/package_operation.dart (PackageOperation)
//   - lib/shared/operasi/transaction_operation.dart (TransactionOperation)
//   - lib/shared/utils/format_util.dart (FormatUtil)
//   - lib/shared/widget/customer_name.dart (CustomerNameWidget)
//   - lib/shared/widget/poin_page_ui.dart (PoinPageUi)
//   - lib/shared/debug/log.dart (Log)

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/package_model.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/operasi/package_operation.dart';
import 'package:wifi/shared/operasi/transaction_operation.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/widget/customer_name.dart';
import 'package:wifi/shared/widget/poin_page_ui.dart';

/// Halaman untuk admin mengelola dan melihat poin pelanggan.
///
/// Menampilkan total poin, daftar hadiah yang bisa ditukar, dan riwayat
/// perolehan serta penggunaan poin pelanggan.
class AdminPointsPage extends StatefulWidget {
  /// ID unik dari pelanggan yang poinnya sedang dilihat.
  final String customerId;

  /// Konstruktor untuk [AdminPointsPage].
  const AdminPointsPage({super.key, required this.customerId});

  @override
  State<AdminPointsPage> createState() => _AdminPointsPageState();
}

class _AdminPointsPageState extends State<AdminPointsPage> {
  MenuPoin _selectedMenu = MenuPoin.penukaran;
  final PackageOperation _packageOperation = PackageOperation();
  final TransactionOperation _transactionOperation = TransactionOperation();

  int _totalPoints = 0;
  List<PackageModel> _rewardList = [];
  List<TransactionModel> _transactionHistory = [];
  bool _isLoading = false;
  bool _isLoadingHistory = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    Log.info('Menginisialisasi AdminPointsPage untuk pelanggan: ${widget.customerId}');
    unawaited(_loadPointsData());
  }

  Future<void> _loadPointsData() async {
    if (!mounted) return;
    Log.info('Memulai memuat data poin...');
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final totalPoints =
          await _transactionOperation.getTotalPoints(widget.customerId);
      final rewardList = await _packageOperation.getPublicPackages();
      if (!mounted) return;
      setState(() {
        _totalPoints = totalPoints;
        _rewardList = rewardList;
        _isLoading = false;
      });
      Log.info('Berhasil memuat data poin dan hadiah.');
      if (_selectedMenu == MenuPoin.riwayat) {
        await _loadTransactionHistory();
      }
    } on Exception catch (e, st) {
      Log.error('Gagal memuat data poin: $e', e: e, st: st);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memuat data: $e';
      });
    }
  }

  Future<void> _loadTransactionHistory() async {
    if (!mounted) return;
    Log.info('Memulai memuat riwayat transaksi poin...');
    setState(() => _isLoadingHistory = true);
    try {
      final history = await _transactionOperation
          .getTransactionsByCustomerId(widget.customerId);
      final pointsTransactions = history
          .where((final TransactionModel t) =>
              t.earnedPoints > 0 || t.usedPoints > 0)
          .toList();
      if (!mounted) return;
      setState(() {
        _transactionHistory = pointsTransactions;
        _isLoadingHistory = false;
      });
      Log.info('Berhasil memuat riwayat transaksi poin.');
    } on Exception catch (e, st) {
      Log.error('Gagal memuat riwayat: $e', e: e, st: st);
      if (!mounted) return;
      setState(() {
        _isLoadingHistory = false;
        _transactionHistory = [];
      });
    }
  }

  @override
  Widget build(final BuildContext context) {
    Log.info('Membangun UI AdminPointsPage, menu terpilih: $_selectedMenu');
    return PoinPageUi(
      appBarTitle: Row(
        children: [
          const Text('Poin: '),
          CustomerNameWidget(customerId: widget.customerId),
        ],
      ),
      totalPoin: _totalPoints,
      menuPilihan: _selectedMenu,
      onSelectionChanged: (final Set<MenuPoin> newSelection) async {
        final selection = newSelection.first;
        Log.info('Menu poin diubah menjadi: $selection');
        setState(() => _selectedMenu = selection);
        if (selection == MenuPoin.riwayat && _transactionHistory.isEmpty) {
          await _loadTransactionHistory();
        }
      },
      contentView: _selectedMenu == MenuPoin.penukaran
          ? _buildRewardList()
          : _buildPointsHistory(),
    );
  }

  Widget _buildRewardList() {
    Log.info('Membangun daftar hadiah (penukaran poin).');
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }
    if (_rewardList.isEmpty) {
      return const Center(child: Text('Belum ada hadiah tersedia'));
    }
    return ListView.builder(
      itemCount: _rewardList.length,
      itemBuilder: (final context, final index) {
        final reward = _rewardList[index];
        final enoughPoints = _totalPoints >= reward.redemptionPoints;
        final progress = reward.redemptionPoints > 0
            ? (_totalPoints / reward.redemptionPoints).clamp(0.0, 1.0)
            : 1.0;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            title: Text(reward.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${reward.redemptionPoints} Poin'),
                LinearProgressIndicator(value: progress, minHeight: 8),
                Text('Poin: $_totalPoints / ${reward.redemptionPoints}',
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
    Log.info('Membangun riwayat transaksi poin.');
    if (_isLoadingHistory) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_transactionHistory.isEmpty) {
      return const Center(child: Text('Belum ada riwayat poin'));
    }
    return ListView.builder(
      itemCount: _transactionHistory.length,
      itemBuilder: (final context, final index) {
        final tx = _transactionHistory[index];
        final isAddition = tx.earnedPoints > 0;
        final pointsValue = isAddition ? tx.earnedPoints : tx.usedPoints;
        final pointsStr = isAddition ? '+$pointsValue' : '-$pointsValue';
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            leading: Icon(
                isAddition
                    ? Icons.add_circle_outline
                    : Icons.remove_circle_outline,
                color: isAddition ? Colors.green : Colors.red),
            title: Text(tx.description),
            subtitle: Text(FormatUtil.formatDateBasic(tx.date),
                style: const TextStyle(fontSize: 12)),
            trailing: Text(pointsStr,
                style: TextStyle(
                    color: isAddition ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ),
        );
      },
    );
  }
}
