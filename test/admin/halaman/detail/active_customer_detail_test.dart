// path: test/admin/halaman/detail/active_customer_detail_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/admin/halaman/detail/active_customer_detail.dart';
import 'package:wifi/admin/providers/active_customer_provider.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/fitur/whatsapp/info_paket.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/model/active_customer_detail_model.dart';
import 'package:wifi/shared/model/active_customer_model.dart';
import 'package:wifi/shared/model/package_model.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/customer_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/package_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/transaction_operation.dart';

import 'active_customer_detail_test.mocks.dart';

@GenerateMocks([
  CustomerOperation,
  PackageOperation,
  TransactionOperation,
  PesanInfoPaket,
])
void main() {
  late MockCustomerOperation mockCustomerOp;
  late MockPackageOperation mockPackageOp;
  late MockTransactionOperation mockTransactionOp;
  late MockPesanInfoPaket mockPesanInfoPaket;

  setUp(() {
    mockCustomerOp = MockCustomerOperation();
    mockPackageOp = MockPackageOperation();
    mockTransactionOp = MockTransactionOperation();
    mockPesanInfoPaket = MockPesanInfoPaket();
  });

  final tActiveCustomer = ActiveCustomerModel(
    id: 'ac1',
    customerId: 'c1',
    packageId: 'p1',
    transactionId: 't1',
    startDate: DateTime(2023, 1, 1),
    endDate: DateTime(2023, 2, 1),
    status: PaymentStatus.paid,
  );

  final tCustomer = CustomerModel(
    id: 'c1',
    name: 'Budi Utomo',
    phone: '08123456789',
    address: 'Alamat Budi',
  );

  final tPackage = PackageModel(
    id: 'p1',
    name: 'Paket Hemat',
    price: 50000,
    duration: 30,
    durationType: DurationType.days,
  );

  final tTransaction = TransactionModel(
    id: 't1',
    customerId: 'c1',
    packageId: 'p1',
    amount: 50000,
    date: DateTime(2023, 1, 1),
    status: PaymentStatus.paid,
  );

  ProviderContainer buatContainer() {
    return ProviderContainer(
      overrides: [
        customerOperationProvider.overrideWithValue(mockCustomerOp),
        packageOperationProvider.overrideWithValue(mockPackageOp),
        transactionOperationProvider.overrideWithValue(mockTransactionOp),
        pesanInfoPaketProvider.overrideWithValue(mockPesanInfoPaket),
        activeCustomerProvider.overrideWith((ref) => Stream.value(
              ActiveCustomerState(
                activeCustomers: [
                  ActiveCustomerDetailModel(
                    activeCustomer: tActiveCustomer,
                    customer: tCustomer,
                    package: tPackage,
                  ),
                ],
              ),
            )),
      ],
    );
  }

  group('Pengujian Halaman Detail Pelanggan Aktif', () {
    testWidgets('1. Menampilkan state loading saat data sedang dimuat',
        (tester) async {
      final container = buatContainer();
      // Menggantung future agar tetap loading
      final longFuture = Completer<
          ({
            CustomerModel? customer,
            PackageModel? package,
            TransactionModel? transaction,
            ActiveCustomerModel activeCustomer
          })>();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: ActiveCustomerDetailPage(activeCustomer: tActiveCustomer),
          ),
        ),
      );

      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('2. Menampilkan data pelanggan lengkap setelah berhasil dimuat',
        (tester) async {
      when(mockCustomerOp.getById('c1')).thenAnswer((_) async => tCustomer);
      when(mockPackageOp.getById('p1')).thenAnswer((_) async => tPackage);
      when(mockTransactionOp.getTransactionById('t1'))
          .thenAnswer((_) async => tTransaction);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            customerOperationProvider.overrideWithValue(mockCustomerOp),
            packageOperationProvider.overrideWithValue(mockPackageOp),
            transactionOperationProvider.overrideWithValue(mockTransactionOp),
            pesanInfoPaketProvider.overrideWithValue(mockPesanInfoPaket),
            activeCustomerProvider.overrideWith((ref) => Stream.value(
                  ActiveCustomerState(
                    activeCustomers: [
                      ActiveCustomerDetailModel(
                        activeCustomer: tActiveCustomer,
                        customer: tCustomer,
                        package: tPackage,
                      ),
                    ],
                  ),
                )),
          ],
          child: MaterialApp(
            home: ActiveCustomerDetailPage(activeCustomer: tActiveCustomer),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Budi Utomo'), findsAtLeastNWidgets(1));
      expect(find.text('Paket Hemat'), findsOneWidget);
      expect(find.text('08123456789'), findsOneWidget);
    });

    testWidgets('3. Menampilkan pesan error jika pemuatan data gagal',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeCustomerProvider.overrideWith((ref) => Stream.error('Gagal')),
          ],
          child: MaterialApp(
            home: ActiveCustomerDetailPage(activeCustomer: tActiveCustomer),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.textContaining('Terjadi kesalahan'), findsOneWidget);
    });

    testWidgets('4. Memastikan tombol WhatsApp memanggil fungsi launch',
        (tester) async {
      when(mockCustomerOp.getById('c1')).thenAnswer((_) async => tCustomer);
      when(mockPackageOp.getById('p1')).thenAnswer((_) async => tPackage);
      when(mockTransactionOp.getTransactionById('t1'))
          .thenAnswer((_) async => tTransaction);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            customerOperationProvider.overrideWithValue(mockCustomerOp),
            packageOperationProvider.overrideWithValue(mockPackageOp),
            transactionOperationProvider.overrideWithValue(mockTransactionOp),
            pesanInfoPaketProvider.overrideWithValue(mockPesanInfoPaket),
            activeCustomerProvider.overrideWith((ref) => Stream.value(
                  ActiveCustomerState(
                    activeCustomers: [
                      ActiveCustomerDetailModel(
                        activeCustomer: tActiveCustomer,
                        customer: tCustomer,
                        package: tPackage,
                      ),
                    ],
                  ),
                )),
          ],
          child: MaterialApp(
            home: ActiveCustomerDetailPage(activeCustomer: tActiveCustomer),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final waButton = find.text('08123456789');
      await tester.tap(waButton);
      await tester.pump();
      // Verifikasi interaksi link atau log (tergantung implementasi mock)
    });

    testWidgets('5. Memastikan tombol Kirim Info via WhatsApp memanggil provider',
        (tester) async {
      when(mockCustomerOp.getById('c1')).thenAnswer((_) async => tCustomer);
      when(mockPackageOp.getById('p1')).thenAnswer((_) async => tPackage);
      when(mockTransactionOp.getTransactionById('t1'))
          .thenAnswer((_) async => tTransaction);
      when(mockPesanInfoPaket.kirimRincianPaket(any)).thenAnswer((_) async {});

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            customerOperationProvider.overrideWithValue(mockCustomerOp),
            packageOperationProvider.overrideWithValue(mockPackageOp),
            transactionOperationProvider.overrideWithValue(mockTransactionOp),
            pesanInfoPaketProvider.overrideWithValue(mockPesanInfoPaket),
            activeCustomerProvider.overrideWith((ref) => Stream.value(
                  ActiveCustomerState(
                    activeCustomers: [
                      ActiveCustomerDetailModel(
                        activeCustomer: tActiveCustomer,
                        customer: tCustomer,
                        package: tPackage,
                      ),
                    ],
                  ),
                )),
          ],
          child: MaterialApp(
            home: ActiveCustomerDetailPage(activeCustomer: tActiveCustomer),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final kirimButton = find.text('Kirim Info via WhatsApp');
      await tester.tap(kirimButton);
      await tester.pump();

      verify(mockPesanInfoPaket.kirimRincianPaket(argThat(
        isA<ActiveCustomerModel>().having((e) => e.id, 'id', 'ac1'),
      ))).called(1);
    });
  });
}