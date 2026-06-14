// path: test/user/page/profile_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/shared/model/package_model.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/customer_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/shared/operasi/firebase_operasi/package_op_firebase.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_firebase.dart';
import 'package:wifi/user/page/profile_page.dart';
import 'package:wifi/user/providers/user_providers.dart';
import 'package:wifi/user/services/ads/interstitial_ad_service.dart';

// Mocks
class MockCustomerOpFirebase extends Mock implements CustomerOpFirebase {}

class MockTransactionOpFirebase extends Mock implements TransaksiOpFirebase {}

class MockPackageOpFirebase extends Mock implements PackageOpFirebase {}

class MockInterstitialAdService extends Mock implements InterstitialAdService {}

void main() {
  late MockCustomerOpFirebase mockCustomerOpFirebase;
  late MockTransactionOpFirebase mockTransactionOpFirebase;
  late MockPackageOpFirebase mockPackageOpFirebase;
  late MockInterstitialAdService mockInterstitialAdService;
  late DateTime now;

  setUp(() {
    now = DateTime.now();
    mockCustomerOpFirebase = MockCustomerOpFirebase();
    mockTransactionOpFirebase = MockTransactionOpFirebase();
    mockPackageOpFirebase = MockPackageOpFirebase();
    mockInterstitialAdService = MockInterstitialAdService();
  });

  final customer = PelangganModel(
    id: 'test-user-id',
    name: 'Test User',
    phone: '123456789',
    password: 'password',
    registrationDate: now,
    fcmToken: '',
    appVersion: '',
    platform: '',
    lastActive: now,
    address: '',
  );

  final transaction = TransaksiModel(
    id: 'test-transaction-id',
    idPelanggan: 'test-user-id',
    idPaket: 'test-package-id',
    tanggal: DateTime.now(),
    tangglberakhir: DateTime.now().add(const Duration(days: 30)),
    jumlah: 100000,
    tipe: 'income',
    deskripsi: '',
    idDompet: '',
    idKategori: '',
  );

  final package = PackageModel(
    id: 'test-package-id',
    name: 'Test Package',
    price: 100000,
    duration: 30,
    type: 'days',
    description: '',
    isAvailable: true,
    createdAt: now,
    updatedAt: now,
  );

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        customerOpFirebaseProvider.overrideWithValue(mockCustomerOpFirebase),
        transactionOpFirebaseProvider
            .overrideWithValue(mockTransactionOpFirebase),
        paketOpFirebaseProvider.overrideWithValue(mockPackageOpFirebase),
        userIdProvider.overrideWithValue('test-user-id'),
        interstitialAdServiceProvider
            .overrideWithValue(mockInterstitialAdService),
      ],
      child: const MaterialApp(
        home: ProfilePage(),
      ),
    );
  }

  group('ProfilePage', () {
    testWidgets('Test 01: should display loading indicator while fetching data',
        (WidgetTester tester) async {
      when(() => mockCustomerOpFirebase.ambilBerdasarkanId(any()))
          .thenAnswer((_) async => customer);
      when(() => mockTransactionOpFirebase.getTotalPoints(any()))
          .thenAnswer((_) async => 100);
      when(() => mockTransactionOpFirebase.getPaketAktifCustomer(any()))
          .thenAnswer((_) async => [transaction]);
      when(() => mockPackageOpFirebase.getPackageById(any()))
          .thenAnswer((_) async => package);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('Test 02: should display profile data after fetching',
        (WidgetTester tester) async {
      when(() => mockCustomerOpFirebase.ambilBerdasarkanId(any()))
          .thenAnswer((_) async => customer);
      when(() => mockTransactionOpFirebase.getTotalPoints(any()))
          .thenAnswer((_) async => 100);
      when(() => mockTransactionOpFirebase.getPaketAktifCustomer(any()))
          .thenAnswer((_) async => [transaction]);
      when(() => mockPackageOpFirebase.getPackageById(any()))
          .thenAnswer((_) async => package);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
      expect(find.text('Test Package'), findsOneWidget);
    });

    testWidgets('Test 03: should display error message when fetching fails',
        (WidgetTester tester) async {
      when(() => mockCustomerOpFirebase.ambilBerdasarkanId(any()))
          .thenThrow(Exception('Failed to fetch data'));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.textContaining('Error'), findsOneWidget);
    });

    testWidgets('Test 04: should navigate to UserCustomerDetailPage on tap',
        (WidgetTester tester) async {
      when(() => mockCustomerOpFirebase.ambilBerdasarkanId(any()))
          .thenAnswer((_) async => customer);
      when(() => mockTransactionOpFirebase.getTotalPoints(any()))
          .thenAnswer((_) async => 100);
      when(() => mockTransactionOpFirebase.getPaketAktifCustomer(any()))
          .thenAnswer((_) async => [transaction]);
      when(() => mockPackageOpFirebase.getPackageById(any()))
          .thenAnswer((_) async => package);
      when(() => mockInterstitialAdService.show())
          .thenAnswer((_) async => Future.value());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Test User'));
      await tester.pumpAndSettle();

      verify(() => mockInterstitialAdService.show());
    });
  });
}
