// path: test/fitur/whatsapp/info_paket_test.dart

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

/// Hub Fake Komprehensif untuk menangkap seluruh lifecycle url_launcher modern
class FakeUrlLauncherPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements UrlLauncherPlatform {
  String? launchedUrl;
  bool canLaunchReturnValue = true;

  @override
  Future<bool> canLaunch(String url) async {
    return canLaunchReturnValue;
  }

  @override
  Future<bool> canLaunchUrl(String url, Map<String, Object> attributes) async {
    return canLaunchReturnValue;
  }

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launchedUrl = url;
    return true;
  }

  @override
  Future<bool> supportsLaunchMode(PreferredLaunchMode mode) async {
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    // Menangkap variasi internal method seperti launch, launchUrlString, dll.
    final memberName = invocation.memberName.toString();
    if (memberName.contains('launch') || memberName.contains('Launch')) {
      if (invocation.positionalArguments.isNotEmpty) {
        final firstArg = invocation.positionalArguments.first;
        if (firstArg is String) {
          launchedUrl = firstArg;
        }
      }
      return Future<bool>.value(true);
    }
    
    // Default value untuk fungsi pendukung boolean lainnya agar tidak return null
    if (invocation.isGetter || invocation.isMethod) {
      return Future<bool>.value(true);
    }
    
    return super.noSuchMethod(invocation);
  }
}

@GenerateMocks([PelangganOpSqlite, PaketOpSqlite])
void main() {
  late PesanInfoPaket pesanInfoPaket;
  late MockPelangganOpSqlite mockPelangganOpSqlite;
  late MockPaketOpSqlite mockPaketOpSqlite;
  late FakeUrlLauncherPlatform fakeUrlLauncher;

  setUp(() {
    mockPelangganOpSqlite = MockPelangganOpSqlite();
    mockPaketOpSqlite = MockPaketOpSqlite();
    fakeUrlLauncher = FakeUrlLauncherPlatform();

    UrlLauncherPlatform.instance = fakeUrlLauncher;

    pesanInfoPaket = PesanInfoPaket(
      pelangganOpSqlite: mockPelangganOpSqlite,
      paketOpSqlite: mockPaketOpSqlite,
    );
  });

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
        when(mockPelangganOpSqlite.ambilBerdasarkanId('c1'))
            .thenAnswer((_) async => pelanggan);
        when(mockPaketOpSqlite.ambilBerdasarkanId('p1'))
            .thenAnswer((_) async => paket);

        await pesanInfoPaket.kirimRincianPaket(pelangganAktif);

        verify(mockPelangganOpSqlite.ambilBerdasarkanId('c1')).called(1);
        verify(mockPaketOpSqlite.ambilBerdasarkanId('p1')).called(1);

        expect(fakeUrlLauncher.launchedUrl, isNotNull);
        expect(
          fakeUrlLauncher.launchedUrl,
          startsWith('https://wa.me/6281234567890'),
        );
      },
    );

    test(
      '02. tidak mengirim rincian paket jika pelanggan tidak ditemukan',
      () async {
        when(mockPelangganOpSqlite.ambilBerdasarkanId('c1'))
            .thenAnswer((_) async => null);
        when(mockPaketOpSqlite.ambilBerdasarkanId('p1'))
            .thenAnswer((_) async => paket);

        await pesanInfoPaket.kirimRincianPaket(pelangganAktif);

        verify(mockPelangganOpSqlite.ambilBerdasarkanId('c1')).called(1);
        verify(mockPaketOpSqlite.ambilBerdasarkanId('p1')).called(1);
        expect(fakeUrlLauncher.launchedUrl, isNull);
      },
    );

    test(
      '03. tidak mengirim rincian paket jika paket tidak ditemukan',
      () async {
        when(mockPelangganOpSqlite.ambilBerdasarkanId('c1'))
            .thenAnswer((_) async => pelanggan);
        when(mockPaketOpSqlite.ambilBerdasarkanId('p1'))
            .thenAnswer((_) async => null);

        await pesanInfoPaket.kirimRincianPaket(pelangganAktif);

        verify(mockPelangganOpSqlite.ambilBerdasarkanId('c1')).called(1);
        verify(mockPaketOpSqlite.ambilBerdasarkanId('p1')).called(1);
        expect(fakeUrlLauncher.launchedUrl, isNull);
      },
    );

    test(
      '04. tidak mencoba membuka URL jika canLaunch mengembalikan false',
      () async {
        when(mockPelangganOpSqlite.ambilBerdasarkanId('c1'))
            .thenAnswer((_) async => pelanggan);
        when(mockPaketOpSqlite.ambilBerdasarkanId('p1'))
            .thenAnswer((_) async => paket);

        fakeUrlLauncher.canLaunchReturnValue = false;

        await pesanInfoPaket.kirimRincianPaket(pelangganAktif);

        verify(mockPelangganOpSqlite.ambilBerdasarkanId('c1')).called(1);
        verify(mockPaketOpSqlite.ambilBerdasarkanId('p1')).called(1);

        expect(fakeUrlLauncher.launchedUrl, isNull);
      },
    );
  });
}