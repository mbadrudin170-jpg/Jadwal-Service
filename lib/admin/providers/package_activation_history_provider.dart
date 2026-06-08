// path: lib/admin/providers/package_activation_history_provider.dart

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/shared/enum/payment_status_enum.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/operasi_sqlite_provider/operasi_sqlite_provider.dart';

part 'package_activation_history_provider.g.dart';

// 1. Buat class untuk menggabungkan data
class TransactionWithCustomer {
  final TransactionModel transaction;
  final CustomerModel? customer;

  TransactionWithCustomer({required this.transaction, this.customer});

  // Helper untuk akses mudah
  String get customerName => customer?.name ?? 'Tidak diketahui';
}

enum SortOption {
  endDate,
  nameAZ,
  nameZA,
  endingToday,
  updatedAtAZ, // Harusnya: Terbaru ke Terlama (Descending)
  updatedAtZA, // Harusnya: Terlama ke Terbaru (Ascending)
  paid,
  unpaid
}

// 2. Ubah State untuk menggunakan class gabungan
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
    ref.watch(transactionOperationProvider);
    ref.watch(
        customerOperationProvider); // Pastikan provider customer juga ditonton
    return _loadData(SortOption.endDate);
  }

  Future<PackageActivationHistoryState> _loadData(SortOption targetSort) async {
    // 3. Ambil kedua data stream
    final transactionOp = ref.read(transactionOperationProvider);
    final customerOp = ref.read(customerOperationProvider);

    final transactions =
        await transactionOp.getTransactionsByPackageActivation();
    final customers = await customerOp.getAll();

    // Buat peta untuk pencarian cepat
    final customerMap = {for (var c in customers) c.id: c};

    // 4. Gabungkan data
    final combinedList = transactions.map((trans) {
      return TransactionWithCustomer(
        transaction: trans,
        customer: customerMap[trans.customerId],
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

    // Buat salinan list untuk diurutkan
    final List<TransactionWithCustomer> sortedList =
        List.from(currentState.items);
    _performSort(sortedList, newSort);

    // Update state dengan list yang sudah diurutkan
    state = AsyncValue.data(currentState.copyWith(
      items: sortedList,
      sortBy: newSort,
    ));
  }

  // 5. Perbaiki fungsi sort untuk bekerja dengan `TransactionWithCustomer`
  void _performSort(List<TransactionWithCustomer> list, SortOption option) {
    switch (option) {
      case SortOption.endDate:
        list.sort((a, b) {
          if (a.transaction.endDate == null && b.transaction.endDate == null) {
            return 0;
          }
          if (a.transaction.endDate == null) return 1;
          if (b.transaction.endDate == null) return -1;
          final dateCompare =
              b.transaction.endDate!.compareTo(a.transaction.endDate!);
          if (dateCompare != 0) return dateCompare;
          return a.transaction.id.compareTo(b.transaction.id);
        });
        break;
      case SortOption.updatedAtAZ: // Sesuai instruksi: Terbaru ke Terlama (Descending)
        list.sort((a, b) {
          final updateAtA = a.transaction.updatedAt;
          final updateAtB = b.transaction.updatedAt;
          if (updateAtA == null && updateAtB == null) return 0;
          if (updateAtA == null) return 1; // null di akhir
          if (updateAtB == null) return -1; // null di akhir
          return updateAtB.compareTo(updateAtA); // b vs a untuk descending
        });
        break;
      case SortOption.updatedAtZA: // Sesuai instruksi: Terlama ke Terbaru (Ascending)
        list.sort((a, b) {
          final updateAtA = a.transaction.updatedAt;
          final updateAtB = b.transaction.updatedAt;
          if (updateAtA == null && updateAtB == null) return 0;
          if (updateAtA == null) return -1; // null di awal
          if (updateAtB == null) return 1; // null di awal
          return updateAtA.compareTo(updateAtB); // a vs b untuk ascending
        });
        break;
      case SortOption.nameAZ:
        // Sekarang kita bisa sort berdasarkan `customerName`
        list.sort((a, b) => a.customerName
            .toLowerCase()
            .compareTo(b.customerName.toLowerCase()));
        break;
      case SortOption.nameZA:
        list.sort((a, b) => b.customerName
            .toLowerCase()
            .compareTo(a.customerName.toLowerCase()));
        break;
      case SortOption.endingToday:
        final now = DateTime.now();
        list.sort((a, b) {
          final isTodayA = a.transaction.endDate != null &&
              a.transaction.endDate!.year == now.year &&
              a.transaction.endDate!.month == now.month &&
              a.transaction.endDate!.day == now.day;
          final isTodayB = b.transaction.endDate != null &&
              b.transaction.endDate!.year == now.year &&
              b.transaction.endDate!.month == now.month &&
              b.transaction.endDate!.day == now.day;

          if (isTodayA && !isTodayB) return -1;
          if (!isTodayA && isTodayB) return 1;

          if (a.transaction.endDate == null && b.transaction.endDate == null) {
            return 0;
          }
          if (a.transaction.endDate == null) return 1;
          if (b.transaction.endDate == null) return -1;
          return a.transaction.endDate!.compareTo(b.transaction.endDate!);
        });
        break;
      case SortOption.paid:
        list.sort((a, b) {
          // 6. Perbaiki ENUM
          final isPaidA = a.transaction.paymentStatus == PaymentStatus.paid;
          final isPaidB = b.transaction.paymentStatus == PaymentStatus.paid;
          if (isPaidA && !isPaidB) return -1;
          if (!isPaidA && isPaidB) return 1;
          return (b.transaction.updatedAt ?? b.transaction.date)
              .compareTo(a.transaction.updatedAt ?? a.transaction.date);
        });
        break;
      case SortOption.unpaid:
        list.sort((a, b) {
          final isUnpaidA = a.transaction.paymentStatus == PaymentStatus.unpaid;
          final isUnpaidB = b.transaction.paymentStatus == PaymentStatus.unpaid;
          if (isUnpaidA && !isUnpaidB) return -1;
          if (!isUnpaidA && isUnpaidB) return 1;
          return (b.transaction.updatedAt ?? b.transaction.date)
              .compareTo(a.transaction.updatedAt ?? a.transaction.date);
        });
        break;
    }
  }
}
