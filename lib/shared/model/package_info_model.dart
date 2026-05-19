// path: lib/shared/model/package_info_model.dart
// Model untuk membungkus data dari package_info_plus.

import 'package:package_info_plus/package_info_plus.dart';

/// Model data yang merepresentasikan informasi dari [PackageInfo].
class PackageInfoModel {
  /// Nama aplikasi.
  final String appName;

  /// Nama paket (package name).
  final String packageName;

  /// Nomor versi aplikasi (e.g., "1.0.0").
  final String version;

  /// Nomor build aplikasi (e.g., "1").
  final String buildNumber;

  /// Konstruktor untuk [PackageInfoModel].
  const PackageInfoModel({
    required this.appName,
    required this.packageName,
    required this.version,
    required this.buildNumber,
  });

  /// Factory constructor untuk membuat instance dari [PackageInfo].
  factory PackageInfoModel.fromPackageInfo(final PackageInfo packageInfo) {
    return PackageInfoModel(
      appName: packageInfo.appName,
      packageName: packageInfo.packageName,
      version: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
    );
  }
}
