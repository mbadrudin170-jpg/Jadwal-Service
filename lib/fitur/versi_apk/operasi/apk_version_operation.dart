// path: lib/fitur/versi_apk/operasi/apk_version_operation.dart

import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/fitur/info_perangkat/enum/arsitektur_apk.dart';
import 'package:wifi/fitur/versi_apk/model/versi_apk_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_operation.dart';

/// Kelas untuk operasi terkait data versi APK user di database lokal.
class VersiApkOpSqlite {
  final SqliteDatabase sqliteDb;
  final String _namaTabel = NamaTabel.versiApkUser;
  final BaseOpSqlite _baseOpSqlite;

  /// Konstruktor untuk [VersiApkOpSqlite].
  VersiApkOpSqlite({
    required final BaseOpSqlite baseOpSqlite,
    required this.sqliteDb,
  }) : _baseOpSqlite = baseOpSqlite {
    Log.info(
      'VersiApkOpSqlite diinisialisasi - Tabel: $_namaTabel',
    );
  }

  // =========================
  // OPERASI TULIS (WRITE)
  // =========================

  /// Menambah [VersiApkModel] baru ke database.
  Future<void> tambahVersiApk(
    final VersiApkModel apkVersion, {
    final bool dariServer = false,
  }) async {
    Log.info(
      'Menambah versi APK user baru - ID: ${apkVersion.id}, Versi: ${apkVersion.versiTerkahir}',
    );

    try {
      await _baseOpSqlite.sisipkan(
        _namaTabel,
        apkVersion.toSqlite(),
        dariServer: dariServer,
      );
      Log.info(
        'Versi APK user berhasil ditambahkan ke tabel $_namaTabel - ID: ${apkVersion.id}',
      );
    } on Exception catch (e, st) {
      Log.error(
        'Gagal menambah versi APK user - ID: ${apkVersion.id}, Versi: ${apkVersion.versiTerkahir}',
        e: e,
        s: st,
      );
      rethrow;
    }
  }

  /// Memperbarui [VersiApkModel] yang ada di database.
  Future<void> perbaruiVersiApk(
    final VersiApkModel apkVersion, {
    final bool dariServer = false,
  }) async {
    Log.info(
      'Memperbarui versi APK user - ID: ${apkVersion.id}, Versi: ${apkVersion.versiTerkahir}',
    );

    try {
      await _baseOpSqlite.update(
        _namaTabel,
        apkVersion.toSqlite(),
        apkVersion.id,
        dariServer: dariServer,
      );
      Log.info(
        'Versi APK user berhasil diperbarui di tabel $_namaTabel - ID: ${apkVersion.id}',
      );
    } on Exception catch (e, st) {
      Log.error(
        'Gagal memperbarui versi APK user - ID: ${apkVersion.id}, Versi: ${apkVersion.versiTerkahir}',
        e: e,
        s: st,
      );
      rethrow;
    }
  }

  /// Melakukan soft delete pada [VersiApkModel] berdasarkan [id].
  Future<void> softDelete(
    final String id, {
    final bool dariServer = false,
  }) async {
    Log.info('Memulai soft delete untuk versi APK ID: $id');
    try {
      await _baseOpSqlite.softDelete(
        _namaTabel,
        id,
        dariServer: dariServer,
      );
      Log.info('Soft delete untuk versi APK ID: $id selesai.');
    } on Exception catch (e, st) {
      Log.error(
        'Gagal melakukan soft delete pada APK version ID: $id',
        e: e,
        s: st,
      );
      rethrow;
    }
  }

  /// Melakukan soft delete untuk semua [VersiApkModel] yang aktif.
  Future<int> softDeleteAll({final bool dariServer = false}) async {
    Log.info('Memulai proses soft delete untuk SEMUA versi APK aktif');
    try {
      final count = await _baseOpSqlite.softDeleteAll(
        _namaTabel,
        dariServer: dariServer,
      );
      Log.info('Proses soft delete semua APK versions selesai. Total: $count');
      return count;
    } on Exception catch (e, st) {
      Log.error(
        'Gagal melakukan soft delete untuk semua APK versions',
        e: e,
        s: st,
      );
      rethrow;
    }
  }

  /// Menyisipkan atau memperbarui sekumpulan [VersiApkModel] dalam satu batch.
  Future<void> sisipkanAtauPerbaruiBatch(
    final List<VersiApkModel> modelList, {
    final bool dariServer = false,
  }) async {
    Log.info(
      'Memulai operasi batch insert/update - Jumlah data: ${modelList.length}, Tabel: $_namaTabel',
    );

    if (modelList.isEmpty) {
      Log.info('Daftar model kosong, tidak ada data yang diproses dalam batch');
      return;
    }

    try {
      final mapList = modelList.map((final model) => model.toSqlite()).toList();
      await _baseOpSqlite.sisipkanAtauPerbaruiBatch(
        _namaTabel,
        mapList,
        dariServer: dariServer,
      );
      Log.info(
        'Operasi batch berhasil - ${mapList.length} data diproses di tabel $_namaTabel',
      );
    } on Exception catch (e, st) {
      Log.error(
        'Gagal melakukan operasi batch - Jumlah data: ${modelList.length}, Tabel: $_namaTabel',
        e: e,
        s: st,
      );
      rethrow;
    }
  }

  // =========================
  // OPERASI BACA (READ)
  // =========================

