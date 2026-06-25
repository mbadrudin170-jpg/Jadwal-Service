// path: lib/fitur/statistik/operasi/statistik_op_sqlite.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/feedback/operasi/feedback_op_sqlite.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';

final statistikOpSliteProvider = Provider<StatistikOpSqlite>((ref) {
  Log.info('Membuat instance StatistikRepository melalui provider');
  return StatistikOpSqlite(
    feedbackOpSqlite: ref.watch(feedbackOpSqliteProvider),
  );
});

/// Repos
class StatistikOpSqlite {
  final FeedbackOpSqlite _statistikOpSliteProvider;

  StatistikOpSqlite({
    required FeedbackOpSqlite feedbackOpSqlite,
  }) : _statistikOpSliteProvider = feedbackOpSqlite;


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
