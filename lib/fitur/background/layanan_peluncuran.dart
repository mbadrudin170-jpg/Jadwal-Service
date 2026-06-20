// path: lib/fitur/background/boot_service.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/alarm/penjadwal_alarm_android.dart';
import 'package:wifi/fitur/background/layanan_latar_belakang.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/shared/debug/log.dart';

const int idArsipKadaluarsaPeriodik = 999;
const int idArsipKadaluarsaSekaliJalan = 998;

class LayananPeluncuran {
  Future<void> jadwalkanTugasArsipPeriodik(ProviderContainer container) async {
    final penjadwalAlarm = container.read(penjadwalAlarmProvider);

    await penjadwalAlarm.jadwalkanPeriodik(
      const Duration(hours: 1),
      idArsipKadaluarsaPeriodik,
      LayananLatarBelakang.periksaDanArsipkanPelangganKedaluwarsa,
      mulaiPada: DateTime.now().add(const Duration(seconds: 10)),
      tepatWaktu: true,
      bangunkan: true,
      jadwalkanUlangSaatBoot: true,
    );
  }

  Future<void> jadwalkanUlangTugasArsip(ProviderContainer container) async {
    Log.info('Memulai penjadwalan ulang tugas pengarsipan...');
    final penjadwalAlarm = container.read(penjadwalAlarmProvider);
    final pelangganAktifOpSqlite = container.read(
      pelangganAktifOpSqliteProvider,
    );

    try {
      final daftarPelangganAktif = await pelangganAktifOpSqlite
          .ambilSemuaPelangganAktifDenganDetail();

      await penjadwalAlarm.batalkan(idArsipKadaluarsaSekaliJalan);
      Log.info(
        'Alarm sekali jalan (ID: $idArsipKadaluarsaSekaliJalan) berhasil dibatalkan.',
      );

      if (daftarPelangganAktif.isEmpty) {
        Log.warning('Tidak ada pelanggan aktif, tidak ada penjadwalan ulang.');
        return;
      }

      daftarPelangganAktif.sort(
        (a, b) => a.pelangganAktif.tanggalBerakhir.compareTo(
          b.pelangganAktif.tanggalBerakhir,
        ),
      );

      final tanggalKadaluarsaTerdekat =
          daftarPelangganAktif.first.pelangganAktif.tanggalBerakhir;

      await penjadwalAlarm.jadwalkanSekaliPada(
        tanggalKadaluarsaTerdekat,
        idArsipKadaluarsaSekaliJalan,
        LayananLatarBelakang.periksaDanArsipkanPelangganKedaluwarsa,
        tepatWaktu: true,
        bangunkan: true,
        jadwalkanUlangSaatBoot: true,
      );

      Log.info(
        'Penjadwalan ulang berhasil. Alarm sekali jalan diatur untuk: $tanggalKadaluarsaTerdekat',
      );
    } on Exception catch (e, st) {
      Log.error('Gagal menjadwalkan ulang tugas pengarsipan', e: e, s: st);
    }
  }
}
