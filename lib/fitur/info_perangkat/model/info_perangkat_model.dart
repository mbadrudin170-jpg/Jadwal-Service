// path: lib/fitur/info_perangkat/model/info_perangkat_model.dart

import 'package:package_info_plus/package_info_plus.dart';

/// Model data yang merepresentasikan informasi dari [PackageInfo].
class InfoPerangkatModel {
  /// Nama aplikasi.
  final String appName;

  /// Nama paket (package name).
  final String packageName;

  /// Nomor versi aplikasi (e.g., "1.0.0").
  final String version;

  /// Nomor build aplikasi (e.g., "1").
  final String buildNumber;

  /// Konstruktor untuk [InfoPerangkatModel].
  const InfoPerangkatModel({
    required this.appName,
    required this.packageName,
    required this.version,
    required this.buildNumber,
  });

  /// Factory constructor untuk membuat instance dari [PackageInfo].
  factory InfoPerangkatModel.fromPackageInfo(final PackageInfo packageInfo) {
    return InfoPerangkatModel(
      appName: packageInfo.appName,
      packageName: packageInfo.packageName,
      version: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
    );
  }
}
