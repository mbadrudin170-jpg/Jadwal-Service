// path: test/shared/operasi/poin/firebase_points_data_source_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/shared/enum/duration_type_enum.dart';
import 'package:wifi/shared/enum/payment_status_enum.dart';
import 'package:wifi/shared/enum/transaction_type_enum.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/shared/model/transaksi_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/paeket_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/transaction_op_firebase.dart';
import 'package:wifi/fitur/poin/operasi/firebase_points_data_source.dart';

import 'firebase_points_data_source_test.mocks.dart';

@GenerateMocks([TransactionOpFirebase, PaketOpFirebase])
void main() {
  // 2. Deklarasi Mocks dan SUT (System Under Test)
  late MockTransactionOpFirebase mockTransactionOpFirebase;
  late MockPackageOpFirebase mockPackageOpFirebase;
  late FirebasePointsDataSource dataSource;

  // 3. Inisialisasi Mocks dan SUT sebelum setiap test dijalankan
  setUp(() {
    mockTransactionOpFirebase = MockTransactionOpFirebase();
    mockPackageOpFirebase = MockPackageOpFirebase();
    dataSource = FirebasePointsDataSource(
      transactionOpFirebase: mockTransactionOpFirebase,
      packageOpFirebase: mockPackageOpFirebase,
    );
  });

  group('Tes Unit untuk FirebasePointsDataSource', () {
    const customerId = 'test-customer-id';
    const packageId = 'test-package-id';

    // Test case 1
    test(
        '1. getTotalPoints harus memanggil metode yang benar pada TransactionOpFirebase',
        () async {
      // Arrange: Atur mock untuk mengembalikan nilai yang diharapkan
      when(mockTransactionOpFirebase.getTotalPoints(customerId))
          .thenAnswer((_) async => 150);

      // Act: Panggil metode yang akan diuji
      final result = await dataSource.ambilTotalPoin(customerId);

      // Assert: Verifikasi bahwa hasilnya benar dan metode mock dipanggil
      expect(result, 150);
      verify(mockTransactionOpFirebase.getTotalPoints(customerId)).called(1);
      verifyNoMoreInteractions(mockTransactionOpFirebase);
      verifyZeroInteractions(mockPackageOpFirebase);
    });

    // Test case 2
    test(
        '2. getPublicPackages harus memanggil metode yang benar pada PackageOpFirebase',
        () async {
      // Arrange
      final mockPackages = [
        PaketModel(
            id: '1',
            name: 'Paket A',
            redemptionPoints: 100,
            price: 0,
            duration: 30,
            type: DurationType.days),
        PaketModel(
            id: '2',
            name: 'Paket B',
            redemptionPoints: 200,
            price: 0,
            duration: 30,
            type: DurationType.days),
      ];
      when(mockPackageOpFirebase.getPublicPackages())
          .thenAnswer((_) async => mockPackages);

      // Act
      final result = await dataSource.getPublicPackages();

      // Assert
      expect(result, equals(mockPackages));
      verify(mockPackageOpFirebase.getPublicPackages()).called(1);
      verifyNoMoreInteractions(mockPackageOpFirebase);
      verifyZeroInteractions(mockTransactionOpFirebase);
    });

    // Test case 3
    test(
        '3. getPointsTransactions harus memfilter dan hanya mengembalikan transaksi poin',
        () async {
      // Arrange
      final now = DateTime.now();
      final allTransactions = [
        // Transaksi yang harus lolos filter
        TransaksiModel(
            id: '1',
            description: 'Beli Poin',
            earnedPoints: 50,
            date: now,
            type: TransactionType.income,
            amount: 5000,
            customerId: customerId,
            paymentStatus: PaymentStatus.paid,
            walletId: 'wallet1',
            categoryId: 'cat1'),
        TransaksiModel(
            id: '3',
            description: 'Tukar Hadiah',
            usedPoints: 100,
            date: now,
            type: TransactionType.expense,
            amount: 0,
            customerId: customerId,
            paymentStatus: PaymentStatus.paid,
            walletId: 'wallet1',
            categoryId: 'cat1'),
        // Transaksi ini harus diabaikan karena tidak ada poin yang didapat atau digunakan
        TransaksiModel(
            id: '2',
            description: 'Bayar Tagihan',
            date: now,
            type: TransactionType.income,
            amount: 50000,
            customerId: customerId,
            paymentStatus: PaymentStatus.paid,
            walletId: 'wallet1',
            categoryId: 'cat1'),
      ];
      when(mockTransactionOpFirebase.getByCustomerId(customerId))
          .thenAnswer((_) async => allTransactions);
      // Act
      final result = await dataSource.getPointsTransactions(customerId);

      // Assert
      expect(result.length, 2);
      expect(result.any((t) => t.id == '1'), isTrue,
          reason: 'Transaksi dengan earnedPoints > 0 harus ada');
      expect(result.any((t) => t.id == '3'), isTrue,
          reason: 'Transaksi dengan usedPoints > 0 harus ada');
      expect(result.any((t) => t.id == '2'), isFalse,
          reason: 'Transaksi tanpa poin harus diabaikan');
      verify(mockTransactionOpFirebase.getByCustomerId(customerId)).called(1);
      verifyNoMoreInteractions(mockTransactionOpFirebase);
      verifyZeroInteractions(mockPackageOpFirebase);
    });

    // Test case 4
    test(
        '4. getPackageById harus memanggil metode yang benar pada PackageOpFirebase',
        () async {
      // Arrange
      final mockPackage = PaketModel(
          id: packageId,
          name: 'Paket Detail',
          redemptionPoints: 50,
          price: 0,
          duration: 7,
          type: DurationType.days);
      when(mockPackageOpFirebase.getPackageById(packageId))
          .thenAnswer((_) async => mockPackage);

      // Act
      final result = await dataSource.getPaketByid(packageId);

      // Assert
      expect(result, equals(mockPackage));
      verify(mockPackageOpFirebase.getPackageById(packageId)).called(1);
      verifyNoMoreInteractions(mockPackageOpFirebase);
      verifyZeroInteractions(mockTransactionOpFirebase);
    });

    // Test case 5
    test('5. Properti isFirebase harus selalu mengembalikan true', () {
      // Act & Assert
      expect(dataSource.isFirebase, isTrue);
      // Pastikan tidak ada interaksi dengan mock untuk properti sederhana ini
      verifyZeroInteractions(mockTransactionOpFirebase);
      verifyZeroInteractions(mockPackageOpFirebase);
    });
  });
}
