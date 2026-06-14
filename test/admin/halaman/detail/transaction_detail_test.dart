// path: test/admin/halaman/detail/transaction_detail_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/halaman/detail/detail_transaksi.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/shared/model/transaksi_model.dart';
import 'package:wifi/shared/model/dompet_model.dart';
import 'package:wifi/shared/model/kategori_model.dart';
import 'package:wifi/shared/model/sub_category_model.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/operasi/firebase_operasi/customer_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/paeket_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/transaction_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/dompet_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/kategori_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/sub_kategori_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';

// Mocks
class MockCustomerOpFirebase extends Mock implements CustomerOpFirebase {}

class MockPaketOpFirebase extends Mock implements PaketOpFirebase {}

class MockTransactionOpFirebase extends Mock implements TransactionOpFirebase {}

class MockDompetOpFirebase extends Mock implements DompetOpFirebase {}

class MockKategoriOpFirebase extends Mock implements KategoriOpFirebase {}

class MockSubKategoriOpFirebase extends Mock implements SubKategoriOpFirebase {}

void main() {
  late MockCustomerOpFirebase mockCustomerOperation;
  late MockPaketOpFirebase mockPackageOperation;
  late MockTransactionOpFirebase mockTransactionOperation;
  late MockDompetOpFirebase mockWalletOperation;
  late MockKategoriOpFirebase mockCategoryOperation;
  late MockSubKategoriOpFirebase mockSubCategoryOperation;

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
    mockCustomerOperation = MockCustomerOpFirebase();
    mockPackageOperation = MockPaketOpFirebase();
    mockTransactionOperation = MockTransactionOpFirebase();
    mockWalletOperation = MockDompetOpFirebase();
    mockCategoryOperation = MockKategoriOpFirebase();
    mockSubCategoryOperation = MockSubKategoriOpFirebase();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        customerOpFirebaseProvider.overrideWithValue(mockCustomerOperation),
        paketOpFirebaseProvider.overrideWithValue(mockPackageOperation),
        transactionOpFirebaseProvider
            .overrideWithValue(mockTransactionOperation),
        dompetOpFirebaseProvider.overrideWithValue(mockWalletOperation),
        kategoriOpFirebaseProvider.overrideWithValue(mockCategoryOperation),
        subKategoriOpFirebaseProvider
            .overrideWithValue(mockSubCategoryOperation),
      ],
      child: MaterialApp(
        home: DetailTransaksi(transaksi: tTransaction),
      ),
    );
  }

  group('TransactionDetailPage', () {
    testWidgets('01. should display transaction details', (tester) async {
      when(() => mockWalletOperation.ambilBerdasarkanId(any())).thenAnswer(
          (_) async => DompetModel(id: 'wallet1', name: 'Test Wallet'));
      when(() => mockCategoryOperation.ambilBerdasarkanId(any())).thenAnswer(
          (_) async => KategoriModel(
              id: 'cat1', name: 'Test Category', type: TipeKategori.income));
      when(() => mockCustomerOperation.ambilBerdasarkanId(any())).thenAnswer(
          (_) async => PelangganModel(
              id: 'cust1',
              name: 'Test Customer',
              phone: '',
              password: '',
              address: ''));
      when(() => mockPackageOperation.ambilBerdasarkanId(any())).thenAnswer(
          (_) async => PaketModel(
              id: 'pkg1',
              name: 'Test Package',
              price: 100,
              duration: 30,
              type: DurationType.days));

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
