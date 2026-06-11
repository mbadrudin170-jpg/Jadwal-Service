// path: lib/admin/providers/active_customer_provider.dart

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/shared/data/services/navigasi_servis.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/active_customer_detail_model.dart';
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
  FutureOr<ActiveCustomerState> build() {
    return _loadData();
  }

  // Helper untuk perbandingan DateTime nullable
  int _compareNullableDates(DateTime? a, DateTime? b, {bool ascending = true}) {
    if (a == null && b == null) return 0;
    if (a == null) return 1; // null dianggap paling besar/lama
    if (b == null) return -1; // non-null dianggap lebih kecil/baru
    return ascending ? a.compareTo(b) : b.compareTo(a);
  }

  List<ActiveCustomerDetailModel> _sortData(
      List<ActiveCustomerDetailModel> data, SortOption sortBy) {
    final sorted = List<ActiveCustomerDetailModel>.from(data);
    final now = DateTime.now();

    sorted.sort((a, b) {
      switch (sortBy) {
        case SortOption.berakhirHariIni:
          final sisaHariA =
              a.activeCustomer.endDate.difference(now).inMilliseconds;
          final sisaHariB =
              b.activeCustomer.endDate.difference(now).inMilliseconds;

          final lewatA = sisaHariA < 0;
          final lewatB = sisaHariB < 0;

          if (!lewatA && lewatB) return -1;
          if (lewatA && !lewatB) return 1;
          if (!lewatA) {
            return sisaHariA.compareTo(sisaHariB);
          }
          return sisaHariB.compareTo(sisaHariA);

        case SortOption.terbaru:
          return _compareNullableDates(
              a.activeCustomer.updatedAt, b.activeCustomer.updatedAt,
              ascending: false); // Terbaru di atas (descending)

        case SortOption.terlama:
          return _compareNullableDates(a.activeCustomer.updatedAt,
              b.activeCustomer.updatedAt); // Terlama di atas (ascending)

        case SortOption.tanggalMulai:
          return a.activeCustomer.startDate
              .compareTo(b.activeCustomer.startDate);

        case SortOption.tanggalBerakhir:
          return b.activeCustomer.endDate.compareTo(a.activeCustomer.endDate);

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
      }
    });
    return sorted;
  }

  Future<ActiveCustomerState> _loadData() async {
    final operation = ref.watch(activeCustomerOperationProvider);
    final results = await Future.wait([
      operation.getAllActiveCustomersWithDetails(),
    ]);

    return ActiveCustomerState(
      activeCustomers: results[0],
    );
  }

  Future<void> fetchActiveCustomers() async {
    Log.info('Memulai pengambilan data pelanggan aktif.');
    final currentSortBy = state.value?.sortBy ?? SortOption.berakhirHariIni;
    state = const AsyncValue.loading();
    try {
      final operation = ref.read(activeCustomerOperationProvider);
      final data = await operation.getAllActiveCustomersWithDetails();
      final sortedData = _sortData(data, currentSortBy);
      state = AsyncValue.data(ActiveCustomerState(
          activeCustomers: sortedData, sortBy: currentSortBy));
    } on Exception catch (e, st) {
      Log.error('Gagal mengambil data pelanggan aktif.', e: e, st: st);
      final context = NavigasiServis.navigatorKey.currentContext;
      if (context != null) {
        ToastUtil.error(context, 'Gagal memuat data pelanggan aktif.');
      } else {
        Log.warning('Context tidak tersedia saat menampilkan error toast.');
      }
      state = AsyncValue.error(e, st);
    }
  }

  // 5. Mengatur kriteria pengurutan
  void setSortBy(SortOption urutanBaru) {
    final currentState = state.value;
    if (currentState == null || currentState.sortBy == urutanBaru) {
      return;
    }

    final pelangganTerurut =
        _sortData(currentState.activeCustomers, urutanBaru);
    state = AsyncValue.data(
      currentState.copyWith(
        activeCustomers: pelangganTerurut,
        sortBy: urutanBaru,
      ),
    );
  }
}
