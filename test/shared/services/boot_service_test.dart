// path: test/shared/services/boot_service_test.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
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
  });

  tearDown(() {
    container.dispose();
  });

  group('BootService Tests', () {
    test('1. uji coba penjadwalan tugas pengarsipan periodik', () async {
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
