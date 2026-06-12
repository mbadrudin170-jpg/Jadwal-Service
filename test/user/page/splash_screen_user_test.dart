
// path: test/user/page/splash_screen_user_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/fitur/akun/provider/akun_provider.dart';
import 'package:wifi/shared/model/event_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/event_op_supabase.dart';
import 'package:wifi/shared/services/koneksi_internet_service.dart';
import 'package:wifi/user/page/event_page_u.dart';
import 'package:wifi/user/page/login_page.dart';
import 'package:wifi/user/page/main_page.dart';
import 'package:wifi/user/page/splash_screen_user.dart';
import 'package:wifi/user/services/storage/layanan_penyimpanan_lokal.dart';

// Mocks
class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockLayananPenyimpananLokal extends Mock
    implements LayananPenyimpananLokal {}

class MockKoneksiInternetService extends Mock
    implements KoneksiInternetService {}

class MockEventOpSupabase extends Mock implements EventOpSupabase {}

class MockPengelolaAkun extends Mock implements PengelolaAkun {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockSharedPreferences mockPrefs;
  late MockLayananPenyimpananLokal mockLocalStorage;
  late MockKoneksiInternetService mockKoneksiService;
  late MockEventOpSupabase mockEventOp;
  late MockPengelolaAkun mockPengelolaAkun;
  late MockNavigatorObserver mockNavigatorObserver;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    mockLocalStorage = MockLayananPenyimpananLokal();
    mockKoneksiService = MockKoneksiInternetService();
    mockEventOp = MockEventOpSupabase();
    mockPengelolaAkun = MockPengelolaAkun();
    mockNavigatorObserver = MockNavigatorObserver();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        koneksiInternetServiceProvider.overrideWithValue(mockKoneksiService),
        eventOpSupabaseProvider.overrideWithValue(mockEventOp),
        pengelolaAkunProvider.overrideWith((ref) async => mockPengelolaAkun),
      ],
      child: MaterialApp(
        home: SplashScreenUser(
          prefs: mockPrefs,
          localStorageService: mockLocalStorage,
        ),
        navigatorObservers: [mockNavigatorObserver],
      ),
    );
  }

  group('SplashScreenUser Tests', () {
    testWidgets('Test 01: Shows loading indicator initially', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Memuat aplikasi...'), findsOneWidget);
    });

    testWidgets('Test 02: Navigates to LoginPage if no active account',
        (tester) async {
      when(() => mockKoneksiService.cekKoneksiLokal())
          .thenAnswer((_) async => true);
      when(() => mockEventOp.getActive()).thenAnswer((_) async => null);
      when(() => mockPengelolaAkun.akunSaatIni).thenReturn(null);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      verify(() => mockNavigatorObserver.didPush(any(), any())).called(1);
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('Test 03: Navigates to MainPage if active account exists',
        (tester) async {
      when(() => mockKoneksiService.cekKoneksiLokal())
          .thenAnswer((_) async => true);
      when(() => mockEventOp.getActive()).thenAnswer((_) async => null);
      when(() => mockPengelolaAkun.akunSaatIni).thenReturn(EventModel(
        id: '1',
        title: 'title',
        imageUrl: 'imageUrl',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      ) as dynamic);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      verify(() => mockNavigatorObserver.didPush(any(), any())).called(1);
      expect(find.byType(MainPage), findsOneWidget);
    });

    testWidgets('Test 04: Navigates to EventPage if event is active',
        (tester) async {
      final event = EventModel(
          id: '1', title: 'title', imageUrl: 'imageUrl', startDate: DateTime.now(), endDate: DateTime.now());
      when(() => mockKoneksiService.cekKoneksiLokal())
          .thenAnswer((_) async => true);
      when(() => mockEventOp.getActive()).thenAnswer((_) async => event);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      verify(() => mockNavigatorObserver.didPush(any(), any())).called(1);
      expect(find.byType(EventPageU), findsOneWidget);
    });
  });
}
