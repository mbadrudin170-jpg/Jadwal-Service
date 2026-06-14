// path: test/admin/halaman/detail/detail_transaksi_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/halaman/detail/detail_transaksi.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/shared/model/transaksi_model.dart';
import 'package:wifi/shared/model/dompet_model.dart';
import 'package:wifi/shared/model/kategori_model.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/customer_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/paket_op_Sqlite.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/transaction_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/dompet_op_sqlite.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/kategori_op_sqlite.dart';

// Mocks
class MockPelangganOpSqlite extends Mock implements PelangganOpSqlite {}

class MockPaketOpSqlite extends Mock implements PaketOpSqlite {}

class MockTransaksiOpsqlite extends Mock implements TransaksiOpsqlite {}

class MockDompetOpSqlite extends Mock implements DompetOpSqlite {}

class MockKategoriOpSqlite extends Mock implements KategoriOpSqlite {}

void main() {
  late MockPelangganOpSqlite mockCustomerOperation;
  late MockPaketOpSqlite mockPackageOperation;
  late MockTransaksiOpsqlite mockTransactionOperation;
  late MockDompetOpSqlite mockWalletOperation;
  late MockKategoriOpSqlite mockCategoryOperation;

  final tTransaction = TransaksiModel(
    id: '1',
    date: DateTime.now(),
    description: 'Test Transaction',
    amount: 100.0,
    type: TransactionType.income,
    walletId: 'wallet1',
    categoryId: 'cat1',
    paymentStatus: PaymentStatus.paid,
    customerId: 'cust1',
    packageId: 'pkg1',
  );

  setUp(() {
    mockCustomerOperation = MockPelangganOpSqlite();
    mockPackageOperation = MockPaketOpSqlite();
    mockTransactionOperation = MockTransaksiOpsqlite();
    mockWalletOperation = MockDompetOpSqlite();
    mockCategoryOperation = MockKategoriOpSqlite();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        pelangganOpSqliteProvider.overrideWithValue(mockCustomerOperation),
        paketOpSqliteProvider.overrideWithValue(mockPackageOperation),
        transaksiOpSqliteProvider.overrideWithValue(mockTransactionOperation),
        dompetOpSqliteProvider.overrideWithValue(mockWalletOperation),
        kategoriOpSqliteProvider.overrideWithValue(mockCategoryOperation),
      ],
      child: MaterialApp(
        home: DetailTransaksi(transaksi: tTransaction),
      ),
    );
  }

  group('Halaman DetailTransaksi', () {
    testWidgets('01. harus menampilkan detail transaksi', (tester) async {
      when(() => mockWalletOperation.ambilBerdasarkanId(any())).thenAnswer(
          (_) async => DompetModel(id: 'wallet1', name: 'Test Wallet', balance: 0));
      when(() => mockCategoryOperation.ambilBerdasarkanId(any())).thenAnswer(
          (_) async => KategoriModel(
              id: 'cat1', name: 'Test Category', type: TipeKategori.income));
      when(() => mockCustomerOperation.ambilBerdasarkanId(any())).thenAnswer(
          (_) async => PelangganModel(
              id: 'cust1',
              name: 'Test Customer',
              phone: '',
              password: '',
              address: '',
              registrationDate: DateTime.now(),
              fcmToken: '',
              appVersion: '',
              platform: '',
              lastActive: DateTime.now()));
      when(() => mockPackageOperation.ambilBerdasarkanId(any())).thenAnswer(
          (_) async => PaketModel(
            id: 'pkg1',
            name: 'Test Package',
            price: 100,
            duration: 30,
            durationType: DurationType.days,
            rewardPoints: 10,
            isPublic: true,
          ));

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.pumpAndSettle();

      expect(find.text('Test Transaction'), findsOneWidget);
      expect(find.text('Test Wallet'), findsOneWidget);
      expect(find.text('Test Category'), findsOneWidget);
      expect(find.text('Test Customer'), findsOneWidget);
      expect(find.text('Test Package'), findsOneWidget);
    });
  });
}
