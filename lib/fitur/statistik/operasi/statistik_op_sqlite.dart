// path: lib/fitur/statistik/operasi/statistik_op_sqlite.dart

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/feedback/operasi/feedback_op_sqlite.dart';
import 'package:wifi/fitur/paket/operasi/paket_op_sqlite.dart';
import 'package:wifi/fitur/pelanggan_aktif/operasi/pelanggan_aktif_op_sqlite.dart';
import 'package:wifi/fitur/statistik/model/paket_terlaris_model.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_sqlite.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';

final statistikOpSliteProvider = Provider<StatistikOpSqlite>((ref) {
  Log.info('Membuat instance StatistikRepository melalui provider');
  return StatistikOpSqlite(
    pelangganAktifOpSqlite: ref.watch(pelangganAktifOpSqliteProvider),
    feedbackOpSqlite: ref.watch(feedbackOpSqliteProvider),
    paketOpSqlite: ref.watch(paketOpSqliteProvider),
    transaksiOpSqlite: ref.watch(transaksiOpSqliteProvider),
  );
});

/// Repos
class StatistikOpSqlite {
  final PelangganAktifOpSqlite _pelangganAktifOpSqlite;
  final FeedbackOpSqlite _statistikOpSliteProvider;
  final PaketOpSqlite _paketOpsqlite;
  final TransaksiOpSqlite _transaksiOpSqlite;

  StatistikOpSqlite({
    required PelangganAktifOpSqlite pelangganAktifOpSqlite,
    required FeedbackOpSqlite feedbackOpSqlite,
    required PaketOpSqlite paketOpSqlite,
    required TransaksiOpSqlite transaksiOpSqlite,
  }) : _pelangganAktifOpSqlite = pelangganAktifOpSqlite,
       _statistikOpSliteProvider = feedbackOpSqlite,
       _paketOpsqlite = paketOpSqlite,
       _transaksiOpSqlite = transaksiOpSqlite;

  Future<List<PaketTerlarisModel>> ambilPaketTerlaris({int limit = 5}) async {
    Log.info('Mulai menghitung paket terlaris.');
    try {
      final daftarPaket = await _paketOpsqlite.ambilSemua();
      final daftartransaksi = await _transaksiOpSqlite.ambilSemua();

      if (daftartransaksi.isEmpty) {
        Log.warning('Tidak ada transaksi, mengembalikan list paket kosong.');
        return [];
      }

      final jumlahPenjualan = daftartransaksi
          .where((t) => t.idPaket != null)
          .groupListsBy((t) => t.idPaket!)
          .map((key, value) => MapEntry(key, value.length));

      final paketTerlaris = daftarPaket.map((paket) {
        return PaketTerlarisModel(
          paket: paket,
          totalTerjual: jumlahPenjualan[paket.id] ?? 0,
        );
      }).toList();

      paketTerlaris.sort((a, b) => b.totalTerjual.compareTo(a.totalTerjual));

      final hasil = paketTerlaris.take(limit).toList();
      Log.info(
        'Berhasil menghitung ${hasil.length} paket terlaris: ${hasil.map((p) => '${p.paket.nama} (${p.totalTerjual})').toList()}',
      );

      return hasil;
    } catch (e, st) {
      Log.error('Gagal menghitung paket terlaris.', e: e, s: st);
      rethrow;
    }
  }

  Future<double> ambilTotalPendapatan() async {
    try {
      final db = await SqliteDatabase.instance.database;
      const String namaTabel = '"${NamaTabel.transaksi}"';
      final String statusLunas = StatusPembayaran.paid.name;
      final String statusBelumLunas = StatusPembayaran.unpaid.name;

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
        WHERE ${NamaKolom.dihapus} = 0
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
      Log.error(
        'Gagal mengambil pendapatan bersih bulan ini dari SQLite.',
        e: e,
        s: st,
      );
      rethrow;
    }
  }

  Future<int> ambilTotalPelanggan() async {
    Log.info('Mulai mengambil total jumlah pelanggan dari SQLite.');
    try {
      final db = await SqliteDatabase.instance.database;
      const String namaTabel = '"${NamaTabel.pelanggan}"';

      final hasil = await db.rawQuery('''
        SELECT COUNT(*) 
        FROM $namaTabel 
        WHERE ${NamaKolom.dihapus} = 0
        ''');

      Log.info('Query total pelanggan selesai. Hasil mentah: $hasil');

      final jumlah = Sqflite.firstIntValue(hasil) ?? 0;
      Log.info('Total pelanggan yang dihitung: $jumlah');
      return jumlah;
    } catch (e, st) {
      Log.error('Gagal mengambil total pelanggan dari SQLite.', e: e, s: st);
      rethrow;
    }
  }

  Future<int> ambilJumlahLanggananAktif() async {
    Log.info('Mulai mengambil jumlah langganan aktif.');
    try {
      final pelangganAktif = await _pelangganAktifOpSqlite.ambilSemua();
      final jumlah = pelangganAktif.length;
      Log.info('Jumlah langganan aktif yang dihitung: $jumlah');
      return jumlah;
    } catch (e, st) {
      Log.error('Gagal mengambil jumlah langganan aktif.', e: e, s: st);
      rethrow;
    }
  }

  Future<int> ambilTotalFeedback() async {
    Log.info('Mulai mengambil jumlah feedback baru.');
    try {
      final daftarFeedbackAktif = await _statistikOpSliteProvider
          .ambilSemuaFeedbackAktif();
      final jumlah = daftarFeedbackAktif.length;
      Log.info('Jumlah feedback baru yang dihitung: $jumlah');
      return jumlah;
    } catch (e, st) {
      Log.error('Gagal mengambil jumlah feedback baru.', e: e, s: st);
      rethrow;
    }
  }
}
