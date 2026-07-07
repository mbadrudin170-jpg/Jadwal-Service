// path: test/admin/halaman_utama_test.dart

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wifi/admin/halaman_utama.dart';
import 'package:wifi/fitur/background/layanan_latar_belakang.dart';
import 'package:wifi/fitur/pelanggan_aktif/page/pelanggan_aktif_page.dart';
import 'package:wifi/fitur/sinkronisasi/layanan_cek_sinkronisasi.dart';
import 'package:wifi/shared/providers/shared_providers.dart';
import 'package:wifi/shared/services/arsipkan_langganan_kadaluarsa_service.dart';
import 'package:workmanager/workmanager.dart';

import 'halaman_utama_test.mocks.dart';

@GenerateMocks([
  LayananCekSinkronisasi,
  ArsipLanggananKadaluarsaService,
  Workmanager,
  Connectivity,
])
void main() {
  // Initialize FFI for sqflite
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  late MockLayananCekSinkronisasi mockSyncService;
  late MockArsipLanggananKadaluarsaService mockExpiredService;
  late MockWorkmanager mockWorkmanager;
  late MockConnectivity mockConnectivity;
  late StreamController<List<ConnectivityResult>> connectivityStreamController;

  setUp(() {
    mockSyncService = MockLayananCekSinkronisasi();
    mockExpiredService = MockArsipLanggananKadaluarsaService();
    mockWorkmanager = MockWorkmanager();
    mockConnectivity = MockConnectivity();
    connectivityStreamController =
        StreamController<List<ConnectivityResult>>.broadcast();

    // Default stubs
    when(mockSyncService.jalankanCekSinkronisasi()).thenAnswer((_) async {});
    when(mockExpiredService.prosesArsipLanggananKadaluarsa())
        .thenAnswer((_) async {});
    when(
      mockWorkmanager.registerPeriodicTask(
        any,
        any,
        frequency: anyNamed('frequency'),
        constraints: anyNamed('constraints'),
      ),
    ).thenAnswer((_) async {});

    // Stub for connectivity
    when(mockConnectivity.onConnectivityChanged)
        .thenAnswer((_) => connectivityStreamController.stream);
    when(mockConnectivity.checkConnectivity())
        .thenAnswer((_) async => [ConnectivityResult.wifi]);
  });

  tearDown(() {
    connectivityStreamController.close();
  });

  Widget createWidget({bool isOffline = false}) {
    return ProviderScope(
      overrides: [
        layananCekSinkronisasiProvider.overrideWithValue(mockSyncService),
        arsipLanggananKadaluarsaServiceProvider
            .overrideWithValue(mockExpiredService),
        workmanagerProvider.overrideWithValue(mockWorkmanager),
      ],
      child: MaterialApp(
        home: HalamanUtama(isOffline: isOffline),
      ),
    );
  }

  group('01. HalamanUtama Initialization and UI', () {
    testWidgets('01. harus menampilkan UI dengan benar dan tab pertama aktif', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.byType(HalamanUtama), findsOneWidget);
      expect(find.byType(PelangganAktifPage), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      final bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNavBar.currentIndex, 0);
    });
  });

  group('02. Logic and Service Calls', () {
    testWidgets('01. harus memanggil service yang diperlukan saat initState', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      verify(mockExpiredService.prosesArsipLanggananKadaluarsa()).called(1);

      // Called once in _initAwal -> _handleConnectivityChange
      verify(mockSyncService.jalankanCekSinkronisasi()).called(1);

      verify(
        mockWorkmanager.registerPeriodicTask(
          '1',
          namaTugasSinkronisasi,
          frequency: const Duration(minutes: 15),
          constraints: anyNamed('constraints'),
        ),
      ).called(1);
    });

    testWidgets(
      '02. harus menjalankan sinkronisasi saat koneksi kembali online',
      (tester) async {
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.none]);

        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        // Should not be called initially because it is offline.
        verifyNever(mockSyncService.jalankanCekSinkronisasi());

        // Simulate coming online
        connectivityStreamController.add([ConnectivityResult.wifi]);
        await tester.pump();

        // Now it should be called
        verify(mockSyncService.jalankanCekSinkronisasi()).called(1);
      },
    );

    testWidgets('03. harus menjalankan sinkronisasi saat aplikasi resumed', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Initial sync (once from _initAwal)
      verify(mockSyncService.jalankanCekSinkronisasi()).called(1);

      // Simulate app lifecycle change to resumed
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();

      // Verify sync is called again (total 2 times)
      verify(mockSyncService.jalankanCekSinkronisasi()).called(2);
    });
  });

  group('03. Navigasi Tab', () {
    testWidgets('01. harus berpindah tab saat item di tap', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Tap on 'Dompet' tab
      await tester.tap(find.text('Dompet'));
      await tester.pumpAndSettle();

      final bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNavBar.currentIndex, 1);

      // Tap on 'Lainnya' tab
      await tester.tap(find.text('Lainnya'));
      await tester.pumpAndSettle();

      final bottomNavBar2 = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNavBar2.currentIndex, 5);
    });
  });
}
