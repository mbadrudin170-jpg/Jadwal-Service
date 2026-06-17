// path: test/fitur/whatsapp/info_paket_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:wifi/fitur/paket/enum/tipe_durasi_paket.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/paket/operasi/paket_op_sqlite.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_sqlite.dart';
import 'package:wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/whatsapp/info_paket.dart';

class MockUrlLauncherPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements UrlLauncherPlatform {}

class MockPelangganOpSqlite extends Mock implements PelangganOpSqlite {}

class MockPaketOpSqlite extends Mock implements PaketOpSqlite {}

class FakeLaunchOptions extends Fake implements LaunchOptions {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeLaunchOptions());
  });

  late PesanInfoPaket pesanInfoPaket;
  late MockPelangganOpSqlite mockPelangganOpSqlite;
  late MockPaketOpSqlite mockPaketOpSqlite;
  late MockUrlLauncherPlatform mockUrlLauncher;

  setUp(() {
    mockPelangganOpSqlite = MockPelangganOpSqlite();
    mockPaketOpSqlite = MockPaketOpSqlite();
    mockUrlLauncher = MockUrlLauncherPlatform();
    UrlLauncherPlatform.instance = mockUrlLauncher;

    pesanInfoPaket = PesanInfoPaket(
      pelangganAktifOpSqlite: mockPelangganOpSqlite,
      paketOpSqlite: mockPaketOpSqlite,
    );
  });

  group('kirimRincianPaket', () {
    final pelangganAktif = PelangganAktifModel(
      id: 'pa1',
      idPelanggan: 'c1',
      idPaket: 'p1',
      idTransaksi: 't1',
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
        when(
          () => mockPelangganOpSqlite.ambilBerdasarkanId('c1'),
        ).thenAnswer((_) async => pelanggan);
        when(
          () => mockPaketOpSqlite.ambilBerdasarkanId('p1'),
        ).thenAnswer((_) async => paket);

        when(
          () => mockUrlLauncher.canLaunch(any()),
        ).thenAnswer((_) async => true);

        // Diubah kembali menjadi 2 argumen posisional wajib
        when(
          () => mockUrlLauncher.launchUrl(any(), any()),
        ).thenAnswer((_) async => true);

        await pesanInfoPaket.kirimRincianPaket(pelangganAktif);

        verify(() => mockPelangganOpSqlite.ambilBerdasarkanId('c1')).called(1);
        verify(() => mockPaketOpSqlite.ambilBerdasarkanId('p1')).called(1);

        verify(
          () => mockUrlLauncher.canLaunch(
            any(that: contains('wa.me/6281234567890')),
          ),
        ).called(1);

        verify(
          () => mockUrlLauncher.launchUrl(
            any(that: contains('wa.me/6281234567890')),
            any(), // Parameter posisional kedua untuk LaunchOptions
          ),
        ).called(1);
      },
    );

    test(
      '02. tidak mengirim rincian paket jika pelanggan tidak ditemukan',
      () async {
        when(
          () => mockPelangganOpSqlite.ambilBerdasarkanId('c1'),
        ).thenAnswer((_) async => null);
        when(
          () => mockPaketOpSqlite.ambilBerdasarkanId('p1'),
        ).thenAnswer((_) async => paket);

        await pesanInfoPaket.kirimRincianPaket(pelangganAktif);

        verify(() => mockPelangganOpSqlite.ambilBerdasarkanId('c1')).called(1);
        verify(() => mockPaketOpSqlite.ambilBerdasarkanId('p1')).called(1);
        verifyNever(() => mockUrlLauncher.canLaunch(any()));
        verifyNever(() => mockUrlLauncher.launchUrl(any(), any()));
      },
    );

    test(
      '03. tidak mengirim rincian paket jika paket tidak ditemukan',
      () async {
        when(
          () => mockPelangganOpSqlite.ambilBerdasarkanId('c1'),
        ).thenAnswer((_) async => pelanggan);
        when(
          () => mockPaketOpSqlite.ambilBerdasarkanId('p1'),
        ).thenAnswer((_) async => null);

        await pesanInfoPaket.kirimRincianPaket(pelangganAktif);

        verify(() => mockPelangganOpSqlite.ambilBerdasarkanId('c1')).called(1);
        verify(() => mockPaketOpSqlite.ambilBerdasarkanId('p1')).called(1);
        verifyNever(() => mockUrlLauncher.canLaunch(any()));
        verifyNever(() => mockUrlLauncher.launchUrl(any(), any()));
      },
    );

    test(
      '04. tidak mencoba membuka URL jika canLaunchUrl mengembalikan false',
      () async {
        when(
          () => mockPelangganOpSqlite.ambilBerdasarkanId('c1'),
        ).thenAnswer((_) async => pelanggan);
        when(
          () => mockPaketOpSqlite.ambilBerdasarkanId('p1'),
        ).thenAnswer((_) async => paket);

        when(
          () => mockUrlLauncher.canLaunch(any()),
        ).thenAnswer((_) async => false);

        await pesanInfoPaket.kirimRincianPaket(pelangganAktif);

        verify(() => mockPelangganOpSqlite.ambilBerdasarkanId('c1')).called(1);
        verify(() => mockPaketOpSqlite.ambilBerdasarkanId('p1')).called(1);

        verify(
          () => mockUrlLauncher.canLaunch(
            any(that: contains('wa.me/6281234567890')),
          ),
        ).called(1);
        verifyNever(() => mockUrlLauncher.launchUrl(any(), any()));
      },
    );
  });
}
