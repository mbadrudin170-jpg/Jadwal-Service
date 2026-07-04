// path: lib/fitur/transaksi/provider/transaksi_provider.dart

import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/transaksi/enum/tipe_transaksi.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_global.dart';
import 'package:wifi/shared/debug/log.dart';

part 'transaksi_provider.freezed.dart';
part 'transaksi_provider.g.dart';

@freezed
abstract class TransaksiState with _$TransaksiState {
  const factory TransaksiState({
    @Default([]) List<TransaksiModel> transaksi,
    @Default(0.0) double totalPemasukan,
    @Default(0.0) double totalPengeluaran,
    @Default(0.0) double total,
    @Default(0) int totalPoinSemuaPelanggan,
    required List<String> paketTerlaris,
    required List<double> pendapatanHarian,
    required List<double> pendapatanMingguan,
    required List<double> pendapatanBulanan,
    required double pendapatanBulanIni,
  }) = _TransaksiState;
}

@riverpod
class Transaksi extends _$Transaksi {
  TransaksiOpGlobal get _transaksiOp => ref.read(transaksiOpGlobalProvider);

  @override
  FutureOr<TransaksiState> build() {
    return _loadData();
  }

  Future<TransaksiState> _loadData() async {
    Log.info('[TransaksiProvider] 🔄 Memuat satu data utama via ambilSemua()');

    // 1. Single Source of Truth: Hanya panggil 1 fungsi async ke database
    final semuaTransaksi = await _transaksiOp.ambilSemua();
    final sekarang = DateTime.now();

    // 2. Kalkulasi statistik pemasukan & pengeluaran secara sinkron di memori HP
    final totalPemasukan = semuaTransaksi
        .where(
          (t) =>
              t.tipe == TipeTransaksi.income &&
              t.statusPembayaran == StatusPembayaran.paid,
        )
        .fold(0.0, (sum, t) => sum + t.jumlah);
    final totalPengeluaran = semuaTransaksi
        .where((t) => t.tipe == TipeTransaksi.expense)
        .fold(0.0, (sum, t) => sum + t.jumlah);
    final netTotal = totalPemasukan - totalPengeluaran;
    final totalPoinSemua = semuaTransaksi.fold(
      0,
      (sum, t) => sum + (t.poinDidapat - t.poinDigunakan),
    );
    final pendapatanBulanIni = semuaTransaksi
        .where(
          (t) =>
              t.tipe == TipeTransaksi.income &&
              t.statusPembayaran == StatusPembayaran.paid &&
              t.tanggal.month == sekarang.month &&
              t.tanggal.year == sekarang.year,
        )
        .fold(0.0, (sum, t) => sum + t.jumlah);
    return TransaksiState(
      transaksi: semuaTransaksi,
      totalPemasukan: totalPemasukan,
      totalPengeluaran: totalPengeluaran,
      total: netTotal,
      totalPoinSemuaPelanggan: totalPoinSemua,
      pendapatanBulanIni: pendapatanBulanIni,
      paketTerlaris: _hitungPaketTerlaris(semuaTransaksi),
      pendapatanHarian: _hitungPendapatanHarian(semuaTransaksi),
      pendapatanMingguan: _hitungPendapatanMingguan(semuaTransaksi),
      pendapatanBulanan: _hitungPendapatanBulanan(semuaTransaksi),
    );
  }

  // --- HELPER METODE UNTUK MEMPROSES GRAFIK & STATISTIK ---

  List<String> _hitungPaketTerlaris(List<TransaksiModel> list) {
    final jumlahPerPaket = <String, int>{};

    for (final t in list) {
      if (t.idPaket != null && t.statusPembayaran == StatusPembayaran.paid) {
        jumlahPerPaket[t.idPaket!] = (jumlahPerPaket[t.idPaket!] ?? 0) + 1;
      }
    }

    final sortedEntries = jumlahPerPaket.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedEntries.take(5).map((e) => e.key).toList();
  }

  List<double> _hitungPendapatanHarian(List<TransaksiModel> list) {
    final hasil = List<double>.filled(7, 0.0);
    final sekarang = DateTime.now();

    for (var i = 0; i < 7; i++) {
      final targetTanggal = sekarang.subtract(Duration(days: i));

      final totalHariItu = list
          .where(
            (t) =>
                t.tipe == TipeTransaksi.income &&
                t.statusPembayaran == StatusPembayaran.paid &&
                t.tanggal.day == targetTanggal.day &&
                t.tanggal.month == targetTanggal.month &&
                t.tanggal.year == targetTanggal.year,
          )
          .fold(0.0, (sum, t) => sum + t.jumlah);

      hasil[6 - i] = totalHariItu; // Mengurutkan dari hari terlama ke hari ini
    }
    return hasil;
  }

