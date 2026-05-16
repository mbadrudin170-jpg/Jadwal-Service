// path: lib/admin/halaman/widget/nama_pelanggan.dart
// diubah: Refactor ke Bahasa Inggris (class, method, variabel) dengan komentar Bahasa Indonesia.
// diubah: Memperbaiki import path yang salah.

import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/customer_model.dart';
import 'package:wifi/shared/operasi/customer_operation.dart';

// === INFORMASI DEPENDENCY ===
// 📂 FILE INI DIGUNAKAN OLEH:
//   - lib/admin/halaman/tab/active_customer_tab.dart (ActiveCustomerPage)
//   - lib/admin/halaman/detail/active_customer_detail.dart (ActiveCustomerDetailPage)
//   - Dan file lain yang memerlukan tampilan nama pelanggan berdasarkan ID
//
// 📂 FILE INI MENGGUNAKAN:
//   - lib/shared/model/customer_model.dart (CustomerModel)
//   - lib/shared/operasi/customer_operation.dart (CustomerOperation)
//   - lib/shared/debug/log.dart (Log)

/// Sebuah widget untuk menampilkan nama pelanggan berdasarkan ID pelanggan.
class CustomerNameWidget extends StatelessWidget {
  /// ID dari pelanggan yang akan ditampilkan namanya.
  final String customerId;

  /// Gaya teks untuk nama pelanggan.
  final TextStyle? style;

  /// Membuat sebuah widget [CustomerNameWidget].
  const CustomerNameWidget({
    super.key,
    required this.customerId,
    this.style,
  });

  @override
  Widget build(final BuildContext context) {
    Log.info('Membangun CustomerNameWidget untuk customerId: $customerId');

    final customerOperation = CustomerOperation();

    return FutureBuilder<CustomerModel?>(
      future: customerOperation.getCustomerById(customerId),
      builder: (final context, final snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          Log.info('Menunggu data pelanggan untuk ID: $customerId');
          return const Text('Loading...', style: TextStyle(color: Colors.grey));
        }
        if (snapshot.hasError) {
          Log.error('Error saat memuat pelanggan ID: $customerId',
              e: snapshot.error);
          return const Text('Error', style: TextStyle(color: Colors.red));
        }
        if (!snapshot.hasData || snapshot.data == null) {
          Log.warning('Pelanggan dengan ID: $customerId tidak ditemukan');
          return const Text(
            'Pelanggan tidak ditemukan',
            style: TextStyle(color: Colors.red),
          );
        }

        final customer = snapshot.data!;
        Log.info(
            'Berhasil memuat pelanggan: ${customer.name} (ID: $customerId)');
        return Text(customer.name, style: style);
      },
    );
  }
}
