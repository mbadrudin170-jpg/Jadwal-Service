// path: test/admin/halaman/form/form_pelanggan_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_sqlite.dart';
import 'package:wifi/fitur/pelanggan/page/admin/form_pelanggan.dart';
import 'package:wifi/fitur/sinkronisasi/layanan_cek_sinkronisasi.dart';
import 'package:wifi/shared/services/koneksi_internet_service.dart';

import 'form_pelanggan_test.mocks.dart';

// The GenerateMocks annotation is necessary for mockito to generate the mock classes.
@GenerateMocks([
  PelangganOpSqlite,
  KoneksiInternetService,
  LayananCekSinkronisasi,
  NavigatorObserver
])
void main() {
  late MockPelangganOpSqlite mockPelangganOpSqlite;
  late MockKoneksiInternetService mockKoneksiInternetService;
  late MockLayananCekSinkronisasi mockLayananCekSinkronisasi;
  late MockNavigatorObserver mockNavigatorObserver;

  setUp(() {
    mockPelangganOpSqlite = MockPelangganOpSqlite();
    mockKoneksiInternetService = MockKoneksiInternetService();
    mockLayananCekSinkronisasi = MockLayananCekSinkronisasi();
    mockNavigatorObserver = MockNavigatorObserver();
  });

  final pelangganModel = PelangganModel(
    id: '1',
    nama: 'John Doe',
    telepon: '08123456789',
    alamat: '123 Main St',
    kataSandi: 'password',
    macAddress: '00:11:22:33:44:55',
  );

  Widget createWidget({PelangganModel? pelanggan}) {
    return ProviderScope(
      overrides: [
        pelangganOpSqliteProvider.overrideWithValue(mockPelangganOpSqlite),
        koneksiInternetServiceProvider
            .overrideWithValue(mockKoneksiInternetService),
        layananCekSinkronisasiProvider
            .overrideWithValue(mockLayananCekSinkronisasi),
      ],
      child: MaterialApp(
        home: FormPelanggan(pelanggan: pelanggan),
        navigatorObservers: [mockNavigatorObserver],
      ),
    );
  }

  group('FormPelanggan Tests', () {
    testWidgets('01. should display add form when pelanggan is null',
        (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('Tambah Pelanggan'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Nama Pelanggan'), findsOneWidget);
    });

    testWidgets('02. should display edit form when pelanggan is not null',
        (tester) async {
      await tester.pumpWidget(createWidget(pelanggan: pelangganModel));

      expect(find.text('Edit Pelanggan'), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('03. should show validation errors for empty fields',
        (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.tap(find.text('SIMPAN'));
      await tester.pump();

      expect(find.text('Nama tidak boleh kosong'), findsOneWidget);
      expect(find.text('Telepon tidak boleh kosong'), findsOneWidget);
      expect(find.text('Alamat tidak boleh kosong'), findsOneWidget);
      expect(find.text('Password tidak boleh kosong'), findsOneWidget);
      expect(find.text('MAC Address tidak boleh kosong'), findsOneWidget);
    });

    testWidgets('04. should add new customer when form is valid',
        (tester) async {
      when(mockPelangganOpSqlite.tambahPelanggan(any))
          .thenAnswer((_) async => Future.value());
      when(mockKoneksiInternetService.cekKoneksiLokal())
          .thenAnswer((_) async => true);
      when(mockLayananCekSinkronisasi.jalankanCekSinkronisasi())
          .thenAnswer((_) async => Future.value());

      await tester.pumpWidget(createWidget());

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Nama Pelanggan'), 'Jane Doe');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Nomor Telepon (WhatsApp)'),
          '08987654321');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Alamat Lengkap'), '456 Oak Ave');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'), 'new_password');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'MAC Address'), '66:77:88:99:AA:BB');

      await tester.tap(find.text('SIMPAN'));
      await tester.pumpAndSettle(); // Use pumpAndSettle to wait for futures to complete

      verify(mockPelangganOpSqlite.tambahPelanggan(any));
    });

    testWidgets('05. should update existing customer when form is valid',
        (tester) async {
      when(mockPelangganOpSqlite.perbaruiPelanggan(any))
          .thenAnswer((_) async => Future.value());
      when(mockKoneksiInternetService.cekKoneksiLokal())
          .thenAnswer((_) async => true);
      when(mockLayananCekSinkronisasi.jalankanCekSinkronisasi())
          .thenAnswer((_) async => Future.value());

      await tester.pumpWidget(createWidget(pelanggan: pelangganModel));

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Nama Pelanggan'), 'John Doe Updated');
      
      await tester.tap(find.text('SIMPAN'));
      await tester.pumpAndSettle(); // Use pumpAndSettle

      verify(mockPelangganOpSqlite.perbaruiPelanggan(any));
    });

     testWidgets('06. should show CircularProgressIndicator while saving', (WidgetTester tester) async {
      when(mockPelangganOpSqlite.tambahPelanggan(any)).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(seconds: 1));
      });
      when(mockKoneksiInternetService.cekKoneksiLokal()).thenAnswer((_) async => false);
      
      await tester.pumpWidget(createWidget());

      await tester.enterText(find.widgetWithText(TextFormField, 'Nama Pelanggan'), 'Test');
      await tester.enterText(find.widgetWithText(TextFormField, 'Nomor Telepon (WhatsApp)'), '123');
      await tester.enterText(find.widgetWithText(TextFormField, 'Alamat Lengkap'), 'Address');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'pass');
      await tester.enterText(find.widgetWithText(TextFormField, 'MAC Address'), 'MAC');

      await tester.tap(find.text('SIMPAN'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      await tester.pumpAndSettle();
    });

    testWidgets('07. should pop navigator on back button press', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      
      final backButton = find.byType(BackButton);
      expect(backButton, findsOneWidget);
      
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      verify(mockNavigatorObserver.didPop(any, any));
    });
  });
}
