// path: lib/shared/widgets/custom_future_builder.dart
// Dibuat: Widget generik untuk menyederhanakan penggunaan FutureBuilder.

import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';

/// Widget generik untuk menangani status Future (loading, error, data)
/// dengan cara yang konsisten dan ringkas.
///
/// [T] adalah tipe data yang diharapkan dari [future].
class CustomFutureBuilder<T> extends StatelessWidget {
  /// Future yang akan dieksekusi.
  final Future<T>? future;

  /// Builder yang dipanggil saat [future] selesai dan menghasilkan data.
  /// Wajib diisi.
  final Widget Function(BuildContext context, T data) dataBuilder;

  /// Builder opsional yang dipanggil saat [future] sedang dalam proses.
  /// Jika null, akan menampilkan [CircularProgressIndicator] kecil secara default.
  final WidgetBuilder? loadingBuilder;

  /// Builder opsional yang dipanggil saat [future] menghasilkan error.
  /// Jika null, akan menampilkan Text 'Error' berwarna merah secara default.
  final Widget Function(BuildContext context, Object error, StackTrace? stack)?
      errorBuilder;
  
  /// Builder opsional yang dipanggil saat [future] selesai tetapi tidak memiliki data.
  /// Jika null, akan menampilkan Text '-' secara default.
  final WidgetBuilder? noDataBuilder;

  const CustomFutureBuilder({
    super.key,
    required this.future,
    required this.dataBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.noDataBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        // 1. Handle Loading State
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingBuilder?.call(context) ??
              const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2.0),
              );
        }

        // 2. Handle Error State
        if (snapshot.hasError) {
          // Log error secara otomatis
          Log.error(
            'Error di dalam CustomFutureBuilder',
            e: snapshot.error,
            st: snapshot.stackTrace,
          );
          return errorBuilder?.call(context, snapshot.error!, snapshot.stackTrace) ??
              const Text(
                'Error',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              );
        }

        // 3. Handle Data State
        if (snapshot.hasData) {
          final data = snapshot.data;
          // Periksa jika data adalah list dan kosong
          if (data is List && data.isEmpty) {
             return noDataBuilder?.call(context) ?? const Text('-');
          }
          // Periksa jika data adalah null
          if (data == null){
            return noDataBuilder?.call(context) ?? const Text('-');
          }
          return dataBuilder(context, data);
        }

        // 4. Fallback (No Data or Future is null)
        return noDataBuilder?.call(context) ?? const Text('-');
      },
    );
  }
}
