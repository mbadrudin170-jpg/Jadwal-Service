# Dokumentasi Fitur: sinkronisasi

## Daftar file

- [lib/fitur/sinkronisasi/layanan_cek_sinkronisasi.dart](../../lib/fitur/sinkronisasi/layanan_cek_sinkronisasi.dart)
- [lib/fitur/sinkronisasi/layanan_unduhan_awal.dart](../../lib/fitur/sinkronisasi/layanan_unduhan_awal.dart)
- [lib/fitur/sinkronisasi/layanan_unduh_data.dart](../../lib/fitur/sinkronisasi/layanan_unduh_data.dart)
- [lib/fitur/sinkronisasi/layanan_unggah_data.dart](../../lib/fitur/sinkronisasi/layanan_unggah_data.dart)
- [lib/fitur/sinkronisasi/pengelola_sinkronisasi.dart](../../lib/fitur/sinkronisasi/pengelola_sinkronisasi.dart)

## Isi file

### File: `lib/fitur/sinkronisasi/layanan_cek_sinkronisasi.dart`
```dart
// path: lib/shared/data/services/layanan_cek_sinkronisasi.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/sinkronisasi/layanan_unduh_data.dart';
import 'package:wifi/fitur/sinkronisasi/layanan_unggah_data.dart';
import 'package:wifi/fitur/sinkronisasi/pengelola_sinkronisasi.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/data/services/layanan_pengecekan_data_baru.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/services/koneksi_internet_service.dart';

/// Layanan untuk mengorkestrasi proses sinkronisasi data.
class LayananCekSinkronisasi {
  final PengelolaSinkronisasi _pengelolaSinkronisasi;
  final LayananUnggahData _layananUnggah;
  final LayananUnduhData _layananUnduh;
  final LayananPengecekanDataBaru _pengecekanDataBaru;
  final FirebaseFirestore _firestore;
  final Ref _ref;
  bool _berjalan = false;

  LayananCekSinkronisasi({
    required PengelolaSinkronisasi pengelolaSinkronisasi,
    required LayananUnggahData layananUnggah,
    required LayananUnduhData layananUnduh,
    required LayananPengecekanDataBaru pengecekanDataBaru,
    required FirebaseFirestore firestore,
    required Ref ref,
  }) : _pengelolaSinkronisasi = pengelolaSinkronisasi,
       _layananUnggah = layananUnggah,
       _layananUnduh = layananUnduh,
       _pengecekanDataBaru = pengecekanDataBaru,
       _firestore = firestore,
       _ref = ref {
    Log.info('SyncCheckService diinisialisasi dengan dependency injection.');
  }

  /// Menjalankan seluruh proses pengecekan dan sinkronisasi data.
  Future<void> jalankanCekSinkronisasi() async {
    Log.info('Memulai siklus orkestrasi sinkronisasi global.');
    if (_berjalan) {
      return;
    }
    final isOnline = await _ref
        .read(koneksiInternetServiceProvider)
        .cekInternet();
    if (!isOnline) {
      Log.warning('Tidak terhubung ke internet');
      return;
    }
    _berjalan = true;
    try {
      final sudahUnggahData = await _periksaDanJalankanUnggah();
      if (sudahUnggahData) {
        Log.info(
          'Pemicu sinkronisasi: Ada data baru yang berhasil diunggah ke server.',
        );
        await _perbaruiStatusGlobal();
      }
      await _periksaDanJalankanUnduh();
      Log.info('Seluruh siklus runSyncCheck() telah berakhir dengan sukses.');
    } on Exception catch (e, s) {
      Log.error('Gagal menjalankan siklus runSyncCheck().', e: e, s: s);
    } finally {
      _berjalan = false;
    }
  }

  Future<bool> _periksaDanJalankanUnggah() async {
    final sekarang = DateTime.now();
    try {
      final adaDataUntukUnggah = await _pengecekanDataBaru
          .apakahSqliteAdaDataBaru();
      if (adaDataUntukUnggah) {
        await _layananUnggah.unggahSemuaData();
        await _pengelolaSinkronisasi.simpanWaktuTerakhirUnggahPreferensi(
          sekarang,
        );
        await _pengecekanDataBaru.resetButuhUpload();
        Log.info('Metadata sinkronisasi berhasil diperbarui: $sekarang.');
        return true;
      } else {
        Log.info('Tidak ditemukan record baru. Melewati fase pengunggahan.');
        return false;
      }
    } catch (e, s) {
      Log.error('Kegagalan Operasional saat unggah.', e: e, s: s);
      return false;
    }
  }

  Future<void> _perbaruiStatusGlobal() async {
    try {
      await _firestore
          .collection(NamaTabel.statusGlobal)
          .doc(globalStatusId)
          .set({
            NamaKolom.diperbaruiPada: FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
      Log.info('Dokumen ${NamaTabel.statusGlobal}/global berhasil diperbarui.');
    } catch (e, s) {
      Log.error(
        'Gagal memperbarui dokumen ${NamaTabel.statusGlobal}/global.',
        e: e,
        s: s,
      );
    }
  }

  Future<void> _periksaDanJalankanUnduh() async {
    try {
      final adaDataBaruDiServer = await _pengecekanDataBaru
          .apakahFirebaseAdaDataBaru(
            namaKoleksi: NamaTabel.statusGlobal,
            idDokumen: globalStatusId,
          );
      if (adaDataBaruDiServer) {
        await _layananUnduh.unduhSemuaData();
        final sekarang = DateTime.now();
        await _pengelolaSinkronisasi.simpanWaktuTerakhirUnduhPreferensi(
          sekarang,
        );
        Log.info('Sinkronisasi masuk selesai: $sekarang.');
      } else {
        Log.info('Cloud tidak memiliki pembaruan data.');
      }
    } catch (e, s) {
      Log.error('Kegagalan Operasional saat unduh.', e: e, s: s);
    }
  }
}

// ============================================================
// Provider Riverpod untuk SyncCheckService
// ============================================================
final layananCekSinkronisasiProvider = Provider<LayananCekSinkronisasi>((ref) {
  return LayananCekSinkronisasi(
    pengelolaSinkronisasi: ref.read(pengelolaSinkronisasiProvider),
    layananUnggah: ref.read(layananUnggahDataProvider), // harus sudah ada
    layananUnduh: ref.read(layananUnduhDataProvider), // sudah ada
    pengecekanDataBaru: ref.read(
      pengecekanDataBaruServiceProvider,
    ), // harus sudah ada
    firestore: FirebaseFirestore.instance,
    ref: ref,
  );
});
```

