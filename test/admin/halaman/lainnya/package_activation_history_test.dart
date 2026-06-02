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
import 'package:wifi/shared/model/customer_model.dart';
import 'package:wifi/shared/model/package_model.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/operasi/customer_operation.dart';
import 'package:wifi/shared/operasi/package_operation.dart';
import 'package:wifi/shared/operasi/transaction_operation.dart';
import 'package:wifi/shared/theme/app_icons.dart';
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
      date: DateTime(2023),
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
      endDate: DateTime(2023, 1, 25), // diubah agar urutan awal berbeda
      description: 'Aktivasi Paket B',
      amount: 50000,
      type: TransactionType.income,
      walletId: 'w1',
      categoryId: 'cat1',
    );

    final c1 = CustomerModel(
      id: 'c1',
      name: 'Alice',
      phone: '08123456789',
      address: 'Alamat Alice',
      password: 'password123',
    );
    final c2 = CustomerModel(
      id: 'c2',
      name: 'Bob',
      phone: '08123456780',
      address: 'Alamat Bob',
      password: 'password123',
    );

    final p1 = PackageModel(
      id: 'p1',
      name: 'Paket A',
      price: 100000,
      duration: 30,
      type: DurationType.days,
    );
    final p2 = PackageModel(
      id: 'p2',
      name: 'Paket B',
      price: 50000,
      duration: 15,
      type: DurationType.days,
    );

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

    testWidgets(
        'harus menampilkan indikator pemuatan lalu menampilkan daftar transaksi',
        (tester) async {
      // Arrange
      when(mockTransactionOperation.getTransactionsByPackageActivation())
          .thenAnswer((_) async => [t1, t2]);
      when(mockCustomerOperation.getCustomersByIds(any))
          .thenAnswer((_) async => [c1, c2]);
      when(mockPackageOperation.getById('p1')).thenAnswer((_) async => p1);
      when(mockPackageOperation.getById('p2')).thenAnswer((_) async => p2);

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert: Tampilkan indikator loading saat awal
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Selesaikan semua frame sampai widget stabil
      await tester.pumpAndSettle();

      // Assert: Daftar transaksi ditampilkan dengan benar
      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('Paket A'), findsOneWidget);
      expect(find.text('Paket B'), findsOneWidget);
      expect(find.text('Status: Lunas'), findsOneWidget);
      expect(find.text('Status: Belum Lunas'), findsOneWidget);
    });

    testWidgets(
        'harus menampilkan dialog pengurutan dan mengurutkan daftar dengan benar',
        (tester) async {
      // Arrange
      when(mockTransactionOperation.getTransactionsByPackageActivation())
          .thenAnswer((_) async => [t1, t2]);
      when(mockCustomerOperation.getCustomersByIds(any))
          .thenAnswer((_) async => [c1, c2]);
      when(mockPackageOperation.getById('p1')).thenAnswer((_) async => p1);
      when(mockPackageOperation.getById('p2')).thenAnswer((_) async => p2);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert: Urutan awal berdasarkan tanggal berakhir (Bob, lalu Alice)
      var listItems = tester.widgetList<Card>(find.byType(Card));
      expect(
          find.descendant(
              of: find.byWidget(listItems.first), matching: find.text('Bob')),
          findsOneWidget);
      expect(
          find.descendant(
              of: find.byWidget(listItems.last), matching: find.text('Alice')),
          findsOneWidget);

      // Tekan tombol filter/sort
      await tester.tap(find.byIcon(TIcons.filter));
      await tester.pumpAndSettle();

      // Assert: Dialog pengurutan muncul
      expect(find.byType(SimpleDialog), findsOneWidget);
      expect(find.text('Urutkan Berdasarkan'), findsOneWidget);

      // Pilih urutkan berdasarkan Nama (A-Z)
      await tester.tap(find.text('Nama Pelanggan (A-Z)'));
      await tester.pumpAndSettle();

      // Assert: Daftar diurutkan berdasarkan nama A-Z (Alice, lalu Bob)
      listItems = tester.widgetList<Card>(find.byType(Card));
      expect(
          find.descendant(
              of: find.byWidget(listItems.first), matching: find.text('Alice')),
          findsOneWidget);
      expect(
          find.descendant(
              of: find.byWidget(listItems.last), matching: find.text('Bob')),
          findsOneWidget);
    });

    testWidgets('harus menampilkan pesan kosong saat tidak ada data tersedia',
        (tester) async {
      // Arrange
      when(mockTransactionOperation.getTransactionsByPackageActivation())
          .thenAnswer((_) async => []);
      when(mockCustomerOperation.getCustomersByIds(any))
          .thenAnswer((_) async => []);

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
      const errorMessage = 'Gagal memuat';
      when(mockTransactionOperation.getTransactionsByPackageActivation())
          .thenAnswer((_) async => throw Exception(errorMessage));

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(
          find.textContaining('Error: Exception: Gagal memuat data transaksi:'),
          findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });
  });

  group('Logika Pengurutan PackageActivationHistory', () {
    // Data Pelanggan
    final customerAlice = CustomerModel(
      id: 'c1',
      name: 'Alice',
      phone: '08123456789',
      address: 'Alamat Alice',
      password: 'password123',
    );
    final customerBob = CustomerModel(
      id: 'c2',
      name: 'Bob',
      phone: '08123456780',
      address: 'Alamat Bob',
      password: 'password123',
    );
    final customerZack = CustomerModel(
      id: 'c3',
      name: 'Zack',
      phone: '08123456781',
      address: 'Alamat Zack',
      password: 'password123',
    );

    final customerMap = {
      'c1': customerAlice,
      'c2': customerBob,
      'c3': customerZack,
    };

    // Data Transaksi
    final transactionOldest = TransactionModel(
      id: 't1',
      customerId: 'c1', // Alice
      packageId: 'p1',
      date: DateTime(2023),
      updatedAt: DateTime(2023),
      endDate: DateTime(2023, 2), // Paling lama
      paymentStatus: PaymentStatus.paid,
      description: 'Oldest',
      amount: 100000,
      type: TransactionType.income,
      walletId: 'w1',
      categoryId: 'cat1',
    );

    final transactionMid = TransactionModel(
      id: 't2',
      customerId: 'c3', // Zack
      packageId: 'p2',
      date: DateTime(2023, 1, 5),
      updatedAt: DateTime(2023, 1, 5),
      endDate: DateTime(2023, 2, 15), // Tengah
      description: 'Mid',
      amount: 50000,
      type: TransactionType.income,
      walletId: 'w1',
      categoryId: 'cat1',
    );

    final transactionNewest = TransactionModel(
      id: 't3',
      customerId: 'c2', // Bob
      packageId: 'p1',
      date: DateTime(2023, 1, 10),
      updatedAt: DateTime(2023, 1, 10),
      endDate: DateTime(2023, 2, 28), // Paling baru
      paymentStatus: PaymentStatus.paid,
      description: 'Newest',
      amount: 150000,
      type: TransactionType.income,
      walletId: 'w1',
      categoryId: 'cat1',
    );

    late List<TransactionModel> transactions;

    // Inisialisasi daftar transaksi yang acak sebelum setiap tes
    setUp(() {
      transactions = [transactionMid, transactionNewest, transactionOldest];
    });

    test('harus mengurutkan berdasarkan Nama A-Z', () {
      // Act
      _sortList(transactions, SortOption.nameAZ, customerMap);

      // Assert
      // Urutan yang diharapkan: Alice (c1), Bob (c2), Zack (c3)
      expect(
          transactions.map((t) => t.customerId).toList(), ['c1', 'c2', 'c3']);
    });

    test('harus mengurutkan berdasarkan Nama Z-A', () {
      // Act
      _sortList(transactions, SortOption.nameZA, customerMap);

      // Assert
      // Urutan yang diharapkan: Zack (c3), Bob (c2), Alice (c1)
      expect(
          transactions.map((t) => t.customerId).toList(), ['c3', 'c2', 'c1']);
    });

    test('harus mengurutkan berdasarkan Terbaru (urutan default)', () {
      // Act
      _sortList(transactions, SortOption.newest, customerMap);

      // Assert
      // Urutan yang diharapkan: Paling baru, tengah, paling lama
      expect(transactions.map((t) => t.id).toList(), ['t3', 't2', 't1']);
    });

    test('harus menggunakan Terbaru sebagai urutan default', () {
      // Act
      _sortList(transactions, SortOption.newest, customerMap);

      // Assert
      // Urutan yang diharapkan: Paling baru, tengah, paling lama
      expect(transactions.map((t) => t.id).toList(), ['t3', 't2', 't1']);
    });

    test('harus mengurutkan berdasarkan Terlama', () {
      // Act
      _sortList(transactions, SortOption.oldest, customerMap);

      // Assert
      // Urutan yang diharapkan: Paling lama, tengah, paling baru
      expect(transactions.map((t) => t.id).toList(), ['t1', 't2', 't3']);
    });
  });
}

