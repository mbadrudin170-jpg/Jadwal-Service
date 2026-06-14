// path: test/admin/halaman/detail/riwayat_aktivasi_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/halaman/detail/detail_riwayat_aktivasi.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/shared/model/transaksi_model.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/customer_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/paket_op_Sqlite.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/transaction_operation.dart';

// Mocks
class MockPelangganOpSqlite extends Mock implements PelangganOpSqlite {}

class MockPaketOpSqlite extends Mock implements PaketOpSqlite {}

class MockTransaksiOpsqlite extends Mock implements TransaksiOpsqlite {}

void main() {
  late MockPelangganOpSqlite mockCustomerOperation;
  late MockPaketOpSqlite mockPackageOperation;
  late MockTransaksiOpsqlite mockTransactionOperation;

  final tCustomer = PelangganModel(
    id: 'cust1',
    name: 'Test Customer',
    phone: '123456789',
    address: 'Test Address',
    password: 'password',
    registrationDate: DateTime.now(),
    fcmToken: '',
    appVersion: '',
    platform: '',
    lastActive: DateTime.now(),
  );

  final tPackage = PaketModel(
    id: 'pkg1',
    name: 'Test Package',
    price: 100000,
    duration: 30,
    durationType: DurationType.days,
    rewardPoints: 10,
    isPublic: true,
  );

  final tTransaction = TransaksiModel(
    id: 'trans1',
    customerId: 'cust1',
    packageId: 'pkg1',
    date: DateTime.now(),
    amount: 100000,
    type: TransactionType.income,
    paymentStatus: PaymentStatus.paid,
    description: 'Test Description',
    walletId: 'wallet1',
    categoryId: 'cat1',
  );

  setUp(() {
    mockCustomerOperation = MockPelangganOpSqlite();
    mockPackageOperation = MockPaketOpSqlite();
    mockTransactionOperation = MockTransaksiOpsqlite();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        pelangganOpSqliteProvider.overrideWithValue(mockCustomerOperation),
        paketOpSqliteProvider.overrideWithValue(mockPackageOperation),
        transaksiOpSqliteProvider.overrideWithValue(mockTransactionOperation),
      ],
      child: MaterialApp(
        home: DetailRiwayatAktivasi(idTransaksi: tTransaction.id),
      ),
    );
  }

  group('Widget DetailRiwayatAktivasi', () {
    testWidgets('01. harus menampilkan loading indicator saat mengambil data',
        (tester) async {
      when(() => mockTransactionOperation.ambilBerdasarkanId(any()))
          .thenAnswer((_) async => tTransaction);
      when(() => mockCustomerOperation.ambilBerdasarkanId(any()))
          .thenAnswer((_) async => tCustomer);
      when(() => mockPackageOperation.ambilBerdasarkanId(any()))
          .thenAnswer((_) async => tPackage);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('02. harus menampilkan data saat pengambilan berhasil',
        (tester) async {
      when(() => mockTransactionOperation.ambilBerdasarkanId(any()))
          .thenAnswer((_) async => tTransaction);
      when(() => mockCustomerOperation.ambilBerdasarkanId(any()))
          .thenAnswer((_) async => tCustomer);
      when(() => mockPackageOperation.ambilBerdasarkanId(any()))
          .thenAnswer((_) async => tPackage);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Test Customer'), findsOneWidget);
      expect(find.text('Test Package'), findsOneWidget);
    });

    testWidgets('03. harus menampilkan pesan error saat transaksi tidak ditemukan',
        (tester) async {
      when(() => mockTransactionOperation.ambilBerdasarkanId(any()))
          .thenAnswer((_) async => null);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Transaksi tidak ditemukan'), findsOneWidget);
    });
  });
}
