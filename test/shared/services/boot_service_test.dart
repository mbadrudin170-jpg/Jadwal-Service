// path: test/shared/services/boot_service_test.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/model/active_customer_detail_model.dart';
import 'package:wifi/shared/model/active_customer_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/active_customer_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/operasi_sqlite_provider/operasi_sqlite_provider.dart';
import 'package:wifi/shared/services/alarm/alarm_scheduler.dart';
import 'package:wifi/shared/services/alarm/alarm_scheduler_provider.dart';
import 'package:wifi/shared/services/background_service.dart';
import 'package:wifi/shared/services/boot_service.dart';

import 'boot_service_test.mocks.dart';

@GenerateMocks([AlarmScheduler, ActiveCustomerOperation])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BootService bootService;
  late MockAlarmScheduler mockAlarmScheduler;
  late MockActiveCustomerOperation mockActiveCustomerOperation;
  late ProviderContainer container;

  setUp(() {
    mockAlarmScheduler = MockAlarmScheduler();
    mockActiveCustomerOperation = MockActiveCustomerOperation();

    container = ProviderContainer(
      overrides: [
        alarmSchedulerProvider.overrideWithValue(mockAlarmScheduler),
        activeCustomerOperationProvider
            .overrideWithValue(mockActiveCustomerOperation),
      ],
    );
    bootService = BootService();

    // Default behavior for mocks
    when(mockAlarmScheduler.schedulePeriodic(
      any,
      any,
      any,
      startAt: anyNamed('startAt'),
      exact: anyNamed('exact'),
      wakeup: anyNamed('wakeup'),
      rescheduleOnReboot: anyNamed('rescheduleOnReboot'),
    )).thenAnswer((_) async => true);

    when(mockAlarmScheduler.oneShotAt(
      any,
      any,
      any,
      exact: anyNamed('exact'),
      wakeup: anyNamed('wakeup'),
      rescheduleOnReboot: anyNamed('rescheduleOnReboot'),
    )).thenAnswer((_) async => true);

    when(mockAlarmScheduler.cancel(any)).thenAnswer((_) async => true);
  });

  tearDown(() {
    container.dispose();
    reset(mockAlarmScheduler);
    reset(mockActiveCustomerOperation);
  });

  group('BootService Tests', () {
    test('1. uji coba penjadwalan ulang saat tidak ada pelanggan aktif',
        () async {
      // Atur
      when(mockActiveCustomerOperation.getAllActiveCustomersWithDetails())
          .thenAnswer((_) async => []);

      // Bertindak
      await bootService.rescheduleArchivingTask(container);

      // Memastikan
      verify(mockAlarmScheduler.cancel(oneShotArchivedId)).called(1);
      verifyNever(mockAlarmScheduler.oneShotAt(
        any,
        any,
        any,
        exact: anyNamed('exact'),
        wakeup: anyNamed('wakeup'),
        rescheduleOnReboot: anyNamed('rescheduleOnReboot'),
      ));
      verifyNoMoreInteractions(mockAlarmScheduler);
    });

    test(
        '2. uji coba penjadwalan ulang dengan satu pelanggan aktif dan satu kedaluwarsa',
        () async {
      final now = DateTime.now();
      final activeCustomer = ActiveCustomerDetailModel(
        activeCustomer: ActiveCustomerModel(
          id: '1',
          customerId: 'c1',
          packageId: 'p1',
          startDate: now,
          endDate: now.add(const Duration(days: 1)),
          status: PaymentStatus.paid,
        ),
        customerName: 'Pelanggan Aktif',
        packageName: 'Paket A',
      );

      // Atur
      when(mockActiveCustomerOperation.getAllActiveCustomersWithDetails())
          .thenAnswer((_) async => [activeCustomer]);

      // Bertindak
      await bootService.rescheduleArchivingTask(container);

      // Memastikan
      verifyInOrder([
        mockAlarmScheduler.cancel(oneShotArchivedId),
        mockAlarmScheduler.oneShotAt(
          activeCustomer.activeCustomer.endDate,
          oneShotArchivedId,
          BackgroundService.checkAndArchiveExpiredCustomers,
          exact: true,
          wakeup: true,
          rescheduleOnReboot: true,
        ),
      ]);
      verifyNoMoreInteractions(mockAlarmScheduler);
    });

    test('3. uji coba penanganan error saat mengambil data pelanggan',
        () async {
      // Atur
      final exception = Exception('Database error');
      when(mockActiveCustomerOperation.getAllActiveCustomersWithDetails())
          .thenThrow(exception);

      // Bertindak
      await bootService.rescheduleArchivingTask(container);

      // Memastikan
      verify(mockAlarmScheduler.cancel(oneShotArchivedId)).called(1);
      verifyNever(mockAlarmScheduler.oneShotAt(
        any,
        any,
        any,
        exact: anyNamed('exact'),
        wakeup: anyNamed('wakeup'),
        rescheduleOnReboot: anyNamed('rescheduleOnReboot'),
      ));
      verifyNoMoreInteractions(mockAlarmScheduler);
    });

    test('4. uji coba penjadwalan tugas pengarsipan periodik', () async {
      // Bertindak
      await bootService.schedulePeriodicArchiveTask(container);

      // Memastikan
      final verification = verify(mockAlarmScheduler.schedulePeriodic(
        const Duration(hours: 1),
        archiveExpiredId,
        BackgroundService.checkAndArchiveExpiredCustomers,
        startAt: anyNamed('startAt'),
        exact: true,
        wakeup: true,
        rescheduleOnReboot: true,
      ));

      verification.called(1);
      verifyNoMoreInteractions(mockAlarmScheduler);
    });
  });
}
