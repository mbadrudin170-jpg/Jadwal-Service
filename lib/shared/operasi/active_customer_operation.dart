// path: lib/shared/operasi/active_customer_operation.dart
// diubah: Mengubah nama tabel menggunakan TableNameValue sesuai migrasi skema v50.
// diubah: Menggunakan DateTime.now().toUtc() untuk konsistensi waktu.
// diubah: Mengganti nama class dari PelangganAktifOperasi menjadi ActiveCustomerOperation.
// diubah: Menggunakan BaseOperation dan ActiveCustomerModel.

import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/model/active_customer_detail_model.dart';
import 'package:wifi/shared/operasi/base_operation.dart';
import 'package:wifi/shared/operasi/customer_operation.dart';
import 'package:wifi/shared/services/notifikasi/notifikasi_servis.dart';

/// Konstanta untuk generate UUID.
const uuid = Uuid();

/// Kelas untuk operasi terkait data pelanggan aktif di database lokal.
class ActiveCustomerOperation {
  /// Instance dari DatabaseHelper untuk mengakses database.
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  final BaseOperation _baseOperation = BaseOperation();

  // DIUBAH: Menggunakan TableNameValue dinamis untuk konsistensi migrasi v50
  final String _tableName = TableNameValue.get(TableName.activeCustomer);
  final String _customerTableName = TableNameValue.get(TableName.customer);
  final String _packageTableName = TableNameValue.get(TableName.package);

  final NotifikasiServis _notifikasiServis = NotifikasiServis();
  final CustomerOperation _customerOperation = CustomerOperation();
  final _nowUtc = DateTime.now().toUtc();

  /// Konstruktor untuk `ActiveCustomerOperation`.
  ActiveCustomerOperation() {
    Log.info('ActiveCustomerOperation diinisialisasi - Tabel: $_tableName');
  }

  /// Mengambil semua pelanggan aktif dengan detail nama pelanggan dan nama paket
  /// menggunakan satu query JOIN yang efisien.
  Future<List<ActiveCustomerDetailModel>>
      getAllActiveCustomersWithDetails() async {
    final db = await dbHelper.database;
    Log.info('Mengambil semua pelanggan aktif dengan detail (JOIN)');

    final query = '''
      SELECT
        ac.*,
        c.${ColumnNames.name} as customer_name,
        p.${ColumnNames.name} as package_name
      FROM $_tableName ac
      LEFT JOIN $_customerTableName c ON ac.${ColumnNames.customerId} = c.${ColumnNames.id}
      LEFT JOIN $_packageTableName p ON ac.${ColumnNames.packageId} = p.${ColumnNames.id}
      WHERE ac.${ColumnNames.isDeleted} = 0
    ''';

    try {
      final List<Map<String, dynamic>> maps = await db.rawQuery(query);
      Log.info(
          'Berhasil mengambil ${maps.length} pelanggan aktif dengan detail.');

      return List.generate(maps.length, (final i) {
        final map = maps[i];
        return ActiveCustomerDetailModel(
          activeCustomer: ActiveCustomerModel.fromSqlite(map),
          customerName: map['customer_name'] as String? ?? 'Tanpa Nama',
          packageName: map['package_name'] as String? ?? 'Tanpa Paket',
        );
      });
    } on Exception catch (e, st) {
      Log.error('Gagal melakukan query JOIN untuk pelanggan aktif',
          e: e, st: st);
      rethrow;
    }
  }

  /// Membuat [ActiveCustomerModel] baru di database.
  Future<ActiveCustomerModel> createActiveCustomer(
    final ActiveCustomerModel activeCustomer, {
    final bool fromServer = false,
  }) async {
    try {
      final newId = activeCustomer.id.isEmpty ? uuid.v4() : activeCustomer.id;
      final customerToSave = activeCustomer.copyWith(
        id: newId,
        updatedAt: _nowUtc,
      );

      Log.info('Membuat active customer baru - ID: $newId');

      await _baseOperation.runComplexOperation<void>(
        (final Transaction txn) async {
          final data = customerToSave.toSqlite();
          await txn.insert(
            _tableName,
            data,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        },
        fromServer: fromServer,
      );

      await _scheduleNotification(customerToSave);
      Log.info('Active customer ID: $newId berhasil dibuat di $_tableName');
      return customerToSave;
    } on Exception catch (e, st) {
      Log.error('Gagal membuat active customer', e: e, st: st);
      rethrow;
    }
  }

  /// Mengambil semua pelanggan aktif (tidak diarsipkan).
  Future<List<ActiveCustomerModel>> getAllActiveCustomers() async {
    try {
      final db = await dbHelper.database;
      Log.info('Mengambil semua active customer dari tabel $_tableName');

      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: '${ColumnNames.isDeleted} = ?',
        whereArgs: [0],
      );

      Log.info('Berhasil mengambil ${maps.length} active customer');
      return List.generate(
        maps.length,
        (final i) => ActiveCustomerModel.fromSqlite(maps[i]),
      );
    } on Exception catch (e, st) {
      Log.error('Gagal mengambil semua active customer', e: e, st: st);
      rethrow;
    }
  }

