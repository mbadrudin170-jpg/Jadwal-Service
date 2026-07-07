// path: test/admin/halaman_utama_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:wifi/admin/halaman_utama.dart';
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
  late MockLayananCekSinkronisasi mockSyncService;
  late MockArsipLanggananKadaluarsaService mockExpiredService;
  late MockWorkmanager mockWorkmanager;
  late MockConnectivity mockConnectivity;

  setUp(() {
    mockSyncService = MockLayananCekSinkronisasi();
    mockExpiredService = MockArsipLanggananKadaluarsaService();
    mockWorkmanager = MockWorkmanager();
    mockConnectivity = MockConnectivity();

    // Setup default mocks
    when(mockSyncService.jalankanCekSinkronisasi())
        .thenAnswer((_) async {});
    when(mockExpiredService.prosesArsipLanggananKadaluarsa())
        .thenAnswer((_) async {});
    when(mockWorkmanager.registerPeriodicTask(
      any,
      any,
      frequency: anyNamed('frequency'),
      constraints: anyNamed('constraints'),
    )).thenAnswer((_) async {});
    when(mockConnectivity.checkConnectivity())
        .thenAnswer((_) async => [ConnectivityResult.wifi]);
  });

  // Helper untuk membuat test widget dengan ProviderScope
  Widget buildTestWidget({
    bool isOffline = false,
    MockLayananCekSinkronisasi? syncService,
    MockArsipLanggananKadaluarsaService? expiredService,
    MockWorkmanager? workmanager,
    MockConnectivity? connectivity,
  }) {
    return ProviderScope(
      overrides: [
        layananCekSinkronisasiProvider.overrideWithValue(
          syncService ?? mockSyncService,
        ),
        arsipLanggananKadaluarsaServiceProvider.overrideWithValue(
          expiredService ?? mockExpiredService,
        ),
        workmanagerProvider.overrideWithValue(
          workmanager ?? mockWorkmanager,
        ),
        // Connectivity tidak punya provider, jadi kita mock via dependency injection
      ],
      child: MaterialApp(
        home: HalamanUtama(
          isOffline: isOffline,
        ),
      ),
    );
  }

  group('HalamanUtama Initialization and UI', () {
    testWidgets(
      '01. harus menampilkan UI dengan benar dan tab pertama aktif',
      (tester) async {
        // PERBAIKAN: Bungkus dengan ProviderScope
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: HalamanUtama(
                isOffline: false,
              ),
            ),
          ),
        );

        // Tunggu build selesai
        await tester.pump();

        // Verifikasi BottomNavigationBar ada
        final bottomNav = find.byType(BottomNavigationBar);
        expect(bottomNav, findsOneWidget);

        // Verifikasi teks pada tab
        expect(find.text('Aktif'), findsOneWidget);
        expect(find.text('Dompet'), findsOneWidget);
        expect(find.text('Transaksi'), findsOneWidget);
        expect(find.text('Statistik'), findsOneWidget);
        expect(find.text('Pesanan'), findsOneWidget);
        expect(find.text('Lainnya'), findsOneWidget);
      },
    );
  });

  group('Logic and Service Calls', () {
    testWidgets(
      '01. harus memanggil service yang diperlukan saat initState',
      (tester) async {
        // PERBAIKAN: Mock dengan benar
        when(mockExpiredService.prosesArsipLanggananKadaluarsa())
            .thenAnswer((_) async {});
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.wifi]);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              arsipLanggananKadaluarsaServiceProvider.overrideWithValue(
                mockExpiredService,
              ),
            ],
            child: MaterialApp(
              home: HalamanUtama(
                isOffline: false,
              ),
            ),
          ),
        );

        await tester.pump();

        // Verifikasi service dipanggil
        verify(mockExpiredService.prosesArsipLanggananKadaluarsa()).called(1);
      },
    );

    testWidgets(
      '02. harus menjalankan sinkronisasi saat koneksi kembali online',
      (tester) async {
        // PERBAIKAN: Mock stream connectivity
        final connectivityStream = Stream<List<ConnectivityResult>>.fromIterable([
          [ConnectivityResult.none],
          [ConnectivityResult.wifi],
        ]);

        when(mockConnectivity.onConnectivityChanged)
            .thenAnswer((_) => connectivityStream);
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.wifi]);
        when(mockSyncService.jalankanCekSinkronisasi())
            .thenAnswer((_) async {});

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              layananCekSinkronisasiProvider.overrideWithValue(mockSyncService),
            ],
            child: MaterialApp(
              home: HalamanUtama(
                isOffline: false,
              ),
            ),
          ),
        );

        await tester.pump();

        // Simulasikan perubahan koneksi
        await tester.pump();

        // Verifikasi sync dipanggil
        verify(mockSyncService.jalankanCekSinkronisasi()).called(1);
      },
    );

    testWidgets(
      '03. harus menjalankan sinkronisasi saat aplikasi resumed',
      (tester) async {
        when(mockSyncService.jalankanCekSinkronisasi())
            .thenAnswer((_) async {});

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              layananCekSinkronisasiProvider.overrideWithValue(mockSyncService),
            ],
            child: MaterialApp(
              home: HalamanUtama(
                isOffline: false,
              ),
            ),
          ),
        );

        await tester.pump();

        // Simulasikan lifecycle resumed
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        await tester.pump();

        // Verifikasi sync dipanggil
        verify(mockSyncService.jalankanCekSinkronisasi()).called(1);
      },
    );
  });

  group('Navigasi Tab', () {
    testWidgets(
      '01. harus berpindah tab saat item di tap',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: HalamanUtama(
                isOffline: false,
              ),
            ),
          ),
        );

        await tester.pump();

        // Tap tab "Dompet" (index 1)
        final dompetTab = find.text('Dompet');
        expect(dompetTab, findsOneWidget);
        await tester.tap(dompetTab);
        await tester.pump();

        // Tap tab "Transaksi" (index 2)
        final transaksiTab = find.text('Transaksi');
        expect(transaksiTab, findsOneWidget);
        await tester.tap(transaksiTab);
        await tester.pump();

        // Tap tab "Statistik" (index 3)
        final statistikTab = find.text('Statistik');
        expect(statistikTab, findsOneWidget);
        await tester.tap(statistikTab);
        await tester.pump();

        // Tap tab "Pesanan" (index 4)
        final pesananTab = find.text('Pesanan');
        expect(pesananTab, findsOneWidget);
        await tester.tap(pesananTab);
        await tester.pump();

        // Tap tab "Lainnya" (index 5)
        final lainnyaTab = find.text('Lainnya');
        expect(lainnyaTab, findsOneWidget);
        await tester.tap(lainnyaTab);
        await tester.pump();

        // Kembali ke tab pertama
        final aktifTab = find.text('Aktif');
        expect(aktifTab, findsOneWidget);
        await tester.tap(aktifTab);
        await tester.pump();

        // Verifikasi tidak error
        expect(find.byType(HalamanUtama), findsOneWidget);
      },
    );
  });

  group('Offline Mode', () {
    testWidgets(
      '01. harus menampilkan UI dengan benar saat offline',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: HalamanUtama(
                isOffline: true,
              ),
            ),
          ),
        );

        await tester.pump();

        // Verifikasi UI tetap tampil
        expect(find.text('Aktif'), findsOneWidget);
        expect(find.text('Dompet'), findsOneWidget);
        expect(find.text('Transaksi'), findsOneWidget);
        expect(find.text('Statistik'), findsOneWidget);
        expect(find.text('Pesanan'), findsOneWidget);
        expect(find.text('Lainnya'), findsOneWidget);
        expect(find.byType(BottomNavigationBar), findsOneWidget);
      },
    );
  });
}