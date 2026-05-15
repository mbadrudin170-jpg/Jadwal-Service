// path: lib/shared/operasi/dompet_operasi.dart
// diubah: Menggunakan DateTime.now().toUtc() untuk konsistensi waktu.
// diubah: Menambahkan konstruktor yang dapat diinjeksi untuk pengujian.

import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/dompet_model.dart';
import 'package:wifi/shared/operasi/operasi_dasar.dart';

/// Kelas untuk operasi terkait data dompet di database lokal.
class DompetOperasi {
  /// Instance dari DatabaseHelper untuk mengakses database.
  late final DatabaseHelper dbHelper;
  late final OperasiDasar _operasiDasar;

  /// Konstruktor dengan injeksi dependensi untuk pengujian.
  DompetOperasi({final DatabaseHelper? dbHelper, final OperasiDasar? operasiDasar}) 
    : dbHelper = dbHelper ?? DatabaseHelper.instance,
      _operasiDasar = operasiDasar ?? OperasiDasar();


  /// Menyimpan [DompetModel] baru ke dalam database.
  ///
  /// [dariServer] menandakan apakah operasi ini berasal dari sinkronisasi server.
  Future<void> createDompet(
    final DompetModel dompet, {
    final bool dariServer = false,
  }) async {
    Log.info('Memulai createDompet untuk dompet: ${dompet.toSqlite()}');
    try {
      final data =
          dompet.copyWith(diperbarui: DateTime.now().toUtc()).toSqlite();
      await _operasiDasar.sisipkan('dompet', data, dariServer: dariServer);
      Log.info('Berhasil membuat dompet dengan ID data: ${dompet.id}');
    } catch (e, st) {
      Log.error('Gagal saat createDompet', e: e, st: st);
      rethrow;
    }
  }

  /// Mengambil semua dompet dari database.
  ///
  /// Jika [tampilkanDiarsipkan] `true`, maka dompet yang telah diarsipkan juga akan diambil.
  Future<List<DompetModel>> getDompet({
    final bool tampilkanDiarsipkan = false,
  }) async {
    Log.info(
      'Memulai getDompet (tampilkanDiarsipkan: $tampilkanDiarsipkan).',
    );
    try {
      final db = await dbHelper.database;
      final query = tampilkanDiarsipkan
          ? 'isDeleted = 0'
          : 'isDeleted = 0 AND diarsipkan IS NULL';
      final List<Map<String, dynamic>> maps = await db.query(
        'dompet',
        where: query,
      );

      final listDompet = List.generate(
        maps.length,
        (final i) => DompetModel.fromSqlite(maps[i]),
      );
      Log.info('Berhasil mengambil ${listDompet.length} data dompet.');
      return listDompet;
    } catch (e, st) {
      Log.error('Gagal saat getDompet', e: e, st: st);
      rethrow;
    }
  }

  /// Mengambil [DompetModel] berdasarkan [id].
  Future<DompetModel?> getDompetById(final String id) async {
    Log.info('Memulai getDompetById untuk ID: $id');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'dompet',
        where: 'id = ? AND isDeleted = 0',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        final dompet = DompetModel.fromSqlite(maps.first);
        Log.info('Dompet dengan ID: $id ditemukan. Data: ${dompet.toSqlite()}');
        return dompet;
      }

