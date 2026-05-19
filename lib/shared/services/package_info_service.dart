// path: lib/shared/services/package_info_service.dart
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/package_info_model.dart';

/// Kelas layanan untuk mendapatkan informasi paket aplikasi.
class PackageInfoService {
  /// Konstruktor untuk [PackageInfoService].
  PackageInfoService() {
    Log.info('PackageInfoService diinisialisasi.');
  }

  /// Mengambil informasi paket aplikasi yang sedang berjalan.
  ///
  /// Mengembalikan instance [PackageInfoModel] yang berisi detail seperti
  /// nama aplikasi, nama paket, versi, dan nomor build.
  /// Mengembalikan `null` jika terjadi kesalahan saat mengambil data.
  Future<PackageInfoModel?> getPackageInfo() async {
    Log.info('Mencoba mengambil info paket aplikasi.');
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final model = PackageInfoModel.fromPackageInfo(packageInfo);
      Log.info('Berhasil mengambil info paket.', {
        'appName': model.appName,
        'packageName': model.packageName,
        'version': model.version,
        'buildNumber': model.buildNumber,
      });
      return model;
    } on Exception catch (e, st) {
      Log.error('Gagal mengambil info paket.', e: e, st: st);
      return null;
    }
  }
}
