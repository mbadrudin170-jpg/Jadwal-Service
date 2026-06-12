// path: test/fitur/speedtest/provider/uji_kecepatan_provider_test.dart

import 'dart:async';

import 'package:dart_ping/dart_ping.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_test_plus/flutter_speed_test_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/speedtest/provider/ping_provider.dart';
import 'package:wifi/fitur/speedtest/provider/uji_kecepatan_provider.dart';

// Mock classes using mocktail
class MockFlutterInternetSpeedTest extends Mock
    implements FlutterInternetSpeedTest {}

class MockClient extends Mock implements Client {}

class MockTestResult extends Mock implements TestResult {}

void main() {
  // Register fallbacks for any() matcher
  setUpAll(() {
    registerFallbackValue(MockClient());
    registerFallbackValue(TestResult(TestType.download, 0, SpeedUnit.kbps));
    registerFallbackValue(SpeedUnit.kbps);
    registerFallbackValue(TestType.download);
  });

  group('UjiKecepatan Provider Tests with Mocktail', () {
    late MockFlutterInternetSpeedTest mockAlatUji;

    ProviderContainer createContainer({List<Override> overrides = const []}) {
      final container = ProviderContainer(overrides: overrides);
      addTearDown(container.dispose);
      return container;
    }

    final successPingOverride = pingProvider.overrideWith((ref) => Future.value(
          const PingData(response: PingResponse(time: Duration(milliseconds: 25))),
        ));

    setUp(() {
      mockAlatUji = MockFlutterInternetSpeedTest();
    });

    testWidgets('1. Status Awal Provider Harus Benar', (tester) async {
      final container = createContainer();
      final state = container.read(ujiKecepatanProvider);

      expect(state.kecepatanUnduh, 0.0);
      expect(state.kecepatanUnggah, 0.0);
      expect(state.ping, 0);
      expect(state.sedangMenguji, isFalse);
      expect(state.statusPesan, 'Siap melakukan pengujian');
    });

    testWidgets('2. Pengujian Berhasil - Alur Lengkap', (tester) async {
      final container = createContainer(overrides: [successPingOverride]);
      final completer = Completer<void>();

      when(() => mockAlatUji.startTesting(
            onStarted: any(named: 'onStarted'),
            onDefaultServerSelectionInProgress:
                any(named: 'onDefaultServerSelectionInProgress'),
            onDefaultServerSelectionDone:
                any(named: 'onDefaultServerSelectionDone'),
            onProgress: any(named: 'onProgress'),
            onCompleted: any(named: 'onCompleted'),
            onError: any(named: 'onError'),
          )).thenAnswer((invocation) async {
        (invocation.namedArguments[const Symbol('onStarted')] as Function())();
        await tester.pump();
        (invocation.namedArguments[const Symbol('onDefaultServerSelectionInProgress')]
            as Function())();
        await tester.pump();
        (invocation.namedArguments[const Symbol('onDefaultServerSelectionDone')]
            as Function(Client))(Client(isp: 'MyTelkom'));
        await tester.pump();
        (invocation.namedArguments[const Symbol('onProgress')]
            as Function(double, TestResult))(
          50.0,
          TestResult(TestType.download, 12000.0, SpeedUnit.kbps),
        );
        await tester.pump();
        (invocation.namedArguments[const Symbol('onProgress')]
            as Function(double, TestResult))(
          50.0,
          TestResult(TestType.upload, 8000.0, SpeedUnit.kbps),
        );
        await tester.pump();
        (invocation.namedArguments[const Symbol('onCompleted')]
            as Function(TestResult, TestResult))(
          TestResult(TestType.download, 15000.0, SpeedUnit.kbps),
          TestResult(TestType.upload, 10000.0, SpeedUnit.kbps),
        );
        completer.complete();
      });

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Builder(builder: (context) {
              container
                  .read(ujiKecepatanProvider.notifier)
                  .mulaiPengujian(context, alatUjiManual: mockAlatUji);
              return const SizedBox.shrink();
            }),
          ),
        ),
      );

      await completer.future;
      await tester.pumpAndSettle();

      final state = container.read(ujiKecepatanProvider);
      expect(state.sedangMenguji, isFalse);
      expect(state.statusPesan, 'Pengujian selesai');
      expect(state.kecepatanUnduh, 15.0);
      expect(state.kecepatanUnggah, 10.0);
      expect(state.ping, 25);
    });

    testWidgets('3. Penanganan Error saat Pengujian', (tester) async {
      final container = createContainer(overrides: [successPingOverride]);
      final completer = Completer<void>();

      when(() => mockAlatUji.startTesting(
            onStarted: any(named: 'onStarted'),
            onDefaultServerSelectionInProgress: any(named: 'onDefaultServerSelectionInProgress'),
            onDefaultServerSelectionDone: any(named: 'onDefaultServerSelectionDone'),
            onProgress: any(named: 'onProgress'),
            onCompleted: any(named: 'onCompleted'),
            onError: any(named: 'onError'),
      )).thenAnswer((invocation) async {
        (invocation.namedArguments[const Symbol('onError')] as Function(String, String))(
          'Kesalahan Jaringan',
          'Detail Stack Trace',
        );
        completer.complete();
      });
      
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Builder(builder: (context) {
              container
                  .read(ujiKecepatanProvider.notifier)
                  .mulaiPengujian(context, alatUjiManual: mockAlatUji);
              return const SizedBox.shrink();
            }),
          ),
        ),
      );

      await completer.future;
      await tester.pumpAndSettle();

      final state = container.read(ujiKecepatanProvider);
      expect(state.sedangMenguji, isFalse);
      expect(state.statusPesan, 'Gagal melakukan pengujian');
      expect(state.kecepatanUnduh, 0.0);
    });

    testWidgets('4. Penanganan Gagal Mendapatkan Ping', (tester) async {
      final container = createContainer(
        overrides: [
          pingProvider.overrideWith((ref) => throw Exception('Gagal ping')),
        ],
      );
      final completer = Completer<void>();

      when(() => mockAlatUji.startTesting(
            onStarted: any(named: 'onStarted'),
            onDefaultServerSelectionInProgress: any(named: 'onDefaultServerSelectionInProgress'),
            onDefaultServerSelectionDone: any(named: 'onDefaultServerSelectionDone'),
            onProgress: any(named: 'onProgress'),
            onCompleted: any(named: 'onCompleted'),
            onError: any(named: 'onError'),
      )).thenAnswer((invocation) async {
        (invocation.namedArguments[const Symbol('onCompleted')] as Function(TestResult, TestResult))(
          TestResult(TestType.download, 1.0, SpeedUnit.mbps),
          TestResult(TestType.upload, 1.0, SpeedUnit.mbps),
        );
        completer.complete();
      });

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Builder(builder: (context) {
              container
                  .read(ujiKecepatanProvider.notifier)
                  .mulaiPengujian(context, alatUjiManual: mockAlatUji);
              return const SizedBox.shrink();
            }),
          ),
        ),
      );
      
      await completer.future;
      await tester.pumpAndSettle();

      final state = container.read(ujiKecepatanProvider);
      expect(state.ping, -1);
      expect(state.sedangMenguji, isFalse);
    });

    testWidgets('5. Penanganan Exception saat startTesting', (tester) async {
      final container = createContainer(overrides: [successPingOverride]);

      when(() => mockAlatUji.startTesting(
            onStarted: any(named: 'onStarted'),
            onDefaultServerSelectionInProgress: any(named: 'onDefaultServerSelectionInProgress'),
            onDefaultServerSelectionDone: any(named: 'onDefaultServerSelectionDone'),
            onProgress: any(named: 'onProgress'),
            onCompleted: any(named: 'onCompleted'),
            onError: any(named: 'onError'),
          )).thenThrow(Exception('Error fatal'));
      
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Builder(builder: (context) {
               container
                  .read(ujiKecepatanProvider.notifier)
                  .mulaiPengujian(context, alatUjiManual: mockAlatUji);
              return const SizedBox.shrink();
            }),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final state = container.read(ujiKecepatanProvider);
      expect(state.sedangMenguji, isFalse);
      expect(state.statusPesan, 'Gagal melakukan pengujian');
    });
  });
}
