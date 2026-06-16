// path: test/fitur/alarm/alarm_scheduler_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/fitur/alarm/penjadwal_alarm.dart';

import 'alarm_scheduler_test.mocks.dart';

@GenerateMocks([PenjadwalAlarm])
void main() {
  group('AlarmScheduler', () {
    late MockAlarmScheduler mockAlarmScheduler;

    setUp(() {
      mockAlarmScheduler = MockAlarmScheduler();
    });

    test('01. scheduleOneShot should call the underlying method', () async {
      // Arrange
      final time = DateTime.now();
      const id = 1;
      void callback() {}
      when(mockAlarmScheduler.jadwalkanSekali(time, id, callback,
              bangunkan: true, tepatWaktu: true))
          .thenAnswer((_) async => true);

      // Act
      await mockAlarmScheduler.jadwalkanSekali(time, id, callback,
          bangunkan: true, tepatWaktu: true);

      // Assert
      verify(mockAlarmScheduler.jadwalkanSekali(time, id, callback,
              bangunkan: true, tepatWaktu: true))
          .called(1);
    });

    test('02. schedulePeriodic should call the underlying method', () async {
      // Arrange
      const duration = Duration(minutes: 15);
      const id = 2;
      void callback() {}
      when(mockAlarmScheduler.jadwalkanPeriodik(duration, id, callback,
              tepatWaktu: true, bangunkan: true, jadwalkanUlangSaatBoot: true))
          .thenAnswer((_) async => true);

      // Act
      await mockAlarmScheduler.jadwalkanPeriodik(duration, id, callback,
          tepatWaktu: true, bangunkan: true, jadwalkanUlangSaatBoot: true);

      // Assert
      verify(mockAlarmScheduler.jadwalkanPeriodik(duration, id, callback,
              tepatWaktu: true, bangunkan: true, jadwalkanUlangSaatBoot: true))
          .called(1);
    });

    test('03. oneShotAt should call the underlying method', () async {
      // Arrange
      final time = DateTime.now();
      const id = 3;
      void callback() {}
      when(mockAlarmScheduler.jadwalkanSekaliPada(time, id, callback,
              tepatWaktu: true, bangunkan: true, jadwalkanUlangSaatBoot: true))
          .thenAnswer((_) async => true);

      // Act
      await mockAlarmScheduler.jadwalkanSekaliPada(time, id, callback,
          tepatWaktu: true, bangunkan: true, jadwalkanUlangSaatBoot: true);

      // Assert
      verify(mockAlarmScheduler.jadwalkanSekaliPada(time, id, callback,
              tepatWaktu: true, bangunkan: true, jadwalkanUlangSaatBoot: true))
          .called(1);
    });

    test('04. cancel should call the underlying method', () async {
      // Arrange
      const id = 1;
      when(mockAlarmScheduler.batalkan(id)).thenAnswer((_) async => true);

      // Act
      await mockAlarmScheduler.batalkan(id);

      // Assert
      verify(mockAlarmScheduler.batalkan(id)).called(1);
    });
  });
}
