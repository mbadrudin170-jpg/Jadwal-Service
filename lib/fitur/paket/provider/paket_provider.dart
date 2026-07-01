// path: lib/fitur/paket/provider/paket_provider.dart

import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/paket/operasi/paket_op_global.dart';
import 'package:wifi/fitur/paket/page/paket.dart';
import 'package:wifi/shared/debug/log.dart';

part 'paket_provider.g.dart';
part 'paket_provider.freezed.dart';

@freezed
abstract class PaketState with _$PaketState {
  const factory PaketState({
    @Default([]) List<PaketModel?> daftarPaket,
    @Default([]) List<PaketModel?> daftarPaketPublik,
    @Default(0) int jumlahPaket,
  }) = _PaketState;
}

@Riverpod(keepAlive: true)
class Paket extends _$Paket {
  PaketOpGlobal get _paketOp => ref.read(paketOpGlobalProvider);
  @override
  FutureOr<PaketState> build() async {
    return _ambilData();
  }

  Future<PaketState> _ambilData() async {
    final daftarpaket = await _paketOp.ambilSemua();
    final daftarPaketPublik = await _paketOp.ambilPaketPublik();

    return PaketState(
      daftarPaket: daftarpaket,
      jumlahPaket: daftarpaket.length,
      daftarPaketPublik: daftarPaketPublik,
    );
  }

  Future<void> tambah(PaketModel paket) async {
    try {
      await _paketOp.tambahPaket(paket);
      unawaited(invalidateProviderPaket());
    } on Exception catch (e, s) {
      Log.error('Error di tambah: $e', e: e, s: s);
      rethrow;
    }
  }

  Future<void> perbarui(PaketModel paket) async {
    try {
      await _paketOp.perbaruiPaket(paket);
      unawaited(invalidateProviderPaket());
    } on Exception catch (e, s) {
      Log.error('Error diupdate: $e', e: e, s: s);
      rethrow;
    }
  }

  Future<void> softDelete(String id) async {
    try {
      await _paketOp.softDelete(id);
      unawaited(invalidateProviderPaket());
    } on Exception catch (e, s) {
      Log.error('Error disoftDelete: $e', e: e, s: s);
      rethrow;
    }
  }

  Future<void> refresh() async {
    Log.info('PaketProvider: Menyegarkan data paket');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _ambilData();
    });
    Log.info('PaketProvider: Penyegaran data paket selesai');
  }

  Future<void> invalidateProviderPaket() async {
    ref.invalidateSelf();
    ref.invalidate(detailPaketProvider);
    ref.invalidate(urutanPaketStateProvider);
  }
}

@riverpod
class UrutanPaketState extends _$UrutanPaketState {
  @override
  UrutanPaket build() {
    return UrutanPaket.durasiTerpendek;
  }

  void ubahUrutan(UrutanPaket urutanBaru) {
    state = urutanBaru;
  }
}

@riverpod
Future<PaketModel> detailPaket(Ref ref, String id) async {
  Log.info('Mendapatkan detail paket dari SQLite via paketProvider...');
  final paketOp = ref.watch(paketOpGlobalProvider);
  final paket = await paketOp.ambilBerdasarkanId(id);
  if (paket == null) {
    throw Exception('Paket dengan id $id tidak ditemukan');
  }
  return paket;
}

@riverpod
Future<String?> namaPaket(Ref ref, String idPaket) async {
  if (idPaket.isEmpty) return null;
  final paketState = await ref.watch(paketProvider.future);
  final paket = paketState.daftarPaket.firstWhere((p) => p!.id == idPaket);
  if (paket == null) return null;
  return paket.nama;
}
