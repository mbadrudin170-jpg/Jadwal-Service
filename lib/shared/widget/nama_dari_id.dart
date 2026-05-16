// path: lib/shared/widget/nama_dari_id.dart
import 'package:flutter/material.dart';
import 'package:wifi/shared/model/pelanggan_model.dart';
import 'package:wifi/shared/operasi/customer_operation.dart';

/// Widget yang menampilkan nama pelanggan berdasarkan ID.
///
/// Mengambil data pelanggan secara async menggunakan [PelangganOperasi]
/// dan menampilkan nama pelanggan. Menampilkan indikator loading saat
/// menunggu, atau 'User Tidak Dikenal' jika data tidak ditemukan.
class NamaDariIdWidget extends StatelessWidget {
  /// ID pengguna yang akan dicari namanya.
  final String userId;

  /// Gaya teks untuk nama yang ditampilkan.
  final TextStyle? style;

  /// Membuat widget [NamaDariIdWidget].
  ///
  /// [userId] wajib diisi.
  const NamaDariIdWidget({super.key, required this.userId, this.style});

  @override
  Widget build(final BuildContext context) {
    final PelangganOperasi pelangganOperasi = PelangganOperasi();

    // diubah: karena nama class yang benar adalah PelangganModel
    return FutureBuilder<PelangganModel?>(
      // PERBAIKAN: Menggunakan nama metode yang benar
      future: pelangganOperasi.getPelangganById(userId),
      builder: (final context, final snapshot) {
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
        final pelanggan = snapshot.data;
        return Text(pelanggan.nama, style: style);
      },
    );
  }
}
