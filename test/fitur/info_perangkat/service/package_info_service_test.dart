// path: test/fitur/info_perangkat/service/package_info_service_test.dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wifi/fitur/info_perangkat/model/info_perangkat_model.dart';
import 'package:wifi/fitur/info_perangkat/service/package_info_service.dart';

void main() {
  late LayananInfoPaket packageInfoService;

  // Inisialisasi binding sekali untuk semua tes
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    packageInfoService = LayananInfoPaket();
    // Membersihkan handler sebelum setiap tes untuk memastikan isolasi
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

    // TES 1: Skenario Gagal (dijalankan pertama)
    // Tes ini harus berjalan sebelum `setMockInitialValues` pernah dipanggil.
    test('02. harus mengembalikan null saat terjadi exception', () async {
      // Siapkan method channel untuk melempar exception.
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

      final result = await packageInfoService.ambilInfoPaket();

      // Verifikasi hasilnya null karena exception ditangani.
      expect(result, isNull);
    });

    // TES 2: Skenario Sukses (dijalankan setelah tes gagal)
    // Tes ini menggunakan `setMockInitialValues` yang akan menimpa method channel.
    test('01. harus mengembalikan InfoPerangkatModel saat berhasil', () async {
      // Atur nilai mock untuk kasus sukses.
      PackageInfo.setMockInitialValues(
        appName: mockAppName,
        packageName: mockPackageName,
        version: mockVersion,
        buildNumber: mockBuildNumber,
        buildSignature: 'mock_signature',
      );

      final result = await packageInfoService.ambilInfoPaket();

      // Verifikasi bahwa hasilnya adalah model yang benar dengan data yang benar.
      expect(result, isA<InfoPerangkatModel>());
      expect(result?.appName, mockAppName);
      expect(result?.packageName, mockPackageName);
      expect(result?.version, mockVersion);
      expect(result?.buildNumber, mockBuildNumber);
    });
  });
}
