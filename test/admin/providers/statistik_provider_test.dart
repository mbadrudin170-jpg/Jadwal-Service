// path: test/admin/providers/statistik_provider_test.dart

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/model/best_selling_package.dart';
import 'package:wifi/admin/providers/statistik_provider.dart';
import 'package:wifi/admin/repository/statistik_op_sqlite.dart';
import 'package:wifi/shared/enum/duration_type_enum.dart';
import 'package:wifi/shared/model/package_model.dart';

class MockStatistikRepository extends Mock implements StatistikOpSqlite {}

void main() {
  final tBestSellingPackage = BestSellingPackage(
    totalSold: 10,
    package: PackageModel(
      name: 'Paket A',
      price: 50000,
      duration: 30,
      type: DurationType.days,
    ),
  );

  test('1. statistikProvider harus memuat data dengan benar', () async {
    final mockRepository = MockStatistikRepository();
    final container = ProviderContainer(
      overrides: [
        statistikRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
    addTearDown(container.dispose);

    when(mockRepository.getPendapatanBulanIni).thenAnswer((_) async => 1000.0);
    when(mockRepository.getTotalPelanggan).thenAnswer((_) async => 10);
    when(mockRepository.getJumlahLanggananAktif).thenAnswer((_) async => 5);
    when(mockRepository.getJumlahFeedbackBaru).thenAnswer((_) async => 2);
    when(mockRepository.getBestSellingPackages)
        .thenAnswer((_) async => [tBestSellingPackage]);

    await expectLater(container.read(statistikProvider.future), completes);

    final state = await container.read(statistikProvider.future);
    expect(state.pendapatanBulanIni, 1000.0);
  });

  test(
      '2. statistikProvider harus mengeluarkan AsyncError saat repository gagal',
      () async {
    final mockRepository = MockStatistikRepository();
    final container = ProviderContainer(
      overrides: [
        statistikRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
    addTearDown(container.dispose);

    final exception = Exception('Gagal memuat');
    final completer = Completer<void>();

    when(mockRepository.getPendapatanBulanIni)
        .thenAnswer((_) => Future.error(exception));

    container.listen<AsyncValue<StatistikState>>(
      statistikProvider,
      (previous, next) {
        if (next is AsyncError) {
          if (!completer.isCompleted) {
            expect(next.error, exception);
            completer.complete();
          }
        }
      },
      fireImmediately: true,
    );

    await expectLater(completer.future, completes);
  });

  test('3. refresh harus memuat ulang data dengan benar', () async {
    final mockRepository = MockStatistikRepository();
    final container = ProviderContainer(
      overrides: [
        statistikRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
    addTearDown(container.dispose);

    when(mockRepository.getPendapatanBulanIni).thenAnswer((_) async => 1000.0);
    when(mockRepository.getTotalPelanggan).thenAnswer((_) async => 10);
    when(mockRepository.getJumlahLanggananAktif).thenAnswer((_) async => 5);
    when(mockRepository.getJumlahFeedbackBaru).thenAnswer((_) async => 2);
    when(mockRepository.getBestSellingPackages).thenAnswer((_) async => []);
    await container.read(statistikProvider.future);

    when(mockRepository.getPendapatanBulanIni).thenAnswer((_) async => 2000.0);
    when(mockRepository.getTotalPelanggan).thenAnswer((_) async => 20);

    final future = container.refresh(statistikProvider.future);

    final newState = await future;
    expect(newState.pendapatanBulanIni, 2000.0);
    expect(newState.totalPelanggan, 20);

    verify(mockRepository.getPendapatanBulanIni).called(2);
  });
}
