// path: lib/fitur/info_perangkat/model/info_perangkat_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_info_plus/package_info_plus.dart';

part 'info_perangkat_model.freezed.dart';

@freezed
abstract class InfoPerangkatModel with _$InfoPerangkatModel {
  const InfoPerangkatModel._();
  const factory InfoPerangkatModel({
    required String namaApk,
    required String namaPaket,
    required String versi,
    required String nomorBuild,
  }) = _InfoPerangkatModel;

  factory InfoPerangkatModel.fromPackageInfo(PackageInfo info) {
    return InfoPerangkatModel(
      namaApk: info.appName,
      namaPaket: info.packageName,
      versi: info.version,
      nomorBuild: info.buildNumber,
    );
  }
}
