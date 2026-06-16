// path: lib/fitur/pelanggan_aktif/operasi/pelanggan_aktif_op_sqlite.dart

import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/notfikasi/layanan_notifikasi.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_sqlite.dart';
import 'package:wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/model/active_customer_detail_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_operation.dart';

class PelangganAktifOpSqlite {
  final SqliteDatabase sqliteDb;
  final BaseOpSqlite _baseOpSqlite;
  final LayananNotifikasi _layananNotifikasi;
  final PelangganOpSqlite _pelangganOpSqlite;
  final String _tableName = NamaTabel.pelangganAktif;
  final String _namaTabelCustomer = NamaTabel.pelanggan;
  final String _namaTabelPaket = NamaTabel.paket;

  DateTime get _nowUtc => DateTime.now().toUtc();

  PelangganAktifOpSqlite({
    required this.sqliteDb,
    required BaseOpSqlite baseOpSqlite,
    required PelangganOpSqlite pelangganOpSqlite,
    required LayananNotifikasi layananNotifikasi,
  })  : _baseOpSqlite = baseOpSqlite,
        _pelangganOpSqlite = pelangganOpSqlite,
        _layananNotifikasi = layananNotifikasi {
    Log.info('ActiveCustomerOperation diinisialisasi - Tabel: $_tableName');
  }

  Future<void> rescheduleAllNotifications() async {
    Log.info('MEMULAI PROSES PENJADWALAN ULANG SEMUA NOTIFIKASI...');
    try {
      final List<PelangganAktifModel> pelangganAktif = await getALl();

      if (pelangganAktif.isEmpty) {
        Log.info('Tidak ada pelanggan aktif untuk dijadwalkan ulang.');
        return;
      }

      Log.info(
          'Ditemukan ${pelangganAktif.length} pelanggan aktif. Menjadwalkan ulang satu per satu...');

      for (final activeCustomer in pelangganAktif) {
        await scheduleNotification(activeCustomer);
      }

      Log.info('PROSES PENJADWALAN ULANG SEMUA NOTIFIKASI SELESAI.');
    } on Exception catch (e, st) {
      Log.error('Gagal total saat proses penjadwalan ulang semua notifikasi',
          e: e, s: st);
    }
  }

