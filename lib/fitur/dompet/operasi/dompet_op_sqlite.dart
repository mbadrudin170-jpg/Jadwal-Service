// path: lib/fitur/dompet/operasi/dompet_op_sqlite.dart

import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/dompet/model/dompet_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_op_sqlite.dart';

class DompetOpSqlite {
  final SqliteDatabase sqliteDb;
  final BaseOpSqlite _baseOpSqlite;
  final String _tabelDompet = NamaTabel.dompet;
  final _nowUtc = DateTime.now().toUtc();

  DompetOpSqlite({
    required this.sqliteDb,
    required final BaseOpSqlite baseOpSqlite,
  }) : _baseOpSqlite = baseOpSqlite;

  Future<void> tambahDompet(
    final DompetModel dompet, {
    final bool dariServer = false,
  }) async {
    Log.info('Memulai tambahDompet untuk wallet: ${dompet.id}');
    try {
      final data = dompet.copyWith(diperbaruiPada: _nowUtc).toSqlite();
      await _baseOpSqlite.sisipkan(_tabelDompet, data, dariServer: dariServer);
      Log.info('Berhasil membuat wallet dengan ID: ${dompet.id}');
    } on Exception catch (e, st) {
      Log.error('Gagal saat tambahDompet', e: e, s: st);
      rethrow;
    }
  }

  Future<List<DompetModel>> ambilSemua({
    bool tampilkanYangDiarsip = false,
  }) async {
    Log.info('Memulai getWallets (showArchived: $tampilkanYangDiarsip).');
    try {
      final db = await sqliteDb.database;
      final query = tampilkanYangDiarsip
          ? null
          : '${NamaKolom.dihapus} = 0 AND ${NamaKolom.diarsipkanPada} IS NULL';
      final List<Map<String, dynamic>> maps = await db.query(
        _tabelDompet,
        where: query,
      );

      final daftarDompet = List.generate(
        maps.length,
        (i) => DompetModel.fromSqlite(maps[i]),
      );
      Log.info('Berhasil mengambil ${daftarDompet.length} data wallet.');
      return daftarDompet;
    } catch (e, st) {
      Log.error('Gagal saat getWallets', e: e, s: st);
      rethrow;
    }
  }

