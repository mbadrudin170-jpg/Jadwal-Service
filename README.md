
// File: lib/fitur/investasi/page/daftar_investor.dart

```dart
// path: lib/fitur/investasi/page/daftar_investor.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/investasi/provider/investasi_provider.dart';

class DaftarInvestor extends ConsumerWidget {
  const DaftarInvestor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investasiAsync = ref.watch(investasiProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('data')),
      body: investasiAsync.when(
        data: (data) {
          return const Column(
            children: [
              ListTile(
                title: Text('Nama'),
                subtitle: Text('lembar'),
                leading: Text('jumlah inves'),
              ),
            ],
          );
        },
        error: (error, stackTrace) {
          return null;
        },
        loading: () => null,
      ),
    );
  }
}
```

// File: lib/fitur/investasi/page/ringkasan_saham.dart

```dart
// path: lib/fitur/investasi/page/ringkasan_saham.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/app_role/app_role_enum.dart';
import 'package:wifi/fitur/investasi/provider/investasi_provider.dart';
import 'package:wifi/fitur/pelanggan/provider/pelanggan_provider.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/format_util.dart';

class RingkasanSaham extends ConsumerWidget {
  const RingkasanSaham({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investasiAsync = ref.watch(investasiProvider);
    final pelangganAsync = ref.watch(pelangganProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Ringkasan Saham')),
      body: investasiAsync.when(
        data: (investasi) {
          final totalLembar = investasi.getTotalLembarBeredar();
          final totalAset = investasi.getTotalAsetPerusahaan();
          final totalDividenDiterima = investasi.totalDividenDiterima;
          final totalDividenBelumDibayar = investasi.totalDividenBelumDibayar;
          final returnPersentase = totalAset > 0
              ? (totalDividenDiterima / totalAset) * 100
              : 0.0;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ringkasan Perusahaan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        gapH16,
                        _buildInfoRow(
                          'Total Aset',
                          FormatUang.formatMataUang(totalAset),
                          icon: TIcons.money,
                        ),
                        gapH8,
                        _buildInfoRow(
                          'Total Lembar Saham',
                          totalLembar.toString(),
                          icon: TIcons.points,
                        ),
                        gapH8,
                        _buildInfoRow(
                          'Dividen Diterima',
                          FormatUang.formatMataUang(totalDividenDiterima),
                          icon: TIcons.success,
                          color: Colors.green,
                        ),
                        gapH8,
                        _buildInfoRow(
                          'Dividen Belum Dibayar',
                          FormatUang.formatMataUang(totalDividenBelumDibayar),
                          icon: TIcons.warning,
                          color: Colors.orange,
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(
                          'Return (%)',
                          '${returnPersentase.toStringAsFixed(2)}%',
                          icon: TIcons.star,
                          color: returnPersentase >= 0
                              ? Colors.green
                              : Colors.red,
                        ),
                      ],
                    ),
                  ),
                ),
                gapH16,

                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Statistik Tambahan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        gapH12,
                        _buildInfoRow(
                          'Jumlah Investasi',
                          investasi.jumlahInvestasi.toString(),
                          icon: TIcons.listAlt,
                        ),
                        gapH8,
                        _buildInfoRow(
                          'Jumlah Dividen',
                          investasi.jumlahDividen.toString(),
                          icon: TIcons.history,
                        ),
                        gapH8,
                        _buildInfoRow(
                          'Rata-rata Modal per Investasi',
                          FormatUang.formatMataUang(
                            investasi.jumlahInvestasi > 0
                                ? totalAset / investasi.jumlahInvestasi
                                : 0,
                          ),
                          icon: TIcons.info,
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {},
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: pelangganAsync.when(
                        data: (listInvestor) {
                          final daftarInvestor =
                              listInvestor.ambilBerdasarkanRole(
                                AppRole.investor,
                              )..sort((a, b) {
                                final lembarA = investasi
                                    .getTotalLembarInvestor(a.id);
                                final lembarB = investasi
                                    .getTotalLembarInvestor(b.id);
                                return lembarB.compareTo(
                                  lembarA,
                                ); // descending (terbanyak ke terkecil)
                              });

                          if (daftarInvestor.isEmpty) {
                            return const Center(
                              child: Text('Belum ada investor'),
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Daftar Investor',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              gapH12,
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: daftarInvestor.length > 5
                                    ? 5
                                    : daftarInvestor.length,
                                itemBuilder: (context, index) {
                                  final investor = daftarInvestor[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(investor.nama),
                                        Text(
                                          investasi
                                              .getTotalLembarInvestor(
                                                investor.id,
                                              )
                                              .toString(),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                        error: (error, stackTrace) =>
                            Center(child: Text('Error: $error')),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        error: (e, s) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(TIcons.error, size: 60, color: Colors.red),
              gapH16,
              Text('Error: $e', textAlign: TextAlign.center),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    IconData? icon,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (icon != null) Icon(icon, size: 20, color: Colors.grey.shade600),
            gapW8,
            Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
```

