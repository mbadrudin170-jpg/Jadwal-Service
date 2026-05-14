// path: lib/shared/operasi/kategori_operasi.dart
// diubah: Menggunakan DateTime.now().toUtc() untuk konsistensi waktu dan memperbaiki path.

import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/kategori_model.dart';
import 'package:wifi/shared/operasi/operasi_dasar.dart';

/// Kelas untuk operasi terkait data kategori di database lokal.
class KategoriOperasi {
  /// Instance dari DatabaseHelper untuk mengakses database.
  final dbHelper = DatabaseHelper.instance;
  final OperasiDasar _operasiDasar = OperasiDasar();

  /// Membuat [KategoriModel] baru di database.
  Future<KategoriModel> createKategori(
    final KategoriModel kategori, {
    final bool dariServer = false,
  }) async {
    Log.info('Memulai createKategori untuk kategori: ${kategori.toSqlite()}');
    try {
      final kategoriBaru =
          kategori.copyWith(diperbarui: DateTime.now().toUtc());
      final data = kategoriBaru.toSqlite();

      await _operasiDasar.sisipkan('kategori', data, dariServer: dariServer);
      Log.info('Berhasil membuat kategori baru dengan ID: ${kategoriBaru.id}');
      return kategoriBaru;
    } catch (e, st) {
      Log.error('Gagal saat createKategori', e: e, st: st);
      rethrow;
    }
  }

