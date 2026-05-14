// path: lib/shared/data/sync/unduh_data.dart
// diubah: Memperbaiki blok catch yang salah dan duplikat.

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

/// Layanan untuk mengunduh semua data dari Firebase.
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

  /// Konstruktor untuk LayananUnduhData.
  LayananUnduhData({FirebaseFirestore? firestore, SyncManager? syncManager})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _syncManager = syncManager ?? SyncManager() {
    Log.info(
      'LayananUnduhData berhasil diinisialisasi.',
    );
  }

  /// Mengunduh semua data dari semua koleksi di Firebase.
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
    } on Exception catch (e, s) {
      Log.error(
        'Kegagalan kritis selama prosedur unduh massal.',
        e: e,
        st: s,
      );
      rethrow;
    }
  }

  /// Mengunduh data pengaturan dari Firebase.
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
            await _pengaturanOperasi.simpanAtauPerbaruiPengaturan(
              pengaturan,
              dariServer: true,
            );
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
    } on Exception catch (e, s) {
      Log.error('Kesalahan sinkronisasi Pengaturan.', e: e, st: s);
    }
  }

  /// Mengunduh data dompet dari Firebase.
  Future<void> unduhDataDompet() async {
    final waktu = await _syncManager.getTerakhirUnduh();
    await sinkronisasiKoleksi<DompetModel>(
      namaKoleksi: 'dompet',
      waktuUnduhTerakhir: waktu,
      fromFirebase: DompetModel.fromFirebase,
      operasiBatch: (data) =>
          _dompetOperasi.sisipkanAtauPerbaruiBatch(data, dariServer: true),
    );
  }

  /// Mengunduh data kategori dari Firebase.
  Future<void> unduhDataKategori() async {
    final waktu = await _syncManager.getTerakhirUnduh();
    await sinkronisasiKoleksi<KategoriModel>(
      namaKoleksi: 'kategori',
      waktuUnduhTerakhir: waktu,
      fromFirebase: KategoriModel.fromFirebase,
      operasiBatch: (data) =>
          _kategoriOperasi.sisipkanAtauPerbaruiBatch(data, dariServer: true),
    );
  }

  /// Mengunduh data paket dari Firebase.
  Future<void> unduhDataPaket() async {
    final waktu = await _syncManager.getTerakhirUnduh();
    await sinkronisasiKoleksi<PaketModel>(
      namaKoleksi: 'paket',
      waktuUnduhTerakhir: waktu,
      fromFirebase: PaketModel.fromFirebase,
      operasiBatch: (data) =>
          _paketOperasi.sisipkanAtauPerbaruiBatch(data, dariServer: true),
    );
  }

  /// Mengunduh data pelanggan dari Firebase.
  Future<void> unduhDataPelanggan() async {
    final waktu = await _syncManager.getTerakhirUnduh();
    await sinkronisasiKoleksi<PelangganModel>(
      namaKoleksi: 'pelanggan',
      waktuUnduhTerakhir: waktu,
      fromFirebase: PelangganModel.fromFirebase,
      operasiBatch: (data) =>
          _pelangganOperasi.sisipkanAtauPerbaruiBatch(data, dariServer: true),
    );
  }

  /// Mengunduh data pelanggan aktif dari Firebase.
  Future<void> unduhDataPelangganAktif() async {
    final waktu = await _syncManager.getTerakhirUnduh();
    await sinkronisasiKoleksi<PelangganAktifModel>(
      namaKoleksi: 'pelanggan_aktif',
      waktuUnduhTerakhir: waktu,
      fromFirebase: PelangganAktifModel.fromFirebase,
      operasiBatch: (data) => _pelangganAktifOperasi
          .sisipkanAtauPerbaruiBatch(data, dariServer: true),
    );
  }

  /// Mengunduh data transaksi dari Firebase.
  Future<void> unduhDataTransaksi() async {
    final waktu = await _syncManager.getTerakhirUnduh();
    await sinkronisasiKoleksi<TransaksiModel>(
      namaKoleksi: 'transaksi',
      waktuUnduhTerakhir: waktu,
      fromFirebase: TransaksiModel.fromFirebase,
      operasiBatch: (data) =>
          _transaksiOperasi.sisipkanAtauPerbaruiBatch(data, dariServer: true),
    );
  }

  /// Mengunduh data kritik dan saran dari Firebase.
  Future<void> unduhDataKritikSaran() async {
    final waktu = await _syncManager.getTerakhirUnduh();
    await sinkronisasiKoleksi<KritikSaranModel>(
      namaKoleksi: 'kritik_saran',
      waktuUnduhTerakhir: waktu,
      fromFirebase: KritikSaranModel.fromFirebase,
      operasiBatch: (data) =>
          _kritikSaranOperasi.sisipkanAtauPerbaruiBatch(data, dariServer: true),
    );
  }

  /// Mengunduh data pesanan dari Firebase.
  Future<void> unduhDataPesanan() async {
    final waktu = await _syncManager.getTerakhirUnduh();
    await sinkronisasiKoleksi<PesananModel>(
      namaKoleksi: 'pesan',
      waktuUnduhTerakhir: waktu,
      fromFirebase: PesananModel.fromFirebase,
      operasiBatch: (data) =>
          _pesanOperasi.sisipkanAtauPerbaruiBatch(data, dariServer: true),
    );
  }

  /// Mengunduh data sub-kategori dari Firebase.
  Future<void> unduhDataSubKategori() async {
    final waktu = await _syncManager.getTerakhirUnduh();
    await sinkronisasiKoleksi<SubKategoriModel>(
      namaKoleksi: 'sub_kategori',
      waktuUnduhTerakhir: waktu,
      fromFirebase: SubKategoriModel.fromFirebase,
      operasiBatch: (data) =>
          _subKategoriOperasi.sisipkanAtauPerbaruiBatch(data, dariServer: true),
    );
  }

  /// Mengunduh data versi APK user dari Firebase.
  Future<void> unduhDataVersiApkUser() async {
    final waktu = await _syncManager.getTerakhirUnduh();
    await sinkronisasiKoleksi<VersiApkUserModel>(
      namaKoleksi: 'versi_apk_user',
      waktuUnduhTerakhir: waktu,
      fromFirebase: VersiApkUserModel.fromFirebase,
      operasiBatch: (data) => _versiApkUserOperasi
          .sisipkanAtauPerbaruiBatch(data, dariServer: true),
    );
  }

  /// Menyinkronkan satu koleksi dari Firebase ke database lokal.
  ///
  /// [T] adalah tipe model data yang akan disinkronkan.
  /// [namaKoleksi] adalah nama koleksi di Firebase.
  /// [waktuUnduhTerakhir] adalah waktu terakhir data diunduh.
  /// [fromFirebase] adalah fungsi untuk mengonversi data dari Firebase ke model lokal.
  /// [operasiBatch] adalah fungsi untuk menyimpan data secara batch ke database lokal.
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
          }on Exception catch (e, s) {
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
        st: s,
      );
    }
  }
}