### File: `lib/fitur/sinkronisasi/layanan_unduhan_awal.dart`
```dart
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
      'Proses unduhan awal selesai dalam ${pengukurWaktu.elapsed.inSeconds} detik.',
    );
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

final layananUnduhanAwalProvider = Provider<LayananUnduhanAwal>((ref) {
  return LayananUnduhanAwal(
    databaseSqlite: ref.read(sqliteDatabaseProvider),
    layananUnduhData: ref.read(layananUnduhDataProvider),
  );
});
```

### File: `lib/fitur/sinkronisasi/layanan_unduh_data.dart`
```dart
// path: lib/shared/data/sync/layanan_unduh_data.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/dompet/model/dompet_model.dart';
import 'package:wifi/fitur/feedback/model/feedback_model.dart';
import 'package:wifi/fitur/kategori/model/kategori_model.dart';
import 'package:wifi/fitur/kategori/model/sub_kategori_model.dart';
import 'package:wifi/fitur/order/model/order_model.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:wifi/fitur/settings/model/settings_model.dart';
import 'package:wifi/fitur/settings/operasi/settings_op_sqlite.dart';
import 'package:wifi/fitur/sinkronisasi/pengelola_sinkronisasi.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_global.dart';
import 'package:wifi/fitur/versi_apk/model/versi_apk_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/operation.dart';

class LayananUnduhData {
  final FirebaseFirestore _firestore;
  final PengelolaSinkronisasi _pengelolaSinkronisasi;
  final DompetOpSqlite _operasiDompet;
  final KategoriOpSqlite _operasiKategori;
  final PaketOpSqlite _operasiPaket;
  final PelangganOpSqlite _operasiPelanggan;
  final PelangganAktifOpSqlite _operasiPelangganAktif;
  final TransaksiOpGlobal _operasiTransaksi;
  final FeedbackOpSqlite _operasiUmpanBalik;
  final OrderOpSqlite _operasiPesanan;
  final SubKategoriOpSqlite _operasiSubKategori;
  final VersiApkOpSqlite _operasiVersiApk;
  final SettingsOpSqlite _operasiPengaturan;

  /// Konstruktor dengan injeksi dependensi (untuk produksi dan testing)
  LayananUnduhData({
    required FirebaseFirestore firestore,
    required PengelolaSinkronisasi syncManager,
    required DompetOpSqlite operasiDompet,
    required KategoriOpSqlite operasiKategori,
    required PaketOpSqlite operasiPaket,
    required PelangganOpSqlite operasiPelanggan,
    required PelangganAktifOpSqlite operasiPelangganAktif,
    required TransaksiOpGlobal operasiTransaksi,
    required FeedbackOpSqlite operasiUmpanBalik,
    required OrderOpSqlite operasiPesanan,
    required SubKategoriOpSqlite operasiSubKategori,
    required VersiApkOpSqlite operasiVersiApk,
    required SettingsOpSqlite operasiPengaturan,
    required PengelolaSinkronisasi pengelolaSinkronisasi,
  }) : _pengelolaSinkronisasi = pengelolaSinkronisasi,
       _firestore = firestore,
       _operasiDompet = operasiDompet,
       _operasiKategori = operasiKategori,
       _operasiPaket = operasiPaket,
       _operasiPelanggan = operasiPelanggan,
       _operasiPelangganAktif = operasiPelangganAktif,
       _operasiTransaksi = operasiTransaksi,
       _operasiUmpanBalik = operasiUmpanBalik,
       _operasiPesanan = operasiPesanan,
       _operasiSubKategori = operasiSubKategori,
       _operasiVersiApk = operasiVersiApk,
       _operasiPengaturan = operasiPengaturan {
    Log.info('LayananUnduhData diinisialisasi dengan dependency injection.');
  }

  LayananUnduhData.test({
    required final FirebaseFirestore firestore,
    required final PengelolaSinkronisasi syncManager,
    required final DompetOpSqlite operasiDompet,
    required final KategoriOpSqlite operasiKategori,
    required final PaketOpSqlite operasiPaket,
    required final PelangganOpSqlite operasiPelanggan,
    required final PelangganAktifOpSqlite operasiPelangganAktif,
    required final TransaksiOpGlobal operasiTransaksi,
    required final FeedbackOpSqlite operasiUmpanBalik,
    required final OrderOpSqlite operasiPesanan,
    required final SubKategoriOpSqlite operasiSubKategori,
    required final VersiApkOpSqlite operasiVersiApk,
    required final SettingsOpSqlite operasiPengaturan,
  }) : _firestore = firestore,
       _pengelolaSinkronisasi = syncManager,
       _operasiDompet = operasiDompet,
       _operasiKategori = operasiKategori,
       _operasiPaket = operasiPaket,
       _operasiPelanggan = operasiPelanggan,
       _operasiPelangganAktif = operasiPelangganAktif,
       _operasiTransaksi = operasiTransaksi,
       _operasiUmpanBalik = operasiUmpanBalik,
       _operasiPesanan = operasiPesanan,
       _operasiSubKategori = operasiSubKategori,
       _operasiVersiApk = operasiVersiApk,
       _operasiPengaturan = operasiPengaturan {
    Log.info('LayananUnduhData berhasil diinisialisasi untuk pengujian.');
  }

  Future<void> unduhSemuaData() async {
    Log.info('Memulai prosedur orkestrasi unduh data massal.');
    final stopwatch = Stopwatch()..start();

    try {
      await Future.wait([
        unduhDataPelangganAktif(),
        unduhDataPengaturan(),
        unduhDataDompet(),
        unduhDataKategori(),
        unduhDataPaket(),
        unduhDataPelanggan(),
        unduhDataTransaksi(),
        unduhDataUmpanBalik(),
        unduhDataPesanan(),
        unduhDataSubKategori(),
        unduhDataVersiApk(),
      ]);

      stopwatch.stop();
      Log.info(
        'Prosedur unduh data massal selesai sepenuhnya. Total durasi: ${stopwatch.elapsed.inMilliseconds} ms.',
      );
    } catch (e, s) {
      Log.error('Kegagalan kritis selama prosedur unduh massal.', e: e, s: s);
      rethrow;
    }
  }

  /// Mengunduh data pengaturan dari Firebase.
  Future<void> unduhDataPengaturan() async {
    Log.info('Memulai sinkronisasi untuk koleksi: [PENGATURAN]');
    try {
      final lastDownloadTime = await _pengelolaSinkronisasi
          .ambilWaktuTerakhirUnduhPreferensi();
      const namaKoleksi = NamaTabel.settings;
      final docRef = _firestore.collection(namaKoleksi).doc(idGlobalSetting);
      final doc = await docRef.get(const GetOptions(source: Source.server));

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        // Menggunakan ColumnNames.updatedAt untuk field 'diperbarui'
        if (data.containsKey(NamaKolom.diperbaruiPada)) {
          final dynamic fieldValue = data[NamaKolom.diperbaruiPada];

          if (fieldValue is! Timestamp) {
            Log.error(
              'Inkompatibilitas Tipe: Field "${NamaKolom.diperbaruiPada}" bukan Timestamp.',
            );
            return;
          }

          final waktuPembaruanServer = fieldValue.toDate();

          if (waktuPembaruanServer.isAfter(lastDownloadTime)) {
            Log.info('Data pengaturan server lebih baru, memperbarui lokal.');
            final settings = SettingsModel.fromFirebase(data);
            await _operasiPengaturan.simpanAtauPerbaruiSettings(
              settings,
              dariServer: true,
            );
            Log.info('Update Settings lokal berhasil.');
          } else {
            Log.info('Data pengaturan lokal sudah sinkron.');
          }
        } else {
          Log.warning(
            'Dokumen pengaturan tidak memiliki field "${NamaKolom.diperbaruiPada}".',
          );
        }
      } else {
        Log.warning('Dokumen pengaturan tidak ditemukan di server.');
      }
    } catch (e, s) {
      Log.error('Kesalahan sinkronisasi Pengaturan.', e: e, s: s);
      rethrow;
    }
  }

  Future<void> unduhDataDompet() async {
    Log.info('Memulai sinkronisasi untuk koleksi: [DOMPET]');
    final lastDownloadTime = await _pengelolaSinkronisasi
        .ambilWaktuTerakhirUnduhPreferensi();
    await sinkronkanKoleksi<DompetModel>(
      namaKoleksi: NamaTabel.dompet,
      waktuTerakhirUnduh: lastDownloadTime,
      dariFirebase: DompetModel.fromFirebase,
      operasiBatch: (final data) =>
          _operasiDompet.sisipkanAtauPerbaruiBatch(data, dariServer: true),
    );
  }

  Future<void> unduhDataKategori() async {
    Log.info('Memulai sinkronisasi untuk koleksi: [KATEGORI]');
    final lastDownloadTime = await _pengelolaSinkronisasi
        .ambilWaktuTerakhirUnduhPreferensi();
    await sinkronkanKoleksi<KategoriModel>(
      namaKoleksi: NamaTabel.kategori,
      waktuTerakhirUnduh: lastDownloadTime,
      dariFirebase: KategoriModel.fromFirebase,
      operasiBatch: (final data) =>
          _operasiKategori.sisipkanAtauPerbaruiBatch(data, dariServer: true),
    );
  }

  Future<void> unduhDataPaket() async {
    Log.info('Memulai sinkronisasi untuk koleksi: [PAKET]');
    final lastDownloadTime = await _pengelolaSinkronisasi
        .ambilWaktuTerakhirUnduhPreferensi();
    await sinkronkanKoleksi<PaketModel>(
      namaKoleksi: NamaTabel.paket,
      waktuTerakhirUnduh: lastDownloadTime,
      dariFirebase: PaketModel.fromFirebase,
      operasiBatch: (final data) =>
          _operasiPaket.sisipkanAtauPerbaruiBatch(data, dariServer: true),
    );
  }

  Future<void> unduhDataPelanggan() async {
    Log.info('Memulai sinkronisasi untuk koleksi: [PELANGGAN]');
    final lastDownloadTime = await _pengelolaSinkronisasi
        .ambilWaktuTerakhirUnduhPreferensi();
    await sinkronkanKoleksi<PelangganModel>(
      namaKoleksi: NamaTabel.pelanggan,
      waktuTerakhirUnduh: lastDownloadTime,
      dariFirebase: PelangganModel.fromFirebase,
      operasiBatch: (final data) =>
          _operasiPelanggan.sisipkanAtauPerbaruiBatch(data, dariServer: true),
    );
  }

  Future<void> unduhDataPelangganAktif() async {
    Log.info('Memulai sinkronisasi untuk koleksi: [PELANGGAN AKTIF]');
    final lastDownloadTime = await _pengelolaSinkronisasi
        .ambilWaktuTerakhirUnduhPreferensi();
    await sinkronkanKoleksi<PelangganAktifModel>(
      namaKoleksi: NamaTabel.pelangganAktif,
      waktuTerakhirUnduh: lastDownloadTime,
      dariFirebase: PelangganAktifModel.fromFirebase,
      operasiBatch: (final data) => _operasiPelangganAktif
          .sisipkanAtauPerbaruiBatch(data, dariServer: true),
    );
  }

  Future<void> unduhDataTransaksi() async {
    Log.info('Memulai sinkronisasi untuk koleksi: [TRANSAKSI]');
    final lastDownloadTime = await _pengelolaSinkronisasi
        .ambilWaktuTerakhirUnduhPreferensi();
    await sinkronkanKoleksi<TransaksiModel>(
      namaKoleksi: NamaTabel.transaksi,
      waktuTerakhirUnduh: lastDownloadTime,
      dariFirebase: TransaksiModel.fromFirebase,
      operasiBatch: (final data) =>
          _operasiTransaksi.sisipkanAtauPerbaruiBatch(data, dariServer: true),
    );
  }

  Future<void> unduhDataUmpanBalik() async {
    Log.info('Memulai sinkronisasi untuk koleksi: [UMPAN BALIK]');
    final lastDownloadTime = await _pengelolaSinkronisasi
        .ambilWaktuTerakhirUnduhPreferensi();
    await sinkronkanKoleksi<FeedbackModel>(
      namaKoleksi: NamaTabel.feedback,
      waktuTerakhirUnduh: lastDownloadTime,
      dariFirebase: FeedbackModel.fromFirebase,
      operasiBatch: (final data) =>
          _operasiUmpanBalik.sisipkanAtauPerbaruiBatch(data, dariServer: true),
    );
  }

  Future<void> unduhDataPesanan() async {
    Log.info('Memulai sinkronisasi untuk koleksi: [PESANAN]');
    final lastDownloadTime = await _pengelolaSinkronisasi
        .ambilWaktuTerakhirUnduhPreferensi();
    await sinkronkanKoleksi<OrderModel>(
      namaKoleksi: NamaTabel.pesananPelanggan,
      waktuTerakhirUnduh: lastDownloadTime,
      dariFirebase: OrderModel.fromFirebase,
      operasiBatch: (final data) =>
          _operasiPesanan.sisipkanAtauPerbaruiBatch(data, dariServer: true),
    );
  }

  Future<void> unduhDataSubKategori() async {
    Log.info('Memulai sinkronisasi untuk koleksi: [SUB KATEGORI]');
    final lastDownloadTime = await _pengelolaSinkronisasi
        .ambilWaktuTerakhirUnduhPreferensi();
    await sinkronkanKoleksi<SubKategoriModel>(
      namaKoleksi: NamaTabel.subKategori,
      waktuTerakhirUnduh: lastDownloadTime,
      dariFirebase: SubKategoriModel.fromFirebase,
      operasiBatch: (final data) =>
          _operasiSubKategori.sisipkanAtauPerbaruiBatch(data, dariServer: true),
    );
  }

  Future<void> unduhDataVersiApk() async {
    Log.info('Memulai sinkronisasi untuk koleksi: [VERSI APK]');
    final lastDownloadTime = await _pengelolaSinkronisasi
        .ambilWaktuTerakhirUnduhPreferensi();
    await sinkronkanKoleksi<VersiApkModel>(
      namaKoleksi: NamaTabel.versiApkUser,
      waktuTerakhirUnduh: lastDownloadTime,
      dariFirebase: VersiApkModel.fromFirebase,
      operasiBatch: (data) =>
          _operasiVersiApk.sisipkanAtauPerbaruiBatch(data, dariServer: true),
    );
  }

  Future<void> sinkronkanKoleksi<T>({
    required final String namaKoleksi,
    required final DateTime waktuTerakhirUnduh,
    required final T Function(String id, Map<String, dynamic> data)
    dariFirebase,
    required final Future<void> Function(List<T>) operasiBatch,
  }) async {
    Log.info(
      'Sinkronisasi Koleksi: Memeriksa [$namaKoleksi] untuk data baru sejak $waktuTerakhirUnduh.',
    );
    try {
      final hasilSnapshot = await _firestore
          .collection(namaKoleksi)
          .where(NamaKolom.diperbaruiPada, isGreaterThan: waktuTerakhirUnduh)
          .get(const GetOptions(source: Source.server));

      if (hasilSnapshot.docs.isNotEmpty) {
        Log.info(
          'Ditemukan ${hasilSnapshot.docs.length} dokumen baru/diperbarui di [$namaKoleksi].',
        );

        final daftarData = <T>[];
        for (final doc in hasilSnapshot.docs) {
          try {
            daftarData.add(dariFirebase(doc.id, doc.data()));
          } on Exception catch (e, s) {
            Log.error(
              'Gagal memproses dokumen ${doc.id} di koleksi $namaKoleksi',
              e: e,
              s: s,
            );
          }
        }

        if (daftarData.isNotEmpty) {
          Log.info(
            'Mengirim ${daftarData.length} item ke operasi batch lokal.',
          );
          await operasiBatch(daftarData);
          Log.info('Sinkronisasi masuk untuk [$namaKoleksi] berhasil.');
        } else {
          Log.warning(
            'Tidak ada data valid untuk disimpan dari [$namaKoleksi].',
          );
        }
      } else {
        Log.info('Koleksi [$namaKoleksi] sudah sinkron.');
      }
    } on Exception catch (e, s) {
      Log.error('Kegagalan sinkronisasi koleksi: $namaKoleksi', e: e, s: s);
      rethrow;
    }
  }
}

final layananUnduhDataProvider = Provider<LayananUnduhData>((ref) {
  return LayananUnduhData(
    firestore: FirebaseFirestore.instance,
    syncManager: ref.read(pengelolaSinkronisasiProvider),
    operasiDompet: ref.read(dompetOpSqliteProvider),
    operasiKategori: ref.read(kategoriOpSqliteProvider),
    operasiPaket: ref.read(paketOpSqliteProvider),
    operasiPelanggan: ref.read(pelangganOpSqliteProvider),
    operasiPelangganAktif: ref.read(pelangganAktifOpSqliteProvider),
    operasiTransaksi: ref.read(transaksiOpGlobalProvider),
    operasiUmpanBalik: ref.read(feedbackOpSqliteProvider),
    operasiPesanan: ref.read(orderOpSqliteProvider),
    operasiSubKategori: ref.read(subKategoriOpSqliteProvider),
    operasiVersiApk: ref.read(versiApkOpSqliteProvider),
    operasiPengaturan: ref.read(settingsOpSqliteProvider),
    pengelolaSinkronisasi: ref.read(pengelolaSinkronisasiProvider),
  );
});
```

