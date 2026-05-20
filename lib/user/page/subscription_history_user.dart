// path: lib/user/page/subscription_history_user.dart
// diubah: Menggunakan ikon dari AppIcons untuk konsistensi UI.
// diperbaiki: Mengganti nama InfoPerangkatService menjadi DeviceInfoService.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wifi/shared/enum/payment_status_enum.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/export/op_firebase.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/utils/calculation_util.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/widget/package_name.dart';
import 'package:wifi/user/page/transaction_detail_user.dart';
import 'package:wifi/user/widget/ads/ad_helper.dart';
import 'package:wifi/user/widget/ads/banner_ad_widget.dart';

/// Enum untuk mode pengurutan riwayat langganan.
enum SortMode {
  /// Urutkan berdasarkan tanggal berakhir terbaru.
  endDateNewest,

  /// Urutkan berdasarkan tanggal berakhir terlama.
  endDateOldest,

  /// Urutkan berdasarkan status lunas.
  statusPaid,

  /// Urutkan berdasarkan status belum lunas.
  statusUnpaid,
}

/// Halaman untuk menampilkan riwayat langganan pengguna.
class SubscriptionHistoryPage extends StatefulWidget {
  /// ID pengguna yang sedang login.
  final String userId;

  /// Membuat instance dari [SubscriptionHistoryPage].
  const SubscriptionHistoryPage({super.key, required this.userId});

  @override
  State<SubscriptionHistoryPage> createState() =>
      _SubscriptionHistoryPageState();
}

class _SubscriptionHistoryPageState extends State<SubscriptionHistoryPage> {
  final CustomerOpFirebase _customerOpFirebase = CustomerOpFirebase();
  final TransactionOpFirebase _transactionOpFirebase = TransactionOpFirebase();
  final PackageOpFirebase _packageOpFirebase = PackageOpFirebase();

  /// Mode pengurutan saat ini.
  SortMode _sortMode = SortMode.endDateNewest;

  @override
  void initState() {
    super.initState();
  }

  List<TransactionModel> _sortHistory(final List<TransactionModel> history) {
    switch (_sortMode) {
      case SortMode.endDateNewest:
        history.sort((final a, final b) {
          if (a.endDate == null && b.endDate == null) return 0;
          if (a.endDate == null) return 1;
          if (b.endDate == null) return -1;
          return b.endDate!.compareTo(a.endDate!);
        });
      case SortMode.endDateOldest:
        history.sort((final a, final b) {
          if (a.endDate == null && b.endDate == null) return 0;
          if (a.endDate == null) return 1;
          if (b.endDate == null) return -1;
          return a.endDate!.compareTo(b.endDate!);
        });
      case SortMode.statusPaid:
        history.sort((final a, final b) {
          final statusA = a.paymentStatus == PaymentStatus.paid ? 0 : 1;
          final statusB = b.paymentStatus == PaymentStatus.paid ? 0 : 1;
          return statusA.compareTo(statusB);
        });
      case SortMode.statusUnpaid:
        history.sort((final a, final b) {
          final statusA = a.paymentStatus == PaymentStatus.unpaid ? 0 : 1;
          final statusB = b.paymentStatus == PaymentStatus.unpaid ? 0 : 1;
          return statusA.compareTo(statusB);
        });
    }
    return history;
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Langganan'),
        actions: [
          PopupMenuButton<SortMode>(
            onSelected: (final SortMode result) =>
                setState(() => _sortMode = result),
            itemBuilder: (final BuildContext context) => [
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
            icon: const Icon(AppIcons.sort),
          ),
        ],
      ),
      body: StreamBuilder<CustomerModel?>(
        stream: _customerOpFirebase.getCustomerStream(widget.userId),
        builder: (final context, final customerSnapshot) {
          if (customerSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (customerSnapshot.hasError) {
            return Center(child: Text('Error: ${customerSnapshot.error}'));
          }
          if (!customerSnapshot.hasData || customerSnapshot.data == null) {
            return const Center(child: Text('Data pelanggan tidak ditemukan.'));
          }
          final customer = customerSnapshot.data!;
          return Column(
            children: [
              Expanded(
                child: FutureBuilder<List<TransactionModel>>(
                  future: _transactionOpFirebase
                      .getFullSubscriptionHistory(customer.id),
                  builder: (final context, final historySnapshot) {
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
                    return ListView.builder(
                      itemCount: sorted.length,
                      itemBuilder: (final context, final index) {
                        final tx = sorted[index];
                        final packageFuture = tx.packageId != null
                            ? _packageOpFirebase
                                .getPackageModelById(tx.packageId!)
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
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: const Icon(AppIcons.receiptLong),
                            title:
                                PackageNameWidget(packageFuture: packageFuture),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (tx.endDate != null)
                                  Text(
                                      'Berakhir - ${FormatDateTime.formatDateAndTimeCompact(tx.endDate!)}'),
                                Text('Status: ${tx.paymentStatus.displayName}',
                                    style: TextStyle(
                                        color: tx.paymentStatus ==
                                                PaymentStatus.paid
                                            ? Colors.green
                                            : Colors.red)),
                                Text('Masa Aktif: $activeText',
                                    style: TextStyle(color: activeColor)),
                              ],
                            ),
                            trailing: const Icon(AppIcons.chevronRight),
                            onTap: () async {
                              final package = await packageFuture;
                              if (context.mounted) {
                                await Navigator.push<void>(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (final context) =>
                                        TransactionDetailPage(
                                            transaction: tx, package: package),
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Center(
                child: BannerAdWidget(adUnitId: AdHelper.bannerAdUnitId),
              ),
            ],
          );
        },
      ),
    );
  }
}
