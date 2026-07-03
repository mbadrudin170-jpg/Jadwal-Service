// path: test/admin/model/best_selling_package_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/fitur/paket/enum/tipe_durasi_paket.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/statistik/model/paket_terlaris_model.dart';

void main() {
  group('PaketTerlarisModel', () {
    // Dummy PaketModel for testing
    final paket = const PaketModel(
      id: 'p1',
      nama: 'Paket Test',
      harga: 50000,
      durasi: 30,
      tipe: TipeDurasiPaket.days,
    );

    test('01. harus membuat instance dengan benar', () {
      final model = PaketTerlarisModel(paket: paket, totalTerjual: 150);

      expect(model.paket, paket);
      expect(model.totalTerjual, 150);
    });
  });
}