### File: `lib/fitur/sinkronisasi/layanan_unggah_data.dart`
```dart
// path: lib/shared/data/sync/layanan_unggah_data.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/dompet/model/dompet_model.dart';
import 'package:wifi/fitur/feedback/model/feedback_model.dart';
import 'package:wifi/fitur/kategori/model/kategori_model.dart';
import 'package:wifi/fitur/kategori/model/sub_kategori_model.dart';
import 'package:wifi/fitur/order/model/order_model.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:wifi/fitur/settings/model/settings_model.dart';
import 'package:wifi/fitur/sinkronisasi/pengelola_sinkronisasi.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/versi_apk/model/versi_apk_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/model/has_id.dart';

class LayananUnggahData {
  final SqliteDatabase _sqliteDb;
  final FirebaseFirestore _firestore;
  final PengelolaSinkronisasi _syncManager;

  LayananUnggahData({
    required SqliteDatabase sqliteDb,
    required FirebaseFirestore firestore,
    required PengelolaSinkronisasi syncManager,
  }) : _sqliteDb = sqliteDb,
       _firestore = firestore,
       _syncManager = syncManager {
    Log.info('UploadDataService diinisialisasi dengan dependency injection.');
  }

  /// Mengunggah semua data dari semua tabel lokal ke koleksi Firestore yang sesuai.
  Future<void> unggahSemuaData() async {
    Log.info('========================================');
    Log.info('MEMULAI PROSES UNGGAH SEMUA DATA KE FIREBASE');
    Log.info(
      'Proses ini akan mengunggah 11 jenis data (tabel) dari SQLite lokal ke Firestore.',
    );
    Log.info('========================================');

    Log.info(
      'Menyiapkan daftar Future untuk semua fungsi unggah spesifik. '
      'Semua fungsi akan dijalankan secara paralel menggunakan Future.wait.',
    );

    final daftarTabel = <Future<void>>[
      unggahDataDompet(),
      unggahDataKategori(),
      unggahDataFeedback(),
      unggahDataPaket(),
      unggahDataPelangganAktif(),
      uploadCustomerData(),
      uploadOrderData(),
      uploadDataTransaksi(),
      uploadSubCategoryData(),
      uploadApkVersionData(),
      uploadSettingsData(),
    ];

    Log.info(
      'Total ${daftarTabel.length} fungsi unggah spesifik telah disiapkan dan siap dieksekusi secara paralel.',
    );

    try {
      Log.info(
        'Menjalankan semua fungsi unggah secara paralel menggunakan Future.wait. '
        'Semua proses unggah akan berjalan bersamaan untuk efisiensi waktu.',
      );
      await Future.wait(daftarTabel);
      Log.info('========================================');
      Log.info('PROSES UNGGAH SEMUA DATA SELESAI DENGAN SUKSES');
      Log.info(
        'Semua 11 jenis data berhasil diunggah ke Firestore tanpa error.',
      );
      Log.info('========================================');
    } on Exception catch (e, s) {
      Log.error(
        'Gagal selama proses unggah massal ke Firestore. '
        'Satu atau lebih fungsi unggah spesifik mengalami kegagalan. '
        'Proses unggah tidak dapat diselesaikan sepenuhnya. '
        'Error ini akan dilempar ulang ke service layer untuk penanganan lebih lanjut.',
        e: e,
        s: s,
      );
      rethrow;
    }
  }

  /// Mengunggah data dompet ke Firestore.
  Future<void> unggahDataDompet() async {
    Log.info(
      'Memulai proses unggah data dompet. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final waktu = await _syncManager.ambilWaktuTerakhirUnggahPreferensi();
      Log.info(
        'Waktu sinkronisasi terakhir untuk dompet: ${waktu.toIso8601String()}. '
        'Hanya data yang diperbarui setelah waktu ini yang akan diunggah.',
      );
      await uploadGenericData<DompetModel>(
        NamaTabel.dompet,
        NamaTabel.dompet,
        DompetModel.fromSqlite,
        (m) => m.toFirebase(),
        waktu,
      );
      Log.info('Proses unggah data dompet selesai dengan sukses.');
    } catch (e, s) {
      Log.error(
        'Gagal mengunggah data dompet. '
        'Kemungkinan penyebab: gagal membaca data dari SQLite, '
        'gagal mengambil waktu sinkronisasi, atau gagal menulis ke Firestore.',
        e: e,
        s: s,
      );
      rethrow;
    }
  }

  /// Mengunggah data kategori ke Firestore.
  Future<void> unggahDataKategori() async {
    Log.info(
      'Memulai proses unggah data kategori. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final waktu = await _syncManager.ambilWaktuTerakhirUnggahPreferensi();
      Log.info(
        'Waktu sinkronisasi terakhir untuk kategori: ${waktu.toIso8601String()}. '
        'Hanya data yang diperbarui setelah waktu ini yang akan diunggah.',
      );
      await uploadGenericData<KategoriModel>(
        NamaTabel.kategori,
        NamaTabel.kategori,
        KategoriModel.fromSqlite,
        (final m) => m.toFirebase(),
        waktu,
      );
      Log.info('Proses unggah data kategori selesai dengan sukses.');
    } on Exception catch (e, s) {
      Log.error(
        'Gagal mengunggah data kategori. '
        'Kemungkinan penyebab: gagal membaca data dari SQLite, '
        'gagal mengambil waktu sinkronisasi, atau gagal menulis ke Firestore.',
        e: e,
        s: s,
      );
      rethrow;
    }
  }

  /// Mengunggah data kritik dan saran ke Firestore.
  Future<void> unggahDataFeedback() async {
    Log.info(
      'Memulai proses unggah data kritik_saran. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final terkahirUpload = await _syncManager
          .ambilWaktuTerakhirUnggahPreferensi();
      Log.info(
        'Waktu sinkronisasi terakhir untuk kritik_saran: ${terkahirUpload.toIso8601String()}. '
        'Hanya data yang diperbarui setelah waktu ini yang akan diunggah.',
      );
      await uploadGenericData<FeedbackModel>(
        NamaTabel.feedback,
        NamaTabel.feedback,
        FeedbackModel.fromSqlite,
        (m) => m.toFirebase(),
        terkahirUpload,
      );
      Log.info('Proses unggah data kritik_saran selesai dengan sukses.');
    } on Exception catch (e, s) {
      Log.error(
        'Gagal mengunggah data kritik_saran. '
        'Kemungkinan penyebab: gagal membaca data dari SQLite, '
        'gagal mengambil waktu sinkronisasi, atau gagal menulis ke Firestore.',
        e: e,
        s: s,
      );
      rethrow;
    }
  }

  /// Mengunggah data paket ke Firestore.
  Future<void> unggahDataPaket() async {
    Log.info(
      'Memulai proses unggah data paket. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final waktu = await _syncManager.ambilWaktuTerakhirUnggahPreferensi();
      Log.info(
        'Waktu sinkronisasi terakhir untuk paket: ${waktu.toIso8601String()}. '
        'Hanya data yang diperbarui setelah waktu ini yang akan diunggah.',
      );
      await uploadGenericData<PaketModel>(
        NamaTabel.paket,
        NamaTabel.paket,
        PaketModel.fromSqlite,
        (final m) => m.toFirebase(),
        waktu,
      );
      Log.info('Proses unggah data paket selesai dengan sukses.');
    } on Exception catch (e, s) {
      Log.error(
        'Gagal mengunggah data paket. '
        'Kemungkinan penyebab: gagal membaca data dari SQLite, '
        'gagal mengambil waktu sinkronisasi, atau gagal menulis ke Firestore.',
        e: e,
        s: s,
      );
      rethrow;
    }
  }

  /// Mengunggah data pelanggan aktif ke Firestore.
  Future<void> unggahDataPelangganAktif() async {
    Log.info(
      'Memulai proses unggah data pelanggan_aktif. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final waktu = await _syncManager.ambilWaktuTerakhirUnggahPreferensi();
      Log.info(
        'Waktu sinkronisasi terakhir untuk pelanggan_aktif: ${waktu.toIso8601String()}. '
        'Hanya data yang diperbarui setelah waktu ini yang akan diunggah.',
      );
      await uploadGenericData<PelangganAktifModel>(
        NamaTabel.pelangganAktif,
        NamaTabel.pelangganAktif,
        PelangganAktifModel.fromSqlite,
        (m) => m.toFirebase(),
        waktu,
      );
      Log.info('Proses unggah data pelanggan_aktif selesai dengan sukses.');
    } on Exception catch (e, s) {
      Log.error(
        'Gagal mengunggah data pelanggan_aktif. '
        'Kemungkinan penyebab: gagal membaca data dari SQLite, '
        'gagal mengambil waktu sinkronisasi, atau gagal menulis ke Firestore.',
        e: e,
        s: s,
      );
      rethrow;
    }
  }

  /// Mengunggah data pelanggan ke Firestore.
  Future<void> uploadCustomerData() async {
    Log.info(
      'Memulai proses unggah data pelanggan. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final waktu = await _syncManager.ambilWaktuTerakhirUnggahPreferensi();
      Log.info(
        'Waktu sinkronisasi terakhir untuk pelanggan: ${waktu.toIso8601String()}. '
        'Hanya data yang diperbarui setelah waktu ini yang akan diunggah.',
      );
      await uploadGenericData<PelangganModel>(
        NamaTabel.pelanggan,
        NamaTabel.pelanggan,
        PelangganModel.fromSqlite,
        (final m) => m.toFirebase(),
        waktu,
      );
      Log.info('Proses unggah data pelanggan selesai dengan sukses.');
    } on Exception catch (e, s) {
      Log.error(
        'Gagal mengunggah data pelanggan. '
        'Kemungkinan penyebab: gagal membaca data dari SQLite, '
        'gagal mengambil waktu sinkronisasi, atau gagal menulis ke Firestore.',
        e: e,
        s: s,
      );
      rethrow;
    }
  }

  /// Mengunggah data pesanan ke Firestore.
  Future<void> uploadOrderData() async {
    Log.info(
      'Memulai proses unggah data pesanan. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final waktu = await _syncManager.ambilWaktuTerakhirUnggahPreferensi();
      Log.info(
        'Waktu sinkronisasi terakhir untuk pesanan: ${waktu.toIso8601String()}. '
        'Hanya data yang diperbarui setelah waktu ini yang akan diunggah.',
      );
      await uploadGenericData<OrderModel>(
        NamaTabel.pesananPelanggan,
        NamaTabel.pesananPelanggan,
        OrderModel.fromSqlite,
        (final m) => m.toFirebase(),
        waktu,
      );
      Log.info('Proses unggah data pesanan selesai dengan sukses.');
    } on Exception catch (e, s) {
      Log.error(
        'Gagal mengunggah data pesanan. '
        'Kemungkinan penyebab: gagal membaca data dari SQLite, '
        'gagal mengambil waktu sinkronisasi, atau gagal menulis ke Firestore.',
        e: e,
        s: s,
      );
      rethrow;
    }
  }

  /// Mengunggah data transaksi ke Firestore.
  Future<void> uploadDataTransaksi() async {
    Log.info(
      'Memulai proses unggah data transaksi. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final waktu = await _syncManager.ambilWaktuTerakhirUnggahPreferensi();
      Log.info(
        'Waktu sinkronisasi terakhir untuk transaksi: ${waktu.toIso8601String()}. '
        'Hanya data yang diperbarui setelah waktu ini yang akan diunggah.',
      );
      await uploadGenericData<TransaksiModel>(
        NamaTabel.transaksi,
        NamaTabel.transaksi,
        TransaksiModel.fromSqlite,
        (m) => m.toFirebase(),
        waktu,
      );
      Log.info('Proses unggah data transaksi selesai dengan sukses.');
    } on Exception catch (e, s) {
      Log.error(
        'Gagal mengunggah data transaksi. '
        'Kemungkinan penyebab: gagal membaca data dari SQLite, '
        'gagal mengambil waktu sinkronisasi, atau gagal menulis ke Firestore.',
        e: e,
        s: s,
      );
      rethrow;
    }
  }

  /// Mengunggah data sub-kategori ke Firestore.
  Future<void> uploadSubCategoryData() async {
    Log.info(
      'Memulai proses unggah data sub_kategori. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final waktu = await _syncManager.ambilWaktuTerakhirUnggahPreferensi();
      Log.info(
        'Waktu sinkronisasi terakhir untuk sub_kategori: ${waktu.toIso8601String()}. '
        'Hanya data yang diperbarui setelah waktu ini yang akan diunggah.',
      );
      await uploadGenericData<SubKategoriModel>(
        NamaTabel.subKategori,
        NamaTabel.subKategori,
        SubKategoriModel.fromSqlite,
        (final m) => m.toFirebase(),
        waktu,
      );
      Log.info('Proses unggah data sub_kategori selesai dengan sukses.');
    } on Exception catch (e, s) {
      Log.error(
        'Gagal mengunggah data sub_kategori. '
        'Kemungkinan penyebab: gagal membaca data dari SQLite, '
        'gagal mengambil waktu sinkronisasi, atau gagal menulis ke Firestore.',
        e: e,
        s: s,
      );
      rethrow;
    }
  }

  /// Mengunggah data pengaturan ke Firestore.
  Future<void> uploadSettingsData() async {
    Log.info(
      'Memulai proses unggah data pengaturan. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final waktu = await _syncManager.ambilWaktuTerakhirUnggahPreferensi();
      Log.info(
        'Waktu sinkronisasi terakhir untuk pengaturan: ${waktu.toIso8601String()}. '
        'Data pengaturan akan selalu diunggah, jadi waktu ini akan diabaikan pada level query.',
      );
      await uploadGenericData<SettingsModel>(
        NamaTabel.settings,
        NamaTabel.settings,
        SettingsModel.fromSqlite,
        (final m) => m.toFirebase(),
        waktu,
      );
      Log.info('Proses unggah data pengaturan selesai dengan sukses.');
    } on Exception catch (e, s) {
      Log.error(
        'Gagal mengunggah data pengaturan. '
        'Kemungkinan penyebab: gagal membaca data dari SQLite, '
        'gagal mengambil waktu sinkronisasi, atau gagal menulis ke Firestore.',
        e: e,
        s: s,
      );
      rethrow;
    }
  }

  /// Mengunggah data versi APK user ke Firestore.
  Future<void> uploadApkVersionData() async {
    Log.info(
      'Memulai proses unggah data versi_apk_user. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final waktu = await _syncManager.ambilWaktuTerakhirUnggahPreferensi();
      Log.info(
        'Waktu sinkronisasi terakhir untuk versi_apk_user: ${waktu.toIso8601String()}. '
        'Hanya data yang diperbarui setelah waktu ini yang akan diunggah.',
      );
      await uploadGenericData<VersiApkModel>(
        NamaTabel.versiApkUser,
        NamaTabel.versiApkUser,
        VersiApkModel.fromSqlite,
        (m) => m.toFirebase(),
        waktu,
      );
      Log.info('Proses unggah data versi_apk_user selesai dengan sukses.');
    } on Exception catch (e, s) {
      Log.error(
        'Gagal mengunggah data versi_apk_user. '
        'Kemungkinan penyebab: gagal membaca data dari SQLite, '
        'gagal mengambil waktu sinkronisasi, atau gagal menulis ke Firestore.',
        e: e,
        s: s,
      );
      rethrow;
    }
  }

  /// Mengunggah data secara generik dari tabel SQLite ke koleksi Firestore.
  ///
  /// [T] adalah tipe model data yang akan diunggah.
  /// [namaTabel] adalah nama tabel di SQLite.
  /// [namaKoleksi] adalah nama koleksi di Firestore.
  /// [fromSqlite] adalah fungsi untuk mengonversi data dari SQLite ke model.
  /// [toFirebase] adalah fungsi untuk mengonversi model ke format data Firestore.
  /// [waktuTerakhirSinkronisasi] adalah waktu terakhir data disinkronkan.
  Future<void> uploadGenericData<T extends HasId>(
    final String namaTabel,
    final String namaKoleksi,
    final T Function(Map<String, dynamic>) fromSqlite,
    final Map<String, dynamic> Function(T) toFirebase,
    final DateTime waktuTerakhirSinkronisasi,
  ) async {
    Log.info('========================================');
    Log.info('MEMULAI UNGGAH DATA GENERIK');
    Log.info('Tabel SQLite sumber: $namaTabel');
    Log.info('Koleksi Firestore tujuan: $namaKoleksi');
    Log.info(
      'Waktu sinkronisasi terakhir: ${waktuTerakhirSinkronisasi.toIso8601String()}',
    );
    Log.info('Tipe data generik: $T');
    Log.info('========================================');

    try {
      Log.info('Mendapatkan instance database SQLite dari DatabaseHelper.');
      final db = await _sqliteDb.database;
      Log.info('Instance database berhasil didapatkan.');

      var dataUntukDiunggah = <Map<String, dynamic>>[];

      if (namaTabel == NamaTabel.versiApkUser) {
        Log.info(
          'Tabel $namaTabel adalah tabel khusus. Mengambil semua data tanpa filter waktu.',
        );
        dataUntukDiunggah = await db.query(namaTabel);
      } else {
        Log.info(
          'Melakukan query pada tabel $namaTabel dengan kondisi: '
          '${NamaKolom.diperbaruiPada} > ${waktuTerakhirSinkronisasi.millisecondsSinceEpoch}',
        );
        dataUntukDiunggah = await db.query(
          namaTabel,
          where: '${NamaKolom.diperbaruiPada} > ?',
          whereArgs: [waktuTerakhirSinkronisasi.millisecondsSinceEpoch],
        );
      }

      Log.info(
        'Query selesai. Jumlah data yang ditemukan untuk diunggah: ${dataUntukDiunggah.length} baris dari tabel $namaTabel.',
      );

      if (dataUntukDiunggah.isEmpty) {
        Log.info(
          'Tabel $namaTabel sudah sinkron dengan Firestore. '
          'Tidak ada data baru atau yang diperbarui sejak ${waktuTerakhirSinkronisasi.toIso8601String()}. '
          'Proses unggah untuk tabel ini dilewati.',
        );
        return;
      }
      Log.info(
        'Terdapat ${dataUntukDiunggah.length} data yang perlu diunggah dari tabel $namaTabel. '
        'Membuat Firestore batch operation untuk mengunggah data secara atomik.',
      );
      final batchFirestore = _firestore.batch();
      Log.info('Firestore batch berhasil dibuat.');
      var jumlahSukses = 0;
      final failedData = <Map<String, dynamic>>[];
      for (var i = 0; i < dataUntukDiunggah.length; i++) {
        final map = dataUntukDiunggah[i];
        Log.info(
          'Memproses data ke-${i + 1}/${dataUntukDiunggah.length} dari tabel $namaTabel.',
        );
        try {
          Log.info(
            'Mengkonversi data SQLite menjadi model $T menggunakan fungsi fromSqlite.',
          );
          final data = fromSqlite(map);
          if (data.id.isEmpty) {
            Log.warning(
              'Melewati data ke-${i + 1} dari tabel $namaTabel karena ID kosong. Data: $map',
            );
            failedData.add(map);
            continue;
          }
          Log.info(
            'Konversi berhasil. ID data: ${data.id}. '
            'Membuat referensi dokumen Firestore pada koleksi $namaKoleksi dengan ID ${data.id}.',
          );
          final docRef = _firestore.collection(namaKoleksi).doc(data.id);
          Log.info(
            'Mengkonversi model menjadi Map<String, dynamic> menggunakan fungsi toFirebase.',
          );
          final firebaseData = toFirebase(data);
          Log.info(
            'Konversi ke format Firestore berhasil. '
            'Jumlah field yang akan diunggah: ${firebaseData.length}.',
          );
          Log.info(
            'Menambahkan operasi set dengan merge:true ke batch Firestore untuk dokumen $namaKoleksi/${data.id}. '
            'Merge:true akan menggabungkan data baru dengan data yang sudah ada tanpa menghapus field lain.',
          );
          batchFirestore.set(docRef, firebaseData, SetOptions(merge: true));
          jumlahSukses++;
          Log.info(
            'Data ke-${i + 1} (ID: ${data.id}) berhasil ditambahkan ke batch Firestore.',
          );
        } catch (e, s) {
          failedData.add(map);
          Log.error(
            'Gagal memproses data ke-${i + 1} dari tabel $namaTabel. '
            'Data ini akan dilewati dan tidak dimasukkan ke batch. '
            'Data SQLite: $map',
            e: e,
            s: s,
          );
        }
      }

      Log.info(
        'Semua data selesai diproses. '
        'Total: ${dataUntukDiunggah.length} data, '
        'Sukses ditambahkan ke batch: $jumlahSukses, '
        'Gagal: ${failedData.length}.',
      );

      if (failedData.isNotEmpty) {
        Log.warning(
          'Ditemukan ${failedData.length} dari ${dataUntukDiunggah.length} data yang gagal dikonversi untuk tabel $namaTabel. '
          'Data yang gagal akan dilewati.',
        );
      }

      if (jumlahSukses > 0) {
        Log.info(
          'Melakukan commit batch Firestore. '
          'Mengirim $jumlahSukses dokumen ke koleksi $namaKoleksi secara atomik.',
        );
        await batchFirestore.commit();
        Log.info(
          'Batch commit berhasil. '
          '$jumlahSukses dokumen dari tabel $namaTabel berhasil diunggah ke Firestore koleksi $namaKoleksi.',
        );
      } else {
        Log.warning(
          'Tidak ada data yang berhasil diproses untuk tabel $namaTabel. '
          'Batch commit tidak dilakukan karena tidak ada data valid untuk diunggah.',
        );
      }

      Log.info('PROSES UNGGAH DATA GENERIK SELESAI');
      Log.info('Tabel: $namaTabel -> Koleksi: $namaKoleksi');
      Log.info('Total data diunggah: $jumlahSukses dokumen');
    } on Exception catch (e, s) {
      Log.error(
        'Gagal mengunggah data untuk tabel $namaTabel ke koleksi Firestore $namaKoleksi. ',
        e: e,
        s: s,
      );
      rethrow;
    }
  }
}

final layananUnggahDataProvider = Provider<LayananUnggahData>((ref) {
  return LayananUnggahData(
    sqliteDb: ref.read(sqliteDatabaseProvider),
    firestore: FirebaseFirestore.instance,
    syncManager: ref.read(pengelolaSinkronisasiProvider),
  );
});
```

