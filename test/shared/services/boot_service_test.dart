// path: test/shared/services/boot_service_test.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/shared/services/alarm/alarm_scheduler.dart';
import 'package:wifi/shared/services/alarm/alarm_scheduler_provider.dart';
import 'package:wifi/shared/services/background_service.dart';
import 'package:wifi/shared/services/boot_service.dart';

import 'boot_service_test.mocks.dart';

// 1. Hasilkan mock untuk AlarmScheduler
@GenerateMocks([AlarmScheduler])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BootService bootService;
  late MockAlarmScheduler mockAlarmScheduler;
  late ProviderContainer container;

  setUp(() {
    mockAlarmScheduler = MockAlarmScheduler();

    // 2. Buat ProviderContainer dengan override untuk alarmSchedulerProvider
    container = ProviderContainer(
      overrides: [
        alarmSchedulerProvider.overrideWithValue(mockAlarmScheduler),
      ],
    );
    bootService = BootService();

    // Atur perilaku default untuk mock, kembali `true` saat penjadwalan berhasil
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

  group('BootService', () {
    test('1. uji coba penjadwalan tugas pengarsipan periodik', () async {
      // Bertindak
      await bootService.schedulePeriodicArchiveTask(container);

      // Memastikan
      // 3. Verifikasi bahwa `schedulePeriodic` dipanggil dengan parameter yang benar
      final verification = verify(mockAlarmScheduler.schedulePeriodic(
        const Duration(hours: 1),
        archiveExpiredId,
        BackgroundService.checkAndArchiveExpiredCustomers,
        startAt: anyNamed('startAt'),
        exact: true,
        wakeup: true,
        rescheduleOnReboot: true,
      ));

      // Pastikan metode dipanggil tepat satu kali
      verification.called(1);

      // 4. Verifikasi bahwa tidak ada lagi interaksi dengan mock
      verifyNoMoreInteractions(mockAlarmScheduler);
    });
  });
}
