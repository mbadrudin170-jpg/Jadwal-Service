// path: test/admin/providers/package_activation_history_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/admin/providers/package_activation_history_provider.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/customer_operation.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/transaction_operation.dart';

import 'package_activation_history_provider_test.mocks.dart';

@GenerateMocks([TransaksiOpsqlite, PelangganOpSqlite])
void main() {
  // 1. Definisikan data dummy yang valid
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day, now.hour, now.minute);
  final yesterday = today.subtract(const Duration(days: 1));
  final tomorrow = today.add(const Duration(days: 1));

  // Customer dummies
  final c1 = PelangganModel(
      id: 'c1', name: 'Charlie', phone: '', address: '', password: '');
  final c2 = PelangganModel(
      id: 'c2', name: 'Alpha', phone: '', address: '', password: '');
  final c3 = PelangganModel(
      id: 'c3', name: 'Bravo', phone: '', address: '', password: '');

  // Transaction dummies
  final t1 = TransaksiModel(
      id: '1',
      customerId: 'c1',
      date: yesterday,
      endDate: today,
      paymentStatus: PaymentStatus.paid,
      description: '',
      amount: 0,
      type: TransactionType.income,
      walletId: '',
      categoryId: '',
      updatedAt: today);
  final t2 = TransaksiModel(
    id: '2',
    customerId: 'c2',
    date: today,
    endDate: tomorrow,
    description: '',
    amount: 0,
    type: TransactionType.income,
    walletId: '',
    categoryId: '',
    updatedAt: tomorrow,
  );
  final t3 = TransaksiModel(
    id: '3',
    customerId: 'c3',
    date: yesterday.subtract(const Duration(days: 1)),
    endDate: yesterday,
    paymentStatus: PaymentStatus.paid,
    description: '',
    amount: 0,
    type: TransactionType.income,
    walletId: '',
    categoryId: '',
    updatedAt: yesterday,
  );
  // Transaksi tanpa customerId yang cocok untuk menguji kasus 'Tidak diketahui'
  final t4 = TransaksiModel(
    id: '4',
    customerId: 'c4-nonexistent',
    date: today.subtract(const Duration(days: 2)),
    description: '',
    amount: 0,
    type: TransactionType.income,
    walletId: '',
    categoryId: '',
    // Waktu sama, menit berbeda
    updatedAt: today.add(const Duration(minutes: 1)),
  );

  final mockTransactions = [t1, t2, t3, t4];
  final mockCustomers = [c1, c2, c3];

  // 2. Buat mock untuk semua dependensi
  late MockTransactionOperation mockTransactionOperation;
  late MockCustomerOperation mockCustomerOperation;
  late ProviderContainer container;

  // 3. Atur setup untuk setiap test
  setUp(() {
    mockTransactionOperation = MockTransactionOperation();
    mockCustomerOperation = MockCustomerOperation();

    container = ProviderContainer(
      overrides: [
        transactionOperationProvider
            .overrideWithValue(mockTransactionOperation),
        customerOperationProvider.overrideWithValue(mockCustomerOperation),
      ],
    );

    // Atur mock untuk mengembalikan data dummy
    when(mockTransactionOperation.getTransactionsByPackageActivation())
        .thenAnswer((_) async => List.from(mockTransactions));
    when(mockCustomerOperation.getAll())
        .thenAnswer((_) async => List.from(mockCustomers));
  });

  tearDown(() {
    container.dispose();
  });

  group('PackageActivationHistory Provider Sorting Tests', () {
    test('1. endDate harus mengurutkan list berdasarkan endDate descending',
        () async {
      // Tunggu provider untuk inisialisasi
      final state =
          await container.read(packageActivationHistoryProvider.future);

      // Verifikasi urutan default adalah berdasarkan endDate descending (null di akhir)
      expect(state.items.map((item) => item.transaction.id).toList(),
          ['2', '1', '3', '4']);
      expect(state.sortBy, SortOption.endDate);
    });

    test('2. nameAZ harus mengurutkan list berdasarkan nama A-Z', () async {
      // Inisialisasi dulu
      await container.read(packageActivationHistoryProvider.future);

      // Panggil changeSort
      container
          .read(packageActivationHistoryProvider.notifier)
          .changeSort(SortOption.nameAZ);

      final state = container.read(packageActivationHistoryProvider).value!;

      // Verifikasi urutan berdasarkan nama A-Z, customer tidak diketahui paling akhir
      expect(state.items.map((item) => item.customerName).toList(),
          ['Alpha', 'Bravo', 'Charlie', 'Tidak diketahui']);
      expect(state.sortBy, SortOption.nameAZ);
    });

    test('3. namaZA harus mengurutkan list berdasarkan nama Z-A', () async {
      await container.read(packageActivationHistoryProvider.future);
      container
          .read(packageActivationHistoryProvider.notifier)
          .changeSort(SortOption.nameZA);

      final state = container.read(packageActivationHistoryProvider).value!;

      // Verifikasi urutan berdasarkan nama Z-A
      expect(state.items.map((item) => item.customerName).toList(),
          ['Tidak diketahui', 'Charlie', 'Bravo', 'Alpha']);
      expect(state.sortBy, SortOption.nameZA);
    });

    test(
        '4. newest harus mengurutkan list updateAt yang terbaru ke yang terlama',
        () async {
      await container.read(packageActivationHistoryProvider.future);
      container
          .read(packageActivationHistoryProvider.notifier)
          .changeSort(SortOption.updatedAtAZ);

      final state = container.read(packageActivationHistoryProvider).value!;

      // Verifikasi urutan berdasarkan tanggal terbaru: t2, t4, t1, t3
      expect(state.items.map((item) => item.transaction.id).toList(),
          ['2', '4', '1', '3']);
      expect(state.sortBy, SortOption.updatedAtAZ);
    });

    test(
        '5. oldest harus mengurutkan list updateAt yang terlama ke yang terbaru',
        () async {
      await container.read(packageActivationHistoryProvider.future);
      container
          .read(packageActivationHistoryProvider.notifier)
          .changeSort(SortOption.updatedAtZA);

      final state = container.read(packageActivationHistoryProvider).value!;

      // Verifikasi urutan berdasarkan tanggal terlama: t3, t1, t4, t2
      expect(state.items.map((item) => item.transaction.id).toList(),
          ['3', '1', '4', '2']);
      expect(state.sortBy, SortOption.updatedAtZA);
    });

    test(
        '6. endingToday harus mengurutkan list yang berakhir hari ini ke paling lama',
        () async {
      await container.read(packageActivationHistoryProvider.future);
      container
          .read(packageActivationHistoryProvider.notifier)
          .changeSort(SortOption.endingToday);

      final state = container.read(packageActivationHistoryProvider).value!;

      // Verifikasi: t1 (berakhir hari ini) harus di paling atas
      expect(state.items.first.transaction.id, '1');
      expect(state.sortBy, SortOption.endingToday);
    });

    test('7. paid harus mengurutkan list dari yang lunas ke yang belum lunas',
        () async {
      await container.read(packageActivationHistoryProvider.future);
      container
          .read(packageActivationHistoryProvider.notifier)
          .changeSort(SortOption.paid);

      final state = container.read(packageActivationHistoryProvider).value!;

      // Verifikasi: yang lunas (t1, t3) di atas, diurutkan berdasarkan tanggal terbaru
      final ids = state.items.map((item) => item.transaction.id).toList();
      expect(ids, ['1', '3', '2', '4']);
      expect(state.items[0].transaction.paymentStatus, PaymentStatus.paid);
      expect(state.items[1].transaction.paymentStatus, PaymentStatus.paid);
      expect(state.sortBy, SortOption.paid);
    });

    test('8. unpaid harus mengurutkan list dari yang belum lunas ke yang lunas',
        () async {
      await container.read(packageActivationHistoryProvider.future);
      container
          .read(packageActivationHistoryProvider.notifier)
          .changeSort(SortOption.unpaid);

      final state = container.read(packageActivationHistoryProvider).value!;

      // Verifikasi: yang belum lunas (t2, t4) di atas, diurutkan berdasarkan tanggal terbaru
      final ids = state.items.map((item) => item.transaction.id).toList();
      expect(ids, ['2', '4', '1', '3']);
      expect(state.items[0].transaction.paymentStatus, PaymentStatus.unpaid);
      expect(state.items[1].transaction.paymentStatus, PaymentStatus.unpaid);
      expect(state.items[2].transaction.paymentStatus, PaymentStatus.paid);
      expect(state.items[3].transaction.paymentStatus, PaymentStatus.paid);

      expect(state.sortBy, SortOption.unpaid);
    });
  });
}
