// path: lib/admin/halaman/lainnya/package_activation_history.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/admin/halaman/detail/subscription_history_detail.dart';
import 'package:wifi/admin/providers/package_activation_history_provider.dart';
import 'package:wifi/shared/enum/payment_status_enum.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/operasi_sqlite_provider/operasi_sqlite_provider.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/widget/customer_name.dart';
import 'package:wifi/shared/widget/package_name.dart';

enum SortOption {
  endDate,
  nameAZ,
  nameZA,
  endingToday,
  newest,
  oldest,
  paid,
  unpaid
}

class PackageActivationHistoryPage extends ConsumerWidget {
  const PackageActivationHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mengamati state riwayat via AsyncValue
    final historyAsync = ref.watch(packageActivationHistoryProvider);
    final packageOperation = ref.read(packageOperationProvider);

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
          if (state.transactions.isEmpty) {
            return const Center(
                child: Text('Tidak ada riwayat langganan ditemukan.'));
          }

          return ListView.builder(
            itemCount: state.transactions.length,
            itemBuilder: (context, index) {
              final transaction = state.transactions[index];
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
                    // Jika ada perubahan data di halaman detail, Anda cukup meng-invalidate provider database:
                    // ref.invalidate(transactionOperationProvider);
                  },
                  title: CustomerNameWidget(
                    customerId: transaction.customerId ?? ' ',
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
                      const SizedBox(height: 4),
                      Text(
                        'Status: ${transaction.paymentStatus.displayName}',
                        style: TextStyle(
                          color: paymentStatusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (transaction.startDate != null &&
                          transaction.endDate != null)
                        Text(
                          'Aktif: ${FormatDate.formatDateBasic(transaction.startDate!)} - ${FormatDate.formatDateBasic(transaction.endDate!)}',
                        ),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
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
            buildOption('Tanggal Berakhir', SortOption.endDate),
            buildOption('Terbaru', SortOption.newest),
            buildOption('Terlama', SortOption.oldest),
          ],
        );
      },
    );

    if (selected != null) {
      ref.read(packageActivationHistoryProvider.notifier).changeSort(selected);
    }
  }
}
