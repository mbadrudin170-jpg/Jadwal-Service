// path: lib/shared/widget/nama_pelanggan.dart
import 'package:flutter/material.dart';
import 'package:wifi/shared/model/pelanggan_model.dart';
import 'package:wifi/shared/operasi/pelanggan_operasi.dart';

/// Widget yang menampilkan nama pelanggan berdasarkan ID.
///
/// Mengambil data pelanggan secara async menggunakan [PelangganOperasi].
/// Menampilkan '...' saat loading, 'Error' jika gagal, atau
/// 'Pelanggan tidak ditemukan' jika data null.
class NamaPelangganWidget extends StatelessWidget {
  /// ID pelanggan yang akan dicari namanya.
  final String idPelanggan;

  /// Gaya teks opsional untuk nama yang ditampilkan.
  final TextStyle? style;

  /// Membuat widget [NamaPelangganWidget].
  ///
  /// [idPelanggan] wajib diisi.
  const NamaPelangganWidget({super.key, required this.idPelanggan, this.style});

  @override
  Widget build(final BuildContext context) {
    final PelangganOperasi pelangganOperasi = PelangganOperasi();

    return FutureBuilder<PelangganModel?>(
      future: pelangganOperasi.getPelangganById(idPelanggan),
      builder: (final context, final snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(
            '...',
            style: style ?? const TextStyle(color: Colors.grey),
          );
        }
        if (snapshot.hasError) {
          return Text(
            'Error',
            style: style ??
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
          style: style ??
              const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
        );
      },
    );
  }
}
