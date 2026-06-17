// path: lib/shared/widget/nama_pelanggan_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';

/// Widget yang menampilkan nama pelanggan berdasarkan ID dari dua sumber data.
///
/// Secara default, mengambil data dari SQLite. Jika [useFirebase] diatur ke true,
/// maka akan mengambil data dari Firebase secara real-time.
class NamaPelangganWidget extends ConsumerWidget {
  /// ID pelanggan yang akan dicari namanya.
  final String idPelanggan;

  /// Gaya teks opsional untuk nama yang ditampilkan.
  final TextStyle? style;

  /// Tentukan `true` untuk menggunakan Firebase, `false` (default) untuk SQLite.
  final bool useFirebase;

  const NamaPelangganWidget({
    super.key,
    required this.idPelanggan,
    this.style,
    this.useFirebase = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (useFirebase) {
      return _buildFromFirebase(ref);
    }
    return _buildFromSqlite(ref);
  }

  /// Membangun widget menggunakan data dari Firebase (Stream).
  Widget _buildFromFirebase(WidgetRef ref) {
    final customerOpFirebase = ref.read(pelangganOpFirebaseProvider);
    return StreamBuilder<PelangganModel?>(
      stream: customerOpFirebase.ambilStreamBerdasarkanId(idPelanggan),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('...', style: style);
        }
        if (snapshot.hasError) {
          Log.error(
            'Error di CustomerNameWidget (Firebase) untuk ID: $idPelanggan',
            e: snapshot.error,
            s: snapshot.stackTrace,
          );
          return Text(
            'Error',
            style:
                style ??
                const TextStyle(color: Colors.red, fontStyle: FontStyle.italic),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          return Text(
            snapshot.data!.nama,
            style: style,
            overflow: TextOverflow.ellipsis,
          );
        }
        return Text(
          'N/A',
          style:
              style ??
              const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
        );
      },
    );
  }

  /// Membangun widget menggunakan data dari SQLite (Future).
  Widget _buildFromSqlite(WidgetRef ref) {
    final customerOperation = ref.read(pelangganOpSqliteProvider);
    return FutureBuilder<PelangganModel?>(
      future: customerOperation.ambilBerdasarkanId(idPelanggan),
      builder: (final context, final snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('...', style: style);
        }
        if (snapshot.hasError) {
          Log.error(
            'Error di CustomerNameWidget (SQLite) untuk ID: $idPelanggan',
            e: snapshot.error,
            s: snapshot.stackTrace,
          );
          return Text(
            'Error',
            style:
                style ??
                const TextStyle(color: Colors.red, fontStyle: FontStyle.italic),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          return Text(
            snapshot.data!.nama,
            style: style,
            overflow: TextOverflow.ellipsis,
          );
        }
        return Text(
          'Pelanggan tidak ditemukan',
          style:
              style ??
              const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
        );
      },
    );
  }
}
