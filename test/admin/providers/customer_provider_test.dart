
// path: test/admin/providers/customer_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/admin/providers/customer_provider.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/admin/providers/customer_provider.g.dart';

import 'customer_provider_test.mocks.dart';

@GenerateMocks([PelangganOpFirebase])
void main() {
  group('CustomerNotifier', () {
    late CustomerNotifier notifier;
    late MockPelangganOpFirebase mockPelangganOpFirebase;
    late ProviderContainer container;

    setUp(() {
      mockPelangganOpFirebase = MockPelangganOpFirebase();
      container = ProviderContainer(
        overrides: [
          pelangganOpFirebaseProvider
              .overrideWithValue(mockPelangganOpFirebase),
        ],
      );
      notifier = container.read(customerNotifierProvider.notifier);
    });

    test('01. initial state is loading and then returns data', () async {
      final customers = [
        const PelangganModel(
            id: '1',
            nama: 'Customer 1',
            alamat: '',
            telepon: '',
            macAddress: '',
            kataSandi: ''),
      ];
      when(mockPelangganOpFirebase.ambilSemuaPelanggan())
          .thenAnswer((_) async => customers);

      // Initially, the state should be loading
      expect(
        container.read(customerNotifierProvider),
        const AsyncValue<List<PelangganModel>>.loading(),
      );

      // Wait for the build method to complete
      await container.read(customerNotifierProvider.future);

      // After build, the state should be data
      expect(
        container.read(customerNotifierProvider).value,
        customers,
      );
    });

    test('02. search filters customers', () async {
      final allCustomers = [
        const PelangganModel(
            id: '1',
            nama: 'Alice',
            alamat: '',
            telepon: '',
            macAddress: '',
            kataSandi: ''),
        const PelangganModel(
            id: '2',
            nama: 'Bob',
            alamat: '',
            telepon: '',
            macAddress: '',
            kataSandi: ''),
      ];
      when(mockPelangganOpFirebase.ambilSemuaPelanggan())
          .thenAnswer((_) async => allCustomers);

      await container.read(customerNotifierProvider.future);

      await notifier.search('ali');

      expect(container.read(customerNotifierProvider).value?.length, 1);
      expect(container.read(customerNotifierProvider).value?.first.nama, 'Alice');
    });

    test('03. search with empty query returns all customers', () async {
      final allCustomers = [
        const PelangganModel(
            id: '1',
            nama: 'Alice',
            alamat: '',
            telepon: '',
            macAddress: '',
            kataSandi: ''),
        const PelangganModel(
            id: '2',
            nama: 'Bob',
            alamat: '',
            telepon: '',
            macAddress: '',
            kataSandi: ''),
      ];
      when(mockPelangganOpFirebase.ambilSemuaPelanggan())
          .thenAnswer((_) async => allCustomers);

      await container.read(customerNotifierProvider.future);

      await notifier.search('');

      expect(container.read(customerNotifierProvider).value?.length, 2);
    });
  });
}
