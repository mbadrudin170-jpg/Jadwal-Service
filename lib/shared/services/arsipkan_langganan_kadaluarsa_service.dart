// path: lib/shared/services/arsipkan_langganan_kadaluarsa_service.dart


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/fitur/pelanggan_aktif/operasi/pelanggan_aktif_op_sqlite.dart';

/// Service untuk memeriksa dan mengarsipkan langganan yang kadaluwarsa.
class ArsipLanggananKadaluarsaService {
  final PelangganAktifOpSqlite _pelangganAktifOpSqlite;

  /// Konstruktor dengan injeksi dependensi.
  ArsipLanggananKadaluarsaService({
    required PelangganAktifOpSqlite pelangganAktifOpSqlite,
  }) : _pelangganAktifOpSqlite = pelangganAktifOpSqlite {
    Log.info(
        'ExpiredSubscriptionCheckService diinisialisasi dengan dependency injection.');
  }

  /// Memproses semua pelanggan aktif, menemukan yang kedaluwarsa,
  /// dan mengarsipkannya.
  Future<void> prosesArsipLanggananKadaluarsa() async {
    Log.info('Memulai siklus pengecekan langganan yang kadaluwarsa...');
    try {
      final jumlahDiarsipkan =
          await _pelangganAktifOpSqlite.arsipkanLanggananKadaluarsa();
      if (jumlahDiarsipkan > 0) {
        Log.info(
            'Berhasil mengarsipkan $jumlahDiarsipkan langganan kadaluwarsa.');
      } else {
        Log.info('Tidak ada langganan kadaluwarsa.');
      }
    } on Exception catch (e, s) {
      Log.error('Gagal memproses langganan kadaluwarsa.', e: e, s: s);
    }
  }
}

final arsipLanggananKadaluarsaServiceProvider =
    Provider<ArsipLanggananKadaluarsaService>((ref) {
  return ArsipLanggananKadaluarsaService(
    pelangganAktifOpSqlite: ref.read(pelangganAktifOpSqliteProvider),
  );
});
