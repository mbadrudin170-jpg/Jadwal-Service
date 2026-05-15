// path: lib/shared/widget/teks_pengaman_database_widget.dart

import 'package:flutter/material.dart';

/// Widget untuk menampilkan teks peringatan atau informasi terkait keamanan database.
///
/// Widget ini menerima sebuah [String?] dan menampilkannya di tengah.
/// Jika teks yang diterima adalah null, widget akan menampilkan tanda hubung ('-') secara aman.
/// Gaya teks dapat disesuaikan melalui parameter [style].
class TeksPengamanDatabaseWidget extends StatelessWidget {
  /// Teks yang akan ditampilkan. Boleh null.
  final String? teks;

  /// Gaya yang akan diterapkan pada teks. Jika null, akan menggunakan gaya default dari tema.
  final TextStyle? style;

  /// Konstruktor untuk TeksPengamanDatabaseWidget.
  const TeksPengamanDatabaseWidget({
    super.key,
    this.teks,
    this.style,
  });

  @override
  Widget build(final BuildContext context) {
    return Text(
      // Gunakan tanda hubung ('-') jika teks null. Ini mencegah error dan memberi visual.
      teks ?? '-',
      style: style ?? Theme.of(context).textTheme.bodyMedium,
    );
  }
}
