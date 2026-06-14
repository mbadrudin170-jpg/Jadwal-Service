// path: test/admin/halaman/detail/active_customer_detail_test.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/halaman/detail/detail_pelanggan_aktif.dart';
import 'package:wifi/admin/halaman/detail/detail_pelanggan.dart';
import 'package:wifi/admin/halaman/detail/detail_paket.dart';
import 'package:wifi/admin/halaman/form/form_pelanggan_aktif.dart';
import 'package:wifi/admin/providers/pelanggan_aktif_provider.dart';
import 'package:wifi/admin/providers/detail_langganan_provider.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/fitur/whatsapp/info_paket.dart';
import 'package:wifi/shared/model/active_customer_detail_model.dart';
import 'package:wifi/shared/model/pelanggan_aktif_model.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/shared/model/transaksi_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/customer_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/paeket_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/transaction_op_firebase.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';

// Mocks
class MockCustomerOpFirebase extends Mock implements CustomerOpFirebase {}

class MockPaketOpFirebase extends Mock implements PaketOpFirebase {}

class MockTransactionOpFirebase extends Mock implements TransactionOpFirebase {}

class MockPesanInfoPaket extends Mock implements PesanInfoPaket {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class FakeRoute extends Fake implements Route<dynamic> {}

void main() {
  // Data dummy
  final tCustomer = PelangganModel(
    id: 'cust1',
    name: 'John Doe',
    phone: '081234567890',
    password: 'password',
    address: '123 Main St',
  );

  final tPackage = PaketModel(
    id: 'pkg1',
    name: 'Paket Kencang',
    price: 100000,
    duration: 30,
    type: DurationType.days,
    rewardPoints: 10,
  );

  final tTransaction = TransaksiModel(
    id: 'trans1',
    customerId: 'cust1',
    packageId: 'pkg1',
    date: DateTime.now(),
    amount: 100000.0,
    type: TransactionType.income,
    paymentStatus: PaymentStatus.paid,
    description: '',
    walletId: '',
    categoryId: '',
  );

  final tActiveCustomer = PelangganAktifModel(
    id: 'active1',
    customerId: 'cust1',
    packageId: 'pkg1',
    transactionId: 'trans1',
    startDate: DateTime.now().subtract(const Duration(days: 10)),
    endDate: DateTime.now().add(const Duration(days: 20)),
    status: PaymentStatus.paid,
  );

  final tActiveCustomerDetailModel = DetailPelangganAktifModel(
    pelangganAktif: tActiveCustomer,
    customerName: tCustomer.name,
    packageName: tPackage.name,
  );

  final tActiveCustomerState =
      PelangganAktifState(pelangganAktif: [tActiveCustomerDetailModel]);

  late MockCustomerOpFirebase mockCustomerOp;
  late MockPaketOpFirebase mockPackageOp;
  late MockTransactionOpFirebase mockTransactionOp;
  late MockPesanInfoPaket mockPesanInfoPaket;
  late MockNavigatorObserver mockNavigatorObserver;

  setUp(() {
    mockCustomerOp = MockCustomerOpFirebase();
    mockPackageOp = MockPaketOpFirebase();
    mockTransactionOp = MockTransactionOpFirebase();
    mockPesanInfoPaket = MockPesanInfoPaket();
    mockNavigatorObserver = MockNavigatorObserver();
    registerFallbackValue(FakeRoute());
  });

  // Helper untuk membuat test widget
  Widget createTestWidget(List<Override> overrides) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        home: DetailPelangganAktif(pelangganAktif: tActiveCustomer),
        navigatorObservers: [mockNavigatorObserver],
      ),
    );
  }

  group('detailLanggananProvider Tests', () {
    test('Test 01: should return full data on success', () async {
      final container = ProviderContainer(
        overrides: [
          activeCustomerProvider.overrideWith((ref) => tActiveCustomerState),
          customerOpFirebaseProvider.overrideWithValue(mockCustomerOp),
          paketOpFirebaseProvider.overrideWithValue(mockPackageOp),
          transactionOpFirebaseProvider.overrideWithValue(mockTransactionOp),
        ],
      );

      when(() => mockCustomerOp.ambilBerdasarkanId(tActiveCustomer.customerId))
          .thenAnswer((_) async => tCustomer);
      when(() => mockPackageOp.ambilBerdasarkanId(tActiveCustomer.packageId))
          .thenAnswer((_) async => tPackage);
      when(() => mockTransactionOp
              .ambilBerdasarkanId(tActiveCustomer.transactionId!))
          .thenAnswer((_) async => tTransaction);

      final result = await container
          .read(detailLanggananProvider(tActiveCustomer.id).future);

      expect(result.customer, tCustomer);
      expect(result.package, tPackage);
      expect(result.transaction, tTransaction);
      expect(result.activeCustomer, tActiveCustomer);
    });

    test('Test 02: should throw exception when active customer not found',
        () async {
      final container = ProviderContainer(
        overrides: [
          activeCustomerProvider
              .overrideWith((ref) => PelangganAktifState(pelangganAktif: [])),
        ],
      );

      await expectLater(
        container.read(detailLanggananProvider(tActiveCustomer.id).future),
        throwsA(isA<Exception>().having((e) => e.toString(), 'toString',
            contains('Data pelanggan aktif tidak ditemukan'))),
      );
    });
  });

  group('ActiveCustomerDetailPage Widget Tests', () {
    final overrides = [
      activeCustomerProvider.overrideWith((ref) => tActiveCustomerState),
      customerOpFirebaseProvider.overrideWithValue(mockCustomerOp),
      paketOpFirebaseProvider.overrideWithValue(mockPackageOp),
      transactionOpFirebaseProvider.overrideWithValue(mockTransactionOp),
      pesanInfoPaketProvider.overrideWithValue(mockPesanInfoPaket),
    ];

    setUp(() {
      when(() => mockCustomerOp.ambilBerdasarkanId(any()))
          .thenAnswer((_) async => tCustomer);
      when(() => mockPackageOp.ambilBerdasarkanId(any()))
          .thenAnswer((_) async => tPackage);
      when(() => mockTransactionOp.ambilBerdasarkanId(any()))
          .thenAnswer((_) async => tTransaction);
    });

    testWidgets('Test 03: should show loading state correctly', (tester) async {
      final completer = Completer<
          ({
            PelangganAktifModel activeCustomer,
            PelangganModel? customer,
            PaketModel? package,
            TransaksiModel? transaction
          })>();
      final loadingOverrides = [
        detailLanggananProvider(tActiveCustomer.id).overrideWith(
          (ref) => completer.future,
        ),
        ...overrides,
      ];

      await tester.pumpWidget(createTestWidget(loadingOverrides));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Test 04: should show error state correctly', (tester) async {
      final errorOverrides = [
        detailLanggananProvider(tActiveCustomer.id)
            .overrideWith((ref) => throw Exception('Test Error')),
        ...overrides,
      ];

      await tester.pumpWidget(createTestWidget(errorOverrides));
      await tester.pumpAndSettle();

      expect(
          find.textContaining('Error: Exception: Test Error'), findsOneWidget);
    });

    testWidgets('Test 05: should display all data correctly', (tester) async {
      await tester.pumpWidget(createTestWidget(overrides));
      await tester.pumpAndSettle();

      expect(find.text('John Doe'), findsOneWidget); // AppBar title
      expect(find.widgetWithText(TextButton, 'John Doe'),
          findsOneWidget); // Body title
      expect(find.text('081234567890'), findsOneWidget);
      expect(find.text('Paket Kencang'), findsOneWidget);
      expect(find.text('Aktif'), findsOneWidget);
      expect(find.text('10 Poin'), findsOneWidget);
      expect(find.text('0 Hari'), findsOneWidget); // Bonus
      expect(find.textContaining('Berakhir pada'), findsOneWidget);
      expect(find.text('Kirim Info via WhatsApp'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('Test 06: tapping edit button navigates to form',
        (tester) async {
      await tester.pumpWidget(createTestWidget(overrides));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      verify(() => mockNavigatorObserver.didPush(any(), any()));
      expect(find.byType(FormPelangganAktif), findsOneWidget);
    });

    testWidgets('Test 07: tapping customer name navigates to customer detail',
        (tester) async {
      await tester.pumpWidget(createTestWidget(overrides));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, 'John Doe'));
      await tester.pumpAndSettle();

      verify(() => mockNavigatorObserver.didPush(any(), any()));
      expect(find.byType(DetailPelanggan), findsOneWidget);
    });

    testWidgets('Test 08: tapping package name navigates to package detail',
        (tester) async {
      await tester.pumpWidget(createTestWidget(overrides));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Paket Kencang'));
      await tester.pumpAndSettle();

      verify(() => mockNavigatorObserver.didPush(any(), any()));
      expect(find.byType(DetailPaketPage), findsOneWidget);
    });

    testWidgets('Test 09: tapping "Kirim Info" button calls provider method',
        (tester) async {
      when(() => mockPesanInfoPaket.kirimRincianPaket(any()))
          .thenAnswer((_) async => true);

      await tester.pumpWidget(createTestWidget(overrides));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Kirim Info via WhatsApp'));
      await tester.pump();

      verify(() => mockPesanInfoPaket.kirimRincianPaket(any())).called(1);
    });
  });
}
