// path: test/fitur/info_perangkat/service/layanan_info_paket_test.dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wifi/fitur/info_perangkat/model/info_perangkat_model.dart';
import 'package:wifi/fitur/info_perangkat/service/layanan_info_paket.dart';

void main() {
  late LayananInfoPaket layananInfoPaket;

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    layananInfoPaket = LayananInfoPaket();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('dev.flutter.plugins/package_info'),
          null,
        );
  });

  group('LayananInfoPaket', () {
    const mockAppName = 'Aplikasi Keren';
    const mockPackageName = 'com.contoh.aplikasi';
    const mockVersion = '1.2.3';
    const mockBuildNumber = '42';

    test(
      '01. harus mengembalikan InfoPerangkatModel pada saat pemanggilan berhasil',
      () async {
        PackageInfo.setMockInitialValues(
          appName: mockAppName,
          packageName: mockPackageName,
          version: mockVersion,
          buildNumber: mockBuildNumber,
          buildSignature: 'mock_signature',
        );

        final hasil = await layananInfoPaket.ambilInfoPaket();

        expect(hasil, isA<InfoPerangkatModel>());
        expect(hasil?.namaApk, mockAppName);
        expect(hasil?.namaPaket, mockPackageName);
        expect(hasil?.versi, mockVersion);
        expect(hasil?.nomorBuild, mockBuildNumber);
      },
    );

    test(
      '02. harus mengembalikan null ketika terjadi PlatformException',
      () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              const MethodChannel('dev.flutter.plugins/package_info'),
              (MethodCall methodCall) async {
                if (methodCall.method == 'getAll') {
                  throw PlatformException(
                    code: 'ERROR',
                    message: 'Gagal mengambil info paket',
                  );
                }
                return null;
              },
            );

        final hasil = await layananInfoPaket.ambilInfoPaket();

        expect(hasil, isNull);
      },
    );
  });
}
