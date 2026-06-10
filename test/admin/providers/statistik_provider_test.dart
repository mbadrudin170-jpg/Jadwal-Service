// path: test/admin/providers/statistik_provider_test.dart

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/model/best_selling_package.dart';
import 'package:wifi/admin/providers/statistik_provider.dart';
import 'package:wifi/admin/repository/statistik_repository.dart';
import 'package:wifi/shared/enum/duration_type_enum.dart';
import 'package:wifi/shared/model/package_model.dart';

class MockStatistikRepository extends Mock implements StatistikRepository {}

void main() {
  late MockStatistikRepository mockRepository;
  late ProviderContainer container;

  final tBestSellingPackage = BestSellingPackage(
    totalSold: 10,
    package: PackageModel(
        name: 'Paket A', price: 50000, duration: 30, type: DurationType.days),
  );
  final tStatistikState = StatistikState(
    pendapatanBulanIni: 1000.0,
    totalPelanggan: 10,
    jumlahLanggananAktif: 5,
    jumlahFeedbackBaru: 2,
    bestSellingPackages: [tBestSellingPackage],
  );

  setUp(() {
    mockRepository = MockStatistikRepository();
    container = ProviderContainer(
      overrides: [
        statistikRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('1. statistikProvider harus memuat StatistikState dengan benar',
      () async {
    when(() => mockRepository.getPendapatanBulanIni())
        .thenAnswer((_) async => 1000.0);
    when(() => mockRepository.getTotalPelanggan()).thenAnswer((_) async => 10);
    when(() => mockRepository.getJumlahLanggananAktif())
        .thenAnswer((_) async => 5);
    when(() => mockRepository.getJumlahFeedbackBaru())
        .thenAnswer((_) async => 2);
    when(() => mockRepository.getBestSellingPackages())
        .thenAnswer((_) async => [tBestSellingPackage]);

    final result = await container.read(statistikProvider.future);

    expect(result.pendapatanBulanIni, tStatistikState.pendapatanBulanIni);
    expect(result.totalPelanggan, tStatistikState.totalPelanggan);
    expect(result.jumlahLanggananAktif, tStatistikState.jumlahLanggananAktif);
    expect(result.jumlahFeedbackBaru, tStatistikState.jumlahFeedbackBaru);
    expect(result.bestSellingPackages.length, 1);

    verify(() => mockRepository.getPendapatanBulanIni()).called(1);
    verify(() => mockRepository.getTotalPelanggan()).called(1);
    verify(() => mockRepository.getJumlahLanggananAktif()).called(1);
    verify(() => mockRepository.getJumlahFeedbackBaru()).called(1);
    verify(() => mockRepository.getBestSellingPackages()).called(1);
  });

  test('2. statistikProvider harus menangani error dengan benar', () async {
    // Arrange
    final exception = Exception('Gagal mengambil data');
    when(() => mockRepository.getPendapatanBulanIni()).thenThrow(exception);
    when(() => mockRepository.getTotalPelanggan()).thenAnswer((_) async => 10);
    when(() => mockRepository.getJumlahLanggananAktif())
        .thenAnswer((_) async => 5);
    when(() => mockRepository.getJumlahFeedbackBaru())
        .thenAnswer((_) async => 2);
    when(() => mockRepository.getBestSellingPackages())
        .thenAnswer((_) async => []);

    final completer = Completer<void>();

    // Act
    container.listen<AsyncValue<StatistikState>>(
      statistikProvider,
      (previous, next) {
        if (next is AsyncError) {
          // Assert
          expect(next.error, isA<Exception>());
          if (!completer.isCompleted) {
            completer.complete();
          }
        }
      },
      fireImmediately: true,
    );

    // Tunggu hingga listener menangkap error
    await completer.future;
  });

  test('3. refresh harus memuat ulang data', () async {
    when(() => mockRepository.getPendapatanBulanIni())
        .thenAnswer((_) async => 1000.0);
    when(() => mockRepository.getTotalPelanggan()).thenAnswer((_) async => 10);
    when(() => mockRepository.getJumlahLanggananAktif())
        .thenAnswer((_) async => 5);
    when(() => mockRepository.getJumlahFeedbackBaru())
        .thenAnswer((_) async => 2);
    when(() => mockRepository.getBestSellingPackages())
        .thenAnswer((_) async => [tBestSellingPackage]);

    await container.read(statistikProvider.future);

    when(() => mockRepository.getPendapatanBulanIni())
        .thenAnswer((_) async => 2000.0);
    when(() => mockRepository.getTotalPelanggan()).thenAnswer((_) async => 20);
    when(() => mockRepository.getJumlahLanggananAktif())
        .thenAnswer((_) async => 8);
    when(() => mockRepository.getJumlahFeedbackBaru())
        .thenAnswer((_) async => 1);
    when(() => mockRepository.getBestSellingPackages())
        .thenAnswer((_) async => []);

    final result = await container.refresh(statistikProvider.future);

    expect(result.pendapatanBulanIni, 2000.0);
    expect(result.totalPelanggan, 20);

    verify(() => mockRepository.getPendapatanBulanIni()).called(2);
    verify(() => mockRepository.getTotalPelanggan()).called(2);
  });
}
