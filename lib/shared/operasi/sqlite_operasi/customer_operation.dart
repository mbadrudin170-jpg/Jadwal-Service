// path: lib/shared/operasi/customer_operation.dart
// diubah: Menggunakan DateTime.now().toUtc() untuk konsistensi waktu.
// diubah: Mengganti nama class dari PelangganOperasi menjadi CustomerOperation.
// diubah: Menggunakan BaseOperation dan CustomerModel.
// diubah: Mengganti string literal 'pelanggan' dengan TableNameValue.get(TableName.customer) sesuai v50.

import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_operation.dart';

/// Kelas untuk operasi terkait data pelanggan di database lokal.
class CustomerOperation {
  /// Instance dari DatabaseHelper untuk mengakses database.
  final DatabaseHelper dbHelper;

  /// Instance dari [BaseOperation] untuk operasi CRUD dasar.
  final BaseOperation _baseOperation;

  final String _tableName = TableNameValue.get(TableName.customer);

  /// Konstruktor untuk [CustomerOperation].
  ///
  /// Memungkinkan injeksi dependensi untuk [dbHelper] dan [baseOperation]
  /// untuk memfasilitasi pengujian. Jika tidak disediakan, instance default akan digunakan.
  CustomerOperation({
    required this.dbHelper,
    required final BaseOperation baseOperation,
  }) : _baseOperation = baseOperation {
    Log.info('CustomerOperation diinisialisasi');
  }

  /// Menyimpan [CustomerModel] baru ke dalam database.
  Future<void> add(
    final CustomerModel customer, {
    final bool fromServer = false,
  }) async {
    Log.info('Memulai pembuatan customer dengan ID: ${customer.id}');
    try {
      final customerToSave = customer.copyWith(
        updatedAt: DateTime.now().toUtc(),
      );
      final data = customerToSave.toSqlite();

      // DIUBAH: Menggunakan TableNameValue berbasis v50
      await _baseOperation.insert(
        _tableName,
        data,
        fromServer: fromServer,
      );

      Log.info(
          'Customer (ID: ${customerToSave.id}) berhasil dibuat di database lokal.');
    } catch (e, s) {
      Log.error('Gagal membuat customer.', e: e, st: s);
      rethrow;
    }
  }

