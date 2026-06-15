
// path: test/admin/halaman/detail/detail_paket_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/halaman/detail/detail_paket.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/paket/operasi/paket_op_sqlite.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_operation.dart';

// Mocks
class MockPaketOpSqlite extends Mock implements PaketOpSqlite {}

class MockBaseOpSqlite extends Mock implements BaseOpSqlite {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockPaketOpSqlite mockPaketOp;
  late MockBaseOpSqlite mockBaseOp;
  late MockNavigatorObserver mockNavigatorObserver;
  late ProviderContainer container;

  final tPaket = PaketModel(
    id: '1',
    nama: 'Paket Test',
    harga: 50000,
    durasi: 30,
    tipe: 'reguler',
  );

  setUp(() {
    mockPaketOp = MockPaketOpSqlite();
    mockBaseOp = MockBaseOpSqlite();
    mockNavigatorObserver = MockNavigatorObserver();

    container = ProviderContainer(
      overrides: [
        paketOpSqliteProvider.overrideWithValue(mockPaketOp),
        baseOpSqliteProvider.overrideWithValue(mockBaseOp),
      ],
    );

    when(() => mockPaketOp.softDelete(any())).thenAnswer((_) async {});
    when(() => mockPaketOp.updatePaket(any())).thenAnswer((_) async {});

    registerFallbackValue(tPaket);
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      parent: container,
      child: MaterialApp(
        home: DetailPaketPage(paket: tPaket),
        navigatorObservers: [mockNavigatorObserver],
      ),
    );
  }

  group('DetailPaketPage', () {
    testWidgets('01. harus menampilkan detail paket dengan benar', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Detail Paket'), findsOneWidget);
      expect(find.text('Paket Test'), findsOneWidget);
      expect(find.text('Rp 50.000'), findsOneWidget);
      expect(find.text('30 hari'), findsOneWidget);
    });

    testWidgets('02. harus memanggil delete dan pop saat tombol hapus ditekan',
        (tester) async {
      when(() => mockNavigatorObserver.didPop(any(), any())).thenReturn(null);
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      verify(() => mockPaketOp.softDelete('1')).called(1);
      verify(() => mockNavigatorObserver.didPop(any(), any())).called(2);
    });

    testWidgets('03. harus navigasi ke form edit saat tombol edit ditekan',
        (tester) async {
      when(() => mockNavigatorObserver.didPush(any(), any())).thenReturn(null);
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      verify(() => mockNavigatorObserver.didPush(any(), any())).called(1);
    });

    testWidgets('04. harus menampilkan snackbar error saat hapus gagal',
        (tester) async {
      when(() => mockPaketOp.softDelete(any())).thenThrow(Exception('Error'));
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      expect(find.text('Gagal menghapus paket'), findsOneWidget);
    });
  });
}
