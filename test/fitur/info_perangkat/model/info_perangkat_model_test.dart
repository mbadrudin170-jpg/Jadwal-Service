
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

      expect(model.appName, 'Test App');
      expect(model.packageName, 'com.test.app');
      expect(model.version, '1.0.0');
      expect(model.buildNumber, '1');
    });

    test('02. constructor harus membuat instance dengan benar', () {
      const model = InfoPerangkatModel(
        appName: 'Another App',
        packageName: 'com.another.app',
        version: '2.0.0',
        buildNumber: '2',
      );

      expect(model.appName, 'Another App');
      expect(model.packageName, 'com.another.app');
      expect(model.version, '2.0.0');
      expect(model.buildNumber, '2');
    });
  });
}
