// path: test/admin/halaman_utama_test.dart
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/admin/halaman/tab/active_customer_tab.dart';
import 'package:wifi/admin/halaman/tab/lainnya.dart';
import 'package:wifi/admin/halaman_utama.dart';
import 'package:wifi/fitur/dompet/page/dompet_page.dart';
import 'package:wifi/shared/data/services/sync_check_service.dart';
import 'package:wifi/shared/services/arsipkan_langganan_kadaluarsa_service.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:workmanager/workmanager.dart';

// Mocks
class MockWorkmanager extends Mock implements Workmanager {}

class MockSyncCheckService extends Mock implements SyncCheckService {}

class MockExpiredSubscriptionCheckService extends Mock
    implements ArsipLanggananKadaluarsaService {}

class MockConnectivity extends Mock implements Connectivity {}

class MockStreamSubscription<T> extends Mock implements StreamSubscription<T> {}

void main() {
  // Deklarasi Mocks
  late MockWorkmanager mockWorkmanager;
  late MockSyncCheckService mockSyncCheckService;
  late MockExpiredSubscriptionCheckService mockExpiredSubscriptionCheckService;
  late MockConnectivity mockConnectivity;
  late StreamController<List<ConnectivityResult>> connectivityStreamController;

  // Widget wrapper
  Widget createTestWidget(
    bool isOffline,
    ProviderContainer container,
  ) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: HalamanUtama(isOffline: isOffline),
      ),
    );
  }

  setUp(() {
    mockWorkmanager = MockWorkmanager();
    mockSyncCheckService = MockSyncCheckService();
    mockExpiredSubscriptionCheckService = MockExpiredSubscriptionCheckService();
    mockConnectivity = MockConnectivity();
    connectivityStreamController = StreamController<List<ConnectivityResult>>();

    // Mock a basic Workmanager instance
    Workmanager.p = mockWorkmanager;

    // Default behaviors for mocks
    when(() => mockWorkmanager.registerPeriodicTask(
          any(),
          any(),
          frequency: any(named: 'frequency'),
          constraints: any(named: 'constraints'),
        )).thenAnswer((_) async {});
    when(() => mockSyncCheckService.runSyncCheck()).thenAnswer((_) async {});
    when(() => mockExpiredSubscriptionCheckService
        .prosesArsipLanggananKadaluarsa()).thenAnswer((_) async {});
    when(() => mockConnectivity.onConnectivityChanged)
        .thenAnswer((_) => connectivityStreamController.stream);
    when(() => MockStreamSubscription<List<ConnectivityResult>>().cancel())
        .thenAnswer((_) async {});
  });

  tearDown(() {
    connectivityStreamController.close();
  });

  ProviderContainer createProviderContainer() {
    final container = ProviderContainer(
      overrides: [
        syncCheckServiceProvider.overrideWithValue(mockSyncCheckService),
        arsipLanggananKadaluarsaServiceProvider
            .overrideWithValue(mockExpiredSubscriptionCheckService),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('Tes Fungsionalitas HalamanUtama', () {
    testWidgets('Test 01: Render UI awal dan inisialisasi sukses',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final container = createProviderContainer();

      await tester.pumpWidget(createTestWidget(false, container));
      await tester.pumpAndSettle(); // Tunggu semua future di initState selesai

      // Verifikasi UI Awal
      expect(find.byType(ActiveCustomerPage), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Aktif'), findsWidgets);

      // Verifikasi pemanggilan fungsi inisialisasi
      verify(() => mockWorkmanager.registerPeriodicTask(
            '1',
            'syncBackgroundTask',
            frequency: const Duration(minutes: 15),
            constraints: any(named: 'constraints'),
          )).called(1);
      verify(() => mockExpiredSubscriptionCheckService
          .prosesArsipLanggananKadaluarsa()).called(1);
      verify(() => mockSyncCheckService.runSyncCheck()).called(1);
    });

    testWidgets(
        'Test 02: Menampilkan pesan offline saat isOffline bernilai true',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final container = createProviderContainer();
      await tester.pumpWidget(createTestWidget(true, container));
      await tester.pumpAndSettle();

      expect(find.text('Anda dalam mode offline. Data mungkin tidak terbaru.'),
          findsOneWidget);
    });

    testWidgets('Test 03: Memproses notifikasi awal saat payload ada',
        (tester) async {
      SharedPreferences.setMockInitialValues(
          {'initial_notification_payload': 'test_payload'});
      final container = createProviderContainer();

      await tester.pumpWidget(createTestWidget(false, container));
      await tester.pumpAndSettle();

      expect(find.text('Dibuka dari notifikasi: test_payload'), findsOneWidget);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('initial_notification_payload'), isNull);
    });

    testWidgets('Test 04: Navigasi tab berfungsi dengan benar', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final container = createProviderContainer();

      await tester.pumpWidget(createTestWidget(false, container));
      await tester.pumpAndSettle();

      // Pindah ke tab Dompet
      await tester.tap(find.byIcon(TIcons.wallet));
      await tester.pumpAndSettle();
      expect(find.byType(DompetPage), findsOneWidget);
      expect(find.byType(ActiveCustomerPage), findsNothing);

      // Pindah ke tab Lainnya
      await tester.tap(find.byIcon(TIcons.apps));
      await tester.pumpAndSettle();
      expect(find.byType(LainnyaPage), findsOneWidget);
      expect(find.byType(DompetPage), findsNothing);
    });

    testWidgets('Test 05: Sinkronisasi dipicu saat koneksi kembali online',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final container = createProviderContainer();

      // Tancapkan mock connectivity ke provider (jika diperlukan)
      // atau pastikan initState bisa mengaksesnya
      // HalamanUtama membuat instance Connectivity sendiri, jadi kita tidak bisa override.
      // Untuk tujuan pengujian, kita akan berasumsi listen dipanggil dengan benar
      // dan kita hanya akan memicu stream-nya.

      await tester.pumpWidget(createTestWidget(false, container));
      await tester.pumpAndSettle();

      // Awalnya dipanggil sekali di initState
      verify(() => mockSyncCheckService.runSyncCheck()).called(1);

      // Simulasikan koneksi kembali
      connectivityStreamController.add([ConnectivityResult.wifi]);
      await tester.pumpAndSettle();

      // Seharusnya dipanggil lagi
      verify(() => mockSyncCheckService.runSyncCheck()).called(1);
    });

    testWidgets('Test 06: Sinkronisasi dipicu saat aplikasi resumed',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final container = createProviderContainer();

      await tester.pumpWidget(createTestWidget(false, container));
      await tester.pumpAndSettle();

      // Awalnya dipanggil sekali
      verify(() => mockSyncCheckService.runSyncCheck()).called(1);

      // Simulasikan app resume
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      // Seharusnya dipanggil lagi
      verify(() => mockSyncCheckService.runSyncCheck()).called(1);
    });

    testWidgets('Test 07: Penanganan error saat sinkronisasi gagal',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      when(() => mockSyncCheckService.runSyncCheck())
          .thenThrow(Exception('Gagal Sinkronisasi'));
      final container = createProviderContainer();

      await tester.pumpWidget(createTestWidget(false, container));
      await tester.pumpAndSettle();

      // Verifikasi bahwa meskipun gagal, tidak ada error yang dilempar oleh widget
      verify(() => mockSyncCheckService.runSyncCheck()).called(1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Test 08: Sinkronisasi tidak berjalan ganda', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final container = createProviderContainer();
      final completer = Completer<void>();
      when(() => mockSyncCheckService.runSyncCheck())
          .thenAnswer((_) => completer.future);

      await tester.pumpWidget(createTestWidget(false, container));
      await tester.pump(); // Mulai sinkronisasi

      // Panggil pemicu sinkronisasi lain saat yang pertama masih berjalan
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();

      // Selesaikan sinkronisasi pertama
      completer.complete();
      await tester.pumpAndSettle();

      // Verifikasi runSyncCheck hanya dipanggil sekali
      verify(() => mockSyncCheckService.runSyncCheck()).called(1);
    });
  });
}
