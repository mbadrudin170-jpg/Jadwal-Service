// path: test/fitur/akun/page/daftar_akun_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/fitur/akun/page/daftar_akun_page.dart';
import 'package:wifi/fitur/akun/provider/akun_provider.dart';
import 'package:wifi/fitur/pelanggan/core/user_activity_service.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/shared/providers/shared_providers.dart';

import 'daftar_akun_page_test.mocks.dart';

// Helper class palsu untuk Route, dibutuhkan oleh registerFallbackValue
class FakeRoute<T> extends Fake implements Route<T> {}

@GenerateMocks([
  MockSpec<PengelolaAkun>(),
  MockSpec<UserActivityService>(),
  MockSpec<NavigatorObserver>(),
])
void main() {
  late MockPengelolaAkun mockPengelolaAkun;
  late MockUserActivityService mockUserActivityService;
  late MockNavigatorObserver mockNavigatorObserver;
  late PelangganModel pelanggan1;
  late PelangganModel pelanggan2;

  // Daftarkan fallback value untuk tipe data kustom sebelum semua tes berjalan
  setUpAll(() {
    registerFallbackValue(const AsyncValue<AkunState>.loading());
    registerFallbackValue(FakeRoute());
  });

  setUp(() {
    mockPengelolaAkun = MockPengelolaAkun();
    mockUserActivityService = MockUserActivityService();
    mockNavigatorObserver = MockNavigatorObserver();

    pelanggan1 = const PelangganModel(
      id: 'user1',
      nama: 'John Doe',
      telepon: '123',
      alamat: 'any',
      kataSandi: '123',
      macAddress: 'any',
    );
    pelanggan2 = const PelangganModel(
      id: 'user2',
      nama: 'Jane Doe',
      telepon: '123',
      alamat: 'any',
      kataSandi: '123',
      macAddress: 'any',
    );
  });

  // Fungsi helper untuk membuat widget yang akan diuji
  Widget createWidgetUnderTest({
    String? currentUserId,
  }) {
    return ProviderScope(
      overrides: [
        pengelolaAkunProvider.overrideWith((_) => mockPengelolaAkun),
        userActivityServiceProvider.overrideWithValue(mockUserActivityService),
        userIdProvider.overrideWith((ref) => currentUserId),
      ],
      child: MaterialApp(
        home: const DaftarAkunPage(),
        navigatorObservers: [mockNavigatorObserver],
      ),
    );
  }

  group('DaftarAkunPage UI States', () {
    testWidgets('01. harus menampilkan CircularProgressIndicator saat loading',
        (tester) async {
      // Atur state provider menjadi loading
      when(mockPengelolaAkun.state).thenReturn(const AsyncValue.loading());

      await tester.pumpWidget(createWidgetUnderTest());

      // Verifikasi CircularProgressIndicator ditampilkan
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('02. harus menampilkan pesan error saat provider gagal',
        (tester) async {
      final error = Exception('Gagal memuat');
      // Atur state provider menjadi error
      when(mockPengelolaAkun.state)
          .thenReturn(AsyncValue.error(error, StackTrace.current));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle(); // Tunggu frame selesai

      // Verifikasi pesan error ditampilkan
      expect(find.text('Gagal memuat akun: $error'), findsOneWidget);
    });

    testWidgets('03. harus menampilkan pesan saat daftar akun kosong',
        (tester) async {
      // Atur state provider dengan daftar akun kosong
      when(mockPengelolaAkun.state).thenReturn(
        const AsyncValue.data(
            AkunState(akunSaatIni: null, daftarAkunTersimpan: [])),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verifikasi pesan untuk daftar kosong ditampilkan
      expect(find.text('Belum ada riwayat login di perangkat ini.'),
          findsOneWidget);
    });

    testWidgets('04. harus menampilkan daftar akun saat ada data',
        (tester) async {
      // Atur state provider dengan data akun
      when(mockPengelolaAkun.state).thenReturn(
        AsyncValue.data(
            AkunState(daftarAkunTersimpan: [pelanggan1, pelanggan2])),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verifikasi daftar akun ditampilkan
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(Card), findsNWidgets(2));
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Jane Doe'), findsOneWidget);
    });
  });

  group('Interaksi Pengguna', () {
    testWidgets('05. harus login dan navigasi saat akun dipilih',
        (tester) async {
      // Atur state awal
      when(mockPengelolaAkun.state).thenReturn(
        AsyncValue.data(AkunState(daftarAkunTersimpan: [pelanggan1])),
      );
      // Stub method yang akan dipanggil
      when(mockPengelolaAkun.login(pelanggan1)).thenAnswer((_) async {});
      when(mockUserActivityService.pingActivity(pelanggan1.id, force: true))
          .thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Lakukan aksi tap
      await tester.tap(find.text('John Doe'));
      await tester.pumpAndSettle();

      // Verifikasi method dipanggil
      verify(mockPengelolaAkun.login(pelanggan1)).called(1);
      verify(mockUserActivityService.pingActivity(pelanggan1.id, force: true))
          .called(1);
      // Verifikasi navigasi terjadi
      verify(mockNavigatorObserver.didPush(any, any)).called(1);
    });

    testWidgets('07. harus menampilkan dialog hapus saat long press',
        (tester) async {
      // Atur state awal
      when(mockPengelolaAkun.state).thenReturn(
        AsyncValue.data(AkunState(
            akunSaatIni: pelanggan2,
            daftarAkunTersimpan: [pelanggan1, pelanggan2])),
      );
      when(mockPengelolaAkun.hapusAkun(pelanggan1.id)).thenAnswer((_) async {});

      await tester.pumpWidget(
        createWidgetUnderTest(currentUserId: pelanggan2.id),
      );
      await tester.pumpAndSettle();

      // Aksi long press
      await tester.longPress(find.text('John Doe'));
      await tester.pumpAndSettle();

      // Verifikasi dialog
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Hapus Akun'), findsOneWidget);

      // Aksi tap tombol hapus
      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      // Verifikasi method dipanggil dan dialog hilang
      verify(mockPengelolaAkun.hapusAkun(pelanggan1.id)).called(1);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('08. harus hapus akun aktif dan navigasi ke login page',
        (tester) async {
      // Atur state awal
      when(mockPengelolaAkun.state).thenReturn(
        AsyncValue.data(AkunState(
            akunSaatIni: pelanggan1, daftarAkunTersimpan: [pelanggan1])),
      );
      when(mockPengelolaAkun.hapusAkun(pelanggan1.id)).thenAnswer((_) async {});

      await tester.pumpWidget(
        createWidgetUnderTest(currentUserId: pelanggan1.id),
      );
      await tester.pumpAndSettle();

      // Aksi long press
      await tester.longPress(find.text('John Doe'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);

      // Aksi tap tombol hapus
      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      // Verifikasi method dipanggil dan navigasi terjadi
      verify(mockPengelolaAkun.hapusAkun(pelanggan1.id)).called(1);
      verify(mockNavigatorObserver.didPush(any, any)).called(1);
    });

    testWidgets('10. harus menampilkan dialog keluar', (tester) async {
      // Atur state awal
      when(mockPengelolaAkun.state).thenReturn(
        const AsyncValue.data(
            AkunState(akunSaatIni: null, daftarAkunTersimpan: [])),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Aksi tap tombol keluar
      await tester.tap(find.widgetWithText(ElevatedButton, 'Keluar'));
      await tester.pumpAndSettle();

      // Verifikasi dialog
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Pilih metode keluar:'), findsOneWidget);
      expect(find.text('Keluar & Hapus Akun'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Keluar'), findsOneWidget);
    });

    testWidgets('11. harus keluar dan hapus token', (tester) async {
      // Atur state awal
      when(mockPengelolaAkun.state).thenReturn(
        const AsyncValue.data(
            AkunState(akunSaatIni: null, daftarAkunTersimpan: [])),
      );
      // Stub method yang akan dipanggil
      when(mockPengelolaAkun.hapusTokenLogin()).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Aksi tap tombol keluar
      await tester.tap(find.widgetWithText(ElevatedButton, 'Keluar'));
      await tester.pumpAndSettle();

      // Aksi tap tombol keluar di dialog
      await tester.tap(find.widgetWithText(TextButton, 'Keluar'));
      await tester.pumpAndSettle();

      // Verifikasi method dipanggil dan navigasi terjadi
      verify(mockPengelolaAkun.hapusTokenLogin()).called(1);
      verify(mockNavigatorObserver.didPush(any, any)).called(1);
    });

    testWidgets('12. harus keluar dan hapus akun', (tester) async {
      // Atur state awal
      when(mockPengelolaAkun.state).thenReturn(
        AsyncValue.data(
            AkunState(akunSaatIni: pelanggan1, daftarAkunTersimpan: [])),
      );
      when(mockPengelolaAkun.hapusAkun(pelanggan1.id)).thenAnswer((_) async {});

      await tester
          .pumpWidget(createWidgetUnderTest(currentUserId: pelanggan1.id));
      await tester.pumpAndSettle();

      // Tap tombol keluar
      await tester.tap(find.widgetWithText(ElevatedButton, 'Keluar'));
      await tester.pumpAndSettle();

      // Tap tombol keluar & hapus akun di dialog
      await tester.tap(find.text('Keluar & Hapus Akun'));
      await tester.pumpAndSettle();

      // Verifikasi method dipanggil dan navigasi
      verify(mockPengelolaAkun.hapusAkun(pelanggan1.id)).called(1);
      verify(mockNavigatorObserver.didPush(any, any)).called(1);
    });
  });
}
