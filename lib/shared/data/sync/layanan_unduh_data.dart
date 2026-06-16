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
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/versi_apk/model/versi_apk_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/operation.dart';
import 'package:wifi/shared/utils/pengelola_sinkronisasi.dart';

class LayananUnduhData {
  final FirebaseFirestore _firestore;
  final PengelolaSinkronisasi _pengelolaSinkronisasi;
  final DompetOpSqlite _operasiDompet;
  final KategoriOpSqlite _operasiKategori;
  final PaketOpSqlite _operasiPaket;
  final PelangganOpSqlite _operasiPelanggan;
  final PelangganAktifOpSqlite _operasiPelangganAktif;
  final TransaksiOpSqlite _operasiTransaksi;
  final FeedbackOpSqlite _operasiUmpanBalik;
  final OrderOpsqlite _operasiPesanan;
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
    required TransaksiOpSqlite operasiTransaksi,
    required FeedbackOpSqlite operasiUmpanBalik,
    required OrderOpsqlite operasiPesanan,
    required SubKategoriOpSqlite operasiSubKategori,
    required VersiApkOpSqlite operasiVersiApk,
    required SettingsOpSqlite operasiPengaturan,
    required PengelolaSinkronisasi pengelolaSinkronisasi,
  })  : _pengelolaSinkronisasi = pengelolaSinkronisasi,
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
    required final TransaksiOpSqlite operasiTransaksi,
    required final FeedbackOpSqlite operasiUmpanBalik,
    required final OrderOpsqlite operasiPesanan,
    required final SubKategoriOpSqlite operasiSubKategori,
    required final VersiApkOpSqlite operasiVersiApk,
    required final SettingsOpSqlite operasiPengaturan,
  })  : _firestore = firestore,
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
      Log.error(
        'Kegagalan kritis selama prosedur unduh massal.',
        e: e,
        s: s,
      );
      rethrow;
    }
  }

  /// Mengunduh data pengaturan dari Firebase.
  Future<void> unduhDataPengaturan() async {
    Log.info('Memulai sinkronisasi untuk koleksi: [PENGATURAN]');
    try {
      final lastDownloadTime =
          await _pengelolaSinkronisasi.ambilWaktuTerakhirUnduh();
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
                'Inkompatibilitas Tipe: Field "${NamaKolom.diperbaruiPada}" bukan Timestamp.');
            return;
          }

          final waktuPembaruanServer = fieldValue.toDate();

          if (waktuPembaruanServer.isAfter(lastDownloadTime)) {
            Log.info('Data pengaturan server lebih baru, memperbarui lokal.');
            final settings = SettingsModel.fromFirebase(data);
            await _operasiPengaturan.saveOrUpdateSettings(
              settings,
              fromServer: true,
            );
            Log.info('Update Settings lokal berhasil.');
          } else {
            Log.info('Data pengaturan lokal sudah sinkron.');
          }
        } else {
          Log.warning(
              'Dokumen pengaturan tidak memiliki field "${NamaKolom.diperbaruiPada}".');
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
    final lastDownloadTime =
        await _pengelolaSinkronisasi.ambilWaktuTerakhirUnduh();
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
    final lastDownloadTime =
        await _pengelolaSinkronisasi.ambilWaktuTerakhirUnduh();
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
    final lastDownloadTime =
        await _pengelolaSinkronisasi.ambilWaktuTerakhirUnduh();
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
    final lastDownloadTime =
        await _pengelolaSinkronisasi.ambilWaktuTerakhirUnduh();
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
    final lastDownloadTime =
        await _pengelolaSinkronisasi.ambilWaktuTerakhirUnduh();
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
    final lastDownloadTime =
        await _pengelolaSinkronisasi.ambilWaktuTerakhirUnduh();
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
    final lastDownloadTime =
        await _pengelolaSinkronisasi.ambilWaktuTerakhirUnduh();
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
    final lastDownloadTime =
        await _pengelolaSinkronisasi.ambilWaktuTerakhirUnduh();
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
    final lastDownloadTime =
        await _pengelolaSinkronisasi.ambilWaktuTerakhirUnduh();
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
    final lastDownloadTime =
        await _pengelolaSinkronisasi.ambilWaktuTerakhirUnduh();
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

        final List<T> daftarData = [];
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
              'Mengirim ${daftarData.length} item ke operasi batch lokal.');
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
      Log.error(
        'Kegagalan sinkronisasi koleksi: $namaKoleksi',
        e: e,
        s: s,
      );
      rethrow;
    }
  }
}

final layananUnduhDataProvider = Provider<LayananUnduhData>((ref) {
  return LayananUnduhData(
    firestore: FirebaseFirestore.instance,
    syncManager: ref.read(PengelolaSinkronisasiProvider),
    operasiDompet: ref.read(dompetOpSqliteProvider),
    operasiKategori: ref.read(kategoriOpSqliteProvider),
    operasiPaket: ref.read(paketOpSqliteProvider),
    operasiPelanggan: ref.read(pelangganOpSqliteProvider),
    operasiPelangganAktif: ref.read(pelangganAktifOpSqliteProvider),
    operasiTransaksi: ref.read(transaksiOpSqliteProvider),
    operasiUmpanBalik: ref.read(feedbackOpSqliteProvider),
    operasiPesanan: ref.read(orderOpSqliteProvider),
    operasiSubKategori: ref.read(subKategoriOpSqliteProvider),
    operasiVersiApk: ref.read(versiApkOpSqliteProvider),
    operasiPengaturan: ref.read(settingsOpSqliteProvider),
    pengelolaSinkronisasi: ref.read(PengelolaSinkronisasiProvider),
  );
});