  List<double> _hitungPendapatanMingguan(List<TransaksiModel> list) {
    final hasil = List<double>.filled(4, 0.0);
    final sekarang = DateTime.now();

    for (var i = 0; i < 4; i++) {
      final batasBawah = sekarang.subtract(Duration(days: (i + 1) * 7));
      final batasAtas = sekarang.subtract(Duration(days: i * 7));

      final totalMingguItu = list
          .where((t) {
            if (t.tipe != TipeTransaksi.income ||
                t.statusPembayaran != StatusPembayaran.paid) {
              return false;
            }
            return t.tanggal.isAfter(batasBawah) &&
                t.tanggal.isBefore(batasAtas.add(const Duration(days: 1)));
          })
          .fold(0.0, (sum, t) => sum + t.jumlah);

      hasil[3 - i] =
          totalMingguItu; // Mengurutkan dari 4 minggu lalu ke minggu ini
    }
    return hasil;
  }

  List<double> _hitungPendapatanBulanan(List<TransaksiModel> list) {
    final hasil = List<double>.filled(5, 0.0);
    final sekarang = DateTime.now();

    for (var i = 0; i < 5; i++) {
      var targetBulan = sekarang.month - i;
      var targetTahun = sekarang.year;

      while (targetBulan <= 0) {
        targetBulan += 12;
        targetTahun -= 1;
      }

      final totalBulanItu = list
          .where(
            (t) =>
                t.tipe == TipeTransaksi.income &&
                t.statusPembayaran == StatusPembayaran.paid &&
                t.tanggal.month == targetBulan &&
                t.tanggal.year == targetTahun,
          )
          .fold(0.0, (sum, t) => sum + t.jumlah);

      hasil[4 - i] =
          totalBulanItu; // Mengurutkan dari 5 bulan lalu ke bulan ini
    }
    return hasil;
  }

  Future<int> getTotalPoinPelanggan(String idPelanggan) async {
    return await _transaksiOp.ambilTotalPoin(idPelanggan);
  }

  Future<Map<String, int>> getTotalPoinBanyakPelanggan(List<String> ids) async {
    final hasil = <String, int>{};
    for (final id in ids) {
      hasil[id] = await _transaksiOp.ambilTotalPoin(id);
    }
    return hasil;
  }

  Future<List<int>> getTotalPoinBanyakPelangganParallel(
    List<String> ids,
  ) async {
    final futures = ids.map((id) => _transaksiOp.ambilTotalPoin(id)).toList();
    return await Future.wait(futures);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadData);
  }

  void invalidateProviderTransaksi() {
    ref.invalidateSelf();
    ref.invalidate(riwayatTransaksiPelangganProvider);
  }
}

@Riverpod(keepAlive: true)
Future<({List<TransaksiModel> transaksi, int totalPoin})>
riwayatTransaksiPelanggan(Ref ref, String idPelanggan) async {
  Log.info(
    '[RiwayatTransaksi] 🔍 Mengambil riwayat transaksi untuk pelanggan: $idPelanggan',
  );
  try {
    final transaksiOp = ref.read(transaksiOpGlobalProvider);
    final results = await Future.wait([
      transaksiOp.ambilBerdasarkanIdPelanggan(idPelanggan),
      transaksiOp.ambilTotalPoin(idPelanggan),
    ]);
    final semuaTransaksi = results[0] as List<TransaksiModel>;
    final totalPoinUser = results[1] as int;
    Log.info('[RiwayatTransaksi] 📊 Total transaksi: ${semuaTransaksi.length}');
    Log.info('[RiwayatTransaksi] 🎯 Total poin: $totalPoinUser');
    return (transaksi: semuaTransaksi, totalPoin: totalPoinUser);
  } catch (e, s) {
    Log.error('[RiwayatTransaksi] ❌ ERROR: $e', e: e, s: s);
    rethrow;
  }
}

@riverpod
Future<List<TransaksiModel>> ambilBerdasarkanIdPelanggan(
  Ref ref,
  String idPelanggan,
) async {
  Log.info(
    '[RiwayatPoin] 🔍 Mengambil riwayat poin untuk pelanggan: $idPelanggan',
  );
  try {
    final transaksiOp = ref.read(transaksiOpGlobalProvider);
    final semuaTransaksi = await transaksiOp.ambilBerdasarkanIdPelanggan(
      idPelanggan,
    );
    Log.info('[RiwayatPoin] 📊 Total transaksi: ${semuaTransaksi.length}');
    return semuaTransaksi;
  } catch (e, s) {
    Log.error('[RiwayatPoin] ❌ ERROR: $e', e: e, s: s);
    rethrow;
  }
}
