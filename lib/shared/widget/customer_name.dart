// path: lib/shared/widget/customer_name.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';

/// Widget yang menampilkan nama pelanggan berdasarkan ID dari dua sumber data.
///
/// Secara default, mengambil data dari SQLite. Jika [useFirebase] diatur ke true,
/// maka akan mengambil data dari Firebase secara real-time.
class CustomerNameWidget extends ConsumerWidget {
  /// ID pelanggan yang akan dicari namanya.
  final String customerId;

  /// Gaya teks opsional untuk nama yang ditampilkan.
  final TextStyle? style;

  /// Tentukan `true` untuk menggunakan Firebase, `false` (default) untuk SQLite.
  final bool useFirebase;

  const CustomerNameWidget({
    super.key,
    required this.customerId,
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
    final customerOpFirebase = ref.read(customerOpFirebaseProvider);
    return StreamBuilder<CustomerModel?>(
      stream: customerOpFirebase.ambilStreamPelanggan(customerId),
      builder: (final context, final snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('...', style: style);
        }
        if (snapshot.hasError) {
          Log.error(
            'Error di CustomerNameWidget (Firebase) untuk ID: $customerId',
            e: snapshot.error,
            st: snapshot.stackTrace,
          );
          return Text('Error',
              style: style ??
                  const TextStyle(
                      color: Colors.red, fontStyle: FontStyle.italic));
        }
        if (snapshot.hasData && snapshot.data != null) {
          return Text(
            snapshot.data!.name,
            style: style,
            overflow: TextOverflow.ellipsis,
          );
        }
        return Text('N/A',
            style: style ??
                const TextStyle(
                    color: Colors.grey, fontStyle: FontStyle.italic));
      },
    );
  }

  /// Membangun widget menggunakan data dari SQLite (Future).
  Widget _buildFromSqlite(WidgetRef ref) {
    final customerOperation = ref.read(customerOperationProvider);
    return FutureBuilder<CustomerModel?>(
      future: customerOperation.ambilBerdasarkanId(customerId),
      builder: (final context, final snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('...', style: style);
        }
        if (snapshot.hasError) {
          Log.error(
            'Error di CustomerNameWidget (SQLite) untuk ID: $customerId',
            e: snapshot.error,
            st: snapshot.stackTrace,
          );
          return Text('Error',
              style: style ??
                  const TextStyle(
                      color: Colors.red, fontStyle: FontStyle.italic));
        }
        if (snapshot.hasData && snapshot.data != null) {
          return Text(
            snapshot.data!.name,
            style: style,
            overflow: TextOverflow.ellipsis,
          );
        }
        return Text('Pelanggan tidak ditemukan',
            style: style ??
                const TextStyle(
                    color: Colors.grey, fontStyle: FontStyle.italic));
      },
    );
  }
}
