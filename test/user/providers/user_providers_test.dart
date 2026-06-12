
// path: test/user/providers/user_providers_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/fitur/akun/provider/akun_provider.dart';
import 'package:wifi/shared/model/akun_model.dart';
import 'package:wifi/user/providers/user_providers.dart';

// Mocks
class MockPengelolaAkun extends Mock implements PengelolaAkun {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockPengelolaAkun mockPengelolaAkun;

  setUp(() {
    mockPengelolaAkun = MockPengelolaAkun();
  });

  group('userIdProvider', () {
    test('Test 01: should return user id when account is active', () async {
      final container = ProviderContainer(overrides: [
        pengelolaAkunProvider.overrideWith((ref) async => mockPengelolaAkun)
      ]);

      when(() => mockPengelolaAkun.akunSaatIni)
          .thenReturn(const AkunModel(id: 'test-user-id', email: 'email'));

      final result = await container.read(userIdProvider.future);

      expect(result, 'test-user-id');
    });

    test('Test 02: should return null when no account is active', () async {
      final container = ProviderContainer(overrides: [
        pengelolaAkunProvider.overrideWith((ref) async => mockPengelolaAkun)
      ]);

      when(() => mockPengelolaAkun.akunSaatIni).thenReturn(null);

      final result = await container.read(userIdProvider.future);

      expect(result, isNull);
    });
  });

  group('AppReadiness', () {
    test('Test 03: should be initially false', () {
      final container = ProviderContainer();
      final appReadiness = container.read(appReadinessProvider);

      expect(appReadiness, isFalse);
    });

    test('Test 04: should be true after setReady(true)', () {
      final container = ProviderContainer();
      container.read(appReadinessProvider.notifier).setReady(true);
      final appReadiness = container.read(appReadinessProvider);

      expect(appReadiness, isTrue);
    });
  });
}
