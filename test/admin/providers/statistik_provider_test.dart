// path: test/admin/providers/statistik_provider_test.dart
// 1. Tambahkan anotasi GenerateMocks untuk StatistikRepository
@GenerateMocks([StatistikRepository])
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/admin/model/best_selling_package.dart';
import 'package:wifi/admin/providers/statistik_provider.dart';
import 'package:wifi/admin/repository/statistik_repository.dart';
import 'package:wifi/shared/enum/duration_type_enum.dart';
import 'package:wifi/shared/model/package_model.dart';

// 2. Import file .mocks.dart yang akan digenerate
import 'statistik_provider_test.mocks.dart';

void main() {
  // 3. Siapkan variabel untuk mock dan ProviderContainer
  late MockStatistikRepository mockRepository;
  late ProviderContainer container;

  // 4. Data dummy untuk pengujian
  final tBestSellingPackage = BestSellingPackage(
      totalSold: 10,
      package: PackageModel(
          name: 'Paket A',
          price: 50000,
          duration: 30,
          type: DurationType.days));
  final tStatistikState = StatistikState(
    pendapatanBulanIni: 1000.0,
    totalPelanggan: 10,
    jumlahLanggananAktif: 5,
    jumlahFeedbackBaru: 2,
    bestSellingPackages: [tBestSellingPackage],
  );

  setUp(() {
    // 5. Inisialisasi mock sebelum setiap test
    mockRepository = MockStatistikRepository();

    // 6. Override provider repository dengan mock
    container = ProviderContainer(
      overrides: [
        statistikRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    // 7. Dispose container setelah setiap test
    container.dispose();
  });

  test('1. statistikProvider harus memuat StatistikState dengan benar',
      () async {
    // Arrange
    // 8. Atur agar mock mengembalikan data dummy ketika methodnya dipanggil
    when(mockRepository.getPendapatanBulanIni())
        .thenAnswer((_) async => 1000.0);
    when(mockRepository.getTotalPelanggan()).thenAnswer((_) async => 10);
    when(mockRepository.getJumlahLanggananAktif()).thenAnswer((_) async => 5);
    when(mockRepository.getJumlahFeedbackBaru()).thenAnswer((_) async => 2);
    when(mockRepository.getBestSellingPackages())
        .thenAnswer((_) async => [tBestSellingPackage]);

    // Act
    // 9. Baca provider untuk memicu pemuatan data
    final result = await container.read(statistikProvider.future);

    // Assert
    // 10. Verifikasi bahwa hasilnya cocok dengan data dummy
    expect(result.pendapatanBulanIni, tStatistikState.pendapatanBulanIni);
    expect(result.totalPelanggan, tStatistikState.totalPelanggan);
    expect(result.jumlahLanggananAktif, tStatistikState.jumlahLanggananAktif);
    expect(result.jumlahFeedbackBaru, tStatistikState.jumlahFeedbackBaru);
    expect(result.bestSellingPackages.length, 1);

    // 11. Verifikasi bahwa setiap method di repository dipanggil sekali
    verify(mockRepository.getPendapatanBulanIni()).called(1);
    verify(mockRepository.getTotalPelanggan()).called(1);
    verify(mockRepository.getJumlahLanggananAktif()).called(1);
    verify(mockRepository.getJumlahFeedbackBaru()).called(1);
    verify(mockRepository.getBestSellingPackages()).called(1);
  });

  test('2. statistikProvider harus menangani error dengan benar', () async {
    // Arrange
    final exception = Exception('Gagal mengambil data');
    // 12. Atur agar mock melempar exception
    when(mockRepository.getPendapatanBulanIni()).thenThrow(exception);
    when(mockRepository.getTotalPelanggan()).thenAnswer((_) async => 10);
    when(mockRepository.getJumlahLanggananAktif()).thenAnswer((_) async => 5);
    when(mockRepository.getJumlahFeedbackBaru()).thenAnswer((_) async => 2);
    when(mockRepository.getBestSellingPackages()).thenAnswer((_) async => []);

    // Act & Assert
    // 13. Harapkan error ketika membaca provider, gunakan expectLater untuk Future
    await expectLater(
      container.read(statistikProvider.future),
      throwsA(isA<Exception>()),
    );
  });

  test('3. refresh harus memuat ulang data', () async {
    // Arrange
    // 14. Pengaturan awal
    when(mockRepository.getPendapatanBulanIni())
        .thenAnswer((_) async => 1000.0);
    when(mockRepository.getTotalPelanggan()).thenAnswer((_) async => 10);
    when(mockRepository.getJumlahLanggananAktif()).thenAnswer((_) async => 5);
    when(mockRepository.getJumlahFeedbackBaru()).thenAnswer((_) async => 2);
    when(mockRepository.getBestSellingPackages()).thenAnswer((_) async => []);

    // 15. Baca awal untuk memastikan data ada
    await container.read(statistikProvider.future);

    // Arrange (untuk refresh)
    // 16. Atur data baru untuk panggilan setelah refresh
    when(mockRepository.getPendapatanBulanIni())
        .thenAnswer((_) async => 2000.0);

    // Act
    // 17. Panggil method refresh
    await container.read(statistikProvider.notifier).refresh();
    final result = await container.read(statistikProvider.future);

    // Assert
    // 18. Verifikasi bahwa data baru yang dimuat
    expect(result.pendapatanBulanIni, 2000.0);
    // 19. Verifikasi method dipanggil dua kali (awal + refresh)
    verify(mockRepository.getPendapatanBulanIni()).called(2);
  });
}
