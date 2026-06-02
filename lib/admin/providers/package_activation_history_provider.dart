// path: lib/admin/providers/package_activation_history_provider.dart
// path: lib/admin/providers/package_activation_history_provider.dart

import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/admin/halaman/lainnya/package_activation_history.dart'; // Impor enum SortOption
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/operasi_sqlite_provider/operasi_sqlite_provider.dart';

part 'package_activation_history_provider.g.dart';

class PackageActivationHistoryState {
  final List<TransactionModel> transactions;
  final SortOption sortBy;

  PackageActivationHistoryState({
    this.transactions = const [],
    this.sortBy = SortOption.endDate,
  });

  PackageActivationHistoryState copyWith({
    List<TransactionModel>? transactions,
    SortOption? sortBy,
  }) {
    return PackageActivationHistoryState(
      transactions: transactions ?? this.transactions,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

@riverpod
class PackageActivationHistory extends _$PackageActivationHistory {
  @override
  FutureOr<PackageActivationHistoryState> build() {
    // Tonton provider database di sini agar reaktif 100% saat data berubah/di-invalidate
    ref.watch(transactionOperationProvider);
    return _loadData(SortOption.endDate);
  }

  Future<PackageActivationHistoryState> _loadData(SortOption targetSort) async {
    final operation = ref.read(transactionOperationProvider);
    final list = await operation.getTransactionsByPackageActivation();

    // Urutkan data secara lokal sebelum dikirim ke UI
    _performSort(list, targetSort);

    return PackageActivationHistoryState(
      transactions: list,
      sortBy: targetSort,
    );
  }

  void changeSort(SortOption newSort) {
    if (!state.hasValue) return;
    final currentState = state.value!;
    if (currentState.sortBy == newSort) return;

    final List<TransactionModel> sortedList =
        List.from(currentState.transactions);
    _performSort(sortedList, newSort);

    state = AsyncValue.data(currentState.copyWith(
      transactions: sortedList,
      sortBy: newSort,
    ));
  }

  void _performSort(List<TransactionModel> list, SortOption option) {
    switch (option) {
      case SortOption.endDate:
        list.sort((a, b) {
          if (a.endDate == null && b.endDate == null) return 0;
          if (a.endDate == null) return 1;
          if (b.endDate == null) return -1;
          return a.endDate!.compareTo(b.endDate!);
        });
        break;
      case SortOption.newest:
        list.sort(
            (a, b) => (b.updatedAt ?? b.date).compareTo(a.updatedAt ?? a.date));
        break;
      case SortOption.oldest:
        list.sort(
            (a, b) => (a.updatedAt ?? a.date).compareTo(b.updatedAt ?? b.date));
        break;
      // Tambahkan logic sorting untuk option lainnya (nameAZ, paid, dll) di sini...
      default:
        break;
    }
  }
}
