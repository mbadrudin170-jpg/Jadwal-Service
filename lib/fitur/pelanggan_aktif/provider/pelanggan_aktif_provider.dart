// path: lib/fitur/pelanggan_aktif/provider/pelanggan_aktif_provider.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/pelanggan_aktif/model/detail_pelanggan_aktif_model.dart';
import 'package:wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:wifi/fitur/pelanggan_aktif/operasi/pelanggan_aktif_op_sqlite.dart';
part 'pelanggan_aktif_provider.g.dart';
part 'pelanggan_aktif_provider.freezed.dart';

@freezed
abstract class PelangganAktifState with _$PelangganAktifState {
  const factory PelangganAktifState({
    @Default([]) List<DetailPelangganAktifModel> daftarPelangganAktif,
    @Default(0) int jumlahPelangganAktif,
  }) = _PelangganAktifState;
}

@Riverpod(keepAlive: true)
class PelangganAktif extends _$PelangganAktif {
  PelangganAktifOpSqlite get pelangganAktifOpSqlite =>
      ref.watch(pelangganAktifOpSqliteProvider);
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  FutureOr<PelangganAktifState> build() {
    return _ambilData();
  }

  Future<PelangganAktifState> _ambilData() async {
    final operasi = ref.read(pelangganAktifOpSqliteProvider);
    final hasil = await operasi.ambilSemuaPelangganAktifDenganDetail();
    return PelangganAktifState(
      daftarPelangganAktif: hasil,
      jumlahPelangganAktif: hasil.length,
    );
  }

  Future<void> tambahPelangganAktif(PelangganAktifModel pelangganAktif) async {
    state = await AsyncValue.guard(() async {
      await pelangganAktifOpSqlite.tambahPelangganAktif(pelangganAktif);
      final hasil = await pelangganAktifOpSqlite
          .ambilSemuaPelangganAktifDenganDetail();
      return PelangganAktifState(
        daftarPelangganAktif: hasil,
        jumlahPelangganAktif: hasil.length,
      );
    });
  }

  Future<void> updatePelangganAktif(PelangganAktifModel pelangganAktif) async {
    state = await AsyncValue.guard(() async {
      await pelangganAktifOpSqlite.updatePelangganAktif(pelangganAktif);
      final hasil = await pelangganAktifOpSqlite
          .ambilSemuaPelangganAktifDenganDetail();
      return PelangganAktifState(
        daftarPelangganAktif: hasil,
        jumlahPelangganAktif: hasil.length,
      );
    });
  }

  Future<void> perbaruiData() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final data = await pelangganAktifOpSqlite
          .ambilSemuaPelangganAktifDenganDetail();
      return PelangganAktifState(
        daftarPelangganAktif: data,
        jumlahPelangganAktif: data.length,
      );
    });
  }
}
