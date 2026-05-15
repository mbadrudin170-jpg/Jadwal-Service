// path: test/admin/halaman/lainnya/versi_apk_user_test.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/halaman/detail/detail_versi_apk_user.dart';
import 'package:wifi/admin/halaman/form/form_versi_apk_user.dart';
import 'package:wifi/admin/halaman/lainnya/versi_apk_user.dart';
import 'package:wifi/shared/enum/arsitektur_apk_enum.dart';
import 'package:wifi/shared/model/versi_apk_user_model.dart';
import 'package:wifi/shared/operasi/versi_apk_user_operasi.dart';

// --- Mock ---
class MockVersiApkUserOperasi extends Mock implements VersiApkUserOperasi {}

class MockVersiApkUserModel extends Mock implements VersiApkUserModel {}

class TestNavigatorObserver extends NavigatorObserver {
  final List<Route<dynamic>> pushedRoutes = [];
  @override
  void didPush(
    final Route<dynamic> route,
    final Route<dynamic>? previousRoute,
  ) {
    pushedRoutes.add(route);
  }
}

void main() {
  late MockVersiApkUserOperasi mockOperasi;
  late TestNavigatorObserver navigatorObserver;
  final testData = <VersiApkUserModel>[];

  /// Helper untuk membuat model dummy dengan properti yang diperlukan halaman.
  MockVersiApkUserModel createDummy(
    final String id,
    final String versi,
    final int buildUniversal, {
    final String catatan = '',
  }) {
    final model = MockVersiApkUserModel();
    when(() => model.id).thenReturn(id);
    when(() => model.versiTerbaru).thenReturn(versi);
    when(() => model.nomorBuildTerbaru)
        .thenReturn({ArsitekturApkEnum.universal: buildUniversal});
    when(() => model.catatanRilis).thenReturn(catatan);
    when(() => model.wajibUpdate).thenReturn(false);
    when(() => model.tautanUnduhan).thenReturn(
      VersiApkUserModel.defaultTautanUnduhan,
    );
    when(() => model.youtubeTutorial).thenReturn('');
    return model;
  }

  setUp(() {
    mockOperasi = MockVersiApkUserOperasi();
    navigatorObserver = TestNavigatorObserver();
    testData.clear();

    // Stub default untuk menghindari error saat FormVersiApkUser.initState
    when(() => mockOperasi.ambilVersiApkTerbaru())
        .thenAnswer((final _) async => null);
  });

  Widget buildTestWidget() {
    return MaterialApp(
      navigatorObservers: [navigatorObserver],
      home: VersiApkUserPage(operasi: mockOperasi),
    );
  }

  group('VersiApkUserPage', () {
    testWidgets('menampilkan loading indicator saat awal',
        (final tester) async {
      when(() => mockOperasi.ambilSemuaVersiApkAktif()).thenAnswer(
        (final _) => Future.delayed(
          const Duration(seconds: 1),
          () => <VersiApkUserModel>[],
        ),
      );

      await tester.pumpWidget(buildTestWidget());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('menampilkan pesan error jika gagal memuat',
        (final tester) async {
      when(() => mockOperasi.ambilSemuaVersiApkAktif())
          .thenThrow(Exception('Gagal koneksi'));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('Gagal memuat data'), findsOneWidget);
    });

    testWidgets('menampilkan placeholder saat data kosong',
        (final tester) async {
      when(() => mockOperasi.ambilSemuaVersiApkAktif())
          .thenAnswer((final _) async => []);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Tidak ada data versi APK.'), findsOneWidget);
    });

    testWidgets('menampilkan data dan urutan default (Build Z-A)',
        (final tester) async {
      final d1 = createDummy('1', '1.0.0', 10);
      final d2 = createDummy('2', '2.0.0', 20);
      final d3 = createDummy('3', '1.5.0', 5);
      when(() => mockOperasi.ambilSemuaVersiApkAktif())
          .thenAnswer((final _) async => [d1, d2, d3]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final itemFinder = find.textContaining('Build:');
      expect(itemFinder, findsNWidgets(3));
      final texts =
          tester.widgetList<Text>(itemFinder).map((final w) => w.data).toList();
      expect(texts[0], contains('Build: 20'));
      expect(texts[1], contains('Build: 10'));
      expect(texts[2], contains('Build: 5'));
    });

    testWidgets('mengubah urutan melalui dialog sort', (final tester) async {
      final d1 = createDummy('1', '2.0.0', 20);
      final d2 = createDummy('2', '1.0.0', 10);
      when(() => mockOperasi.ambilSemuaVersiApkAktif())
          .thenAnswer((final _) async => [d1, d2]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.sort));
      await tester.pumpAndSettle();

      expect(find.text('Urutkan Berdasarkan'), findsOneWidget);

      await tester.tap(find.text('Versi (A-Z)'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      final texts = tester
          .widgetList<Text>(find.textContaining('Build:'))
          .map((final w) => w.data)
          .toList();
      expect(texts[0], contains('Build: 10'));
      expect(texts[1], contains('Build: 20'));
    });

    testWidgets('tap item navigasi ke detail', (final tester) async {
      final d1 = createDummy('1', '1.0.0', 10);
      when(() => mockOperasi.ambilSemuaVersiApkAktif())
          .thenAnswer((final _) async => [d1]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('Versi: 1.0.0'));
      await tester.pumpAndSettle();

      expect(navigatorObserver.pushedRoutes, isNotEmpty);
      final lastRoute =
          navigatorObserver.pushedRoutes.last as MaterialPageRoute;
      final builtWidget = lastRoute.builder(
        tester.element(find.byType(MaterialApp)),
      );
      expect(builtWidget, isA<DetailVersiApkUser>());
    });

    testWidgets('long press menampilkan dialog opsi', (final tester) async {
      final d1 = createDummy('1', '1.0.0', 10);
      when(() => mockOperasi.ambilSemuaVersiApkAktif())
          .thenAnswer((final _) async => [d1]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.longPress(find.textContaining('Versi: 1.0.0'));
      await tester.pumpAndSettle();

      expect(find.text('Opsi Versi 1.0.0'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Arsipkan'), findsOneWidget);
    });

    testWidgets('arsipkan item sukses menampilkan snackbar',
        (final tester) async {
      final d1 = createDummy('1', '1.0.0', 10);
      when(() => mockOperasi.ambilSemuaVersiApkAktif())
          .thenAnswer((final _) async => [d1]);
      when(() => mockOperasi.arsipkanVersiApkUser('1'))
          .thenAnswer((final _) async => {});

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.longPress(find.textContaining('Versi: 1.0.0'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Arsipkan'));
      await tester.pumpAndSettle();

      expect(find.text('Arsipkan Versi APK?'), findsOneWidget);
      await tester.tap(find.text('Arsipkan'));
      await tester.pumpAndSettle();

      verify(() => mockOperasi.arsipkanVersiApkUser('1')).called(1);
      expect(find.textContaining('berhasil diarsipkan'), findsOneWidget);
      expect(find.textContaining('Versi: 1.0.0'), findsNothing);
    });

    testWidgets('gagal arsip menampilkan snackbar error', (final tester) async {
      final d1 = createDummy('1', '1.0.0', 10);
      when(() => mockOperasi.ambilSemuaVersiApkAktif())
          .thenAnswer((final _) async => [d1]);
      when(() => mockOperasi.arsipkanVersiApkUser('1'))
          .thenThrow(Exception('DB locked'));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.longPress(find.textContaining('Versi: 1.0.0'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Arsipkan'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Arsipkan'));
      await tester.pumpAndSettle();

      verify(() => mockOperasi.arsipkanVersiApkUser('1')).called(1);
      expect(find.textContaining('Gagal mengarsipkan'), findsOneWidget);
    });

    testWidgets('pull to refresh memuat ulang data', (final tester) async {
      final d1 = createDummy('1', '1.0.0', 10);
      when(() => mockOperasi.ambilSemuaVersiApkAktif())
          .thenAnswer((final _) async => [d1]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      when(() => mockOperasi.ambilSemuaVersiApkAktif())
          .thenAnswer((final _) async => [d1, createDummy('2', '2.0.0', 20)]);

      final listFinder = find.byType(ListView);
      await tester.fling(listFinder, const Offset(0, 200), 1000);
      await tester.pumpAndSettle();

      verify(() => mockOperasi.ambilSemuaVersiApkAktif()).called(2);
      expect(find.textContaining('Build:'), findsNWidgets(2));
    });

    testWidgets('FAB navigasi ke form tambah', (final tester) async {
      when(() => mockOperasi.ambilSemuaVersiApkAktif())
          .thenAnswer((final _) async => []);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(navigatorObserver.pushedRoutes, isNotEmpty);
      final lastRoute =
          navigatorObserver.pushedRoutes.last as MaterialPageRoute;
      final builtWidget = lastRoute.builder(
        tester.element(find.byType(MaterialApp)),
      );
      expect(builtWidget, isA<FormVersiApkUser>());
    });

    testWidgets('back button pop halaman', (final tester) async {
      when(() => mockOperasi.ambilSemuaVersiApkAktif())
          .thenAnswer((final _) async => []);

      await tester.pumpWidget(
        MaterialApp(
          navigatorObservers: [navigatorObserver],
          home: Builder(
            builder: (final context) {
              return Scaffold(
                body: ElevatedButton(
                  child: const Text('Buka Versi'),
                  onPressed: () {
                    unawaited(
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (final _) =>
                              VersiApkUserPage(operasi: mockOperasi),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('Buka Versi'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('Buka Versi'), findsOneWidget);
    });
  });
}
