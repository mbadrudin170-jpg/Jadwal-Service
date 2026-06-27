// path: lib/fitur/pelanggan_aktif/operasi/pelanggan_aktif_op_sqlite.dart

import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/notfikasi/layanan_notifikasi.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_sqlite.dart';
import 'package:wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_sqlite.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_op_sqlite.dart';

class PelangganAktifOpSqlite {
  final SqliteDatabase sqliteDb;
  final BaseOpSqlite _baseOpSqlite;
  final LayananNotifikasi _layananNotifikasi;
  final PelangganOpSqlite _pelangganOpSqlite;
  final TransaksiOpSqlite _transaksiOpSqlite;
  final String _namaTabel = NamaTabel.pelangganAktif;
  final String _namaTabelCustomer = NamaTabel.pelanggan;
  final String _namaTabelPaket = NamaTabel.paket;

  DateTime get _nowUtc => DateTime.now().toUtc();

  PelangganAktifOpSqlite({
    required this.sqliteDb,
    required BaseOpSqlite baseOpSqlite,
    required PelangganOpSqlite pelangganOpSqlite,
    required LayananNotifikasi layananNotifikasi,
    required TransaksiOpSqlite transaksiOpSqlite,
  }) : _baseOpSqlite = baseOpSqlite,
       _pelangganOpSqlite = pelangganOpSqlite,
       _layananNotifikasi = layananNotifikasi,
       _transaksiOpSqlite = transaksiOpSqlite {
    Log.info('PelangganAktifOperation diinisialisasi - Tabel: $_namaTabel');
  }

  Future<void> rescheduleAllNotifications() async {
    Log.info('MEMULAI PROSES PENJADWALAN ULANG SEMUA NOTIFIKASI...');
    try {
      final List<PelangganAktifModel> pelangganAktif = await ambilSemua();

      if (pelangganAktif.isEmpty) {
        Log.info('Tidak ada pelanggan aktif untuk dijadwalkan ulang.');
        return;
      }

      Log.info(
        'Ditemukan ${pelangganAktif.length} pelanggan aktif. Menjadwalkan ulang satu per satu...',
      );

      for (final pelangganAktif in pelangganAktif) {
        await scheduleNotification(pelangganAktif);
      }

      Log.info('PROSES PENJADWALAN ULANG SEMUA NOTIFIKASI SELESAI.');
    } on Exception catch (e, st) {
      Log.error(
        'Gagal total saat proses penjadwalan ulang semua notifikasi',
        e: e,
        s: st,
      );
    }
  }

