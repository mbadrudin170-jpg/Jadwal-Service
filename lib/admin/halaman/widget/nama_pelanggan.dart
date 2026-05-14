// path: lib/admin/halaman/widget/nama_pelanggan.dart
import 'package:flutter/material.dart';
import 'package:wifi/shared/model/pelanggan_model.dart';
import 'package:wifi/shared/operasi/pelanggan_operasi.dart';

/// Sebuah widget untuk menampilkan nama pelanggan berdasarkan ID pelanggan.
class NamaPelangganWidget extends StatelessWidget {
  /// ID dari pelanggan yang akan ditampilkan namanya.
  final String idPelanggan;
  /// Gaya teks untuk nama pelanggan.
  final TextStyle? style;

  /// Membuat sebuah widget [NamaPelangganWidget].
  const NamaPelangganWidget({super.key, required this.idPelanggan, this.style});

  @override
  Widget build(final BuildContext context) {
    final PelangganOperasi pelangganOperasi = PelangganOperasi();

    return FutureBuilder<PelangganModel?>(
      future: pelangganOperasi.getPelangganById(idPelanggan),
      builder: (final context, final snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...', style: TextStyle(color: Colors.grey));
        }
        if (snapshot.hasError) {
          return const Text('Error', style: TextStyle(color: Colors.red));
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Text(
            'Pelanggan tidak ditemukan',
            style: TextStyle(color: Colors.red),
          );
        }

        final pelanggan = snapshot.data!;
        return Text(pelanggan.nama, style: style);
      },
    );
  }
}
