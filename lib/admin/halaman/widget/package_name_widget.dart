// path: lib/admin/halaman/widget/package_name_widget.dart
// diubah: Refactor ke Bahasa Inggris (class, method, variabel) dengan komentar Bahasa Indonesia.
// diubah: Memperbaiki import path yang salah.
// diubah: Mengganti nama file dari nama_paket.dart menjadi package_name_widget.dart.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/package_model.dart';
import 'package:wifi/shared/operasi/package_operation.dart';

class PackageNameWidget extends ConsumerWidget {
  /// ID dari paket yang akan ditampilkan namanya.
  final String packageId;

  /// Gaya teks untuk nama paket.
  final TextStyle? style;

  /// Membuat sebuah widget [PackageNameWidget].
  const PackageNameWidget({
    super.key,
    required this.packageId,
    this.style,
  });

  @override
  Widget build(final BuildContext context, WidgetRef ref) {
    Log.info('Membangun PackageNameWidget untuk packageId: $packageId');

final packageOperation = ref.read(packageOperationProvider);
    return FutureBuilder<PackageModel?>(
      future: packageOperation.getById(packageId),
      builder: (final context, final snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          Log.info('Menunggu data paket untuk ID: $packageId');
          return const Text('Loading...', style: TextStyle(color: Colors.grey));
        }
        if (snapshot.hasError) {
          Log.error('Error saat memuat paket ID: $packageId',
              e: snapshot.error);
          return const Text('Error', style: TextStyle(color: Colors.red));
        }
        if (!snapshot.hasData || snapshot.data == null) {
          Log.warning('Paket dengan ID: $packageId tidak ditemukan');
          return const Text(
            'Paket tidak ditemukan',
            style: TextStyle(color: Colors.red),
          );
        }

        final package = snapshot.data!;
        Log.info('Berhasil memuat paket: ${package.name} (ID: $packageId)');
        return Text(package.name, style: style);
      },
    );
  }
}
