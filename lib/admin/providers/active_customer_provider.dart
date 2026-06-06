// path: lib/admin/providers/active_customer_provider.dart

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/shared/data/services/navigasi_servis.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/active_customer_detail_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/operasi_sqlite_provider/operasi_sqlite_provider.dart';
import 'package:wifi/shared/utils/toast_util.dart';

part 'active_customer_provider.g.dart';

enum SortOption {
  berakhirHariIni,
  terbaru,
  terlama,
  tanggalMulai,
  tanggalBerakhir,
  lunas,
  belumLunas,
  namaAZ,
  namaZA,
}

class ActiveCustomerState {
  final List<ActiveCustomerDetailModel> activeCustomers;
  final SortOption sortBy;

  ActiveCustomerState({
    this.activeCustomers = const [],
    this.sortBy = SortOption.berakhirHariIni,
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

@riverpod
class ActiveCustomer extends _$ActiveCustomer {
  @override
  ActiveCustomerState build() {
    return ActiveCustomerState();
  }

  List<ActiveCustomerDetailModel> _sortData(
      List<ActiveCustomerDetailModel> data, SortOption sortBy) {
    final sorted = List<ActiveCustomerDetailModel>.from(data);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    sorted.sort((a, b) {
      switch (sortBy) {
        case SortOption.berakhirHariIni:
          final sisaHariA = a.activeCustomer.endDate.difference(today).inDays;
          final sisaHariB = b.activeCustomer.endDate.difference(today).inDays;
          final comparison = sisaHariA.abs().compareTo(sisaHariB.abs());
          if (comparison != 0) {
            return comparison;
          }
          return sisaHariA.compareTo(sisaHariB);

        case SortOption.tanggalBerakhir:
          return b.activeCustomer.endDate.compareTo(a.activeCustomer.endDate);
        case SortOption.tanggalMulai:
          return a.activeCustomer.startDate
              .compareTo(b.activeCustomer.startDate);
        case SortOption.lunas:
          return a.activeCustomer.status.index
              .compareTo(b.activeCustomer.status.index);
        case SortOption.belumLunas:
          return b.activeCustomer.status.index
              .compareTo(a.activeCustomer.status.index);
        case SortOption.namaAZ:
          return a.customerName
              .toLowerCase()
              .compareTo(b.customerName.toLowerCase());
        case SortOption.namaZA:
          return b.customerName
              .toLowerCase()
              .compareTo(a.customerName.toLowerCase());
        case SortOption.terbaru:
          return b.activeCustomer.startDate
              .compareTo(b.activeCustomer.startDate);
        case SortOption.terlama:
          return a.activeCustomer.startDate
              .compareTo(b.activeCustomer.startDate);
      }
    });
    return sorted;
  }

  Future<void> fetchActiveCustomers() async {
    Log.info('Memulai pengambilan data pelanggan aktif.');
    try {
      final operation = ref.read(activeCustomerOperationProvider);
      final data = await operation.getAllActiveCustomersWithDetails();
      final sortedData = _sortData(data, state.sortBy);
      state = state.copyWith(activeCustomers: sortedData);
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
