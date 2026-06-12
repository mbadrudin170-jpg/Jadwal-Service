// path: test/shared/services/expired_subscription_check_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/active_customer_operation.dart';
import 'package:wifi/shared/services/expired_subscription_check_service.dart';

import 'expired_subscription_check_service_test.mocks.dart';

// Jalankan perintah `flutter pub run build_runner build` untuk menghasilkan file mocks
@GenerateMocks([PelangganAktifOpSqlite])
void main() {
  // Deklarasi variabel untuk mock dan service
  late MockActiveCustomerOperation mockActiveCustomerOperation;
  late ExpiredSubscriptionCheckService service;

  // setUp dijalankan sebelum setiap tes
  setUp(() {
    // Inisialisasi mock dan service
    mockActiveCustomerOperation = MockActiveCustomerOperation();
    service = ExpiredSubscriptionCheckService(
      activeCustomerOperation: mockActiveCustomerOperation,
    );
  });

  group('ExpiredSubscriptionCheckService', () {
    test(
        '1. harus memanggil archiveExpiredCustomers dan mencatat sukses saat checkAndArchive dipanggil',
        () async {
      // Arrange
      // Atur agar mock mengembalikan nilai 2 (misalnya 2 pelanggan berhasil diarsipkan)
      when(mockActiveCustomerOperation.archiveExpiredCustomers())
          .thenAnswer((_) async => 2);

      // Act
      // Panggil metode yang akan diuji
      await service.processExpiredSubscriptions();

      // Assert
      // Pastikan metode archiveExpiredCustomers() pada mock dipanggil tepat satu kali
      verify(mockActiveCustomerOperation.archiveExpiredCustomers()).called(1);
      // Anda juga bisa menambahkan verifikasi log jika Log class di-mock,
      // tapi untuk sekarang kita fokus pada interaksi dengan operation.
    });

    test(
        '2. harus mencatat error saat archiveExpiredCustomers melempar pengecualian',
        () async {
      // Arrange
      // Atur agar mock melempar sebuah exception saat dipanggil
      final exception = Exception('Gagal terhubung ke database');
      when(mockActiveCustomerOperation.archiveExpiredCustomers())
          .thenThrow(exception);

      // Act
      // Panggil metode yang akan diuji
      await service.processExpiredSubscriptions();

      // Assert
      // Pastikan metode archiveExpiredCustomers() tetap dipanggil
      verify(mockActiveCustomerOperation.archiveExpiredCustomers()).called(1);
      // Di dalam implementasi aslinya, error akan ditangkap dan di-log.
      // Tes ini memastikan bahwa eksekusi tidak berhenti (crash) karena exception tersebut.
    });

    test('3. tidak boleh melempar error saat 0 pelanggan diarsipkan', () async {
      // Arrange
      // Atur agar mock mengembalikan 0
      when(mockActiveCustomerOperation.archiveExpiredCustomers())
          .thenAnswer((_) async => 0);

      // Act
      // Panggil metode yang akan diuji
      await service.processExpiredSubscriptions();

      // Assert
      // Pastikan metode pada mock dipanggil
      verify(mockActiveCustomerOperation.archiveExpiredCustomers()).called(1);
    });
  });
}
