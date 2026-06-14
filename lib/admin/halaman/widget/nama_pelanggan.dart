// path: lib/admin/halaman/widget/nama_pelanggan.dart
// diubah: Refactor ke Bahasa Inggris (class, method, variabel) dengan komentar Bahasa Indonesia.
// diubah: Memperbaiki import path yang salah.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/shared/debug/log.dart';

/// Sebuah widget untuk menampilkan nama pelanggan berdasarkan ID pelanggan.
class CustomerNameWidget extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    Log.info('Membangun CustomerNameWidget untuk customerId: $customerId');
    final customerOperation = ref.read(pelangganOpSqliteProvider);
    return FutureBuilder<PelangganModel?>(
      future: customerOperation.ambilBerdasarkanId(customerId),
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
