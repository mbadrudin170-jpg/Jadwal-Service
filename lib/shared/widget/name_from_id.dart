// path: lib/shared/widget/name_from_id.dart
// digunakan oleh: beberapa file admin & user

import 'package:flutter/material.dart';
import 'package:wifi/shared/model/customer_model.dart';
import 'package:wifi/shared/operasi/customer_operation.dart';

/// Widget yang menampilkan nama pelanggan berdasarkan ID.
///
/// Mengambil data pelanggan secara async menggunakan [CustomerOperation]
/// dan menampilkan nama pelanggan. Menampilkan indikator loading saat
/// menunggu, atau 'User Tidak Dikenal' jika data tidak ditemukan.
class NameFromIdWidget extends StatelessWidget {
  /// ID pengguna yang akan dicari namanya.
  final String userId;

  /// Gaya teks untuk nama yang ditampilkan.
  final TextStyle? style;

  /// Membuat widget [NameFromIdWidget].
  const NameFromIdWidget({super.key, required this.userId, this.style});

  @override
  Widget build(final BuildContext context) {
    final CustomerOperation customerOperation = CustomerOperation();

    return FutureBuilder<CustomerModel?>(
      future: customerOperation.getCustomerById(userId),
      builder: (final context, final snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return Text('User Tidak Dikenal', style: style);
        }
        final customer = snapshot.data;
        return Text(customer!.name, style: style);
      },
    );
  }
}
