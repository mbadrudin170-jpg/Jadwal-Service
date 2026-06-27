// path lib/fitur/riwayat_aktivasi/provider/riwayat_aktivasi_paket_provider.dart

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_global.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_global.dart';

part 'riwayat_aktivasi_paket_provider.g.dart';

class TransaksiDenganPelanggan {
  final TransaksiModel transaksi;
  final PelangganModel? pelanggan;
  TransaksiDenganPelanggan({required this.transaksi, this.pelanggan});
  String get namaPelanggan => pelanggan?.nama ?? 'Tidak diketahui';
}

enum OpsiUrutan {
  tanggalBerakhir,
  namaAZ,
  namaZA,
  berakhirHariIni,
  diperbaruiPadaAZ,
  diperbaruiPadaZA,
  lunas,
  belumLunas,
}

class RiwayatAktivasiPaketState {
  final List<TransaksiDenganPelanggan> items;
  final OpsiUrutan sortBy;
  RiwayatAktivasiPaketState({
    this.items = const [],
    this.sortBy = OpsiUrutan.berakhirHariIni,
  });

  RiwayatAktivasiPaketState copyWith({
    List<TransaksiDenganPelanggan>? items,
    OpsiUrutan? sortBy,
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
    ref.watch(transaksiOpGlobalProvider);
    ref.watch(pelangganOpGlobalProvider);
    return _loadData(OpsiUrutan.berakhirHariIni);
  }

  Future<RiwayatAktivasiPaketState> _loadData(OpsiUrutan targetSort) async {
    final transaksiOp = ref.read(transaksiOpGlobalProvider);
    final pelangganOpSqlite = ref.read(pelangganOpSqliteProvider);
    final transaksi = await transaksiOp.ambilBerdasarkanStatusAktivasi();
    final pealnggan = await pelangganOpSqlite.ambilSemua();
    final customerMap = {for (var c in pealnggan) c.id: c};
    final combinedList = transaksi.map((trans) {
      return TransaksiDenganPelanggan(
        transaksi: trans,
        pelanggan: customerMap[trans.idPelanggan],
      );
    }).toList();
    _performSort(combinedList, targetSort);
    return RiwayatAktivasiPaketState(items: combinedList, sortBy: targetSort);
  }

  void changeSort(OpsiUrutan newSort) {
    if (!state.hasValue) return;
    final currentState = state.value!;
    if (currentState.sortBy == newSort) return;
    final List<TransaksiDenganPelanggan> sortedList = List.from(
      currentState.items,
    );
    _performSort(sortedList, newSort);
    state = AsyncValue.data(
      currentState.copyWith(items: sortedList, sortBy: newSort),
    );
  }

  void _performSort(List<TransaksiDenganPelanggan> list, OpsiUrutan option) {
    switch (option) {
      case OpsiUrutan.tanggalBerakhir:
        list.sort((a, b) {
          if (a.transaksi.tanggalBerakhir == null &&
              b.transaksi.tanggalBerakhir == null) {
            return 0;
          }
          if (a.transaksi.tanggalBerakhir == null) return 1;
          if (b.transaksi.tanggalBerakhir == null) return -1;
          final dateCompare = a.transaksi.tanggalBerakhir!.compareTo(
            b.transaksi.tanggalBerakhir!,
          );
          if (dateCompare != 0) return dateCompare;
          return a.transaksi.id.compareTo(b.transaksi.id);
        });
        break;
      case OpsiUrutan.diperbaruiPadaAZ:
        list.sort((a, b) {
          final updateAtA = a.transaksi.diperbaruiPada;
          final updateAtB = b.transaksi.diperbaruiPada;
          if (updateAtA == null && updateAtB == null) return 0;
          if (updateAtA == null) return 1;
          if (updateAtB == null) return -1;
          return updateAtB.compareTo(updateAtA);
        });
        break;
      case OpsiUrutan.diperbaruiPadaZA:
        list.sort((a, b) {
          final updateAtA = a.transaksi.diperbaruiPada;
          final updateAtB = b.transaksi.diperbaruiPada;
          if (updateAtA == null && updateAtB == null) return 0;
          if (updateAtA == null) return -1;
          if (updateAtB == null) return 1;
          return updateAtA.compareTo(updateAtB);
        });
        break;
      case OpsiUrutan.namaAZ:
        list.sort((a, b) {
          final nameCompare = a.namaPelanggan.toLowerCase().compareTo(
            b.namaPelanggan.toLowerCase(),
          );
          if (nameCompare != 0) return nameCompare;
          // Jika nama sama, urutkan berdasarkan ID transaksi (trx1 < trx3)
          return a.transaksi.id.compareTo(b.transaksi.id);
        });
        break;
      case OpsiUrutan.namaZA:
        list.sort((a, b) {
          final nameCompare = b.namaPelanggan.toLowerCase().compareTo(
            a.namaPelanggan.toLowerCase(),
          );
          if (nameCompare != 0) return nameCompare;
          return a.transaksi.id.compareTo(b.transaksi.id);
        });
        break;
      case OpsiUrutan.berakhirHariIni:
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
        break;
      case OpsiUrutan.lunas:
        list.sort((a, b) {
          final isPaidA = a.transaksi.statusPembayaran == StatusPembayaran.paid;
          final isPaidB = b.transaksi.statusPembayaran == StatusPembayaran.paid;
          if (isPaidA && !isPaidB) return -1;
          if (!isPaidA && isPaidB) return 1;
          return (b.transaksi.diperbaruiPada ?? b.transaksi.tanggal).compareTo(
            a.transaksi.diperbaruiPada ?? a.transaksi.tanggal,
          );
        });
        break;
      case OpsiUrutan.belumLunas:
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
        break;
    }
  }
}
