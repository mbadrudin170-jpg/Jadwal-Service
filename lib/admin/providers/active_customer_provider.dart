// path: lib/admin/providers/active_customer_provider.dart

import 'dart:async';

// Menggunakan anotasi Riverpod terbaru
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/shared/data/services/navigasi_servis.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/active_customer_detail_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/operasi_sqlite_provider/operasi_sqlite_provider.dart';
import 'package:wifi/shared/utils/toast_util.dart';

// Wajib ditambahkan agar generator build_runner bisa bekerja
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

// Memicu pembuatan kode otomatis untuk 'activeCustomerProvider'
@riverpod
class ActiveCustomer extends _$ActiveCustomer {
  @override
  ActiveCustomerState build() {
    final currentState = stateOrNull;
    ref.watch(activeCustomerOperationProvider);
    Future.microtask(fetchActiveCustomers);
    return ActiveCustomerState(
        activeCustomers: [],
        sortBy: currentState?.sortBy ?? SortOption.berakhirHariIni);
  }

  List<ActiveCustomerDetailModel> _sortData(
      List<ActiveCustomerDetailModel> data, SortOption sortBy) {
    final sorted = List<ActiveCustomerDetailModel>.from(data);

    // Ambil waktu sekarang dan normalisasi ke jam 00:00 agar perhitungan tanggal murni akurat
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    sorted.sort((a, b) {
      switch (sortBy) {
        case SortOption.berakhirHariIni:
          final dateA = DateTime(
            a.activeCustomer.endDate.year,
            a.activeCustomer.endDate.month,
            a.activeCustomer.endDate.day,
          );
          final dateB = DateTime(
            b.activeCustomer.endDate.year,
            b.activeCustomer.endDate.month,
            b.activeCustomer.endDate.day,
          );

          // 2. Hitung sisa hari (bisa bernilai minus jika sudah lewat/kadaluarsa)
          final sisaHariA = dateA.difference(today).inDays;
          final sisaHariB = dateB.difference(today).inDays;

          // 3. Logika Urutan:
          // Kita ingin sisa hari yang paling kecil/mendekati nol (atau minus kecil) berada di atas.
          // Menggunakan nilai absolut (.abs()) memastikan selisih 0 hari (hari ini) berada di urutan teratas,
          // diikuti selisih 1 hari (besok/kemarin), dst.
          return sisaHariA.abs().compareTo(sisaHariB.abs());

        case SortOption.tanggalBerakhir:
          return b.activeCustomer.endDate.compareTo(a.activeCustomer.endDate);
        case SortOption.tanggalMulai:
          return a.activeCustomer.startDate
              .compareTo(b.activeCustomer.startDate);
        case SortOption.lunas: // Paid (index 0) vs Unpaid (index 1)
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
              .compareTo(a.activeCustomer.startDate);
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
