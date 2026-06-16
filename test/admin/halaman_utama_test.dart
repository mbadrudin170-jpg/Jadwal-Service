
// path: test/admin/halaman_utama_test.dart

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/admin/halaman_utama.dart';
import 'package:wifi/fitur/pelanggan_aktif/page/pelanggan_aktif_page.dart';
import 'package:wifi/shared/data/services/layanan_cek_sinkronisasi.dart';
import 'package:wifi/shared/services/arsipkan_langganan_kadaluarsa_service.dart';
import 'package:workmanager/workmanager.dart';

import 'halaman_utama_test.mocks.dart';

// Mocks
@GenerateMocks([
  LayananCekSinkronisasi,
  ArsipLanggananKadaluarsaService,
  Workmanager,
  Connectivity
])
void main() {
  late MockLayananCekSinkronisasi mockSyncService;
  late MockArsipLanggananKadaluarsaService mockExpiredService;
  late MockWorkmanager mockWorkmanager;
  late MockConnectivity mockConnectivity;
  late StreamController<List<ConnectivityResult>> connectivityStreamController;

  // We need to create a dummy main to avoid errors
  // This is because FlutterNativeSplash.remove() is called in initState
  void main() => runApp(const MaterialApp(home: HalamanUtama()));

  setUpAll(() {
    // This is required to mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    // This is required to mock FlutterNativeSplash
    TestWidgetsFlutterBinding.ensureInitialized();
    final originalMethod = FlutterNativeSplash.remove;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter_native_splash'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'remove') {
          return null;
        }
        return null;
      },
    );
    addTearDown(() {
      // restore original
    });
  });

  setUp(() {
    mockSyncService = MockLayananCekSinkronisasi();
    mockExpiredService = MockArsipLanggananKadaluarsaService();
    mockWorkmanager = MockWorkmanager();
    mockConnectivity = MockConnectivity();

    connectivityStreamController =
        StreamController<List<ConnectivityResult>>.broadcast();

    when(mockSyncService.jalankanCekSinkronisasi()).thenAnswer((_) async {});
    when(mockExpiredService.prosesArsipLanggananKadaluarsa())
        .thenAnswer((_) async {});
    when(mockWorkmanager.registerPeriodicTask(
      any,
      any,
      frequency: anyNamed('frequency'),
      constraints: anyNamed('constraints'),
    )).thenAnswer((_) async {});
    when(mockConnectivity.onConnectivityChanged)
        .thenAnswer((_) => connectivityStreamController.stream);
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
        // We can't easily mock the connectivity provider as it creates its own instance.
        // Instead, we inject the mock via stream listening in initState.
      ],
      child: MaterialApp(
        home: HalamanUtama(isOffline: isOffline),
      ),
    );
  }

  group('01. HalamanUtama Initialization and UI', () {
    testWidgets('01. harus menampilkan UI dengan benar dan tab pertama aktif',
        (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.byType(HalamanUtama), findsOneWidget);
      expect(find.byType(PelangganAktifPage), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // Verify first tab is selected
      final bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNavBar.currentIndex, 0);
    });

    testWidgets('02. harus menampilkan toast saat isOffline true',
        (tester) async {
      await tester.pumpWidget(createWidget(isOffline: true));
      await tester.pump(); // for addPostFrameCallback
      await tester.pump(); // for the toast

      expect(find.text('Anda dalam mode offline. Data mungkin tidak terbaru.'),
          findsOneWidget);

      await tester.pumpAndSettle(const Duration(seconds: 4)); // Clear toast
    });
  });

  group('02. Logic and Service Calls', () {
    testWidgets('01. harus memanggil service yang diperlukan saat initState',
        (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      verify(mockExpiredService.prosesArsipLanggananKadaluarsa()).called(1);
      verify(mockSyncService.jalankanCekSinkronisasi()).called(1);
      verify(mockWorkmanager.registerPeriodicTask(
        '1',
        syncTaskName,
        frequency: const Duration(minutes: 15),
        constraints: anyNamed('constraints'),
      )).called(1);
    });

    testWidgets('02. harus memproses notifikasi awal jika ada payload',
        (tester) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('initial_notification_payload', 'test_payload');

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Dibuka dari notifikasi: test_payload'), findsOneWidget);

      // Check that payload is removed
      expect(prefs.getString('initial_notification_payload'), isNull);
      
      await tester.pumpAndSettle(const Duration(seconds: 4)); // Clear toast
    });
    
    testWidgets('03. harus menjalankan sinkronisasi saat koneksi kembali online',
        (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Initial sync
      verify(mockSyncService.jalankanCekSinkronisasi()).called(1);

      // Simulate connectivity change to online
      connectivityStreamController.add([ConnectivityResult.wifi]);
      await tester.pump();

      // Verify sync is called again
      verify(mockSyncService.jalankanCekSinkronisasi()).called(1);
    });

    testWidgets('04. harus menjalankan sinkronisasi saat aplikasi resumed',
        (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

       // Initial sync
      verify(mockSyncService.jalankanCekSinkronisasi()).called(1);

      // Simulate app lifecycle change
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();

      // Verify sync is called again
      verify(mockSyncService.jalankanCekSinkronisasi()).called(1);
    });

  });

  group('03. Navigasi Tab', () {
    testWidgets('01. harus berpindah tab saat item di tap', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Tap on 'Dompet' tab
      await tester.tap(find.text('Dompet'));
      await tester.pumpAndSettle();

      // Verify second tab is selected
      final bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNavBar.currentIndex, 1);
      // expect(find.byType(DompetPage), findsOneWidget);

      // Tap on 'Lainnya' tab
      await tester.tap(find.text('Lainnya'));
      await tester.pumpAndSettle();
      
      final bottomNavBar2 = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNavBar2.currentIndex, 5);
      // expect(find.byType(LainnyaPage), findsOneWidget);
    });
  });
}
