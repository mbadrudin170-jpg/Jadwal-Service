// path: test/admin/halaman/lainnya/paket_test.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/paket/enum/tipe_durasi_paket.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/paket/operasi/paket_op_sqlite.dart';
import 'package:wifi/fitur/paket/page/paket.dart';
import 'package:wifi/fitur/paket/provider/paket_provider.dart';

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
    const PaketModel(
      id: '1',
      nama: 'Paket A',
      harga: 10000,
      durasi: 1,
      tipe: TipeDurasiPaket.days,
      poinHadiah: 10,
    ),
    const PaketModel(
      id: '2',
      nama: 'Paket B',
      harga: 20000,
      durasi: 7,
      tipe: TipeDurasiPaket.days,
      poinHadiah: 20,
    ),
  ];

  final paketState = PaketState(daftarPaket: paketList);

  Widget createWidget() {
    return ProviderScope(
      overrides: [
        paketOpSqliteProvider.overrideWithValue(mockPaketOpSqlite),
        // Gunakan cara yang benar untuk override AsyncNotifierProvider
        paketProvider.overrideWith(() => _MockPaketNotifier(paketState)),
      ],
      child: MaterialApp(
        home: const PackagePage(),
        navigatorObservers: [mockNavigatorObserver],
      ),
    );
  }

  group('PackagePage Tests', () {
    testWidgets('01. harus menampilkan daftar paket', (tester) async {
      when(
        mockPaketOpSqlite.ambilSemua(
          tampilkanYangDiarsip: anyNamed('tampilkanYangDiarsip'),
        ),
      ).thenAnswer((_) async => paketList);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Paket A'), findsOneWidget);
      expect(find.text('Paket B'), findsOneWidget);
    });

    testWidgets('02. harus membuka form tambah paket', (tester) async {
      when(
        mockPaketOpSqlite.ambilSemua(
          tampilkanYangDiarsip: anyNamed('tampilkanYangDiarsip'),
        ),
      ).thenAnswer((_) async => paketList);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      verify(mockNavigatorObserver.didPush(any, any));
    });

    testWidgets('03. harus menampilkan dialog urutkan', (tester) async {
      when(
        mockPaketOpSqlite.ambilSemua(
          tampilkanYangDiarsip: anyNamed('tampilkanYangDiarsip'),
        ),
      ).thenAnswer((_) async => paketList);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.sort));
      await tester.pumpAndSettle();

      expect(find.text('Urutkan Berdasarkan'), findsOneWidget);
    });

    testWidgets('04. harus menampilkan dialog konfirmasi hapus semua', (
      tester,
    ) async {
      when(
        mockPaketOpSqlite.ambilSemua(
          tampilkanYangDiarsip: anyNamed('tampilkanYangDiarsip'),
        ),
      ).thenAnswer((_) async => paketList);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      expect(find.text('Konfirmasi Hapus Semua'), findsOneWidget);
    });

    testWidgets('05. harus menghapus semua paket', (tester) async {
      when(
        mockPaketOpSqlite.ambilSemua(
          tampilkanYangDiarsip: anyNamed('tampilkanYangDiarsip'),
        ),
      ).thenAnswer((_) async => paketList);
      when(mockPaketOpSqlite.hapusSementaraSemua()).thenAnswer((_) async => 1);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Hapus Semua'));
      await tester.pumpAndSettle();

      verify(mockPaketOpSqlite.hapusSementaraSemua());
    });

    testWidgets('06. harus menampilkan dialog edit/hapus saat long press', (
      tester,
    ) async {
      when(
        mockPaketOpSqlite.ambilSemua(
          tampilkanYangDiarsip: anyNamed('tampilkanYangDiarsip'),
        ),
      ).thenAnswer((_) async => paketList);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.longPress(find.text('Paket A'));
      await tester.pumpAndSettle();

      expect(find.text('Pilih aksi yang ingin Anda lakukan.'), findsOneWidget);
    });
  });
}

/// Mock Notifier untuk testing PaketProvider
class _MockPaketNotifier extends Paket {
  final PaketState _state;

  _MockPaketNotifier(this._state);

  @override
  FutureOr<PaketState> build() {
    return _state;
  }
}