  /// Mengambil semua kategori yang tidak diarsipkan.
  Future<List<KategoriModel>> getKategori() async {
    Log.info(
      'Memulai getKategori (mengambil semua kategori yang tidak diarsipkan).',
    );
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'kategori',
        where: 'diarsipkan IS NULL',
      );
      final listKategori = List.generate(
        maps.length,
        (final i) => KategoriModel.fromSqlite(maps[i]),
      );
      Log.info('Berhasil mengambil ${listKategori.length} data kategori.');
      return listKategori;
    } catch (e, st) {
      Log.error('Gagal saat getKategori', e: e, st: st);
      rethrow;
    }
  }

  /// Mengambil [KategoriModel] berdasarkan [id].
  Future<KategoriModel> getKategoriById(final String id) async {
    Log.info('Memulai getKategoriById untuk ID: $id');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'kategori',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        final kategori = KategoriModel.fromSqlite(maps.first);
        Log.info(
          'Kategori dengan ID: $id ditemukan. Data: ${kategori.toSqlite()}',
        );
        return kategori;
      } else {
        Log.error('Kategori dengan ID $id tidak ditemukan di database.');
        throw Exception('Kategori dengan ID $id tidak ditemukan.');
      }
    } catch (e, st) {
      Log.error(
        'Gagal saat getKategoriById untuk ID: $id',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Mengambil semua kategori berdasarkan [TipeKategori].
  Future<List<KategoriModel>> getKategoriByTipe(final TipeKategori tipe) async {
    Log.info('Memulai getKategoriByTipe untuk tipe: ${tipe.name}');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'kategori',
        where: 'tipe = ? AND diarsipkan IS NULL',
        whereArgs: [tipe.name],
      );
      final listKategori = List.generate(
        maps.length,
        (final i) => KategoriModel.fromSqlite(maps[i]),
      );
      Log.info(
        'Berhasil mengambil ${listKategori.length} data kategori untuk tipe ${tipe.name}.',
      );
      return listKategori;
    } catch (e, st) {
      Log.error(
        'Gagal saat getKategoriByTipe untuk tipe: ${tipe.name}',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Memperbarui [KategoriModel] yang ada di database.
  Future<void> update(final KategoriModel kategori, {final bool dariServer = false}) async {
    Log.info('Memulai update untuk kategori: ${kategori.toSqlite()}');
    try {
      final data =
          kategori.copyWith(diperbarui: DateTime.now().toUtc()).toSqlite();
      await _operasiDasar.perbarui(
        'kategori',
        data,
        kategori.id,
        dariServer: dariServer,
      );
      Log.info('Berhasil update kategori untuk ID: ${kategori.id}.');
    } catch (e, st) {
      Log.error(
        'Gagal saat update kategori ID: ${kategori.id}',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Menghapus [KategoriModel] dari database secara permanen.
  Future<void> delete(final String id, {final bool dariServer = false}) async {
    Log.warning(
      'PERINGATAN: Memulai operasi delete (hard delete) untuk kategori ID: $id',
    );
    try {
      await _operasiDasar.hapus('kategori', id, dariServer: dariServer);
      Log.info('Berhasil delete kategori ID: $id.');
    } catch (e, st) {
      Log.error('Gagal saat delete kategori ID: $id', e: e, st: st);
      rethrow;
    }
  }

  /// Mengarsipkan satu kategori berdasarkan [id] (soft delete).
  Future<void> arsipkanSatuKategori(
    final String id, {
    final bool dariServer = false,
  }) async {
    Log.info('Memulai arsipkanSatuKategori (soft delete) untuk ID: $id');
    try {
      final now = DateTime.now().toUtc();
      final Map<String, dynamic> dataToUpdate = {
        'diarsipkan': now.millisecondsSinceEpoch,
        'diperbarui': now.millisecondsSinceEpoch,
        'isDeleted': 1,
      };

      await _operasiDasar.perbarui(
        'kategori',
        dataToUpdate,
        id,
        dariServer: dariServer,
      );

      Log.info('Berhasil arsipkanSatuKategori untuk ID: $id.');
    } catch (e, st) {
      Log.error(
        'Gagal saat arsipkanSatuKategori untuk ID: $id',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Menghapus semua kategori yang ada dan menyisipkan yang baru.
  Future<void> bersihkanDanSisipkanSemua(
    final List<KategoriModel> items, {
    final bool dariServer = false,
  }) async {
    Log.warning(
      'PERINGATAN: Memulai bersihkanDanSisipkanSemua. Ini akan menghapus semua kategori dan menggantinya dengan ${items.length} item baru.',
    );
    if (items.isEmpty) {
      Log.warning(
        'List item untuk bersihkanDanSisipkanSemua kosong, hanya operasi pembersihan yang akan dilakukan.',
      );
    }
    try {
      await _operasiDasar.jalankanOperasiKompleks(
        (final txn) async {
          await txn.delete('kategori');
          Log.info('Tabel kategori berhasil dibersihkan.');
          for (var item in items) {
            await txn.insert(
              'kategori',
              item.copyWith(diperbarui: DateTime.now().toUtc()).toSqlite(),
            );
          }
          Log.info(
            'Berhasil menyisipkan ${items.length} item baru ke tabel kategori.',
          );
        },
        dariServer: dariServer,
      );
    } catch (e, st) {
      Log.error(
        'Gagal saat menjalankan bersihkanDanSisipkanSemua',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Mengambil semua kategori yang telah diubah sejak [since].
  Future<List<KategoriModel>> getPerubahan(final DateTime since) async {
    Log.info(
      'Memulai getPerubahan untuk kategori sejak: ${since.toIso8601String()}',
    );
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'kategori',
        where: 'diperbarui > ?',
        whereArgs: [since.toUtc().millisecondsSinceEpoch],
      );
      final listKategori = List.generate(
        maps.length,
        (final i) => KategoriModel.fromSqlite(maps[i]),
      );
      Log.info(
        'Berhasil menemukan ${listKategori.length} perubahan kategori sejak ${since.toIso8601String()}.',
      );
      return listKategori;
    } catch (e, st) {
      Log.error('Gagal saat getPerubahan kategori', e: e, st: st);
      rethrow;
    }
  }

  /// Menyisipkan atau memperbarui sekumpulan [KategoriModel] dalam satu batch.
  Future<void> sisipkanAtauPerbaruiBatch(
    final List<KategoriModel> items, {
    final bool dariServer = false,
  }) async {
    Log.info(
      'Memulai sisipkanAtauPerbaruiBatch untuk ${items.length} item kategori.',
    );
    if (items.isEmpty) {
      Log.warning(
        'List item untuk batch kosong, tidak ada operasi yang dilakukan.',
      );
      return;
    }
    try {
      final data = items
          .map(
            (final item) =>
                item.copyWith(diperbarui: DateTime.now().toUtc()).toSqlite(),
          )
          .toList();
      await _operasiDasar.sisipkanAtauPerbaruiBatch(
        'kategori',
        data,
        dariServer: dariServer,
      );
      Log.info(
        'Berhasil menyelesaikan sisipkanAtauPerbaruiBatch untuk ${items.length} item kategori.',
      );
    } catch (e, st) {
      Log.error(
        'Gagal saat menjalankan sisipkanAtauPerbaruiBatch kategori',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Mengambil beberapa [KategoriModel] berdasarkan daftar [ids].
  Future<List<KategoriModel>> getKategoriByIds(final List<String> ids) async {
    Log.info('Memulai getKategoriByIds untuk ${ids.length} ID.');
    if (ids.isEmpty) {
      Log.warning(
        'List ID untuk getKategoriByIds kosong, mengembalikan list kosong.',
      );
      return [];
    }
    try {
      final db = await dbHelper.database;
      final placeholders = List.filled(ids.length, '?').join(',');
      final List<Map<String, dynamic>> maps = await db.query(
        'kategori',
        where: 'id IN ($placeholders)',
        whereArgs: ids,
      );
      final listKategori = List.generate(
        maps.length,
        (final i) => KategoriModel.fromSqlite(maps[i]),
      );
      Log.info(
        'Berhasil mengambil ${listKategori.length} kategori dari ${ids.length} ID yang diminta.',
      );
      return listKategori;
    } catch (e, st) {
      Log.error('Gagal saat getKategoriByIds', e: e, st: st);
      rethrow;
    }
  }
}
