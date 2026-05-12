// path: lib/widget/nama_paket.dart
// Widget ini berfungsi untuk menampilkan nama paket berdasarkan ID.

import 'package:admin_wifi/data/operasi/paket_operasi.dart';
import 'package:admin_wifi/model/paket_model.dart';
import 'package:flutter/material.dart';

class NamaPaketWidget extends StatelessWidget {
  final String idPaket;
  final TextStyle? style;

  const NamaPaketWidget({super.key, required this.idPaket, this.style});

  @override
  Widget build(BuildContext context) {
    final PaketOperasi paketOperasi = PaketOperasi();

    // diubah: karena nama class yang benar adalah PaketModel
    return FutureBuilder<PaketModel?>(
      // diubah: Menggunakan fungsi baru getPaketById untuk efisiensi
      future: paketOperasi.getPaketById(idPaket),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // diubah: Menampilkan indikator loading yang lebih halus.
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
