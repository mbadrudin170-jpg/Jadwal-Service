// path: lib/admin/halaman/widget/nama_paket_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/shared/debug/log.dart';

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

    final packageOperation = ref.read(paketOpSqliteProvider);
    return FutureBuilder<PaketModel?>(
      future: packageOperation.ambilBerdasarkanId(packageId),
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
