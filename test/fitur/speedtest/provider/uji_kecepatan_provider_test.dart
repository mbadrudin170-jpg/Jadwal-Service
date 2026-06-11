// path: test/fitur/speedtest/provider/uji_kecepatan_provider_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_test_plus/flutter_speed_test_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/fitur/speedtest/provider/uji_kecepatan_provider.dart';

/// Mocking untuk FlutterInternetSpeedTest.
class AlatUjiMock extends Mock implements FlutterInternetSpeedTest {}

void main() {
  // Memastikan binding Flutter diinisialisasi untuk testWidgets
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer wadah;
  late AlatUjiMock mockAlatUji;

  setUpAll(() {
    // Mendaftarkan nilai fallback untuk mocktail enum.
    registerFallbackValue(TestType.download);
    registerFallbackValue(SpeedUnit.kbps);
  });

  setUp(() {
    wadah = ProviderContainer();
    mockAlatUji = AlatUjiMock();
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

    testWidgets(
        '2. Memulai pengujian harus mengubah status menjadi sedang menguji dan mereset nilai',
        (tester) async {
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

      final sub = wadah.listen(ujiKecepatanProvider, (_, __) {});
      addTearDown(sub.close);

      late BuildContext testContext;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: wadah,
          child: MaterialApp(
            home: Builder(builder: (context) {
              testContext = context;
              return const SizedBox.shrink();
            }),
          ),
        ),
      );

      await wadah.read(ujiKecepatanProvider.notifier).mulaiPengujian(
            testContext,
            alatUjiManual: mockAlatUji,
          );
      await tester.pump();

      final keadaan = sub.read(); // Baca dari subscription
      expect(keadaan.sedangMenguji, true);
      expect(keadaan.statusPesan, 'Menghubungkan ke server...');
    });

    testWidgets(
        '3. Callback onProgress harus memperbarui kecepatan unduh secara real-time',
        (tester) async {
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

        onProgress(75.0, TestResult(TestType.download, 25.5, SpeedUnit.mbps));
      });

      final sub = wadah.listen(ujiKecepatanProvider, (_, __) {});
      addTearDown(sub.close);

      late BuildContext testContext;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: wadah,
          child: MaterialApp(
            home: Builder(builder: (context) {
              testContext = context;
              return const SizedBox.shrink();
            }),
          ),
        ),
      );

      await wadah.read(ujiKecepatanProvider.notifier).mulaiPengujian(
            testContext,
            alatUjiManual: mockAlatUji,
          );
      await tester.pump();

      final keadaan = sub.read(); // Baca dari subscription
      expect(keadaan.kecepatanUnduh, 25.5);
      expect(keadaan.statusPesan, 'Menguji unduh: 75%');
    });

    testWidgets(
        '4. Callback onCompleted harus menghentikan status menguji dan menyimpan hasil akhir Mbps',
        (tester) async {
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

      final sub = wadah.listen(ujiKecepatanProvider, (_, __) {});
      addTearDown(sub.close);

      late BuildContext testContext;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: wadah,
          child: MaterialApp(
            home: Builder(builder: (context) {
              testContext = context;
              return const SizedBox.shrink();
            }),
          ),
        ),
      );

      await wadah.read(ujiKecepatanProvider.notifier).mulaiPengujian(
            testContext,
            alatUjiManual: mockAlatUji,
          );
      await tester.pumpAndSettle();

      // Selesaikan timer dari Toast
      await tester.pump(const Duration(seconds: 3));

      final keadaan = sub.read(); // Baca dari subscription
      expect(keadaan.kecepatanUnduh, 120.0);
      expect(keadaan.kecepatanUnggah, 60.0);
      expect(keadaan.sedangMenguji, false);
      expect(keadaan.statusPesan, 'Pengujian selesai');
    });

    testWidgets(
        '5. Callback onError harus menghentikan pengujian dan mengubah pesan status menjadi gagal',
        (tester) async {
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

      final sub = wadah.listen(ujiKecepatanProvider, (_, __) {});
      addTearDown(sub.close);

      late BuildContext testContext;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: wadah,
          child: MaterialApp(
            home: Builder(builder: (context) {
              testContext = context;
              return const SizedBox.shrink();
            }),
          ),
        ),
      );

      await wadah.read(ujiKecepatanProvider.notifier).mulaiPengujian(
            testContext,
            alatUjiManual: mockAlatUji,
          );
      await tester.pumpAndSettle();

      // Selesaikan timer dari Toast
      await tester.pump(const Duration(seconds: 3));

      final keadaan = sub.read(); // Baca dari subscription
      expect(keadaan.sedangMenguji, false);
      expect(keadaan.statusPesan, 'Gagal melakukan pengujian');
    });
  });
}
