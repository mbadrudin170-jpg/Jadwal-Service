// path: lib/fitur/info_perangkat/service/layanan_info_paket.dart

import 'package:package_info_plus/package_info_plus.dart';
import 'package:wifi/fitur/info_perangkat/model/info_perangkat_model.dart';
import 'package:wifi/shared/debug/log.dart';

class LayananInfoPaket {
  LayananInfoPaket() {
    Log.info('LayananInfoPaket diinisialisasi.');
  }

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