  Future<List<DetailPelangganAktifModel>>
  ambilSemuaPelangganAktifDenganDetail() async {
    final db = await sqliteDb.database;
    Log.info(
      'Mengambil semua pelanggan aktif dengan detail yang belum berakhir (JOIN)',
    );

    final query =
        '''
      SELECT
        ac.*,
        c.${NamaKolom.nama} as customer_name,
        p.${NamaKolom.nama} as package_name
      FROM $_namaTabel ac
      LEFT JOIN $_namaTabelCustomer c ON ac.${NamaKolom.idPelanggan} = c.${NamaKolom.id}
      LEFT JOIN $_namaTabelPaket p ON ac.${NamaKolom.idPaket} = p.${NamaKolom.id}
      WHERE ac.${NamaKolom.dihapus} = 0
        AND ac.${NamaKolom.tanggalBerakhir} >= ?
    ''';

    try {
      final List<Map<String, dynamic>> maps = await db.rawQuery(query, [
        _nowUtc.millisecondsSinceEpoch,
      ]);
      Log.info(
        'Berhasil mengambil ${maps.length} pelanggan aktif yang belum berakhir dengan detail.',
      );

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
        s: st,
      );
      rethrow;
    }
  }

  Future<PelangganAktifModel> tambahPelangganAktif(
    final PelangganAktifModel pelangganAktif, {
    final bool fromServer = false,
  }) async {
    try {
      final customerToSave = pelangganAktif.copyWith(diperbaruiPada: _nowUtc);

      await _baseOpSqlite.operasiKompleks<void>((final Transaction txn) async {
        final data = customerToSave.toSqlite();
        await txn.insert(
          _namaTabel,
          data,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }, dariServer: fromServer);

      await scheduleNotification(customerToSave);

      return customerToSave;
    } on Exception catch (e, st) {
      Log.error('Gagal membuat active customer', e: e, s: st);
      rethrow;
    }
  }

  Future<List<PelangganAktifModel>> ambilSemua() async {
    try {
      final db = await sqliteDb.database;
      Log.info('Mengambil semua active customer dari tabel $_namaTabel');

      final List<Map<String, dynamic>> maps = await db.query(
        _namaTabel,
        where: '${NamaKolom.dihapus} = ?',
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

  Future<PelangganAktifModel?> ambilBerdasarkanid(final String id) async {
    try {
      final db = await sqliteDb.database;
      Log.info('Mencari active customer dengan ID: $id di tabel $_namaTabel');

      final List<Map<String, dynamic>> maps = await db.query(
        _namaTabel,
        where: '${NamaKolom.id} = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        final pelangganAktif = PelangganAktifModel.fromSqlite(maps.first);
        Log.info('Active customer ID: $id ditemukan');
        return pelangganAktif;
      }

      Log.info('Active customer ID: $id tidak ditemukan');
      return null;
    } on Exception catch (e, st) {
      Log.error('Gagal mengambil active customer ID: $id', e: e, s: st);
      rethrow;
    }
  }

  Future<PelangganAktifModel> updatePelangganAktif(
    final PelangganAktifModel pelangganAktif, {
    final bool fromServer = false,
  }) async {
    try {
      final customerToSave = pelangganAktif.copyWith(diperbaruiPada: _nowUtc);
      Log.info('Memperbarui active customer ID: ${customerToSave.id}');
      await _baseOpSqlite.operasiKompleks<void>((Transaction txn) async {
        final data = customerToSave.toSqlite();
        await txn.update(
          _namaTabel,
          data,
          where: '${NamaKolom.id} = ?',
          whereArgs: [customerToSave.id],
        );
      }, dariServer: fromServer);
      await scheduleNotification(customerToSave);
      Log.info('Active customer ID: ${customerToSave.id} berhasil diperbarui');
      return customerToSave;
    } on Exception catch (e, st) {
      Log.error(
        'Gagal memperbarui active customer ID: ${pelangganAktif.id}',
        e: e,
        s: st,
      );
      rethrow;
    }
  }

  Future<void> scheduleNotification(PelangganAktifModel pelangganAktif) async {
    try {
      Log.info(
        '(RE)SCHEDULING: Menjadwalkan notifikasi untuk active customer ID: ${pelangganAktif.id}',
      );

      final pelanggan = await _pelangganOpSqlite.ambilBerdasarkanId(
        pelangganAktif.idPelanggan,
      );
      final customerName = pelanggan?.nama ?? 'Tanpa Nama';

      await _layananNotifikasi.batalNotifikasi(pelangganAktif.id.hashCode);
      await _layananNotifikasi.batalNotifikasi(
        (pelangganAktif.id.hashCode + 1),
      );
      await _layananNotifikasi.batalNotifikasi(
        (pelangganAktif.id.hashCode + 2),
      );
      Log.info(
        'Membatalkan notifikasi yang ada sebelum menjadwalkan ulang notifiaksi',
      );

      final tanggalBerakhir = pelangganAktif.tanggalBerakhir;
      if (tanggalBerakhir.isAfter(DateTime.now())) {
        await _layananNotifikasi.jadwalNotifikasi(
          id: (pelangganAktif.id.hashCode + 2),
          judul: 'Masa Aktif Habis!',
          pesan: 'Paket WiFi untuk $customerName telah berakhir sekarang.',
          jadwal: tanggalBerakhir,
        );
      }

      final jadwalH1 = pelangganAktif.tanggalBerakhir.subtract(
        const Duration(days: 1),
      );
      if (jadwalH1.isAfter(DateTime.now())) {
        await _layananNotifikasi.jadwalNotifikasi(
          id: pelangganAktif.id.hashCode,
          judul: 'Paket Akan Segera Berakhir',
          pesan: 'Paket untuk pelanggan $customerName akan berakhir besok.',
          jadwal: jadwalH1,
        );
      }

      final jadwalH3 = pelangganAktif.tanggalBerakhir.subtract(
        const Duration(days: 3),
      );
      if (jadwalH3.isAfter(DateTime.now())) {
        await _layananNotifikasi.jadwalNotifikasi(
          id: (pelangganAktif.id.hashCode + 1),
          judul: 'Pengingat Paket',
          pesan:
              'Paket untuk pelanggan $customerName akan berakhir dalam 3 hari.',
          jadwal: jadwalH3,
        );
      }

      Log.info(
        'Penjadwalan notifikasi selesai untuk ID: ${pelangganAktif.id}',
        {'h3': jadwalH3, 'h1': jadwalH1, 'h0': tanggalBerakhir},
      );
    } catch (e, st) {
      Log.error(
        'Gagal menjadwalkan notifikasi untuk ID: ${pelangganAktif.id}',
        e: e,
        s: st,
      );
    }
  }

  Future<void> sisipkanAtauPerbaruiBatch(
    final List<PelangganAktifModel> daftarPelangganAktif, {
    final bool dariServer = false,
  }) async {
    try {
      Log.info(
        'Memproses batch ${daftarPelangganAktif.length} active customer di $_namaTabel',
      );

      final data = daftarPelangganAktif
          .map((item) => item.copyWith(diperbaruiPada: _nowUtc).toSqlite())
          .toList();

      await _baseOpSqlite.sisipkanAtauPerbaruiBatch(
        _namaTabel,
        data,
        dariServer: dariServer,
      );

      Log.info(
        'Batch ${daftarPelangganAktif.length} active customer berhasil diproses',
      );
    } catch (e, st) {
      Log.error(
        'Gagal memproses batch ${daftarPelangganAktif.length} active customer',
        e: e,
        s: st,
      );
      rethrow;
    }
  }

  Future<void> softDelete(String id, {bool dariServer = false}) async {
    try {
      Log.info('Mengarsipkan active customer ID: $id');

      final pelangganAktif = await ambilBerdasarkanid(id);
      if (pelangganAktif == null) {
        Log.info('Active customer ID: $id tidak ditemukan');
        return;
      }

      await _baseOpSqlite.operasiKompleks<void>((Transaction txn) async {
        final archivedCustomer = pelangganAktif.copyWith(
          diperbaruiPada: _nowUtc,
          diHapus: true,
          diarsipkanPada: _nowUtc,
        );

        await txn.update(
          _namaTabel,
          archivedCustomer.toSqlite(),
          where: '${NamaKolom.id} = ?',
          whereArgs: [id],
        );

        await _layananNotifikasi.batalNotifikasi(id.hashCode);
        await _layananNotifikasi.batalNotifikasi((id.hashCode + 1));
        await _layananNotifikasi.batalNotifikasi((id.hashCode + 2));

        Log.info('Notifikasi telah di batalkan pada fungsi softDelete');
      }, dariServer: dariServer);

      Log.info('Active customer ID: $id berhasil diarsipkan');
    } catch (e, st) {
      Log.error('Gagal mengarsipkan active customer ID: $id', e: e, s: st);
      rethrow;
    }
  }

  Future<void> softDeletePelangganAktifDanTransaksi(
    String idPelangganAKtif,
    String? idTransaksi, {
    bool dariServer = false,
  }) async {
    final pelangganAktif = await ambilBerdasarkanid(idPelangganAKtif);
    if (pelangganAktif == null) {
      Log.info('Pelanggan aktif dengan ID $idPelangganAKtif tidak ditemukan');
      return;
    }
    TransaksiModel? transaksi;
    if (idTransaksi != null) {
      transaksi = await _transaksiOpSqlite.ambilBerdasarkanId(idTransaksi);
      if (transaksi == null) {
        Log.info('Transaksi dengan ID $idTransaksi tidak ditemukan');
      }
    }
    await _baseOpSqlite.operasiKompleks<void>((Transaction txn) async {
      final archivedCustomer = pelangganAktif.copyWith(
        diperbaruiPada: _nowUtc,
        diHapus: true,
        diarsipkanPada: _nowUtc,
      );

      await txn.update(
        _namaTabel,
        archivedCustomer.toSqlite(),
        where: '${NamaKolom.id} = ?',
        whereArgs: [idPelangganAKtif],
      );
      if (idTransaksi != null && transaksi != null) {
        final transkasiArsip = transaksi.copyWith(
          diperbaruiPada: _nowUtc,
          diHapus: true,
          diarsipkanPada: _nowUtc,
        );

        await txn.update(
          NamaTabel.transaksi,
          transkasiArsip.toSqlite(),
          where: '${NamaKolom.id} = ?',
          whereArgs: [idTransaksi],
        );
      }
    });
  }

  Future<void> hapusPermanenDataSoftDelete({
    final bool dariServer = false,
  }) async {
    try {
      await _baseOpSqlite.operasiKompleks<void>((Transaction txn) async {
        final deadline = _nowUtc.subtract(const Duration(days: 30));

        final List<Map<String, dynamic>> expiredCustomers = await txn.query(
          _namaTabel,
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

        final jumlah = await txn.delete(
          _namaTabel,
          where:
              '${NamaKolom.id} IN (${List.filled(idsToDelete.length, '?').join(',')})',
          whereArgs: idsToDelete,
        );

        Log.info(
          '$jumlah active customer telah dihapus permanen dari $_namaTabel',
        );
      }, dariServer: dariServer);
    } catch (e, st) {
      Log.error(
        'Gagal menghapus permanen active customer diarsipkan',
        e: e,
        s: st,
      );
      rethrow;
    }
  }

  Future<int> arsipkanLanggananKadaluarsa({bool dariServer = false}) async {
    try {
      Log.info('Memeriksa active customer kadaluarsa');
      final db = await sqliteDb.database;

      final List<Map<String, dynamic>> expiredCustomers = await db.query(
        _namaTabel,
        where: '${NamaKolom.tanggalBerakhir} < ? AND ${NamaKolom.dihapus} = 0',
        whereArgs: [_nowUtc.millisecondsSinceEpoch],
      );

      if (expiredCustomers.isEmpty) {
        Log.info('Tidak ada active customer kadaluarsa');
        return 0;
      }

      final idsToArchive = expiredCustomers
          .map((final p) => p[NamaKolom.id] as String)
          .toList();

      await _baseOpSqlite.operasiKompleks<void>((final Transaction txn) async {
        await txn.update(
          _namaTabel,
          {
            NamaKolom.dihapus: 1,
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
      }, dariServer: dariServer);

      Log.info(
        '${idsToArchive.length} active customer kadaluarsa telah diarsipkan',
      );
      return idsToArchive.length;
    } catch (e, st) {
      Log.error('Gagal mengarsipkan active customer kadaluarsa', e: e, s: st);
      rethrow;
    }
  }

  Future<int> softDeleteAll({bool dariServer = false}) async {
    try {
      Log.info('Mengarsipkan SEMUA active customer');
      final pelangganAktif = await ambilSemua();

      if (pelangganAktif.isEmpty) {
        Log.info('Tidak ada active customer untuk diarsipkan');
        return 0;
      }

      final dataUntukDiarsip = pelangganAktif.map((p) => p.id).toList();

      await _baseOpSqlite.operasiKompleks<void>((final Transaction txn) async {
        await txn.update(
          _namaTabel,
          {
            NamaKolom.dihapus: 1,
            NamaKolom.diarsipkanPada: _nowUtc.millisecondsSinceEpoch,
            NamaKolom.diperbaruiPada: _nowUtc.millisecondsSinceEpoch,
          },
          where:
              '${NamaKolom.id} IN (${List.filled(dataUntukDiarsip.length, '?').join(',')})',
          whereArgs: dataUntukDiarsip,
        );

        for (final id in dataUntukDiarsip) {
          await _layananNotifikasi.batalNotifikasi(id.hashCode);
          await _layananNotifikasi.batalNotifikasi((id.hashCode + 1));
          await _layananNotifikasi.batalNotifikasi((id.hashCode + 2));
        }
      }, dariServer: dariServer);

      Log.info('${dataUntukDiarsip.length} active customer telah diarsipkan');
      return dataUntukDiarsip.length;
    } catch (e, st) {
      Log.error('Gagal mengarsipkan semua active customer', e: e, s: st);
      rethrow;
    }
  }

  Future<List<PelangganAktifModel>> ambilBerdasarkanIds(
    List<String> ids,
  ) async {
    try {
      if (ids.isEmpty) {
        Log.info('getPelangganAktifsByIds dipanggil dengan list ID kosong');
        return [];
      }

      final db = await sqliteDb.database;
      final placeholders = List.filled(ids.length, '?').join(',');
      final List<Map<String, dynamic>> maps = await db.query(
        _namaTabel,
        where: '${NamaKolom.id} IN ($placeholders)',
        whereArgs: ids,
      );

      Log.info('Ditemukan ${maps.length} dari ${ids.length} active customer');
      return List.generate(maps.length, (i) {
        return PelangganAktifModel.fromSqlite(maps[i]);
      });
    } catch (e, st) {
      Log.error('Gagal mengambil active customer berdasarkan IDs', e: e, s: st);
      rethrow;
    }
  }
}
