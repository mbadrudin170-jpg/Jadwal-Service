// path: lib/widget/nama_pelanggan.dart
import 'package:flutter/material.dart';
import 'package:admin_wifi/data/operasi/pelanggan_operasi.dart';
import 'package:admin_wifi/model/pelanggan_model.dart';

class NamaPelangganWidget extends StatelessWidget {
  final String idPelanggan;
  final TextStyle? style;

  const NamaPelangganWidget({super.key, required this.idPelanggan, this.style});

  @override
  Widget build(BuildContext context) {
    final PelangganOperasi pelangganOperasi = PelangganOperasi();

    return FutureBuilder<PelangganModel?>(
      future: pelangganOperasi.getPelangganById(idPelanggan),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(
            '...',
            style: style ?? const TextStyle(color: Colors.grey),
          );
        }
        if (snapshot.hasError) {
          return Text(
            'Error',
            style:
                style ??
                const TextStyle(color: Colors.red, fontStyle: FontStyle.italic),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          return Text(
            snapshot.data!.nama,
            style: style ?? const TextStyle(fontWeight: FontWeight.bold),
          );
        }
        return Text(
          'Pelanggan tidak ditemukan',
          style:
              style ??
              const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
        );
      },
    );
  }
}
