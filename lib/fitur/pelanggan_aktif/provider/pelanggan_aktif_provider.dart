// path: lib/fitur/pelanggan_aktif/provider/pelanggan_aktif_provider.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/pelanggan_aktif/model/detail_pelanggan_aktif_model.dart';
part 'pelanggan_aktif_provider.g.dart';
part 'pelanggan_aktif_provider.freezed.dart';

@freezed
abstract class PelangganAktifState with _$PelangganAktifState {
  const factory PelangganAktifState({
    @Default([]) List<DetailPelangganAktifModel> daftarPelangganAktif,
  }) = _PelangganAktifState;
}

@Riverpod(keepAlive: true)
class PelangganAktif extends _$PelangganAktif {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  @override
  FutureOr<PelangganAktifState> build() {
    return _ambilData();
  }

  Future<PelangganAktifState> _ambilData() async {
    // Gunakan `ref.read` karena ini ada di dalam method build
    final operasi = ref.read(pelangganAktifOpSqliteProvider);
    final hasil = await operasi.ambilSemuaPelangganAktifDenganDetail();

    return PelangganAktifState(daftarPelangganAktif: hasil);
  }

  Future<void> perbaruiData() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final data = await ref
          .read(pelangganAktifOpSqliteProvider)
          .ambilSemuaPelangganAktifDenganDetail();
      return PelangganAktifState(daftarPelangganAktif: data);
    });
  }
}
