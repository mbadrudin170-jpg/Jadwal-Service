// path: lib/admin/providers/package_activation_history_provider.dart

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/shared/enum/payment_status_enum.dart';
import 'package:wifi/shared/model/transaksi_model.dart';

part 'package_activation_history_provider.g.dart';

class TransactionWithCustomer {
  final TransaksiModel transaksi;
  final PelangganModel? pelanggan;

  TransactionWithCustomer({required this.transaksi, this.pelanggan});

  String get customerName => pelanggan?.name ?? 'Tidak diketahui';
}

enum SortOption {
  endDate,
  nameAZ,
  nameZA,
  endingToday,
  updatedAtAZ,
  updatedAtZA,
  paid,
  unpaid
}

class PackageActivationHistoryState {
  final List<TransactionWithCustomer> items;
  final SortOption sortBy;

  PackageActivationHistoryState({
    this.items = const [],
    this.sortBy = SortOption.endingToday,
  });

  PackageActivationHistoryState copyWith({
    List<TransactionWithCustomer>? items,
    SortOption? sortBy,
  }) {
    return PackageActivationHistoryState(
      items: items ?? this.items,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

@riverpod
class PackageActivationHistory extends _$PackageActivationHistory {
  @override
  FutureOr<PackageActivationHistoryState> build() {
    ref.watch(transaksiOpSqliteProvider);
    ref.watch(pelangganOpSqliteProvider);
    return _loadData(SortOption.endDate);
  }

  Future<PackageActivationHistoryState> _loadData(SortOption targetSort) async {
    // 3. Ambil kedua data stream
    final transaksiOpSqlite = ref.read(transaksiOpSqliteProvider);
    final pelangganOpSqlite = ref.read(pelangganOpSqliteProvider);

    final transaksi =
        await transaksiOpSqlite.getTransactionsByPackageActivation();
    final pealnggan = await pelangganOpSqlite.ambilPelanggan();

    // Buat peta untuk pencarian cepat
    final customerMap = {for (var c in pealnggan) c.id: c};

    // 4. Gabungkan data
    final combinedList = transaksi.map((trans) {
      return TransactionWithCustomer(
        transaksi: trans,
        pelanggan: customerMap[trans.customerId],
      );
    }).toList();

    // Urutkan data gabungan
    _performSort(combinedList, targetSort);

    return PackageActivationHistoryState(
      items: combinedList,
      sortBy: targetSort,
    );
  }

  void changeSort(SortOption newSort) {
    if (!state.hasValue) return;

    final currentState = state.value!;
    if (currentState.sortBy == newSort) return;

    final List<TransactionWithCustomer> sortedList =
        List.from(currentState.items);
    _performSort(sortedList, newSort);

    state = AsyncValue.data(currentState.copyWith(
      items: sortedList,
      sortBy: newSort,
    ));
  }

  void _performSort(List<TransactionWithCustomer> list, SortOption option) {
    switch (option) {
      case SortOption.endDate:
        list.sort((a, b) {
          if (a.transaksi.endDate == null && b.transaksi.endDate == null) {
            return 0;
          }
          if (a.transaksi.endDate == null) return 1;
          if (b.transaksi.endDate == null) return -1;
          final dateCompare =
              b.transaksi.endDate!.compareTo(a.transaksi.endDate!);
          if (dateCompare != 0) return dateCompare;
          return a.transaksi.id.compareTo(b.transaksi.id);
        });
      case SortOption.updatedAtAZ:
        list.sort((a, b) {
          final updateAtA = a.transaksi.updatedAt;
          final updateAtB = b.transaksi.updatedAt;
          if (updateAtA == null && updateAtB == null) return 0;
          if (updateAtA == null) return 1;
          if (updateAtB == null) return -1;
          return updateAtB.compareTo(updateAtA);
        });
        break;
      case SortOption.updatedAtZA:
        list.sort((a, b) {
          final updateAtA = a.transaksi.updatedAt;
          final updateAtB = b.transaksi.updatedAt;
          if (updateAtA == null && updateAtB == null) return 0;
          if (updateAtA == null) return -1;
          if (updateAtB == null) return 1;
          return updateAtA.compareTo(updateAtB);
        });
      case SortOption.nameAZ:
        list.sort((a, b) => a.customerName
            .toLowerCase()
            .compareTo(b.customerName.toLowerCase()));
      case SortOption.nameZA:
        list.sort((a, b) => b.customerName
            .toLowerCase()
            .compareTo(a.customerName.toLowerCase()));
      case SortOption.endingToday:
        final now = DateTime.now();
        list.sort((a, b) {
          final isTodayA = a.transaksi.endDate != null &&
              a.transaksi.endDate!.year == now.year &&
              a.transaksi.endDate!.month == now.month &&
              a.transaksi.endDate!.day == now.day;
          final isTodayB = b.transaksi.endDate != null &&
              b.transaksi.endDate!.year == now.year &&
              b.transaksi.endDate!.month == now.month &&
              b.transaksi.endDate!.day == now.day;

          if (isTodayA && !isTodayB) return -1;
          if (!isTodayA && isTodayB) return 1;

          if (a.transaksi.endDate == null && b.transaksi.endDate == null) {
            return 0;
          }
          if (a.transaksi.endDate == null) return 1;
          if (b.transaksi.endDate == null) return -1;
          return a.transaksi.endDate!.compareTo(b.transaksi.endDate!);
        });
      case SortOption.paid:
        list.sort((a, b) {
          final isPaidA = a.transaksi.paymentStatus == PaymentStatus.paid;
          final isPaidB = b.transaksi.paymentStatus == PaymentStatus.paid;
          if (isPaidA && !isPaidB) return -1;
          if (!isPaidA && isPaidB) return 1;
          return (b.transaksi.updatedAt ?? b.transaksi.date)
              .compareTo(a.transaksi.updatedAt ?? a.transaksi.date);
        });
      case SortOption.unpaid:
        list.sort((a, b) {
          final isUnpaidA = a.transaksi.paymentStatus == PaymentStatus.unpaid;
          final isUnpaidB = b.transaksi.paymentStatus == PaymentStatus.unpaid;
          if (isUnpaidA && !isUnpaidB) return -1;
          if (!isUnpaidA && isUnpaidB) return 1;
          return (b.transaksi.updatedAt ?? b.transaksi.date)
              .compareTo(a.transaksi.updatedAt ?? a.transaksi.date);
        });
    }
  }
}
