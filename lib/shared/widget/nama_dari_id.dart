// path: lib/widget/nama_dari_id.dart
import 'package:flutter/material.dart';
import 'package:admin_wifi/data/operasi/pelanggan_operasi.dart';
import 'package:admin_wifi/model/pelanggan_model.dart';

class NamaDariIdWidget extends StatelessWidget {
  final String userId;
  final TextStyle? style;

  const NamaDariIdWidget({super.key, required this.userId, this.style});

  @override
  Widget build(BuildContext context) {
    final PelangganOperasi pelangganOperasi = PelangganOperasi();

    // diubah: karena nama class yang benar adalah PelangganModel
    return FutureBuilder<PelangganModel?>(
      // PERBAIKAN: Menggunakan nama metode yang benar
      future: pelangganOperasi.getPelangganById(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return Text('User Tidak Dikenal', style: style);
        }
        final pelanggan = snapshot.data!;
        return Text(pelanggan.nama, style: style);
      },
    );
  }
}
