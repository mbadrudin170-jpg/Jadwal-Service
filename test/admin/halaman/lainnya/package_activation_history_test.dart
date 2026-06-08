// path: test/admin/halaman/lainnya/package_activation_history_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/admin/halaman/lainnya/package_activation_history.dart';
import 'package:wifi/shared/enum/duration_type_enum.dart';
import 'package:wifi/shared/enum/payment_status_enum.dart';
import 'package:wifi/shared/enum/transaction_type_enum.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/shared/model/package_model.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/customer_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/operasi_sqlite_provider/operasi_sqlite_provider.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/package_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/transaction_operation.dart';

import 'package_activation_history_test.mocks.dart';

// Menjalankan build_runner:
// flutter pub run build_runner build --delete-conflicting-outputs
@GenerateMocks([TransactionOperation, PackageOperation, CustomerOperation])
void main() {
  group('Pengujian Widget PackageActivationHistoryPage', () {
    // Deklarasi variabel mock
    late MockTransactionOperation mockTransactionOperation;
    late MockPackageOperation mockPackageOperation;
    late MockCustomerOperation mockCustomerOperation;

    // Data tiruan untuk pengujian
    final t1 = TransactionModel(
      id: 't1',
      customerId: 'c1',
      packageId: 'p1',
      date: DateTime(2023, 1, 10),
      endDate: DateTime(2023, 2, 10), // Berakhir lebih lambat
      description: 'Aktivasi Paket A',
      amount: 100000,
      type: TransactionType.income,
      walletId: 'w1',
      paymentStatus: PaymentStatus.paid,
      categoryId: 'cat1',
    );
    final t2 = TransactionModel(
      id: 't2',
      customerId: 'c2',
      packageId: 'p2',
      date: DateTime(2023, 1, 5),
      endDate: DateTime(2023, 2, 5), // Berakhir lebih cepat
      description: 'Aktivasi Paket B',
      amount: 200000,
      type: TransactionType.income,
      walletId: 'w2',
      paymentStatus: PaymentStatus.paid,
      categoryId: 'cat2',
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

// Inisialisasi mock sebelum setiap pengujian
    setUp(() {
      mockTransactionOperation = MockTransactionOperation();
      mockPackageOperation = MockPackageOperation();
      mockCustomerOperation = MockCustomerOperation();
    });

    // Helper function untuk membuat widget yang diuji
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

    // Pengujian untuk state loading
    testWidgets('harus menampilkan CircularProgressIndicator saat data sedang dimuat',
        (tester) async {
      // Arrange
      when(mockTransactionOperation.getTransactionsByPackageActivation())
          .thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return [];
      });
      when(mockPackageOperation.getById(any)).thenAnswer((_) async => null);
      when(mockCustomerOperation.getById(any)).thenAnswer((_) async => null);

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Selesaikan future
      await tester.pumpAndSettle();
    });

    group('ketika data berhasil dimuat', () {
      setUp(() {
        // Stub untuk operasi transaksi
        when(mockTransactionOperation.getTransactionsByPackageActivation())
            .thenAnswer((_) async => [t1, t2]);

        // Stub untuk operasi paket
        when(mockPackageOperation.getById('p1'))
            .thenAnswer((_) async => package1);
        when(mockPackageOperation.getById('p2'))
            .thenAnswer((_) async => package2);
        when(mockPackageOperation.getById(argThat(isNot(isIn(['p1', 'p2'])))))
            .thenAnswer((_) async => null);

        // Stub untuk operasi pelanggan
        when(mockCustomerOperation.getById('c1'))
            .thenAnswer((_) async => customer1);
        when(mockCustomerOperation.getById('c2'))
            .thenAnswer((_) async => customer2);
        when(mockCustomerOperation.getById(argThat(isNot(isIn(['c1', 'c2'])))))
            .thenAnswer((_) async => null);
      });

      testWidgets(
          'harus menampilkan daftar riwayat langganan yang diurutkan berdasarkan tanggal akhir terbaru',
          (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle(); // Tunggu semua Future (termasuk di FutureBuilder) selesai

        // Assert
        // Pastikan nama-nama pelanggan muncul di layar
        expect(find.text('Pelanggan Satu'), findsOneWidget);
        expect(find.text('Pelanggan Dua'), findsOneWidget);

        // Verifikasi urutan dengan membandingkan posisi vertikal (koordinat Y)
        final customerOneFinder = find.text('Pelanggan Satu');
        final customerTwoFinder = find.text('Pelanggan Dua');

        final firstWidgetY = tester.getTopLeft(customerOneFinder).dy;
        final secondWidgetY = tester.getTopLeft(customerTwoFinder).dy;

        // 'Pelanggan Satu' (t1) memiliki endDate lebih baru, jadi harus
        // muncul di atas (koordinat Y lebih kecil).
        expect(
          firstWidgetY < secondWidgetY,
          isTrue,
          reason: 'Pelanggan Satu harus muncul di atas Pelanggan Dua',
        );
      });
    });

    group('ketika terjadi kondisi khusus', () {
      testWidgets('harus menampilkan pesan saat tidak ada riwayat ditemukan',
          (tester) async {
        // Arrange
        when(mockTransactionOperation.getTransactionsByPackageActivation())
            .thenAnswer((_) async => []); // Kembalikan list kosong

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(
            find.text('Tidak ada riwayat langganan ditemukan.'), findsOneWidget);
        expect(find.byType(ListView), findsNothing);
      });

      testWidgets('harus menampilkan pesan error saat pengambilan data gagal',
          (tester) async {
        // Arrange
        const errorMessage = 'Gagal memuat data transaksi';
        when(mockTransactionOperation.getTransactionsByPackageActivation())
            .thenAnswer((_) async => throw Exception(errorMessage));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.textContaining(errorMessage), findsOneWidget);
        expect(find.byType(ListView), findsNothing);
      });
    });
  });
}
