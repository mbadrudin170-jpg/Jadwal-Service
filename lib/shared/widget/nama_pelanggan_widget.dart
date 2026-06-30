// path: lib/shared/widget/nama_pelanggan_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan/provider/pelanggan_provider.dart';
import 'package:wifi/shared/debug/log.dart';

class NamaPelangganWidget extends ConsumerWidget {
  final String idPelanggan;
  final TextStyle? style;
  final bool showLoadingIndicator;
  final String loadingText;
  final String errorText;
  final String emptyText;

  const NamaPelangganWidget({
    super.key,
    required this.idPelanggan,
    this.style,
    this.showLoadingIndicator = false,
    this.loadingText = '',
    this.errorText = 'Error memuat data',
    this.emptyText = 'Pelanggan tidak ditemukan',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final namaAsync = ref.watch(namaPelangganProvider(idPelanggan));

    return namaAsync.when(
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
        Log.error(
          'Gagal memuat pelanggan ID: $idPelanggan',
          e: error,
          s: stack,
        );
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

/// Widget yang mengembalikan data pelanggan lengkap
class PelangganDetailWidget extends ConsumerWidget {
  final String idPelanggan;
  final Widget Function(PelangganModel pelanggan) builder;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Widget? emptyWidget;

  const PelangganDetailWidget({
    super.key,
    required this.idPelanggan,
    required this.builder,
    this.loadingWidget,
    this.errorWidget,
    this.emptyWidget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pelangganAsync = ref.watch(pelangganDetailProvider(idPelanggan));

    return pelangganAsync.when(
      loading: () =>
          loadingWidget ??
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
      error: (error, stack) {
        Log.error(
          'Gagal memuat pelanggan ID: $idPelanggan',
          e: error,
          s: stack,
        );
        return errorWidget ??
            Text(
              'Error',
              style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic),
            );
      },
      data: (pelanggan) {
        return builder(pelanggan as PelangganModel);
      },
    );
  }
}
