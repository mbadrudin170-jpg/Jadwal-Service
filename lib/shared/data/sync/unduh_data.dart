// path: lib/shared/data/sync/unduh_data.dart
// diubah: Memperbaiki typo dan menambahkan `dariServer` ke pemanggilan batch.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/dompet_model.dart';
import 'package:wifi/shared/model/kategori_model.dart';
import 'package:wifi/shared/model/kritik_saran_model.dart';
import 'package:wifi/shared/model/paket_model.dart';
import 'package:wifi/shared/model/pelanggan_aktif_model.dart';
import 'package:wifi/shared/model/pelanggan_model.dart';
import 'package:wifi/shared/model/pengaturan_model.dart';
import 'package:wifi/shared/model/pesanan_model.dart';
import 'package:wifi/shared/model/sub_kategori_model.dart';
import 'package:wifi/shared/model/transaksi_model.dart';
import 'package:wifi/shared/model/versi_apk_user_model.dart';
import 'package:wifi/shared/operasi/dompet_operasi.dart';
import 'package:wifi/shared/operasi/kategori_operasi.dart';
import 'package:wifi/shared/operasi/kritik_saran_operasi.dart';
import 'package:wifi/shared/operasi/paket_operasi.dart';
import 'package:wifi/shared/operasi/pelanggan_aktif_operasi.dart';
import 'package:wifi/shared/operasi/pelanggan_operasi.dart';
import 'package:wifi/shared/operasi/pengaturan_operasi.dart';
import 'package:wifi/shared/operasi/pesanan_operasi.dart';
import 'package:wifi/shared/operasi/sub_kategori_operasi.dart';
import 'package:wifi/shared/operasi/transaksi_operasi.dart';
import 'package:wifi/shared/operasi/versi_apk_user_operasi.dart';
import 'package:wifi/shared/utils/sync_manager.dart';

class LayananUnduhData {
  final FirebaseFirestore _firestore;
  final SyncManager _syncManager;

  // Operasi
  final DompetOperasi _dompetOperasi = DompetOperasi();
  final KategoriOperasi _kategoriOperasi = KategoriOperasi();
  final PaketOperasi _paketOperasi = PaketOperasi();
  final PelangganOperasi _pelangganOperasi = PelangganOperasi();
  final PelangganAktifOperasi _pelangganAktifOperasi = PelangganAktifOperasi();
  final TransaksiOperasi _transaksiOperasi = TransaksiOperasi();
  final KritikSaranOperasi _kritikSaranOperasi = KritikSaranOperasi();
  final PesananOperasi _pesanOperasi = PesananOperasi();
  final SubKategoriOperasi _subKategoriOperasi = SubKategoriOperasi();
  final VersiApkUserOperasi _versiApkUserOperasi = VersiApkUserOperasi();
  final PengaturanOperasi _pengaturanOperasi = PengaturanOperasi();

  LayananUnduhData({FirebaseFirestore? firestore, SyncManager? syncManager})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _syncManager = syncManager ?? SyncManager() {
    Log.info(
      'LayananUnduhData berhasil diinisialisasi.',
    );
  }

  Future<void> unduhSemuaData() async {
    Log.info(
      'Memulai prosedur orkestrasi unduh data massal.',
    );
    final stopwatch = Stopwatch()..start();

    try {
      await Future.wait([
        unduhDataPengaturan(),
        unduhDataDompet(),
        unduhDataKategori(),
        unduhDataPaket(),
        unduhDataPelanggan(),
        unduhDataPelangganAktif(),
        unduhDataTransaksi(),
        unduhDataKritikSaran(),
        unduhDataPesanan(),
        unduhDataSubKategori(),
        unduhDataVersiApkUser(),
      ]);

      stopwatch.stop();
      Log.info(
        'Prosedur unduh data massal selesai sepenuhnya. Total durasi: ${stopwatch.elapsed.inMilliseconds} ms.',
      );
    } catch (e, s) {
      Log.error(
        'Kegagalan kritis selama prosedur unduh massal.',
        e: e,
        st: s,
      );
      rethrow;
    }
  }

