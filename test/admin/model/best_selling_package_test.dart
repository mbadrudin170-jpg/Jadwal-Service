// path: test/admin/model/best_selling_package_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/fitur/statistik/model/paket_terlaris_model.dart';

void main() {
  group('BestSellingPackage', () {
    test('01. fromJson() harus mengembalikan model yang valid', () {
      // Data JSON sampel
      final Map<String, dynamic> json = {
        'packageName': 'Paket Internet Super Cepat',
        'count': 150,
      };

      // Panggil metode fromJson
      final model = PaketTerlarisModel.fromJson(json);

      // Verifikasi bahwa model yang dikembalikan adalah instance dari BestSellingPackage
      expect(model, isA<PaketTerlarisModel>());

      // Verifikasi bahwa properti model sesuai dengan data JSON
      expect(model.packageName, 'Paket Internet Super Cepat');
      expect(model.count, 150);
    });

    test('02. toJson() harus mengembalikan map yang valid', () {
      // Buat instance dari BestSellingPackage
      const model = PaketTerlarisModel(
        packageName: 'Paket Keluarga Bahagia',
        count: 75,
      );

      // Panggil metode toJson
      final json = model.toJson();

      // Verifikasi bahwa map yang dikembalikan memiliki kunci dan nilai yang benar
      expect(json, isA<Map<String, dynamic>>());
      expect(json['packageName'], 'Paket Keluarga Bahagia');
      expect(json['count'], 75);
    });

    test('03. props harus mengembalikan daftar properti yang benar', () {
      // Buat instance dari BestSellingPackage
      const model = PaketTerlarisModel(
        packageName: 'Paket Gaming Pro',
        count: 100,
      );

      // Verifikasi bahwa getter props mengembalikan daftar yang berisi kedua properti
      expect(model.props, [model.packageName, model.count]);
    });
  });
}
