// path: test/fitur/speedtest/provider/uji_kecepatan_provider_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_test_plus/flutter_speed_test_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/fitur/speedtest/provider/uji_kecepatan_provider.dart';

/// Mocking untuk BuildContext.
class KonteksMock extends Mock implements BuildContext {}

/// Mocking untuk FlutterInternetSpeedTest.
class AlatUjiMock extends Mock implements FlutterInternetSpeedTest {}

void main() {
  late ProviderContainer wadah;
  late KonteksMock mockKonteks;
  late AlatUjiMock mockAlatUji;

  setUpAll(() {
    // Mendaftarkan nilai fallback untuk mocktail enum.
    registerFallbackValue(TestType.download);
    registerFallbackValue(SpeedUnit.kbps);
  });

  setUp(() {
    wadah = ProviderContainer();
    mockKonteks = KonteksMock();
    mockAlatUji = AlatUjiMock();

    // Mengatur agar context.mounted selalu mengembalikan true.
    when(() => mockKonteks.mounted).thenReturn(true);
  });

  tearDown(() {
    wadah.dispose();
  });

  group('UjiKecepatanProvider - Unit Test', () {
    test('1. Inisialisasi awal state harus memiliki nilai default yang benar',
        () {
      final keadaan = wadah.read(ujiKecepatanProvider);

      expect(keadaan.kecepatanUnduh, 0.0);
      expect(keadaan.kecepatanUnggah, 0.0);
      expect(keadaan.sedangMenguji, false);
      expect(keadaan.statusPesan, 'Siap melakukan pengujian');
    });

    test(
        '2. Memulai pengujian harus mengubah status menjadi sedang menguji dan mereset nilai',
        () {
      when(() => mockAlatUji.startTesting(
            onStarted: any(named: 'onStarted'),
            onCompleted: any(named: 'onCompleted'),
            onError: any(named: 'onError'),
            onProgress: any(named: 'onProgress'),
            onDefaultServerSelectionDone:
                any(named: 'onDefaultServerSelectionDone'),
            onDefaultServerSelectionInProgress:
                any(named: 'onDefaultServerSelectionInProgress'),
          )).thenAnswer((_) async {});

      // Jalankan fungsi tanpa menunggu (karena kita cek state awal transisi).
      wadah.read(ujiKecepatanProvider.notifier).mulaiPengujian(
            mockKonteks,
            alatUjiManual: mockAlatUji,
          );

      final keadaan = wadah.read(ujiKecepatanProvider);
      expect(keadaan.sedangMenguji, true);
      expect(keadaan.statusPesan, 'Menghubungkan ke server...');
    });

    test(
        '3. Callback onProgress harus memperbarui kecepatan unduh secara real-time',
        () async {
      when(() => mockAlatUji.startTesting(
            onStarted: any(named: 'onStarted'),
            onCompleted: any(named: 'onCompleted'),
            onError: any(named: 'onError'),
            onProgress: any(named: 'onProgress'),
            onDefaultServerSelectionDone:
                any(named: 'onDefaultServerSelectionDone'),
            onDefaultServerSelectionInProgress:
                any(named: 'onDefaultServerSelectionInProgress'),
          )).thenAnswer((panggilan) async {
        final onProgress = panggilan.namedArguments[#onProgress] as void
            Function(double, TestResult);

        // Simulasikan progress download 75% dengan kecepatan 25.5 Mbps.
        onProgress(75.0, TestResult(TestType.download, 25.5, SpeedUnit.mbps));
      });

      await wadah.read(ujiKecepatanProvider.notifier).mulaiPengujian(
            mockKonteks,
            alatUjiManual: mockAlatUji,
          );

      final keadaan = wadah.read(ujiKecepatanProvider);
      expect(keadaan.kecepatanUnduh, 25.5);
      expect(keadaan.statusPesan, 'Menguji unduh: 75%');
    });

    test(
        '4. Callback onCompleted harus menghentikan status menguji dan menyimpan hasil akhir Mbps',
        () async {
      when(() => mockAlatUji.startTesting(
            onStarted: any(named: 'onStarted'),
            onCompleted: any(named: 'onCompleted'),
            onError: any(named: 'onError'),
            onProgress: any(named: 'onProgress'),
            onDefaultServerSelectionDone:
                any(named: 'onDefaultServerSelectionDone'),
            onDefaultServerSelectionInProgress:
                any(named: 'onDefaultServerSelectionInProgress'),
          )).thenAnswer((panggilan) async {
        final onCompleted = panggilan.namedArguments[#onCompleted] as void
            Function(TestResult, TestResult);

        onCompleted(
          TestResult(TestType.download, 120.0, SpeedUnit.mbps),
          TestResult(TestType.upload, 60.0, SpeedUnit.mbps),
        );
      });

      await wadah.read(ujiKecepatanProvider.notifier).mulaiPengujian(
            mockKonteks,
            alatUjiManual: mockAlatUji,
          );

      final keadaan = wadah.read(ujiKecepatanProvider);
      expect(keadaan.kecepatanUnduh, 120.0);
      expect(keadaan.kecepatanUnggah, 60.0);
      expect(keadaan.sedangMenguji, false);
      expect(keadaan.statusPesan, 'Pengujian selesai');
    });

    test(
        '5. Callback onError harus menghentikan pengujian dan mengubah pesan status menjadi gagal',
        () async {
      when(() => mockAlatUji.startTesting(
            onStarted: any(named: 'onStarted'),
            onCompleted: any(named: 'onCompleted'),
            onError: any(named: 'onError'),
            onProgress: any(named: 'onProgress'),
            onDefaultServerSelectionDone:
                any(named: 'onDefaultServerSelectionDone'),
            onDefaultServerSelectionInProgress:
                any(named: 'onDefaultServerSelectionInProgress'),
          )).thenAnswer((panggilan) async {
        final onError =
            panggilan.namedArguments[#onError] as void Function(String, String);
        onError('Koneksi Terputus', 'CONN_LOST');
      });

      await wadah.read(ujiKecepatanProvider.notifier).mulaiPengujian(
            mockKonteks,
            alatUjiManual: mockAlatUji,
          );

      final keadaan = wadah.read(ujiKecepatanProvider);
      expect(keadaan.sedangMenguji, false);
      expect(keadaan.statusPesan, 'Gagal melakukan pengujian');
    });
  });
}
