// path: test/shared/services/cek_langganan_kadaluarsa_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/shared/operasi/active_customer_operation.dart';
import 'package:wifi/shared/services/expired_subscription_check_service.dart';

// --- Mock ---
class MockPelangganAktifOperasi extends Mock implements PelangganAktifOperasi {}

void main() {
  late MockPelangganAktifOperasi mockPelangganAktifOperasi;
  late CekLanggananKadaluarsaService service;

  setUp(() {
    mockPelangganAktifOperasi = MockPelangganAktifOperasi();
    service = CekLanggananKadaluarsaService();
    service.pelangganAktifOperasi = mockPelangganAktifOperasi;
  });

  group('prosesLanggananKadaluarsa', () {
    test('berhasil mengarsipkan dan mengembalikan jumlah > 0', () async {
      when(() => mockPelangganAktifOperasi.arsipkanPelangganKadaluarsa())
          .thenAnswer((final _) async => 5);

      // Tidak boleh throw
      await service.prosesLanggananKadaluarsa();

      verify(() => mockPelangganAktifOperasi.arsipkanPelangganKadaluarsa())
          .called(1);
    });

    test('menangani kasus tidak ada yang kedaluwarsa (jumlah 0)', () async {
      when(() => mockPelangganAktifOperasi.arsipkanPelangganKadaluarsa())
          .thenAnswer((final _) async => 0);

      await service.prosesLanggananKadaluarsa();

      verify(() => mockPelangganAktifOperasi.arsipkanPelangganKadaluarsa())
          .called(1);
    });

    test('tidak melempar exception jika operasi gagal', () async {
      when(() => mockPelangganAktifOperasi.arsipkanPelangganKadaluarsa())
          .thenThrow(Exception('Database error'));

      // Harusnya tidak throw, hanya log error
      await service.prosesLanggananKadaluarsa();

      verify(() => mockPelangganAktifOperasi.arsipkanPelangganKadaluarsa())
          .called(1);
    });

    test('menangani exception spesifik', () async {
      when(() => mockPelangganAktifOperasi.arsipkanPelangganKadaluarsa())
          .thenThrow(const FormatException('Data corrupt'));

      await service.prosesLanggananKadaluarsa();
      // Tidak throw
    });
  });
}
