// path: lib/user/page/subscription_history_user.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/shared/enum/payment_status_enum.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/export/op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/utils/perhitungan_util.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/widget/package_name.dart';
import 'package:wifi/user/page/transaction_detail_u.dart';
import 'package:wifi/user/providers/ad_providers.dart';
import 'package:wifi/user/providers/user_providers.dart';

enum SortMode {
  endDateNewest,
  endDateOldest,
  statusPaid,
  statusUnpaid,
}

class SubscriptionHistoryPage extends ConsumerStatefulWidget {
  const SubscriptionHistoryPage({super.key});

  @override
  ConsumerState<SubscriptionHistoryPage> createState() =>
      _SubscriptionHistoryPageState();
}

class _SubscriptionHistoryPageState
    extends ConsumerState<SubscriptionHistoryPage> {
  final TransaksiOpFirebase _transactionOpFirebase = TransaksiOpFirebase();

  SortMode _sortMode = SortMode.endDateNewest;
  late Future<List<TransaksiModel>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _loadHistory();
  }

  Future<List<TransaksiModel>> _loadHistory() async {
    final userId = await ref.watch(userIdProvider.future);

    if (userId == null) return [];
    final customerOpFirebase = ref.read(customerOpFirebaseProvider);
    final customer = await customerOpFirebase.getById(userId);
    if (customer == null) return [];
    return _transactionOpFirebase.ambilBerdasarkanIdPelanggan(customer.id);
  }

  List<TransaksiModel> _sortHistory(List<TransaksiModel> history) {
    switch (_sortMode) {
      case SortMode.endDateNewest:
        history.sort((a, b) {
          if (a.tangglberakhir == null && b.tangglberakhir == null) return 0;
          if (a.tangglberakhir == null) return 1;
          if (b.tangglberakhir == null) return -1;
          return b.tangglberakhir!.compareTo(a.tangglberakhir!);
        });
        break;
      case SortMode.endDateOldest:
        history.sort((a, b) {
          if (a.tangglberakhir == null && b.tangglberakhir == null) return 0;
          if (a.tangglberakhir == null) return 1;
          if (b.tangglberakhir == null) return -1;
          return a.tangglberakhir!.compareTo(b.tangglberakhir!);
        });
        break;
      case SortMode.statusPaid:
        history.sort((a, b) {
          final statusA = a.statusPembayaran == PaymentStatus.paid ? 0 : 1;
          final statusB = b.statusPembayaran == PaymentStatus.paid ? 0 : 1;
          return statusA.compareTo(statusB);
        });
        break;
      case SortMode.statusUnpaid:
        history.sort((a, b) {
          final statusA = a.statusPembayaran == PaymentStatus.unpaid ? 0 : 1;
          final statusB = b.statusPembayaran == PaymentStatus.unpaid ? 0 : 1;
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
    TransaksiModel tx,
    Future<PaketModel?> packageFuture,
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
    final packageOpFirebase = ref.read(packageOpFirebaseProvider);
    final customerOpFirebase = ref.read(customerOpFirebaseProvider);
    final userId = ref.watch(userIdProvider);
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
      body: StreamBuilder<PelangganModel?>(
        stream: userId.when(
          data: (id) => id != null
              ? customerOpFirebase.getStreamPelanggan(id)
              : const Stream.empty(),
          loading: () => const Stream.empty(),
          error: (_, __) => const Stream.empty(),
        ),
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
                child: FutureBuilder<List<TransaksiModel>>(
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
                          final packageFuture = tx.idPaket != null
                              ? packageOpFirebase
                                  .ambilBerdasarkanId(tx.idPaket!)
                              : Future<PaketModel?>.value();
                          final activeText = tx.tangglberakhir != null
                              ? PerhitunganUtil.ambilTeksSisaMasaAktif(
                                  tx.tangglberakhir!)
                              : 'N/A';
                          final activeColor = tx.tangglberakhir != null
                              ? PerhitunganUtil.ambilWarnaSisaMasaAktif(
                                  tx.tangglberakhir!)
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
                                    if (tx.tangglberakhir != null)
                                      Text(
                                          'Berakhir - ${FormatWaktuLengkap.formatSingkat(tx.tangglberakhir!)}'),
                                    Text(
                                        'Status: ${tx.statusPembayaran.displayName}',
                                        style: TextStyle(
                                            color: tx.statusPembayaran ==
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
