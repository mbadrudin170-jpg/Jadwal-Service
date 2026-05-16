// path: lib/shared/operasi/apk_version_operation.dart

import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/apk_architecture_enum.dart';
import 'package:wifi/shared/model/apk_version_model.dart';
import 'package:wifi/shared/operasi/base_operation.dart';

/// Kelas untuk operasi terkait data versi APK user di database lokal.
class ApkVersionOperation {
  /// Instance dari DatabaseHelper untuk berinteraksi dengan database.
  final DatabaseHelper dbHelper;

  static const String _tableName = 'versi_apk_user';

  final BaseOperation _baseOperation;

  /// Konstruktor untuk [ApkVersionOperation].
  ApkVersionOperation({
    final BaseOperation? baseOperation,
    final DatabaseHelper? dbHelper,
  })  : _baseOperation = baseOperation ?? BaseOperation(),
        dbHelper = dbHelper ?? DatabaseHelper.instance {
    Log.info(
      'ApkVersionOperation diinisialisasi - Tabel: $_tableName, BaseOperation: ${baseOperation != null ? "dari parameter" : "instance baru"}',
    );
  }

  // ==========================
  // OPERASI TULIS (WRITE)
  // ==========================

  /// Menambah [ApkVersionModel] baru ke database.
  Future<void> addApkVersion(
    final ApkVersionModel apkVersion, {
    final bool fromServer = false,
  }) async {
    Log.info(
      'Menambah versi APK user baru - ID: ${apkVersion.id}, Versi: ${apkVersion.latestVersion}',
    );

    try {
      await _baseOperation.insert(
        _tableName,
        apkVersion.toSqlite(),
        fromServer: fromServer,
      );
      Log.info(
        'Versi APK user berhasil ditambahkan ke tabel $_tableName - ID: ${apkVersion.id}',
      );
    } on Exception catch (e, st) {
      Log.error(
        'Gagal menambah versi APK user - ID: ${apkVersion.id}, Versi: ${apkVersion.latestVersion}',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Memperbarui [ApkVersionModel] yang ada di database.
  Future<void> updateApkVersion(
    final ApkVersionModel apkVersion, {
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
        fromServer: fromServer,
      );
      Log.info(
        'Versi APK user berhasil diperbarui di tabel $_tableName - ID: ${apkVersion.id}',
      );
    } on Exception catch (e, st) {
      Log.error(
        'Gagal memperbarui versi APK user - ID: ${apkVersion.id}, Versi: ${apkVersion.latestVersion}',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Mengarsipkan [ApkVersionModel] berdasarkan [id].
  Future<void> archiveApkVersion(
    final String id, {
    final bool fromServer = false,
  }) async {
    Log.info('Mengarsipkan versi APK user - ID: $id');

    try {
      final db = await dbHelper.database;
      Log.info('Mencari data versi APK user ID: $id di tabel $_tableName');

      final data = await db.query(_tableName, where: 'id = ?', whereArgs: [id]);

      if (data.isNotEmpty) {
        final model = ApkVersionModel.fromSqlite(data.first);
        Log.info(
          'Data ditemukan - Versi: ${model.latestVersion}, isDeleted: ${model.isDeleted}',
        );

        final archivedModel = model.copyWith(
          isDeleted: true,
          archivedAt: DateTime.now(),
        );

        await updateApkVersion(archivedModel, fromServer: fromServer);

        Log.info(
          'Versi APK user berhasil diarsipkan - ID: $id',
        );
      } else {
        Log.info(
          'Data versi APK user ID: $id tidak ditemukan di tabel $_tableName, tidak dapat mengarsipkan',
        );
      }
    } on Exception catch (e, st) {
      Log.error(
        'Gagal mengarsipkan versi APK user - ID: $id',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Menyisipkan atau memperbarui sekumpulan [ApkVersionModel] dalam satu batch.
  Future<void> insertOrUpdateBatch(
    final List<ApkVersionModel> modelList, {
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
        fromServer: fromServer,
      );
      Log.info(
        'Operasi batch berhasil - ${mapList.length} data diproses di tabel $_tableName',
      );
    } on Exception catch (e, st) {
      Log.error(
        'Gagal melakukan operasi batch - Jumlah data: ${modelList.length}, Tabel: $_tableName',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  // ==========================
  // OPERASI BACA (READ)
  // ==========================

  /// Mengambil semua versi APK dari database.
  Future<List<ApkVersionModel>> getAllApkVersions() async {
    Log.info(
      'Mengambil semua data versi APK dari tabel $_tableName (termasuk yang diarsipkan)',
    );

    try {
      final db = await dbHelper.database;
      Log.info('Query: SELECT * FROM $_tableName ORDER BY diperbarui DESC');

      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        orderBy: 'diperbarui DESC',
      );

      final result = List.generate(
        maps.length,
        (final i) => ApkVersionModel.fromSqlite(maps[i]),
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
        st: st,
      );
      return [];
    }
  }

  /// Mengambil semua versi APK yang aktif dari database.
  Future<List<ApkVersionModel>> getAllActiveApkVersions() async {
    Log.info(
      'Mengambil semua versi APK aktif (isDeleted = 0) dari tabel $_tableName',
    );

    try {
      final db = await dbHelper.database;
      Log.info(
        'Query: SELECT * FROM $_tableName WHERE isDeleted = 0 ORDER BY diperbarui DESC',
      );

      final maps = await db.query(
        _tableName,
        where: 'isDeleted = 0',
        orderBy: 'diperbarui DESC',
      );

      final result = List.generate(
        maps.length,
        (final i) => ApkVersionModel.fromSqlite(maps[i]),
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
        st: st,
      );
      return [];
    }
  }

  /// Mengambil versi APK terbaru yang aktif dari database.
  Future<ApkVersionModel?> getLatestApkVersion() async {
    Log.info('Mengambil versi APK terbaru (aktif) dari tabel $_tableName');

    try {
      final db = await dbHelper.database;
      Log.info(
        'Query: SELECT * FROM $_tableName WHERE isDeleted = 0 ORDER BY diperbarui DESC LIMIT 1',
      );

      final maps = await db.query(
        _tableName,
        where: 'isDeleted = 0',
        orderBy: 'diperbarui DESC',
        limit: 1,
      );

      if (maps.isNotEmpty) {
        final model = ApkVersionModel.fromSqlite(maps.first);
        Log.info(
          'Versi APK terbaru ditemukan - ID: ${model.id}, Versi: ${model.latestVersion}, Build Universal: ${model.latestBuildNumber[ApkArchitectureEnum.universal] ?? 0}, Diperbarui: ${model.updatedAt?.toIso8601String()}',
        );
        return model;
      } else {
        Log.info(
            'Tidak ada versi APK aktif yang ditemukan di tabel $_tableName');
        return null;
      }
    } on Exception catch (e, st) {
      Log.error(
        'Gagal mengambil versi APK terbaru dari tabel $_tableName, mengembalikan null',
        e: e,
        st: st,
      );
      return null;
    }
  }

  /// Mengambil [ApkVersionModel] berdasarkan [id].
  Future<ApkVersionModel?> getApkVersionById(final String id) async {
    Log.info('Mengambil versi APK by ID: $id dari tabel $_tableName');

    try {
      final db = await dbHelper.database;
      Log.info(
        'Query: SELECT * FROM $_tableName WHERE id = $id AND isDeleted = 0',
      );

      final maps = await db.query(
        _tableName,
        where: 'id = ? AND isDeleted = 0',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        final model = ApkVersionModel.fromSqlite(maps.first);
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
        st: st,
      );
      return null;
    }
  }
}
