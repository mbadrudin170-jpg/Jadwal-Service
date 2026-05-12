// path: lib/data/operasi/dompet_operasi.dart
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/dompet_model.dart';
import 'package:wifi/shared/operasi/operasi_dasar.dart';

class DompetOperasi {
  final dbHelper = DatabaseHelper.instance;
  final OperasiDasar _operasiDasar = OperasiDasar();

  Future<void> createDompet(DompetModel dompet) async {
    Log.info('Memulai createDompet untuk dompet: ${dompet.toSqlite()}');
    try {
      final data = dompet.copyWith(diperbarui: DateTime.now()).toSqlite();
      await _operasiDasar.sisipkan('dompet', data);
      Log.info('Berhasil membuat dompet dengan ID data: ${dompet.id}');
    } catch (e, st) {
      Log.error('Gagal saat createDompet', e: e, st: st);
      rethrow;
    }
  }

  // diubah: Menambahkan parameter untuk memfilter dompet yang diarsipkan
  Future<List<DompetModel>> getDompet(
      {bool tampilkanDiarsipkan = false}) async {
    Log.info(
      'Memulai getDompet (tampilkanDiarsipkan: $tampilkanDiarsipkan).',
    );
    try {
      final db = await dbHelper.database;
      // diubah: query disesuaikan berdasarkan parameter
      final query = tampilkanDiarsipkan
          ? 'isDeleted = 0'
          : 'isDeleted = 0 AND diarsipkan IS NULL';
      final List<Map<String, dynamic>> maps = await db.query(
        'dompet',
        where: query,
      );

      final listDompet = List.generate(
        maps.length,
        (i) => DompetModel.fromSqlite(maps[i]),
      );
      Log.info('Berhasil mengambil ${listDompet.length} data dompet.');
      return listDompet;
    } catch (e, st) {
      Log.error('Gagal saat getDompet', e: e, st: st);
      rethrow;
    }
  }

  Future<DompetModel?> getDompetById(String id) async {
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

  Future<void> updateDompet(DompetModel dompet) async {
    Log.info('Memulai updateDompet untuk dompet: ${dompet.toSqlite()}');
    try {
      final data = dompet.copyWith(diperbarui: DateTime.now()).toSqlite();
      await _operasiDasar.perbarui('dompet', data, dompet.id);
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

  // ditambah: Fungsi baru untuk mengarsipkan semua dompet
  /// Mengarsipkan semua dompet yang belum diarsipkan.
  Future<void> arsipSemuaDompet() async {
    Log.info('Memulai proses pengarsipan untuk semua dompet.');
    try {
      // 1. Ambil semua dompet yang aktif (belum diarsipkan)
      final daftarDompetAktif = await getDompet(tampilkanDiarsipkan: false);
      Log.info(
          'Ditemukan ${daftarDompetAktif.length} dompet aktif untuk diarsipkan.');

      // 2. Loop melalui setiap dompet dan arsipkan
      for (final dompet in daftarDompetAktif) {
        // 3. Panggil `updateDompet` untuk mengarsipkan satu per satu
        await updateDompet(dompet.copyWith(diarsipkan: DateTime.now()));
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

  Future<void> hapusSemuaDompet() async {
    Log.warning(
      'PERINGATAN: Memulai hapusSemuaDompet. Ini adalah operasi destruktif yang akan menghapus semua dompet secara permanen.',
    );
    try {
      await _operasiDasar.jalankanOperasiKompleks((txn) async {
        final count = await txn.delete('dompet');
        Log.info(
          'Berhasil hapusSemuaDompet. Total baris yang dihapus permanen: $count',
        );
      });
    } catch (e, st) {
      Log.error('Gagal saat hapusSemuaDompet', e: e, st: st);
      rethrow;
    }
  }

  Future<void> arsipkanSatuDompet(String id) async {
    Log.info('Memulai arsipkanSatuDompet (soft delete) untuk ID: $id');
    try {
      final now = DateTime.now();
      final Map<String, dynamic> dataToUpdate = {
        'diarsipkan': now.toIso8601String(),
        'diperbarui': now.toIso8601String(),
        'isDeleted': 1,
      };

      await _operasiDasar.perbarui('dompet', dataToUpdate, id);

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

  Future<void> sisipkanAtauPerbaruiBatch(List<DompetModel> items) async {
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
      final data = items.map((item) => item.toSqlite()).toList();
      await _operasiDasar.sisipkanAtauPerbaruiBatch('dompet', data);
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

  Future<List<DompetModel>> getDompetByIds(List<String> ids) async {
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
        (i) => DompetModel.fromSqlite(maps[i]),
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