### File: `lib/fitur/sinkronisasi/pengelola_sinkronisasi.dart`
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/shared/data/services/layanan_preferensi.dart'; // ← import
import 'package:wifi/shared/debug/log.dart';

final pengelolaSinkronisasiProvider = Provider<PengelolaSinkronisasi>((ref) {
  Log.info('Membuat instance SyncManager melalui Riverpod provider');
  return PengelolaSinkronisasi();
});

class PengelolaSinkronisasi {
  LayananPreferensi get _layananPrefs => LayananPreferensi();

  // Method dengan nama berbeda agar tidak bentrok
  Future<DateTime> ambilWaktuTerakhirUnduhPreferensi() async {
    Log.info('Meminta timestamp terakhir unduh dari PreferenceService');
    final hasil = await _layananPrefs
        .ambilWaktuTerakhirUnduh(); // ← fungsi top-level
    final waktuTerakhir =
        hasil ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    Log.info('Timestamp terakhir unduh yang digunakan: $waktuTerakhir');
    return waktuTerakhir;
  }

  Future<void> simpanWaktuTerakhirUnduhPreferensi(DateTime waktu) async {
    Log.info('Menyimpan timestamp terakhir unduh: $waktu');
    await _layananPrefs.simpanWaktuTerakhirUnduh(waktu); // ← fungsi top-level
    Log.info('Timestamp terakhir unduh berhasil disimpan');
  }

  Future<DateTime> ambilWaktuTerakhirUnggahPreferensi() async {
    Log.info('Meminta timestamp terakhir unggah dari PreferenceService');
    final hasil = await _layananPrefs
        .ambilWaktuTerakhirUnggah(); // ← fungsi top-level
    final waktuTerakhir =
        hasil ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    Log.info('Timestamp terakhir unggah yang digunakan: $waktuTerakhir');
    return waktuTerakhir;
  }

  Future<void> simpanWaktuTerakhirUnggahPreferensi(DateTime waktu) async {
    Log.info('Menyimpan timestamp terakhir unggah: $waktu');
    await _layananPrefs.simpanWaktuTerakhirUnggah(waktu); // ← fungsi top-level
    Log.info('Timestamp terakhir unggah berhasil disimpan');
  }

  Future<void> resetWaktuSinkronisasiPreferensi() async {
    Log.warning('MERESET WAKTU SINKRONISASI (UNDUH & UNGGAH)');
    await _layananPrefs.resetWaktuSinkronisasi(); // ← fungsi top-level
    Log.info('Waktu sinkronisasi (unduh dan unggah) berhasil di-reset.');
  }
}
```

