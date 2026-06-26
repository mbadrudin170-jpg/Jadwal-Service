// path: lib/fitur/paket/provider/paket_provider.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/paket/operasi/paket_op_sqlite.dart';
import 'package:wifi/fitur/paket/page/paket.dart';
import 'package:wifi/shared/debug/log.dart';

part 'paket_provider.g.dart';
part 'paket_provider.freezed.dart';

@freezed
abstract class PaketState with _$PaketState {
  const factory PaketState({
    @Default([]) List<PaketModel> daftarPaket,
    @Default([]) List<PaketModel> daftarPaketPublik,
    @Default(0) int jumlahPaket,
  }) = _PaketState;
}

@Riverpod(keepAlive: true)
class Paket extends _$Paket {
  PaketOpSqlite get _paketOpSqlite => ref.read(paketOpSqliteProvider);

  @override
  FutureOr<PaketState> build() async {
    return _ambilData();
  }

  Future<PaketState> _ambilData() async {
    final daftarpaket = await _paketOpSqlite.ambilSemua();
    final daftarPaketPublik = await _paketOpSqlite.ambilPaketPublik();
    return PaketState(
      daftarPaket: daftarpaket,
      jumlahPaket: daftarpaket.length,
      daftarPaketPublik: daftarPaketPublik,
    );
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
  final paketOpSqlite = ref.watch(paketOpSqliteProvider);
  final paket = await paketOpSqlite.ambilBerdasarkanId(id);
  if (paket == null) {
    throw Exception('Paket dengan id $id tidak ditemukan');
  }
  return paket;
}
