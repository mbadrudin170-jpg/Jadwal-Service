// path: lib/shared/operasi/sqlite_operasi/active_customer_operation.dart

import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/notfikasi/notifikasi_servis.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/model/active_customer_detail_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/customer_operation.dart';

const uuid = Uuid();

class ActiveCustomerOperation {
  final SqliteDatabase dbHelper;
  final BaseOpSqlite _baseOperation;
  final NotifikasiServis _notifikasiServis;
  final PelangganOpSqlite _customerOperation;
  final String _tableName = NamaTabel.activeCustomer;
  final String _customerTableName = NamaTabel.customer;
  final String _packageTableName = NamaTabel.package;

  DateTime get _nowUtc => DateTime.now().toUtc();

  ActiveCustomerOperation({
    required this.dbHelper,
    required BaseOpSqlite baseOperation,
    required PelangganOpSqlite customerOperation,
    required NotifikasiServis notifikasiServis,
  })  : _baseOperation = baseOperation,
        _customerOperation = customerOperation,
        _notifikasiServis = notifikasiServis {
    Log.info('ActiveCustomerOperation diinisialisasi - Tabel: $_tableName');
  }

  Future<void> rescheduleAllNotifications() async {
    Log.info('MEMULAI PROSES PENJADWALAN ULANG SEMUA NOTIFIKASI...');
    try {
      final List<ActiveCustomerModel> allActiveCustomers =
          await getAllActiveCustomers();

      if (allActiveCustomers.isEmpty) {
        Log.info('Tidak ada pelanggan aktif untuk dijadwalkan ulang.');
        return;
      }

      Log.info(
          'Ditemukan ${allActiveCustomers.length} pelanggan aktif. Menjadwalkan ulang satu per satu...');

      for (final activeCustomer in allActiveCustomers) {
        await scheduleNotification(activeCustomer);
      }

      Log.info('PROSES PENJADWALAN ULANG SEMUA NOTIFIKASI SELESAI.');
    } on Exception catch (e, st) {
      Log.error('Gagal total saat proses penjadwalan ulang semua notifikasi',
          e: e, st: st);
    }
  }

  Future<List<ActiveCustomerDetailModel>>
      getAllActiveCustomersWithDetails() async {
    final db = await dbHelper.database;
    Log.info(
        'Mengambil semua pelanggan aktif dengan detail yang belum berakhir (JOIN)');

    final query = '''
      SELECT
        ac.*,
        c.${NamaKolom.name} as customer_name,
        p.${NamaKolom.name} as package_name
      FROM $_tableName ac
      LEFT JOIN $_customerTableName c ON ac.${NamaKolom.customerId} = c.${NamaKolom.id}
      LEFT JOIN $_packageTableName p ON ac.${NamaKolom.packageId} = p.${NamaKolom.id}
      WHERE ac.${NamaKolom.isDeleted} = 0
        AND ac.${NamaKolom.endDate} >= ?
    ''';

    try {
      final List<Map<String, dynamic>> maps = await db.rawQuery(
        query,
        [_nowUtc.millisecondsSinceEpoch],
      );
      Log.info(
          'Berhasil mengambil ${maps.length} pelanggan aktif yang belum berakhir dengan detail.');

      return List.generate(maps.length, (final i) {
        final map = maps[i];
        return ActiveCustomerDetailModel(
          activeCustomer: ActiveCustomerModel.fromSqlite(map),
          customerName: map['customer_name'] as String? ?? 'Tanpa Nama',
          packageName: map['package_name'] as String? ?? 'Tanpa Paket',
        );
      });
    } on Exception catch (e, st) {
      Log.error(
          'Gagal melakukan query JOIN untuk pelanggan aktif yang belum berakhir',
          e: e,
          st: st);
      rethrow;
    }
  }

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

      await scheduleNotification(customerToSave);

