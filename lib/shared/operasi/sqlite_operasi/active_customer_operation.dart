// path: lib/shared/operasi/sqlite_operasi/active_customer_operation.dart
// diubah: Mengganti nama class dari OperasiPelangganAktif ke ActiveCustomerOperation.
// diubah: Menggunakan TableNameValue.get() untuk konsistensi nama tabel.
// diubah: Menggunakan BaseOperation untuk operasi tulis.

import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/notifikasi/servis/notifikasi_servis.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/model/active_customer_model.dart';
import 'package:wifi/shared/model/customer_state.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/customer_operation.dart';

class ActiveCustomerOperation {
  final DatabaseHelper dbHelper;
  final BaseOperation baseOperation;
  final CustomerOperation customerOperation;
  final NotifikasiServis notifikasiServis;

  final String _tableName = TableNameValue.get(TableName.activeCustomer);

  ActiveCustomerOperation({
    required this.dbHelper,
    required this.baseOperation,
    required this.customerOperation,
    required this.notifikasiServis,
  }) {
    Log.info('ActiveCustomerOperation diinisialisasi');
  }

  Future<void> tambahPelangganAktif(
    ActiveCustomerModel activeCustomer, {
    bool dariServer = false,
  }) async {
    Log.info(
        'Menambah atau memperbarui pelanggan aktif ID: ${activeCustomer.id}');
    try {
      final data = activeCustomer
          .copyWith(updatedAt: DateTime.now().toUtc())
          .toSqlite();

      await baseOperation.insert(
        _tableName,
        data,
        fromServer: dariServer,
      );

      await customerOperation.updateCustomer(
        (await customerOperation.getById(activeCustomer.customerId))!
            .copyWith(lastActiveAt: DateTime.now().toUtc()),
        fromServer: dariServer,
      );

      Log.info(
          'Pelanggan aktif ID: ${activeCustomer.id} berhasil ditambahkan/diperbarui');
    } catch (e, s) {
      Log.error(
        'Gagal menambah/memperbarui pelanggan aktif',
        e: e,
        st: s,
        data: activeCustomer.toSqlite(),
      );
      rethrow;
    }
  }

  Future<List<ActiveCustomerModel>> ambilSemuaPelangganAktif() async {
    Log.info('Mengambil semua data pelanggan aktif dari database lokal');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: '${ColumnNames.isDeleted} = 0',
      );
      Log.info('Ditemukan ${maps.length} pelanggan aktif');
      return List.generate(maps.length, (i) {
        return ActiveCustomerModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      Log.error('Gagal mengambil pelanggan aktif', e: e, st: s);
      return [];
    }
  }

