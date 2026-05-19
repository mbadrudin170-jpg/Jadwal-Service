// path: lib/shared/widget/package_name.dart
// digunakan oleh: lib/user/page/riwayat_langganan_user.dart
// ditambah: Menambahkan logging untuk error di FutureBuilder.

import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/package_model.dart';

/// Widget yang menampilkan nama paket berdasarkan Future yang diberikan.
///
/// Widget ini didekopling dari sumber data. Ia hanya menerima [packageFuture]
/// dan menampilkan hasilnya. Menampilkan indikator loading saat menunggu,
/// atau 'Paket tidak tersedia' jika data null atau error.
class PackageNameWidget extends StatelessWidget {
  /// Future yang mengembalikan [PackageModel] untuk ditampilkan namanya.
  final Future<PackageModel?> packageFuture;

  /// Gaya teks opsional untuk nama paket.
  final TextStyle? style;

  /// Membuat widget [PackageNameWidget].
  const PackageNameWidget({super.key, required this.packageFuture, this.style});

  @override
  Widget build(final BuildContext context) {
    return FutureBuilder<PackageModel?>(
      future: packageFuture,
      builder: (final context, final snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }

        // ditambah: Pengecekan error yang eksplisit dengan logging.
        if (snapshot.hasError) {
          Log.error(
            'Error di PackageNameWidget saat memuat paket',
            e: snapshot.error,
            st: snapshot.stackTrace,
          );
          return Text(
            'Error',
            style: style?.copyWith(color: Colors.red, fontStyle: FontStyle.italic),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Text(
            'Paket tidak tersedia',
            style: style?.copyWith(color: Colors.grey, fontStyle: FontStyle.italic),
          );
        }

        return Text(snapshot.data!.name, style: style);
      },
    );
  }
}
