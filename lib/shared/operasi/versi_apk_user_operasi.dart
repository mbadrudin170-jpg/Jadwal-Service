// path: lib/data/operasi/versi_apk_user_operasi.dart
// diubah: Menambahkan injeksi DatabaseHelper dan membuatnya final untuk kemudahan pengujian dan best practice.

import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/arsitektur_apk_enum.dart';
import 'package:wifi/shared/model/versi_apk_user_model.dart';
import 'package:wifi/shared/operasi/operasi_dasar.dart';

/// Kelas untuk operasi terkait data versi APK user di database lokal.
class VersiApkUserOperasi {
  /// Instance dari DatabaseHelper untuk berinteraksi dengan database.
  /// Dapat diganti saat pengujian.
  final DatabaseHelper dbHelper;
  final String _tableName = 'versi_apk_user';
  final OperasiDasar _operasi;

  /// Konstruktor untuk `VersiApkUserOperasi`.
  VersiApkUserOperasi({
    final OperasiDasar? operasi,
    final DatabaseHelper? dbHelper,
  })  : _operasi = operasi ?? OperasiDasar(),
        dbHelper = dbHelper ?? DatabaseHelper.instance {
    Log.info(
      'VersiApkUserOperasi diinisialisasi - Tabel: $_tableName, OperasiDasar: ${operasi != null ? "dari parameter" : "instance baru"}',
    );
  }

  // ==========================
  // OPERASI TULIS (WRITE)
  // ==========================

  /// Menambah [VersiApkUserModel] baru ke database.
  Future<void> tambahVersiApkUser(
    final VersiApkUserModel versiApkUser, {
    final bool dariServer = false,
  }) async {
    Log.info(
      'Menambah versi APK user baru - ID: ${versiApkUser.id}, Versi: ${versiApkUser.versiTerbaru}',
    );

    try {
      await _operasi.sisipkan(
        _tableName,
        versiApkUser.toSqlite(),
        dariServer: dariServer,
      );
      Log.info(
        'Versi APK user berhasil ditambahkan ke tabel $_tableName - ID: ${versiApkUser.id}',
      );
    } on Exception catch (e, st) {
      Log.error(
        'Gagal menambah versi APK user - ID: ${versiApkUser.id}, Versi: ${versiApkUser.versiTerbaru}',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Memperbarui [VersiApkUserModel] yang ada di database.
  Future<void> perbaruiVersiApkUser(
    final VersiApkUserModel versiApkUser, {
    final bool dariServer = false,
  }) async {
    Log.info(
      'Memperbarui versi APK user - ID: ${versiApkUser.id}, Versi: ${versiApkUser.versiTerbaru}',
    );

    try {
      await _operasi.perbarui(
        _tableName,
        versiApkUser.toSqlite(),
        versiApkUser.id,
        dariServer: dariServer,
      );
      Log.info(
        'Versi APK user berhasil diperbarui di tabel $_tableName - ID: ${versiApkUser.id}',
      );
    } on Exception catch (e, st) {
      Log.error(
        'Gagal memperbarui versi APK user - ID: ${versiApkUser.id}, Versi: ${versiApkUser.versiTerbaru}',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Mengarsipkan [VersiApkUserModel] berdasarkan [id].
  Future<void> arsipkanVersiApkUser(
    final String id, {
    final bool dariServer = false,
  }) async {
    Log.info('Mengarsipkan versi APK user - ID: $id');

    try {
      final db = await dbHelper.database;
      Log.info('Mencari data versi APK user ID: $id di tabel $_tableName');

      final data = await db.query(_tableName, where: 'id = ?', whereArgs: [id]);

      if (data.isNotEmpty) {
        final model = VersiApkUserModel.fromSqlite(data.first);
        Log.info(
          'Data ditemukan - Versi: ${model.versiTerbaru}, isDeleted: ${model.isDeleted}',
        );

        final modelDiarsipkan = model.copyWith(
          isDeleted: true,
          diarsipkan: DateTime.now(),
        );

        await perbaruiVersiApkUser(modelDiarsipkan, dariServer: dariServer);

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

  /// Menyisipkan atau memperbarui sekumpulan [VersiApkUserModel] dalam satu batch.
  Future<void> sisipkanAtauPerbaruiBatch(
    final List<VersiApkUserModel> daftarModel, {
    final bool dariServer = false,
  }) async {
    Log.info(
      'Memulai operasi batch sisipkan/perbarui - Jumlah data: ${daftarModel.length}, Tabel: $_tableName',
    );

    if (daftarModel.isEmpty) {
      Log.info('Daftar model kosong, tidak ada data yang diproses dalam batch');
      return;
    }

    try {
      final daftarMap = daftarModel.map((final model) => model.toSqlite()).toList();
      await _operasi.sisipkanAtauPerbaruiBatch(
        _tableName,
        daftarMap,
        dariServer: dariServer,
      );
      Log.info(
        'Operasi batch berhasil - ${daftarMap.length} data diproses di tabel $_tableName',
      );
    } on Exception catch (e, st) {
      Log.error(
        'Gagal melakukan operasi batch - Jumlah data: ${daftarModel.length}, Tabel: $_tableName',
        e: e,
        st: st,
      );
      rethrow;
    }
  }
  // ... sisa file tidak berubah ...

  // ==========================
  // OPERASI BACA (READ)
  // ==========================

  /// Mengambil semua versi APK dari database.
  Future<List<VersiApkUserModel>> ambilSemuaVersiApk() async {
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
        (final i) => VersiApkUserModel.fromSqlite(maps[i]),
      );

      // Log ringkasan
      int jumlahAktif = 0;
      int jumlahDiarsipkan = 0;
      for (final model in result) {
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
  Future<List<VersiApkUserModel>> ambilSemuaVersiApkAktif() async {
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
        (final i) => VersiApkUserModel.fromSqlite(maps[i]),
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
  Future<VersiApkUserModel?> ambilVersiApkTerbaru() async {
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
        final model = VersiApkUserModel.fromSqlite(maps.first);
        Log.info(
          'Versi APK terbaru ditemukan - ID: ${model.id}, Versi: ${model.versiTerbaru}, Build Universal: ${model.nomorBuildTerbaru[ArsitekturApkEnum.universal] ?? 0}, Diperbarui: ${model.diperbarui?.toIso8601String()}',
        );
        return model;
      } else {
        Log.info('Tidak ada versi APK aktif yang ditemukan di tabel $_tableName');
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

  /// Mengambil [VersiApkUserModel] berdasarkan [id].
  Future<VersiApkUserModel?> ambilVersiApkById(final String id) async {
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
        final model = VersiApkUserModel.fromSqlite(maps.first);
        Log.info(
          'Versi APK ditemukan - ID: $id, Versi: ${model.versiTerbaru}, Build Universal: ${model.nomorBuildTerbaru[ArsitekturApkEnum.universal] ?? 0}, Catatan: ${model.catatanRilis.length > 50 ? "${model.catatanRilis.substring(0, 50)}..." : model.catatanRilis}',
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
