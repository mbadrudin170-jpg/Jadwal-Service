// path: lib/admin/providers/statistik_provider.dart

import 'dart:async';

// 1. Ubah import ke riverpod_annotation agar seragam dengan file lainnya
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/admin/model/best_selling_package.dart';
import 'package:wifi/admin/repository/statistik_repository.dart';
import 'package:wifi/shared/debug/log.dart';

part 'statistik_provider.g.dart';

class StatistikState {
  final double pendapatanBulanIni;
  final int totalPelanggan;
  final int jumlahLanggananAktif;
  final int jumlahFeedbackBaru;
  final List<BestSellingPackage> bestSellingPackages;

  StatistikState({
    this.pendapatanBulanIni = 0.0,
    this.totalPelanggan = 0,
    this.jumlahLanggananAktif = 0,
    this.jumlahFeedbackBaru = 0,
    this.bestSellingPackages = const [],
  });

  StatistikState copyWith({
    double? pendapatanBulanIni,
    int? totalPelanggan,
    int? jumlahLanggananAktif,
    int? jumlahFeedbackBaru,
    List<BestSellingPackage>? bestSellingPackages,
  }) {
    return StatistikState(
      pendapatanBulanIni: pendapatanBulanIni ?? this.pendapatanBulanIni,
      totalPelanggan: totalPelanggan ?? this.totalPelanggan,
      jumlahLanggananAktif: jumlahLanggananAktif ?? this.jumlahLanggananAktif,
      jumlahFeedbackBaru: jumlahFeedbackBaru ?? this.jumlahFeedbackBaru,
      bestSellingPackages: bestSellingPackages ?? this.bestSellingPackages,
    );
  }
}

// 3. Pasang anotasi @riverpod. Variabel 'statistikProvider' otomatis tercipta.
@riverpod
class Statistik extends _$Statistik {
  StatistikRepository get _repository {
    return ref.read(statistikRepositoryProvider);
  }

  @override
  Future<StatistikState> build() {
    Log.info('[StatistikNotifier] Build dipanggil, memuat data awal.');
    return _loadData();
  }

  Future<StatistikState> _loadData() async {
    final results = await Future.wait([
      _repository.getPendapatanBulanIni(),
      _repository.getTotalPelanggan(),
      _repository.getJumlahLanggananAktif(),
      _repository.getJumlahFeedbackBaru(),
      _repository.getBestSellingPackages(),
    ]);
    Log.info('[StatistikNotifier] Semua future dari repository selesai.');
    return StatistikState(
      pendapatanBulanIni: results[0] as double,
      totalPelanggan: results[1] as int,
      jumlahLanggananAktif: results[2] as int,
      jumlahFeedbackBaru: results[3] as int,
      bestSellingPackages: results[4] as List<BestSellingPackage>,
    );
  }

  Future<void> refresh() async {
    Log.info('[StatistikNotifier] Refresh dipicu oleh UI.');
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadData);
    Log.info('[StatistikNotifier] Refresh selesai.');
  }
}
