// path: test/admin/providers/statistik_provider_test.dart

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/model/best_selling_package.dart';
import 'package:wifi/fitur/statistik/provider/statistik_provider.dart';
import 'package:wifi/fitur/statistik/operasi/statistik_op_sqlite.dart';
import 'package:wifi/shared/enum/duration_type_enum.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';

class MockStatistikRepository extends Mock implements StatistikOpSqlite {}

void main() {
  final tBestSellingPackage = BestSellingPackage(
    totalTerjual: 10,
    paket: PaketModel(
      nama: 'Paket A',
      harga: 50000,
      durasi: 30,
      tipe: DurationType.days,
    ),
  );

  test('1. statistikProvider harus memuat data dengan benar', () async {
    final mockRepository = MockStatistikRepository();
    final container = ProviderContainer(
      overrides: [
        statistikOpSliteProvider.overrideWithValue(mockRepository),
      ],
    );
    addTearDown(container.dispose);

    when(mockRepository.ambilPendapatanBulanIni)
        .thenAnswer((_) async => 1000.0);
    when(mockRepository.ambilTotalPelanggan).thenAnswer((_) async => 10);
    when(mockRepository.ambilJumlahLanggananAktif).thenAnswer((_) async => 5);
    when(mockRepository.ambilJumlahFeedbackBaru).thenAnswer((_) async => 2);
    when(mockRepository.ambilPaketTerlaris)
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
        statistikOpSliteProvider.overrideWithValue(mockRepository),
      ],
    );
    addTearDown(container.dispose);

    final exception = Exception('Gagal memuat');
    final completer = Completer<void>();

    when(mockRepository.ambilPendapatanBulanIni)
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
        statistikOpSliteProvider.overrideWithValue(mockRepository),
      ],
    );
    addTearDown(container.dispose);

    when(mockRepository.ambilPendapatanBulanIni)
        .thenAnswer((_) async => 1000.0);
    when(mockRepository.ambilTotalPelanggan).thenAnswer((_) async => 10);
    when(mockRepository.ambilJumlahLanggananAktif).thenAnswer((_) async => 5);
    when(mockRepository.ambilJumlahFeedbackBaru).thenAnswer((_) async => 2);
    when(mockRepository.ambilPaketTerlaris).thenAnswer((_) async => []);
    await container.read(statistikProvider.future);

    when(mockRepository.ambilPendapatanBulanIni)
        .thenAnswer((_) async => 2000.0);
    when(mockRepository.ambilTotalPelanggan).thenAnswer((_) async => 20);

    final future = container.refresh(statistikProvider.future);

    final newState = await future;
    expect(newState.pendapatanBulanIni, 2000.0);
    expect(newState.totalPelanggan, 20);

    verify(mockRepository.ambilPendapatanBulanIni).called(2);
  });
}
