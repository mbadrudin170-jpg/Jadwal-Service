// path: test/admin/halaman/detail/active_customer_detail_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/halaman/detail/detail_paket.dart';
import 'package:wifi/admin/halaman/detail/detail_pelanggan.dart';
import 'package:wifi/admin/halaman/detail/detail_pelanggan_aktif.dart';
import 'package:wifi/admin/halaman/form/form_pelanggan_aktif.dart';
import 'package:wifi/admin/providers/pelanggan_aktif_provider.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/fitur/whatsapp/info_paket.dart';
import 'package:wifi/shared/model/pelanggan_aktif_model.dart';
import 'package:wifi/shared/model/transaksi_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/customer_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/paket_op_Sqlite.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/transaction_operation.dart';
import 'package:wifi/shared/model/active_customer_detail_model.dart';
import 'package:wifi/shared/export/enum.dart';

// Mocks
class MockPelangganOpSqlite extends Mock implements PelangganOpSqlite {}

class MockPaketOpSqlite extends Mock implements PaketOpSqlite {}

class MockTransaksiOpsqlite extends Mock implements TransaksiOpsqlite {}

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
    registrationDate: DateTime.now(),
    fcmToken: '',
    appVersion: '',
    platform: '',
    lastActive: DateTime.now(),
  );

  final tPackage = PaketModel(
    id: 'pkg1',
    name: 'Paket Kencang',
    price: 100000,
    duration: 30,
    durationType: DurationType.days,
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
    status: ActiveStatus.active,
  );

  final tActiveCustomerDetailModel = DetailPelangganAktifModel(
    pelangganAktif: tActiveCustomer,
    customerName: tCustomer.name,
    packageName: tPackage.name,
  );

  final tActiveCustomerState =
      PelangganAktifState(daftarPelangganAktif: [tActiveCustomerDetailModel]);

  late MockPelangganOpSqlite mockCustomerOp;
  late MockPaketOpSqlite mockPackageOp;
  late MockTransaksiOpsqlite mockTransactionOp;
  late MockPesanInfoPaket mockPesanInfoPaket;
  late MockNavigatorObserver mockNavigatorObserver;

  setUpAll(() {
    registerFallbackValue(FakeRoute());
  });

  setUp(() {
    mockCustomerOp = MockPelangganOpSqlite();
    mockPackageOp = MockPaketOpSqlite();
    mockTransactionOp = MockTransaksiOpsqlite();
    mockPesanInfoPaket = MockPesanInfoPaket();
    mockNavigatorObserver = MockNavigatorObserver();
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

  group('activeCustomerDetailProvider Tests', () {
    test('01. harus mengembalikan data lengkap saat sukses', () async {
      final container = ProviderContainer(
        overrides: [
          pelangganAktifProvider.overrideWith((ref) async => tActiveCustomerState),
          pelangganOpSqliteProvider.overrideWithValue(mockCustomerOp),
          paketOpSqliteProvider.overrideWithValue(mockPackageOp),
          transaksiOpSqliteProvider.overrideWithValue(mockTransactionOp),
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
          .read(activeCustomerDetailProvider(tActiveCustomer.id).future);

      expect(result.customer, tCustomer);
      expect(result.package, tPackage);
      expect(result.transaction, tTransaction);
      expect(result.activeCustomer, tActiveCustomer);
    });

    test('02. harus throw exception saat pelanggan aktif tidak ditemukan',
        () async {
      final container = ProviderContainer(
        overrides: [
          pelangganAktifProvider.overrideWith(
              (ref) async => PelangganAktifState(daftarPelangganAktif: [])),
        ],
      );

      await expectLater(
        container.read(activeCustomerDetailProvider(tActiveCustomer.id).future),
        throwsA(isA<Exception>().having((e) => e.toString(), 'toString',
            contains('Data pelanggan aktif tidak ditemukan'))),
      );
    });
  });

  group('Widget DetailPelangganAktif', () {
    final overrides = [
      pelangganAktifProvider.overrideWith((ref) async => tActiveCustomerState),
      pelangganOpSqliteProvider.overrideWithValue(mockCustomerOp),
      paketOpSqliteProvider.overrideWithValue(mockPackageOp),
      transaksiOpSqliteProvider.overrideWithValue(mockTransactionOp),
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

    testWidgets('03. harus menampilkan loading indicator dengan benar', (tester) async {
      final completer = Completer<PelangganAktifState>();

      await tester.pumpWidget(createTestWidget([
        pelangganAktifProvider.overrideWith((ref) => completer.future),
      ]));
      expect(find.byType(Text), findsOneWidget);
      expect(find.text(''), findsOneWidget);
    });

    testWidgets('04. harus menampilkan error dengan benar', (tester) async {
      final errorOverrides = [
        pelangganAktifProvider
            .overrideWith((ref) => throw Exception('Test Error')),
        ...overrides,
      ];

      await tester.pumpWidget(createTestWidget(errorOverrides));
      await tester.pumpAndSettle();

      expect(
          find.text('Terjadi kesalahan: Exception: Test Error'), findsOneWidget);
    });

    testWidgets('05. harus menampilkan semua data dengan benar', (tester) async {
      await tester.pumpWidget(createTestWidget(overrides));
      await tester.pumpAndSettle();

      expect(find.text('John Doe'), findsNWidgets(2));
      expect(find.text('081234567890'), findsOneWidget);
      expect(find.text('Paket Kencang'), findsOneWidget);
      expect(find.text('Aktif'), findsOneWidget);
      expect(find.text('10 Poin'), findsOneWidget);
      expect(find.text('0 Hari'), findsOneWidget);
      expect(find.textContaining('sisa'), findsOneWidget);
      expect(find.text('Kirim Info via WhatsApp'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('06. menekan tombol edit harus navigasi ke form',
        (tester) async {
      await tester.pumpWidget(createTestWidget(overrides));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      verify(() => mockNavigatorObserver.didPush(any(), any()));
      expect(find.byType(FormPelangganAktif), findsOneWidget);
    });

    testWidgets('07. menekan nama pelanggan harus navigasi ke detail pelanggan',
        (tester) async {
      await tester.pumpWidget(createTestWidget(overrides));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, 'John Doe'));
      await tester.pumpAndSettle();

      verify(() => mockNavigatorObserver.didPush(any(), any()));
      expect(find.byType(DetailPelanggan), findsOneWidget);
    });

    testWidgets('08. menekan nama paket harus navigasi ke detail paket',
        (tester) async {
      await tester.pumpWidget(createTestWidget(overrides));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Paket Kencang'));
      await tester.pumpAndSettle();

      verify(() => mockNavigatorObserver.didPush(any(), any()));
      expect(find.byType(DetailPaketPage), findsOneWidget);
    });

    testWidgets('09. menekan tombol "Kirim Info" harus memanggil method provider',
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