      Log.warning('Dompet dengan ID: $id tidak ditemukan di database.');
      return null;
    } catch (e, st) {
      Log.error(
        'Gagal saat getDompetById untuk ID: $id',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Memperbarui [DompetModel] yang ada di database.
  Future<void> updateDompet(
    final DompetModel dompet, {
    final bool dariServer = false,
  }) async {
    Log.info('Memulai updateDompet untuk dompet: ${dompet.toSqlite()}');
    try {
      final data =
          dompet.copyWith(diperbarui: DateTime.now().toUtc()).toSqlite();
      await _operasiDasar.perbarui(
        'dompet',
        data,
        dompet.id,
        dariServer: dariServer,
      );
      Log.info('Berhasil updateDompet untuk ID: ${dompet.id}.');
    } catch (e, st) {
      Log.error(
        'Gagal saat updateDompet untuk ID: ${dompet.id}',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Mengarsipkan semua dompet yang aktif.
  Future<void> arsipSemuaDompet({final bool dariServer = false}) async {
    Log.info('Memulai proses pengarsipan untuk semua dompet.');
    try {
      final daftarDompetAktif = await getDompet();
      Log.info(
        'Ditemukan ${daftarDompetAktif.length} dompet aktif untuk diarsipkan.',
      );

      for (final dompet in daftarDompetAktif) {
        await updateDompet(
          dompet.copyWith(diarsipkan: DateTime.now().toUtc()),
          dariServer: dariServer,
        );
      }

      Log.info('Proses pengarsipan semua dompet telah selesai.');
    } catch (e, st) {
      Log.error(
        'Gagal saat proses pengarsipan massal dompet.',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Menghapus semua dompet dari database secara permanen.
  Future<void> hapusSemuaDompet({final bool dariServer = false}) async {
    Log.warning(
      'PERINGATAN: Memulai hapusSemuaDompet. Ini adalah operasi destruktif.',
    );
    try {
      await _operasiDasar.jalankanOperasiKompleks(
        (final txn) async {
          final count = await txn.delete('dompet');
          Log.info(
            'Berhasil hapusSemuaDompet. Total baris yang dihapus: $count',
          );
        },
        dariServer: dariServer,
      );
    } catch (e, st) {
      Log.error('Gagal saat hapusSemuaDompet', e: e, st: st);
      rethrow;
    }
  }

  /// Mengarsipkan satu dompet berdasarkan [id] (soft delete).
  Future<void> arsipkanSatuDompet(final String id, {final bool dariServer = false}) async {
    Log.info('Memulai arsipkanSatuDompet (soft delete) untuk ID: $id');
    try {
      final now = DateTime.now().toUtc();
      final Map<String, dynamic> dataToUpdate = {
        'diarsipkan': now.millisecondsSinceEpoch,
        'diperbarui': now.millisecondsSinceEpoch,
        'isDeleted': 1,
      };

      await _operasiDasar.perbarui(
        'dompet',
        dataToUpdate,
        id,
        dariServer: dariServer,
      );

      Log.info('Berhasil arsipkanSatuDompet untuk ID: $id.');
    } catch (e, st) {
      Log.error(
        'Gagal saat arsipkanSatuDompet untuk ID: $id',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Menghitung total saldo dari semua dompet aktif.
  Future<double> getTotalSaldo() async {
    Log.info(
      'Memulai getTotalSaldo (menghitung total saldo dari semua dompet aktif).',
    );
    try {
      final db = await dbHelper.database;
      final result = await db.rawQuery(
        'SELECT SUM(saldo) as total FROM dompet WHERE isDeleted = 0',
      );

      double total = 0.0;
      if (result.isNotEmpty && result.first['total'] != null) {
        total = (result.first['total'] as num).toDouble();
      }

      Log.info('Berhasil menghitung total saldo: $total');
      return total;
    } catch (e, st) {
      Log.error('Gagal saat getTotalSaldo', e: e, st: st);
      rethrow;
    }
  }

  /// Menghitung total saldo positif dari semua dompet aktif.
  Future<double> getTotalSaldoPositif() async {
    Log.info(
      'Memulai getTotalSaldoPositif (menghitung total saldo > 0 dari dompet aktif).',
    );
    try {
      final db = await dbHelper.database;
      final result = await db.rawQuery(
        'SELECT SUM(saldo) as total FROM dompet WHERE saldo > 0 AND isDeleted = 0',
      );

      double total = 0.0;
      if (result.isNotEmpty && result.first['total'] != null) {
        total = (result.first['total'] as num).toDouble();
      }

      Log.info('Berhasil menghitung total saldo positif: $total');
      return total;
    } catch (e, st) {
      Log.error('Gagal saat getTotalSaldoPositif', e: e, st: st);
      rethrow;
    }
  }

  /// Menghitung total saldo negatif dari semua dompet aktif.
  Future<double> getTotalSaldoNegatif() async {
    Log.info(
      'Memulai getTotalSaldoNegatif (menghitung total saldo < 0 dari dompet aktif).',
    );
    try {
      final db = await dbHelper.database;
      final result = await db.rawQuery(
        'SELECT SUM(saldo) as total FROM dompet WHERE saldo < 0 AND isDeleted = 0',
      );

      double total = 0.0;
      if (result.isNotEmpty && result.first['total'] != null) {
        total = (result.first['total'] as num).toDouble();
      }

      Log.info('Berhasil menghitung total saldo negatif: $total');
      return total;
    } catch (e, st) {
      Log.error('Gagal saat getTotalSaldoNegatif', e: e, st: st);
      rethrow;
    }
  }

  /// Menyisipkan atau memperbarui sekumpulan dompet dalam satu batch.
  Future<void> sisipkanAtauPerbaruiBatch(
    final List<DompetModel> items, {
    final bool dariServer = false,
  }) async {
    Log.info(
      'Memulai sisipkanAtauPerbaruiBatch untuk ${items.length} item dompet.',
    );
    if (items.isEmpty) {
      Log.warning(
        'List item untuk batch kosong, tidak ada operasi yang dilakukan.',
      );
      return;
    }
    try {
      final data = items.map((final item) => item.toSqlite()).toList();
      await _operasiDasar.sisipkanAtauPerbaruiBatch(
        'dompet',
        data,
        dariServer: dariServer,
      );
      Log.info(
        'Berhasil menyelesaikan sisipkanAtauPerbaruiBatch untuk ${items.length} item.',
      );
    } catch (e, st) {
      Log.error(
        'Gagal saat menjalankan sisipkanAtauPerbaruiBatch',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Mengambil beberapa [DompetModel] berdasarkan daftar [ids].
  Future<List<DompetModel>> getDompetByIds(final List<String> ids) async {
    Log.info('Memulai getDompetByIds untuk ${ids.length} ID.');
    if (ids.isEmpty) {
      Log.warning(
        'List ID untuk getDompetByIds kosong, mengembalikan list kosong.',
      );
      return [];
    }
    try {
      final db = await dbHelper.database;
      final placeholders = List.filled(ids.length, '?').join(',');
      final List<Map<String, dynamic>> maps = await db.query(
        'dompet',
        where: 'id IN ($placeholders)',
        whereArgs: ids,
      );

      final listDompet = List.generate(
        maps.length,
        (final i) => DompetModel.fromSqlite(maps[i]),
      );
      Log.info(
        'Berhasil mengambil ${listDompet.length} dompet dari ${ids.length} ID yang diminta.',
      );
      return listDompet;
    } catch (e, st) {
      Log.error('Gagal saat getDompetByIds', e: e, st: st);
      rethrow;
    }
  }
}
