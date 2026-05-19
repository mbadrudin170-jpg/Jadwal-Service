// path: lib/shared/model/active_customer_detail_model.dart

import 'package:wifi/shared/model/active_customer_model.dart';

/// Model ini adalah struktur data gabungan untuk menampilkan detail pelanggan aktif.
/// Ini bukan tabel database, melainkan hasil dari query JOIN yang efisien.
class ActiveCustomerDetailModel {
  /// Data inti pelanggan aktif.
  final ActiveCustomerModel activeCustomer;

  /// Nama lengkap pelanggan, diambil dari tabel `customer`.
  final String customerName;

  /// Nama paket, diambil dari tabel `package`.
  final String packageName;

  /// Konstruktor untuk membuat instance [ActiveCustomerDetailModel].
  ActiveCustomerDetailModel({
    required this.activeCustomer,
    required this.customerName,
    required this.packageName,
  });
}
