// path: lib/shared/widget/nama_pelanggan_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';

part 'nama_pelanggan_widget.g.dart';

@riverpod
Future<PelangganModel?> namaPelangganSqlite(Ref ref, String id) {
  return ref.watch(pelangganOpSqliteProvider).ambilBerdasarkanId(id);
}

@riverpod
Stream<PelangganModel?> namaPelangganFirebase(Ref ref, String id) {
  return ref.watch(pelangganOpFirebaseProvider).ambilStreamBerdasarkanId(id);
}

class NamaPelangganWidget extends ConsumerWidget {
  final String idPelanggan;
  final TextStyle? style;
  final bool pakaiFirebase;

  const NamaPelangganWidget({
    super.key,
    required this.idPelanggan,
    this.style,
    this.pakaiFirebase = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPelanggan = pakaiFirebase
        ? ref.watch(namaPelangganFirebaseProvider(idPelanggan))
        : ref.watch(namaPelangganSqliteProvider(idPelanggan));
    return asyncPelanggan.when(
      loading: () => Text('...', style: style),
      error: (error, stack) {
        Log.error(
          'Error di NamaPelangganWidget (${pakaiFirebase ? "Firebase" : "SQLite"}) untuk ID: $idPelanggan',
          e: error,
          s: stack,
        );
        return Text(
          'Error',
          style:
              style ??
              const TextStyle(color: Colors.red, fontStyle: FontStyle.italic),
        );
      },
      data: (pelanggan) {
        if (pelanggan != null) {
          return Text(
            pelanggan.nama,
            style: style,
            overflow: TextOverflow.ellipsis,
          );
        }

        return Text(
          pakaiFirebase ? 'N/A' : 'Pelanggan tidak ditemukan',
          style:
              style ??
              const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
        );
      },
    );
  }
}
