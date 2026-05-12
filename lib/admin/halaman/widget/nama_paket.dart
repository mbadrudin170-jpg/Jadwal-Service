import 'package:flutter/material.dart';
import 'package:wifi/shared/model/paket_model.dart';
import 'package:wifi/shared/operasi/paket_operasi.dart';

class NamaPaketWidget extends StatelessWidget {
  final String idPaket;
  final TextStyle? style;

  const NamaPaketWidget({super.key, required this.idPaket, this.style});

  @override
  Widget build(BuildContext context) {
    final PaketOperasi paketOperasi = PaketOperasi();

    return FutureBuilder<PaketModel?>(
      future: paketOperasi.getPaketById(idPaket),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...', style: TextStyle(color: Colors.grey));
        }
        if (snapshot.hasError) {
          return const Text('Error', style: TextStyle(color: Colors.red));
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Text('Paket tidak ditemukan', style: TextStyle(color: Colors.red));
        }

        final paket = snapshot.data!;
        return Text(paket.nama, style: style);
      },
    );
  }
}
