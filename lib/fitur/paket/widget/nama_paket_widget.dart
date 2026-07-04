// path: lib/fitur/paket/widget/nama_paket_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/paket/provider/paket_provider.dart';
import 'package:wifi/shared/debug/log.dart';

class NamaPaketWidget extends ConsumerWidget {
  final String idPaket;
  final TextStyle? style;
  final bool showLoadingIndicator;
  final String loadingText;
  final String errorText;
  final String emptyText;

  const NamaPaketWidget({
    super.key,
    required this.idPaket,
    this.style,
    this.showLoadingIndicator = false,
    this.loadingText = '',
    this.errorText = 'Error memuat data',
    this.emptyText = 'Paket tidak ditemukan',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (idPaket.isEmpty) {
      return Text(
        emptyText,
        style:
            style?.copyWith(color: Colors.grey, fontStyle: FontStyle.italic) ??
            const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
      );
    }
    final namaAsync = ref.watch(namaPaketProvider(idPaket));
    return namaAsync.when(
      skipLoadingOnReload: true,
      loading: () {
        if (showLoadingIndicator) {
          return const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }
        return Text(
          loadingText,
          style:
              style?.copyWith(color: Colors.grey.shade400) ??
              const TextStyle(color: Colors.grey),
        );
      },
      error: (error, stack) {
        Log.error('Gagal memuat pelanggan ID: $idPaket', e: error, s: stack);
        return Text(
          errorText,
          style:
              style?.copyWith(color: Colors.red, fontStyle: FontStyle.italic) ??
              const TextStyle(color: Colors.red, fontStyle: FontStyle.italic),
        );
      },
      data: (nama) {
        if (nama == null || nama.isEmpty) {
          return Text(
            emptyText,
            style:
                style?.copyWith(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ) ??
                const TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
          );
        }
        return Text(nama, style: style, overflow: TextOverflow.ellipsis);
      },
    );
  }
}
