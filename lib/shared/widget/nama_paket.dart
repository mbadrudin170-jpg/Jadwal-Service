// path: lib/shared/widget/nama_paket.dart
// diubah: Widget didekopling dari sumber data. Sekarang hanya menerima Future.

import 'package:flutter/material.dart';
import 'package:wifi/shared/model/paket_model.dart';

/// Widget yang menampilkan nama paket berdasarkan Future yang diberikan.
///
/// Widget ini didekopling dari sumber data. Ia hanya menerima [paketFuture]
/// dan menampilkan hasilnya. Menampilkan indikator loading saat menunggu,
/// atau 'Paket tidak tersedia' jika data null atau error.
class NamaPaketWidget extends StatelessWidget {
  /// Future yang mengembalikan [PaketModel] untuk ditampilkan namanya.
  final Future<PaketModel?> paketFuture;

  /// Gaya teks opsional untuk nama paket.
  final TextStyle? style;

  /// Membuat widget [NamaPaketWidget].
  ///
  /// [paketFuture] wajib diisi.
  const NamaPaketWidget({super.key, required this.paketFuture, this.style});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PaketModel?>(
      future: paketFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        } else if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data == null) {
          return Text(
            'Paket tidak tersedia',
            style: style?.copyWith(color: Colors.red),
          );
        } else {
          return Text(snapshot.data!.nama, style: style);
        }
      },
    );
  }
}
