// path: lib/fitur/statistik/operasi/statistik_op_sqlite.dart

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/admin/model/best_selling_package.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/feedback/operasi/feedback_operation.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/payment_status_enum.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/active_customer_operation.dart';
import 'package:wifi/fitur/paket/operasi/paket_op_Sqlite.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/transaction_operation.dart';

final statistikOpSliteProvider = Provider<StatistikOpSqlite>((ref) {
  Log.info('Membuat instance StatistikRepository melalui provider');
  return StatistikOpSqlite(
    pelangganAktifOpSqlite: ref.watch(pelangganAktifOpSqliteProvider),
    feedbackOpSqlite: ref.watch(feedbackOperationProvider),
    paketOpSqlite: ref.watch(paketOpSqliteProvider),
    transaksiOpSqlite: ref.watch(transaksiOpSqliteProvider),
  );
});

/// Repos
class StatistikOpSqlite {
  final PelangganAktifOpSqlite _pelangganAktifOpSqlite;
  final FeedbackOperation _statistikOpSliteProvider;
  final PaketOpSqlite _paketOpsqlite;
  final TransaksiOpsqlite _transaksiOpSlite;

  StatistikOpSqlite({
    required PelangganAktifOpSqlite pelangganAktifOpSqlite,
    required FeedbackOperation feedbackOpSqlite,
    required PaketOpSqlite paketOpSqlite,
    required TransaksiOpsqlite transaksiOpSqlite,
  })  : _pelangganAktifOpSqlite = pelangganAktifOpSqlite,
        _statistikOpSliteProvider = feedbackOpSqlite,
        _paketOpsqlite = paketOpSqlite,
        _transaksiOpSlite = transaksiOpSqlite;

  Future<List<BestSellingPackage>> ambilPaketTerlaris({int limit = 5}) async {
    Log.info('Mulai menghitung paket terlaris.');
    try {
      final daftarPaket = await _paketOpsqlite.ambilBerdasarkanAktif();
      final daftartransaksi = await _transaksiOpSlite.getAllTransactions();

      if (daftartransaksi.isEmpty) {
        Log.warning('Tidak ada transaksi, mengembalikan list paket kosong.');
        return [];
      }

      final jumlahPenjualan = daftartransaksi
          .where((t) => t.idPaket != null)
          .groupListsBy((t) => t.idPaket!)
          .map((key, value) => MapEntry(key, value.length));

      final paketTerlaris = daftarPaket.map((paket) {
        return BestSellingPackage(
          paket: paket,
          totalTerjual: jumlahPenjualan[paket.id] ?? 0,
        );
      }).toList();

      paketTerlaris.sort((a, b) => b.totalTerjual.compareTo(a.totalTerjual));

      final hasil = paketTerlaris.take(limit).toList();
      Log.info(
          'Berhasil menghitung ${hasil.length} paket terlaris: ${hasil.map((p) => '${p.paket.nama} (${p.totalTerjual})').toList()}');

      return hasil;
    } on Exception catch (e, st) {
      Log.error('Gagal menghitung paket terlaris.', e: e, s: st);
      rethrow;
    }
  }

  Future<double> ambilPendapatanBulanIni() async {
    Log.info(
        'Mulai mengambil pendapatan bersih (paid-unpaid) bulan ini dari SQLite.');
    try {
      final db = await SqliteDatabase.instance.database;
      const String namaTabel = '"${NamaTabel.transactions}"';
      final String statusLunas = PaymentStatus.paid.name;
      final String statusBelumLunas = PaymentStatus.unpaid.name;

      final List<Map<String, dynamic>> hasil = await db.rawQuery(
        '''
        SELECT SUM(
          CASE
            WHEN ${NamaKolom.statusPembayaran} = ? THEN ${NamaKolom.jumlah}
            WHEN ${NamaKolom.statusPembayaran} = ? THEN -${NamaKolom.jumlah}
            ELSE 0
          END
        ) as total
        FROM $namaTabel
        WHERE ${NamaKolom.diHapus} = 0
        ''',
        [statusLunas, statusBelumLunas],
      );

      Log.info('Query pendapatan bersih selesai. Hasil mentah: $hasil');

      if (hasil.isNotEmpty && hasil.first['total'] != null) {
        final total = (hasil.first['total'] as num).toDouble();
        Log.info('Total pendapatan bersih yang dihitung: $total');
        return total;
      } else {
        Log.info('Tidak ada transaksi ditemukan bulan ini, mengembalikan 0.0');
        return 0.0;
      }
    } catch (e, st) {
      Log.error('Gagal mengambil pendapatan bersih bulan ini dari SQLite.',
          e: e, s: st);
      rethrow;
    }
  }

  Future<int> ambilTotalPelanggan() async {
    Log.info('Mulai mengambil total jumlah pelanggan dari SQLite.');
    try {
      final db = await SqliteDatabase.instance.database;
      const String namaTabel = '"${NamaTabel.customer}"';

      final result = await db.rawQuery(
        '''
        SELECT COUNT(*) 
        FROM $namaTabel 
        WHERE ${NamaKolom.diHapus} = 0
        ''',
      );

      Log.info('Query total pelanggan selesai. Hasil mentah: $result');

      final total = Sqflite.firstIntValue(result) ?? 0;
      Log.info('Total pelanggan yang dihitung: $total');
      return total;
    } on Exception catch (e, st) {
      Log.error('Gagal mengambil total pelanggan dari SQLite.', e: e, s: st);
      rethrow;
    }
  }

  Future<int> ambilJumlahLanggananAktif() async {
    Log.info('Mulai mengambil jumlah langganan aktif.');
    try {
      final pelangganAktif = await _pelangganAktifOpSqlite.getALl();
      final total = pelangganAktif.length;
      Log.info('Jumlah langganan aktif yang dihitung: $total');
      return total;
    } on Exception catch (e, st) {
      Log.error('Gagal mengambil jumlah langganan aktif.', e: e, s: st);
      rethrow;
    }
  }

  Future<int> ambilJumlahFeedbackBaru() async {
    Log.info('Mulai mengambil jumlah feedback baru.');
    try {
      final listfeddbackAktif =
          await _statistikOpSliteProvider.getAllActiveFeedback();
      final count = listfeddbackAktif.length;
      Log.info('Jumlah feedback baru yang dihitung: $count');
      return count;
    } catch (e, st) {
      Log.error('Gagal mengambil jumlah feedback baru.', e: e, s: st);
      rethrow;
    }
  }
}
