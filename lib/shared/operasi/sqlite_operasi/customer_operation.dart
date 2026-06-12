// path: lib/shared/operasi/customer_operation.dart

import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_operation.dart';

/// Kelas untuk operasi terkait data pelanggan di database lokal.
class PelangganOpSqlite {
  /// Instance dari DatabaseHelper untuk mengakses database.
  final SqliteDatabase dbHelper;

  /// Instance dari [BaseOpSqlite] untuk operasi CRUD dasar.
  final BaseOpSqlite _baseOperation;

  final String _namaTabel = NamaTabel.customer;

  /// Konstruktor untuk [PelangganOpSqlite].
  ///
  /// Memungkinkan injeksi dependensi untuk [dbHelper] dan [baseOperation]
  /// untuk memfasilitasi pengujian. Jika tidak disediakan, instance default akan digunakan.
  PelangganOpSqlite({
    required this.dbHelper,
    required BaseOpSqlite baseOperation,
  }) : _baseOperation = baseOperation {
    Log.info('CustomerOperation diinisialisasi');
  }

  /// Menyimpan [CustomerModel] baru ke dalam database.
  Future<void> tambah(
    CustomerModel customer, {
    bool dariServer = false,
  }) async {
    Log.info('Memulai pembuatan customer dengan ID: ${customer.id}');
    try {
      final customerToSave = customer.copyWith(
        updatedAt: DateTime.now().toUtc(),
      );
      final data = customerToSave.toSqlite();

      // DIUBAH: Menggunakan TableNameValue berbasis v50
      await _baseOperation.sisipkan(
        _namaTabel,
        data,
        dariServer: dariServer,
      );

      Log.info(
          'Customer (ID: ${customerToSave.id}) berhasil dibuat di database lokal.');
    } catch (e, s) {
      Log.error('Gagal membuat customer.', e: e, st: s);
      rethrow;
    }
  }

