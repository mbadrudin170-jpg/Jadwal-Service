// path: test/fitur/akun/page/daftar_akun_page_test.dart
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
// IMPORT INI UNTUK MENYEDIAKAN FUNGSI MOCK FIREBASE RESMI YANG SESUAI DENGAN PIGEON CODEC
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/fitur/akun/page/daftar_akun_page.dart';
import 'package:wifi/fitur/akun/provider/akun_provider.dart';
import 'package:wifi/fitur/pelanggan/core/layanan_aktivitas_user.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/shared/providers/shared_providers.dart';
import 'package:wifi/user/providers/user_provider.dart';
import 'package:wifi/user/services/storage/layanan_penyimpanan_lokal.dart';

import 'daftar_akun_page_test.mocks.dart';

// Membuat objek Fake untuk mensimulasikan Notifier secara aman tanpa merusak internal Riverpod
class FakePengelolaAkun extends PengelolaAkun {
  final Future<AkunState> Function() fungsiBuild;

  FakePengelolaAkun(this.fungsiBuild);

  final List<PelangganModel> daftarPanggilanLogin = [];
  final List<String> daftarPanggilanHapus = [];
  int totalHapusToken = 0;

  @override
  Future<AkunState> build() => fungsiBuild();

  @override
  Future<void> login(PelangganModel pelanggan) async {
    daftarPanggilanLogin.add(pelanggan);
  }

  @override
  Future<void> hapusAkun(String id) async {
    daftarPanggilanHapus.add(id);
  }

