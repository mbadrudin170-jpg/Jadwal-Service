// path: test/admin/providers/transaction_provider_test.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/admin/halaman/tab/transaction_page_a.dart';
import 'package:wifi/admin/providers/transaction_provider.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/transaction_operation.dart';

import 'transaction_provider_test.mocks.dart';

// 1. Membuat mock untuk TransactionOperation
@GenerateNiceMocks([MockSpec<TransaksiOpsqlite>()])
void main() {
  late MockTransactionOperation mockOperation;
  late ProviderContainer container;

  // 2. Data dummy untuk pengujian
  final tDate1 = DateTime(2023, 1, 1);
  final tDate2 = DateTime(2023, 1, 2);

  final tTransaction1 = TransaksiModel(
    id: '1',
    description: 'Pembelian Pulsa',
    categoryId: 'cat1',
    amount: 50000,
    date: tDate1,
    type: TransactionType.expense,
    walletId: 'wallet1',
  );

  final tTransaction2 = TransaksiModel(
    id: '2',
    description: 'Gaji',
    categoryId: 'cat2',
    amount: 200000,
    date: tDate2,
    type: TransactionType.income,
    walletId: 'wallet1',
  );

  // 3. Fungsi pembantu untuk stubbing pemanggilan data awal
  void stubInitialData() {
    when(mockOperation.getAllTransactions())
        .thenAnswer((_) async => [tTransaction1, tTransaction2]);
    when(mockOperation.getTotalIncome()).thenAnswer((_) async => 200000);
    when(mockOperation.getTotalExpense()).thenAnswer((_) async => 50000);
    when(mockOperation.getNetTotal()).thenAnswer((_) async => 150000);
  }

  // 4. Fungsi setup untuk menginisialisasi mock dan container
  void setupContainer() {
    container = ProviderContainer(
      overrides: [
        transactionOperationProvider.overrideWithValue(mockOperation),
      ],
    );
  }

  // 5. Pengaturan awal untuk semua test
  setUp(() {
    mockOperation = MockTransactionOperation();
    stubInitialData();
    setupContainer();
  });

  // 6. Pastikan container di-dispose setelah setiap test
  tearDown(() {
    container.dispose();
  });

  group('Pengujian Transaction Provider', () {
    test('1. build harus memuat data awal dengan benar', () async {
      // Arrange & Act
      final state = await container.read(transactionProvider.future);

      // Assert
      expect(state.transactions.length, 2);
      expect(state.totalIncome, 200000);
      expect(state.totalExpense, 50000);
      expect(state.netTotal, 150000);
      expect(state.sortBy, SortBy.newest);
      expect(state.transactions.first.id, '2');
      verify(mockOperation.getAllTransactions()).called(1);
      verify(mockOperation.getTotalIncome()).called(1);
      verify(mockOperation.getTotalExpense()).called(1);
      verify(mockOperation.getNetTotal()).called(1);
    });

    test('2. sortTransactions harus mengurutkan list tanpa memuat ulang',
        () async {
      // Arrange
      await container.read(transactionProvider.future);
      expect(container.read(transactionProvider),
          isA<AsyncData<TransactionState>>());

      // Act: urutkan berdasarkan terlama
      container
          .read(transactionProvider.notifier)
          .sortTransactions(SortBy.oldest);

      // Assert
      expect(container.read(transactionProvider),
          isA<AsyncData<TransactionState>>());
      final stateOldest = container.read(transactionProvider).value!;
      expect(stateOldest.sortBy, SortBy.oldest);
      expect(stateOldest.transactions.first.id, '1');

      // Act: urutkan berdasarkan nominal terendah
      container
          .read(transactionProvider.notifier)
          .sortTransactions(SortBy.lowestAmount);

      // Assert
      expect(container.read(transactionProvider),
          isA<AsyncData<TransactionState>>());
      final stateLowest = container.read(transactionProvider).value!;
      expect(stateLowest.sortBy, SortBy.lowestAmount);
      expect(stateLowest.transactions.first.amount, 50000);

      // Verifikasi bahwa tidak ada pemanggilan baru ke database
      verify(mockOperation.getAllTransactions()).called(1);
    });

    test('3. addTransaction harus menambahkan data dan memuat ulang', () async {
      // Arrange
      await container.read(transactionProvider.future);
      when(mockOperation.addTransaction(any)).thenAnswer((_) async => 0);
      // Stub untuk pemanggilan _loadData kedua kalinya
      when(mockOperation.getAllTransactions()).thenAnswer(
          (_) async => [tTransaction1, tTransaction2, tTransaction1]);
      when(mockOperation.getTotalIncome()).thenAnswer((_) async => 250000);
      when(mockOperation.getTotalExpense()).thenAnswer((_) async => 50000);
      when(mockOperation.getNetTotal()).thenAnswer((_) async => 200000);

      // Act
      await container
          .read(transactionProvider.notifier)
          .addTransaction(tTransaction1);

      // Assert
      verify(mockOperation.addTransaction(tTransaction1)).called(1);
      verify(mockOperation.getAllTransactions()).called(2);
    });

    test('4. updateTransaction harus memperbarui data dan memuat ulang',
        () async {
      // Arrange
      await container.read(transactionProvider.future);
      when(mockOperation.updateTransaction(any, any))
          .thenAnswer((_) async => 0);

      // Act
      await container
          .read(transactionProvider.notifier)
          .updateTransaction(tTransaction1);

      // Assert
      verify(mockOperation.updateTransaction(tTransaction1.id, tTransaction1))
          .called(1);
      verify(mockOperation.getAllTransactions()).called(2);
    });

    test('5. softDelete harus menghapus data dan memuat ulang', () async {
      // Arrange
      await container.read(transactionProvider.future);
      when(mockOperation.softDelete(any)).thenAnswer((_) async => 0);
      when(mockOperation.getAllTransactions())
          .thenAnswer((_) async => [tTransaction2]);

      // Act
      await container.read(transactionProvider.notifier).softDelete('1');

      // Assert
      verify(mockOperation.softDelete('1')).called(1);
      verify(mockOperation.getAllTransactions()).called(2);
    });

    test('6. softDeleteAll harus menghapus semua data dan memuat ulang',
        () async {
      // Arrange
      await container.read(transactionProvider.future);
      when(mockOperation.softDeleteAll()).thenAnswer((_) async => 0);
      when(mockOperation.getAllTransactions()).thenAnswer((_) async => []);

      // Act
      await container.read(transactionProvider.notifier).softDeleteAll();

      // Assert
      verify(mockOperation.softDeleteAll()).called(1);
      verify(mockOperation.getAllTransactions()).called(2);
    });

    test('7. refresh harus memuat ulang data', () async {
      // Arrange
      await container.read(transactionProvider.future);

      // Act
      await container.read(transactionProvider.notifier).refresh();

      // Assert
      verify(mockOperation.getAllTransactions()).called(2);
      verify(mockOperation.getTotalIncome()).called(2);
      verify(mockOperation.getTotalExpense()).called(2);
      verify(mockOperation.getNetTotal()).called(2);
    });
  });
}
