// path: test/fitur/info_perangkat/service/package_info_service_test.dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wifi/fitur/info_perangkat/model/info_perangkat_model.dart';
import 'package:wifi/fitur/info_perangkat/service/package_info_service.dart';

void main() {
  late PackageInfoService packageInfoService;

  // Pastikan binding siap untuk semua tes
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    packageInfoService = PackageInfoService();
  });

  // tearDown akan membersihkan nilai mock setiap kali tes selesai
  tearDown(() {
    // Reset mock values untuk memastikan tes terisolasi
    PackageInfo.setMockInitialValues(
      appName: '',
      packageName: '',
      version: '',
      buildNumber: '',
      buildSignature: '',
    );
    // Membersihkan method channel handler jika ada
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dev.flutter.plugins/package_info'),
      null,
    );
  });

  group('PackageInfoService', () {
    const mockAppName = 'My Awesome App';
    const mockPackageName = 'com.example.app';
    const mockVersion = '1.0.0';
    const mockBuildNumber = '1';

    test('01. harus mengembalikan InfoPerangkatModel saat berhasil', () async {
      // Atur nilai mock untuk kasus sukses
      PackageInfo.setMockInitialValues(
        appName: mockAppName,
        packageName: mockPackageName,
        version: mockVersion,
        buildNumber: mockBuildNumber,
        buildSignature: 'mock_signature',
      );

      final result = await packageInfoService.getPackageInfo();

      // Verifikasi bahwa hasilnya adalah model yang benar dengan data yang benar
      expect(result, isA<InfoPerangkatModel>());
      expect(result?.appName, mockAppName);
      expect(result?.packageName, mockPackageName);
      expect(result?.version, mockVersion);
      expect(result?.buildNumber, mockBuildNumber);
    });

    test('02. harus mengembalikan null saat terjadi exception', () async {
      // Untuk tes exception, kita akan meniru method channel
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('dev.flutter.plugins/package_info'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'getAll') {
            throw PlatformException(
              code: 'ERROR',
              message: 'Gagal mendapatkan info paket',
            );
          }
          return null;
        },
      );

      final result = await packageInfoService.getPackageInfo();

      // Verifikasi hasilnya null karena exception sudah ditangani
      expect(result, isNull);
    });
  });
}
