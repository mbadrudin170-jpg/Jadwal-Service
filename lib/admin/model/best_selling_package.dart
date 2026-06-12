// path: lib/admin/model/best_selling_package.dart
import 'package:wifi/fitur/paket/model/paket_model.dart';

/// Model untuk merepresentasikan paket yang paling banyak terjual.
///
/// Menggabungkan data dari [PaketModel] dengan jumlah total penjualannya.
class BestSellingPackage {
  /// Data lengkap dari paket yang terjual.
  final PaketModel paket;

  /// Jumlah total paket ini terjual berdasarkan data transaksi.
  final int totalTerjual;

  /// Konstruktor untuk membuat instance [BestSellingPackage].
  BestSellingPackage({
    required this.paket,
    required this.totalTerjual,
  });
}
