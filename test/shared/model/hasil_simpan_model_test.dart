// path: test/shared/model/hasil_simpan_model_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/shared/model/hasil_simpan_model.dart';

// Contoh kelas untuk digunakan sebagai tipe generik T
class ModelContoh {
  final String nama;
  ModelContoh(this.nama);
}

void main() {
  group('HasilSimpanModel', () {
    // Uji kasus sukses
    test('Konstruktor harus menyimpan nilai dengan benar untuk kasus sukses', () {
      final hasil = HasilSimpanModel<ModelContoh>(
        sukses: true,
        pesan: 'Operasi berhasil',
        data: ModelContoh('Data Tes'),
      );

      expect(hasil.sukses, isTrue);
      expect(hasil.pesan, 'Operasi berhasil');
      expect(hasil.data, isA<ModelContoh>());
      expect(hasil.data?.nama, 'Data Tes');
    });

    // Uji kasus gagal
    test('Konstruktor harus menyimpan nilai dengan benar untuk kasus gagal', () {
      final hasil = HasilSimpanModel<ModelContoh>(
        sukses: false,
        pesan: 'Terjadi kesalahan',
      );

      expect(hasil.sukses, isFalse);
      expect(hasil.pesan, 'Terjadi kesalahan');
      expect(hasil.data, isNull); // Data harus null saat gagal
    });

    // Uji dengan tipe data yang berbeda (String)
    test('Model harus bekerja dengan tipe data String', () {
      final hasil = HasilSimpanModel<String>(
        sukses: true,
        pesan: 'Sukses mengambil string',
        data: 'Ini adalah data string',
      );

      expect(hasil.sukses, isTrue);
      expect(hasil.pesan, 'Sukses mengambil string');
      expect(hasil.data, 'Ini adalah data string');
    });

    // Uji dengan tipe data primitif (int)
    test('Model harus bekerja dengan tipe data int', () {
      final hasil = HasilSimpanModel<int>(
        sukses: true,
        pesan: 'Sukses mengambil integer',
        data: 123,
      );

      expect(hasil.sukses, isTrue);
      expect(hasil.pesan, 'Sukses mengambil integer');
      expect(hasil.data, 123);
    });

    // Uji tanpa data (data is null)
    test('Model harus menangani kasus di mana data adalah null', () {
      final hasil = HasilSimpanModel<int>(
        sukses: true,
        pesan: 'Operasi berhasil tanpa data kembali',
      );

      expect(hasil.sukses, isTrue);
      expect(hasil.pesan, 'Operasi berhasil tanpa data kembali');
      expect(hasil.data, isNull);
    });
  });
}
