// path: test/fitur/info_perangkat/service/layanan_info_paket_test.dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wifi/fitur/info_perangkat/model/info_perangkat_model.dart';
import 'package:wifi/fitur/info_perangkat/service/layanan_info_paket.dart';

void main() {
  late LayananInfoPaket layananInfoPaket;
  const channel = MethodChannel('dev.flutter.plugins/package_info');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    layananInfoPaket = LayananInfoPaket();
  });

  tearDown(() {
    // Bersihkan handler setiap kali sebuah test selesai
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('LayananInfoPaket', () {
    const mockAppName = 'Aplikasi Keren';
    const mockPackageName = 'com.contoh.aplikasi';
    const mockVersion = '1.2.3';
    const mockBuildNumber = '42';

    // =========================================================================
    // TEST 1: KITA UJI EXCEPTION TERLEBIH DAHULU
    // Sebelum cache statis internal Dart milik PackageInfo terkunci oleh data sukses.
    // =========================================================================
    test(
      '01. harus mengembalikan null ketika terjadi PlatformException',
      () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          channel,
          (methodCall) async {
            throw PlatformException(
              code: 'ERROR',
              message: 'Gagal mengambil info paket',
            );
          },
        );

        final hasil = await layananInfoPaket.ambilInfoPaket();

        expect(hasil, isNull);
      },
    );

    // =========================================================================
    // TEST 2: BARU KITA UJI SKENARIO SUKSES
    // Menggunakan setMockInitialValues untuk mengunci cache ke state sukses.
    // =========================================================================
    test(
      '02. harus mengembalikan InfoPerangkatModel pada saat pemanggilan berhasil',
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
  });
}