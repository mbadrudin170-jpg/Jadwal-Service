// test/fitur/whatsapp/info_paket_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
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

import 'info_paket_test.mocks.dart';

// Membuat Mock manual yang aman dari masalah Non-Nullable dengan menyediakan default value
class MockUrlLauncher extends Mock
    with MockPlatformInterfaceMixin
    implements UrlLauncherPlatform {
  @override
  Future<bool> canLaunch(String? url) async => true;

  @override
  Future<bool> launchUrl(String? url, LaunchOptions? options) async => true;
}

@GenerateMocks([PelangganOpSqlite, PaketOpSqlite])
void main() {
  late PesanInfoPaket pesanInfoPaket;
  late MockPelangganOpSqlite mockPelangganOpSqlite;
  late MockPaketOpSqlite mockPaketOpSqlite;
  late MockUrlLauncher mockUrlLauncher;

  setUp(() {
    mockPelangganOpSqlite = MockPelangganOpSqlite();
    mockPaketOpSqlite = MockPaketOpSqlite();
    mockUrlLauncher = MockUrlLauncher();

    // Mendaftarkan mock platform instance resmi
    UrlLauncherPlatform.instance = mockUrlLauncher;

    pesanInfoPaket = PesanInfoPaket(
      pelangganOpSqlite: mockPelangganOpSqlite,
      paketOpSqlite: mockPaketOpSqlite,
    );
  });

  // Data dummy
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

  group('kirimRincianPaket', () {
    test(
      '01. harus mengirim rincian paket jika pelanggan dan paket ditemukan dan URL bisa dibuka',
      () async {
        when(
          mockPelangganOpSqlite.ambilBerdasarkanId('c1'),
        ).thenAnswer((_) async => pelanggan);
        when(
          mockPaketOpSqlite.ambilBerdasarkanId('p1'),
        ).thenAnswer((_) async => paket);

        // Menggunakan nilai string kosong atau object dummy untuk menghindari bad null argument passthrough
        when(mockUrlLauncher.canLaunch(any)).thenAnswer((_) async => true);
        when(mockUrlLauncher.launchUrl(any, any)).thenAnswer((_) async => true);

        await pesanInfoPaket.kirimRincianPaket(pelangganAktif);

        verify(mockPelangganOpSqlite.ambilBerdasarkanId('c1')).called(1);
        verify(mockPaketOpSqlite.ambilBerdasarkanId('p1')).called(1);

        verify(
          mockUrlLauncher.canLaunch(
            argThat(startsWith('https://wa.me/6281234567890')),
          ),
        ).called(1);

        verify(
          mockUrlLauncher.launchUrl(
            argThat(startsWith('https://wa.me/6281234567890')),
            any,
          ),
        ).called(1);
      },
    );

    test(
      '02. tidak mengirim rincian paket jika pelanggan tidak ditemukan',
      () async {
        when(
          mockPelangganOpSqlite.ambilBerdasarkanId(any),
        ).thenAnswer((_) async => null);

        await pesanInfoPaket.kirimRincianPaket(pelangganAktif);

        verify(mockPelangganOpSqlite.ambilBerdasarkanId('c1')).called(1);
        verifyNever(mockPaketOpSqlite.ambilBerdasarkanId(any));
        verifyNever(mockUrlLauncher.canLaunch(any));
        verifyNever(mockUrlLauncher.launchUrl(any, any));
      },
    );

    test(
      '03. tidak mengirim rincian paket jika paket tidak ditemukan',
      () async {
        when(
          mockPelangganOpSqlite.ambilBerdasarkanId(any),
        ).thenAnswer((_) async => pelanggan);
        when(
          mockPaketOpSqlite.ambilBerdasarkanId(any),
        ).thenAnswer((_) async => null);

        await pesanInfoPaket.kirimRincianPaket(pelangganAktif);

        verify(mockPelangganOpSqlite.ambilBerdasarkanId('c1')).called(1);
        verify(mockPaketOpSqlite.ambilBerdasarkanId('p1')).called(1);
        verifyNever(mockUrlLauncher.canLaunch(any));
        verifyNever(mockUrlLauncher.launchUrl(any, any));
      },
    );

    test(
      '04. tidak mencoba membuka URL jika canLaunch mengembalikan false',
      () async {
        when(
          mockPelangganOpSqlite.ambilBerdasarkanId(any),
        ).thenAnswer((_) async => pelanggan);
        when(
          mockPaketOpSqlite.ambilBerdasarkanId(any),
        ).thenAnswer((_) async => paket);

        when(mockUrlLauncher.canLaunch(any)).thenAnswer((_) async => false);

        await pesanInfoPaket.kirimRincianPaket(pelangganAktif);

        verify(mockPelangganOpSqlite.ambilBerdasarkanId('c1')).called(1);
        verify(mockPaketOpSqlite.ambilBerdasarkanId('p1')).called(1);

        verify(
          mockUrlLauncher.canLaunch(
            argThat(startsWith('https://wa.me/6281234567890')),
          ),
        ).called(1);
        verifyNever(mockUrlLauncher.launchUrl(any, any));
      },
    );
  });
}
