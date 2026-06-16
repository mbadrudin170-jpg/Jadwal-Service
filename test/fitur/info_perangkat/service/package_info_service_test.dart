
// path: test/fitur/info_perangkat/service/package_info_service_test.dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wifi/fitur/info_perangkat/model/info_perangkat_model.dart';
import 'package:wifi/fitur/info_perangkat/service/package_info_service.dart';

void main() {
  late PackageInfoService packageInfoService;

  setUp(() {
    packageInfoService = PackageInfoService();
  });

  group('PackageInfoService', () {
    const mockPackageInfo = {
      'appName': 'My Awesome App',
      'packageName': 'com.example.app',
      'version': '1.0.0',
      'buildNumber': '1',
    };

    test('01. harus mengembalikan InfoPerangkatModel saat berhasil', () async {
      PackageInfo.setMockInitialValues(
        appName: mockPackageInfo['appName']!,
        packageName: mockPackageInfo['packageName']!,
        version: mockPackageInfo['version']!,
        buildNumber: mockPackageInfo['buildNumber']!,
        buildSignature: '',
      );

      final result = await packageInfoService.getPackageInfo();

      expect(result, isA<InfoPerangkatModel>());
      expect(result?.appName, mockPackageInfo['appName']);
      expect(result?.packageName, mockPackageInfo['packageName']);
      expect(result?.version, mockPackageInfo['version']);
      expect(result?.buildNumber, mockPackageInfo['buildNumber']);
    });

    test('02. harus mengembalikan null saat terjadi exception', () async {
      // Atur MethodChannel untuk melempar exception saat dipanggil
      TestWidgetsFlutterBinding.ensureInitialized();
      const channel = MethodChannel('dev.flutter.plugins/package_info');
      
      // Simpan handler asli
      final originalHandler = channel.getMockMethodCallHandler();

      // Atur handler mock untuk melempar PlatformException
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'getAll') {
          throw PlatformException(code: 'ERROR', message: 'Gagal mendapatkan info paket');
        }
        return null;
      });

      final result = await packageInfoService.getPackageInfo();

      expect(result, isNull);

      // Kembalikan handler asli setelah tes selesai
      channel.setMockMethodCallHandler(originalHandler);
    });
  });
}
