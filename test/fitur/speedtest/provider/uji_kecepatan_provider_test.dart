
// path: test/fitur/speedtest/provider/uji_kecepatan_provider_test.dart

import 'package:dart_ping/dart_ping.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_test_plus/flutter_speed_test_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/fitur/speedtest/provider/ping_provider.dart';
import 'package:wifi/fitur/speedtest/provider/uji_kecepatan_provider.dart';

import 'uji_kecepatan_provider_test.mocks.dart';

// Kelas mock untuk TestReport karena tidak dapat di-instantiate secara langsung
class MockTestReport implements TestReport {
  @override
  final TestType testType;
  @override
  final double transferRate;
  @override
  final SpeedUnit unit;
  @override
  final int durationInMillis;

  MockTestReport({
    required this.testType,
    required this.transferRate,
    required this.unit,
    required this.durationInMillis,
  });
}

@GenerateMocks([FlutterInternetSpeedTest, BuildContext])
void main() {
  late MockFlutterInternetSpeedTest mockAlatUji;
  late MockBuildContext mockKonteks;
  late ProviderContainer container;

  // Data palsu untuk hasil tes menggunakan MockTestReport
  final unduhLaporan = MockTestReport(
    testType: TestType.download,
    transferRate: 50.0, // Mbps
    unit: SpeedUnit.mbps,
    durationInMillis: 1000,
  );
  final unggahLaporan = MockTestReport(
    testType: TestType.upload,
    transferRate: 20.0, // Mbps
    unit: SpeedUnit.mbps,
    durationInMillis: 1000,
  );

  setUp(() {
    mockAlatUji = MockFlutterInternetSpeedTest();
    mockKonteks = MockBuildContext();
    container = ProviderContainer();

    // Pastikan konteks mounted secara default
    when(mockKonteks.mounted).thenReturn(true);
  });

  tearDown(() {
    container.dispose();
  });

  test('Uji Coba Provider Kecepatan 01: Status awal harus benar', () {
    final state = container.read(ujiKecepatanProvider);

    expect(state.kecepatanUnduh, 0.0);
    expect(state.kecepatanUnggah, 0.0);
    expect(state.ping, 0);
    expect(state.sedangMenguji, false);
    expect(state.statusPesan, 'Siap melakukan pengujian');
  });

  test(
      'Uji Coba Provider Kecepatan 02: `mulaiPengujian` berhasil menyelesaikan semua langkah',
      () async {
    // Atur container untuk menimpa pingProvider
    container = ProviderContainer(
      overrides: [
        pingProvider.overrideWith(
          (ref) => Future.value(
            PingData(
              response: PingResponse(
                time: const Duration(milliseconds: 30),
              ),
            ),
          ),
        ),
      ],
    );

    // Atur mock untuk `startTesting`
    when(mockAlatUji.startTesting(
      onStarted: anyNamed('onStarted'),
      onDefaultServerSelectionInProgress:
          anyNamed('onDefaultServerSelectionInProgress'),
      onDefaultServerSelectionDone: anyNamed('onDefaultServerSelectionDone'),
      onProgress: anyNamed('onProgress'),
      onCompleted: anyNamed('onCompleted'),
      onError: anyNamed('onError'),
    )).thenAnswer((realInvocation) async {
      // Panggil callback secara berurutan
      final onStarted = realInvocation.namedArguments[const Symbol('onStarted')]
          as Function;
      final onProgress =
          realInvocation.namedArguments[const Symbol('onProgress')]
              as Function(double, TestReport);
      final onCompleted =
          realInvocation.namedArguments[const Symbol('onCompleted')]
              as Function(TestReport, TestReport);

      onStarted();
      onProgress(50.0, unduhLaporan);
      onProgress(100.0, unggahLaporan);
      onCompleted(unduhLaporan, unggahLaporan);
    });

    final notifier = container.read(ujiKecepatanProvider.notifier);

    // Lacak perubahan state
    final states = <UjiKecepatanState>[];
    container.listen(ujiKecepatanProvider, (_, next) => states.add(next));

    await notifier.mulaiPengujian(mockKonteks, alatUjiManual: mockAlatUji);

    // Verifikasi perubahan state
    expect(states.length, greaterThan(3));

    // Status awal
    expect(states[0].sedangMenguji, true);
    expect(states[0].statusPesan, 'Menghubungkan ke server...');

    // Setelah ping
    expect(states[1].ping, 30);
    expect(states[1].statusPesan, contains('Mengukur ping'));

    // Status akhir
    final stateAkhir = container.read(ujiKecepatanProvider);
    expect(stateAkhir.sedangMenguji, false);
    expect(stateAkhir.statusPesan, 'Pengujian selesai');
    expect(stateAkhir.kecepatanUnduh, 50.0);
    expect(stateAkhir.kecepatanUnggah, 20.0);
  });

  test(
      'Uji Coba Provider Kecepatan 03: `mulaiPengujian` gagal saat mengukur ping',
      () async {
    // Atur container untuk menimpa pingProvider agar gagal
    container = ProviderContainer(
      overrides: [
        pingProvider.overrideWith(
          (ref) => Future.error('Gagal ping'),
        ),
      ],
    );

    // Atur mock agar tidak melakukan apa-apa karena ping gagal
    when(mockAlatUji.startTesting(
      onStarted: anyNamed('onStarted'),
      onDefaultServerSelectionInProgress:
          anyNamed('onDefaultServerSelectionInProgress'),
      onDefaultServerSelectionDone: anyNamed('onDefaultServerSelectionDone'),
      onProgress: anyNamed('onProgress'),
      onCompleted: anyNamed('onCompleted'),
      onError: anyNamed('onError'),
    )).thenAnswer((_) async {});

    final notifier = container.read(ujiKecepatanProvider.notifier);
    await notifier.mulaiPengujian(mockKonteks, alatUjiManual: mockAlatUji);

    final state = container.read(ujiKecepatanProvider);
    expect(state.ping, -1); // Menandakan error
    // Verifikasi bahwa pengujian tetap berjalan meskipun ping gagal
    verify(mockAlatUji.startTesting(
            onStarted: anyNamed('onStarted'),
            onDefaultServerSelectionInProgress:
                anyNamed('onDefaultServerSelectionInProgress'),
            onDefaultServerSelectionDone:
                anyNamed('onDefaultServerSelectionDone'),
            onProgress: anyNamed('onProgress'),
            onCompleted: anyNamed('onCompleted'),
            onError: anyNamed('onError')))
        .called(1);
  });

  test(
      'Uji Coba Provider Kecepatan 04: `mulaiPengujian` gagal karena `startTesting` melempar exception',
      () async {
    final exception = Exception('Kesalahan fatal');
    when(mockAlatUji.startTesting(
            onStarted: anyNamed('onStarted'),
            onDefaultServerSelectionInProgress:
                anyNamed('onDefaultServerSelectionInProgress'),
            onDefaultServerSelectionDone:
                anyNamed('onDefaultServerSelectionDone'),
            onProgress: anyNamed('onProgress'),
            onCompleted: anyNamed('onCompleted'),
            onError: anyNamed('onError')))
        .thenThrow(exception);

    final notifier = container.read(ujiKecepatanProvider.notifier);
    await notifier.mulaiPengujian(mockKonteks, alatUjiManual: mockAlatUji);

    final state = container.read(ujiKecepatanProvider);
    expect(state.sedangMenguji, false);
    expect(state.statusPesan, 'Gagal melakukan pengujian');
  });

  test(
      'Uji Coba Provider Kecepatan 05: `mulaiPengujian` gagal karena callback `onError` dipanggil',
      () async {
    const errorMessage = 'Server tidak ditemukan';
    const errorCode = '404';

    when(mockAlatUji.startTesting(
      onStarted: anyNamed('onStarted'),
      onDefaultServerSelectionInProgress:
          anyNamed('onDefaultServerSelectionInProgress'),
      onDefaultServerSelectionDone: anyNamed('onDefaultServerSelectionDone'),
      onProgress: anyNamed('onProgress'),
      onCompleted: anyNamed('onCompleted'),
      onError: anyNamed('onError'),
    )).thenAnswer((realInvocation) async {
      final onError = realInvocation.namedArguments[const Symbol('onError')]
          as Function(String, String);
      onError(errorMessage, errorCode);
    });

    final notifier = container.read(ujiKecepatanProvider.notifier);
    await notifier.mulaiPengujian(mockKonteks, alatUjiManual: mockAlatUji);

    final state = container.read(ujiKecepatanProvider);
    expect(state.sedangMenguji, false);
    expect(state.statusPesan, 'Gagal melakukan pengujian');
  });

  test(
      'Uji Coba Provider Kecepatan 06: `onProgress` memperbarui state unduh dan unggah dengan benar',
      () async {
    final unduhProgress = MockTestReport(
        testType: TestType.download,
        transferRate: 45.5,
        unit: SpeedUnit.mbps,
        durationInMillis: 500);
    final unggahProgress = MockTestReport(
        testType: TestType.upload,
        transferRate: 18.2,
        unit: SpeedUnit.mbps,
        durationInMillis: 500);

    when(mockAlatUji.startTesting(
            onStarted: anyNamed('onStarted'),
            onDefaultServerSelectionInProgress:
                anyNamed('onDefaultServerSelectionInProgress'),
            onDefaultServerSelectionDone:
                anyNamed('onDefaultServerSelectionDone'),
            onProgress: anyNamed('onProgress'),
            onCompleted: anyNamed('onCompleted'),
            onError: anyNamed('onError'))).thenAnswer((realInvocation) async {
      final onProgress =
          realInvocation.namedArguments[const Symbol('onProgress')]
              as Function(double, TestReport);
      
      // Simulasikan progress unduh
      onProgress(50.0, unduhProgress);
      // Baca state setelah progress unduh
      var state = container.read(ujiKecepatanProvider);
      expect(state.kecepatanUnduh, 45.5);
      expect(state.statusPesan, contains('Menguji unduh'));

      // Simulasikan progress unggah
      onProgress(50.0, unggahProgress);
      // Baca state setelah progress unggah
      state = container.read(ujiKecepatanProvider);
      expect(state.kecepatanUnggah, 18.2);
      expect(state.statusPesan, contains('Menguji unggah'));
    });

    final notifier = container.read(ujiKecepatanProvider.notifier);
    await notifier.mulaiPengujian(mockKonteks, alatUjiManual: mockAlatUji);
  });
}
