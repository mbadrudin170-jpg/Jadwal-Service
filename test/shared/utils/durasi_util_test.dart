// path: test/shared/utils/durasi_util_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/fitur/paket/enum/tipe_durasi_paket.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/shared/utils/durasi_util.dart';

void main() {
  group('DurasiUtil', () {
    test(
      '01. hitungDurasiDalamMenit harus mengembalikan durasi dalam menit',
      () {
        final paket = const PaketModel(
          id: '1',
          nama: 'Paket Test',
          harga: 10000,
          durasi: 2,
          tipe: TipeDurasiPaket.days,
        );

        final hasil = DurasiUtil.hitungDurasiDalamMenit(paket);
        expect(hasil, 2 * 24 * 60); // 2 hari = 2880 menit
      },
    );

    test('02. tambahDurasi harus menambahkan durasi dengan benar', () {
      final tanggal = DateTime(2023);

      // Test penambahan hari
      final hasilHari = DurasiUtil.tambahDurasi(
        tanggal,
        TipeDurasiPaket.days,
        5,
      );
      expect(hasilHari, DateTime(2023, 1, 6));

      // Test penambahan bulan dengan Jiffy
      final hasilBulan = DurasiUtil.tambahDurasi(
        tanggal,
        TipeDurasiPaket.months,
        2,
      );
      expect(hasilBulan, DateTime(2023, 3));
    });

    test('03. hitungTotalDurasiDalamMenit harus menghitung paket + bonus', () {
      final paket = const PaketModel(
        id: '1',
        nama: 'Paket Test',
        harga: 10000,
        durasi: 1,
        tipe: TipeDurasiPaket.days,
      );

      final hasil = DurasiUtil.hitungTotalDurasiDalamMenit(
        paket,
        durasiBonus: 3,
        tipeBonus: TipeDurasiPaket.hours,
      );

      // 1 hari = 1440 menit + 3 jam = 180 menit = 1620 menit
      expect(hasil, 1440 + 180);
    });
  });
}
