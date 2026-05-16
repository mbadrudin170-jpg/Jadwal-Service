// path: lib/shared/operasi/pengaturan_operasi.dart
// diubah: Menambahkan pengaturan `diperbarui` dengan UTC pada setiap operasi tulis.

import 'package:flutter/foundation.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/pengaturan_model.dart';
import 'package:wifi/shared/operasi/base_operation.dart';

/// Kelas untuk operasi terkait data pengaturan di database lokal.
class PengaturanOperasi {
  final _namaTabel = 'pengaturan';
  final OperasiDasar _operasiDasar;

  /// Konstruktor untuk `PengaturanOperasi`.
  PengaturanOperasi({@visibleForTesting final OperasiDasar? operasiDasar})
      : _operasiDasar = operasiDasar ?? OperasiDasar();

  /// Mengambil data pengaturan dari database.
  /// Jika tidak ada, akan membuat pengaturan default.
  Future<PengaturanModel> getPengaturan() async {
    try {
      Log.info(
        'Memulai proses pengambilan data pengaturan dari database - method: getPengaturan, tabel: $_namaTabel',
      );
      final db = await DatabaseHelper.instance.database;

      final hasil = await db.query(
        _namaTabel,
        where: 'id = ?',
        whereArgs: [idPengaturanGlobal],
      );

      if (hasil.isNotEmpty) {
        Log.info('Data pengaturan berhasil ditemukan di database.');
        return PengaturanModel.fromSqlite(hasil.first);
      } else {
        Log.warning(
          'Tidak ditemukan data pengaturan, membuat pengaturan default.',
        );
        // ditambah: Saat membuat default, kita juga set `diperbarui`.
        final pengaturanDefault = PengaturanModel(
          diperbarui: DateTime.now().toUtc(),
        );
        await simpanAtauPerbaruiPengaturan(
          pengaturanDefault,
        );
        Log.info('Pengaturan default berhasil dibuat dan disimpan.');
        return pengaturanDefault;
      }
    } on Exception catch (e, st) {
      Log.error(
        'Gagal mengambil data pengaturan: $e',
        e: e,
        st: st,
      );
      Log.warning('Mengembalikan PengaturanModel default sebagai fallback.');
      return PengaturanModel();
    }
  }

  /// Menyimpan atau memperbarui [PengaturanModel] di database.
  Future<void> simpanAtauPerbaruiPengaturan(
    final PengaturanModel pengaturan, {
    final bool dariServer = false,
  }) async {
    try {
      final pengaturanUntukDisimpan = pengaturan.copyWith(
        id: idPengaturanGlobal,
        diperbarui: DateTime.now().toUtc(),
      );

      Log.info(
        'Memulai proses simpan/perbarui untuk pengaturan dengan ID: ${pengaturanUntukDisimpan.id}',
      );
      await _operasiDasar.sisipkan(
        _namaTabel,
        pengaturanUntukDisimpan.toSqlite(),
        dariServer: dariServer,
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

  /// Memperbarui sebagian field dari [PengaturanModel] di database.
  ///
  /// [data] adalah Map yang berisi field yang akan diperbarui.
  Future<void> updatePengaturan(
    final Map<String, dynamic> data, {
    final bool dariServer = false,
  }) async {
    try {
      Log.info(
        'Memulai proses update parsial untuk pengaturan dengan ID: $idPengaturanGlobal',
      );

      // Selalu tambahkan timestamp `diperbarui` pada setiap operasi tulis.
      final dataUntukUpdate = {
        ...data,
        'diperbarui': DateTime.now().toUtc().millisecondsSinceEpoch,
      };

      await _operasiDasar.perbarui(
        _namaTabel,
        dataUntukUpdate,
        idPengaturanGlobal,
        dariServer: dariServer,
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

  /// Menyimpan atau memperbarui [PengaturanModel] di database menggunakan batch.
  Future<void> simpanAtauPerbaruiPengaturanDenganBatch(
    final PengaturanModel pengaturan, {
    final bool dariServer = false,
  }) async {
    try {
      Log.info('Memulai penyimpanan pengaturan dengan batch operation.');
      final pengaturanUntukDisimpan = pengaturan.copyWith(
        id: idPengaturanGlobal,
        diperbarui: DateTime.now().toUtc(),
      );
      final dataPengaturan = pengaturanUntukDisimpan.toSqlite();
      await _operasiDasar.sisipkanAtauPerbaruiBatch(
        _namaTabel,
        [
          dataPengaturan,
        ],
        dariServer: dariServer,
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
