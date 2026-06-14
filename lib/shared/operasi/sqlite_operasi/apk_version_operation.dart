// path: lib/shared/operasi/sqlite_operasi/apk_version_operation.dart

import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/apk_architecture_enum.dart';
import 'package:wifi/fitur/versi_apk/model/versi_apk_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_operation.dart';

/// Kelas untuk operasi terkait data versi APK user di database lokal.
class ApkVersionOperation {
  final SqliteDatabase dbHelper;
  final String _tableName = NamaTabel.userApkVersion;
  final BaseOpSqlite _baseOperation;

  /// Konstruktor untuk [ApkVersionOperation].
  ApkVersionOperation({
    required final BaseOpSqlite baseOpSqlite,
    required this.dbHelper,
  }) : _baseOperation = baseOpSqlite {
    Log.info(
      'ApkVersionOperation diinisialisasi - Tabel: $_tableName, BaseOperation: ${"dari parameter"}',
    );
  }

  // =========================
  // OPERASI TULIS (WRITE)
  // =========================

  /// Menambah [VersiApkModel] baru ke database.
  Future<void> addApkVersion(
    final VersiApkModel apkVersion, {
    final bool fromServer = false,
  }) async {
    Log.info(
      'Menambah versi APK user baru - ID: ${apkVersion.id}, Versi: ${apkVersion.latestVersion}',
    );

    try {
      await _baseOperation.sisipkan(
        _tableName,
        apkVersion.toSqlite(),
        dariServer: fromServer,
      );
      Log.info(
        'Versi APK user berhasil ditambahkan ke tabel $_tableName - ID: ${apkVersion.id}',
      );
    } on Exception catch (e, st) {
      Log.error(
        'Gagal menambah versi APK user - ID: ${apkVersion.id}, Versi: ${apkVersion.latestVersion}',
        e: e,
        s: st,
      );
      rethrow;
    }
  }

  /// Memperbarui [VersiApkModel] yang ada di database.
  Future<void> updateApkVersion(
    final VersiApkModel apkVersion, {
    final bool fromServer = false,
  }) async {
    Log.info(
      'Memperbarui versi APK user - ID: ${apkVersion.id}, Versi: ${apkVersion.latestVersion}',
    );

    try {
      await _baseOperation.update(
        _tableName,
        apkVersion.toSqlite(),
        apkVersion.id,
        dariServer: fromServer,
      );
      Log.info(
        'Versi APK user berhasil diperbarui di tabel $_tableName - ID: ${apkVersion.id}',
      );
    } on Exception catch (e, st) {
      Log.error(
        'Gagal memperbarui versi APK user - ID: ${apkVersion.id}, Versi: ${apkVersion.latestVersion}',
        e: e,
        s: st,
      );
      rethrow;
    }
  }

