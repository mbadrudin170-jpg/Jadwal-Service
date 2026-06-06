// path: test/user/page/login_page_test.dart
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/model/customer_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/customer_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/shared/providers/shared_providers.dart';
import 'package:wifi/shared/services/internet_connection_check.dart';
import 'package:wifi/user/page/login_page.dart';
import 'package:wifi/user/page/main_page.dart';
import 'package:wifi/user/providers/user_providers.dart';
import 'package:wifi/user/services/storage/local_storage_service.dart';

import 'login_page_test.mocks.dart';

// 1. TAMBAHKAN CustomerOpFirebase KE MOCKS
@GenerateMocks([
  InternetConnectionService,
  LocalStorageService,
  SharedPreferences,
  NavigatorObserver,
  CustomerOpFirebase
])
void main() {
  // 2. SIAPKAN SEMUA INSTANCE MOCK DAN FAKE
  late MockInternetConnectionService mockInternetService;
  late MockLocalStorageService mockLocalStorageService;
  late MockSharedPreferences mockSharedPreferences;
  late MockCustomerOpFirebase mockCustomerOpFirebase;
  late FakeFirebaseFirestore fakeFirestore;
  late MockNavigatorObserver mockNavigatorObserver;

  group('Uji Coba Halaman Login', () {
    // 3. INISIALISASI SEMUA MOCK
    setUp(() {
      mockInternetService = MockInternetConnectionService();
      mockLocalStorageService = MockLocalStorageService();
      mockSharedPreferences = MockSharedPreferences();
      mockCustomerOpFirebase = MockCustomerOpFirebase();
      fakeFirestore = FakeFirebaseFirestore();
      mockNavigatorObserver = MockNavigatorObserver();

      // Atur default behavior untuk semua mock
      when(mockInternetService.isInternetAvailable()).thenAnswer((_) async => true);
      when(mockLocalStorageService.saveAccount(any)).thenAnswer((_) async => true);
      when(mockLocalStorageService.getAccountList()).thenAnswer((_) async => []);
      when(mockLocalStorageService.prefs).thenReturn(mockSharedPreferences);
      when(mockSharedPreferences.setString(any, any)).thenAnswer((_) async => true);
      // Atur default behavior untuk customerOpFirebase
      when(mockCustomerOpFirebase.updateLastActive(any)).thenAnswer((_) async {});

      SharedPreferences.setMockInitialValues({});
    });

    Future<void> pumpWidget(WidgetTester tester, {List<Override> overrides = const []}) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            internetConnectionServiceProvider.overrideWithValue(mockInternetService),
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

    testWidgets('1. harus menampilkan semua widget awal dengan benar', (WidgetTester tester) async {
      await pumpWidget(tester);
      await tester.pumpAndSettle();

      expect(find.text('Silakan Masuk'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Nomor Telepon'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    });

    testWidgets('2. harus menampilkan dialog error jika form kosong', (WidgetTester tester) async {
      await pumpWidget(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Nomor telepon dan password tidak boleh kosong.'), findsOneWidget);
    });

    testWidgets('3. harus menampilkan toast saat tidak ada koneksi internet', (WidgetTester tester) async {
      when(mockInternetService.isInternetAvailable()).thenAnswer((_) async => false);

      await pumpWidget(tester);
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, 'Nomor Telepon'), '123');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), '123');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      verifyNever(mockNavigatorObserver.didPush(any, any));
    });

    testWidgets('4. harus menampilkan dialog error saat kredensial salah', (WidgetTester tester) async {
      await pumpWidget(tester);
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, 'Nomor Telepon'), '12345');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'salah');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Nomor telepon atau password yang Anda masukkan salah.'), findsOneWidget);
    });

    testWidgets('5. harus menavigasi ke halaman utama saat login berhasil', (WidgetTester tester) async {
      final customerId = 'user-sukses';
      final customerTable = TableNameValue.get(TableName.customer);
      await fakeFirestore.collection(customerTable).doc(customerId).set({
        ColumnNames.phone: '08123456789',
        ColumnNames.password: 'password123',
        ColumnNames.name: 'Pengguna Uji',
        ColumnNames.isDeleted: false,
        ColumnNames.createdAt: DateTime.now(),
        ColumnNames.updatedAt: DateTime.now(),
        ColumnNames.lastActiveAt: DateTime.now(),
      });

      final prefs = await SharedPreferences.getInstance();

      // 4. LENGKAPI SEMUA OVERRIDE PROVIDER YANG DIBUTUHKAN
      await pumpWidget(tester, overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        customerOpFirebaseProvider.overrideWithValue(mockCustomerOpFirebase),
      ]);
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, 'Nomor Telepon'), '08123456789');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));

      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();

      // Verifikasi bahwa navigasi terjadi
      verify(mockNavigatorObserver.didPush(any, any));
      expect(find.byType(MainPage), findsOneWidget);
      expect(find.byType(LoginPage), findsNothing);

      // Verifikasi bahwa interaksi dengan mock terjadi
      verify(mockLocalStorageService.saveAccount(any)).called(1);
      verify(mockSharedPreferences.setString('userId', customerId)).called(1);
      verify(mockCustomerOpFirebase.updateLastActive(customerId)).called(1);
    });

    testWidgets('6. harus mengubah visibilitas password saat ikon ditekan', (WidgetTester tester) async {
      await pumpWidget(tester);
      await tester.pumpAndSettle();

      var passwordField = tester.widget<TextFormField>(find.widgetWithText(TextFormField, 'Password'));
      expect(passwordField.obscureText, isTrue);

      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      passwordField = tester.widget<TextFormField>(find.widgetWithText(TextFormField, 'Password'));
      expect(passwordField.obscureText, isFalse);
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });
  });
}
