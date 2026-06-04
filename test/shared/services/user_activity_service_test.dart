// path: test/shared/services/user_activity_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/shared/operasi/firebase_operasi/customer_op_firebase.dart';
import 'package:wifi/shared/services/user_activity_service.dart';

import 'user_activity_service_test.mocks.dart';

@GenerateMocks([CustomerOpFirebase])
void main() {
  late MockCustomerOpFirebase mockCustomerOpFirebase;
  late UserActivityService userActivityService;
  late SharedPreferences sharedPreferences;

  // Nilai konstan untuk customerId agar konsisten
  const String testCustomerId = 'test-customer-123';

  setUp(() async {
    // Inisialisasi mock
    mockCustomerOpFirebase = MockCustomerOpFirebase();

    // Atur nilai awal untuk SharedPreferences dalam mode testing
    SharedPreferences.setMockInitialValues({});
    sharedPreferences = await SharedPreferences.getInstance();

    // Inisialisasi service dengan mock
    userActivityService = UserActivityService(
      customerOpFirebase: mockCustomerOpFirebase,
    );
  });

  group('UserActivityService - pingActivity', () {
    test(
        'should update last active and save timestamp if pinged for the first time',
        () async {
      // Arrange
      // Siapkan mock agar tidak mengembalikan error saat updateLastActive dipanggil
      when(mockCustomerOpFirebase.updateLastActive(any))
          .thenAnswer((_) async => true);

      // Act
      // Panggil metode yang diuji
      await userActivityService.pingActivity(testCustomerId);

      // Assert
      // Pastikan metode updateLastActive di firebase operation dipanggil
      verify(mockCustomerOpFirebase.updateLastActive(testCustomerId)).called(1);

      // Pastikan timestamp disimpan di SharedPreferences
      final timestamp =
          sharedPreferences.getInt(UserActivityService.lastPingTimestampKey);
      expect(timestamp, isNotNull);
      expect(timestamp, isA<int>());
    });

    test('should NOT update last active if pinged within the interval',
        () async {
      // Arrange
      // Simulasikan bahwa ping sudah pernah dilakukan baru-baru ini
      final now = DateTime.now();
      await sharedPreferences.setInt(
          UserActivityService.lastPingTimestampKey, now.millisecondsSinceEpoch);

      // Act
      // Panggil lagi pingActivity
      await userActivityService.pingActivity(testCustomerId);

      // Assert
      // Pastikan updateLastActive TIDAK pernah dipanggil
      verifyNever(mockCustomerOpFirebase.updateLastActive(any));
    });

    test('should update last active if pinged after the interval has passed',
        () async {
      // Arrange
      // Siapkan mock
      when(mockCustomerOpFirebase.updateLastActive(any))
          .thenAnswer((_) async => true);

      // Simulasikan bahwa ping terakhir dilakukan sudah lama (lebih dari interval)
      final longTimeAgo = DateTime.now()
          .subtract(UserActivityService.pingInterval * 2)
          .millisecondsSinceEpoch;
      await sharedPreferences.setInt(
          UserActivityService.lastPingTimestampKey, longTimeAgo);

      // Act
      await userActivityService.pingActivity(testCustomerId);

      // Assert
      // Pastikan updateLastActive dipanggil
      verify(mockCustomerOpFirebase.updateLastActive(testCustomerId)).called(1);

      // Pastikan timestamp di SharedPreferences diperbarui
      final newTimestamp =
          sharedPreferences.getInt(UserActivityService.lastPingTimestampKey);
      expect(newTimestamp, isNotNull);
      expect(newTimestamp, greaterThan(longTimeAgo));
    });

    test('should handle exception from CustomerOpFirebase gracefully', () {
      // Arrange
      // Atur agar mock melempar exception
      final exception = Exception('Firebase error');
      when(mockCustomerOpFirebase.updateLastActive(any)).thenThrow(exception);

      // Act & Assert
      // Panggilan ini seharusnya tidak melempar exception (karena sudah ditangani di dalam service)
      expect(() => userActivityService.pingActivity(testCustomerId),
          returnsNormally);

      // Pastikan timestamp TIDAK disimpan/diperbarui jika terjadi error
      final timestamp =
          sharedPreferences.getInt(UserActivityService.lastPingTimestampKey);
      expect(timestamp, isNull);
    });
  });
}
