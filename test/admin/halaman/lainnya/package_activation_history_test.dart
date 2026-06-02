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
      endDate: DateTime(2023, 1, 25), // Berakhir lebih dulu
      description: 'Aktivasi Paket B',
      type: TransactionType.income,
      amount: 50000,
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
      when(mockPackageOperation.getById(any))
          .thenAnswer((final invocation) async {
        final id = invocation.positionalArguments.first as String;
        if (id == 'p1') return p1;
        if (id == 'p2') return p2;
        return null;
      });

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert: Tampilkan indikator loading saat awal
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

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
          .thenAnswer((_) async => [t1, t2]); // t1 (Alice), t2 (Bob)
      when(mockCustomerOperation.getCustomersByIds(any))
          .thenAnswer((_) async => [c1, c2]);
      when(mockPackageOperation.getById(any))
          .thenAnswer((final invocation) async {
        final id = invocation.positionalArguments.first as String;
        if (id == 'p1') return p1;
        if (id == 'p2') return p2;
        return null;
      });

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert: Urutan awal berdasarkan tanggal berakhir (t2/Bob, lalu t1/Alice)
      var listItems = tester.widgetList<Card>(find.byType(Card));
      expect(listItems, isNotEmpty); // Pastikan list tidak kosong sebelum diakses
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
          find.textContaining('Error: Exception: Gagal memuat data transaksi'),
          findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });
  });

  group('Logika Pengurutan PackageActivationHistory', () {
    final customerAlice = CustomerModel(
        id: 'c1', name: 'Alice', phone: '', address: '', password: '');
    final customerBob = CustomerModel(
        id: 'c2', name: 'Bob', phone: '', address: '', password: '');
    final customerZack = CustomerModel(
        id: 'c3', name: 'Zack', phone: '', address: '', password: '');

    final customerMap = {
      'c1': customerAlice,
      'c2': customerBob,
      'c3': customerZack,
    };

    final transactionOldest = TransactionModel(
        id: 't1',
        customerId: 'c1',
        packageId: '',
        date: DateTime(2023),
        updatedAt: DateTime(2023),
        endDate: DateTime(2023, 2),
        paymentStatus: PaymentStatus.paid,
        description: '',
        amount: 0,
        type: TransactionType.income,
        walletId: '',
        categoryId: '');
    final transactionMid = TransactionModel(
        id: 't2',
        customerId: 'c3',
        packageId: '',
        date: DateTime(2023, 1, 5),
        updatedAt: DateTime(2023, 1, 5),
        endDate: DateTime(2023, 2, 15),
        description: '',
        type: TransactionType.income,
        paymentStatus: PaymentStatus.paid,
        amount: 0,
        walletId: '',
        categoryId: '');
    final transactionNewest = TransactionModel(
        id: 't3',
        customerId: 'c2',
        packageId: '',
        date: DateTime(2023, 1, 10),
        updatedAt: DateTime(2023, 1, 10),
        endDate: DateTime(2023, 2, 28),
        paymentStatus: PaymentStatus.paid,
        description: '',
        amount: 0,
        type: TransactionType.income,
        walletId: '',
        categoryId: '');

    late List<TransactionModel> transactions;

    setUp(() {
      transactions = [transactionMid, transactionNewest, transactionOldest];
    });

    test('harus mengurutkan berdasarkan Nama A-Z', () {
      _sortList(transactions, SortOption.nameAZ, customerMap);
      expect(
          transactions.map((t) => t.customerId).toList(), ['c1', 'c2', 'c3']);
    });

    test('harus mengurutkan berdasarkan Nama Z-A', () {
      _sortList(transactions, SortOption.nameZA, customerMap);
      expect(
          transactions.map((t) => t.customerId).toList(), ['c3', 'c2', 'c1']);
    });

    test('harus mengurutkan berdasarkan Terbaru (updatedAt)', () {
      _sortList(transactions, SortOption.newest, customerMap);
      expect(transactions.map((t) => t.id).toList(), ['t3', 't2', 't1']);
    });

    test('harus mengurutkan berdasarkan Terlama (updatedAt)', () {
      _sortList(transactions, SortOption.oldest, customerMap);
      expect(transactions.map((t) => t.id).toList(), ['t1', 't2', 't3']);
    });

    test('harus mengurutkan berdasarkan Tanggal Berakhir', () {
      _sortList(transactions, SortOption.endDate, customerMap);
      expect(transactions.map((t) => t.id).toList(), ['t1', 't2', 't3']);
    });
  });
}

// PERBAIKAN: Fungsi ini dikembalikan. Ini adalah replika dari logika sort di dalam state
// untuk pengujian unit yang terisolasi. Ini diperlukan karena state widget bersifat private.
void _sortList(
  List<TransactionModel> list,
  SortOption option,
  Map<String, CustomerModel> customerMap,
) {
  int Function(TransactionModel, TransactionModel) comparator;
  switch (option) {
    case SortOption.endDate:
      comparator = (final a, final b) {
        final dateA = a.endDate;
        final dateB = b.endDate;
        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;
        return dateA.compareTo(dateB);
      };
      break;
    case SortOption.nameAZ:
      comparator = (final a, final b) {
        final nameA = customerMap[a.customerId]?.name.toLowerCase() ?? '';
        final nameB = customerMap[b.customerId]?.name.toLowerCase() ?? '';
        return nameA.compareTo(nameB);
      };
      break;
    case SortOption.nameZA:
      comparator = (final a, final b) {
        final nameA = customerMap[a.customerId]?.name.toLowerCase() ?? '';
        final nameB = customerMap[b.customerId]?.name.toLowerCase() ?? '';
        return nameB.compareTo(nameA);
      };
      break;
    case SortOption.newest:
      comparator = (final a, final b) =>
          (b.updatedAt ?? b.date).compareTo(a.updatedAt ?? a.date);
      break;
    case SortOption.oldest:
      comparator = (final a, final b) =>
          (a.updatedAt ?? a.date).compareTo(b.updatedAt ?? b.date);
      break;
    case SortOption.paid:
      comparator = (final a, final b) {
        final isPaidA = a.paymentStatus == PaymentStatus.paid;
        final isPaidB = b.paymentStatus == PaymentStatus.paid;
        if (isPaidA == isPaidB) return 0;
        return isPaidA ? -1 : 1;
      };
      break;
    case SortOption.unpaid:
      comparator = (final a, final b) {
        final isPaidA = a.paymentStatus == PaymentStatus.paid;
        final isPaidB = b.paymentStatus == PaymentStatus.paid;
        if (isPaidA == isPaidB) return 0;
        return isPaidA ? 1 : -1;
      };
      break;
    case SortOption.endingToday:
      comparator = (final a, final b) {
        final now = DateTime.now();
        bool isToday(final DateTime? date) {
          if (date == null) return false;
          return date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;
        }

        final aIsToday = isToday(a.endDate);
        final bIsToday = isToday(b.endDate);
        if (aIsToday == bIsToday) return 0;
        return aIsToday ? -1 : 1;
      };
      break;
  }
  list.sort(comparator);
}
