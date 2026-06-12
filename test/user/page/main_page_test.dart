import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/fitur/notfikasi/notifikasi_servis.dart';
import 'package:wifi/fitur/notfikasi/penjadwal_notifikasi.dart';
import 'package:wifi/fitur/pelanggan/core/user_activity_service.dart';
import 'package:wifi/user/page/main_page.dart';
import 'package:wifi/user/providers/user_providers.dart';

// Mocks
class MockNotifikasiServis extends Mock implements NotifikasiServis {}

class MockUserActivityService extends Mock implements UserActivityService {}

void main() {
  late MockNotifikasiServis mockNotifikasiServis;
  late MockUserActivityService mockUserActivityService;

  setUp(() {
    mockNotifikasiServis = MockNotifikasiServis();
    mockUserActivityService = MockUserActivityService();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        userIdProvider.overrideWith((ref) => Future.value('testUserId')),
        notifikasiServisProvider.overrideWithValue(mockNotifikasiServis),
        userActivityServiceProvider
            .overrideWith((ref) => Future.value(mockUserActivityService)),
      ],
      child: const MaterialApp(
        home: MainPage(),
      ),
    );
  }

  group('MainPage Tests', () {
    testWidgets(
        'Test 01: Initial render shows ProfilePage and correct bottom navigation',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verify initial page is ProfilePage
      expect(find.text('Profil'), findsWidgets);

      // Verify BottomNavigationBar items
      expect(find.text('Riwayat'), findsOneWidget);
      expect(find.text('Pesanan'), findsOneWidget);
      expect(find.text('Uji Speed'), findsOneWidget);
      expect(find.text('Pengaturan'), findsOneWidget);
    });

    testWidgets('Test 02: Tapping bottom navigation items changes the page',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Tap on 'Riwayat'
      await tester.tap(find.text('Riwayat'));
      await tester.pump();
      expect(find.text('Riwayat Langganan'), findsOneWidget);

      // Tap on 'Pesanan'
      await tester.tap(find.text('Pesanan'));
      await tester.pump();
      expect(find.text('Pilih Paket'), findsOneWidget);

      // Tap on 'Uji Speed'
      await tester.tap(find.text('Uji Speed'));
      await tester.pump();
      expect(find.text('Uji Kecepatan Internet'), findsOneWidget);

      // Tap on 'Pengaturan'
      await tester.tap(find.text('Pengaturan'));
      await tester.pump();
      expect(find.text('Pengaturan Aplikasi'), findsOneWidget);
    });

    testWidgets(
        'Test 03: initState calls PenjadwalNotifikasi and UserActivityService',
        (tester) async {
      when(() => PenjadwalNotifikasi.aturNotifikasiLangganan(
          any(), any()))
          .thenAnswer((_) async {});
      when(() => mockUserActivityService.pingActivity(any()))
          .thenAnswer((_) async => Future.value());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      verify(() => PenjadwalNotifikasi.aturNotifikasiLangganan(
          any(), any()))
          .called(1);
      verify(() => mockUserActivityService.pingActivity(any())).called(1);
    });
  });
}
