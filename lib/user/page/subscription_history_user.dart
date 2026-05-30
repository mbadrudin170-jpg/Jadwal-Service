// path: lib/user/page/subscription_history_user.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/shared/enum/payment_status_enum.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/export/op_firebase.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/utils/calculation_util.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/widget/package_name.dart';
import 'package:wifi/user/page/transaction_detail_u.dart';
import 'package:wifi/user/providers/ad_providers.dart';

enum SortMode {
  endDateNewest,
  endDateOldest,
  statusPaid,
  statusUnpaid,
}

class SubscriptionHistoryPage extends ConsumerStatefulWidget {
  final String userId;

  const SubscriptionHistoryPage({super.key, required this.userId});

  @override
  ConsumerState<SubscriptionHistoryPage> createState() =>
      _SubscriptionHistoryPageState();
}

class _SubscriptionHistoryPageState
    extends ConsumerState<SubscriptionHistoryPage> {
  final CustomerOpFirebase _customerOpFirebase = CustomerOpFirebase();
  final TransactionOpFirebase _transactionOpFirebase = TransactionOpFirebase();
  final PackageOpFirebase _packageOpFirebase = PackageOpFirebase();

  SortMode _sortMode = SortMode.endDateNewest;
  late Future<List<TransactionModel>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _loadHistory();
  }

  Future<List<TransactionModel>> _loadHistory() async {
    final customer = await _customerOpFirebase.getCustomerOnce(widget.userId);
    if (customer == null) return [];
    return _transactionOpFirebase.getTransactionsByCustomerId(customer.id);
  }

  List<TransactionModel> _sortHistory(List<TransactionModel> history) {
    switch (_sortMode) {
      case SortMode.endDateNewest:
        history.sort((a, b) {
          if (a.endDate == null && b.endDate == null) return 0;
          if (a.endDate == null) return 1;
          if (b.endDate == null) return -1;
          return b.endDate!.compareTo(a.endDate!);
        });
        break;
      case SortMode.endDateOldest:
        history.sort((a, b) {
          if (a.endDate == null && b.endDate == null) return 0;
          if (a.endDate == null) return 1;
          if (b.endDate == null) return -1;
          return a.endDate!.compareTo(b.endDate!);
        });
        break;
      case SortMode.statusPaid:
        history.sort((a, b) {
          final statusA = a.paymentStatus == PaymentStatus.paid ? 0 : 1;
          final statusB = b.paymentStatus == PaymentStatus.paid ? 0 : 1;
          return statusA.compareTo(statusB);
        });
        break;
      case SortMode.statusUnpaid:
        history.sort((a, b) {
          final statusA = a.paymentStatus == PaymentStatus.unpaid ? 0 : 1;
          final statusB = b.paymentStatus == PaymentStatus.unpaid ? 0 : 1;
          return statusA.compareTo(statusB);
        });
        break;
    }
    return history;
  }

  Future<void> _refreshHistory() async {
    setState(() {
      _historyFuture = _loadHistory();
    });
  }

  Future<void> _navigateToTransactionDetail(
    TransactionModel tx,
    Future<PackageModel?> packageFuture,
  ) async {
    final package = await packageFuture;
    await ref.read(interstitialAdServiceProvider).show();
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionDetailPage(
          transaction: tx,
          package: package,
        ),
      ),
    );
    await ref.read(interstitialAdServiceProvider).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Langganan'),
        actions: [
          PopupMenuButton<SortMode>(
            onSelected: (SortMode result) => setState(() => _sortMode = result),
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                  value: SortMode.endDateNewest,
                  child: Text('Tanggal Berakhir (Terbaru)')),
              const PopupMenuItem(
                  value: SortMode.endDateOldest,
                  child: Text('Tanggal Berakhir (Terlama)')),
              const PopupMenuItem(
                  value: SortMode.statusPaid, child: Text('Status: Lunas')),
              const PopupMenuItem(
                  value: SortMode.statusUnpaid,
                  child: Text('Status: Belum Lunas')),
            ],
            icon: const Icon(TIcons.sort),
          ),
        ],
      ),
      body: StreamBuilder<CustomerModel?>(
        stream: _customerOpFirebase.getCustomerStream(widget.userId),
        builder: (context, customerSnapshot) {
          if (customerSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (customerSnapshot.hasError) {
            return Center(child: Text('Error: ${customerSnapshot.error}'));
          }
          if (!customerSnapshot.hasData || customerSnapshot.data == null) {
            return const Center(child: Text('Data pelanggan tidak ditemukan.'));
          }
          return Column(
            children: [
              Expanded(
                child: FutureBuilder<List<TransactionModel>>(
                  future: _historyFuture,
                  builder: (context, historySnapshot) {
                    if (historySnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (historySnapshot.hasError) {
                      return Center(
                          child:
                              Text('Gagal memuat: ${historySnapshot.error}'));
                    }
                    if (!historySnapshot.hasData ||
                        historySnapshot.data!.isEmpty) {
                      return const Center(child: Text('Tidak ada riwayat.'));
                    }
                    final sorted =
                        _sortHistory(List.from(historySnapshot.data!));
                    return RefreshIndicator(
                      onRefresh: _refreshHistory,
                      child: ListView.builder(
                        itemCount: sorted.length,
                        itemBuilder: (context, index) {
                          final tx = sorted[index];
                          final packageFuture = tx.packageId != null
                              ? _packageOpFirebase.getPackageById(tx.packageId!)
                              : Future<PackageModel?>.value();
                          final activeText = tx.endDate != null
                              ? CalculationUtil.getRemainingActivePeriodText(
                                  tx.endDate!)
                              : 'N/A';
                          final activeColor = tx.endDate != null
                              ? CalculationUtil.getRemainingActivePeriodColor(
                                  tx.endDate!)
                              : Colors.grey;
                          return Card(
                            key: ValueKey(tx.id),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: ListTile(
                                leading: const Icon(TIcons.receiptLong),
                                title: PackageNameWidget(
                                    packageFuture: packageFuture),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (tx.endDate != null)
                                      Text(
                                          'Berakhir - ${FormatDateTime.formatDateAndTimeCompact(tx.endDate!)}'),
                                    Text(
                                        'Status: ${tx.paymentStatus.displayName}',
                                        style: TextStyle(
                                            color: tx.paymentStatus ==
                                                    PaymentStatus.paid
                                                ? Colors.green
                                                : Colors.red)),
                                    Text('Masa Aktif: $activeText',
                                        style: TextStyle(color: activeColor)),
                                  ],
                                ),
                                trailing: const Icon(TIcons.chevronRight),
                                onTap: () => _navigateToTransactionDetail(
                                    tx, packageFuture)),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
