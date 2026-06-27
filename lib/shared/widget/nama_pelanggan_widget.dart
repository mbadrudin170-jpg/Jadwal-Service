import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_global.dart';
import 'package:wifi/shared/debug/log.dart';

class NamaPelangganWidget extends ConsumerWidget {
  final String idPelanggan;
  final TextStyle? style;

  const NamaPelangganWidget({super.key, required this.idPelanggan, this.style});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pelangganOp = ref.read(pelangganOpGlobalProvider);

    return FutureBuilder<PelangganModel?>(
      future: pelangganOp.ambilBerdasarkanId(idPelanggan),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Memuat...', style: TextStyle(color: Colors.grey));
        }
        if (snapshot.hasError) {
          Log.error(
            'Gagal memuat pelanggan ID: $idPelanggan',
            e: snapshot.error,
          );
          return Text(
            'Error memuat data',
            style:
                style ??
                const TextStyle(color: Colors.red, fontStyle: FontStyle.italic),
          );
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return Text(
            'Pelanggan tidak ditemukan',
            style:
                style ??
                const TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
          );
        }
        return Text(
          snapshot.data!.nama,
          style: style,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}
