// path: lib/shared/operasi/pengaturan_operasi.dart
// diubah: Menambahkan parameter `dariServer` ke semua operasi tulis.

import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/pengaturan_model.dart';
import 'package:flutter/foundation.dart';
import 'package:wifi/shared/operasi/operasi_dasar.dart';

class PengaturanOperasi {
  final _namaTabel = 'pengaturan';
  final OperasiDasar _operasiDasar;

  PengaturanOperasi({@visibleForTesting OperasiDasar? operasiDasar})
      : _operasiDasar = operasiDasar ?? OperasiDasar();

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
        final pengaturanDefault = PengaturanModel(id: idPengaturanGlobal);
        // Saat membuat default, itu adalah operasi lokal, jadi `dariServer` adalah false
        await simpanAtauPerbaruiPengaturan(pengaturanDefault, dariServer: false);
        Log.info('Pengaturan default berhasil dibuat dan disimpan.');
        return pengaturanDefault;
      }
    } catch (e, st) {
      Log.error(
        'Gagal mengambil data pengaturan: $e',
        e: e,
        st: st,
      );
      Log.warning('Mengembalikan PengaturanModel default sebagai fallback.');
      return PengaturanModel(id: idPengaturanGlobal);
    }
  }

  // diubah: Menambahkan `dariServer`
  Future<void> simpanAtauPerbaruiPengaturan(PengaturanModel pengaturan, {bool dariServer = false}) async {
    try {
      final pengaturanUntukDisimpan = pengaturan.copyWith(
        id: idPengaturanGlobal,
      );

      Log.info(
        'Memulai proses simpan/perbarui untuk pengaturan dengan ID: ${pengaturanUntukDisimpan.id}',
      );
      await _operasiDasar.sisipkan(
        _namaTabel,
        pengaturanUntukDisimpan.toSqlite(),
        dariServer: dariServer, // diteruskan ke operasi dasar
      );
      Log.info(
        'Pengaturan berhasil disimpan atau diperbarui dengan metode UPSERT.',
      );
    } catch (e, st) {
      Log.error(
        'Gagal menyimpan atau memperbarui data pengaturan: $e',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  // diubah: Menambahkan `dariServer`
  Future<void> simpanAtauPerbaruiPengaturanDenganBatch(
    PengaturanModel pengaturan,
     {bool dariServer = false}
  ) async {
    try {
      Log.info('Memulai penyimpanan pengaturan dengan batch operation.');
      final pengaturanUntukDisimpan = pengaturan.copyWith(
        id: idPengaturanGlobal,
      );
      final dataPengaturan = pengaturanUntukDisimpan.toSqlite();
      await _operasiDasar.sisipkanAtauPerbaruiBatch(_namaTabel, [
        dataPengaturan,
      ], dariServer: dariServer); // diteruskan ke operasi dasar
      Log.info('Batch operation untuk pengaturan berhasil.');
    } catch (e, st) {
      Log.error(
        'Gagal menyimpan pengaturan dengan batch: $e',
        e: e,
        st: st,
      );
      rethrow;
    }
  }
}
