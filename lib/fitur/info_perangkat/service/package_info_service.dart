// path: lib/fitur/info_perangkat/service/package_info_service.dart

import 'package:package_info_plus/package_info_plus.dart';
import 'package:wifi/fitur/info_perangkat/model/info_perangkat_model.dart';
import 'package:wifi/shared/debug/log.dart';

/// Kelas layanan untuk mendapatkan informasi paket aplikasi.
class LayananInfoPaket {
  /// Konstruktor untuk [LayananInfoPaket].
  LayananInfoPaket() {
    Log.info('LayananInfoPaket diinisialisasi.');
  }

  /// Mengambil informasi paket aplikasi yang sedang berjalan.
  ///
  /// Mengembalikan instance [InfoPerangkatModel] yang berisi detail seperti
  /// nama aplikasi, nama paket, versi, dan nomor build.
  /// Mengembalikan `null` jika terjadi kesalahan saat mengambil data.
  Future<InfoPerangkatModel?> ambilInfoPaket() async {
    Log.info('Mencoba mengambil info paket aplikasi.');
    try {
      final infoPaket = await PackageInfo.fromPlatform();
      final model = InfoPerangkatModel.fromPackageInfo(infoPaket);
      Log.info('Berhasil mengambil info paket.', {
        'namaAplikasi': model.appName,
        'namaPaket': model.packageName,
        'versi': model.version,
        'nomorBuild': model.buildNumber,
      });
      return model;
    } catch (e, st) {
      Log.error('Gagal mengambil info paket.', e: e, s: st);
      return null;
    }
  }
}
