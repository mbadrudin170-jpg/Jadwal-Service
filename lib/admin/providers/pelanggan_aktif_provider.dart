// path: lib/admin/providers/pelanggan_aktif_provider.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/active_customer_detail_model.dart';
import 'package:wifi/shared/utils/toast_util.dart';

part 'pelanggan_aktif_provider.g.dart';
part 'pelanggan_aktif_provider.freezed.dart';

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

@freezed
abstract class PelangganAktifState with _$PelangganAktifState {
  const factory PelangganAktifState({
    @Default([]) List<ActiveCustomerDetailModel> daftarPelangganAktif,
    @Default(SortOption.berakhirHariIni) SortOption sortBy,
  }) = _PelangganAktifState;
}

@riverpod
class PelangganAktif extends _$PelangganAktif {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  @override
  FutureOr<PelangganAktifState> build() {
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

  Future<PelangganAktifState> _loadData() async {
    final operation = ref.watch(pelangganAktifOpSqliteProvider);
    final results = await Future.wait([
      operation.getAllActiveCustomersWithDetails(),
    ]);

    return PelangganAktifState(
      daftarPelangganAktif: results[0],
    );
  }

  Future<void> fetchActiveCustomers() async {
    Log.info('Memulai pengambilan data pelanggan aktif.');
    final currentSortBy = state.value?.sortBy ?? SortOption.berakhirHariIni;
    state = const AsyncValue.loading();
    try {
      final data =await  ref.read(pelangganAktifOpSqliteProvider).getAllActiveCustomersWithDetails();
     final sortedData = _sortData(data, currentSortBy);
      state = AsyncValue.data(PelangganAktifState(
          daftarPelangganAktif: sortedData, sortBy: currentSortBy));
    } on Exception catch (e, st) {
      Log.error('Gagal mengambil data pelanggan aktif.', e: e, s: st);
      final context = navigatorKey.currentContext;
      if (context!.mounted) {
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
        _sortData(currentState.daftarPelangganAktif, urutanBaru);
    state = AsyncValue.data(
      currentState.copyWith(
        daftarPelangganAktif: pelangganTerurut,
        sortBy: urutanBaru,
      ),
    );
  }
}