  Future<ActiveCustomerModel?> ambilBerdasarkanId(String id) async {
    Log.info('Mencari pelanggan aktif berdasarkan ID: $id');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: '${ColumnNames.id} = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        Log.info('Pelanggan aktif ID: $id ditemukan');
        return ActiveCustomerModel.fromSqlite(maps.first);
      }
      Log.warning('Pelanggan aktif ID: $id tidak ditemukan');
      return null;
    } catch (e, s) {
      Log.error('Gagal mencari pelanggan aktif', e: e, st: s);
      return null;
    }
  }

  Future<List<ActiveCustomerModel>> ambilBerdasarkanIdPelanggan(
      String idPelanggan) async {
    Log.info('Mengambil semua paket aktif untuk pelanggan ID: $idPelanggan');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where:
            '${ColumnNames.customerId} = ? AND ${ColumnNames.isDeleted} = 0',
        whereArgs: [idPelanggan],
        orderBy: '${ColumnNames.endDate} DESC',
      );

      if (maps.isEmpty) {
        Log.info('Tidak ada paket aktif ditemukan untuk pelanggan $idPelanggan');
        return [];
      }

      Log.info('Ditemukan ${maps.length} paket aktif untuk pelanggan $idPelanggan');
      return List.generate(maps.length, (i) {
        return ActiveCustomerModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      Log.error('Gagal mengambil paket aktif pelanggan', e: e, st: s);
      return [];
    }
  }

  Future<void> perbaruiPelangganAktif(
    ActiveCustomerModel activeCustomer, {
    bool dariServer = false,
  }) async {
    Log.info('Memperbarui pelanggan aktif ID: ${activeCustomer.id}');
    try {
      final data = activeCustomer
          .copyWith(updatedAt: DateTime.now().toUtc())
          .toSqlite();
      await baseOperation.update(
        _tableName,
        data,
        activeCustomer.id,
        fromServer: dariServer,
      );
      Log.info('Pembaruan pelanggan aktif ID: ${activeCustomer.id} berhasil');
    } catch (e, s) {
      Log.error(
        'Gagal memperbarui pelanggan aktif',
        e: e,
        st: s,
        data: activeCustomer.toSqlite(),
      );
      rethrow;
    }
  }

  Future<void> hapusPelangganAktif(String id, {bool dariServer = false}) async {
    Log.info('Menghapus (soft delete) pelanggan aktif ID: $id');
    try {
      await baseOperation.softDelete(
        _tableName,
        id,
        fromServer: dariServer,
      );
      Log.info('Berhasil menghapus (soft delete) pelanggan aktif ID: $id');
    } catch (e, s) {
      Log.error('Gagal menghapus pelanggan aktif', e: e, st: s, data: {'id': id});
      rethrow;
    }
  }

  Future<List<CustomerState>> periksaStatusPelanggan() async {
    Log.info('Memeriksa status semua pelanggan aktif...');
    try {
      final db = await dbHelper.database;
      final now = DateTime.now();
      final threeDaysFromNow = now.add(const Duration(days: 3));

      final List<Map<String, dynamic>> results = await db.rawQuery(
        '''
      SELECT
        c.id AS customer_id,
        c.name AS customer_name,
        MIN(ac.endDate) AS earliest_expiry
      FROM
        ${TableNameValue.get(TableName.customer)} c
      LEFT JOIN
        $_tableName ac ON c.id = ac.customer_id
      WHERE
        c.isDeleted = 0
      GROUP BY
        c.id, c.name
      ''',
      );

      final customerStates = <CustomerState>[];
      for (final row in results) {
        final customerId = row['customer_id'] as String;
        final customerName = row['customer_name'] as String;
        final earliestExpiryMillis = row['earliest_expiry'] as int?;

        DateTime? earliestExpiry;
        if (earliestExpiryMillis != null) {
          earliestExpiry =
              DateTime.fromMillisecondsSinceEpoch(earliestExpiryMillis);
        }

        CustomerStatus status;
        if (earliestExpiry == null) {
          status = CustomerStatus.inactive;
        } else if (earliestExpiry.isBefore(now)) {
          status = CustomerStatus.expired;
        } else if (earliestExpiry.isBefore(threeDaysFromNow)) {
          status = CustomerStatus.expiringSoon;
        } else {
          status = CustomerStatus.active;
        }

        customerStates.add(CustomerState(
          customerId: customerId,
          customerName: customerName,
          status: status,
          expiryDate: earliestExpiry,
        ));

        // Kirim notifikasi jika akan kedaluwarsa atau sudah kedaluwarsa
        if (status == CustomerStatus.expiringSoon) {
          await notifikasiServis.tampilkanNotifikasiMasaAktifAkanHabis(
            idPelanggan: customerId,
            namaPelanggan: customerName,
            tanggalKedaluwarsa: earliestExpiry!,
          );
        } else if (status == CustomerStatus.expired) {
          await notifikasiServis.tampilkanNotifikasiMasaAktifHabis(
            idPelanggan: customerId,
            namaPelanggan: customerName,
          );
        }
      }

      Log.info('Pemeriksaan status pelanggan selesai. Total: ${results.length}');
      return customerStates;
    } catch (e, s) {
      Log.error('Gagal memeriksa status pelanggan', e: e, st: s);
      return [];
    }
  }

  Future<int> hapusSemuaPelangganAktif({bool dariServer = false}) async {
    Log.info('Menghapus (soft delete) semua pelanggan aktif');
    try {
      final count = await baseOperation.softDeleteAll(
        _tableName,
        fromServer: dariServer,
      );
      Log.info('Berhasil soft delete $count pelanggan aktif');
      return count;
    } catch (e, s) {
      Log.error('Gagal soft delete semua pelanggan aktif', e: e, st: s);
      rethrow;
    }
  }

  Future<List<ActiveCustomerModel>> ambilPerubahanSejak(DateTime sejak) async {
    Log.info(
        'Mengambil perubahan pelanggan aktif sejak ${sejak.toIso8601String()}');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: '${ColumnNames.updatedAt} > ?',
        whereArgs: [sejak.toUtc().millisecondsSinceEpoch],
      );
      Log.info('Ditemukan ${maps.length} perubahan pelanggan aktif');
      return List.generate(maps.length, (i) {
        return ActiveCustomerModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      Log.error('Gagal mengambil perubahan pelanggan aktif', e: e, st: s);
      rethrow;
    }
  }

  Future<void> sisipkanAtauPerbaruiBatch(
    List<ActiveCustomerModel> items, {
    bool dariServer = false,
  }) async {
    if (items.isEmpty) {
      Log.warning('Daftar batch pelanggan aktif kosong, operasi dibatalkan');
      return;
    }
    Log.info('Memulai batch insert/update untuk ${items.length} pelanggan aktif');
    try {
      final data = items
          .map((item) =>
              item.copyWith(updatedAt: DateTime.now().toUtc()).toSqlite())
          .toList();

      await baseOperation.insertOrUpdateBatch(
        _tableName,
        data,
        fromServer: dariServer,
      );
      Log.info('Batch pelanggan aktif berhasil dieksekusi');
    } catch (e, s) {
      Log.error('Gagal batch insert/update pelanggan aktif', e: e, st: s);
      rethrow;
    }
  }
}
