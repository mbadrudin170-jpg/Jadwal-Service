import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_global.dart';
import 'package:wifi/shared/debug/log.dart';

class NamaPelangganWidget extends ConsumerWidget {
  final String idPelanggan;
  final TextStyle? style;
  final bool showLoadingIndicator;

  const NamaPelangganWidget({
    super.key,
    required this.idPelanggan,
    this.style,
    this.showLoadingIndicator = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pelangganOp = ref.read(pelangganOpGlobalProvider);

    return FutureBuilder<PelangganModel?>(
      future: pelangganOp.ambilBerdasarkanId(idPelanggan),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return showLoadingIndicator
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('');
        }
        if (snapshot.hasError) {
          Log.error(
            'Gagal memuat pelanggan ID: $idPelanggan',
            e: snapshot.error,
          );
          return Text(
            'Error memuat data',
            style:
                style?.copyWith(
                  color: Colors.red,
                  fontStyle: FontStyle.italic,
                ) ??
                const TextStyle(color: Colors.red, fontStyle: FontStyle.italic),
          );
        }

        final pelanggan = snapshot.data;
        if (pelanggan == null) {
          return Text(
            'Pelanggan tidak ditemukan',
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

        return Text(
          pelanggan.nama,
          style: style,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}