  /// Melakukan soft delete pada [VersiApkModel] berdasarkan [id].
  Future<void> softDelete(
    final String id, {
    final bool fromServer = false,
  }) async {
    Log.info('Memulai soft delete untuk APK version ID: $id via BaseOperation');
    try {
      await _baseOperation.softDelete(
        _tableName,
        id,
        dariServer: fromServer,
      );
      Log.info('Soft delete untuk APK version ID: $id selesai.');
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
  Future<int> softDeleteAll({final bool fromServer = false}) async {
    Log.info(
        'Memulai proses soft delete untuk SEMUA active APK versions via BaseOperation');
    try {
      final count = await _baseOperation.softDeleteAll(
        _tableName,
        dariServer: fromServer,
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
  Future<void> insertOrUpdateBatch(
    final List<VersiApkModel> modelList, {
    final bool fromServer = false,
  }) async {
    Log.info(
      'Memulai operasi batch insert/update - Jumlah data: ${modelList.length}, Tabel: $_tableName',
    );

    if (modelList.isEmpty) {
      Log.info('Daftar model kosong, tidak ada data yang diproses dalam batch');
      return;
    }

    try {
      final mapList = modelList.map((final model) => model.toSqlite()).toList();
      await _baseOperation.insertOrUpdateBatch(
        _tableName,
        mapList,
        dariServer: fromServer,
      );
      Log.info(
        'Operasi batch berhasil - ${mapList.length} data diproses di tabel $_tableName',
      );
    } on Exception catch (e, st) {
      Log.error(
        'Gagal melakukan operasi batch - Jumlah data: ${modelList.length}, Tabel: $_tableName',
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
  Future<List<VersiApkModel>> getAllApkVersions() async {
    Log.info(
      'Mengambil semua data versi APK dari tabel $_tableName (termasuk yang diarsipkan)',
    );

    try {
      final db = await dbHelper.database;
      const orderBy = '${NamaKolom.updatedAt} DESC';
      Log.info('Query: SELECT * FROM $_tableName ORDER BY $orderBy');

      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        orderBy: orderBy,
      );

      final result = List.generate(
        maps.length,
        (final i) => VersiApkModel.fromSqlite(maps[i]),
      );

      int activeCount = 0;
      int archivedCount = 0;
      for (final model in result) {
        if (model.isDeleted) {
          archivedCount++;
        } else {
          activeCount++;
        }
      }

      Log.info(
        'Berhasil mengambil ${result.length} data versi APK - Aktif: $activeCount, Diarsipkan: $archivedCount',
      );
      return result;
    } on Exception catch (e, st) {
      Log.error(
        'Gagal mengambil semua data versi APK dari tabel $_tableName, mengembalikan list kosong',
        e: e,
        s: st,
      );
      return [];
    }
  }

  /// Mengambil semua versi APK yang aktif dari database.
  Future<List<VersiApkModel>> getAllActiveApkVersions() async {
    Log.info(
      'Mengambil semua versi APK aktif (${NamaKolom.isDeleted} = 0) dari tabel $_tableName',
    );

    try {
      final db = await dbHelper.database;
      const where = '${NamaKolom.isDeleted} = 0';
      const orderBy = '${NamaKolom.updatedAt} DESC';
      Log.info(
          'Query: SELECT * FROM $_tableName WHERE $where ORDER BY $orderBy');

      final maps = await db.query(
        _tableName,
        where: where,
        orderBy: orderBy,
      );

      final result = List.generate(
        maps.length,
        (final i) => VersiApkModel.fromSqlite(maps[i]),
      );

      Log.info('Berhasil mengambil ${result.length} versi APK aktif');

      for (int i = 0; i < (result.length < 3 ? result.length : 3); i++) {
        final v = result[i];
        Log.info(
          '  ${i + 1}. ID: ${v.id}, Versi: ${v.latestVersion}, Build Universal: ${v.latestBuildNumber[ApkArchitectureEnum.universal] ?? 0}',
        );
      }

      return result;
    } on Exception catch (e, st) {
      Log.error(
        'Gagal mengambil versi APK aktif dari tabel $_tableName, mengembalikan list kosong',
        e: e,
        s: st,
      );
      return [];
    }
  }

  /// Mengambil versi APK terbaru yang aktif dari database.
  Future<VersiApkModel?> getLatestApkVersion() async {
    Log.info('Mengambil versi APK terbaru (aktif) dari tabel $_tableName');

    try {
      final db = await dbHelper.database;
      const where = '${NamaKolom.isDeleted} = 0';
      const orderBy = '${NamaKolom.updatedAt} DESC';
      Log.info(
          'Query: SELECT * FROM $_tableName WHERE $where ORDER BY $orderBy LIMIT 1');

      final maps = await db.query(
        _tableName,
        where: where,
        orderBy: orderBy,
        limit: 1,
      );

      if (maps.isNotEmpty) {
        final model = VersiApkModel.fromSqlite(maps.first);
        Log.info(
          'Versi APK terbaru ditemukan - ID: ${model.id}, Versi: ${model.latestVersion}, Build Universal: ${model.latestBuildNumber[ApkArchitectureEnum.universal] ?? 0}, Diperbarui: ${model.updatedAt?.toIso8601String()}',
        );
        return model;
      } else {
        Log.info(
          'Tidak ada versi APK aktif yang ditemukan di tabel $_tableName',
        );
        return null;
      }
    } on Exception catch (e, st) {
      Log.error(
        'Gagal mengambil versi APK terbaru dari tabel $_tableName, mengembalikan null',
        e: e,
        s: st,
      );
      return null;
    }
  }

  /// Mengambil [VersiApkModel] berdasarkan [id].
  Future<VersiApkModel?> getApkVersionById(final String id) async {
    Log.info('Mengambil versi APK by ID: $id dari tabel $_tableName');

    try {
      final db = await dbHelper.database;
      const where = 'id = ? AND ${NamaKolom.isDeleted} = 0';
      Log.info('Query: SELECT * FROM $_tableName WHERE $where');

      final maps = await db.query(
        _tableName,
        where: where,
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        final model = VersiApkModel.fromSqlite(maps.first);
        Log.info(
          'Versi APK ditemukan - ID: $id, Versi: ${model.latestVersion}, Build Universal: ${model.latestBuildNumber[ApkArchitectureEnum.universal] ?? 0}, Catatan: ${model.releaseNotes.length > 50 ? "${model.releaseNotes.substring(0, 50)}..." : model.releaseNotes}',
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
        'Gagal mengambil versi APK by ID: $id dari tabel $_tableName, mengembalikan null',
        e: e,
        s: st,
      );
      return null;
    }
  }
}
