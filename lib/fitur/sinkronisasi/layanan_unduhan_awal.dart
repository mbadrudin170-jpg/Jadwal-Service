// path: lib/shared/data/sync/unduhan_awal_service.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/sinkronisasi/layanan_unduh_data.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';

class LayananUnduhanAwal {
  final SqliteDatabase _databaseSqlite;
  final LayananUnduhData _layananUnduhData;

  LayananUnduhanAwal({
    required SqliteDatabase databaseSqlite,
    required LayananUnduhData layananUnduhData,
  }) : _databaseSqlite = databaseSqlite,
       _layananUnduhData = layananUnduhData {
    Log.info('LayananUnduhanAwal diinisialisasi dengan dependency injection.');
  }
  Future<bool> jalankanUnduhanAwal() async {
    Log.info('Memulai sinkronisasi awal: Mengecek tabel lokal yang kosong...');
    final pengukurWaktu = Stopwatch()..start();

    final futures = [
      _unduhPaketJikaKosong().catchError((Object e) {
        Log.error('Gagal unduh paket', e: e);
        return false;
      }),
      _unduhKategoriJikaKosong().catchError((Object e) {
        Log.error('Gagal unduh kategori', e: e);
        return false;
      }),
      _unduhSubKategoriJikaKosong().catchError((Object e) {
        Log.error('Gagal unduh sub kategori', e: e);
        return false;
      }),
      _unduhDompetJikaKosong().catchError((Object e) {
        Log.error('Gagal unduh dompet', e: e);
        return false;
      }),
      _unduhPelangganJikaKosong().catchError((Object e) {
        Log.error('Gagal unduh pelanggan', e: e);
        return false;
      }),
      _unduhVersiApkJikaKosong().catchError((Object e) {
        Log.error('Gagal unduh versi APK', e: e);
        return false;
      }),
      _unduhPengaturanJikaKosong().catchError((Object e) {
        Log.error('Gagal unduh pengaturan', e: e);
        return false;
      }),
      _unduhPelangganAktifJikaKosong().catchError((Object e) {
        Log.error('Gagal unduh pelanggan aktif', e: e);
        return false;
      }),
      _unduhTransaksiJikaKosong().catchError((Object e) {
        Log.error('Gagal unduh transaksi', e: e);
        return false;
      }),
      _unduhUmpanBalikJikaKosong().catchError((Object e) {
        Log.error('Gagal unduh umpan balik', e: e);
        return false;
      }),
      _unduhPesananJikaKosong().catchError((Object e) {
        Log.error('Gagal unduh pesanan', e: e);
        return false;
      }),
    ];

    final results = await Future.wait(futures);
    final adaDataBaru = results.any((r) => r == true);
    pengukurWaktu.stop();
    Log.info(
      'Proses unduhan awal selesai dalam ${pengukurWaktu.elapsed.inSeconds} detik. '
      'Ada data baru: $adaDataBaru',
    );

    return adaDataBaru;
  }

  Future<bool> _apakahTabelKosong(String namaTabel) async {
    try {
      final db = await _databaseSqlite.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $namaTabel',
      );
      final jumlah = Sqflite.firstIntValue(result) ?? 0;
      Log.info("Tabel '$namaTabel': $jumlah baris.");
      return jumlah == 0;
    } on Exception catch (e, st) {
      Log.error("Gagal mengecek tabel '$namaTabel'.", e: e, s: st);
      return false;
    }
  }

  Future<bool> _unduhJikaKosong({
    required String namaTabel,
    required Future<void> Function() fungsiUnduh,
  }) async {
    try {
      if (await _apakahTabelKosong(namaTabel)) {
        Log.info("Memulai unduh data untuk '$namaTabel'...");
        await fungsiUnduh();
        Log.info("Data '$namaTabel' berhasil disimpan ke lokal.");
        return true; // ✅ Berhasil mengunduh
      } else {
        Log.info("Lewati '$namaTabel' (Sudah ada data).");
        return false; // ❌ Tidak perlu unduh
      }
    } on Exception catch (e, s) {
      Log.error("ERROR saat mengunduh '$namaTabel'", e: e, s: s);
      return false; // ❌ Gagal
    }
  }

  Future<bool> _unduhPaketJikaKosong() => _unduhJikaKosong(
    namaTabel: NamaTabel.paket,
    fungsiUnduh: _layananUnduhData.unduhDataPaket,
  );

  Future<bool> _unduhKategoriJikaKosong() => _unduhJikaKosong(
    namaTabel: NamaTabel.kategori,
    fungsiUnduh: _layananUnduhData.unduhDataKategori,
  );

  Future<bool> _unduhSubKategoriJikaKosong() => _unduhJikaKosong(
    namaTabel: NamaTabel.subKategori,
    fungsiUnduh: _layananUnduhData.unduhDataSubKategori,
  );

  Future<bool> _unduhDompetJikaKosong() => _unduhJikaKosong(
    namaTabel: NamaTabel.dompet,
    fungsiUnduh: _layananUnduhData.unduhDataDompet,
  );

  Future<bool> _unduhPelangganJikaKosong() => _unduhJikaKosong(
    namaTabel: NamaTabel.pelanggan,
    fungsiUnduh: _layananUnduhData.unduhDataPelanggan,
  );

  Future<bool> _unduhVersiApkJikaKosong() => _unduhJikaKosong(
    namaTabel: NamaTabel.versiApkUser,
    fungsiUnduh: _layananUnduhData.unduhDataVersiApk,
  );

  Future<bool> _unduhPengaturanJikaKosong() => _unduhJikaKosong(
    namaTabel: NamaTabel.settings,
    fungsiUnduh: _layananUnduhData.unduhDataPengaturan,
  );

  Future<bool> _unduhPelangganAktifJikaKosong() => _unduhJikaKosong(
    namaTabel: NamaTabel.pelangganAktif,
    fungsiUnduh: _layananUnduhData.unduhDataPelangganAktif,
  );

  Future<bool> _unduhTransaksiJikaKosong() => _unduhJikaKosong(
    namaTabel: NamaTabel.transaksi,
    fungsiUnduh: _layananUnduhData.unduhDataTransaksi,
  );

  Future<bool> _unduhUmpanBalikJikaKosong() => _unduhJikaKosong(
    namaTabel: NamaTabel.feedback,
    fungsiUnduh: _layananUnduhData.unduhDataUmpanBalik,
  );

  Future<bool> _unduhPesananJikaKosong() => _unduhJikaKosong(
    namaTabel: NamaTabel.pesananPelanggan,
    fungsiUnduh: _layananUnduhData.unduhDataPesanan,
  );
}

final layananUnduhanAwalProvider = Provider<LayananUnduhanAwal>((ref) {
  return LayananUnduhanAwal(
    databaseSqlite: ref.read(sqliteDatabaseProvider),
    layananUnduhData: ref.read(layananUnduhDataProvider),
  );
});