// File: lib/fitur/investasi/provider/investasi_provider.dart

```dart
// path: lib/fitur/investasi/provider/investasi_provider.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/investasi/model/dividen_model.dart';
import 'package:wifi/fitur/investasi/model/investasi_model.dart';
import 'package:wifi/fitur/investasi/operasi/investasi_op_sqlite.dart';
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
  late InvestasiOpSqlite _investasiOp;

  @override
  FutureOr<InvestasiState> build() {
    _investasiOp = ref.read(investasiOpSqliteProvider);
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
```

// File: lib/fitur/pelanggan/provider/pelanggan_provider.dart

```dart
// path lib/fitur/pelanggan/provider/pelanggan_provider.dart

import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/app_role/app_role_enum.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_global.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_global.dart';

part 'pelanggan_provider.g.dart';
part 'pelanggan_provider.freezed.dart';

@freezed
abstract class PelangganState with _$PelangganState {
  const PelangganState._();
  const factory PelangganState({
    @Default([]) List<PelangganModel> daftarPelanggan,
    @Default(0) int jumlahPelanggan,
    @Default(0) int totalPoin,
  }) = _PelangganState;

  PelangganModel? ambilBerdasarkanId(String idPelanggan) {
    return daftarPelanggan.firstWhereOrNull((p) => p.id == idPelanggan);
  }

  List<PelangganModel> ambilBerdasarkanRole(AppRole role) {
    return daftarPelanggan.where((p) => p.role == role).toList();
  }
}

@Riverpod(keepAlive: true)
class Pelanggan extends _$Pelanggan {
  PelangganOpGlobal get _pelangganOp => ref.read(pelangganOpGlobalProvider);
  TransaksiOpGlobal get _transaksiOp => ref.read(transaksiOpGlobalProvider);

  @override
  FutureOr<PelangganState> build() {
    return _ambilData();
  }

  Future<PelangganState> _ambilData() async {
    final hasil = await _pelangganOp.ambilSemua();
    final hitungPoinFutures = hasil.map(
      (pelanggan) => _transaksiOp.ambilTotalPoin(pelanggan.id),
    );
    final daftarPoin = await Future.wait(hitungPoinFutures);
    final totalPoinSistem = daftarPoin.fold<int>(0, (sum, poin) => sum + poin);
    return PelangganState(
      daftarPelanggan: hasil,
      jumlahPelanggan: hasil.length,
      totalPoin: totalPoinSistem,
    );
  }

  void invalidateDetailPelanggan(String? idPelanggan) {
    ref.invalidateSelf();
    if (idPelanggan != null) {
      ref.invalidate(pelangganDetailProvider(idPelanggan));
    } else {
      ref.invalidate(pelangganDetailProvider);
    }
    ref.invalidate(isSearchingPelangganProvider);
    ref.invalidate(searchQueryPelangganProvider);
    ref.invalidate(namaPelangganProvider);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _ambilData();
    });
  }
}

@riverpod
class IsSearchingPelanggan extends _$IsSearchingPelanggan {
  @override
  bool build() => false;
  void toggle() => state = !state;
  void setFalse() => state = false;
}

/// Provider generator modern untuk menyimpan text query pencarian pelanggan
@riverpod
class SearchQueryPelanggan extends _$SearchQueryPelanggan {
  @override
  String build() => '';
  void updateQuery(String query) => state = query;
  void clear() => state = '';
}

@riverpod
Future<String?> namaPelanggan(Ref ref, String idPelanggan) async {
  if (idPelanggan.isEmpty) return null;
  final pelangganOp = ref.watch(pelangganOpGlobalProvider);
  final pelanggan = await pelangganOp.ambilBerdasarkanId(idPelanggan);
  return pelanggan?.nama;
}

@riverpod
Future<(PelangganModel?, int)> pelangganDetail(
  Ref ref,
  String idPelanggan,
) async {
  final pelangganOp = ref.watch(pelangganOpGlobalProvider);
  final transaksiOp = ref.watch(transaksiOpGlobalProvider);
  final pelanggan = await pelangganOp.ambilBerdasarkanId(idPelanggan);
  final poin = await transaksiOp.ambilTotalPoin(idPelanggan);
  return (pelanggan, poin);
}
```