  /// Mengambil semua versi APK dari database.
  Future<List<VersiApkModel>> ambilSemuaVersiApk() async {
    Log.info(
      'Mengambil semua data versi APK dari tabel $_namaTabel (termasuk yang diarsipkan)',
    );

    try {
      final db = await sqliteDb.database;
      const orderBy = '${NamaKolom.diperbaruiPada} DESC';
      Log.info('Query: SELECT * FROM $_namaTabel ORDER BY $orderBy');

      final List<Map<String, dynamic>> maps = await db.query(
        _namaTabel,
        orderBy: orderBy,
      );

      final hasil = List.generate(
        maps.length,
        (final i) => VersiApkModel.fromSqlite(maps[i]),
      );

      int jumlahAktif = 0;
      int jumlahArsip = 0;
      for (final model in hasil) {
        if (model.diHapus) {
          jumlahArsip++;
        } else {
          jumlahAktif++;
        }
      }

      Log.info(
        'Berhasil mengambil ${hasil.length} data versi APK - Aktif: $jumlahAktif, Diarsipkan: $jumlahArsip',
      );
      return hasil;
    } on Exception catch (e, st) {
      Log.error(
        'Gagal mengambil semua data versi APK dari tabel $_namaTabel, mengembalikan list kosong',
        e: e,
        s: st,
      );
      return [];
    }
  }

  /// Mengambil semua versi APK yang aktif dari database.
  Future<List<VersiApkModel>> ambilSemuaVersiApkAktif() async {
    Log.info(
      'Mengambil semua versi APK aktif (${NamaKolom.diHapus} = 0) dari tabel $_namaTabel',
    );

    try {
      final db = await sqliteDb.database;
      const where = '${NamaKolom.diHapus} = 0';
      const orderBy = '${NamaKolom.diperbaruiPada} DESC';
      Log.info(
          'Query: SELECT * FROM $_namaTabel WHERE $where ORDER BY $orderBy');

      final maps = await db.query(
        _namaTabel,
        where: where,
        orderBy: orderBy,
      );

      final hasil = List.generate(
        maps.length,
        (final i) => VersiApkModel.fromSqlite(maps[i]),
      );

      Log.info('Berhasil mengambil ${hasil.length} versi APK aktif');

      for (int i = 0; i < (hasil.length < 3 ? hasil.length : 3); i++) {
        final v = hasil[i];
        Log.info(
          '  ${i + 1}. ID: ${v.id}, Versi: ${v.versiTerkahir}, Build Universal: ${v.nomorBuildTerakhir[ArsitekturApk.universal] ?? 0}',
        );
      }

      return hasil;
    } on Exception catch (e, st) {
      Log.error(
        'Gagal mengambil versi APK aktif dari tabel $_namaTabel, mengembalikan list kosong',
        e: e,
        s: st,
      );
      return [];
    }
  }

  /// Mengambil versi APK terbaru yang aktif dari database.
  Future<VersiApkModel?> getLatestApkVersion() async {
    Log.info('Mengambil versi APK terbaru (aktif) dari tabel $_namaTabel');

    try {
      final db = await sqliteDb.database;
      const where = '${NamaKolom.diHapus} = 0';
      const orderBy = '${NamaKolom.diperbaruiPada} DESC';
      Log.info(
          'Query: SELECT * FROM $_namaTabel WHERE $where ORDER BY $orderBy LIMIT 1');

      final maps = await db.query(
        _namaTabel,
        where: where,
        orderBy: orderBy,
        limit: 1,
      );

      if (maps.isNotEmpty) {
        final model = VersiApkModel.fromSqlite(maps.first);
        Log.info(
          'Versi APK terbaru ditemukan - ID: ${model.id}, Versi: ${model.versiTerkahir}, Build Universal: ${model.nomorBuildTerakhir[ArsitekturApk.universal] ?? 0}, Diperbarui: ${model.diperbaruiPada?.toIso8601String()}',
        );
        return model;
      } else {
        Log.info(
          'Tidak ada versi APK aktif yang ditemukan di tabel $_namaTabel',
        );
        return null;
      }
    } on Exception catch (e, st) {
      Log.error(
        'Gagal mengambil versi APK terbaru dari tabel $_namaTabel, mengembalikan null',
        e: e,
        s: st,
      );
      return null;
    }
  }

  /// Mengambil [VersiApkModel] berdasarkan [id].
  Future<VersiApkModel?> ambilBerdasarkanId(final String id) async {
    Log.info('Mengambil versi APK by ID: $id dari tabel $_namaTabel');

    try {
      final db = await sqliteDb.database;
      const where = 'id = ? AND ${NamaKolom.diHapus} = 0';
      Log.info('Query: SELECT * FROM $_namaTabel WHERE $where');

      final maps = await db.query(
        _namaTabel,
        where: where,
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        final model = VersiApkModel.fromSqlite(maps.first);
        Log.info(
          'Versi APK ditemukan - ID: $id, Versi: ${model.versiTerkahir}, Build Universal: ${model.nomorBuildTerakhir[ArsitekturApk.universal] ?? 0}, Catatan: ${model.catatanRilis.length > 50 ? "${model.catatanRilis.substring(0, 50)}..." : model.catatanRilis}',
        );
        return model;
      } else {
        Log.info(
          'Versi APK dengan ID: $id tidak ditemukan (mungkin sudah diarsipkan atau tidak ada)',
        );
        return null;
      }
    } on Exception catch (e, st) {
      Log.error(
        'Gagal mengambil versi APK by ID: $id dari tabel $_namaTabel, mengembalikan null',
        e: e,
        s: st,
      );
      return null;
    }
  }
}
