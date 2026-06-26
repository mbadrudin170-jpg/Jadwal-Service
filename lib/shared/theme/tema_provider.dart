// path: lib/shared/theme/tema_provider.dart

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/providers/shared_providers.dart';
import 'package:wifi/user/services/storage/layanan_penyimpanan_lokal.dart';

part 'tema_provider.g.dart'; // Pastikan jalankan build_runner setelah ini

@Riverpod(keepAlive: true)
class Tema extends _$Tema {
  late LayananPenyimpananLokal _penyimpananLokal;

  @override
  Future<ThemeMode> build() async {
    _penyimpananLokal = await ref.read(layananPenyimpananLokalProvider.future);
    final simpanTema = await _penyimpananLokal.ambilModeTema();
    Log.info('[TemaNotifier] Tema awal dimuat: $simpanTema');
    return simpanTema;
  }

  Future<void> simpanModeTema(ThemeMode mode) async {
    if (state.value == mode) return;
    Log.info('[TemaNotifier] Mengatur tema: $mode');
    state = AsyncData(mode);
    await _penyimpananLokal.simpanModeTema(mode);
  }

  /// Helper untuk mengecek apakah mode gelap aktif
  bool pengecekanModeGelap(BuildContext context) {
    final tema = state.value ?? ThemeMode.system;
    if (tema == ThemeMode.system) {
      final terang = MediaQuery.of(context).platformBrightness;
      return terang == Brightness.dark;
    }
    return tema == ThemeMode.dark;
  }
}
