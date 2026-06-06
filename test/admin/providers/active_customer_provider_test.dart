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

// 1. Menggunakan GenerateNiceMocks untuk menghindari MissingStubError
@GenerateNiceMocks([MockSpec<ActiveCustomerOperation>()])
void main() {
  // 2. Inisialisasi binding untuk Flutter test
  TestWidgetsFlutterBinding.ensureInitialized();

  // 3. Deklarasi variabel
  late MockActiveCustomerOperation mockActiveCustomerOperation;
  late ProviderContainer container;

  // 4. Data dummy untuk pengujian
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final tomorrow = today.add(const Duration(days: 1));

  final customer1 = CustomerModel(
    id: 'cust1',
    name: 'Budi',
    address: 'Jl. A',
    phone: '123',
    password: 'password',
    updatedAt: now,
  );
  final customer2 = CustomerModel(
    id: 'cust2',
    name: 'Andi',
    address: 'Jl. B',
    phone: '456',
    password: 'password',
    updatedAt: now,
  );
  final customer3 = CustomerModel(
    id: 'cust3',
    name: 'Cici',
    address: 'Jl. C',
    phone: '789',
    password: 'password',
    updatedAt: now,
  );

  final package1 = PackageModel(
      id: 'pkg1',
      name: 'Paket 1',
      price: 100000,
      duration: 30,
      type: DurationType.days,
      updatedAt: now);

  final activeCust1 = ActiveCustomerDetailModel(
    activeCustomer: ActiveCustomerModel(
      id: 'ac1',
      customerId: 'cust1',
      packageId: 'pkg1',
      startDate: yesterday,
      endDate: today,
      status: PaymentStatus.unpaid,
      updatedAt: now,
    ),
    customerName: customer1.name,
    packageName: package1.name,
  );

  final activeCust2 = ActiveCustomerDetailModel(
    activeCustomer: ActiveCustomerModel(
      id: 'ac2',
      customerId: 'cust2',
      packageId: 'pkg1',
      startDate: today,
      endDate: tomorrow,
      status: PaymentStatus.paid,
      updatedAt: now,
    ),
    customerName: customer2.name,
    packageName: package1.name,
  );

  final activeCust3 = ActiveCustomerDetailModel(
    activeCustomer: ActiveCustomerModel(
      id: 'ac3',
      customerId: 'cust3',
      packageId: 'pkg1',
      startDate: yesterday.subtract(const Duration(days: 1)),
      endDate: yesterday,
      status: PaymentStatus.paid,
      updatedAt: now,
    ),
    customerName: customer3.name,
    packageName: package1.name,
  );

  final mockList = [activeCust1, activeCust2, activeCust3];

  // 5. Fungsi setUp untuk inisialisasi sebelum setiap tes
  setUp(() {
    mockActiveCustomerOperation = MockActiveCustomerOperation();
    container = ProviderContainer(
      overrides: [
        activeCustomerOperationProvider
            .overrideWithValue(mockActiveCustomerOperation),
      ],
    );
  });

  // 6. Fungsi tearDown untuk membersihkan setelah setiap tes
  tearDown(() {
    container.dispose();
  });

  group('Uji ActiveCustomer Provider', () {
    test('1. fetchActiveCustomers harus memperbarui state dengan data yang diurutkan',
        () async {
      // Atur stub untuk metode yang akan dipanggil
      when(mockActiveCustomerOperation.getAllActiveCustomersWithDetails())
          .thenAnswer((_) async => mockList);

      // Baca provider, ini akan memicu panggilan fetch otomatis di build()
      container.read(activeCustomerProvider);

      // Tunggu hingga microtask (termasuk fetch) selesai dieksekusi
      await pumpEventQueue();

      final state = container.read(activeCustomerProvider);

      expect(state.activeCustomers.length, 3);
      expect(state.activeCustomers[0].activeCustomer.id, 'ac1');
      expect(state.activeCustomers[1].activeCustomer.id, 'ac3');
      expect(state.activeCustomers[2].activeCustomer.id, 'ac2');
    });

    test('2. fetchActiveCustomers harus menangani error dengan benar', () async {
      final exception = Exception('Gagal memuat');
      when(mockActiveCustomerOperation.getAllActiveCustomersWithDetails())
          .thenThrow(exception);

      // Baca provider untuk memicu fetch
      container.read(activeCustomerProvider);

      // Tunggu hingga microtask selesai
      await pumpEventQueue();

      final state = container.read(activeCustomerProvider);

      expect(state.activeCustomers.isEmpty, isTrue);
    });

    // Menjadikan test async untuk menunggu auto-fetch awal selesai
    test('3. setSortBy harus mengurutkan ulang data yang ada', () async {
      // Tunggu fetch otomatis (dari NiceMock, hasilkan list kosong)
      await pumpEventQueue();

      // Atur state secara manual untuk pengujian
      container.read(activeCustomerProvider.notifier).state =
          ActiveCustomerState(activeCustomers: mockList);

      container
          .read(activeCustomerProvider.notifier)
          .setSortBy(SortOption.namaAZ);

      final state = container.read(activeCustomerProvider);

      expect(state.sortBy, SortOption.namaAZ);
      expect(state.activeCustomers[0].customerName, 'Andi');
      expect(state.activeCustomers[1].customerName, 'Budi');
      expect(state.activeCustomers[2].customerName, 'Cici');
    });

    test('4. setSortBy tidak melakukan apa-apa jika opsi sama', () async {
      await pumpEventQueue();

      final initialState = ActiveCustomerState(
        activeCustomers: mockList,
        sortBy: SortOption.namaAZ,
      );
      container.read(activeCustomerProvider.notifier).state = initialState;

      container
          .read(activeCustomerProvider.notifier)
          .setSortBy(SortOption.namaAZ);

      final state = container.read(activeCustomerProvider);

      // Verifikasi instance state tidak berubah
      expect(identical(state, initialState), isTrue);
    });

    group('Pengujian Logika Pengurutan melalui setSortBy', () {
      // Atur state awal untuk setiap tes di dalam grup ini
      setUp(() {
        container.read(activeCustomerProvider.notifier).state =
            ActiveCustomerState(activeCustomers: mockList);
      });

      test('5. Urutkan berdasarkan namaZA', () {
        container
            .read(activeCustomerProvider.notifier)
            .setSortBy(SortOption.namaZA);
        final state = container.read(activeCustomerProvider);
        expect(state.activeCustomers[0].customerName, 'Cici');
        expect(state.activeCustomers[1].customerName, 'Budi');
        expect(state.activeCustomers[2].customerName, 'Andi');
      });

      test('6. Urutkan berdasarkan lunas', () {
        container
            .read(activeCustomerProvider.notifier)
            .setSortBy(SortOption.lunas);
        final state = container.read(activeCustomerProvider);
        expect(
            state.activeCustomers[0].activeCustomer.status, PaymentStatus.paid);
        expect(
            state.activeCustomers[1].activeCustomer.status, PaymentStatus.paid);
        expect(state.activeCustomers[2].activeCustomer.status,
            PaymentStatus.unpaid);
      });

      test('7. Urutkan berdasarkan belumLunas', () {
        container
            .read(activeCustomerProvider.notifier)
            .setSortBy(SortOption.belumLunas);
        final state = container.read(activeCustomerProvider);
        expect(state.activeCustomers[0].activeCustomer.status,
            PaymentStatus.unpaid);
        expect(
            state.activeCustomers[1].activeCustomer.status, PaymentStatus.paid);
        expect(
            state.activeCustomers[2].activeCustomer.status, PaymentStatus.paid);
      });

      test('8. Urutkan berdasarkan tanggalBerakhir (terbaru ke terlama)', () {
        container
            .read(activeCustomerProvider.notifier)
            .setSortBy(SortOption.tanggalBerakhir);
        final state = container.read(activeCustomerProvider);
        expect(state.activeCustomers[0].activeCustomer.endDate, tomorrow);
        expect(state.activeCustomers[1].activeCustomer.endDate, today);
        expect(state.activeCustomers[2].activeCustomer.endDate, yesterday);
      });
    });
  });
}
