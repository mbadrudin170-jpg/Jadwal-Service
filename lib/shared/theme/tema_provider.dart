// path: lib/shared/theme/tema_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/providers/shared_providers.dart';
import 'package:wifi/user/services/storage/layanan_penyimpanan_lokal.dart';

/// Provider tema menggunakan AsyncNotifier (modern Riverpod)
final temaProvider =
    AsyncNotifierProvider<TemaNotifier, ThemeMode>(TemaNotifier.new);

class TemaNotifier extends AsyncNotifier<ThemeMode> {
  late LayananPenyimpananLokal _penyimapananLokal;

  @override
  Future<ThemeMode> build() async {
    _penyimapananLokal = await ref.read(layananPenyimpananLokalProvider.future);
    final simpanTema = await _penyimapananLokal.ambilModeTema();
    Log.info('[ThemeNotifier] Tema awal dimuat: $simpanTema');
    return simpanTema;
  }

  /// Mengganti mode tema aplikasi
  Future<void> simpanModeTema(ThemeMode mode) async {
    final dapatkanTema = state;
    if (dapatkanTema is AsyncData && dapatkanTema.value == mode) return;

    Log.info('[ThemeNotifier] Mengatur tema: $mode');
    state = AsyncData(mode); // update state
    await _penyimapananLokal.simpanModeTema(mode);
  }

  /// Helper untuk mengecek apakah mode gelap aktif (opsional)
  bool pengecekanModeGelap(BuildContext context) {
    final tema = state.value ?? ThemeMode.system;
    if (tema == ThemeMode.system) {
      final terang = MediaQuery.of(context).platformBrightness;
      return terang == Brightness.dark;
    }
    return tema == ThemeMode.dark;
  }
}
