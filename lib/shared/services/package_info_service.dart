// path: lib/shared/services/package_info_service.dart
// File ini bertanggung jawab untuk menyediakan informasi paket aplikasi.

import 'package:package_info_plus/package_info_plus.dart';
import 'package:wifi/shared/debug/log.dart';

/// Kelas layanan untuk mengambil informasi paket aplikasi.
class PackageInfoService {
  /// Konstruktor untuk PackageInfoService.
  PackageInfoService() {
    Log.info('PackageInfoService diinisialisasi.');
  }

  /// Mengambil informasi paket aplikasi seperti versi dan build number.
  ///
  /// Mengembalikan objek [PackageInfo] jika berhasil, atau `null` jika gagal.
  Future<PackageInfo?> getPackageInfo() async {
    Log.info('Mencoba mengambil info paket aplikasi.');
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      Log.info('Berhasil mengambil info paket.', {
        'appName': packageInfo.appName,
        'packageName': packageInfo.packageName,
        'version': packageInfo.version,
        'buildNumber': packageInfo.buildNumber,
      });
      return packageInfo;
    } on Exception catch (e, st) {
      Log.error('Gagal mengambil info paket.', e: e, st: st);
      return null;
    }
  }
}