  /// Mengambil [ActiveCustomerModel] berdasarkan [id].
  Future<ActiveCustomerModel?> getActiveCustomerById(final String id) async {
    try {
      final db = await dbHelper.database;
      Log.info('Mencari active customer dengan ID: $id di tabel $_tableName');

      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: '${ColumnNames.id} = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        final activeCustomer = ActiveCustomerModel.fromSqlite(maps.first);
        Log.info('Active customer ID: $id ditemukan');
        return activeCustomer;
      }

      Log.info('Active customer ID: $id tidak ditemukan');
      return null;
    } on Exception catch (e, st) {
      Log.error('Gagal mengambil active customer ID: $id', e: e, st: st);
      rethrow;
    }
  }

  /// Memperbarui [ActiveCustomerModel] yang ada di database.
  Future<ActiveCustomerModel> updateActiveCustomer(
    final ActiveCustomerModel activeCustomer, {
    final bool fromServer = false,
  }) async {
    try {
      final customerToSave = activeCustomer.copyWith(
        updatedAt: _nowUtc,
      );

      Log.info('Memperbarui active customer ID: ${customerToSave.id}');

      await _baseOperation.runComplexOperation<void>(
        (final Transaction txn) async {
          final data = customerToSave.toSqlite();
          await txn.update(
            _tableName,
            data,
            where: '${ColumnNames.id} = ?',
            whereArgs: [customerToSave.id],
          );
        },
        fromServer: fromServer,
      );

      await _scheduleNotification(customerToSave);
      Log.info('Active customer ID: ${customerToSave.id} berhasil diperbarui');
      return customerToSave;
    } on Exception catch (e, st) {
      Log.error('Gagal memperbarui active customer ID: ${activeCustomer.id}',
          e: e, st: st);
      rethrow;
    }
  }

  /// Menjadwalkan notifikasi untuk [ActiveCustomerModel].
  Future<void> _scheduleNotification(
      final ActiveCustomerModel activeCustomer) async {
    try {
      Log.info(
          'Menjadwalkan notifikasi untuk active customer ID: ${activeCustomer.id}');

      final customer =
          await _customerOperation.getById(activeCustomer.customerId);
      final customerName = customer?.name ?? 'Tanpa Nama';

      // Batalkan notifikasi lama
      await _notifikasiServis.batalNotifikasi(activeCustomer.id.hashCode);
      await _notifikasiServis.batalNotifikasi((activeCustomer.id.hashCode + 1));
      await _notifikasiServis.batalNotifikasi((activeCustomer.id.hashCode + 2));

      // 1. NOTIFIKASI TEPAT SAAT BERAKHIR
      final exactTime = activeCustomer.endDate;
      if (exactTime.isAfter(DateTime.now())) {
        await _notifikasiServis.jadwalNotifikasi(
          id: (activeCustomer.id.hashCode + 2),
          title: 'Masa Aktif Habis!',
          body: 'Paket WiFi untuk $customerName telah berakhir sekarang.',
          jadwal: exactTime,
        );
      }

      // 2. NOTIFIKASI H-1
      final h1Schedule =
          activeCustomer.endDate.subtract(const Duration(days: 1));
      if (h1Schedule.isAfter(DateTime.now())) {
        await _notifikasiServis.jadwalNotifikasi(
          id: activeCustomer.id.hashCode,
          title: 'Paket Akan Segera Berakhir',
          body: 'Paket untuk pelanggan $customerName akan berakhir besok.',
          jadwal: h1Schedule,
        );
      }

      // 3. NOTIFIKASI H-3
      final h3Schedule =
          activeCustomer.endDate.subtract(const Duration(days: 3));
      if (h3Schedule.isAfter(DateTime.now())) {
        await _notifikasiServis.jadwalNotifikasi(
          id: (activeCustomer.id.hashCode + 1),
          title: 'Pengingat Paket',
          body:
              'Paket untuk pelanggan $customerName akan berakhir dalam 3 hari.',
          jadwal: h3Schedule,
        );
      }

      Log.info('Penjadwalan notifikasi selesai',
          {h3Schedule, h1Schedule, exactTime});
    } on Exception catch (e, st) {
      Log.error('Gagal menjadwalkan notifikasi', e: e, st: st);
    }
  }

  /// Menyisipkan atau memperbarui sekumpulan [ActiveCustomerModel] dalam satu batch.
  Future<void> insertOrUpdateBatch(
    final List<ActiveCustomerModel> items, {
    final bool fromServer = false,
  }) async {
    try {
      Log.info(
          'Memproses batch ${items.length} active customer di $_tableName');

      final data = items
          .map(
            (final item) => item.copyWith(updatedAt: _nowUtc).toSqlite(),
          )
          .toList();

      // DIUBAH: Meneruskan TableName enum ke baseOperation untuk konsistensi internal
      await _baseOperation.insertOrUpdateBatch(
        _tableName,
        data,
        fromServer: fromServer,
      );

      Log.info('Batch ${items.length} active customer berhasil diproses');
    } on Exception catch (e, st) {
      Log.error('Gagal memproses batch ${items.length} active customer',
          e: e, st: st);
      rethrow;
    }
  }

  /// Mengarsipkan [ActiveCustomerModel] berdasarkan [id].
  Future<void> softDelete(
    final String id, {
    final bool fromServer = false,
  }) async {
    try {
      Log.info('Mengarsipkan active customer ID: $id');

      final activeCustomer = await getActiveCustomerById(id);
      if (activeCustomer == null) {
        Log.info('Active customer ID: $id tidak ditemukan');
        return;
      }

      await _baseOperation.runComplexOperation<void>(
        (final Transaction txn) async {
          final archivedCustomer = activeCustomer.copyWith(
            updatedAt: _nowUtc,
            isDeleted: true,
            archivedAt: _nowUtc,
          );

          await txn.update(
            _tableName,
            archivedCustomer.toSqlite(),
            where: '${ColumnNames.id} = ?',
            whereArgs: [id],
          );

          await _notifikasiServis.batalNotifikasi(id.hashCode);
          await _notifikasiServis.batalNotifikasi((id.hashCode + 1));
          await _notifikasiServis.batalNotifikasi((id.hashCode + 2));
        },
        fromServer: fromServer,
      );

      Log.info('Active customer ID: $id berhasil diarsipkan');
    } on Exception catch (e, st) {
      Log.error('Gagal mengarsipkan active customer ID: $id', e: e, st: st);
      rethrow;
    }
  }

  /// Menghapus permanen pelanggan yang sudah diarsipkan lebih dari 30 hari.
  Future<void> permanentlyDeleteArchivedCustomers({
    final bool fromServer = false,
  }) async {
    try {
      await _baseOperation.runComplexOperation<void>(
        (final Transaction txn) async {
          final deadline = _nowUtc.subtract(const Duration(days: 30));

          final List<Map<String, dynamic>> expiredCustomers = await txn.query(
            _tableName,
            where:
                '${ColumnNames.archivedAt} IS NOT NULL AND ${ColumnNames.archivedAt} < ?',
            whereArgs: [deadline.millisecondsSinceEpoch],
          );

          if (expiredCustomers.isEmpty) {
            Log.info('Tidak ada active customer diarsipkan lebih dari 30 hari');
            return;
          }

          final idsToDelete = expiredCustomers
              .map((final map) => map[ColumnNames.id] as String)
              .toList();

          final count = await txn.delete(
            _tableName,
            where:
                '${ColumnNames.id} IN (${List.filled(idsToDelete.length, '?').join(',')})',
            whereArgs: idsToDelete,
          );

          Log.info(
              '$count active customer telah dihapus permanen dari $_tableName');
        },
        fromServer: fromServer,
      );
    } on Exception catch (e, st) {
      Log.error('Gagal menghapus permanen active customer diarsipkan',
          e: e, st: st);
      rethrow;
    }
  }

  /// Mengarsipkan pelanggan yang sudah kadaluarsa.
  Future<int> archiveExpiredCustomers({final bool fromServer = false}) async {
    try {
      Log.info('Memeriksa active customer kadaluarsa');
      final db = await dbHelper.database;

      final List<Map<String, dynamic>> expiredCustomers = await db.query(
        _tableName,
        where: '${ColumnNames.endDate} < ? AND ${ColumnNames.isDeleted} = 0',
        whereArgs: [_nowUtc.millisecondsSinceEpoch],
      );

      if (expiredCustomers.isEmpty) {
        Log.info('Tidak ada active customer kadaluarsa');
        return 0;
      }

      final idsToArchive = expiredCustomers
          .map((final p) => p[ColumnNames.id] as String)
          .toList();

      await _baseOperation.runComplexOperation<void>(
        (final Transaction txn) async {
          await txn.update(
            _tableName,
            {
              ColumnNames.isDeleted: 1,
              ColumnNames.archivedAt: _nowUtc.millisecondsSinceEpoch,
              ColumnNames.updatedAt: _nowUtc.millisecondsSinceEpoch,
            },
            where:
                '${ColumnNames.id} IN (${List.filled(idsToArchive.length, '?').join(',')})',
            whereArgs: idsToArchive,
          );

          for (final id in idsToArchive) {
            await _notifikasiServis.batalNotifikasi(id.hashCode);
            await _notifikasiServis.batalNotifikasi((id.hashCode + 1));
            await _notifikasiServis.batalNotifikasi((id.hashCode + 2));
          }
        },
        fromServer: fromServer,
      );

      Log.info(
          '${idsToArchive.length} active customer kadaluarsa telah diarsipkan');
      return idsToArchive.length;
    } on Exception catch (e, st) {
      Log.error('Gagal mengarsipkan active customer kadaluarsa', e: e, st: st);
      rethrow;
    }
  }

  /// Mengarsipkan semua pelanggan aktif.
  Future<int> softDeleteAll({final bool fromServer = false}) async {
    try {
      Log.info('Mengarsipkan SEMUA active customer');
      final allCustomers = await getAllActiveCustomers();

      if (allCustomers.isEmpty) {
        Log.info('Tidak ada active customer untuk diarsipkan');
        return 0;
      }

      final idsToArchive = allCustomers.map((final p) => p.id).toList();

      await _baseOperation.runComplexOperation<void>(
        (final Transaction txn) async {
          await txn.update(
            _tableName,
            {
              ColumnNames.isDeleted: 1,
              ColumnNames.archivedAt: _nowUtc.millisecondsSinceEpoch,
              ColumnNames.updatedAt: _nowUtc.millisecondsSinceEpoch,
            },
            where:
                '${ColumnNames.id} IN (${List.filled(idsToArchive.length, '?').join(',')})',
            whereArgs: idsToArchive,
          );

          for (final id in idsToArchive) {
            await _notifikasiServis.batalNotifikasi(id.hashCode);
            await _notifikasiServis.batalNotifikasi((id.hashCode + 1));
            await _notifikasiServis.batalNotifikasi((id.hashCode + 2));
          }
        },
        fromServer: fromServer,
      );

      Log.info('${idsToArchive.length} active customer telah diarsipkan');
      return idsToArchive.length;
    } on Exception catch (e, st) {
      Log.error('Gagal mengarsipkan semua active customer', e: e, st: st);
      rethrow;
    }
  }

  /// Mengambil beberapa [ActiveCustomerModel] berdasarkan daftar [ids].
  Future<List<ActiveCustomerModel>> getActiveCustomersByIds(
    final List<String> ids,
  ) async {
    try {
      if (ids.isEmpty) {
        Log.info('getActiveCustomersByIds dipanggil dengan list ID kosong');
        return [];
      }

      final db = await dbHelper.database;
      final placeholders = List.filled(ids.length, '?').join(',');
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: '${ColumnNames.id} IN ($placeholders)',
        whereArgs: ids,
      );

      Log.info('Ditemukan ${maps.length} dari ${ids.length} active customer');
      return List.generate(maps.length, (final i) {
        return ActiveCustomerModel.fromSqlite(maps[i]);
      });
    } on Exception catch (e, st) {
      Log.error('Gagal mengambil active customer berdasarkan IDs',
          e: e, st: st);
      rethrow;
    }
  }
}
