// path: test/fitur/whatsapp/info_paket_test.dart

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/fitur/paket/enum/tipe_durasi_paket.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/paket/operasi/paket_op_sqlite.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_sqlite.dart';
import 'package:wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/whatsapp/info_paket.dart';

import 'info_paket_test.mocks.dart';

// Mocks for dependencies
@GenerateMocks([PelangganOpSqlite, PaketOpSqlite])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PesanInfoPaket pesanInfoPaket;
  late MockPelangganOpSqlite mockPelangganOpSqlite;
  late MockPaketOpSqlite mockPaketOpSqlite;

  const channel = MethodChannel(
    'plugins.flutter.io/url_launcher',
  );
  String? launchedUrl;
  var canLaunchReturnValue = true;

  setUp(() {
    mockPelangganOpSqlite = MockPelangganOpSqlite();
    mockPaketOpSqlite = MockPaketOpSqlite();
    launchedUrl = null;
    canLaunchReturnValue = true;

    pesanInfoPaket = PesanInfoPaket(
      pelangganOpSqlite: mockPelangganOpSqlite,
      paketOpSqlite: mockPaketOpSqlite,
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'canLaunch') {
        return canLaunchReturnValue;
      }
      if (methodCall.method == 'launch') {
        launchedUrl =
            (methodCall.arguments as Map<String, dynamic>)['url'] as String?;
        return true;
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  final pelangganAktif = PelangganAktifModel(
    id: 'pa1',
    idPelanggan: 'c1',
    idPaket: 'p1',
    idTransaksi: 't1',
    tanggalMulai: DateTime(2023),
    tanggalBerakhir: DateTime(2023, 1, 31),
    status: StatusPembayaran.paid,
    diperbaruiPada: DateTime(2023),
  );

  final pelanggan = PelangganModel(
    id: 'c1',
    nama: 'John Doe',
    telepon: '081234567890',
    alamat: 'Jl. Contoh',
    kataSandi: 'password123',
    macAddress: 'AA:BB:CC:DD:EE:FF',
    diperbaruiPada: DateTime(2023),
  );

  final paket = PaketModel(
    id: 'p1',
    nama: 'Paket Kencang',
    harga: 100000,
    durasi: 30,
    tipe: TipeDurasiPaket.days,
    diperbaruiPada: DateTime(2023),
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

        await pesanInfoPaket.kirimRincianPaket(pelangganAktif);

        verify(mockPelangganOpSqlite.ambilBerdasarkanId('c1')).called(1);
        verify(mockPaketOpSqlite.ambilBerdasarkanId('p1')).called(1);

        expect(launchedUrl, isNotNull);
        expect(launchedUrl, startsWith('https://wa.me/6281234567890'));
      },
    );

    test(
      '02. tidak mengirim rincian paket jika pelanggan tidak ditemukan',
      () async {
        when(
          mockPelangganOpSqlite.ambilBerdasarkanId('c1'),
        ).thenAnswer((_) async => null);
        when(
          mockPaketOpSqlite.ambilBerdasarkanId('p1'),
        ).thenAnswer((_) async => paket);

        await pesanInfoPaket.kirimRincianPaket(pelangganAktif);

        verify(mockPelangganOpSqlite.ambilBerdasarkanId('c1')).called(1);
        verifyNever(mockPaketOpSqlite.ambilBerdasarkanId('p1'));

        expect(launchedUrl, isNull);
      },
    );

    test(
      '03. tidak mengirim rincian paket jika paket tidak ditemukan',
      () async {
        when(
          mockPelangganOpSqlite.ambilBerdasarkanId('c1'),
        ).thenAnswer((_) async => pelanggan);
        when(
          mockPaketOpSqlite.ambilBerdasarkanId('p1'),
        ).thenAnswer((_) async => null);

        await pesanInfoPaket.kirimRincianPaket(pelangganAktif);

        verify(mockPelangganOpSqlite.ambilBerdasarkanId('c1')).called(1);
        verify(mockPaketOpSqlite.ambilBerdasarkanId('p1')).called(1);

        expect(launchedUrl, isNull);
      },
    );

    test(
      '04. tidak mencoba membuka URL jika canLaunch mengembalikan false',
      () async {
        when(
          mockPelangganOpSqlite.ambilBerdasarkanId('c1'),
        ).thenAnswer((_) async => pelanggan);
        when(
          mockPaketOpSqlite.ambilBerdasarkanId('p1'),
        ).thenAnswer((_) async => paket);

        canLaunchReturnValue = false;

        await pesanInfoPaket.kirimRincianPaket(pelangganAktif);

        verify(mockPelangganOpSqlite.ambilBerdasarkanId('c1')).called(1);
        verify(mockPaketOpSqlite.ambilBerdasarkanId('p1')).called(1);

        expect(launchedUrl, isNull);
      },
    );
  });
}
