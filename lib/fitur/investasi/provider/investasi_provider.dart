// path: lib/fitur/investasi/provider/investasi_provider.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/investasi/model/dividen_model.dart';
import 'package:wifi/fitur/investasi/model/investasi_model.dart';
import 'package:wifi/fitur/investasi/operasi/investasi_op_global.dart';
import 'package:wifi/shared/debug/log.dart';

part 'investasi_provider.freezed.dart';
part 'investasi_provider.g.dart';

@freezed
abstract class InvestasiState with _$InvestasiState {
  const InvestasiState._();
  const factory InvestasiState({
    @Default([]) List<InvestasiModel> daftarInvestasi,
    @Default([]) List<DividenModel> daftarDividen,
    @Default(0) int jumlahInvestasi,
    @Default(0) int jumlahDividen,
    @Default(0.0) double totalModal,
    @Default(0.0) double totalDividenDiterima,
    @Default(0.0) double totalDividenBelumDibayar,
  }) = _InvestasiState;

  InvestasiModel? ambilInvestasiById(String id) {
    try {
      return daftarInvestasi.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  List<InvestasiModel> ambilInvestasiByIdInvestor(String idInvestor) {
    return daftarInvestasi.where((i) => i.idInvestor == idInvestor).toList();
  }

  List<DividenModel> ambilDividenByIdInvestor(String idInvestor) {
    return daftarDividen.where((d) => d.idInvestor == idInvestor).toList();
  }

  List<DividenModel> ambilDividenByIdInvestasi(String idInvestasi) {
    return daftarDividen.where((d) => d.idInvestasi == idInvestasi).toList();
  }

  double getTotalModalInvestor(String idInvestor) {
    return daftarInvestasi
        .where((i) => i.idInvestor == idInvestor)
        .fold(0.0, (sum, i) => sum + i.jumlahModal);
  }

  double getTotalDividenDiterimaInvestor(String idInvestor) {
    return daftarDividen
        .where((d) => d.idInvestor == idInvestor && d.sudahDibayar)
        .fold(0.0, (sum, d) => sum + d.jumlahDividen);
  }

  double getTotalDividenBelumDibayarInvestor(String idInvestor) {
    return daftarDividen
        .where((d) => d.idInvestor == idInvestor && !d.sudahDibayar)
        .fold(0.0, (sum, d) => sum + d.jumlahDividen);
  }

  int getTotalLembarInvestor(String idInvestor) {
    return daftarInvestasi
        .where((i) => i.idInvestor == idInvestor)
        .fold(0, (sum, i) => sum + i.jumlahLembar);
  }

  int getTotalLembarBeredar() {
    return daftarInvestasi.fold(0, (sum, i) => sum + i.jumlahLembar);
  }

  double getTotalAsetPerusahaan() {
    return daftarInvestasi.fold(0.0, (sum, i) => sum + i.jumlahModal);
  }
}

@riverpod
class InvestasiNotifier extends _$InvestasiNotifier {
  late InvestasiOpGlobal _investasiOp;

  @override
  FutureOr<InvestasiState> build() {
    _investasiOp = ref.read(investasiOpGlobalProvider);
    return _loadData();
  }

  Future<InvestasiState> _loadData() async {
    Log.info('Memuat data investasi dan dividen');
    try {
      final results = await Future.wait([
        _investasiOp.ambilSemuaInvestasi(),
        _investasiOp.ambilSemuaDividen(),
      ]);

      final daftarInvestasi = results[0] as List<InvestasiModel>;
      final daftarDividen = results[1] as List<DividenModel>;

      final totalModal = daftarInvestasi.fold(
        0.0,
        (sum, i) => sum + i.jumlahModal,
      );
      final totalDividenDiterima = daftarDividen
          .where((d) => d.sudahDibayar)
          .fold(0.0, (sum, d) => sum + d.jumlahDividen);
      final totalDividenBelumDibayar = daftarDividen
          .where((d) => !d.sudahDibayar)
          .fold(0.0, (sum, d) => sum + d.jumlahDividen);

      return InvestasiState(
        daftarInvestasi: daftarInvestasi,
        daftarDividen: daftarDividen,
        jumlahInvestasi: daftarInvestasi.length,
        jumlahDividen: daftarDividen.length,
        totalModal: totalModal,
        totalDividenDiterima: totalDividenDiterima,
        totalDividenBelumDibayar: totalDividenBelumDibayar,
      );
    } catch (e, s) {
      Log.error('Gagal memuat data investasi', e: e, s: s);
      rethrow;
    }
  }

  Future<void> refresh() async {
    Log.info('Menyegarkan data investasi');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _loadData();
    });
  }

