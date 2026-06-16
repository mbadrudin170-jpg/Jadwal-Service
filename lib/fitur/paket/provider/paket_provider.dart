// path: lib/fitur/paket/provider/paket_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/paket/page/paket.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/shared/debug/log.dart';

part 'paket_provider.g.dart';

@riverpod
Future<List<PaketModel>> daftarPaket(Ref ref) async {
  Log.info('Mendapatkan daftar paket aktif dari SQLite via paketProvider...');

  final paketOpSqlite = ref.watch(paketOpSqliteProvider);
  return await paketOpSqlite.ambilBerdasarkanAktif();
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
