// path: test/shared/operasi/pembersihan_data_operasi_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/operasi/pembersihan_data_operasi.dart';

// --- Mock ---
class MockDatabaseHelper extends Mock implements DatabaseHelper {}

class MockDatabase extends Mock implements Database {}

void main() {
  late MockDatabaseHelper mockDbHelper;
  late MockDatabase mockDatabase;
  late PembersihanDataOperasi pembersihanDataOperasi;

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    mockDatabase = MockDatabase();
    when(() => mockDbHelper.database).thenAnswer((_) async => mockDatabase);
    pembersihanDataOperasi = PembersihanDataOperasi(dbHelper: mockDbHelper);
  });

  group('hapusSemuaDataArsipKadaluarsa', () {
    test('menghapus data di semua tabel dan mengembalikan total yang dihapus',
        () async {
      // Simulasi: setiap tabel mengembalikan jumlah yang berbeda
      when(() => mockDatabase.rawDelete(
            any(),
            any(),
          )).thenAnswer((_) async => 1);

      final total = await pembersihanDataOperasi.hapusSemuaDataArsipKadaluarsa(
          batasHari: 30);

      // 9 tabel × 1 = 9
      expect(total, 9);
    });

    test('mengembalikan 0 jika tidak ada data arsip yang kadaluarsa', () async {
      // rawDelete mengembalikan 0
      when(() => mockDatabase.rawDelete(any(), any()))
          .thenAnswer((_) async => 0);

      final total = await pembersihanDataOperasi.hapusSemuaDataArsipKadaluarsa(
          batasHari: 7);

      expect(total, 0);
    });

    test('menggunakan batas waktu yang benar (UTC Epoch) dalam query',
        () async {
      // Tangkap argumen query
      List<dynamic> capturedArgs = [];
      when(() => mockDatabase.rawDelete(any(), captureAny()))
          .thenAnswer((invocation) {
        capturedArgs = invocation.positionalArguments[1] as List<dynamic>;
        return 0;
      });

      await pembersihanDataOperasi.hapusSemuaDataArsipKadaluarsa(batasHari: 30);

      // Argumen harus ada 1 (list dengan satu elemen epoch)
      expect(capturedArgs.length, 1);
      final batasEpoch = capturedArgs[0] as int;

      // Batas waktu harus sekitar 30 hari sebelum sekarang (UTC)
      final expectedBatas = DateTime.now()
          .toUtc()
          .subtract(const Duration(days: 30))
          .millisecondsSinceEpoch;

      // Toleransi 1 detik untuk waktu eksekusi
      expect(batasEpoch, greaterThanOrEqualTo(expectedBatas - 1000));
      expect(batasEpoch, lessThanOrEqualTo(expectedBatas + 1000));
    });

    test('query mencakup kondisi diarsipkan IS NOT NULL', () async {
      String? capturedQuery;
      when(() => mockDatabase.rawDelete(captureAny(), any()))
          .thenAnswer((invocation) {
        capturedQuery = invocation.positionalArguments[0] as String;
        return 0;
      });

      await pembersihanDataOperasi.hapusSemuaDataArsipKadaluarsa(batasHari: 30);

      expect(capturedQuery, isNotNull);
      // Pastikan ada klausa "diarsipkan IS NOT NULL"
      expect(
        capturedQuery!.toLowerCase(),
        contains('diarsipkan is not null'),
      );
      // Pastikan ada klausa "diarsipkan <="
      expect(
        capturedQuery!.toLowerCase(),
        contains('diarsipkan <='),
      );
    });

    test('melanjutkan ke tabel berikutnya jika satu tabel gagal', () async {
      final daftarTabel = [
        'pelanggan',
        'pelanggan_aktif',
        'paket',
        'kategori',
        'sub_kategori',
        'transaksi',
        'dompet',
        'pesanan',
        'versi_apk_user',
      ];

      int hitungPanggil = 0;
      final tabelError = 'transaksi'; // Simulasi error di tabel ini

      when(() => mockDatabase.rawDelete(any(), any())).thenAnswer((_) async {
        hitungPanggil++;
        // Lempar error untuk tabel ke-6 (indeks 5) = 'transaksi'
        // Tapi karena mock sulit tahu tabel mana, kita gunakan counter
        if (hitungPanggil == 6) {
          throw Exception('Gagal menghapus di $tabelError');
        }
        return 5; // tabel lain berhasil hapus 5
      });

      // Tidak boleh throw exception
      final total = await pembersihanDataOperasi.hapusSemuaDataArsipKadaluarsa(
        batasHari: 30,
      );

      // 8 tabel sukses × 5 = 40, 1 gagal
      expect(total, 40);
      // Harus dipanggil 9 kali (semua tabel tetap dicoba)
      expect(hitungPanggil, 9);
    });

    test('menangani batasHari 0 (penghapusan segera)', () async {
      when(() => mockDatabase.rawDelete(any(), any()))
          .thenAnswer((_) async => 0);

      // Tidak boleh throw, meskipun batasHari = 0
      final total = await pembersihanDataOperasi.hapusSemuaDataArsipKadaluarsa(
          batasHari: 0);

      expect(total, 0);
    });
  });
}