  Future<void> tambahInvestasi(InvestasiModel investasi) async {
    if (!state.hasValue) return;
    Log.info('Menambahkan investasi baru - ID: ${investasi.id}');

    try {
      await _investasiOp.tambahInvestasi(investasi);
      final currentData = state.requireValue;
      final updatedList = [...currentData.daftarInvestasi, investasi];
      state = AsyncData(
        currentData.copyWith(
          daftarInvestasi: updatedList,
          jumlahInvestasi: updatedList.length,
          totalModal: updatedList.fold(0.0, (sum, i) => sum + i.jumlahModal),
        ),
      );
      Log.info('Investasi berhasil ditambahkan - ID: ${investasi.id}');
    } catch (e, s) {
      Log.error('Gagal menambahkan investasi', e: e, s: s);
      rethrow;
    }
  }

  Future<void> perbaruiInvestasi(InvestasiModel investasi) async {
    if (!state.hasValue) return;
    Log.info('Memperbarui investasi - ID: ${investasi.id}');

    try {
      await _investasiOp.perbaruiInvestasi(investasi);
      final currentData = state.requireValue;
      final updatedList = currentData.daftarInvestasi.map((i) {
        return i.id == investasi.id ? investasi : i;
      }).toList();

      state = AsyncData(
        currentData.copyWith(
          daftarInvestasi: updatedList,
          totalModal: updatedList.fold(0.0, (sum, i) => sum + i.jumlahModal),
        ),
      );
      Log.info('Investasi berhasil diperbarui - ID: ${investasi.id}');
    } catch (e, s) {
      Log.error('Gagal memperbarui investasi', e: e, s: s);
      rethrow;
    }
  }

  Future<void> softDeleteInvestasi(String id) async {
    if (!state.hasValue) return;
    Log.info('Soft delete investasi - ID: $id');

    try {
      await _investasiOp.softDeleteInvestasi(id);
      final currentData = state.requireValue;
      final updatedList = currentData.daftarInvestasi
          .where((i) => i.id != id)
          .toList();

      state = AsyncData(
        currentData.copyWith(
          daftarInvestasi: updatedList,
          jumlahInvestasi: updatedList.length,
          totalModal: updatedList.fold(0.0, (sum, i) => sum + i.jumlahModal),
        ),
      );
      Log.info('Soft delete investasi berhasil - ID: $id');
    } catch (e, s) {
      Log.error('Gagal soft delete investasi', e: e, s: s);
      rethrow;
    }
  }

  Future<void> tambahDividen(DividenModel dividen) async {
    if (!state.hasValue) return;
    Log.info('Menambahkan dividen baru - ID: ${dividen.id}');

    try {
      await _investasiOp.tambahDividen(dividen);
      final currentData = state.requireValue;
      final updatedList = [...currentData.daftarDividen, dividen];

      state = AsyncData(
        currentData.copyWith(
          daftarDividen: updatedList,
          jumlahDividen: updatedList.length,
          totalDividenDiterima: updatedList
              .where((d) => d.sudahDibayar)
              .fold(0.0, (sum, d) => sum + d.jumlahDividen),
          totalDividenBelumDibayar: updatedList
              .where((d) => !d.sudahDibayar)
              .fold(0.0, (sum, d) => sum + d.jumlahDividen),
        ),
      );
      Log.info('Dividen berhasil ditambahkan - ID: ${dividen.id}');
    } catch (e, s) {
      Log.error('Gagal menambahkan dividen', e: e, s: s);
      rethrow;
    }
  }

