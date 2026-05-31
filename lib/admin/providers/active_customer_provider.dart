// path: lib/admin/providers/active_customer_provider.dart

import 'dart:async';

// Menggunakan anotasi Riverpod terbaru
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/operation.dart';
import 'package:wifi/shared/model/active_customer_detail_model.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/data/services/navigasi_servis.dart';

// Wajib ditambahkan agar generator build_runner bisa bekerja
part 'active_customer_provider.g.dart';

enum SortOption {
  newest,
  endDate,
  startDate,
}

class ActiveCustomerState {
  final List<ActiveCustomerDetailModel> activeCustomers;
  final SortOption sortBy;

  ActiveCustomerState({
    this.activeCustomers = const [],
    this.sortBy = SortOption.newest,
  });

  ActiveCustomerState copyWith({
    List<ActiveCustomerDetailModel>? activeCustomers,
    SortOption? sortBy,
  }) {
    return ActiveCustomerState(
      activeCustomers: activeCustomers ?? this.activeCustomers,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

// Memicu pembuatan kode otomatis untuk 'activeCustomerProvider'
@riverpod
class ActiveCustomer extends _$ActiveCustomer {
  ActiveCustomerState build() {
    Future.microtask(() => fetchActiveCustomers());
    return ActiveCustomerState(activeCustomers: [], sortBy: SortOption.endDate);
  }

  late final ActiveCustomerOperation operation =
      ref.read(activeCustomerOperationProvider);

  List<ActiveCustomerDetailModel> _sortData(
      List<ActiveCustomerDetailModel> data, SortOption sortBy) {
    final sorted = List<ActiveCustomerDetailModel>.from(data);
    sorted.sort((a, b) {
      switch (sortBy) {
        case SortOption.endDate:
          return b.activeCustomer.endDate.compareTo(a.activeCustomer.endDate);
        case SortOption.startDate:
          return a.activeCustomer.startDate
              .compareTo(b.activeCustomer.startDate);
        default:
          return 0;
      }
    });
    return sorted;
  }

  Future<void> fetchActiveCustomers() async {
    Log.info('Memulai pengambilan data pelanggan aktif.');
    try {
      final List<ActiveCustomerDetailModel> data =
          await operation.getAllActiveCustomersWithDetails();

      final sortedData = _sortData(data, state.sortBy);

      state = state.copyWith(activeCustomers: sortedData);

      final context = NavigasiServis.navigatorKey.currentContext;

      if (context != null) {
      } else {
        Log.warning('Context tidak tersedia saat menampilkan success toast.');
      }
    } on Exception catch (e, st) {
      Log.error('Gagal mengambil data pelanggan aktif.', e: e, st: st);
      final context = NavigasiServis.navigatorKey.currentContext;
      if (context != null) {
        ToastUtil.error(context, 'Gagal memuat data pelanggan aktif.');
      } else {
        Log.warning('Context tidak tersedia saat menampilkan error toast.');
      }
      state = state.copyWith(activeCustomers: []);
    }
  }

  void setSortBy(SortOption newSortBy) {
    if (state.sortBy == newSortBy) return;
    final sortedCustomers = _sortData(state.activeCustomers, newSortBy);
    state = state.copyWith(activeCustomers: sortedCustomers, sortBy: newSortBy);
  }
}
