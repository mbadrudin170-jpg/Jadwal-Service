
// path: test/shared/services/boot_service_test.dart
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/shared/enum/payment_status_enum.dart';
import 'package:wifi/shared/model/active_customer_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/active_customer_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/operasi_sqlite_provider/operasi_sqlite_provider.dart';
import 'package:wifi/shared/services/boot_service.dart';

import 'boot_service_test.mocks.dart';

@GenerateMocks([ActiveCustomerOperation])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BootService bootService;
  late MockActiveCustomerOperation mockActiveCustomerOperation;
  late ProviderContainer container;
  final List<MethodCall> log = <MethodCall>[];

  setUp(() {
    mockActiveCustomerOperation = MockActiveCustomerOperation();
    container = ProviderContainer(
      overrides: [
        activeCustomerOperationProvider
            .overrideWithValue(mockActiveCustomerOperation),
      ],
    );
    bootService = BootService();

    const channel =
        MethodChannel('dev.fluttercommunity.plus/android_alarm_manager');
    
    // Perbaikan: Menggunakan instance binding yang benar
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel,
        (MethodCall methodCall) async {
      log.add(methodCall);
      if (methodCall.method == 'oneShotAt') {
        return true;
      }
      return null;
    });

    log.clear();
  });

  group('BootService Tests', () {
    test('1. uji coba penjadwalan ulang saat tidak ada pelanggan aktif',
        () async {
      // Atur
      when(mockActiveCustomerOperation.getAllActiveCustomers())
          .thenAnswer((_) async => []);

      // Bertindak
      await bootService.rescheduleAlarmsOnBoot(container);

      // Memastikan
      verify(mockActiveCustomerOperation.getAllActiveCustomers()).called(1);
      expect(log, isEmpty);
    });

    test(
        '2. uji coba penjadwalan ulang dengan satu pelanggan aktif dan satu kedaluwarsa',
        () async {
      // Atur
      final now = DateTime.now();
      final activeCustomer = ActiveCustomerModel(
        id: '1',
        customerId: 'cust1',
        packageId: 'pkg1',
        startDate: now.subtract(const Duration(days: 1)),
        endDate: now.add(const Duration(days: 1)),
        status: PaymentStatus.paid,
      );
      final expiredCustomer = ActiveCustomerModel(
        id: '2',
        customerId: 'cust2',
        packageId: 'pkg2',
        startDate: now.subtract(const Duration(days: 2)),
        endDate: now.subtract(const Duration(days: 1)),
        status: PaymentStatus.paid,
      );
      when(mockActiveCustomerOperation.getAllActiveCustomers())
          .thenAnswer((_) async => [activeCustomer, expiredCustomer]);

      // Bertindak
      await bootService.rescheduleAlarmsOnBoot(container);

      // Memastikan
      verify(mockActiveCustomerOperation.getAllActiveCustomers()).called(1);
      expect(log.length, 2); // 1 cancel, 1 oneShotAt
      expect(log[0].method, 'cancel');
      final cancelArgs = log[0].arguments as Map;
      expect(cancelArgs['alarmId'], activeCustomer.id.hashCode);

      expect(log[1].method, 'oneShotAt');
       final oneShotArgs = log[1].arguments as Map;
      expect(oneShotArgs['alarmId'], activeCustomer.id.hashCode);
      expect(oneShotArgs['wakeup'], true);
      expect(oneShotArgs['exact'], true);
    });

    test('3. uji coba penanganan error saat mengambil data pelanggan', () async {
      // Atur
      when(mockActiveCustomerOperation.getAllActiveCustomers())
          .thenThrow(Exception('Database error'));

      // Bertindak
      await bootService.rescheduleAlarmsOnBoot(container);

      // Memastikan
      verify(mockActiveCustomerOperation.getAllActiveCustomers()).called(1);
      expect(log, isEmpty);
    });
  });
}