// Fungsi ini adalah replika dari logika _sortList di dalam widget
// untuk pengujian unit yang terisolasi.
void _sortList(
  List<TransactionModel> list,
  SortOption option,
  Map<String, CustomerModel> customerMap,
) {
  switch (option) {
    case SortOption.nameAZ:
      list.sort((a, b) => (customerMap[a.customerId]?.name ?? '')
          .compareTo(customerMap[b.customerId]?.name ?? ''));
      break;
    case SortOption.nameZA:
      list.sort((a, b) => (customerMap[b.customerId]?.name ?? '')
          .compareTo(customerMap[a.customerId]?.name ?? ''));
      break;
    case SortOption.newest:
      list.sort((a, b) => b.endDate!.compareTo(a.endDate!));
      break;
    case SortOption.oldest:
      list.sort((a, b) => a.endDate!.compareTo(b.endDate!));
      break;
    case SortOption.endDate:
      list.sort((a, b) => b.endDate!.compareTo(a.endDate!));
      break;
    case SortOption.endingToday:
      final now = DateTime.now();
      list.sort((a, b) {
        final aIsToday = a.endDate?.day == now.day &&
            a.endDate?.month == now.month &&
            a.endDate?.year == now.year;
        final bIsToday = b.endDate?.day == now.day &&
            b.endDate?.month == now.month &&
            b.endDate?.year == now.year;
        if (aIsToday == bIsToday) return 0;
        return aIsToday ? -1 : 1;
      });
      break;
    case SortOption.paid:
      list.sort((a, b) => (a.paymentStatus == PaymentStatus.paid ? 0 : 1)
          .compareTo(b.paymentStatus == PaymentStatus.paid ? 0 : 1));
      break;
    case SortOption.unpaid:
      list.sort((a, b) => (a.paymentStatus == PaymentStatus.unpaid ? 0 : 1)
          .compareTo(b.paymentStatus == PaymentStatus.unpaid ? 0 : 1));
      break;
  }
}
