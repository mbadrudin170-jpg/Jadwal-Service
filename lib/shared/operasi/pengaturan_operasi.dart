// path: lib/shared/operasi/pengaturan_operasi.dart// diubah: Memperbaiki bug logika UPSERT dengan memaksakan penggunaan ID statis.
// diubah: Menghapus konstanta ID duplikat dan mengimpornya dari model untuk Single Source of Truth.

import 'package:wifi/shared/data/sqlite.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/pengaturan_model.dart'; // ditambah: Mengimpor model untuk mengakses konstanta idPengaturanGlobal.
import 'package:flutter/foundation.dart';
import 'package:wifi/shared/operasi/operasi_dasar.dart';

// dihapus: ID statis tidak lagi didefinisikan di sini untuk menghindari duplikasi.
// 'idPengaturanGlobal' sekarang diimpor dari 'pengaturan_model.dart'.

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
        whereArgs: [idPengaturanGlobal], // sekarang menggunakan konstanta dari model
      );

      if (hasil.isNotEmpty) {
        Log.info('Data pengaturan berhasil ditemukan di database.');
        return PengaturanModel.fromSqlite(hasil.first);
      } else {
        Log.warning(
          'Tidak ditemukan data pengaturan, membuat pengaturan default.',
        );
        final pengaturanDefault = PengaturanModel(id: idPengaturanGlobal);
        await simpanAtauPerbaruiPengaturan(pengaturanDefault);
        Log.info('Pengaturan default berhasil dibuat dan disimpan.');
        return pengaturanDefault;
      }
    } catch (e, stackTrace) {
      Log.error(
        'Gagal mengambil data pengaturan: $e',
        error: e,
        stackTrace: stackTrace,
      );
      Log.warning('Mengembalikan PengaturanModel default sebagai fallback.');
      return PengaturanModel(id: idPengaturanGlobal);
    }
  }

  Future<void> simpanAtauPerbaruiPengaturan(PengaturanModel pengaturan) async {
    try {
      final pengaturanUntukDisimpan = pengaturan.copyWith(
        id: idPengaturanGlobal, // sekarang menggunakan konstanta dari model
      );

      Log.info(
        'Memulai proses simpan/perbarui untuk pengaturan dengan ID: ${pengaturanUntukDisimpan.id}',
      );
      await _operasiDasar.sisipkan(
        _namaTabel,
        pengaturanUntukDisimpan.toSqlite(),
      );
      Log.info(
        'Pengaturan berhasil disimpan atau diperbarui dengan metode UPSERT.',
      );
    } catch (e, stackTrace) {
      Log.error(
        'Gagal menyimpan atau memperbarui data pengaturan: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> simpanAtauPerbaruiPengaturanDenganBatch(
    PengaturanModel pengaturan,
  ) async {
    try {
      Log.info('Memulai penyimpanan pengaturan dengan batch operation.');
      final pengaturanUntukDisimpan = pengaturan.copyWith(
        id: idPengaturanGlobal, // sekarang menggunakan konstanta dari model
      );
      final dataPengaturan = pengaturanUntukDisimpan.toSqlite();
      await _operasiDasar.sisipkanAtauPerbaruiBatch(_namaTabel, [
        dataPengaturan,
      ]);
      Log.info('Batch operation untuk pengaturan berhasil.');
    } catch (e, stackTrace) {
      Log.error(
        'Gagal menyimpan pengaturan dengan batch: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
