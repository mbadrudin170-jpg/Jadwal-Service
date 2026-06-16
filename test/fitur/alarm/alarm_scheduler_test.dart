// path: test/fitur/alarm/alarm_scheduler_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/fitur/alarm/alarm_scheduler.dart';

import 'alarm_scheduler_test.mocks.dart';

@GenerateMocks([AlarmScheduler])
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
      when(mockAlarmScheduler.scheduleOneShot(time, id, callback,
              wakeup: true, exact: true))
          .thenAnswer((_) async => true);

      // Act
      await mockAlarmScheduler.scheduleOneShot(time, id, callback,
          wakeup: true, exact: true);

      // Assert
      verify(mockAlarmScheduler.scheduleOneShot(time, id, callback,
              wakeup: true, exact: true))
          .called(1);
    });

    test('02. schedulePeriodic should call the underlying method', () async {
      // Arrange
      const duration = Duration(minutes: 15);
      const id = 2;
      void callback() {}
      when(mockAlarmScheduler.schedulePeriodic(duration, id, callback,
              exact: true, wakeup: true, rescheduleOnReboot: true))
          .thenAnswer((_) async => true);

      // Act
      await mockAlarmScheduler.schedulePeriodic(duration, id, callback,
          exact: true, wakeup: true, rescheduleOnReboot: true);

      // Assert
      verify(mockAlarmScheduler.schedulePeriodic(duration, id, callback,
              exact: true, wakeup: true, rescheduleOnReboot: true))
          .called(1);
    });

    test('03. oneShotAt should call the underlying method', () async {
      // Arrange
      final time = DateTime.now();
      const id = 3;
      void callback() {}
      when(mockAlarmScheduler.oneShotAt(time, id, callback,
              exact: true, wakeup: true, rescheduleOnReboot: true))
          .thenAnswer((_) async => true);

      // Act
      await mockAlarmScheduler.oneShotAt(time, id, callback,
          exact: true, wakeup: true, rescheduleOnReboot: true);

      // Assert
      verify(mockAlarmScheduler.oneShotAt(time, id, callback,
              exact: true, wakeup: true, rescheduleOnReboot: true))
          .called(1);
    });

    test('04. cancel should call the underlying method', () async {
      // Arrange
      const id = 1;
      when(mockAlarmScheduler.cancel(id)).thenAnswer((_) async => true);

      // Act
      await mockAlarmScheduler.cancel(id);

      // Assert
      verify(mockAlarmScheduler.cancel(id)).called(1);
    });
  });
}
