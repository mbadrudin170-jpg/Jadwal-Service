// path: test/fitur/whatsapp/info_paket_test.dart

// Flutter/Dart imports
import 'package:flutter_test/flutter_test.dart';

// Mocktail imports
import 'package:mocktail/mocktail.dart';

// Platform interface imports
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

// Project-specific imports
import 'package:wifi/fitur/paket/enum/tipe_durasi_paket.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/whatsapp/info_paket.dart';
import 'package:wifi/fitur/paket/operasi/paket_op_sqlite.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_sqlite.dart';

// Mock class untuk UrlLauncherPlatform
class MockUrlLauncherPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements UrlLauncherPlatform {}

// Mock class untuk PelangganOpSqlite
class MockPelangganOpSqlite extends Mock implements PelangganOpSqlite {}

// Mock class untuk PaketOpSqlite
class MockPaketOpSqlite extends Mock implements PaketOpSqlite {}

void main() {
  late PesanInfoPaket pesanInfoPaket;
  late MockPelangganOpSqlite mockPelangganOpSqlite;
  late MockPaketOpSqlite mockPaketOpSqlite;
  late MockUrlLauncherPlatform mockUrlLauncher;

  setUpAll(() {
    registerFallbackValue(const LaunchOptions());
  });

  setUp(() {
    mockPelangganOpSqlite = MockPelangganOpSqlite();
    mockPaketOpSqlite = MockPaketOpSqlite();
    mockUrlLauncher = MockUrlLauncherPlatform();
    UrlLauncherPlatform.instance = mockUrlLauncher;

    pesanInfoPaket = PesanInfoPaket(
      customerOperation: mockPelangganOpSqlite,
      packageOperation: mockPaketOpSqlite,
    );
  });

  group('kirimRincianPaket', () {
    final pelangganAktif = PelangganAktifModel(
      id: 'pa1',
      idPelanggan: 'c1',
      idPaket: 'p1',
      tanggalMulai: DateTime(2023, 1, 1),
      tanggalBerakhir: DateTime(2023, 1, 31),
      status: StatusPembayaran.paid,
    );

    final pelanggan = PelangganModel(
      id: 'c1',
      nama: 'John Doe',
      telepon: '081234567890',
      alamat: 'Jl. Contoh',
      kataSandi: 'password123',
      macAddress: 'AA:BB:CC:DD:EE:FF',
    );

    final paket = PaketModel(
      id: 'p1',
      nama: 'Paket Kencang',
      harga: 100000,
      durasi: 30,
      tipe: TipeDurasiPaket.days,
    );

    test(
      '01. harus mengirim rincian paket jika pelanggan dan paket ditemukan dan URL bisa dibuka',
      () async {
        // Arrange
        when(() => mockPelangganOpSqlite.ambilBerdasarkanId('c1'))
            .thenAnswer((_) async => pelanggan);
        when(() => mockPaketOpSqlite.ambilBerdasarkanId('p1'))
            .thenAnswer((_) async => paket);
        when(() => mockUrlLauncher.canLaunch(any()))
            .thenAnswer((_) async => true);
        when(() => mockUrlLauncher.launchUrl(any(), any()))
            .thenAnswer((_) async => true);

        // Act
        await pesanInfoPaket.kirimRincianPaket(pelangganAktif);

        // Assert
        verify(() => mockPelangganOpSqlite.ambilBerdasarkanId('c1')).called(1);
        verify(() => mockPaketOpSqlite.ambilBerdasarkanId('p1')).called(1);
        verify(() => mockUrlLauncher.canLaunch(any())).called(1);
        verify(() => mockUrlLauncher.launchUrl(any(), any())).called(1);
      },
    );

    test(
      '02. tidak mengirim rincian paket jika pelanggan tidak ditemukan',
      () async {
        // Arrange
        when(() => mockPelangganOpSqlite.ambilBerdasarkanId('c1'))
            .thenAnswer((_) async => null);
        // Stub panggilan yang tidak terduga untuk mencegah error tipe null
        when(() => mockPaketOpSqlite.ambilBerdasarkanId('p1'))
            .thenAnswer((_) async => paket);

        // Act
        await pesanInfoPaket.kirimRincianPaket(pelangganAktif);

        // Assert
        verify(() => mockPelangganOpSqlite.ambilBerdasarkanId('c1')).called(1);
        // Verifikasi bahwa pengambilan paket tetap terjadi
        verify(() => mockPaketOpSqlite.ambilBerdasarkanId('p1')).called(1);
        // Pastikan tidak ada URL yang coba diluncurkan
        verifyNever(() => mockUrlLauncher.canLaunch(any()));
        verifyNever(() => mockUrlLauncher.launchUrl(any(), any()));
      },
    );

    test(
      '03. tidak mengirim rincian paket jika paket tidak ditemukan',
      () async {
        // Arrange
        when(() => mockPelangganOpSqlite.ambilBerdasarkanId('c1'))
            .thenAnswer((_) async => pelanggan);
        when(() => mockPaketOpSqlite.ambilBerdasarkanId('p1'))
            .thenAnswer((_) async => null);

        // Act
        await pesanInfoPaket.kirimRincianPaket(pelangganAktif);

        // Assert
        verify(() => mockPelangganOpSqlite.ambilBerdasarkanId('c1')).called(1);
        verify(() => mockPaketOpSqlite.ambilBerdasarkanId('p1')).called(1);
        verifyNever(() => mockUrlLauncher.canLaunch(any()));
        verifyNever(() => mockUrlLauncher.launchUrl(any(), any()));
      },
    );

    test(
      '04. tidak mencoba membuka URL jika canLaunchUrl mengembalikan false',
      () async {
        // Arrange
        when(() => mockPelangganOpSqlite.ambilBerdasarkanId('c1'))
            .thenAnswer((_) async => pelanggan);
        when(() => mockPaketOpSqlite.ambilBerdasarkanId('p1'))
            .thenAnswer((_) async => paket);
        when(() => mockUrlLauncher.canLaunch(any()))
            .thenAnswer((_) async => false);

        // Act
        await pesanInfoPaket.kirimRincianPaket(pelangganAktif);

        // Assert
        verify(() => mockPelangganOpSqlite.ambilBerdasarkanId('c1')).called(1);
        verify(() => mockPaketOpSqlite.ambilBerdasarkanId('p1')).called(1);
        verify(() => mockUrlLauncher.canLaunch(any())).called(1);
        verifyNever(() => mockUrlLauncher.launchUrl(any(), any()));
      },
    );
  });
}
