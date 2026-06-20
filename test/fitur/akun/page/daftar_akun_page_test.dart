// path: test/fitur/akun/page/daftar_akun_page_test.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/fitur/akun/page/daftar_akun_page.dart';
import 'package:wifi/fitur/akun/provider/akun_provider.dart';
import 'package:wifi/fitur/pelanggan/core/layanan_aktivitas_user.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/shared/providers/shared_providers.dart'; // Ditambahkan untuk layananPenyimpananLokalProvider
import 'package:wifi/user/providers/user_provider.dart';
import 'package:wifi/user/services/storage/layanan_penyimpanan_lokal.dart';

import 'daftar_akun_page_test.mocks.dart';

// Membuat objek Fake untuk mensimulasikan Notifier secara aman tanpa merusak internal Riverpod
class FakePengelolaAkun extends PengelolaAkun {
  final Future<AkunState> Function() onBuild;

  FakePengelolaAkun(this.onBuild);

  // Menyimpan riwayat pemanggilan untuk keperluan verifikasi (assert)
  final List<PelangganModel> loginCalls = [];
  final List<String> hapusAkunCalls = [];
  int hapusTokenLoginCalls = 0;

  @override
  Future<AkunState> build() => onBuild();

  @override
  Future<void> login(PelangganModel pelanggan) async {
    loginCalls.add(pelanggan);
  }

  @override
  Future<void> hapusAkun(String id) async {
    hapusAkunCalls.add(id);
  }

  @override
  Future<void> hapusTokenLogin() async {
    hapusTokenLoginCalls++;
  }
}

// Objek Fake untuk mengontrol data penyimpanan lokal pada skenario keluar akun
class FakeLayananPenyimpananLokal extends Fake
    implements LayananPenyimpananLokal {
  final PelangganModel? akunTerdaftar;
  FakeLayananPenyimpananLokal(this.akunTerdaftar);

  @override
  Future<PelangganModel?> ambilAkunLogin() async => akunTerdaftar;
}

