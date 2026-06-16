// path: test/fitur/background/alarm_utils_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/fitur/background/alarm_utils.dart';
import 'package:wifi/shared/services/arsipkan_langganan_kadaluarsa_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Mocks
class MockArsipLanggananKadaluarsaService extends Mock
    implements ArsipLanggananKadaluarsaService {}

// ignore: must_be_immutable
class MockFirebase extends Mock implements Firebase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('alarmCallback', () {
    late MockArsipLanggananKadaluarsaService mockService;

    setUp(() {
      mockService = MockArsipLanggananKadaluarsaService();
    });

    test('01. should call prosesArsipLanggananKadaluarsa', () async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          arsipLanggananKadaluarsaServiceProvider.overrideWithValue(mockService),
        ],
      );
      when(mockService.prosesArsipLanggananKadaluarsa()).thenAnswer((_) async {});

      // Act
      await alarmCallback();

      // Assert
      verify(mockService.prosesArsipLanggananKadaluarsa()).called(1);
      container.dispose();
    });
  });
}
