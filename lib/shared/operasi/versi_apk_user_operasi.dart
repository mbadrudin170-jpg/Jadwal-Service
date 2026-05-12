// path: lib/data/operasi/versi_apk_user_operasi.dart


import 'package:wifi/shared/data/sqlite.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/arsitektur_apk_enum.dart';
import 'package:wifi/shared/model/versi_apk_user_model.dart';
import 'package:wifi/shared/operasi/operasi_dasar.dart';

class VersiApkUserOperasi {
  final _dbHelper = DatabaseHelper.instance;
  final String _tableName = 'versi_apk_user';
  final OperasiDasar _operasi;

  VersiApkUserOperasi({OperasiDasar? operasi})
    : _operasi = operasi ?? OperasiDasar() {
    Log.info(
      'VersiApkUserOperasi diinisialisasi - Tabel: $_tableName, OperasiDasar: ${operasi != null ? "dari parameter" : "instance baru"}',
    );
  }

  // ==========================
  // OPERASI TULIS (WRITE)
  // ==========================

  Future<void> tambahVersiApkUser(VersiApkUserModel versiApkUser) async {
    Log.info(
      'Menambah versi APK user baru - ID: ${versiApkUser.id}, Versi: ${versiApkUser.versiTerbaru}',
    );
    Log.info(
      'Detail data - Build Universal: ${versiApkUser.nomorBuildTerbaru[ArsitekturApkEnum.universal] ?? 0}, Build ARM64: ${versiApkUser.nomorBuildTerbaru[ArsitekturApkEnum.arm64] ?? 0}, Build X86_64: ${versiApkUser.nomorBuildTerbaru[ArsitekturApkEnum.x86_64] ?? 0}, Catatan: ${versiApkUser.catatanRilis.length > 50 ? "${versiApkUser.catatanRilis.substring(0, 50)}..." : versiApkUser.catatanRilis}',
    );

    try {
      await _operasi.sisipkan(_tableName, versiApkUser.toSqlite());
      Log.info(
        'Versi APK user berhasil ditambahkan ke tabel $_tableName - ID: ${versiApkUser.id}',
      );
    } catch (e, stackTrace) {
      Log.error(
        'Gagal menambah versi APK user - ID: ${versiApkUser.id}, Versi: ${versiApkUser.versiTerbaru}',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> perbaruiVersiApkUser(VersiApkUserModel versiApkUser) async {
    Log.info(
      'Memperbarui versi APK user - ID: ${versiApkUser.id}, Versi: ${versiApkUser.versiTerbaru}',
    );
    Log.info(
      'Data baru - Build Universal: ${versiApkUser.nomorBuildTerbaru[ArsitekturApkEnum.universal] ?? 0}, Build ARM64: ${versiApkUser.nomorBuildTerbaru[ArsitekturApkEnum.arm64] ?? 0}, Build X86_64: ${versiApkUser.nomorBuildTerbaru[ArsitekturApkEnum.x86_64] ?? 0}',
    );

    try {
      await _operasi.perbarui(
        _tableName,
        versiApkUser.toSqlite(),
        versiApkUser.id,
      );
      Log.info(
        'Versi APK user berhasil diperbarui di tabel $_tableName - ID: ${versiApkUser.id}',
      );
    } catch (e, stackTrace) {
      Log.error(
        'Gagal memperbarui versi APK user - ID: ${versiApkUser.id}, Versi: ${versiApkUser.versiTerbaru}',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> arsipkanVersiApkUser(String id) async {
    Log.info('Mengarsipkan versi APK user - ID: $id');

    try {
      final db = await _dbHelper.database;
      Log.info('Mencari data versi APK user ID: $id di tabel $_tableName');

      final data = await db.query(_tableName, where: 'id = ?', whereArgs: [id]);

      if (data.isNotEmpty) {
        final model = VersiApkUserModel.fromSqlite(data.first);
        Log.info(
          'Data ditemukan - Versi: ${model.versiTerbaru}, Build Universal: ${model.nomorBuildTerbaru[ArsitekturApkEnum.universal] ?? 0}, isDeleted: ${model.isDeleted}',
        );

        final modelDiarsipkan = model.copyWith(
          isDeleted: true,
          diarsipkan: DateTime.now(),
        );

        Log.info(
          'Menandai isDeleted=true, diarsipkan=${modelDiarsipkan.diarsipkan?.toIso8601String()}',
        );
        await _operasi.perbarui(_tableName, modelDiarsipkan.toSqlite(), id);

        Log.info(
          'Versi APK user berhasil diarsipkan - ID: $id, Waktu arsip: ${modelDiarsipkan.diarsipkan?.toIso8601String()}',
        );
      } else {
        Log.info(
          'Data versi APK user ID: $id tidak ditemukan di tabel $_tableName, tidak dapat mengarsipkan',
        );
      }
    } catch (e, stackTrace) {
      Log.error(
        'Gagal mengarsipkan versi APK user - ID: $id',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> sisipkanAtauPerbaruiBatch(
    List<VersiApkUserModel> daftarModel,
  ) async {
    Log.info(
      'Memulai operasi batch sisipkan/perbarui - Jumlah data: ${daftarModel.length}, Tabel: $_tableName',
    );

    if (daftarModel.isEmpty) {
      Log.info('Daftar model kosong, tidak ada data yang diproses dalam batch');
      return;
    }

    try {
      final daftarMap = daftarModel.map((model) => model.toSqlite()).toList();
      Log.info('${daftarModel.length} model berhasil dikonversi ke Map SQLite');

      await _operasi.sisipkanAtauPerbaruiBatch(_tableName, daftarMap);
      Log.info(
        'Operasi batch berhasil - ${daftarMap.length} data diproses di tabel $_tableName',
      );
    } catch (e, stackTrace) {
      Log.error(
        'Gagal melakukan operasi batch - Jumlah data: ${daftarModel.length}, Tabel: $_tableName',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // ==========================
  // OPERASI BACA (READ)
  // ==========================

  Future<List<VersiApkUserModel>> ambilSemuaVersiApk() async {
    Log.info(
      'Mengambil semua data versi APK dari tabel $_tableName (termasuk yang diarsipkan)',
    );

    try {
      final db = await _dbHelper.database;
      Log.info('Query: SELECT * FROM $_tableName ORDER BY diperbarui DESC');

      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        orderBy: 'diperbarui DESC',
      );

      final result = List.generate(
        maps.length,
        (i) => VersiApkUserModel.fromSqlite(maps[i]),
      );

      // Log ringkasan
      int jumlahAktif = 0;
      int jumlahDiarsipkan = 0;
      for (var model in result) {
        if (model.isDeleted) {
          jumlahDiarsipkan++;
        } else {
          jumlahAktif++;
        }
      }

      Log.info(
        'Berhasil mengambil ${result.length} data versi APK - Aktif: $jumlahAktif, Diarsipkan: $jumlahDiarsipkan',
      );
      return result;
    } catch (e, stackTrace) {
      Log.error(
        'Gagal mengambil semua data versi APK dari tabel $_tableName, mengembalikan list kosong',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  Future<List<VersiApkUserModel>> ambilSemuaVersiApkAktif() async {
    Log.info(
      'Mengambil semua versi APK aktif (isDeleted = 0) dari tabel $_tableName',
    );

    try {
      final db = await _dbHelper.database;
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
        (i) => VersiApkUserModel.fromSqlite(maps[i]),
      );

      Log.info('Berhasil mengambil ${result.length} versi APK aktif');

      // Log 3 data teratas
      for (int i = 0; i < (result.length < 3 ? result.length : 3); i++) {
        final v = result[i];
        Log.info(
          '  ${i + 1}. ID: ${v.id}, Versi: ${v.versiTerbaru}, Build Universal: ${v.nomorBuildTerbaru[ArsitekturApkEnum.universal] ?? 0}',
        );
      }

      return result;
    } catch (e, stackTrace) {
      Log.error(
        'Gagal mengambil versi APK aktif dari tabel $_tableName, mengembalikan list kosong',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  Future<VersiApkUserModel?> ambilVersiApkTerbaru() async {
    Log.info('Mengambil versi APK terbaru (aktif) dari tabel $_tableName');

    try {
      final db = await _dbHelper.database;
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
        final model = VersiApkUserModel.fromSqlite(maps.first);
        Log.info(
          'Versi APK terbaru ditemukan - ID: ${model.id}, Versi: ${model.versiTerbaru}, Build Universal: ${model.nomorBuildTerbaru[ArsitekturApkEnum.universal] ?? 0}, Diperbarui: ${model.diperbarui?.toIso8601String()}',
        );
        return model;
      }

      Log.info('Tidak ada versi APK aktif yang ditemukan di tabel $_tableName');
      return null;
    } catch (e, stackTrace) {
      Log.error(
        'Gagal mengambil versi APK terbaru dari tabel $_tableName, mengembalikan null',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  Future<VersiApkUserModel?> ambilVersiApkById(String id) async {
    Log.info('Mengambil versi APK by ID: $id dari tabel $_tableName');

    try {
      final db = await _dbHelper.database;
      Log.info(
        'Query: SELECT * FROM $_tableName WHERE id = $id AND isDeleted = 0',
      );

      final maps = await db.query(
        _tableName,
        where: 'id = ? AND isDeleted = 0',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        final model = VersiApkUserModel.fromSqlite(maps.first);
        Log.info(
          'Versi APK ditemukan - ID: $id, Versi: ${model.versiTerbaru}, Build Universal: ${model.nomorBuildTerbaru[ArsitekturApkEnum.universal] ?? 0}, Catatan: ${model.catatanRilis.length > 50 ? "${model.catatanRilis.substring(0, 50)}..." : model.catatanRilis}',
        );
        return model;
      }

      Log.info(
        'Versi APK dengan ID: $id tidak ditemukan (mungkin sudah diarsipkan atau tidak ada)',
      );
      return null;
    } catch (e, stackTrace) {
      Log.error(
        'Gagal mengambil versi APK by ID: $id dari tabel $_tableName, mengembalikan null',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }
}
