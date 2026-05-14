// path: lib/admin/halaman/widget/nama_paket.dart
import 'package:flutter/material.dart';
import 'package:wifi/shared/model/paket_model.dart';
import 'package:wifi/shared/operasi/paket_operasi.dart';

/// Sebuah widget untuk menampilkan nama paket berdasarkan ID paket.
class NamaPaketWidget extends StatelessWidget {
  /// ID dari paket yang akan ditampilkan namanya.
  final String idPaket;
  /// Gaya teks untuk nama paket.
  final TextStyle? style;

  /// Membuat sebuah widget [NamaPaketWidget].
  const NamaPaketWidget({super.key, required this.idPaket, this.style});

  @override
  Widget build(final BuildContext context) {
    final PaketOperasi paketOperasi = PaketOperasi();

    return FutureBuilder<PaketModel?>(
      future: paketOperasi.getPaketById(idPaket),
      builder: (final context, final snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...', style: TextStyle(color: Colors.grey));
        }
        if (snapshot.hasError) {
          return const Text('Error', style: TextStyle(color: Colors.red));
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Text(
            'Paket tidak ditemukan',
            style: TextStyle(color: Colors.red),
          );
        }

        final paket = snapshot.data!;
        return Text(paket.nama, style: style);
      },
    );
  }
}
