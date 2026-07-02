// path: test/shared/data/services/layanan_preferensi_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/shared/data/services/layanan_preferensi.dart';

void main() {
  group('LayananPreferensi', () {
    const kunciTerakhirUnduh = 'terakhir_unduh';
    late LayananPreferensi layananPreferensi;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      layananPreferensi = LayananPreferensi();
    });

    test(
      '01. ambilWaktuTerakhirUnduh harus mengembalikan null jika tidak ada data',
      () async {
        final waktu = await layananPreferensi.ambilWaktuTerakhirUnduh();
        expect(waktu, isNull);
      },
    );

    test(
      '02. simpan dan ambilWaktuTerakhirUnduh harus mengembalikan waktu yang benar',
      () async {
        final waktuSimpan = DateTime.now();
        await layananPreferensi.simpanWaktuTerakhirUnduh(waktuSimpan);

        final waktuAmbil = await layananPreferensi.ambilWaktuTerakhirUnduh();

        expect(
          waktuAmbil?.millisecondsSinceEpoch,
          waktuSimpan.toUtc().millisecondsSinceEpoch,
        );
      },
    );

    test(
      '03. ambilWaktuTerakhirUnggah harus mengembalikan null jika tidak ada data',
      () async {
        final waktu = await layananPreferensi.ambilWaktuTerakhirUnggah();
        expect(waktu, isNull);
      },
    );

    test(
      '04. simpan dan ambilWaktuTerakhirUnggah harus mengembalikan waktu yang benar',
      () async {
        final waktuSimpan = DateTime.now();
        await layananPreferensi.simpanWaktuTerakhirUnggah(waktuSimpan);

        final waktuAmbil = await layananPreferensi.ambilWaktuTerakhirUnggah();

        expect(
          waktuAmbil?.millisecondsSinceEpoch,
          waktuSimpan.toUtc().millisecondsSinceEpoch,
        );
      },
    );

    test(
      '05. resetWaktuSinkronisasi harus menghapus kedua timestamp',
      () async {
        final waktuSekarang = DateTime.now();
        await layananPreferensi.simpanWaktuTerakhirUnduh(waktuSekarang);
        await layananPreferensi.simpanWaktuTerakhirUnggah(waktuSekarang);

        expect(await layananPreferensi.ambilWaktuTerakhirUnduh(), isNotNull);
        expect(await layananPreferensi.ambilWaktuTerakhirUnggah(), isNotNull);

        await layananPreferensi.resetWaktuSinkronisasi();

        expect(await layananPreferensi.ambilWaktuTerakhirUnduh(), isNull);
        expect(await layananPreferensi.ambilWaktuTerakhirUnggah(), isNull);
      },
    );

    test('06. ambilWaktuTerakhirUnduh harus mengembalikan null jika nilai 0',
        () async {
      SharedPreferences.setMockInitialValues({kunciTerakhirUnduh: 0});

      final waktu = await layananPreferensi.ambilWaktuTerakhirUnduh();
      expect(waktu, isNull);
    });

    test('07. simpanWaktuTerakhirUnduh menyimpan nilai dalam format UTC',
        () async {
      final waktuLokal = DateTime(2023, 1, 1, 10);
      await layananPreferensi.simpanWaktuTerakhirUnduh(waktuLokal);

      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(kunciTerakhirUnduh);

      expect(timestamp, waktuLokal.toUtc().millisecondsSinceEpoch);
    });
  });
}
