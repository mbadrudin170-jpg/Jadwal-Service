// path: lib/shared/widget/customer_name.dart
// digunakan oleh: lib/admin/halaman/widget/nama_pelanggan.dart

import 'package:flutter/material.dart';
import 'package:wifi/shared/model/customer_model.dart';
import 'package:wifi/shared/operasi/customer_operation.dart';

/// Widget yang menampilkan nama pelanggan berdasarkan ID.
///
/// Mengambil data pelanggan secara async menggunakan [CustomerOperation].
/// Menampilkan '...' saat loading, 'Error' jika gagal, atau
/// 'Pelanggan tidak ditemukan' jika data null.
class CustomerNameWidget extends StatelessWidget {
  /// ID pelanggan yang akan dicari namanya.
  final String customerId;

  /// Gaya teks opsional untuk nama yang ditampilkan.
  final TextStyle? style;

  /// Membuat widget [CustomerNameWidget].
  const CustomerNameWidget({super.key, required this.customerId, this.style});

  @override
  Widget build(final BuildContext context) {
    final CustomerOperation customerOperation = CustomerOperation();

    return FutureBuilder<CustomerModel?>(
      future: customerOperation.getCustomerById(customerId),
      builder: (final context, final snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(
            '...',
            style: style ?? const TextStyle(color: Colors.grey),
          );
        }
        if (snapshot.hasError) {
          return Text(
            'Error',
            style: style ??
                const TextStyle(color: Colors.red, fontStyle: FontStyle.italic),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          return Text(
            snapshot.data!.name,
            style: style ?? const TextStyle(fontWeight: FontWeight.bold),
          );
        }
        return Text(
          'Pelanggan tidak ditemukan',
          style: style ??
              const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
        );
      },
    );
  }
}
