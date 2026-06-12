// path: test/admin/halaman/lainnya/package_activation_history_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/admin/halaman/lainnya/package_activation_history.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/shared/enum/duration_type_enum.dart';
import 'package:wifi/shared/enum/payment_status_enum.dart';
import 'package:wifi/shared/enum/transaction_type_enum.dart';
import 'package:wifi/shared/model/package_model.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/customer_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/package_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/transaction_operation.dart';

import 'package_activation_history_test.mocks.dart';

// Menjalankan build_runner:
// flutter pub run build_runner build --delete-conflicting-outputs
@GenerateMocks([TransactionOperation, PackageOperation, CustomerOperation])
void main() {
  group('Pengujian Widget PackageActivationHistoryPage', () {
    late MockTransactionOperation mockTransactionOperation;
    late MockPackageOperation mockPackageOperation;
    late MockCustomerOperation mockCustomerOperation;

    final t1 = TransactionModel(
      id: 't1',
      customerId: 'c1',
      packageId: 'p1',
      date: DateTime(2023, 1, 10),
      endDate: DateTime(2023, 2, 10), // Berakhir lebih baru
      description: 'Aktivasi Paket A',
      amount: 100000,
      type: TransactionType.income,
      walletId: 'w1',
      paymentStatus: PaymentStatus.paid,
      categoryId: 'cat1',
      updatedAt: DateTime(2023, 1, 10),
    );
    final t2 = TransactionModel(
      id: 't2',
      customerId: 'c2',
      packageId: 'p2',
      date: DateTime(2023, 1, 5),
      endDate: DateTime(2023, 2, 5), // Berakhir lebih dulu
      description: 'Aktivasi Paket B',
      amount: 200000,
      type: TransactionType.income,
      walletId: 'w2',
      paymentStatus: PaymentStatus.paid,
      categoryId: 'cat2',
      updatedAt: DateTime(2023, 1, 5),
    );

    final customer1 = CustomerModel(
        id: 'c1',
        name: 'Pelanggan Satu',
        phone: '123',
        address: 'alamat 1',
        password: '123');
    final customer2 = CustomerModel(
        id: 'c2',
        name: 'Pelanggan Dua',
        phone: '456',
        address: 'alamat 2',
        password: '456');

    final package1 = PackageModel(
        id: 'p1',
        name: 'Paket A',
        price: 100000,
        duration: 30,
        type: DurationType.days);
    final package2 = PackageModel(
        id: 'p2',
        name: 'Paket B',
        price: 200000,
        duration: 30,
        type: DurationType.days);

    setUp(() {
      mockTransactionOperation = MockTransactionOperation();
      mockPackageOperation = MockPackageOperation();
      mockCustomerOperation = MockCustomerOperation();
    });

    Widget createTestWidget() {
      return ProviderScope(
        overrides: [
          transactionOperationProvider
              .overrideWithValue(mockTransactionOperation),
          packageOperationProvider.overrideWithValue(mockPackageOperation),
          customerOperationProvider.overrideWithValue(mockCustomerOperation),
        ],
        child: const MaterialApp(
          home: PackageActivationHistoryPage(),
        ),
      );
    }

    testWidgets('1. harus menampilkan CircularProgressIndicator saat data sedang dimuat',
        (tester) async {
      when(mockTransactionOperation.getTransactionsByPackageActivation())
          .thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        return [];
      });
      when(mockCustomerOperation.getAll()).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();
    });

    group('2. ketika data berhasil dimuat', () {
      setUp(() {
        when(mockTransactionOperation.getTransactionsByPackageActivation())
            .thenAnswer((_) async => [t2, t1]); // Urutan acak
        when(mockCustomerOperation.getAll())
            .thenAnswer((_) async => [customer1, customer2]);

        when(mockPackageOperation.getById('p1'))
            .thenAnswer((_) async => package1);
        when(mockPackageOperation.getById('p2'))
            .thenAnswer((_) async => package2);
      });

      testWidgets(
          'harus menampilkan daftar riwayat langganan yang diurutkan berdasarkan tanggal akhir terbaru',
          (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Pelanggan Satu'), findsOneWidget);
        expect(find.text('Pelanggan Dua'), findsOneWidget);

        final customerOneFinder = find.text('Pelanggan Satu');
        final customerTwoFinder = find.text('Pelanggan Dua');

        final firstWidgetY = tester.getTopLeft(customerOneFinder).dy;
        final secondWidgetY = tester.getTopLeft(customerTwoFinder).dy;

        expect(
          firstWidgetY < secondWidgetY,
          isTrue,
          reason:
              'Pelanggan Satu (t1) harus di atas Pelanggan Dua (t2) karena endDate lebih baru',
        );
      });
    });

    group('3. ketika terjadi kondisi khusus', () {
      testWidgets('harus menampilkan pesan saat tidak ada riwayat ditemukan',
          (tester) async {
        when(mockTransactionOperation.getTransactionsByPackageActivation())
            .thenAnswer((_) async => []); // List kosong
        when(mockCustomerOperation.getAll()).thenAnswer((_) async => []);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(
            find.text('Tidak ada riwayat langganan ditemukan.'), findsOneWidget);
        expect(find.byType(ListView), findsNothing);
      });

      testWidgets('harus menampilkan pesan error saat pengambilan data gagal',
          (tester) async {
        const errorMessage = 'Gagal memuat data transaksi';
        when(mockTransactionOperation.getTransactionsByPackageActivation())
            .thenThrow(Exception(errorMessage));
        when(mockCustomerOperation.getAll()).thenAnswer((_) async => []);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.textContaining('Error: Exception: $errorMessage'),
            findsOneWidget);
        expect(find.byType(ListView), findsNothing);
      });
    });
  });
}
