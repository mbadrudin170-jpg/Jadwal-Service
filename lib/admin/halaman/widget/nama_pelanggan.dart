import 'package:flutter/material.dart';
import 'package:wifi/shared/model/pelanggan_model.dart';
import 'package:wifi/shared/operasi/pelanggan_operasi.dart';

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
          return const Text('Loading...', style: TextStyle(color: Colors.grey));
        }
        if (snapshot.hasError) {
          return const Text('Error', style: TextStyle(color: Colors.red));
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Text('Pelanggan tidak ditemukan', style: TextStyle(color: Colors.red));
        }

        final pelanggan = snapshot.data!;
        return Text(pelanggan.nama, style: style);
      },
    );
  }
}
