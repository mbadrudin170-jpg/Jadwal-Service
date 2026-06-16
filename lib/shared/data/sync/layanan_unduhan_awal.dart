// path: lib/shared/data/sync/unduhan_awal_service.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/data/sync/layanan_unduh_data.dart';
import 'package:wifi/shared/debug/log.dart';

class LayananUnduhanAwal {
  final SqliteDatabase _databaseSqlite;
  final LayananUnduhData _layananUnduhData;

  LayananUnduhanAwal({
    required SqliteDatabase databaseSqlite,
    required LayananUnduhData layananUnduhData,
  })  : _databaseSqlite = databaseSqlite,
        _layananUnduhData = layananUnduhData {
    Log.info('LayananUnduhanAwal diinisialisasi dengan dependency injection.');
  }

  Future<void> jalankanUnduhanAwal() async {
    Log.info('Memulai sinkronisasi awal: Mengecek tabel lokal yang kosong...');
    final pengukurWaktu = Stopwatch()..start();

    await _unduhPaketJikaKosong();
    await _unduhKategoriJikaKosong();
    await _unduhSubKategoriJikaKosong();
    await _unduhDompetJikaKosong();
    await _unduhPelangganJikaKosong();
    await _unduhVersiApkJikaKosong();
    await _unduhPengaturanJikaKosong();
    await _unduhPelangganAktifJikaKosong();
    await _unduhTransaksiJikaKosong();
    await _unduhUmpanBalikJikaKosong();
    await _unduhPesananJikaKosong();

    pengukurWaktu.stop();
    Log.info(
        'Proses unduhan awal selesai dalam ${pengukurWaktu.elapsed.inSeconds} detik.');
  }

  Future<bool> _apakahTabelKosong(String namaTabel) async {
    try {
      final db = await _databaseSqlite.database;
      final result =
          await db.rawQuery('SELECT COUNT(*) as count FROM $namaTabel');
      final jumlah = Sqflite.firstIntValue(result) ?? 0;
      Log.info("Tabel '$namaTabel': $jumlah baris.");
      return jumlah == 0;
    } on Exception catch (e, st) {
      Log.error("Gagal mengecek tabel '$namaTabel'.", e: e, s: st);
      return false;
    }
  }

  Future<void> _unduhJikaKosong({
    required String namaTabel,
    required Future<void> Function() fungsiUnduh,
  }) async {
    try {
      if (await _apakahTabelKosong(namaTabel)) {
        Log.info("Memulai unduh data untuk '$namaTabel'...");
        await fungsiUnduh();
        Log.info("Data '$namaTabel' berhasil disimpan ke lokal.");
      } else {
        Log.info("Lewati '$namaTabel' (Sudah ada data).");
      }
    } on Exception catch (e, s) {
      Log.error("ERROR saat mengunduh '$namaTabel'", e: e, s: s);
    }
  }

  Future<void> _unduhPaketJikaKosong() => _unduhJikaKosong(
        namaTabel: NamaTabel.paket,
        fungsiUnduh: _layananUnduhData.unduhDataPaket,
      );

  Future<void> _unduhKategoriJikaKosong() => _unduhJikaKosong(
        namaTabel: NamaTabel.kategori,
        fungsiUnduh: _layananUnduhData.unduhDataKategori,
      );

  Future<void> _unduhSubKategoriJikaKosong() => _unduhJikaKosong(
        namaTabel: NamaTabel.subKategori,
        fungsiUnduh: _layananUnduhData.unduhDataSubKategori,
      );

  Future<void> _unduhDompetJikaKosong() => _unduhJikaKosong(
        namaTabel: NamaTabel.dompet,
        fungsiUnduh: _layananUnduhData.unduhDataDompet,
      );

  Future<void> _unduhPelangganJikaKosong() => _unduhJikaKosong(
        namaTabel: NamaTabel.pelanggan,
        fungsiUnduh: _layananUnduhData.unduhDataPelanggan,
      );

  Future<void> _unduhVersiApkJikaKosong() => _unduhJikaKosong(
        namaTabel: NamaTabel.versiApkUser,
        fungsiUnduh: _layananUnduhData.unduhDataVersiApk,
      );

  Future<void> _unduhPengaturanJikaKosong() => _unduhJikaKosong(
        namaTabel: NamaTabel.settings,
        fungsiUnduh: _layananUnduhData.unduhDataPengaturan,
      );

  Future<void> _unduhPelangganAktifJikaKosong() => _unduhJikaKosong(
        namaTabel: NamaTabel.pelangganAktif,
        fungsiUnduh: _layananUnduhData.unduhDataPelangganAktif,
      );

  Future<void> _unduhTransaksiJikaKosong() => _unduhJikaKosong(
        namaTabel: NamaTabel.transaksi,
        fungsiUnduh: _layananUnduhData.unduhDataTransaksi,
      );

  Future<void> _unduhUmpanBalikJikaKosong() => _unduhJikaKosong(
        namaTabel: NamaTabel.feedback,
        fungsiUnduh: _layananUnduhData.unduhDataUmpanBalik,
      );

  Future<void> _unduhPesananJikaKosong() => _unduhJikaKosong(
        namaTabel: NamaTabel.pesananPelanggan,
        fungsiUnduh: _layananUnduhData.unduhDataPesanan,
      );
}

// ✅ HANYA SATU PROVIDER - gunakan Provider biasa
final providerLayananUnduhanAwal = Provider<LayananUnduhanAwal>((ref) {
  return LayananUnduhanAwal(
    databaseSqlite: ref.read(sqliteDatabaseProvider),
    layananUnduhData: ref.read(layananUnduhDataProvider),
  );
});