  Future<void> perbaruiDividen(DividenModel dividen) async {
    if (!state.hasValue) return;
    Log.info('Memperbarui dividen - ID: ${dividen.id}');

    try {
      await _investasiOp.perbaruiDividen(dividen);
      final currentData = state.requireValue;
      final updatedList = currentData.daftarDividen.map((d) {
        return d.id == dividen.id ? dividen : d;
      }).toList();

      state = AsyncData(
        currentData.copyWith(
          daftarDividen: updatedList,
          totalDividenDiterima: updatedList
              .where((d) => d.sudahDibayar)
              .fold(0.0, (sum, d) => sum + d.jumlahDividen),
          totalDividenBelumDibayar: updatedList
              .where((d) => !d.sudahDibayar)
              .fold(0.0, (sum, d) => sum + d.jumlahDividen),
        ),
      );
      Log.info('Dividen berhasil diperbarui - ID: ${dividen.id}');
    } catch (e, s) {
      Log.error('Gagal memperbarui dividen', e: e, s: s);
      rethrow;
    }
  }

  Future<void> softDeleteDividen(String id) async {
    if (!state.hasValue) return;
    Log.info('Soft delete dividen - ID: $id');

    try {
      await _investasiOp.softDeleteDividen(id);
      final currentData = state.requireValue;
      final updatedList = currentData.daftarDividen
          .where((d) => d.id != id)
          .toList();

      state = AsyncData(
        currentData.copyWith(
          daftarDividen: updatedList,
          jumlahDividen: updatedList.length,
          totalDividenDiterima: updatedList
              .where((d) => d.sudahDibayar)
              .fold(0.0, (sum, d) => sum + d.jumlahDividen),
          totalDividenBelumDibayar: updatedList
              .where((d) => !d.sudahDibayar)
              .fold(0.0, (sum, d) => sum + d.jumlahDividen),
        ),
      );
      Log.info('Soft delete dividen berhasil - ID: $id');
    } catch (e, s) {
      Log.error('Gagal soft delete dividen', e: e, s: s);
      rethrow;
    }
  }

  Future<void> tandaiDividenDibayar(String id) async {
    if (!state.hasValue) return;
    Log.info('Menandai dividen sudah dibayar - ID: $id');

    try {
      await _investasiOp.tandaiDividenDibayar(id);
      final currentData = state.requireValue;
      final updatedList = currentData.daftarDividen.map((d) {
        if (d.id == id) {
          return d.copyWith(sudahDibayar: true);
        }
        return d;
      }).toList();

      state = AsyncData(
        currentData.copyWith(
          daftarDividen: updatedList,
          totalDividenDiterima: updatedList
              .where((d) => d.sudahDibayar)
              .fold(0.0, (sum, d) => sum + d.jumlahDividen),
          totalDividenBelumDibayar: updatedList
              .where((d) => !d.sudahDibayar)
              .fold(0.0, (sum, d) => sum + d.jumlahDividen),
        ),
      );
      Log.info('Dividen berhasil ditandai sudah dibayar - ID: $id');
    } catch (e, s) {
      Log.error('Gagal menandai dividen sudah dibayar', e: e, s: s);
      rethrow;
    }
  }

  void invalidate() {
    ref.invalidateSelf();
  }
}

@riverpod
Future<({List<InvestasiModel> investasi, List<DividenModel> dividen})>
detailInvestorInvestasi(Ref ref, String idInvestor) async {
  final state = await ref.watch(investasiProvider.future);
  return (
    investasi: state.ambilInvestasiByIdInvestor(idInvestor),
    dividen: state.ambilDividenByIdInvestor(idInvestor),
  );
}

@riverpod
Future<double> totalModalInvestor(Ref ref, String idInvestor) async {
  final state = await ref.watch(investasiProvider.future);
  return state.getTotalModalInvestor(idInvestor);
}

@riverpod
Future<double> totalDividenInvestor(Ref ref, String idInvestor) async {
  final state = await ref.watch(investasiProvider.future);
  return state.getTotalDividenDiterimaInvestor(idInvestor);
}
