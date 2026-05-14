// path: lib/admin/halaman/widget/info_detail.dart

import 'package:flutter/material.dart';

/// Widget untuk menampilkan informasi dengan format label dan nilai.
///
/// Berguna untuk menampilkan detail data di halaman admin.
class InfoDetail extends StatelessWidget {
  /// Label atau judul informasi.
  final String label;

  /// Nilai atau isi dari informasi.
  final String value;

  /// Membuat widget [InfoDetail] dengan [label] dan [value] yang wajib diisi.
  const InfoDetail({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(final BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
