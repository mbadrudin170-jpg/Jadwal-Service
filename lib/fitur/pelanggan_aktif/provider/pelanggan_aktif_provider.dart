// path: lib/fitur/pelanggan_aktif/provider/pelanggan_aktif_provider.dart

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/paket/provider/paket_provider.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan/provider/pelanggan_provider.dart';
import 'package:wifi/fitur/pelanggan_aktif/helper/pengurut_pelanggan_aktif.dart';
import 'package:wifi/fitur/pelanggan_aktif/model/detail_pelanggan_aktif_model.dart';
import 'package:wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:wifi/fitur/pelanggan_aktif/operasi/pelanggan_aktif_op_sqlite.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/shared/debug/log.dart';

part 'pelanggan_aktif_provider.g.dart';
part 'pelanggan_aktif_provider.freezed.dart';

@freezed
abstract class PelangganAktifState with _$PelangganAktifState {
  const PelangganAktifState._();
  const factory PelangganAktifState({
    @Default([]) List<PelangganAktifModel> daftarPelangganAktif,
    @Default(0) int jumlahPelangganAktif,
  }) = _PelangganAktifState;

  PelangganAktifModel? ambilBerdasarkanId(String idPelangganAktif) {
    return daftarPelangganAktif.firstWhereOrNull(
      (p) => p.id == idPelangganAktif,
    );
  }
}

@Riverpod(keepAlive: true)
class PelangganAktif extends _$PelangganAktif {
  PelangganAktifOpSqlite get pelangganAktifOpSqlite =>
      ref.read(pelangganAktifOpSqliteProvider);

  @override
  FutureOr<PelangganAktifState> build() {
    return _ambilData();
  }

  Future<PelangganAktifState> _ambilData() async {
    final operasi = ref.read(pelangganAktifOpSqliteProvider);
    final hasil = await operasi.ambilSemua();
    return PelangganAktifState(
      daftarPelangganAktif: hasil,
      jumlahPelangganAktif: hasil.length,
    );
  }

  Future<void> tambah(PelangganAktifModel pelangganAktif) async {
    try {
      if (!state.hasValue) return;
      await pelangganAktifOpSqlite.tambahPelangganAktif(pelangganAktif);
      final currentData = state.requireValue;
      state = AsyncData(
        currentData.copyWith(
          daftarPelangganAktif: [
            ...currentData.daftarPelangganAktif,
            pelangganAktif,
          ],
        ),
      );
    } on Exception catch (e, s) {
      Log.error('Error ditambah: $e', e: e, s: s);
      rethrow;
    }
  }

  Future<void> perbarui(PelangganAktifModel pelangganAktif) async {
    try {
      if (!state.hasValue) return;
      await pelangganAktifOpSqlite.updatePelangganAktif(pelangganAktif);
      final currentData = state.requireValue;
      final updatedList = currentData.daftarPelangganAktif.map((t) {
        return t.id == pelangganAktif.id ? pelangganAktif : t;
      }).toList();
      state = AsyncData(
        currentData.copyWith(daftarPelangganAktif: updatedList),
      );
    } on Exception catch (e, s) {
      Log.error('Error perbarui: $e', e: e, s: s);
      rethrow;
    }
  }

  Future<void> hapus(String idPelangganAktif) async {
    try {
      if (!state.hasValue) return;
      await pelangganAktifOpSqlite.softDelete(idPelangganAktif);
      final currentData = state.requireValue;
      final updatedList = currentData.daftarPelangganAktif
          .where((t) => t.id != idPelangganAktif)
          .toList();
      state = AsyncData(
        currentData.copyWith(daftarPelangganAktif: updatedList),
      );
    } on Exception catch (e, s) {
      Log.error('Error hapus: $e', e: e, s: s);
      rethrow;
    }
  }

  Future<void> softDeleteAll() async {
    try {
      if (!state.hasValue) return;
      await pelangganAktifOpSqlite.softDeleteAll();
      final currentData = state.requireValue;
      state = AsyncData(currentData.copyWith(daftarPelangganAktif: []));
    } on Exception catch (e, s) {
      Log.error('Error hapus semua: $e', e: e, s: s);
      rethrow;
    }
  }

  Future<void> perbaruiData() async {
    try {
      await _ambilData();
    } on Exception catch (e, s) {
      Log.error('Error diperbaruiData: $e', e: e, s: s);
      rethrow;
    }
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

@riverpod
Future<List<DetailPelangganAktifModel>> daftarPelangganAktifTerurut(
  Ref ref,
) async {
  final pelangganAktifState = await ref.watch(pelangganAktifProvider.future);
  final pelangganState = await ref.watch(pelangganProvider.future);
  final paketState = await ref.watch(paketProvider.future);

  final daftarDetail = pelangganAktifState.daftarPelangganAktif.map((pa) {
    final pelanggan = pelangganState.ambilBerdasarkanId(pa.idPelanggan);
    final paket = paketState.ambilBerdasarkanId(pa.idPaket);
    return DetailPelangganAktifModel(
      pelangganAktif: pa,
      namaPelanggan: pelanggan?.nama ?? '',
      namaPaket: paket?.nama ?? '',
    );
  }).toList();

  final sortBy = ref.watch(urutanPelangganAktifStateProvider);
  return urutkanPelangganAktif(daftarDetail, sortBy);
}