  /// Mengambil semua pelanggan yang aktif (tidak diarsipkan dan tidak dihapus).
  Future<List<CustomerModel>> ambilSemua() async {
    Log.info(
        'Mengambil semua customer yang aktif (tidak diarsipkan dan tidak dihapus).');
    try {
      final db = await dbHelper.database;
      // DIUBAH: Menggunakan TableNameValue berbasis v50
      final List<Map<String, dynamic>> maps = await db.query(
        _namaTabel,
        where: '${NamaKolom.archivedAt} IS NULL AND ${NamaKolom.isDeleted} = ?',
        whereArgs: [0],
      );

      Log.info('Berhasil mengambil ${maps.length} customer aktif.');
      return List.generate(maps.length, (i) {
        return CustomerModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      Log.error('Gagal mengambil customer aktif.', e: e, st: s);
      rethrow;
    }
  }

  /// Mengambil semua pelanggan, termasuk yang diarsipkan dan dihapus.
  Future<List<CustomerModel>> ambilSemuaPelanggan() async {
    Log.info('Mengambil SEMUA data customer dari database lokal.');
    try {
      final db = await dbHelper.database;
      // DIUBAH: Menggunakan TableNameValue berbasis v50
      final List<Map<String, dynamic>> maps = await db.query(
        _namaTabel,
      );

      Log.info('Berhasil mengambil total ${maps.length} customer.');
      return List.generate(maps.length, (i) {
        return CustomerModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      Log.error('Gagal mengambil semua data customer.', e: e, st: s);
      rethrow;
    }
  }

  /// Mengambil [CustomerModel] berdasarkan [id].
  Future<CustomerModel?> ambilBerdasarkanId(String id) async {
    Log.info('Mencari customer berdasarkan ID: $id');
    try {
      final db = await dbHelper.database;
      // DIUBAH: Menggunakan TableNameValue berbasis v50
      final List<Map<String, dynamic>> maps = await db.query(
        _namaTabel,
        where: '${NamaKolom.id} = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        Log.info('Customer dengan ID: $id ditemukan.');
        return CustomerModel.fromSqlite(maps.first);
      }
      Log.info('Customer dengan ID: $id tidak ditemukan (hasil valid).');
      return null;
    } catch (e, s) {
      Log.error('Gagal mencari customer berdasarkan ID.', e: e, st: s);
      rethrow;
    }
  }

  /// Memperbarui [CustomerModel] yang ada di database.
  Future<void> perbaruiPelanggan(
    CustomerModel customer, {
    bool dariServer = false,
  }) async {
    Log.info('Memulai pembaruan untuk customer ID: ${customer.id}');
    try {
      final data =
          customer.copyWith(updatedAt: DateTime.now().toUtc()).toSqlite();

      // DIUBAH: Menggunakan TableNameValue berbasis v50
      await _baseOperation.update(
        _namaTabel,
        data,
        customer.id,
        dariServer: dariServer,
      );

      Log.info('Berhasil memperbarui customer ID: ${customer.id}.');
    } catch (e, s) {
      Log.error('Gagal memperbarui customer.', e: e, st: s);
      rethrow;
    }
  }

  /// Melakukan soft delete pada [CustomerModel] berdasarkan [id].
  Future<void> hapusSementara(
    String id, {
    bool dariServer = false,
  }) async {
    Log.info('Memulai proses soft delete untuk customer ID: $id');
    try {
      await _baseOperation.hapusSementara(
        _namaTabel,
        id,
        dariServer: dariServer,
      );
      Log.info('Berhasil melakukan soft delete pada customer ID: $id.');
    } catch (e, s) {
      Log.error('Gagal menghapus customer.', e: e, st: s);
      rethrow;
    }
  }

  /// Melakukan soft delete pada semua customer.
  Future<int> hapusSementaraSemua({
    bool dariServer = false,
  }) async {
    Log.info('Memulai proses soft delete untuk semua customer.');
    try {
      final count = await _baseOperation.hapusSementaraSemua(
        _namaTabel,
        dariServer: dariServer,
      );
      Log.info(
          'Berhasil melakukan soft delete pada semua customer. Total: $count');
      return count;
    } catch (e, s) {
      Log.error('Gagal melakukan soft delete pada semua customer.',
          e: e, st: s);
      rethrow;
    }
  }

  /// Mengambil semua pelanggan yang telah diubah sejak [since].
  Future<List<CustomerModel>> ambilPerubahanSejak(DateTime since) async {
    Log.info('Mengambil perubahan customer sejak: ${since.toIso8601String()}');
    try {
      final db = await dbHelper.database;
      // DIUBAH: Menggunakan TableNameValue berbasis v50
      final List<Map<String, dynamic>> maps = await db.query(
        _namaTabel,
        where: '${NamaKolom.updatedAt} > ?',
        whereArgs: [since.toUtc().millisecondsSinceEpoch],
      );
      Log.info(
          'Ditemukan ${maps.length} perubahan customer sejak waktu yang ditentukan.');
      return List.generate(
        maps.length,
        (i) => CustomerModel.fromSqlite(maps[i]),
      );
    } catch (e, s) {
      Log.error('Gagal mengambil perubahan customer.', e: e, st: s);
      rethrow;
    }
  }

  /// Menyisipkan atau memperbarui sekumpulan [CustomerModel] dalam satu batch.
  Future<void> sisipkanAtauPerbaruiBatch(
    List<CustomerModel> items, {
    bool dariServer = false,
  }) async {
    if (items.isEmpty) {
      Log.info('Tidak ada item untuk diproses dalam batch.');
      return;
    }
    Log.info('Memulai batch insert/update untuk ${items.length} customer.');
    try {
      final data = items.map((item) {
        return item.copyWith(updatedAt: DateTime.now().toUtc()).toSqlite();
      }).toList();

      // DIUBAH: Menggunakan TableNameValue berbasis v50
      await _baseOperation.insertOrUpdateBatch(
        _namaTabel,
        data,
        fromServer: dariServer,
      );
      Log.info(
          'Berhasil menyelesaikan operasi batch untuk ${items.length} customer.');
    } catch (e, s) {
      Log.error('Gagal menjalankan operasi batch.', e: e, st: s);
      rethrow;
    }
  }

  /// Mengambil beberapa [CustomerModel] berdasarkan daftar [ids].
  Future<List<CustomerModel>> ambilPelangganBerdasarkanId(
      List<String> ids) async {
    if (ids.isEmpty) {
      Log.info('List ID kosong, tidak ada customer yang diambil.');
      return [];
    }
    Log.info('Mengambil data customer untuk ${ids.length} ID.');
    try {
      final db = await dbHelper.database;
      final placeholders = List.filled(ids.length, '?').join(',');
      // DIUBAH: Menggunakan TableNameValue berbasis v50
      final List<Map<String, dynamic>> maps = await db.query(
        _namaTabel,
        where: '${NamaKolom.id} IN ($placeholders)',
        whereArgs: ids,
      );
      Log.info(
          'Berhasil mengambil ${maps.length} customer berdasarkan list ID.');
      return List.generate(maps.length, (i) {
        return CustomerModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      Log.error('Gagal mengambil customer berdasarkan list ID.', e: e, st: s);
      rethrow;
    }
  }
}
