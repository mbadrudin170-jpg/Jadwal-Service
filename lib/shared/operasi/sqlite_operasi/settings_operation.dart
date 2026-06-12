// path: lib/shared/operasi/settings_operation.dart

import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/settings_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_operation.dart';

class SettingsOpSqlite {
  final SqliteDatabase sqliteDb;
  final BaseOpSqlite _baseOpSqlite;

  /// Konstruktor untuk [SettingsOpSqlite].
  ///
  /// Memungkinkan injeksi dependensi untuk [sqliteDb] dan [_baseOpSqlite] guna memfasilitasi pengujian.
  SettingsOpSqlite({
    required final SqliteDatabase dbHelper,
    required final BaseOpSqlite baseOperation,
  })  : sqliteDb = dbHelper,
        _baseOpSqlite = baseOperation;

  final String _namaTabel = NamaTabel.settings;

  /// Mengambil data pengaturan dari database.
  /// Jika tidak ada, akan membuat pengaturan default.
  Future<SettingsModel> getSettings() async {
    try {
      Log.info(
        'Memulai proses pengambilan data pengaturan dari database - method: getSettings, tabel: ${NamaTabel.settings}',
        'Memulai proses pengambilan data pengaturan dari database - method: ambilPengaturan, tabel: ${NamaTabel.settings}',
      );
      final db = await sqliteDb.database;

      final result = await db.query(
        _namaTabel,
        where: 'id = ?',
        whereArgs: [globalSettingsId],
      );

      if (result.isNotEmpty) {
        Log.info('Data pengaturan berhasil ditemukan di database.');
        return SettingsModel.fromSqlite(result.first);
      } else {
        Log.warning(
          'Tidak ditemukan data pengaturan, membuat pengaturan default.',
        );
        final defaultSettings = SettingsModel(
          updatedAt: DateTime.now().toUtc(),
        );
        await saveOrUpdateSettings(
          defaultSettings,
        );
        Log.info('Pengaturan default berhasil dibuat dan disimpan.');
        return defaultSettings;
      }
    } on Exception catch (e, st) {
      Log.error(
        'Gagal mengambil data pengaturan: $e',
        e: e,
        st: st,
      );
      Log.warning('Mengembalikan SettingsModel default sebagai fallback.');
      return SettingsModel();
    }
  }

  /// Menyimpan atau memperbarui [SettingsModel] di database.
  Future<void> saveOrUpdateSettings(
    final SettingsModel settings, {
    final bool fromServer = false,
  }) async {
    try {
      final settingsToSave = settings.copyWith(
        id: globalSettingsId,
        updatedAt: DateTime.now().toUtc(),
      );

      Log.info(
        'Memulai proses simpan/perbarui untuk pengaturan dengan ID: ${settingsToSave.id}',
      );
      await _baseOpSqlite.sisipkan(
        _namaTabel,
        settingsToSave.toSqlite(),
        dariServer: fromServer,
      );
      Log.info(
        'Pengaturan berhasil disimpan atau diperbarui dengan metode UPSERT.',
      );
    } on Exception catch (e, st) {
      Log.error(
        'Gagal menyimpan atau memperbarui data pengaturan: $e',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Memperbarui sebagian field dari [SettingsModel] di database.
  ///
  /// [data] adalah Map yang berisi field yang akan diperbarui.
  Future<void> updateSettings(
    final Map<String, dynamic> data, {
    final bool dariServer = false,
  }) async {
    try {
      Log.info(
        'Memulai proses update parsial untuk pengaturan dengan ID: $globalSettingsId',
      );

      final dataToUpdate = {
        ...data,
        NamaKolom.updatedAt: DateTime.now().millisecondsSinceEpoch,
      };

      await _baseOpSqlite.update(
        _namaTabel,
        dataToUpdate,
        globalSettingsId,
        dariServer: dariServer,
      );

      Log.info(
        'Pengaturan berhasil diperbarui sebagian. Fields: ${data.keys.join(', ')}',
      );
    } on Exception catch (e, st) {
      Log.error('Gagal memperbarui data pengaturan sebagian: $e', e: e, st: st);
      rethrow;
    }
  }

  /// Menyimpan atau memperbarui [SettingsModel] di database menggunakan batch.
  Future<void> saveOrUpdateSettingsWithBatch(
    final SettingsModel settings, {
    final bool fromServer = false,
  }) async {
    try {
      Log.info('Memulai penyimpanan pengaturan dengan batch operation.');
      final dataToSave = settings.copyWith(
        id: globalSettingsId,
        updatedAt: DateTime.now().toUtc(),
      );
      final data = dataToSave.toSqlite();
      await _baseOpSqlite.insertOrUpdateBatch(
        _namaTabel,
        [data],
        fromServer: fromServer,
      );
      Log.info('Batch operation untuk pengaturan berhasil.');
    } catch (e, st) {
      Log.error('Gagal menyimpan pengaturan dengan batch: $e', e: e, st: st);
      rethrow;
    }
  }
}