  Future<void> unduhDataPengaturan() async {
    Log.info('Memulai sinkronisasi untuk koleksi: [PENGATURAN]');
    try {
      final waktuUnduhTerakhir = await _syncManager.getTerakhirUnduh();
      final docRef =
          _firestore.collection('pengaturan').doc(idPengaturanGlobal);
      final doc = await docRef.get(const GetOptions(source: Source.server));

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data.containsKey('diperbarui')) {
          final dynamic fieldValue = data['diperbarui'];

          if (fieldValue is! Timestamp) {
            Log.error(
              'Inkompatibilitas Tipe: Field "diperbarui" bukan Timestamp.',
            );
            return;
          }

          final waktuPembaruanServer = (fieldValue).toDate();

          if (waktuPembaruanServer.isAfter(waktuUnduhTerakhir)) {
            Log.info('Data pengaturan server lebih baru, memperbarui lokal.');
            final pengaturan = PengaturanModel.fromFirebase(data);
            await _pengaturanOperasi.simpanAtauPerbaruiPengaturan(pengaturan,
                dariServer: true);
            Log.info('Update Pengaturan lokal berhasil.');
          } else {
            Log.info('Data pengaturan lokal sudah sinkron.');
          }
        } else {
          Log.warning('Dokumen pengaturan tidak memiliki field "diperbarui".');
        }
      } else {
        Log.warning('Dokumen pengaturan tidak ditemukan di server.');
      }
    } catch (e, s) {
      Log.error('Kesalahan sinkronisasi Pengaturan.', e: e, st: s);
    }
  }

  // Wrapper untuk Koleksi Lainnya
  Future<void> unduhDataDompet() async {
    final waktu = await _syncManager.getTerakhirUnduh();
    await sinkronisasiKoleksi<DompetModel>(
      namaKoleksi: 'dompet',
      waktuUnduhTerakhir: waktu,
      fromFirebase: (id, map) => DompetModel.fromFirebase(id, map),
      operasiBatch: (data) =>
          _dompetOperasi.sisipkanAtauPerbaruiBatch(data, dariServer: true),
    );
  }

  Future<void> unduhDataKategori() async {
    final waktu = await _syncManager.getTerakhirUnduh();
    await sinkronisasiKoleksi<KategoriModel>(
      namaKoleksi: 'kategori',
      waktuUnduhTerakhir: waktu,
      fromFirebase: (id, map) => KategoriModel.fromFirebase(id, map),
      operasiBatch: (data) =>
          _kategoriOperasi.sisipkanAtauPerbaruiBatch(data, dariServer: true),
    );
  }

  Future<void> unduhDataPaket() async {
    final waktu = await _syncManager.getTerakhirUnduh();
    await sinkronisasiKoleksi<PaketModel>(
      namaKoleksi: 'paket',
      waktuUnduhTerakhir: waktu,
      fromFirebase: (id, map) => PaketModel.fromFirebase(id, map),
      operasiBatch: (data) =>
          _paketOperasi.sisipkanAtauPerbaruiBatch(data, dariServer: true),
    );
  }

  Future<void> unduhDataPelanggan() async {
    final waktu = await _syncManager.getTerakhirUnduh();
    await sinkronisasiKoleksi<PelangganModel>(
      namaKoleksi: 'pelanggan',
      waktuUnduhTerakhir: waktu,
      fromFirebase: (id, map) => PelangganModel.fromFirebase(id, map),
      operasiBatch: (data) =>
          _pelangganOperasi.sisipkanAtauPerbaruiBatch(data, dariServer: true),
    );
  }

  Future<void> unduhDataPelangganAktif() async {
    final waktu = await _syncManager.getTerakhirUnduh();
    await sinkronisasiKoleksi<PelangganAktifModel>(
      namaKoleksi: 'pelanggan_aktif',
      waktuUnduhTerakhir: waktu,
      fromFirebase: (id, map) => PelangganAktifModel.fromFirebase(id, map),
      operasiBatch: (data) => _pelangganAktifOperasi
          .sisipkanAtauPerbaruiBatch(data, dariServer: true),
    );
  }

  Future<void> unduhDataTransaksi() async {
    final waktu = await _syncManager.getTerakhirUnduh();
    await sinkronisasiKoleksi<TransaksiModel>(
      namaKoleksi: 'transaksi',
      waktuUnduhTerakhir: waktu,
      fromFirebase: (id, map) => TransaksiModel.fromFirebase(id, map),
      operasiBatch: (data) =>
          _transaksiOperasi.sisipkanAtauPerbaruiBatch(data, dariServer: true),
    );
  }

  Future<void> unduhDataKritikSaran() async {
    final waktu = await _syncManager.getTerakhirUnduh();
    await sinkronisasiKoleksi<KritikSaranModel>(
      namaKoleksi: 'kritik_saran',
      waktuUnduhTerakhir: waktu,
      fromFirebase: (id, map) => KritikSaranModel.fromFirebase(id, map),
      operasiBatch: (data) =>
          _kritikSaranOperasi.sisipkanAtauPerbaruiBatch(data, dariServer: true),
    );
  }

  Future<void> unduhDataPesanan() async {
    final waktu = await _syncManager.getTerakhirUnduh();
    await sinkronisasiKoleksi<PesananModel>(
      namaKoleksi: 'pesan',
      waktuUnduhTerakhir: waktu,
      fromFirebase: (id, map) => PesananModel.fromFirebase(id, map),
      operasiBatch: (data) =>
          _pesanOperasi.sisipkanAtauPerbaruiBatch(data, dariServer: true),
    );
  }

  Future<void> unduhDataSubKategori() async {
    final waktu = await _syncManager.getTerakhirUnduh();
    await sinkronisasiKoleksi<SubKategoriModel>(
      namaKoleksi: 'sub_kategori',
      waktuUnduhTerakhir: waktu,
      fromFirebase: (id, map) => SubKategoriModel.fromFirebase(id, map),
      operasiBatch: (data) =>
          _subKategoriOperasi.sisipkanAtauPerbaruiBatch(data, dariServer: true),
    );
  }

  Future<void> unduhDataVersiApkUser() async {
    final waktu = await _syncManager.getTerakhirUnduh();
    await sinkronisasiKoleksi<VersiApkUserModel>(
      namaKoleksi: 'versi_apk_user',
      waktuUnduhTerakhir: waktu,
      fromFirebase: (id, map) => VersiApkUserModel.fromFirebase(id, map),
      operasiBatch: (data) => _versiApkUserOperasi
          .sisipkanAtauPerbaruiBatch(data, dariServer: true),
    );
  }

  Future<void> sinkronisasiKoleksi<T>({
    required String namaKoleksi,
    required DateTime waktuUnduhTerakhir,
    required T Function(String id, Map<String, dynamic> data) fromFirebase,
    required Future<void> Function(List<T>) operasiBatch,
  }) async {
    Log.info(
      'Sinkronisasi Koleksi: Memeriksa [$namaKoleksi] untuk data baru sejak $waktuUnduhTerakhir.',
    );
    try {
      final snapshot = await _firestore
          .collection(namaKoleksi)
          .where('diperbarui', isGreaterThan: waktuUnduhTerakhir)
          .get(const GetOptions(source: Source.server));

      if (snapshot.docs.isNotEmpty) {
        Log.info(
          'Ditemukan ${snapshot.docs.length} dokumen baru/diperbarui di [$namaKoleksi].',
        );

        final List<T> dataList = [];
        for (final doc in snapshot.docs) {
          try {
            dataList.add(fromFirebase(doc.id, doc.data()));
          } catch (e, s) {
            Log.error(
              'Gagal memproses dokumen ${doc.id} di koleksi $namaKoleksi',
              e: e,
              st: s,
            );
          }
        }

        if (dataList.isNotEmpty) {
          Log.info('Mengirim ${dataList.length} item ke operasi batch lokal.');
          await operasiBatch(dataList);
          Log.info('Sinkronisasi masuk untuk [$namaKoleksi] berhasil.');
        } else {
          Log.warning(
              'Tidak ada data valid untuk disimpan dari [$namaKoleksi].');
        }
      } else {
        Log.info('Koleksi [$namaKoleksi] sudah sinkron.');
      }
    } catch (e, s) {
      Log.error(
        'Kegagalan sinkronisasi koleksi: $namaKoleksi',
        e: e,
        st: s,
      );
    }
  }
}
