// path: test/admin/halaman/lainnya/package_activation_history_widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart'; // Menggunakan mockito sesuai context
import 'package:wifi/admin/halaman/lainnya/package_activation_history.dart';
import 'package:wifi/shared/enum/payment_status_enum.dart';
import 'package:wifi/shared/enum/transaction_type_enum.dart';
import 'package:wifi/shared/model/customer_model.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/operasi/customer_operation.dart';
import 'package:wifi/shared/operasi/package_operation.dart';
import 'package:wifi/shared/operasi/transaction_operation.dart';

// --- MOCKS ---
class MockTransactionOperation extends Mock implements TransactionOperation {}

class MockPackageOperation extends Mock implements PackageOperation {}

class MockCustomerOperation extends Mock implements CustomerOperation {}

// Helper untuk Unit Test Logika Pengurutan
void sortTransactionList({
  required List<TransactionModel> list,
  required SortOption option,
  required Map<String, CustomerModel> customerMap,
}) {
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

void main() {
  // Data Dummy Bersama
  final now = DateTime.now();
  final customer = CustomerModel(
    id: 'c1',
    name: 'Budi Utomo',
    phone: '08123',
    address: 'Alamat Test',
    password: '123',
  );

  final tPaid = TransactionModel(
    id: 't1',
    customerId: 'c1',
    date: now,
    endDate: now,
    paymentStatus: PaymentStatus.paid,
    description: 'Lunas',
    amount: 50000,
    type: TransactionType.income,
    walletId: 'w1',
    categoryId: 'cat1',
  );

  final Map<String, CustomerModel> customerMap = {'c1': customer};

  // State untuk Widget Test
  late MockTransactionOperation mockTransactionOp;
  late MockPackageOperation mockPackageOp;
  late MockCustomerOperation mockCustomerOp;

  setUp(() {
    mockTransactionOp = MockTransactionOperation();
    mockPackageOp = MockPackageOperation();
    mockCustomerOp = MockCustomerOperation();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        transactionOperationProvider.overrideWithValue(mockTransactionOp),
        packageOperationProvider.overrideWithValue(mockPackageOp),
        customerOperationProvider.overrideWithValue(mockCustomerOp),
      ],
      child: const MaterialApp(
        home: PackageActivationHistoryPage(),
      ),
    );
  }

  group('1. Unit Test: Logika Pengurutan', () {
    test('Harus mengutamakan status Paid jika opsi SortOption.paid dipilih',
        () {
      final tUnpaid =
          tPaid.copyWith(id: 't2', paymentStatus: PaymentStatus.unpaid);
      final list = [tUnpaid, tPaid];

      sortTransactionList(
          list: list, option: SortOption.paid, customerMap: customerMap);

      expect(list[0].paymentStatus, PaymentStatus.paid);
    });

    test('Harus meletakkan transaksi yang berakhir hari ini di posisi teratas',
        () {
      final tFuture = tPaid.copyWith(
          id: 'tFuture', endDate: now.add(const Duration(days: 5)));
      final tToday = tPaid.copyWith(id: 'tToday', endDate: now);
      final list = [tFuture, tToday];

      sortTransactionList(
          list: list, option: SortOption.endingToday, customerMap: customerMap);

      expect(list[0].id, 'tToday');
    });

    test('Harus mengurutkan berdasarkan Nama Pelanggan (A-Z)', () {
      final custA = CustomerModel(id: 'a', name: 'Agus', phone: '1', address: '1', password: '1');
      final custB = CustomerModel(id: 'b', name: 'Zaki', phone: '2', address: '2', password: '2');
      final tA = tPaid.copyWith(id: 'ta', customerId: 'a');
      final tB = tPaid.copyWith(id: 'tb', customerId: 'b');
      final list = [tB, tA];
      final map = {'a': custA, 'b': custB};

      sortTransactionList(list: list, option: SortOption.nameAZ, customerMap: map);
      expect(list[0].customerId, 'a');
    });

    test('Harus mengurutkan berdasarkan Tanggal Berakhir (Terdekat)', () {
      final tSoon = tPaid.copyWith(id: 'soon', endDate: now.add(const Duration(days: 1)));
      final tLater = tPaid.copyWith(id: 'later', endDate: now.add(const Duration(days: 10)));
      final tNull = tPaid.copyWith(id: 'null', endDate: null);
      final list = [tNull, tLater, tSoon];

      sortTransactionList(list: list, option: SortOption.endDate, customerMap: customerMap);
      expect(list[0].id, 'soon');
      expect(list[1].id, 'later');
      expect(list[2].id, 'null');
    });
  });

  group('2. Widget Test: Tampilan & Loading', () {
    testWidgets(
        'Harus menampilkan data pelanggan dan status setelah loading selesai',
        (WidgetTester tester) async {
      // Atur perilaku mock (Sesuai syntax Mockito)
      when(mockTransactionOp.getTransactionsByPackageActivation())
          .thenAnswer((_) async => [tPaid]);
      when(mockCustomerOp.getCustomersByIds(any))
          .thenAnswer((_) async => [customer]);
      when(mockPackageOp.getById(any)).thenAnswer((_) async => null);

      await tester.pumpWidget(createWidgetUnderTest());

      // Cek loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      // Cek apakah nama pelanggan muncul
      expect(find.text('Budi Utomo'), findsOneWidget);
      // Cek status lunas
      expect(find.textContaining('Lunas'), findsOneWidget);

      // Verifikasi interaksi mock
      verify(mockTransactionOp.getTransactionsByPackageActivation()).called(1);
      verify(mockCustomerOp.getCustomersByIds(any)).called(1);
    });

    testWidgets('Harus menampilkan pesan jika data kosong',
        (WidgetTester tester) async {
      when(mockTransactionOp.getTransactionsByPackageActivation())
          .thenAnswer((_) async => []);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(
          find.text('Tidak ada riwayat langganan ditemukan.'), findsOneWidget);
    });
  });
}
