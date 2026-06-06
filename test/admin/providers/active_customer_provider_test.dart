// path: test/admin/providers/active_customer_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/admin/providers/active_customer_provider.dart';
import 'package:wifi/shared/enum/duration_type_enum.dart';
import 'package:wifi/shared/enum/payment_status_enum.dart';
import 'package:wifi/shared/model/active_customer_detail_model.dart';
import 'package:wifi/shared/model/active_customer_model.dart';
import 'package:wifi/shared/model/customer_model.dart';
import 'package:wifi/shared/model/package_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/active_customer_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/operasi_sqlite_provider/operasi_sqlite_provider.dart';

import 'active_customer_provider_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ActiveCustomerOperation>()])

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockActiveCustomerOperation mockActiveCustomerOperation;
  late ProviderContainer container;

  // ✅ Gunakan waktu real saat test berjalan (bukan hardcoded 2024)
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final tomorrow = today.add(const Duration(days: 1));
  final twoDaysAgo = today.subtract(const Duration(days: 2));

  // Data pelanggan (tidak berubah, hanya updatedAt pakai now)
  final customer1 = CustomerModel(
      id: 'cust1',
      name: 'Budi',
      address: '-',
      phone: '-',
      password: '-',
      updatedAt: now);
  final customer2 = CustomerModel(
      id: 'cust2',
      name: 'Andi',
      address: '-',
      phone: '-',
      password: '-',
      updatedAt: now);
  final customer3 = CustomerModel(
      id: 'cust3',
      name: 'Cici',
      address: '-',
      phone: '-',
      password: '-',
      updatedAt: now);

  final package1 = PackageModel(
      id: 'pkg1',
      name: 'Paket 1',
      price: 100000,
      duration: 30,
      type: DurationType.days,
      updatedAt: now);

  // Pelanggan aktif dengan endDate relatif terhadap today
  final activeCust1 = ActiveCustomerDetailModel(
    activeCustomer: ActiveCustomerModel(
        id: 'ac1',
        customerId: 'cust1',
        packageId: 'pkg1',
        startDate: twoDaysAgo,
        endDate: today, // berakhir hari ini
        status: PaymentStatus.unpaid,
        updatedAt: now.subtract(const Duration(hours: 2))),
    customerName: customer1.name,
    packageName: package1.name,
  );

  final activeCust2 = ActiveCustomerDetailModel(
    activeCustomer: ActiveCustomerModel(
        id: 'ac2',
        customerId: 'cust2',
        packageId: 'pkg1',
        startDate: yesterday,
        endDate: tomorrow, // berakhir besok
        status: PaymentStatus.paid,
        updatedAt: now.subtract(const Duration(hours: 1))),
    customerName: customer2.name,
    packageName: package1.name,
  );

  final activeCust3 = ActiveCustomerDetailModel(
    activeCustomer: ActiveCustomerModel(
        id: 'ac3',
        customerId: 'cust3',
        packageId: 'pkg1',
        startDate: today,
        endDate: tomorrow.add(const Duration(days: 1)), // berakhir lusa
        status: PaymentStatus.paid,
        updatedAt: now),
    customerName: customer3.name,
    packageName: package1.name,
  );

  final mockList = [activeCust1, activeCust2, activeCust3];


  setUp(() {
    mockActiveCustomerOperation = MockActiveCustomerOperation();
    container = ProviderContainer(
      overrides: [
        activeCustomerOperationProvider
            .overrideWithValue(mockActiveCustomerOperation),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('Uji ActiveCustomer Provider', () {
    test('1. fetchActiveCustomers harus memuat dan mengurutkan data awal',
        () async {
      when(mockActiveCustomerOperation.getAllActiveCustomersWithDetails())
          .thenAnswer((_) async => mockList);

      await container
          .read(activeCustomerProvider.notifier)
          .fetchActiveCustomers();

      final state = container.read(activeCustomerProvider);

      expect(state.activeCustomers.length, 3);
      // Urutan default adalah `berakhirHariIni`
      expect(state.activeCustomers.map((e) => e.activeCustomer.id).toList(),
          ['ac1', 'ac2', 'ac3']);
    });

    test('2. fetchActiveCustomers harus menangani error', () async {
      when(mockActiveCustomerOperation.getAllActiveCustomersWithDetails())
          .thenThrow(Exception('Error'));

      await container
          .read(activeCustomerProvider.notifier)
          .fetchActiveCustomers();

      final state = container.read(activeCustomerProvider);
      expect(state.activeCustomers.isEmpty, isTrue);
    });

    group('Pengujian Logika Pengurutan melalui setSortBy', () {
      setUp(() {
        container.read(activeCustomerProvider.notifier).state =
            ActiveCustomerState(activeCustomers: mockList);
      });

      test('3. Urutkan berdasarkan namaAZ', () {
        container
            .read(activeCustomerProvider.notifier)
            .setSortBy(SortOption.namaAZ);
        final state = container.read(activeCustomerProvider);
        expect(state.activeCustomers.map((e) => e.customerName).toList(),
            ['Andi', 'Budi', 'Cici']);
      });

      test('4. Urutkan berdasarkan namaZA', () {
        container
            .read(activeCustomerProvider.notifier)
            .setSortBy(SortOption.namaZA);
        final state = container.read(activeCustomerProvider);
        expect(state.activeCustomers.map((e) => e.customerName).toList(),
            ['Cici', 'Budi', 'Andi']);
      });

      test('5. Urutkan berdasarkan lunas', () {
        container
            .read(activeCustomerProvider.notifier)
            .setSortBy(SortOption.lunas);
        final state = container.read(activeCustomerProvider);
        expect(
            state.activeCustomers.map((e) => e.activeCustomer.status).toList(),
            [PaymentStatus.paid, PaymentStatus.paid, PaymentStatus.unpaid]);
      });

      test('6. Urutkan berdasarkan belumLunas', () {
        container
            .read(activeCustomerProvider.notifier)
            .setSortBy(SortOption.belumLunas);
        final state = container.read(activeCustomerProvider);
        expect(
            state.activeCustomers.map((e) => e.activeCustomer.status).toList(),
            [PaymentStatus.unpaid, PaymentStatus.paid, PaymentStatus.paid]);
      });

      test('7. Urutkan berdasarkan tanggalBerakhir (terbaru ke terlama)', () {
        container
            .read(activeCustomerProvider.notifier)
            .setSortBy(SortOption.tanggalBerakhir);
        final state = container.read(activeCustomerProvider);
        expect(state.activeCustomers.map((e) => e.activeCustomer.id).toList(),
            ['ac3', 'ac2', 'ac1']);
      });

      // Tes baru yang diminta
      test('8. Urutkan berdasarkan terbaru (updatedAt descending)', () {
        container
            .read(activeCustomerProvider.notifier)
            .setSortBy(SortOption.terbaru);
        final state = container.read(activeCustomerProvider);
        // Harusnya: ac3 (paling baru) -> ac2 -> ac1 (paling lama diupdate)
        expect(state.activeCustomers.map((e) => e.activeCustomer.id).toList(),
            ['ac3', 'ac2', 'ac1']);
      });

      test('9. Urutkan berdasarkan terlama (updatedAt ascending)', () {
        container
            .read(activeCustomerProvider.notifier)
            .setSortBy(SortOption.terlama);
        final state = container.read(activeCustomerProvider);
        // Harusnya: ac1 (paling lama diupdate) -> ac2 -> ac3 (paling baru)
        expect(state.activeCustomers.map((e) => e.activeCustomer.id).toList(),
            ['ac1', 'ac2', 'ac3']);
      });

      test('10. Urutkan berdasarkan tanggalMulai (startDate ascending)', () {
        container
            .read(activeCustomerProvider.notifier)
            .setSortBy(SortOption.tanggalMulai);
        final state = container.read(activeCustomerProvider);
        // Harusnya: ac1 (mulai 2 hari lalu) -> ac2 (mulai kemarin) -> ac3 (mulai hari ini)
        expect(state.activeCustomers.map((e) => e.activeCustomer.id).toList(),
            ['ac1', 'ac2', 'ac3']);
      });
    });
  });
}