  @override
  Future<void> hapusTokenLogin() async {
    totalHapusToken++;
  }
}

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
  MockSpec<FirebaseFirestore>(),
])
void main() {

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  late MockLayananAktivitasUser mockLayananAktivitasUser;
  late MockFirebaseFirestore mockFirebaseFirestore;
  late PelangganModel pelanggan1;
  late PelangganModel pelanggan2;

  setUp(() {
    mockLayananAktivitasUser = MockLayananAktivitasUser();
    mockFirebaseFirestore = MockFirebaseFirestore();

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

  Widget buatWidgetUji({
    required NavigatorObserver pengamatNavigator,
    required PengelolaAkun pengelola,
    PelangganModel? akunLokal,
    String? idUserSaatIni,
  }) {
    return ProviderScope(
      overrides: [
        firestoreProvider.overrideWithValue(mockFirebaseFirestore),
        pengelolaAkunProvider.overrideWith(() => pengelola),
        layananAktivitasUserProvider.overrideWith(
          (ref) => Future.value(mockLayananAktivitasUser),
        ),
        layananPenyimpananLokalProvider.overrideWith(
          (ref) => Future.value(FakeLayananPenyimpananLokal(akunLokal)),
        ),
        userIdProvider.overrideWith((ref) => idUserSaatIni),
      ],
      child: MaterialApp(
        home: const DaftarAkunPage(),
        navigatorObservers: [pengamatNavigator],
      ),
    );
  }

  group('DaftarAkunPage UI States', () {
    testWidgets(
      '01. harus menampilkan CircularProgressIndicator saat loading',
      (tester) async {
        final pengamatLokal = MockNavigatorObserver();
        final penyelesai = Completer<AkunState>();
        final pengelolaPalsu = FakePengelolaAkun(() => penyelesai.future);

        await tester.pumpWidget(
          buatWidgetUji(
            pengamatNavigator: pengamatLokal,
            pengelola: pengelolaPalsu,
          ),
        );
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets('02. harus menampilkan pesan error saat provider gagal', (
      tester,
    ) async {
      final pengamatLokal = MockNavigatorObserver();
      final pengelolaPalsu = FakePengelolaAkun(
        () => Future.error(Exception('Gagal memuat')),
      );

      await tester.pumpWidget(
        buatWidgetUji(
          pengamatNavigator: pengamatLokal,
          pengelola: pengelolaPalsu,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Gagal memuat akun:'), findsOneWidget);
    });

    testWidgets('03. harus menampilkan pesan saat daftar akun kosong', (
      tester,
    ) async {
      final pengamatLokal = MockNavigatorObserver();
      const statusKosong = AkunState();
      final pengelolaPalsu = FakePengelolaAkun(
        () => Future.value(statusKosong),
      );

      await tester.pumpWidget(
        buatWidgetUji(
          pengamatNavigator: pengamatLokal,
          pengelola: pengelolaPalsu,
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
      final pengamatLokal = MockNavigatorObserver();
      final statusData = AkunState(
        daftarAkunTersimpan: [pelanggan1, pelanggan2],
      );
      final pengelolaPalsu = FakePengelolaAkun(() => Future.value(statusData));

      await tester.pumpWidget(
        buatWidgetUji(
          pengamatNavigator: pengamatLokal,
          pengelola: pengelolaPalsu,
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
        final pengamatLokal = MockNavigatorObserver();
        final statusData = AkunState(daftarAkunTersimpan: [pelanggan1]);
        final pengelolaPalsu = FakePengelolaAkun(
          () => Future.value(statusData),
        );

        when(
          mockLayananAktivitasUser.pingAktivitas(any, paksa: anyNamed('paksa')),
        ).thenAnswer((_) async => Future.value());

        await tester.pumpWidget(
          buatWidgetUji(
            pengamatNavigator: pengamatLokal,
            pengelola: pengelolaPalsu,
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('John Doe'));
        await tester.pumpAndSettle();

        expect(pengelolaPalsu.daftarPanggilanLogin.length, 1);
        expect(pengelolaPalsu.daftarPanggilanLogin.first, pelanggan1);
        verify(pengamatLokal.didPush(any, any)).called(2);
      },
    );

    testWidgets('06. harus menampilkan dialog hapus saat long press', (
      tester,
    ) async {
      final pengamatLokal = MockNavigatorObserver();
      final statusData = AkunState(
        akunSaatIni: pelanggan2,
        daftarAkunTersimpan: [pelanggan1, pelanggan2],
      );
      final pengelolaPalsu = FakePengelolaAkun(() => Future.value(statusData));

      await tester.pumpWidget(
        buatWidgetUji(
          pengamatNavigator: pengamatLokal,
          pengelola: pengelolaPalsu,
          idUserSaatIni: pelanggan2.id,
        ),
      );
      await tester.pumpAndSettle();

      await tester.longPress(find.text('John Doe'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Hapus Akun'), findsOneWidget);

      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      expect(pengelolaPalsu.daftarPanggilanHapus, [pelanggan1.id]);
      expect(find.byType(AlertDialog), findsNothing);

      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('07. harus hapus akun aktif dan navigasi ke login page', (
      tester,
    ) async {
      final pengamatLokal = MockNavigatorObserver();
      final statusData = AkunState(
        akunSaatIni: pelanggan1,
        daftarAkunTersimpan: [pelanggan1],
      );
      final pengelolaPalsu = FakePengelolaAkun(() => Future.value(statusData));

      await tester.pumpWidget(
        buatWidgetUji(
          pengamatNavigator: pengamatLokal,
          pengelola: pengelolaPalsu,
          idUserSaatIni: pelanggan1.id,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('John Doe'), findsOneWidget);

      await tester.longPress(find.text('John Doe'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);

      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      expect(pengelolaPalsu.daftarPanggilanHapus, [pelanggan1.id]);
      verify(pengamatLokal.didPush(any, any)).called(3);

      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('08. harus menampilkan dialog keluar', (tester) async {
      final pengamatLokal = MockNavigatorObserver();
      final statusData = AkunState(
        daftarAkunTersimpan: [pelanggan1, pelanggan2],
      );
      final pengelolaPalsu = FakePengelolaAkun(() => Future.value(statusData));

      await tester.pumpWidget(
        buatWidgetUji(
          pengamatNavigator: pengamatLokal,
          pengelola: pengelolaPalsu,
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
      final pengamatLokal = MockNavigatorObserver();
      final statusData = AkunState(
        daftarAkunTersimpan: [pelanggan1, pelanggan2],
      );
      final pengelolaPalsu = FakePengelolaAkun(() => Future.value(statusData));

      await tester.pumpWidget(
        buatWidgetUji(
          pengamatNavigator: pengamatLokal,
          pengelola: pengelolaPalsu,
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

      expect(pengelolaPalsu.totalHapusToken, 1);
      verify(pengamatLokal.didPush(any, any)).called(3);

      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('10. harus keluar dan hapus akun', (tester) async {
      final pengamatLokal = MockNavigatorObserver();
      final statusData = AkunState(
        akunSaatIni: pelanggan1,
        daftarAkunTersimpan: [pelanggan1],
      );
      final pengelolaPalsu = FakePengelolaAkun(() => Future.value(statusData));

      await tester.pumpWidget(
        buatWidgetUji(
          pengamatNavigator: pengamatLokal,
          pengelola: pengelolaPalsu,
          akunLokal: pelanggan1,
          idUserSaatIni: pelanggan1.id,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Keluar'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Keluar & Hapus Akun'));
      await tester.pumpAndSettle();

      expect(pengelolaPalsu.daftarPanggilanHapus, [pelanggan1.id]);
      verify(pengamatLokal.didPush(any, any)).called(3);

      await tester.pump(const Duration(seconds: 3));
    });
  });
}
