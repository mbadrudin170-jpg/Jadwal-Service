'''
// path: test/user/page/login_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/fitur/akun/provider/akun_provider.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/shared/services/koneksi_internet_service.dart';
import 'package:wifi/user/page/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:wifi/user/page/main_page.dart';

// Mocks
class MockKoneksiInternetService extends Mock
    implements KoneksiInternetService {}

class MockPengelolaAkun extends Mock implements PengelolaAkun {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockKoneksiInternetService mockKoneksiInternetService;
  late MockPengelolaAkun mockPengelolaAkun;
  late MockNavigatorObserver mockNavigatorObserver;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockKoneksiInternetService = MockKoneksiInternetService();
    mockPengelolaAkun = MockPengelolaAkun();
    mockNavigatorObserver = MockNavigatorObserver();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        firestoreProvider.overrideWithValue(fakeFirestore),
        koneksiInternetServiceProvider
            .overrideWithValue(mockKoneksiInternetService),
        pengelolaAkunProvider.overrideWith((ref) => mockPengelolaAkun),
      ],
      child: MaterialApp(
        home: const LoginPage(),
        navigatorObservers: [mockNavigatorObserver],
      ),
    );
  }

  group('LoginPage Tests', () {
    testWidgets('Test 01: Initial render shows login form', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Silakan Masuk'), findsOneWidget);
      expect(find.widgetWithText(InputAngka, 'Nomor Telepon'), findsOneWidget);
      expect(find.byType(InputPassword), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
      expect(find.text('Pilih dari Akun Tersimpan'), findsOneWidget);
      expect(find.text('Lupa Sandi?'), findsOneWidget);
    });

    testWidgets('Test 02: Login with empty fields shows error dialog',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(find.text('Akun tidak ditemukan'), findsOneWidget);
      expect(find.text('Nomor telepon dan password tidak boleh kosong.'),
          findsOneWidget);
    });

    testWidgets('Test 03: Login with no internet shows error toast',
        (tester) async {
      when(() => mockKoneksiInternetService.cekInternet(any()))
          .thenAnswer((_) async => false);

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(
          find.widgetWithText(InputAngka, 'Nomor Telepon'), '12345');
      await tester.enterText(find.byType(InputPassword), 'password');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();
    });

    testWidgets(
        'Test 04: Login with incorrect credentials shows error dialog',
        (tester) async {
      when(() => mockKoneksiInternetService.cekInternet(any()))
          .thenAnswer((_) async => true);
      await fakeFirestore.collection('customer').add({
        'phone': '12345',
        'password': 'password',
        'isDeleted': false,
        'name': 'Test User',
        'email': 'test@example.com',
      });

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(
          find.widgetWithText(InputAngka, 'Nomor Telepon'), '12345');
      await tester.enterText(find.byType(InputPassword), 'wrongpassword');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(find.text('Akun tidak ditemukan'), findsOneWidget);
      expect(find.text('Nomor telepon atau password yang Anda masukkan salah.'),
          findsOneWidget);
    });

    testWidgets('Test 05: Successful login navigates to MainPage',
        (tester) async {
      when(() => mockKoneksiInternetService.cekInternet(any()))
          .thenAnswer((_) async => true);
      final customerData = {
        'phone': '12345',
        'password': 'password',
        'isDeleted': false,
        'name': 'Test User',
        'email': 'test@example.com',
      };
      await fakeFirestore.collection('customer').add(customerData);
      final customer = CustomerModel.fromFirebase(
          '1', customerData); // Assuming CustomerModel.fromFirebase works

      when(() => mockPengelolaAkun.login(customer))
          .thenAnswer((_) async => Future.value());

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(
          find.widgetWithText(InputAngka, 'Nomor Telepon'), '12345');
      await tester.enterText(find.byType(InputPassword), 'password');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      verify(() => mockPengelolaAkun.login(any(named: 'customer'))).called(1);
      verify(() => mockNavigatorObserver.didPush(any(), any())).called(1);
      expect(find.byType(MainPage), findsOneWidget);
    });
  });
}
''