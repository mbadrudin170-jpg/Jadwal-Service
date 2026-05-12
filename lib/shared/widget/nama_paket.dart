// path: lib/shared/widget/nama_paket.dart
// diubah: Widget didekopling dari sumber data. Sekarang hanya menerima Future.

import 'package:flutter/material.dart';
import 'package:wifi/shared/model/paket_model.dart';

class NamaPaketWidget extends StatelessWidget {
  // diubah: Tidak lagi menerima idPaket, tapi langsung sebuah Future.
  final Future<PaketModel?> paketFuture;
  final TextStyle? style;

  const NamaPaketWidget({super.key, required this.paketFuture, this.style});

  @override
  Widget build(BuildContext context) {
    // diubah: Tidak ada lagi logika pengambilan data di sini.
    return FutureBuilder<PaketModel?>(
      // diubah: Menggunakan future yang diberikan dari luar.
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
