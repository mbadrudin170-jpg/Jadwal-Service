// path: test/admin/halaman/detail/detail_dompet_test.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/dompet/model/dompet_model.dart';
import 'package:wifi/fitur/dompet/operasi/dompet_op_sqlite.dart';
import 'package:wifi/fitur/dompet/page/detail_dompet.dart';
import 'package:wifi/fitur/transaksi/enum/tipe_transaksi.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_sqlite.dart';

import 'detail_dompet_test.mocks.dart';

@GenerateMocks([DompetOpSqlite, TransaksiOpSqlite, NavigatorObserver])
void main() {
  late MockDompetOpSqlite mockDompetOpSqlite;
  late MockTransaksiOpSqlite mockTransaksiOpSqlite;
  late MockNavigatorObserver mockNavigatorObserver;

  final dompetAwal = DompetModel(
    id: 'd1',
    nama: 'Dompet Utama',
    saldo: 1000.0,
    diperbaruiPada: DateTime.now(),
  );
  final daftarTransaksi = <TransaksiModel>[
    TransaksiModel(
      id: 't1',
      deskripsi: 'Gaji',
      jumlah: 5000.0,
      tipe: TipeTransaksi.income,
      tanggal: DateTime(2023, 1, 5),
      idDompet: 'd1',
      idKategori: 'k1',
      idPelanggan: 'pelanggan1',
      idPaket: 'paket1',
      tanggalMulai: DateTime(2023, 1, 3),
      tanggalBerakhir: DateTime(2023, 1, 31),
    ),
    TransaksiModel(
      id: 't2',
      deskripsi: 'Beli Kopi',
      jumlah: 15.0,
      tipe: TipeTransaksi.expense,
      tanggal: DateTime(2023, 1, 6),
      idDompet: 'd1',
      idKategori: 'k2',
      idPelanggan: null,
      idPaket: null,
      tanggalMulai: null,
      tanggalBerakhir: null,
    ),
  ];

  setUp(() {
    mockDompetOpSqlite = MockDompetOpSqlite();
    mockTransaksiOpSqlite = MockTransaksiOpSqlite();
    mockNavigatorObserver = MockNavigatorObserver();

    when(
      mockDompetOpSqlite.ambilBerdasarkanId(any),
    ).thenAnswer((_) async => dompetAwal);
    when(
      mockTransaksiOpSqlite.ambilBerdasarkanIdDompet(any),
    ).thenAnswer((_) async => daftarTransaksi);
    when(mockTransaksiOpSqlite.softDelete(any)).thenAnswer((_) async => 1);
  });

  Widget createWidget() {
    return ProviderScope(
      overrides: [
        dompetOpSqliteProvider.overrideWithValue(mockDompetOpSqlite),
        transaksiOpSqliteProvider.overrideWithValue(mockTransaksiOpSqlite),
      ],
      child: MaterialApp(
        home: DetailDompet(dompet: dompetAwal),
        navigatorObservers: [mockNavigatorObserver],
      ),
    );
  }

  group('01. DetailDompet Widget Tests', () {
    testWidgets(
      '01. harus menampilkan CircularProgressIndicator saat loading',
      (tester) async {
        final completer = Completer<DompetModel>();
        when(
          mockDompetOpSqlite.ambilBerdasarkanId(any),
        ).thenAnswer((_) => completer.future);

        await tester.pumpWidget(createWidget());
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        completer.complete(dompetAwal);
        await tester.pumpAndSettle();
      },
    );

    testWidgets('02. harus menampilkan pesan error jika data gagal dimuat', (
      tester,
    ) async {
      when(
        mockDompetOpSqlite.ambilBerdasarkanId(any),
      ).thenThrow(Exception('Gagal memuat'));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Error: Exception: Gagal memuat'),
        findsOneWidget,
      );
    });

    testWidgets(
      '03. harus menampilkan "Belum ada transaksi." jika future selesai tanpa data',
      (tester) async {
        when(
          mockDompetOpSqlite.ambilBerdasarkanId(any),
        ).thenAnswer((_) async => dompetAwal);
        when(
          mockTransaksiOpSqlite.ambilBerdasarkanIdDompet(any),
        ).thenAnswer((_) async => []);

        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        expect(find.text('Belum ada transaksi.'), findsOneWidget);
      },
    );

    testWidgets(
      '04. harus menampilkan detail dan daftar transaksi setelah data berhasil dimuat',
      (tester) async {
        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        expect(find.text('Dompet Utama'), findsOneWidget);
        expect(find.text('Pemasukan'), findsOneWidget);
        expect(find.textContaining('5,000'), findsOneWidget);
        expect(find.text('Pengeluaran'), findsOneWidget);
        expect(find.textContaining('15'), findsOneWidget);
        expect(find.text('Saldo'), findsOneWidget);
        expect(find.textContaining('1,000'), findsOneWidget);
        expect(find.text('Gaji'), findsOneWidget);
        expect(find.text('Beli Kopi'), findsOneWidget);
      },
    );

    testWidgets(
      '05. harus menampilkan "Belum ada transaksi." jika daftar transaksi kosong',
      (tester) async {
        when(
          mockTransaksiOpSqlite.ambilBerdasarkanIdDompet(any),
        ).thenAnswer((_) async => []);

        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        expect(find.text('Belum ada transaksi.'), findsOneWidget);
      },
    );
  });

  group('02. Interaksi dan Navigasi', () {
    testWidgets('01. harus memanggil Navigator.pop saat tombol back ditekan', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      verify(mockNavigatorObserver.didPop(any, any));
    });

    testWidgets(
      '02. harus navigasi ke DetailTransaksi dan refresh data jika result true',
      (tester) async {
        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        when(
          mockNavigatorObserver.didPush(any, any),
        ).thenAnswer((_) => Future.value(true));

        await tester.tap(find.text('Gaji'));
        await tester.pumpAndSettle();

        verify(mockNavigatorObserver.didPush(any, any)).called(1);
        verify(mockDompetOpSqlite.ambilBerdasarkanId('d1')).called(2);
      },
    );

    testWidgets(
      '03. harus hapus transaksi dan refresh data saat on_delete ditekan',
      (tester) async {
        when(mockTransaksiOpSqlite.softDelete('t1')).thenAnswer((_) async => 1);

        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        final gajiItem = find.widgetWithText(ListTile, 'Gaji');
        final deleteIcon = find.descendant(
          of: gajiItem,
          matching: find.byIcon(Icons.delete),
        );

        expect(deleteIcon, findsOneWidget);

        await tester.tap(deleteIcon);
        await tester.pumpAndSettle();

        verify(mockTransaksiOpSqlite.softDelete('t1')).called(1);
        verify(mockDompetOpSqlite.ambilBerdasarkanId('d1')).called(2);
        verify(mockTransaksiOpSqlite.ambilBerdasarkanIdDompet('d1')).called(2);
      },
    );

    testWidgets('04. harus navigasi ke FormTransaksi saat onEdit ditekan', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      final gajiItem = find.widgetWithText(ListTile, 'Gaji');
      final editIcon = find.descendant(
        of: gajiItem,
        matching: find.byIcon(Icons.edit),
      );

      expect(editIcon, findsOneWidget);

      await tester.tap(editIcon);
      await tester.pump();

      final pushedRoute =
          verify(mockNavigatorObserver.didPush(captureAny, any)).captured.last
              as Route<dynamic>;
      expect(pushedRoute, isA<MaterialPageRoute>());
    });
  });
}
