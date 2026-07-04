// path: lib/fitur/pelanggan_aktif/provider/pelanggan_aktif_provider.dart

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:wifi/fitur/pelanggan_aktif/operasi/pelanggan_aktif_op_sqlite.dart';
import 'package:wifi/fitur/transaksi/operasi_provider.dart/transaksi_provider.dart';
import 'package:wifi/shared/export/model.dart';

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
    await pelangganAktifOpSqlite.tambahPelangganAktif(pelangganAktif);
    invalidatePelangganAktif();
  }

  Future<void> updatePelangganAktif(PelangganAktifModel pelangganAktif) async {
    await pelangganAktifOpSqlite.updatePelangganAktif(pelangganAktif);
    invalidatePelangganAktif();
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

  void invalidatePelangganAktif() {
    ref.invalidateSelf();
    ref.invalidate(transaksiProvider);
  }
}

@freezed
abstract class DetailPelangganAktifState with _$DetailPelangganAktifState {
  const factory DetailPelangganAktifState({
    required PelangganAktifModel pelangganAktif,
    required PelangganModel pelanggan,
    required TransaksiModel transaksi,
    required PaketModel paket,
  }) = _DetailPelangganAktifState;
}

@riverpod
Future<void> detailPelangganAktif(Ref ref) async {
  final pelangganAktifOpSqlite = ref.read(pelangganAktifOpSqliteProvider);
  await pelangganAktifOpSqlite.ambilSemuaPelangganAktifDenganDetail();
  return;
}
