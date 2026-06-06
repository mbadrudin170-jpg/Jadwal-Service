import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/services/internet_connection_check.dart';
import 'package:wifi/shared/services/user_activity_service.dart';
import 'package:wifi/user/page/login_page.dart';
import 'package:wifi/user/page/main_page.dart';
import 'package:wifi/user/providers/user_providers.dart';
import 'package:wifi/user/services/storage/local_storage_service.dart';

import 'login_page_test.mocks.dart';

@GenerateMocks([
  InternetConnectionService,
  LocalStorageService,
  SharedPreferences,
  NavigatorObserver,
  UserActivityService,
])
Future<void> main() async {
  // ✅ KRUSIAL: Inisialisasi binding test terlebih dahulu
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockInternetConnectionService mockInternetService;
  late MockLocalStorageService mockLocalStorageService;
  late MockSharedPreferences mockSharedPreferences;
  late MockUserActivityService mockUserActivityService;
  late FakeFirebaseFirestore fakeFirestore;
  late MockNavigatorObserver mockNavigatorObserver;

  group('Uji Coba Halaman Login', () {
    setUp(() {
      mockInternetService = MockInternetConnectionService();
      mockLocalStorageService = MockLocalStorageService();
      mockSharedPreferences = MockSharedPreferences();
      mockUserActivityService = MockUserActivityService();
      fakeFirestore = FakeFirebaseFirestore();
      mockNavigatorObserver = MockNavigatorObserver();

      when(mockInternetService.isInternetAvailable())
          .thenAnswer((_) async => true);
      when(mockLocalStorageService.getAccountList())
          .thenAnswer((_) async => []);
      when(mockNavigatorObserver.navigator).thenReturn(null);
      when(mockLocalStorageService.prefs).thenReturn(mockSharedPreferences);
      when(mockSharedPreferences.setString(any, any))
          .thenAnswer((_) async => true);
      when(mockUserActivityService.pingActivity(any, force: anyNamed('force')))
          .thenAnswer((_) async {});
      when(mockLocalStorageService.saveAccount(any)).thenAnswer((_) async {});
      when(mockLocalStorageService.saveCurrentAccount(any))
          .thenAnswer((_) async {});

      SharedPreferences.setMockInitialValues({});
    });

    Future<void> pumpWidget(WidgetTester tester,
        {List<Override> overrides = const []}) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userActivityServiceProvider
                .overrideWith((ref) => Future.value(mockUserActivityService)),
            internetConnectionServiceProvider
                .overrideWithValue(mockInternetService),
            ...overrides,
          ],
          child: MaterialApp(
            home: LoginPage(
              firestore: fakeFirestore,
              localStorageService: mockLocalStorageService,
            ),
            navigatorObservers: [mockNavigatorObserver],
          ),
        ),
      );
    }

    testWidgets('1. harus menampilkan semua widget awal dengan benar',
        (WidgetTester tester) async {
      await pumpWidget(tester);
      await tester.pumpAndSettle();
      expect(find.text('Silakan Masuk'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    });

    testWidgets('2. harus menampilkan dialog error jika form kosong',
        (WidgetTester tester) async {
      await pumpWidget(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Nomor telepon dan password tidak boleh kosong.'),
          findsOneWidget);
    });

    testWidgets(
        '3. harus menampilkan dialog error jika pelanggan tidak ditemukan',
        (WidgetTester tester) async {
      await pumpWidget(tester);
      await tester.pumpAndSettle();
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Nomor Telepon'), '123');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'), '123');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      // Sesuaikan dengan pesan dari kode produk
      expect(find.text('Nomor telepon atau password yang Anda masukkan salah.'),
          findsOneWidget);
    });

    testWidgets('5. harus menavigasi ke halaman utama saat login berhasil',
        (WidgetTester tester) async {
      const customerId = 'user-sukses';
      final customerTable = TableNameValue.get(TableName.customer);
      await fakeFirestore.collection(customerTable).doc(customerId).set({
        ColumnNames.phone: '08123456789',
        ColumnNames.password: 'password123',
        ColumnNames.name: 'Pengguna Uji',
        ColumnNames.isDeleted: false,
      });

      await pumpWidget(tester);
      await tester.pumpAndSettle();

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Nomor Telepon'), '08123456789');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'), 'password123');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Tunggu hingga loading selesai dan navigasi terjadi
      await tester.pumpAndSettle(const Duration(seconds: 5));

      verify(mockNavigatorObserver.didPush(any, any)).called(1);
      expect(find.byType(MainPage), findsOneWidget);

      verify(mockLocalStorageService.saveCurrentAccount(any)).called(1);
      verify(mockUserActivityService.pingActivity(customerId, force: true))
          .called(1);
    });
  });
}
