// path: lib/data/services/navigasi_servis.dart

import 'package:flutter/material.dart';

/// [NavigasiServis] menyediakan akses global ke [NavigatorState].
/// Digunakan untuk navigasi tanpa [BuildContext], contohnya dari layanan notifikasi.
class NavigasiServis {
  /// Kunci global yang harus didaftarkan pada [MaterialApp].
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Helper untuk mendapatkan context global jika diperlukan.
  static BuildContext? get context => navigatorKey.currentContext;

  /// Helper untuk navigasi ke route tertentu secara ringkas.
  /// Contoh: NavigasiServis.navigateTo('/detail_pelanggan', arguments: data);
  static Future<dynamic>? navigateTo(final String routeName, {final Object? arguments}) {
    return navigatorKey.currentState?.pushNamed(
      routeName,
      arguments: arguments,
    );
  }
}
