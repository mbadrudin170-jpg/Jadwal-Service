// path: lib/admin/model/best_selling_package.dart
import 'package:wifi/shared/model/package_model.dart';

/// Model untuk merepresentasikan paket yang paling banyak terjual.
///
/// Menggabungkan data dari [PackageModel] dengan jumlah total penjualannya.
class BestSellingPackage {
  /// Data lengkap dari paket yang terjual.
  final PackageModel package;

  /// Jumlah total paket ini terjual berdasarkan data transaksi.
  final int totalSold;

  /// Konstruktor untuk membuat instance [BestSellingPackage].
  BestSellingPackage({
    required this.package,
    required this.totalSold,
  });
}
