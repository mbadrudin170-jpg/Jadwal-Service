// path: lib/admin/model/best_selling_package.dart
import 'package:wifi/fitur/paket/model/paket_model.dart';

class BestSellingPackage {
  final PaketModel paket;
  final int totalTerjual;

  BestSellingPackage({
    required this.paket,
    required this.totalTerjual,
  });
}
