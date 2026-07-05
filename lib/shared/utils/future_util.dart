// path: lib/shared/utils/future_util.dart

import 'package:wifi/shared/debug/log.dart';

/// Helper untuk menjalankan multiple Future secara paralel dengan penanganan error terpusat.
///
/// Contoh penggunaan:
/// ```dart
/// final hasil = await loadAll([
///   pelangganOp.ambilSemua(),
///   paketOp.ambilSemua(),
///   dompetOp.ambilSemua(),
/// ]);
/// ```
Future<List<Object?>> loadAll(List<Future<Object?>> futures) async {
  try {
    return await Future.wait(futures);
  } catch (e, st) {
    Log.error('Gagal memuat data paralel', e: e, s: st);
    rethrow;
  }
}

/// Versi dengan label untuk logging yang lebih baik.
///
/// Contoh:
/// ```dart
/// final hasil = await loadAllWithLabel([
///   ('pelanggan', pelangganOp.ambilSemua()),
///   ('paket', paketOp.ambilSemua()),
/// ]);
/// ```
Future<List<Object?>> loadAllWithLabel(List<(String label, Future<Object?> future)> items) async {
  try {
    final futures = items.map((e) => e.$2).toList();
    return await Future.wait(futures);
  } catch (e, st) {
    String? labelError;
    for (final item in items) {
      try {
        await item.$2.timeout(Duration.zero);
      } catch (_) {
        labelError = item.$1;
        break;
      }
    }
    Log.error('Gagal memuat data paralel: ${labelError ?? 'unknown'}', e: e, s: st);
    rethrow;
  }
}
