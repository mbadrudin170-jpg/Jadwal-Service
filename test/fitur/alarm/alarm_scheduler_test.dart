// path: test/fitur/alarm/alarm_scheduler_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/fitur/alarm/penjadwal_alarm.dart';

import 'alarm_scheduler_test.mocks.dart';

@GenerateMocks([PenjadwalAlarm])
void main() {
  group('AlarmScheduler', () {
    late MockPenjadwalAlarm mockPenjadwalAlarm;

    setUp(() {
      mockPenjadwalAlarm = MockPenjadwalAlarm();
    });

    test('01. scheduleOneShot should call the underlying method', () async {
      // Arrange
      final time = DateTime.now();
      const id = 1;
      void callback() {}
      when(
        mockPenjadwalAlarm.jadwalkanSekali(
          time,
          id,
          callback,
          bangunkan: true,
          tepatWaktu: true,
        ),
      ).thenAnswer((_) async => true);

      // Act
      await mockPenjadwalAlarm.jadwalkanSekali(
        time,
        id,
        callback,
        bangunkan: true,
        tepatWaktu: true,
      );

      // Assert
      verify(
        mockPenjadwalAlarm.jadwalkanSekali(
          time,
          id,
          callback,
          bangunkan: true,
          tepatWaktu: true,
        ),
      ).called(1);
    });

    test('02. schedulePeriodic should call the underlying method', () async {
      // Arrange
      const duration = Duration(minutes: 15);
      const id = 2;
      void callback() {}
      when(
        mockPenjadwalAlarm.jadwalkanPeriodik(
          duration,
          id,
          callback,
          tepatWaktu: true,
          bangunkan: true,
          jadwalkanUlangSaatBoot: true,
        ),
      ).thenAnswer((_) async => true);

      // Act
      await mockPenjadwalAlarm.jadwalkanPeriodik(
        duration,
        id,
        callback,
        tepatWaktu: true,
        bangunkan: true,
        jadwalkanUlangSaatBoot: true,
      );

      // Assert
      verify(
        mockPenjadwalAlarm.jadwalkanPeriodik(
          duration,
          id,
          callback,
          tepatWaktu: true,
          bangunkan: true,
          jadwalkanUlangSaatBoot: true,
        ),
      ).called(1);
    });

    test('03. oneShotAt should call the underlying method', () async {
      // Arrange
      final time = DateTime.now();
      const id = 3;
      void callback() {}
      when(
        mockPenjadwalAlarm.jadwalkanSekaliPada(
          time,
          id,
          callback,
          tepatWaktu: true,
          bangunkan: true,
          jadwalkanUlangSaatBoot: true,
        ),
      ).thenAnswer((_) async => true);

      // Act
      await mockPenjadwalAlarm.jadwalkanSekaliPada(
        time,
        id,
        callback,
        tepatWaktu: true,
        bangunkan: true,
        jadwalkanUlangSaatBoot: true,
      );

      // Assert
      verify(
        mockPenjadwalAlarm.jadwalkanSekaliPada(
          time,
          id,
          callback,
          tepatWaktu: true,
          bangunkan: true,
          jadwalkanUlangSaatBoot: true,
        ),
      ).called(1);
    });

    test('04. cancel should call the underlying method', () async {
      // Arrange
      const id = 1;
      when(mockPenjadwalAlarm.batalkan(id)).thenAnswer((_) async => true);

      // Act
      await mockPenjadwalAlarm.batalkan(id);

      // Assert
      verify(mockPenjadwalAlarm.batalkan(id)).called(1);
    });
  });
}
