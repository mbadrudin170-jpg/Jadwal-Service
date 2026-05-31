// path: lib/admin/providers/active_customer_provider.dart

import 'dart:async';

// Menggunakan anotasi Riverpod terbaru
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/model/active_customer_model.dart';
import 'package:wifi/shared/providers/shared_providers.dart';
import 'package:wifi/shared/data/services/navigasi_servis.dart';

// Wajib ditambahkan agar generator build_runner bisa bekerja
part 'active_customer_provider.g.dart';

enum SortBy { newest, oldest }

class ActiveCustomerState {
  final List<ActiveCustomerModel> activeCustomers;
  final SortBy sortBy;

  ActiveCustomerState({
    this.activeCustomers = const [],
    this.sortBy = SortBy.newest,
  });

  ActiveCustomerState copyWith({
    List<ActiveCustomerModel>? activeCustomers,
    SortBy? sortBy,
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
  // Method build() menggantikan konstruktor lama untuk inisialisasi state awal
  @override
  ActiveCustomerState build() {
    // Memanggil fungsi fetch secara aman setelah widget selesai dirender pertama kali
    Future.microtask(() => fetchActiveCustomers());
    return ActiveCustomerState();
  }

  Future<void> fetchActiveCustomers() async {
    Log.info('Memulai pengambilan data pelanggan aktif.');
    try {
      // Menggunakan objek 'ref' bawaan kelas Notifier secara langsung
      final operation = ref.read(activeCustomerOperationProvider);
      final data = await operation.getAllActiveCustomers();

      data.sort((a, b) {
        if (state.sortBy == SortBy.newest) {
          return b.startDate.compareTo(a.startDate);
        } else {
          return a.startDate.compareTo(b.startDate);
        }
      });

      state = state.copyWith(activeCustomers: data);

      final context = NavigasiServis.navigatorKey.currentContext;
      if (context != null) {
        ToastUtil.success(context, 'Data pelanggan aktif berhasil dimuat.');
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

  void sortCustomers(SortBy newSortBy) {
    if (state.sortBy == newSortBy) return;

    final sortedCustomers =
        List<ActiveCustomerModel>.from(state.activeCustomers);
    sortedCustomers.sort((a, b) {
      if (newSortBy == SortBy.newest) {
        return b.startDate.compareTo(a.startDate);
      } else {
        return a.startDate.compareTo(b.startDate);
      }
    });

    state = state.copyWith(activeCustomers: sortedCustomers, sortBy: newSortBy);
  }
}
