// path: lib/shared/data/services/layanan_cek_sinkronisasi.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/sinkronisasi/layanan_unduh_data.dart';
import 'package:wifi/fitur/sinkronisasi/layanan_unggah_data.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/data/services/layanan_pengecekan_data_baru.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/utils/pengelola_sinkronisasi.dart';

/// Layanan untuk mengorkestrasi proses sinkronisasi data.
class LayananCekSinkronisasi {
  final PengelolaSinkronisasi _pengelolaSinkronisasi;
  final LayananUnggahData _layananUnggah;
  final LayananUnduhData _layananUnduh;
  final LayananPengecekanDataBaru _pengecekanDataBaru;
  final FirebaseFirestore _firestore;
  bool _berjalan = false;

  /// Konstruktor dengan injeksi dependensi (wajib).
  LayananCekSinkronisasi({
    required PengelolaSinkronisasi pengelolaSinkronisasi,
    required LayananUnggahData layananUnggah,
    required LayananUnduhData layananUnduh,
    required LayananPengecekanDataBaru pengecekanDataBaru,
    required FirebaseFirestore firestore,
  }) : _pengelolaSinkronisasi = pengelolaSinkronisasi,
       _layananUnggah = layananUnggah,
       _layananUnduh = layananUnduh,
       _pengecekanDataBaru = pengecekanDataBaru,
       _firestore = firestore {
    Log.info('SyncCheckService diinisialisasi dengan dependency injection.');
  }

  /// Menjalankan seluruh proses pengecekan dan sinkronisasi data.
  Future<void> jalankanCekSinkronisasi() async {
    Log.info('Memulai siklus orkestrasi sinkronisasi global.');
    if (_berjalan) {
      return;
    }
    _berjalan = true;
    try {
      final bool sudahUnggahData = await _periksaDanJalankanUnggah();
      if (sudahUnggahData) {
        Log.info(
          'Pemicu sinkronisasi: Ada data baru yang berhasil diunggah ke server.',
        );
        await _perbaruiStatusGlobal();
      }
      await _periksaDanJalankanUnduh();
      Log.info('Seluruh siklus runSyncCheck() telah berakhir dengan sukses.');
    } finally {
      _berjalan = false;
    }
  }

  Future<bool> _periksaDanJalankanUnggah() async {
    final DateTime sekarang = DateTime.now();
    try {
      final bool adaDataUntukUnggah = await _pengecekanDataBaru
          .apakahSqliteAdaDataBaru();
      if (adaDataUntukUnggah) {
        await _layananUnggah.unggahSemuaData();
        await _pengelolaSinkronisasi.simpanWaktuTerakhirUnggah(sekarang);
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
      final bool adaDataBaruDiServer = await _pengecekanDataBaru
          .apakahFirebaseAdaDataBaru(
            namaKoleksi: NamaTabel.statusGlobal,
            idDokumen: globalStatusId,
          );
      if (adaDataBaruDiServer) {
        await _layananUnduh.unduhSemuaData();
        final DateTime sekarang = DateTime.now();
        await _pengelolaSinkronisasi.simpanWaktuTerakhirUnduh(sekarang);
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
  );
});
