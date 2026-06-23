// path: lib/fitur/pelanggan_aktif/provider/pelanggan_aktif_provider.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/pelanggan_aktif/model/detail_pelanggan_aktif_model.dart';
import 'package:wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
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
    final operasi = ref.read(pelangganAktifOpSqliteProvider);
    final hasil = await operasi.ambilSemuaPelangganAktifDenganDetail();
    return PelangganAktifState(daftarPelangganAktif: hasil);
  }

  Future<void> tambahPelangganAktif(PelangganAktifModel pelangganAktif) async {
    state = await AsyncValue.guard(() async {
      final operasi = ref.read(pelangganAktifOpSqliteProvider);
      await operasi.tambahPelangganAktif(pelangganAktif);
      final hasil = await operasi.ambilSemuaPelangganAktifDenganDetail();
      return PelangganAktifState(daftarPelangganAktif: hasil);
    });
  }

  Future<void> updatePelangganAktif(PelangganAktifModel pelangganAktif) async {
    state = await AsyncValue.guard(() async {
      final operasi = ref.read(pelangganAktifOpSqliteProvider);
      await operasi.updatePelangganAktif(pelangganAktif);
      final hasil = await operasi.ambilSemuaPelangganAktifDenganDetail();
      return PelangganAktifState(daftarPelangganAktif: hasil);
    });
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
