// path: test/fitur/akun/page/daftar_akun_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/fitur/akun/akun_state.dart';
import 'package:wifi/fitur/akun/page/daftar_akun_page.dart';
import 'package:wifi/fitur/akun/provider/akun_provider.dart';
import 'package:wifi/fitur/pelanggan/core/user_activity_service.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/user/providers/user_providers.dart';

import 'daftar_akun_page_test.mocks.dart';

class FakeRoute<T> extends Fake implements Route<T> {}

@GenerateMocks([
  PengelolaAkun,
  UserActivityService,
  NavigatorObserver,
])
void main() {
  late MockPengelolaAkun mockPengelolaAkun;
  late MockUserActivityService mockUserActivityService;
  late MockNavigatorObserver mockNavigatorObserver;
  late PelangganModel pelanggan1;
  late PelangganModel pelanggan2;

  setUpAll(() {
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

  Widget createWidgetUnderTest({
    String? currentUserId,
  }) {
    return ProviderScope(
      overrides: [
        pengelolaAkunProvider.overrideWith(() => mockPengelolaAkun),
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
      when(mockPengelolaAkun.state).thenReturn(const AsyncValue.loading());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('02. harus menampilkan pesan error saat provider gagal',
        (tester) async {
      final error = Exception('Gagal memuat');
      when(mockPengelolaAkun.state)
          .thenReturn(AsyncValue.error(error, StackTrace.current));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Gagal memuat akun: $error'), findsOneWidget);
    });

    testWidgets('03. harus menampilkan pesan saat daftar akun kosong',
        (tester) async {
      when(mockPengelolaAkun.state).thenReturn(
        const AsyncValue.data(
            AkunState(akunSaatIni: null, daftarAkunTersimpan: [])),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Belum ada riwayat login di perangkat ini.'),
          findsOneWidget);
    });

    testWidgets('04. harus menampilkan daftar akun saat ada data',
        (tester) async {
      when(mockPengelolaAkun.state).thenReturn(
        AsyncValue.data(
            AkunState(daftarAkunTersimpan: [pelanggan1, pelanggan2])),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(Card), findsNWidgets(2));
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Jane Doe'), findsOneWidget);
    });
  });

  group('Interaksi Pengguna', () {
    testWidgets('05. harus login dan navigasi saat akun dipilih',
        (tester) async {
      when(mockPengelolaAkun.state).thenReturn(
        AsyncValue.data(AkunState(daftarAkunTersimpan: [pelanggan1])),
      );
      when(mockPengelolaAkun.login(pelanggan1)).thenAnswer((_) async {});
      when(mockUserActivityService.pingActivity(pelanggan1.id, force: true))
          .thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('John Doe'));
      await tester.pumpAndSettle();

      verify(mockPengelolaAkun.login(pelanggan1)).called(1);
      verify(mockUserActivityService.pingActivity(pelanggan1.id, force: true))
          .called(1);
      verify(mockNavigatorObserver.didPush(any, any)).called(1);
    });

    testWidgets('06. harus menampilkan dialog hapus saat long press',
        (tester) async {
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

      await tester.longPress(find.text('John Doe'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Hapus Akun'), findsOneWidget);

      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      verify(mockPengelolaAkun.hapusAkun(pelanggan1.id)).called(1);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('07. harus hapus akun aktif dan navigasi ke login page',
        (tester) async {
      when(mockPengelolaAkun.state).thenReturn(
        AsyncValue.data(AkunState(
            akunSaatIni: pelanggan1, daftarAkunTersimpan: [pelanggan1])),
      );
      when(mockPengelolaAkun.hapusAkun(pelanggan1.id)).thenAnswer((_) async {});

      await tester.pumpWidget(
        createWidgetUnderTest(currentUserId: pelanggan1.id),
      );
      await tester.pumpAndSettle();

      await tester.longPress(find.text('John Doe'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);

      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      verify(mockPengelolaAkun.hapusAkun(pelanggan1.id)).called(1);
      verify(mockNavigatorObserver.didPush(any, any)).called(1);
    });

    testWidgets('08. harus menampilkan dialog keluar', (tester) async {
      when(mockPengelolaAkun.state).thenReturn(
        const AsyncValue.data(
            AkunState(akunSaatIni: null, daftarAkunTersimpan: [])),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Keluar'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Pilih metode keluar:'), findsOneWidget);
      expect(find.text('Keluar & Hapus Akun'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Keluar'), findsOneWidget);
    });

    testWidgets('09. harus keluar dan hapus token', (tester) async {
      when(mockPengelolaAkun.state).thenReturn(
        const AsyncValue.data(
            AkunState(akunSaatIni: null, daftarAkunTersimpan: [])),
      );
      when(mockPengelolaAkun.hapusTokenLogin()).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Keluar'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, 'Keluar'));
      await tester.pumpAndSettle();

      verify(mockPengelolaAkun.hapusTokenLogin()).called(1);
      verify(mockNavigatorObserver.didPush(any, any)).called(1);
    });

    testWidgets('10. harus keluar dan hapus akun', (tester) async {
      when(mockPengelolaAkun.state).thenReturn(
        AsyncValue.data(
            AkunState(akunSaatIni: pelanggan1, daftarAkunTersimpan: [])),
      );
      when(mockPengelolaAkun.hapusAkun(pelanggan1.id)).thenAnswer((_) async {});

      await tester
          .pumpWidget(createWidgetUnderTest(currentUserId: pelanggan1.id));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Keluar'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Keluar & Hapus Akun'));
      await tester.pumpAndSettle();

      verify(mockPengelolaAkun.hapusAkun(pelanggan1.id)).called(1);
      verify(mockNavigatorObserver.didPush(any, any)).called(1);
    });
  });
}