  Future<DompetModel?> ambilBerdasarkanId(String id) async {
    Log.info('Memulai getById untuk ID: $id');
    try {
      final db = await sqliteDb.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tabelDompet,
        where: '${NamaKolom.id} = ? AND ${NamaKolom.dihapus} = 0',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        final wallet = DompetModel.fromSqlite(maps.first);
        Log.info('Wallet dengan ID: $id ditemukan.');
        return wallet;
      }

      Log.warning('Wallet dengan ID: $id tidak ditemukan di database.');
      return null;
    } on Exception catch (e, st) {
      Log.error('Gagal saat getById untuk ID: $id', e: e, s: st);
      rethrow;
    }
  }

  Future<void> updateDompet(DompetModel wallet) async {
    Log.info('Memulai updateDompet untuk wallet ID: ${wallet.id}');
    try {
      final data = wallet.copyWith(diperbaruiPada: _nowUtc).toSqlite();
      await _baseOpSqlite.update(_tabelDompet, data, wallet.id);
      Log.info('Berhasil updateDompet untuk ID: ${wallet.id}.');
    } on Exception catch (e, st) {
      Log.error('Gagal saat updateDompet untuk ID: ${wallet.id}', e: e, s: st);
      rethrow;
    }
  }

  Future<void> softDelete(String id, {bool dariServer = false}) async {
    Log.info('Memulai soft delete untuk wallet ID: $id');
    try {
      await _baseOpSqlite.softDelete(_tabelDompet, id, dariServer: dariServer);
      Log.info('Berhasil soft delete wallet ID: $id.');
    } catch (e, st) {
      Log.error('Gagal saat soft delete wallet ID: $id', e: e, s: st);
      rethrow;
    }
  }

  Future<int> softDeleteAll({bool dariServer = false}) async {
    Log.info('Memulai soft delete untuk semua dompet');
    try {
      final count = await _baseOpSqlite.softDeleteAll(
        _tabelDompet,
        dariServer: dariServer,
      );
      Log.info('Berhasil soft delete semua dompet. Total: $count item.');
      return count;
    } catch (e, st) {
      Log.error('Gagal saat soft delete semua dompet', e: e, s: st);
      rethrow;
    }
  }

  Future<double> ambilTotalsaldo() async {
    Log.info(
      'Memulai ambilTotalsaldo (menghitung total saldo dari semua wallet aktif).',
    );
    try {
      final db = await sqliteDb.database;
      final result = await db.rawQuery(
        'SELECT SUM(${NamaKolom.saldo}) as total FROM $_tabelDompet WHERE ${NamaKolom.dihapus} = 0',
      );

      double total = 0.0;
      if (result.isNotEmpty && result.first['total'] != null) {
        total = (result.first['total'] as num).toDouble();
      }

      Log.info('Berhasil menghitung total saldo: $total');
      return total;
    } on Exception catch (e, st) {
      Log.error('Gagal saat ambilTotalsaldo', e: e, s: st);
      rethrow;
    }
  }

  Future<double> ambilSaldoPositif() async {
    Log.info(
      'Memulai ambilSaldoPositif (menghitung total saldo > 0 dari wallet aktif).',
    );
    try {
      final db = await sqliteDb.database;
      final result = await db.rawQuery(
        'SELECT SUM(${NamaKolom.saldo}) as total FROM $_tabelDompet WHERE ${NamaKolom.saldo} > 0 AND ${NamaKolom.dihapus} = 0',
      );

      double total = 0.0;
      if (result.isNotEmpty && result.first['total'] != null) {
        total = (result.first['total'] as num).toDouble();
      }

      Log.info('Berhasil menghitung total saldo positif: $total');
      return total;
    } on Exception catch (e, st) {
      Log.error('Gagal saat ambilSaldoPositif', e: e, s: st);
      rethrow;
    }
  }

  Future<double> ambilSaldoNegatif() async {
    Log.info(
      'Memulai ambilSaldoNegatif (menghitung total saldo < 0 dari wallet aktif).',
    );
    try {
      final db = await sqliteDb.database;
      final result = await db.rawQuery(
        'SELECT SUM(${NamaKolom.saldo}) as total FROM $_tabelDompet WHERE ${NamaKolom.saldo} < 0 AND ${NamaKolom.dihapus} = 0',
      );

      double total = 0.0;
      if (result.isNotEmpty && result.first['total'] != null) {
        total = (result.first['total'] as num).toDouble();
      }

      Log.info('Berhasil menghitung total saldo negatif: $total');
      return total;
    } on Exception catch (e, st) {
      Log.error('Gagal saat ambilSaldoNegatif', e: e, s: st);
      rethrow;
    }
  }

  Future<void> sisipkanAtauPerbaruiBatch(
    final List<DompetModel> daftarDompet, {
    final bool dariServer = false,
  }) async {
    Log.info(
      'Memulai batch insert/update untuk ${daftarDompet.length} data dompet.',
    );
    if (daftarDompet.isEmpty) {
      Log.warning('Daftar dompet kosong, membatalkan operasi batch.');
      return;
    }
    try {
      final data = daftarDompet
          .map((item) => item.copyWith(diperbaruiPada: _nowUtc).toSqlite())
          .toList();
      await _baseOpSqlite.sisipkanAtauPerbaruiBatch(
        _tabelDompet,
        data,
        dariServer: dariServer,
      );
      Log.info('Batch dompet selesai diproses.');
    } on Exception catch (e, st) {
      Log.error('Gagal menjalankan batch dompet', e: e, s: st);
      rethrow;
    }
  }
}
