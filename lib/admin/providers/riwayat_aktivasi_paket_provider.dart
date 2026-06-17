// path: lib/admin/providers/riwayat_aktivasi_paket_provider.dart

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';

part 'riwayat_aktivasi_paket_provider.g.dart';

class TransactionWithCustomer {
  final TransaksiModel transaksi;
  final PelangganModel? pelanggan;

  TransactionWithCustomer({required this.transaksi, this.pelanggan});

  String get customerName => pelanggan?.nama ?? 'Tidak diketahui';
}

enum SortOption {
  endDate,
  nameAZ,
  nameZA,
  endingToday,
  updatedAtAZ,
  updatedAtZA,
  paid,
  unpaid,
}

class RiwayatAktivasiPaketState {
  final List<TransactionWithCustomer> items;
  final SortOption sortBy;

  RiwayatAktivasiPaketState({
    this.items = const [],
    this.sortBy = SortOption.endingToday,
  });

  RiwayatAktivasiPaketState copyWith({
    List<TransactionWithCustomer>? items,
    SortOption? sortBy,
  }) {
    return RiwayatAktivasiPaketState(
      items: items ?? this.items,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

@riverpod
class RiwayatAktivasiPaket extends _$RiwayatAktivasiPaket {
  @override
  FutureOr<RiwayatAktivasiPaketState> build() {
    ref.watch(transaksiOpSqliteProvider);
    ref.watch(pelangganOpSqliteProvider);
    return _loadData(SortOption.endDate);
  }

  Future<RiwayatAktivasiPaketState> _loadData(SortOption targetSort) async {
    // 3. Ambil kedua data stream
    final transaksiOpSqlite = ref.read(transaksiOpSqliteProvider);
    final pelangganOpSqlite = ref.read(pelangganOpSqliteProvider);

    final transaksi = await transaksiOpSqlite.ambilBerdasarkanStatusAktivasi();
    final pealnggan = await pelangganOpSqlite.ambilSemua();

    // Buat peta untuk pencarian cepat
    final customerMap = {for (var c in pealnggan) c.id: c};

    // 4. Gabungkan data
    final combinedList = transaksi.map((trans) {
      return TransactionWithCustomer(
        transaksi: trans,
        pelanggan: customerMap[trans.idPelanggan],
      );
    }).toList();

    // Urutkan data gabungan
    _performSort(combinedList, targetSort);

    return RiwayatAktivasiPaketState(items: combinedList, sortBy: targetSort);
  }

  void changeSort(SortOption newSort) {
    if (!state.hasValue) return;

    final currentState = state.value!;
    if (currentState.sortBy == newSort) return;

    final List<TransactionWithCustomer> sortedList = List.from(
      currentState.items,
    );
    _performSort(sortedList, newSort);

    state = AsyncValue.data(
      currentState.copyWith(items: sortedList, sortBy: newSort),
    );
  }

  void _performSort(List<TransactionWithCustomer> list, SortOption option) {
    switch (option) {
      case SortOption.endDate:
        list.sort((a, b) {
          if (a.transaksi.tanggalBerakhir == null &&
              b.transaksi.tanggalBerakhir == null) {
            return 0;
          }
          if (a.transaksi.tanggalBerakhir == null) return 1;
          if (b.transaksi.tanggalBerakhir == null) return -1;
          final dateCompare = b.transaksi.tanggalBerakhir!.compareTo(
            a.transaksi.tanggalBerakhir!,
          );
          if (dateCompare != 0) return dateCompare;
          return a.transaksi.id.compareTo(b.transaksi.id);
        });
      case SortOption.updatedAtAZ:
        list.sort((a, b) {
          final updateAtA = a.transaksi.diperbaruiPada;
          final updateAtB = b.transaksi.diperbaruiPada;
          if (updateAtA == null && updateAtB == null) return 0;
          if (updateAtA == null) return 1;
          if (updateAtB == null) return -1;
          return updateAtB.compareTo(updateAtA);
        });
        break;
      case SortOption.updatedAtZA:
        list.sort((a, b) {
          final updateAtA = a.transaksi.diperbaruiPada;
          final updateAtB = b.transaksi.diperbaruiPada;
          if (updateAtA == null && updateAtB == null) return 0;
          if (updateAtA == null) return -1;
          if (updateAtB == null) return 1;
          return updateAtA.compareTo(updateAtB);
        });
      case SortOption.nameAZ:
        list.sort(
          (a, b) => a.customerName.toLowerCase().compareTo(
            b.customerName.toLowerCase(),
          ),
        );
      case SortOption.nameZA:
        list.sort(
          (a, b) => b.customerName.toLowerCase().compareTo(
            a.customerName.toLowerCase(),
          ),
        );
      case SortOption.endingToday:
        final now = DateTime.now();
        list.sort((a, b) {
          final isTodayA =
              a.transaksi.tanggalBerakhir != null &&
              a.transaksi.tanggalBerakhir!.year == now.year &&
              a.transaksi.tanggalBerakhir!.month == now.month &&
              a.transaksi.tanggalBerakhir!.day == now.day;
          final isTodayB =
              b.transaksi.tanggalBerakhir != null &&
              b.transaksi.tanggalBerakhir!.year == now.year &&
              b.transaksi.tanggalBerakhir!.month == now.month &&
              b.transaksi.tanggalBerakhir!.day == now.day;

          if (isTodayA && !isTodayB) return -1;
          if (!isTodayA && isTodayB) return 1;

          if (a.transaksi.tanggalBerakhir == null &&
              b.transaksi.tanggalBerakhir == null) {
            return 0;
          }
          if (a.transaksi.tanggalBerakhir == null) return 1;
          if (b.transaksi.tanggalBerakhir == null) return -1;
          return a.transaksi.tanggalBerakhir!.compareTo(
            b.transaksi.tanggalBerakhir!,
          );
        });
      case SortOption.paid:
        list.sort((a, b) {
          final isPaidA = a.transaksi.statusPembayaran == StatusPembayaran.paid;
          final isPaidB = b.transaksi.statusPembayaran == StatusPembayaran.paid;
          if (isPaidA && !isPaidB) return -1;
          if (!isPaidA && isPaidB) return 1;
          return (b.transaksi.diperbaruiPada ?? b.transaksi.tanggal).compareTo(
            a.transaksi.diperbaruiPada ?? a.transaksi.tanggal,
          );
        });
      case SortOption.unpaid:
        list.sort((a, b) {
          final isUnpaidA =
              a.transaksi.statusPembayaran == StatusPembayaran.unpaid;
          final isUnpaidB =
              b.transaksi.statusPembayaran == StatusPembayaran.unpaid;
          if (isUnpaidA && !isUnpaidB) return -1;
          if (!isUnpaidA && isUnpaidB) return 1;
          return (b.transaksi.diperbaruiPada ?? b.transaksi.tanggal).compareTo(
            a.transaksi.diperbaruiPada ?? a.transaksi.tanggal,
          );
        });
    }
  }
}
