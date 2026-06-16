// path: test/fitur/info_perangkat/model/info_perangkat_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wifi/fitur/info_perangkat/model/info_perangkat_model.dart';

void main() {
  group('InfoPerangkatModel', () {
    test('01. fromPackageInfo harus membuat instance dengan benar', () {
      final packageInfo = PackageInfo(
        appName: 'Test App',
        packageName: 'com.test.app',
        version: '1.0.0',
        buildNumber: '1',
        buildSignature: '',
      );

      final model = InfoPerangkatModel.fromPackageInfo(packageInfo);

      expect(model.namaApk, 'Test App');
      expect(model.namaPaket, 'com.test.app');
      expect(model.versi, '1.0.0');
      expect(model.nomorBuild, '1');
    });

    test('02. constructor harus membuat instance dengan benar', () {
      const model = InfoPerangkatModel(
        namaApk: 'Another App',
        namaPaket: 'com.another.app',
        versi: '2.0.0',
        nomorBuild: '2',
      );

      expect(model.namaApk, 'Another App');
      expect(model.namaPaket, 'com.another.app');
      expect(model.versi, '2.0.0');
      expect(model.nomorBuild, '2');
    });
  });
}