  /// Mengambil semua pelanggan yang aktif (tidak diarsipkan dan tidak dihapus).
  Future<List<CustomerModel>> getAll() async {
    Log.info(
        'Mengambil semua customer yang aktif (tidak diarsipkan dan tidak dihapus).');
    try {
      final db = await dbHelper.database;
      // DIUBAH: Menggunakan TableNameValue berbasis v50
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where:
            '${ColumnNames.archivedAt} IS NULL AND ${ColumnNames.isDeleted} = ?',
        whereArgs: [0],
      );

      Log.info('Berhasil mengambil ${maps.length} customer aktif.');
      return List.generate(maps.length, (final i) {
        return CustomerModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      Log.error('Gagal mengambil customer aktif.', e: e, st: s);
      rethrow;
    }
  }

  /// Mengambil semua pelanggan, termasuk yang diarsipkan dan dihapus.
  Future<List<CustomerModel>> getAllCustomers() async {
    Log.info('Mengambil SEMUA data customer dari database lokal.');
    try {
      final db = await dbHelper.database;
      // DIUBAH: Menggunakan TableNameValue berbasis v50
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
      );

      Log.info('Berhasil mengambil total ${maps.length} customer.');
      return List.generate(maps.length, (final i) {
        return CustomerModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      Log.error('Gagal mengambil semua data customer.', e: e, st: s);
      rethrow;
    }
  }

  /// Mengambil [CustomerModel] berdasarkan [id].
  Future<CustomerModel?> getById(final String id) async {
    Log.info('Mencari customer berdasarkan ID: $id');
    try {
      final db = await dbHelper.database;
      // DIUBAH: Menggunakan TableNameValue berbasis v50
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: '${ColumnNames.id} = ?',
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
  Future<void> updateCustomer(
    final CustomerModel customer, {
    final bool fromServer = false,
  }) async {
    Log.info('Memulai pembaruan untuk customer ID: ${customer.id}');
    try {
      final data =
          customer.copyWith(updatedAt: DateTime.now().toUtc()).toSqlite();

      // DIUBAH: Menggunakan TableNameValue berbasis v50
      await _baseOperation.update(
        _tableName,
        data,
        customer.id,
        fromServer: fromServer,
      );

      Log.info('Berhasil memperbarui customer ID: ${customer.id}.');
    } catch (e, s) {
      Log.error('Gagal memperbarui customer.', e: e, st: s);
      rethrow;
    }
  }

  /// Melakukan soft delete pada [CustomerModel] berdasarkan [id].
  Future<void> softDelete(
    final String id, {
    final bool fromServer = false,
  }) async {
    Log.info('Memulai proses soft delete untuk customer ID: $id');
    try {
      await _baseOperation.softDelete(
        _tableName,
        id,
        fromServer: fromServer,
      );
      Log.info('Berhasil melakukan soft delete pada customer ID: $id.');
    } catch (e, s) {
      Log.error('Gagal menghapus customer.', e: e, st: s);
      rethrow;
    }
  }

  /// Melakukan soft delete pada semua customer.
  Future<int> softDeleteAll({
    final bool fromServer = false,
  }) async {
    Log.info('Memulai proses soft delete untuk semua customer.');
    try {
      final count = await _baseOperation.softDeleteAll(
        _tableName,
        fromServer: fromServer,
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
  Future<List<CustomerModel>> getChangesSince(final DateTime since) async {
    Log.info('Mengambil perubahan customer sejak: ${since.toIso8601String()}');
    try {
      final db = await dbHelper.database;
      // DIUBAH: Menggunakan TableNameValue berbasis v50
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: '${ColumnNames.updatedAt} > ?',
        whereArgs: [since.toUtc().millisecondsSinceEpoch],
      );
      Log.info(
          'Ditemukan ${maps.length} perubahan customer sejak waktu yang ditentukan.');
      return List.generate(
        maps.length,
        (final i) => CustomerModel.fromSqlite(maps[i]),
      );
    } catch (e, s) {
      Log.error('Gagal mengambil perubahan customer.', e: e, st: s);
      rethrow;
    }
  }

  /// Menyisipkan atau memperbarui sekumpulan [CustomerModel] dalam satu batch.
  Future<void> insertOrUpdateBatch(
    final List<CustomerModel> items, {
    final bool fromServer = false,
  }) async {
    if (items.isEmpty) {
      Log.info('Tidak ada item untuk diproses dalam batch.');
      return;
    }
    Log.info('Memulai batch insert/update untuk ${items.length} customer.');
    try {
      final data = items.map((final item) {
        return item.copyWith(updatedAt: DateTime.now().toUtc()).toSqlite();
      }).toList();

      // DIUBAH: Menggunakan TableNameValue berbasis v50
      await _baseOperation.insertOrUpdateBatch(
        _tableName,
        data,
        fromServer: fromServer,
      );
      Log.info(
          'Berhasil menyelesaikan operasi batch untuk ${items.length} customer.');
    } catch (e, s) {
      Log.error('Gagal menjalankan operasi batch.', e: e, st: s);
      rethrow;
    }
  }

  /// Mengambil beberapa [CustomerModel] berdasarkan daftar [ids].
  Future<List<CustomerModel>> getCustomersByIds(final List<String> ids) async {
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
        _tableName,
        where: '${ColumnNames.id} IN ($placeholders)',
        whereArgs: ids,
      );
      Log.info(
          'Berhasil mengambil ${maps.length} customer berdasarkan list ID.');
      return List.generate(maps.length, (final i) {
        return CustomerModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      Log.error('Gagal mengambil customer berdasarkan list ID.', e: e, st: s);
      rethrow;
    }
  }
}
