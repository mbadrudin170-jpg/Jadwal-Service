// path: lib/fitur/transaksi/operasi_provider.dart/transaksi_provider.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/transaksi/enum/tipe_transaksi.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi_provider.dart/transaksi_op_provider.dart';
import 'package:wifi/shared/debug/log.dart';

part 'transaksi_provider.g.dart';
part 'transaksi_provider.freezed.dart';

class PaketTerlarisMentah {
  final String id;
  final int totalTerjual;
  const PaketTerlarisMentah(this.id, this.totalTerjual);
}

@freezed
abstract class TransaksiState with _$TransaksiState {
  const TransaksiState._();
  const factory TransaksiState({
    @Default(0.0) double totalPemasukan,
    @Default(0.0) double totalPengeluaran,
    @Default(0.0) double total,
    @Default(0) int totalPoinSemuaPelanggan,
    @Default([]) List<PaketTerlarisMentah> paketTerlaris,
    @Default([]) List<double> pendapatanHarian,
    @Default([]) List<double> pendapatanMingguan,
    @Default([]) List<double> pendapatanBulanan,
    @Default(0.0) double pendapatanBulanIni,
  }) = _TransaksiState;
}

@riverpod
class Transaksi extends _$Transaksi {
  @override
  FutureOr<TransaksiState> build() {
    return _loadData();
  }

  Future<TransaksiState> _loadData() async {
    try {
      final state = ref.watch(transaksiOpProvider).value;
      final list = state?.transaksi ?? [];
      final totalPemasukan = list
          .where(
            (t) =>
                t.tipe == TipeTransaksi.income &&
                t.statusPembayaran == StatusPembayaran.paid,
          )
          .fold(0.0, (sum, t) => sum + t.jumlah);
      final totalPengeluaran = list
          .where((t) => t.tipe == TipeTransaksi.expense)
          .fold(0.0, (sum, t) => sum + t.jumlah);
      final total = totalPemasukan - totalPengeluaran;
      final totalPoinSemuaPelanggan = list.fold<int>(
        0,
        (sum, t) => sum + (t.poinDidapat - t.poinDigunakan),
      );
      final paketTerlaris = _hitungPaketTerlaris(list);
      final pendapatanHarian = _hitungPendapatanHarian(list);
      final pendapatanMingguan = _hitungPendapatanMingguan(list);
      final pendapatanBulanan = _hitungPendapatanBulanan(list);
      final pendapatanBulanIni = _hitungPendapatanBulanIni(list);
      return TransaksiState(
        totalPemasukan: totalPemasukan,
        totalPengeluaran: totalPengeluaran,
        total: total,
        totalPoinSemuaPelanggan: totalPoinSemuaPelanggan,
        paketTerlaris: paketTerlaris,
        pendapatanHarian: pendapatanHarian,
        pendapatanMingguan: pendapatanMingguan,
        pendapatanBulanan: pendapatanBulanan,
        pendapatanBulanIni: pendapatanBulanIni,
      );
    } on Exception catch (e, s) {
      Log.error('Error di Load_loadData(: $e', e: e, s: s);
      rethrow;
    }
  }

  // --- HELPER METODE UNTUK MEMPROSES GRAFIK & STATISTIK ---

  List<PaketTerlarisMentah> _hitungPaketTerlaris(List<TransaksiModel> list) {
    final jumlahPerPaket = <String, int>{};
    for (final t in list) {
      if (t.idPaket != null && t.statusPembayaran == StatusPembayaran.paid) {
        jumlahPerPaket[t.idPaket!] = (jumlahPerPaket[t.idPaket!] ?? 0) + 1;
      }
    }
    final sortedEntries = jumlahPerPaket.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedEntries
        .take(5)
        .map((e) => PaketTerlarisMentah(e.key, e.value))
        .toList();
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
      hasil[6 - i] = totalHariItu;
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

      hasil[3 - i] = totalMingguItu;
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
      hasil[4 - i] = totalBulanItu;
    }
    return hasil;
  }

  double _hitungPendapatanBulanIni(List<TransaksiModel> list) {
    final sekarang = DateTime.now();
    return list
        .where(
          (t) =>
              t.tipe == TipeTransaksi.income &&
              t.statusPembayaran == StatusPembayaran.paid &&
              t.tanggal.month == sekarang.month &&
              t.tanggal.year == sekarang.year,
        )
        .fold(0.0, (sum, t) => sum + t.jumlah);
  }

  Future<({List<TransaksiModel> transaksi, int totalPoin})>
  riwayatTransaksiPelanggan(String idPelanggan) async {
    Log.info(
      '[RiwayatTransaksi] 🔍 Mengambil riwayat transaksi untuk pelanggan: $idPelanggan',
    );
    try {
      // Dapatkan state terbaru dari TransaksiOp (AsyncNotifier)
      final notifierState = await ref.watch(transaksiOpProvider.future);

      // Filter transaksi yang dimiliki pelanggan ini
      final semuaTransaksi = notifierState.transaksi
          .where((t) => t.idPelanggan == idPelanggan)
          .toList();
      final totalPoinUser = semuaTransaksi
          .where((t) => t.statusPembayaran == StatusPembayaran.paid)
          .fold<int>(0, (sum, t) => sum + (t.poinDidapat - t.poinDigunakan));
      return (transaksi: semuaTransaksi, totalPoin: totalPoinUser);
    } catch (e, s) {
      Log.error('[RiwayatTransaksi] ❌ ERROR: $e', e: e, s: s);
      rethrow;
    }
  }
}
