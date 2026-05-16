// path: lib/shared/operasi/settings_operation.dart

import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/model/settings_model.dart';
import 'package:wifi/shared/operasi/base_operation.dart';

/// Kelas untuk operasi terkait data pengaturan di database lokal.
class SettingsOperation {
  final DatabaseHelper _dbHelper;
  final BaseOperation _baseOperation;

  /// Konstruktor untuk [SettingsOperation].
  ///
  /// Memungkinkan injeksi dependensi untuk [_dbHelper] dan [_baseOperation] guna memfasilitasi pengujian.
  SettingsOperation({
    final DatabaseHelper? dbHelper,
    final BaseOperation? baseOperation,
  })  : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _baseOperation = baseOperation ?? BaseOperation();

  /// Mengambil data pengaturan dari database.
  /// Jika tidak ada, akan membuat pengaturan default.
  Future<SettingsModel> getSettings() async {
    try {
      Log.info(
        'Memulai proses pengambilan data pengaturan dari database - method: getSettings, tabel: ${TableNameValue.get(TableName.settings)}',
      );
      final db = await _dbHelper.database;

      // DIUBAH: Menggunakan TableNameValue untuk nama tabel settings
      final result = await db.query(
        TableNameValue.get(TableName.settings),
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
      // DIUBAH: Menggunakan TableNameValue untuk nama tabel settings
      await _baseOperation.insert(
        TableNameValue.get(TableName.settings),
        settingsToSave.toSqlite(),
        fromServer: fromServer,
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
    final bool fromServer = false,
  }) async {
    try {
      Log.info(
        'Memulai proses update parsial untuk pengaturan dengan ID: $globalSettingsId',
      );

      // Selalu tambahkan timestamp `updated_at` pada setiap operasi tulis dalam bentuk epoch millisecond.
      final dataToUpdate = {
        ...data,
        'diperbarui': DateTime.now().toUtc().millisecondsSinceEpoch,
      };

      // DIUBAH: Menggunakan TableNameValue untuk nama tabel settings
      await _baseOperation.update(
        TableNameValue.get(TableName.settings),
        dataToUpdate,
        globalSettingsId,
        fromServer: fromServer,
      );

      Log.info(
        'Pengaturan berhasil diperbarui sebagian. Fields: ${data.keys.join(', ')}',
      );
    } on Exception catch (e, st) {
      Log.error(
        'Gagal memperbarui data pengaturan sebagian: $e',
        e: e,
        st: st,
      );
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
      final settingsToSave = settings.copyWith(
        id: globalSettingsId,
        updatedAt: DateTime.now().toUtc(),
      );
      final settingsData = settingsToSave.toSqlite();

      // DIUBAH: Menggunakan TableNameValue untuk nama tabel settings
      await _baseOperation.insertOrUpdateBatch(
        TableNameValue.get(TableName.settings),
        [settingsData],
        fromServer: fromServer,
      );
      Log.info('Batch operation untuk pengaturan berhasil.');
    } on Exception catch (e, st) {
      Log.error(
        'Gagal menyimpan pengaturan dengan batch: $e',
        e: e,
        st: st,
      );
      rethrow;
    }
  }
}
