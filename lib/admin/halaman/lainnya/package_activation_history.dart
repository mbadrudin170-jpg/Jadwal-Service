// path: lib/admin/halaman/lainnya/package_activation_history.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/admin/halaman/detail/subscription_history_detail.dart';
import 'package:wifi/admin/providers/package_activation_history_provider.dart';
import 'package:wifi/shared/enum/payment_status_enum.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/widget/package_name.dart';

class PackageActivationHistoryPage extends ConsumerWidget {
  const PackageActivationHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(packageActivationHistoryProvider);
    final packageOperation = ref.watch(packageOperationProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Langganan'),
        actions: [
          IconButton(
            icon: const Icon(TIcons.filter),
            onPressed: () {
              if (historyAsync.hasValue) {
                _showSortDialog(context, ref, historyAsync.value!.sortBy);
              }
            },
            tooltip: 'Urutkan',
          ),
        ],
      ),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (state) {
          if (state.items.isEmpty) {
            return const Center(
                child: Text('Tidak ada riwayat langganan ditemukan.'));
          }
          return ListView.builder(
            itemCount: state.items.length,
            itemBuilder: (context, index) {
              final item = state.items[index];
              final transaction = item.transaction;
              final paymentStatusColor =
                  transaction.paymentStatus == PaymentStatus.paid
                      ? Colors.green
                      : Colors.red;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                child: ListTile(
                  onTap: () async {
                    await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubscriptionHistoryDetailPage(
                          transactionId: transaction.id,
                        ),
                      ),
                    );
                  },
                  title: Text(
                    item.customerName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PackageNameWidget(
                        packageFuture: packageOperation
                            .getById(transaction.packageId ?? ''),
                        style: TextStyle(color: paymentStatusColor),
                      ),
                      gapH4,
                      Text(
                        'Status: ${transaction.paymentStatus.displayName}',
                        style: TextStyle(
                          color: paymentStatusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      gapH4,
                      if (transaction.startDate != null &&
                          transaction.endDate != null)
                        Text(
                          'Aktif: ${FormatDate.formatDateBasic(transaction.startDate!)} - ${FormatDate.formatDateBasic(transaction.endDate!)}',
                        ),
                    ],
                  ),
                  trailing: const Icon(TIcons.chevronRight),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showSortDialog(
      BuildContext context, WidgetRef ref, SortOption currentSort) async {
    final SortOption? selected = await showDialog<SortOption>(
      context: context,
      builder: (BuildContext context) {
        Widget buildOption(String text, SortOption value) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, value),
            child: Text(text,
                style: TextStyle(
                    fontWeight: currentSort == value
                        ? FontWeight.bold
                        : FontWeight.normal)),
          );
        }

        return SimpleDialog(
          title: const Text('Urutkan Berdasarkan'),
          children: <Widget>[
            buildOption('Berakhir Hari Ini', SortOption.endingToday),
            buildOption('Tanggal Berakhir', SortOption.endDate),
            buildOption('Nama A-Z', SortOption.nameAZ),
            buildOption('Nama Z-A', SortOption.nameZA),
            buildOption('Lunas', SortOption.paid),
            buildOption('Belum Lunas', SortOption.unpaid),
            buildOption('Update Terbaru', SortOption.updatedAtAZ),
            buildOption('Update Terlama', SortOption.updatedAtZA),
          ],
        );
      },
    );

    if (selected != null) {
      ref.read(packageActivationHistoryProvider.notifier).changeSort(selected);
    }
  }
}
