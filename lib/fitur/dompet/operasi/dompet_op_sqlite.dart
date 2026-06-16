// path: lib/fitur/dompet/operasi/dompet_op_sqlite.dart

import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/dompet/model/dompet_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_op_sqlite.dart';

/// Kelas untuk operasi terkait data dompet di database lokal.
class DompetOpSqlite {
  final SqliteDatabase sqliteDb;
  final BaseOpSqlite _baseOperation;
  final String _tabelDompet = NamaTabel.dompet;
  final _nowUtc = DateTime.now().toUtc();

  /// Konstruktor dengan injeksi dependensi untuk pengujian.
  DompetOpSqlite({
    required this.sqliteDb,
    required final BaseOpSqlite baseOpSqlite,
  }) : _baseOperation = baseOpSqlite;

  Future<void> tambahDompet(
    final DompetModel wallet, {
    final bool fromServer = false,
  }) async {
    Log.info('Memulai tambahDompet untuk wallet: ${wallet.id}');
    try {
      final data = wallet.copyWith(diperbaruiPada: _nowUtc).toSqlite();
      await _baseOperation.sisipkan(
        _tabelDompet,
        data,
        dariServer: fromServer,
      );
      Log.info('Berhasil membuat wallet dengan ID: ${wallet.id}');
    } on Exception catch (e, st) {
      Log.error('Gagal saat tambahDompet', e: e, s: st);
      rethrow;
    }
  }

  /// Mengambil semua dompet dari database.
  ///
  /// Jika [showArchived] `true`, maka dompet yang telah diarsipkan juga akan diambil.
  Future<List<DompetModel>> ambilSemua({
    final bool showArchived = false,
  }) async {
    Log.info('Memulai getWallets (showArchived: $showArchived).');
    try {
      final db = await sqliteDb.database;
      final query = showArchived
          ? null
          : '${NamaKolom.dihapus} = 0 AND ${NamaKolom.diarsipkanPada} IS NULL';
      final List<Map<String, dynamic>> maps = await db.query(
        _tabelDompet,
        where: query,
      );

      final listWallet = List.generate(
        maps.length,
        (final i) => DompetModel.fromSqlite(maps[i]),
      );
      Log.info('Berhasil mengambil ${listWallet.length} data wallet.');
      return listWallet;
    } on Exception catch (e, st) {
      Log.error('Gagal saat getWallets', e: e, s: st);
      rethrow;
    }
  }

  /// Mengambil [DompetModel] berdasarkan [id].
  Future<DompetModel?> ambilBerdasarkanId(final String id) async {
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
      Log.error(
        'Gagal saat getById untuk ID: $id',
        e: e,
        s: st,
      );
      rethrow;
    }
  }

  /// Memperbarui [DompetModel] yang ada di database.
  Future<void> updateDompet(
    final DompetModel wallet, {
    final bool fromServer = false,
  }) async {
    Log.info('Memulai updateDompet untuk wallet ID: ${wallet.id}');
    try {
      final data = wallet.copyWith(diarsipkanPada: _nowUtc).toSqlite();
      await _baseOperation.update(
        _tabelDompet,
        data,
        wallet.id,
        dariServer: fromServer,
      );
      Log.info('Berhasil updateDompet untuk ID: ${wallet.id}.');
    } on Exception catch (e, st) {
      Log.error(
        'Gagal saat updateDompet untuk ID: ${wallet.id}',
        e: e,
        s: st,
      );
      rethrow;
    }
  }

  /// Melakukan soft delete pada satu dompet berdasarkan [id].
  Future<void> softDelete(final String id,
      {final bool fromServer = false}) async {
    Log.info('Memulai soft delete untuk wallet ID: $id');
    try {
      await _baseOperation.softDelete(
        _tabelDompet,
        id,
        dariServer: fromServer,
      );
      Log.info('Berhasil soft delete wallet ID: $id.');
    } catch (e, st) {
      Log.error(
        'Gagal saat soft delete wallet ID: $id',
        e: e,
        s: st,
      );
      rethrow;
    }
  }

  /// Melakukan soft delete pada semua dompet.
  Future<int> softDeleteAll({
    final bool fromServer = false,
  }) async {
    Log.info('Memulai soft delete untuk semua dompet');
    try {
      final count = await _baseOperation.softDeleteAll(
        _tabelDompet,
        dariServer: fromServer,
      );
      Log.info('Berhasil soft delete semua dompet. Total: $count item.');
      return count;
    } catch (e, st) {
      Log.error(
        'Gagal saat soft delete semua dompet',
        e: e,
        s: st,
      );
      rethrow;
    }
  }

  /// Menghitung total saldo dari semua dompet aktif.
  Future<double> ambilTotalsaldo() async {
    Log.info(
        'Memulai ambilTotalsaldo (menghitung total saldo dari semua wallet aktif).');
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

  /// Menghitung total saldo positif dari semua dompet aktif.
  Future<double> ambilSaldoPositif() async {
    Log.info(
        'Memulai ambilSaldoPositif (menghitung total saldo > 0 dari wallet aktif).');
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

  /// Menghitung total saldo negatif dari semua dompet aktif.
  Future<double> ambilSaldoNegatif() async {
    Log.info(
        'Memulai ambilSaldoNegatif (menghitung total saldo < 0 dari wallet aktif).');
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

  /// Menyisipkan atau memperbarui sekumpulan dompet dalam satu batch.
  Future<void> sisipkanAtauPerbaruiBatch(
    final List<DompetModel> items, {
    final bool dariServer = false,
  }) async {
    Log.info('Memulai batch insert/update untuk ${items.length} data dompet.');
    if (items.isEmpty) {
      Log.warning('Daftar dompet kosong, membatalkan operasi batch.');
      return;
    }
    try {
      final data = items
          .map(
            (final item) => item.copyWith(diperbaruiPada: _nowUtc).toSqlite(),
          )
          .toList();
      await _baseOperation.sisipkanAtauPerbaruiBatch(
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