      Log.info('Active customer ID: $newId berhasil dibuat di $_tableName');
      return customerToSave;
    } on Exception catch (e, st) {
      Log.error('Gagal membuat active customer', e: e, st: st);
      rethrow;
    }
  }

  Future<List<ActiveCustomerModel>> getAllActiveCustomers() async {
    try {
      final db = await dbHelper.database;
      Log.info('Mengambil semua active customer dari tabel $_tableName');

      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: '${NamaKolom.isDeleted} = ?',
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

  Future<ActiveCustomerModel?> getActiveCustomerById(final String id) async {
    try {
      final db = await dbHelper.database;
      Log.info('Mencari active customer dengan ID: $id di tabel $_tableName');

      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: '${NamaKolom.id} = ?',
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
            where: '${NamaKolom.id} = ?',
            whereArgs: [customerToSave.id],
          );
        },
        fromServer: fromServer,
      );

      await scheduleNotification(customerToSave);
      Log.info('Active customer ID: ${customerToSave.id} berhasil diperbarui');

      return customerToSave;
    } on Exception catch (e, st) {
      Log.error('Gagal memperbarui active customer ID: ${activeCustomer.id}',
          e: e, st: st);
      rethrow;
    }
  }

  Future<void> scheduleNotification(
      final ActiveCustomerModel activeCustomer) async {
    try {
      Log.info(
          '(RE)SCHEDULING: Menjadwalkan notifikasi untuk active customer ID: ${activeCustomer.id}');

      final customer = await _customerOperation
          .ambilBerdasarkanId(activeCustomer.customerId);
      final customerName = customer?.name ?? 'Tanpa Nama';

      await _notifikasiServis.batalNotifikasi(activeCustomer.id.hashCode);
      await _notifikasiServis.batalNotifikasi((activeCustomer.id.hashCode + 1));
      await _notifikasiServis.batalNotifikasi((activeCustomer.id.hashCode + 2));
      Log.info(
          'Membatalkan notifikasi yang ada sebelum menjadwalkan ulang notifiaksi');

      final exactTime = activeCustomer.endDate;
      if (exactTime.isAfter(DateTime.now())) {
        await _notifikasiServis.jadwalNotifikasi(
          id: (activeCustomer.id.hashCode + 2),
          title: 'Masa Aktif Habis!',
          body: 'Paket WiFi untuk $customerName telah berakhir sekarang.',
          jadwal: exactTime,
        );
      }

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

      Log.info('Penjadwalan notifikasi selesai untuk ID: ${activeCustomer.id}',
          {'h3': h3Schedule, 'h1': h1Schedule, 'h0': exactTime});
    } on Exception catch (e, st) {
      Log.error('Gagal menjadwalkan notifikasi untuk ID: ${activeCustomer.id}',
          e: e, st: st);
    }
  }

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
            where: '${NamaKolom.id} = ?',
            whereArgs: [id],
          );

          await _notifikasiServis.batalNotifikasi(id.hashCode);
          await _notifikasiServis.batalNotifikasi((id.hashCode + 1));
          await _notifikasiServis.batalNotifikasi((id.hashCode + 2));
          Log.info('Notifikasi telah di batalkan pada fungsi softDelete');
        },
        fromServer: fromServer,
      );

      Log.info('Active customer ID: $id berhasil diarsipkan');
    } on Exception catch (e, st) {
      Log.error('Gagal mengarsipkan active customer ID: $id', e: e, st: st);
      rethrow;
    }
  }

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
                '${NamaKolom.archivedAt} IS NOT NULL AND ${NamaKolom.archivedAt} < ?',
            whereArgs: [deadline.millisecondsSinceEpoch],
          );

          if (expiredCustomers.isEmpty) {
            Log.info('Tidak ada active customer diarsipkan lebih dari 30 hari');
            return;
          }

          final idsToDelete = expiredCustomers
              .map((final map) => map[NamaKolom.id] as String)
              .toList();

          final count = await txn.delete(
            _tableName,
            where:
                '${NamaKolom.id} IN (${List.filled(idsToDelete.length, '?').join(',')})',
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

  Future<int> archiveExpiredCustomers({bool fromServer = false}) async {
    try {
      Log.info('Memeriksa active customer kadaluarsa');
      final db = await dbHelper.database;

      final List<Map<String, dynamic>> expiredCustomers = await db.query(
        _tableName,
        where: '${NamaKolom.endDate} < ? AND ${NamaKolom.isDeleted} = 0',
        whereArgs: [_nowUtc.millisecondsSinceEpoch],
      );

      if (expiredCustomers.isEmpty) {
        Log.info('Tidak ada active customer kadaluarsa');
        return 0;
      }

      final idsToArchive =
          expiredCustomers.map((final p) => p[NamaKolom.id] as String).toList();

      await _baseOperation.runComplexOperation<void>(
        (final Transaction txn) async {
          await txn.update(
            _tableName,
            {
              NamaKolom.isDeleted: 1,
              NamaKolom.archivedAt: _nowUtc.millisecondsSinceEpoch,
              NamaKolom.updatedAt: _nowUtc.millisecondsSinceEpoch,
            },
            where:
                '${NamaKolom.id} IN (${List.filled(idsToArchive.length, '?').join(',')})',
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
              NamaKolom.isDeleted: 1,
              NamaKolom.archivedAt: _nowUtc.millisecondsSinceEpoch,
              NamaKolom.updatedAt: _nowUtc.millisecondsSinceEpoch,
            },
            where:
                '${NamaKolom.id} IN (${List.filled(idsToArchive.length, '?').join(',')})',
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

  Future<List<ActiveCustomerModel>> ambilBerdasarkanIds(
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
        where: '${NamaKolom.id} IN ($placeholders)',
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
