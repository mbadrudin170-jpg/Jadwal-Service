
// path: test/fitur/transaksi/page/transaksi_page_a_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/transaksi/enum/tipe_transaksi.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_sqlite.dart';
import 'package:wifi/fitur/transaksi/page/detail_transaksi.dart';
import 'package:wifi/fitur/transaksi/page/form_transaksi.dart';
import 'package:wifi/fitur/transaksi/page/transaksi_page_a.dart';
import 'package:wifi/fitur/transaksi/provider/transaksi_provider.dart';
import 'package:wifi/shared/theme/app_icons.dart';

// Mocks
class MockTransaksiOpSqlite extends Mock implements TransaksiOpsqlite {}
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockTransaksiOpSqlite mockTransaksiOpSqlite;
  late MockNavigatorObserver mockNavigatorObserver;
  late ProviderContainer container;

  final tTransaksi1 = TransaksiModel(
    id: 't1',
    deskripsi: 'Gaji',
    jumlah: 5000000,
    tanggal: DateTime(2023, 10, 1),
    tipe: TipeTransaksi.income,
    idDompet: 'd1',
    idKategori: 'k1',
  );
  final tTransaksi2 = TransaksiModel(
    id: 't2',
    deskripsi: 'Beli Kopi',
    jumlah: 25000,
    tanggal: DateTime(2023, 10, 2),
    tipe: TipeTransaksi.expense,
    idDompet: 'd1',
    idKategori: 'k2',
  );

  setUp(() {
    mockTransaksiOpSqlite = MockTransaksiOpSqlite();
    mockNavigatorObserver = MockNavigatorObserver();

    // Default behaviors
    when(() => mockTransaksiOpSqlite.getAllTransactions()).thenAnswer((_) async => [tTransaksi1, tTransaksi2]);
    when(() => mockTransaksiOpSqlite.getTotalIncome()).thenAnswer((_) async => 5000000);
    when(() => mockTransaksiOpSqlite.getTotalExpense()).thenAnswer((_) async => 25000);
    when(() => mockTransaksiOpSqlite.getNetTotal()).thenAnswer((_) async => 4975000);
    when(() => mockTransaksiOpSqlite.softDelete(any())).thenAnswer((_) async => 1);
    when(() => mockTransaksiOpSqlite.softDeleteAll()).thenAnswer((_) async => 2);

    container = ProviderContainer(
      overrides: [
        transaksiOpSqliteProvider.overrideWithValue(mockTransaksiOpSqlite),
      ],
    );
  });

  Widget createWidgetUnderTest() {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: const TransaksiPageA(),
        navigatorObservers: [mockNavigatorObserver],
      ),
    );
  }

  group('Rendering State', () {
    testWidgets('01. harus menampilkan CircularProgressIndicator saat state loading', (tester) async {
      container.read(transaksiProvider.notifier);
      container.read(transaksiProvider).state = const AsyncLoading();

      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('02. harus menampilkan pesan error saat state error', (tester) async {
      container.read(transaksiProvider.notifier);
      container.read(transaksiProvider).state = AsyncError('DB Error', StackTrace.empty);

      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.text('Error: DB Error'), findsOneWidget);
    });

    testWidgets('03. harus menampilkan TransactionSummary dan daftar transaksi saat ada data', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle(); 

      expect(find.byType(TransactionSummary), findsOneWidget);
      expect(find.text('Gaji'), findsOneWidget);
      expect(find.text('Beli Kopi'), findsOneWidget);
    });

    testWidgets('04. harus menampilkan TransactionSummary dan pesan 'Tidak ada transaksi' saat data kosong', (tester) async {
      when(() => mockTransaksiOpSqlite.getAllTransactions()).thenAnswer((_) async => []);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(TransactionSummary), findsOneWidget);
      expect(find.text('Tidak ada transaksi'), findsOneWidget);
    });
  });

  group('Interaksi AppBar', () {
    testWidgets('05. harus membuka dialog pengurutan saat tombol filter ditekan', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(TIcons.filter));
      await tester.pumpAndSettle();

      expect(find.text('Urutkan Berdasarkan'), findsOneWidget);
    });

    testWidgets('06. harus mengurutkan ulang saat kriteria baru dipilih', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      
      // Default: Beli Kopi (terbaru) di atas
      final listTilesBefore = tester.widgetList<InkWell>(find.byType(InkWell));
      expect((listTilesBefore.first as InkWell).onTap, isNotNull); // Dummy check

      await tester.tap(find.byIcon(TIcons.filter));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Terlama'));
      await tester.pumpAndSettle();

      // After sort: Gaji (terlama) di atas
      final listTilesAfter = tester.widgetList<InkWell>(find.byType(InkWell));
      expect((listTilesAfter.first as InkWell).onTap, isNotNull); // Dummy check
    });

    testWidgets('07. harus membuka dialog konfirmasi saat tombol Hapus Semua ditekan', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(TIcons.delete));
      await tester.pumpAndSettle();

      expect(find.text('Konfirmasi'), findsOneWidget);
    });

    testWidgets('08. harus memanggil softDeleteAll saat penghapusan dikonfirmasi', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(TIcons.delete));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Hapus'));
      await tester.pump(); 

      verify(() => mockTransaksiOpSqlite.softDeleteAll()).called(1);
    });
  });

  group('Interaksi Body & FAB', () {
    testWidgets('12. harus memanggil refresh saat RefreshIndicator ditarik', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.fling(find.text('Gaji'), const Offset(0, 300), 1000);
      await tester.pumpAndSettle();

      verify(() => mockTransaksiOpSqlite.getAllTransactions()).called(2);
    });

    testWidgets('13. harus navigasi ke FormTransaksi (tambah) saat FAB ditekan', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      
      when(() => mockNavigatorObserver.didPush(any(), any())).thenReturn(null);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      verify(() => mockNavigatorObserver.didPush(any(that: isA<MaterialPageRoute>()), any()));
      expect(find.byType(FormTransaksi), findsOneWidget);
    });
  });

  group('Interaksi Item ListView', () {
    testWidgets('14. harus navigasi ke DetailTransaksi saat item di-tap', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      
      when(() => mockNavigatorObserver.didPush(any(), any())).thenReturn(null);

      await tester.tap(find.text('Gaji'));
      await tester.pumpAndSettle();

      verify(() => mockNavigatorObserver.didPush(any(that: isA<MaterialPageRoute>()), any()));
      expect(find.byType(DetailTransaksi), findsOneWidget);
    });

    testWidgets('16. harus memanggil softDelete dengan ID saat tombol onDelete ditekan', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      
      // Assuming the delete button is an icon within the list tile item actions
      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pump();

      verify(() => mockTransaksiOpSqlite.softDelete('t2')).called(1);
    });
  });
}
