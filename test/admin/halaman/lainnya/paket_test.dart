// path: test/admin/halaman/lainnya/paket_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/fitur/paket/page/paket.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/paket/operasi/paket_op_sqlite.dart';
import 'package:wifi/fitur/paket/provider/paket_provider.dart';
import 'package:wifi/fitur/paket/enum/tipe_durasi_paket.dart';

import 'paket_test.mocks.dart';

@GenerateMocks([PaketOpSqlite, NavigatorObserver])
void main() {
  late MockPaketOpSqlite mockPaketOpSqlite;
  late MockNavigatorObserver mockNavigatorObserver;

  setUp(() {
    mockPaketOpSqlite = MockPaketOpSqlite();
    mockNavigatorObserver = MockNavigatorObserver();
  });

  final paketList = [
    PaketModel(
      id: '1',
      nama: 'Paket A',
      harga: 10000,
      durasi: 1,
      tipe: TipeDurasiPaket.days,
      poinHadiah: 10,
    ),
    PaketModel(
      id: '2',
      nama: 'Paket B',
      harga: 20000,
      durasi: 7,
      tipe: TipeDurasiPaket.days,
      poinHadiah: 20,
    ),
  ];

  Widget createWidget() {
    return ProviderScope(
      overrides: [
        paketOpSqliteProvider.overrideWithValue(mockPaketOpSqlite),
        daftarPaketProvider.overrideWith((ref) async => paketList),
      ],
      child: MaterialApp(
        home: const PackagePage(),
        navigatorObservers: [mockNavigatorObserver],
      ),
    );
  }

  group('PackagePage Tests', () {
    testWidgets('01. should display list of packages', (tester) async {
      when(mockPaketOpSqlite.ambilPaket()).thenAnswer((_) async => paketList);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Paket A'), findsOneWidget);
      expect(find.text('Paket B'), findsOneWidget);
    });

    testWidgets('02. should open add package form', (tester) async {
      when(mockPaketOpSqlite.ambilPaket()).thenAnswer((_) async => paketList);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      verify(mockNavigatorObserver.didPush(any, any));
    });

    testWidgets('03. should show sort dialog', (tester) async {
      when(mockPaketOpSqlite.ambilPaket()).thenAnswer((_) async => paketList);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.sort));
      await tester.pumpAndSettle();

      expect(find.text('Urutkan Berdasarkan'), findsOneWidget);
    });

    testWidgets('04. should show delete all confirmation dialog', (
      tester,
    ) async {
      when(mockPaketOpSqlite.ambilPaket()).thenAnswer((_) async => paketList);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      expect(find.text('Konfirmasi Hapus Semua'), findsOneWidget);
    });

    testWidgets('05. should delete all packages', (tester) async {
      when(mockPaketOpSqlite.ambilPaket()).thenAnswer((_) async => paketList);
      when(mockPaketOpSqlite.hapusSementaraSemua()).thenAnswer((_) async => 1);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Hapus Semua'));
      await tester.pumpAndSettle();

      verify(mockPaketOpSqlite.hapusSementaraSemua());
    });

    testWidgets('06. should show edit/delete dialog on long press', (
      tester,
    ) async {
      when(mockPaketOpSqlite.ambilPaket()).thenAnswer((_) async => paketList);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.longPress(find.text('Paket A'));
      await tester.pumpAndSettle();

      expect(find.text('Pilih aksi yang ingin Anda lakukan.'), findsOneWidget);
    });
  });
}