  Future<List<DetailPelangganAktifModel>>
      getAllActiveCustomersWithDetails() async {
    final db = await sqliteDb.database;
    Log.info(
        'Mengambil semua pelanggan aktif dengan detail yang belum berakhir (JOIN)');

    final query = '''
      SELECT
        ac.*,
        c.${NamaKolom.nama} as customer_name,
        p.${NamaKolom.nama} as package_name
      FROM $_tableName ac
      LEFT JOIN $_namaTabelCustomer c ON ac.${NamaKolom.idPelanggan} = c.${NamaKolom.id}
      LEFT JOIN $_namaTabelPaket p ON ac.${NamaKolom.idPaket} = p.${NamaKolom.id}
      WHERE ac.${NamaKolom.diHapus} = 0
        AND ac.${NamaKolom.tangglberakhir} >= ?
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
        return DetailPelangganAktifModel(
          pelangganAktif: PelangganAktifModel.fromSqlite(map),
          namaPelanggan: map['customer_name'] as String? ?? 'Tanpa Nama',
          namaPaket: map['package_name'] as String? ?? 'Tanpa Paket',
        );
      });
    } on Exception catch (e, st) {
      Log.error(
          'Gagal melakukan query JOIN untuk pelanggan aktif yang belum berakhir',
          e: e,
          s: st);
      rethrow;
    }
  }

  Future<PelangganAktifModel> tambahPelangganAktif(
    final PelangganAktifModel pelangganAktif, {
    final bool fromServer = false,
  }) async {
    try {
      final customerToSave = pelangganAktif.copyWith(
        diperbaruiPada: _nowUtc,
      );

      await _baseOpSqlite.runComplexOperation<void>(
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

      return customerToSave;
    } on Exception catch (e, st) {
      Log.error('Gagal membuat active customer', e: e, s: st);
      rethrow;
    }
  }

  Future<List<PelangganAktifModel>> getALl() async {
    try {
      final db = await sqliteDb.database;
      Log.info('Mengambil semua active customer dari tabel $_tableName');

      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: '${NamaKolom.diHapus} = ?',
        whereArgs: [0],
      );

      Log.info('Berhasil mengambil ${maps.length} active customer');
      return List.generate(
        maps.length,
        (final i) => PelangganAktifModel.fromSqlite(maps[i]),
      );
    } on Exception catch (e, st) {
      Log.error('Gagal mengambil semua active customer', e: e, s: st);
      rethrow;
    }
  }

  Future<PelangganAktifModel?> getById(final String id) async {
    try {
      final db = await sqliteDb.database;
      Log.info('Mencari active customer dengan ID: $id di tabel $_tableName');

      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: '${NamaKolom.id} = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        final activeCustomer = PelangganAktifModel.fromSqlite(maps.first);
        Log.info('Active customer ID: $id ditemukan');
        return activeCustomer;
      }

      Log.info('Active customer ID: $id tidak ditemukan');
      return null;
    } on Exception catch (e, st) {
      Log.error('Gagal mengambil active customer ID: $id', e: e, s: st);
      rethrow;
    }
  }

  Future<PelangganAktifModel> updateActiveCustomer(
    final PelangganAktifModel activeCustomer, {
    final bool fromServer = false,
  }) async {
    try {
      final customerToSave = activeCustomer.copyWith(
        diperbaruiPada: _nowUtc,
      );

      Log.info('Memperbarui active customer ID: ${customerToSave.id}');

      await _baseOpSqlite.runComplexOperation<void>(
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
          e: e, s: st);
      rethrow;
    }
  }

  Future<void> scheduleNotification(
      final PelangganAktifModel activeCustomer) async {
    try {
      Log.info(
          '(RE)SCHEDULING: Menjadwalkan notifikasi untuk active customer ID: ${activeCustomer.id}');

      final pelanggan = await _pelangganOpSqlite
          .ambilBerdasarkanId(activeCustomer.idPelanggan);
      final customerName = pelanggan?.nama ?? 'Tanpa Nama';

      await _layananNotifikasi.batalNotifikasi(activeCustomer.id.hashCode);
      await _layananNotifikasi
          .batalNotifikasi((activeCustomer.id.hashCode + 1));
      await _layananNotifikasi
          .batalNotifikasi((activeCustomer.id.hashCode + 2));
      Log.info(
          'Membatalkan notifikasi yang ada sebelum menjadwalkan ulang notifiaksi');

      final tanggalBerakhir = activeCustomer.tanggalBerakhir;
      if (tanggalBerakhir.isAfter(DateTime.now())) {
        await _layananNotifikasi.jadwalNotifikasi(
          id: (activeCustomer.id.hashCode + 2),
          title: 'Masa Aktif Habis!',
          body: 'Paket WiFi untuk $customerName telah berakhir sekarang.',
          jadwal: tanggalBerakhir,
        );
      }

      final jadwalH1 =
          activeCustomer.tanggalBerakhir.subtract(const Duration(days: 1));
      if (jadwalH1.isAfter(DateTime.now())) {
        await _layananNotifikasi.jadwalNotifikasi(
          id: activeCustomer.id.hashCode,
          title: 'Paket Akan Segera Berakhir',
          body: 'Paket untuk pelanggan $customerName akan berakhir besok.',
          jadwal: jadwalH1,
        );
      }

      final jadwalH3 =
          activeCustomer.tanggalBerakhir.subtract(const Duration(days: 3));
      if (jadwalH3.isAfter(DateTime.now())) {
        await _layananNotifikasi.jadwalNotifikasi(
          id: (activeCustomer.id.hashCode + 1),
          title: 'Pengingat Paket',
          body:
              'Paket untuk pelanggan $customerName akan berakhir dalam 3 hari.',
          jadwal: jadwalH3,
        );
      }

      Log.info('Penjadwalan notifikasi selesai untuk ID: ${activeCustomer.id}',
          {'h3': jadwalH3, 'h1': jadwalH1, 'h0': tanggalBerakhir});
    } on Exception catch (e, st) {
      Log.error('Gagal menjadwalkan notifikasi untuk ID: ${activeCustomer.id}',
          e: e, s: st);
    }
  }

  Future<void> sisipkanAtauPerbaruiBatch(
    final List<PelangganAktifModel> items, {
    final bool fromServer = false,
  }) async {
    try {
      Log.info(
          'Memproses batch ${items.length} active customer di $_tableName');

      final data = items
          .map(
            (final item) => item.copyWith(diperbaruiPada: _nowUtc).toSqlite(),
          )
          .toList();

      await _baseOpSqlite.sisipkanAtauPerbaruiBatch(
        _tableName,
        data,
        dariServer: fromServer,
      );

      Log.info('Batch ${items.length} active customer berhasil diproses');
    } on Exception catch (e, st) {
      Log.error('Gagal memproses batch ${items.length} active customer',
          e: e, s: st);
      rethrow;
    }
  }

  Future<void> softDelete(
    final String id, {
    final bool fromServer = false,
  }) async {
    try {
      Log.info('Mengarsipkan active customer ID: $id');

      final activeCustomer = await getById(id);
      if (activeCustomer == null) {
        Log.info('Active customer ID: $id tidak ditemukan');
        return;
      }

      await _baseOpSqlite.runComplexOperation<void>(
        (Transaction txn) async {
          final archivedCustomer = activeCustomer.copyWith(
            diperbaruiPada: _nowUtc,
            diHapus: true,
            diarsipkanPada: _nowUtc,
          );

          await txn.update(
            _tableName,
            archivedCustomer.toSqlite(),
            where: '${NamaKolom.id} = ?',
            whereArgs: [id],
          );

          await _layananNotifikasi.batalNotifikasi(id.hashCode);
          await _layananNotifikasi.batalNotifikasi((id.hashCode + 1));
          await _layananNotifikasi.batalNotifikasi((id.hashCode + 2));
          Log.info('Notifikasi telah di batalkan pada fungsi softDelete');
        },
        fromServer: fromServer,
      );

      Log.info('Active customer ID: $id berhasil diarsipkan');
    } on Exception catch (e, st) {
      Log.error('Gagal mengarsipkan active customer ID: $id', e: e, s: st);
      rethrow;
    }
  }

  Future<void> hapusPermanenDataSoftDelete({
    final bool fromServer = false,
  }) async {
    try {
      await _baseOpSqlite.runComplexOperation<void>(
        (final Transaction txn) async {
          final deadline = _nowUtc.subtract(const Duration(days: 30));

          final List<Map<String, dynamic>> expiredCustomers = await txn.query(
            _tableName,
            where:
                '${NamaKolom.diarsipkanPada} IS NOT NULL AND ${NamaKolom.diarsipkanPada} < ?',
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
          e: e, s: st);
      rethrow;
    }
  }

  Future<int> arsipkanLanggananKadaluarsa({bool fromServer = false}) async {
    try {
      Log.info('Memeriksa active customer kadaluarsa');
      final db = await sqliteDb.database;

      final List<Map<String, dynamic>> expiredCustomers = await db.query(
        _tableName,
        where: '${NamaKolom.tangglberakhir} < ? AND ${NamaKolom.diHapus} = 0',
        whereArgs: [_nowUtc.millisecondsSinceEpoch],
      );

      if (expiredCustomers.isEmpty) {
        Log.info('Tidak ada active customer kadaluarsa');
        return 0;
      }

      final idsToArchive =
          expiredCustomers.map((final p) => p[NamaKolom.id] as String).toList();

      await _baseOpSqlite.runComplexOperation<void>(
        (final Transaction txn) async {
          await txn.update(
            _tableName,
            {
              NamaKolom.diHapus: 1,
              NamaKolom.diarsipkanPada: _nowUtc.millisecondsSinceEpoch,
              NamaKolom.diperbaruiPada: _nowUtc.millisecondsSinceEpoch,
            },
            where:
                '${NamaKolom.id} IN (${List.filled(idsToArchive.length, '?').join(',')})',
            whereArgs: idsToArchive,
          );

          for (final id in idsToArchive) {
            await _layananNotifikasi.batalNotifikasi(id.hashCode);
            await _layananNotifikasi.batalNotifikasi((id.hashCode + 1));
            await _layananNotifikasi.batalNotifikasi((id.hashCode + 2));
          }
        },
        fromServer: fromServer,
      );

      Log.info(
          '${idsToArchive.length} active customer kadaluarsa telah diarsipkan');
      return idsToArchive.length;
    } on Exception catch (e, st) {
      Log.error('Gagal mengarsipkan active customer kadaluarsa', e: e, s: st);
      rethrow;
    }
  }

  Future<int> softDeleteAll({final bool fromServer = false}) async {
    try {
      Log.info('Mengarsipkan SEMUA active customer');
      final allCustomers = await getALl();

      if (allCustomers.isEmpty) {
        Log.info('Tidak ada active customer untuk diarsipkan');
        return 0;
      }

      final idsToArchive = allCustomers.map((final p) => p.id).toList();

      await _baseOpSqlite.runComplexOperation<void>(
        (final Transaction txn) async {
          await txn.update(
            _tableName,
            {
              NamaKolom.diHapus: 1,
              NamaKolom.diarsipkanPada: _nowUtc.millisecondsSinceEpoch,
              NamaKolom.diperbaruiPada: _nowUtc.millisecondsSinceEpoch,
            },
            where:
                '${NamaKolom.id} IN (${List.filled(idsToArchive.length, '?').join(',')})',
            whereArgs: idsToArchive,
          );

          for (final id in idsToArchive) {
            await _layananNotifikasi.batalNotifikasi(id.hashCode);
            await _layananNotifikasi.batalNotifikasi((id.hashCode + 1));
            await _layananNotifikasi.batalNotifikasi((id.hashCode + 2));
          }
        },
        fromServer: fromServer,
      );

      Log.info('${idsToArchive.length} active customer telah diarsipkan');
      return idsToArchive.length;
    } on Exception catch (e, st) {
      Log.error('Gagal mengarsipkan semua active customer', e: e, s: st);
      rethrow;
    }
  }

  Future<List<PelangganAktifModel>> ambilBerdasarkanIds(
    final List<String> ids,
  ) async {
    try {
      if (ids.isEmpty) {
        Log.info('getActiveCustomersByIds dipanggil dengan list ID kosong');
        return [];
      }

      final db = await sqliteDb.database;
      final placeholders = List.filled(ids.length, '?').join(',');
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: '${NamaKolom.id} IN ($placeholders)',
        whereArgs: ids,
      );

      Log.info('Ditemukan ${maps.length} dari ${ids.length} active customer');
      return List.generate(maps.length, (final i) {
        return PelangganAktifModel.fromSqlite(maps[i]);
      });
    } on Exception catch (e, st) {
      Log.error('Gagal mengambil active customer berdasarkan IDs', e: e, s: st);
      rethrow;
    }
  }
}