@GenerateNiceMocks([
  MockSpec<LayananAktivitasUser>(),
  MockSpec<NavigatorObserver>(),
])
void main() {
  late MockLayananAktivitasUser mockLayananAktivitasUser;
  late PelangganModel pelanggan1;
  late PelangganModel pelanggan2;

  setUp(() {
    mockLayananAktivitasUser = MockLayananAktivitasUser();

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
    required NavigatorObserver navigatorObserver,
    required PengelolaAkun notifier,
    PelangganModel? akunLokal,
    String? currentUserId,
  }) {
    return ProviderScope(
      overrides: [
        pengelolaAkunProvider.overrideWith(() => notifier),
        layananAktivitasUserProvider.overrideWith(
          (ref) => Future.value(mockLayananAktivitasUser),
        ),
        layananPenyimpananLokalProvider.overrideWith(
          (ref) => Future.value(FakeLayananPenyimpananLokal(akunLokal)),
        ),
        userIdProvider.overrideWith((ref) => currentUserId),
      ],
      child: MaterialApp(
        home: const DaftarAkunPage(),
        navigatorObservers: [navigatorObserver],
      ),
    );
  }

  group('DaftarAkunPage UI States', () {
    testWidgets(
      '01. harus menampilkan CircularProgressIndicator saat loading',
      (tester) async {
        final localObserver = MockNavigatorObserver();
        final completer = Completer<AkunState>();
        final fakeNotifier = FakePengelolaAkun(() => completer.future);

        await tester.pumpWidget(
          createWidgetUnderTest(
            navigatorObserver: localObserver,
            notifier: fakeNotifier,
          ),
        );
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets('02. harus menampilkan pesan error saat provider gagal', (
      tester,
    ) async {
      final localObserver = MockNavigatorObserver();
      final fakeNotifier = FakePengelolaAkun(
        () => Future.error(Exception('Gagal memuat')),
      );

      await tester.pumpWidget(
        createWidgetUnderTest(
          navigatorObserver: localObserver,
          notifier: fakeNotifier,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Gagal memuat akun:'), findsOneWidget);
    });

    testWidgets('03. harus menampilkan pesan saat daftar akun kosong', (
      tester,
    ) async {
      final localObserver = MockNavigatorObserver();
      final emptyState = const AkunState(daftarAkunTersimpan: []);
      final fakeNotifier = FakePengelolaAkun(() => Future.value(emptyState));

      await tester.pumpWidget(
        createWidgetUnderTest(
          navigatorObserver: localObserver,
          notifier: fakeNotifier,
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Belum ada riwayat login di perangkat ini.'),
        findsOneWidget,
      );
    });

    testWidgets('04. harus menampilkan daftar akun saat ada data', (
      tester,
    ) async {
      final localObserver = MockNavigatorObserver();
      final dataState = AkunState(
        akunSaatIni: null,
        daftarAkunTersimpan: [pelanggan1, pelanggan2],
      );
      final fakeNotifier = FakePengelolaAkun(() => Future.value(dataState));

      await tester.pumpWidget(
        createWidgetUnderTest(
          navigatorObserver: localObserver,
          notifier: fakeNotifier,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(Card), findsNWidgets(2));
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Jane Doe'), findsOneWidget);
    });
  });

  group('Interaksi Pengguna', () {
    testWidgets(
      '05. harus login dan navigasi ke main_page.dart saat akun dipilih',
      (tester) async {
        final localObserver = MockNavigatorObserver();
        final dataState = AkunState(daftarAkunTersimpan: [pelanggan1]);
        final fakeNotifier = FakePengelolaAkun(() => Future.value(dataState));

        when(
          mockLayananAktivitasUser.pingAktivitas(any, paksa: anyNamed('paksa')),
        ).thenAnswer((_) async => Future.value());

        await tester.pumpWidget(
          createWidgetUnderTest(
            navigatorObserver: localObserver,
            notifier: fakeNotifier,
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('John Doe'));
        await tester.pumpAndSettle();

        expect(fakeNotifier.loginCalls.length, 1);
        expect(fakeNotifier.loginCalls.first, pelanggan1);
        verify(localObserver.didPush(any, any)).called(1);
      },
    );

    testWidgets('06. harus menampilkan dialog hapus saat long press', (
      tester,
    ) async {
      final localObserver = MockNavigatorObserver();
      final dataState = AkunState(
        akunSaatIni: pelanggan2,
        daftarAkunTersimpan: [pelanggan1, pelanggan2],
      );
      final fakeNotifier = FakePengelolaAkun(() => Future.value(dataState));

      await tester.pumpWidget(
        createWidgetUnderTest(
          navigatorObserver: localObserver,
          notifier: fakeNotifier,
          currentUserId: pelanggan2.id,
        ),
      );
      await tester.pumpAndSettle();

      await tester.longPress(find.text('John Doe'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Hapus Akun'), findsOneWidget);

      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      expect(fakeNotifier.hapusAkunCalls, [pelanggan1.id]);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('07. harus hapus akun aktif dan navigasi ke login page', (
      tester,
    ) async {
      final localObserver = MockNavigatorObserver();
      final dataState = AkunState(
        akunSaatIni: pelanggan1,
        daftarAkunTersimpan: [pelanggan1],
      );
      final fakeNotifier = FakePengelolaAkun(() => Future.value(dataState));

      await tester.pumpWidget(
        createWidgetUnderTest(
          navigatorObserver: localObserver,
          notifier: fakeNotifier,
          currentUserId: pelanggan1.id,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('John Doe'), findsOneWidget);

      await tester.longPress(find.text('John Doe'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);

      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      expect(fakeNotifier.hapusAkunCalls, [pelanggan1.id]);
      verify(localObserver.didPush(any, any)).called(1);
    });

    testWidgets('08. harus menampilkan dialog keluar', (tester) async {
      final localObserver = MockNavigatorObserver();
      final dataState = AkunState(
        akunSaatIni: null,
        daftarAkunTersimpan: [pelanggan1, pelanggan2],
      );
      final fakeNotifier = FakePengelolaAkun(() => Future.value(dataState));

      await tester.pumpWidget(
        createWidgetUnderTest(
          navigatorObserver: localObserver,
          notifier: fakeNotifier,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Keluar'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Pilih metode keluar:'), findsOneWidget);
      expect(find.text('Keluar & Hapus Akun'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Keluar'), findsOneWidget);
    });

    testWidgets('09. harus keluar dan hapus token', (tester) async {
      final localObserver = MockNavigatorObserver();
      final dataState = AkunState(
        akunSaatIni: null,
        daftarAkunTersimpan: [pelanggan1, pelanggan2],
      );
      final fakeNotifier = FakePengelolaAkun(() => Future.value(dataState));

      await tester.pumpWidget(
        createWidgetUnderTest(
          navigatorObserver: localObserver,
          notifier: fakeNotifier,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Keluar'));
      await tester.pumpAndSettle();

      final tombolKeluarSaja = find.byWidgetPredicate(
        (widget) =>
            widget is TextButton &&
            widget.child is Text &&
            (widget.child as Text).data == 'Keluar',
      );
      await tester.tap(tombolKeluarSaja);
      await tester.pumpAndSettle();

      expect(fakeNotifier.hapusTokenLoginCalls, 1);
      verify(localObserver.didPush(any, any)).called(1);
    });

    testWidgets('10. harus keluar dan hapus akun', (tester) async {
      final localObserver = MockNavigatorObserver();
      final dataState = AkunState(
        akunSaatIni: pelanggan1,
        daftarAkunTersimpan: [pelanggan1],
      );
      final fakeNotifier = FakePengelolaAkun(() => Future.value(dataState));

      await tester.pumpWidget(
        createWidgetUnderTest(
          navigatorObserver: localObserver,
          notifier: fakeNotifier,
          akunLokal: pelanggan1,
          currentUserId: pelanggan1.id,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Keluar'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Keluar & Hapus Akun'));
      await tester.pumpAndSettle();

      expect(fakeNotifier.hapusAkunCalls, [pelanggan1.id]);
      verify(localObserver.didPush(any, any)).called(1);
    });
  });
}
