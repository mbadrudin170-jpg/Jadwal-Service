
// path: test/admin/halaman/detail/detail_dompet_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/fitur/dompet/model/dompet_model.dart';
import 'package:wifi/fitur/dompet/operasi/dompet_op_sqlite.dart';
import 'package:wifi/fitur/dompet/page/detail_dompet.dart';
import 'package:wifi/fitur/transaksi/enum/tipe_transaksi.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_sqlite.dart';
import 'package:wifi/fitur/transaksi/page/detail_transaksi.dart';
import 'package:wifi/fitur/transaksi/page/form_transaksi.dart';
import 'package:wifi/fitur/dompet/provider/dompet_provider.dart';

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
      diperbaruiPada: DateTime.now());
  final List<TransaksiModel> daftarTransaksi = [
    TransaksiModel(
      id: 't1',
      deskripsi: 'Gaji',
      jumlah: 5000.0,
      tipe: TipeTransaksi.pemasukan,
      tanggal: DateTime(2023, 1, 5),
      idDompet: 'd1',
      idKategori: 'k1',
    ),
    TransaksiModel(
      id: 't2',
      deskripsi: 'Beli Kopi',
      jumlah: 15.0,
      tipe: TipeTransaksi.pengeluaran,
      tanggal: DateTime(2023, 1, 6),
      idDompet: 'd1',
      idKategori: 'k2',
    ),
  ];

  setUp(() {
    mockDompetOpSqlite = MockDompetOpSqlite();
    mockTransaksiOpSqlite = MockTransaksiOpSqlite();
    mockNavigatorObserver = MockNavigatorObserver();

    // Stub default successful data loading
    when(mockDompetOpSqlite.ambilBerdasarkanId(any))
        .thenAnswer((_) async => dompetAwal);
    when(mockTransaksiOpSqlite.getTransactionsByWalletId(any))
        .thenAnswer((_) async => daftarTransaksi);
    when(mockTransaksiOpSqlite.softDelete(any)).thenAnswer((_) async => 1);
  });

  Widget createWidget() {
    return ProviderScope(
      overrides: [
        dompetProvider.overrideWith((ref) => mockDompetOpSqlite),
        transaksiOpSqliteProvider.overrideWithValue(mockTransaksiOpSqlite),
      ],
      child: MaterialApp(
        home: DetailDompet(dompet: dompetAwal),
        navigatorObservers: [mockNavigatorObserver],
      ),
    );
  }

  group('01. DetailDompet Widget Tests', () {
    testWidgets('01. harus menampilkan CircularProgressIndicator saat loading',
        (tester) async {
      when(mockDompetOpSqlite.ambilBerdasarkanId(any))
          .thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return dompetAwal;
      });

      await tester.pumpWidget(createWidget());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('02. harus menampilkan pesan error jika data gagal dimuat',
        (tester) async {
      when(mockDompetOpSqlite.ambilBerdasarkanId(any))
          .thenThrow(Exception('Gagal memuat'));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('Error: Exception: Gagal memuat'),
          findsOneWidget);
    });

    testWidgets(
        '03. harus menampilkan "Data Kosong" jika future selesai tanpa data',
        (tester) async {
      // Skenario ini sulit terjadi karena _muatData akan throw error,
      // tapi kita tetap uji case FutureBuilder
      final completer = Completer<DataDetailDompet>();
      // Jangan complete completernya untuk membuat snapshot.hasData false

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dompetProvider.overrideWith((ref) => mockDompetOpSqlite),
            transaksiOpSqliteProvider.overrideWithValue(mockTransaksiOpSqlite),
          ],
          child: MaterialApp(
            home: FutureBuilder<DataDetailDompet>(
              future: completer.future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    !snapshot.hasData) {
                  return const Center(child: Text('Data Kosong'));
                }
                return const CircularProgressIndicator();
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Data Kosong'), findsOneWidget);
    });

    testWidgets(
        '04. harus menampilkan detail dan daftar transaksi setelah data berhasil dimuat',
        (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Cek AppBar title
      expect(find.text('Dompet Utama'), findsOneWidget);

      // Cek summary info (Pemasukan, Pengeluaran, Saldo)
      expect(find.text('Pemasukan'), findsOneWidget);
      expect(find.textContaining('5,000'), findsOneWidget);
      expect(find.text('Pengeluaran'), findsOneWidget);
      expect(find.textContaining('15'), findsOneWidget);
      expect(find.text('Saldo'), findsOneWidget);
      expect(find.textContaining('1,000'), findsOneWidget);

      // Cek item transaksi
      expect(find.text('Gaji'), findsOneWidget);
      expect(find.text('Beli Kopi'), findsOneWidget);
    });

    testWidgets(
        '05. harus menampilkan "Belum ada transaksi." jika daftar transaksi kosong',
        (tester) async {
      when(mockTransaksiOpSqlite.getTransactionsByWalletId(any))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Belum ada transaksi.'), findsOneWidget);
    });
  });

  group('02. Interaksi dan Navigasi', () {
    testWidgets('01. harus memanggil Navigator.pop saat tombol back ditekan',
        (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      verify(mockNavigatorObserver.didPop(any, any));
    });

    testWidgets(
        '02. harus navigasi ke DetailTransaksi dan refresh data jika result true',
        (tester) async {
      // Pertama, muat data awal
      when(mockDompetOpSqlite.ambilBerdasarkanId('d1'))
          .thenAnswer((_) async => dompetAwal);
      when(mockTransaksiOpSqlite.getTransactionsByWalletId('d1'))
          .thenAnswer((_) async => daftarTransaksi);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Siapkan data yang di-refresh (misal, ada perubahan nama)
      final dompetDiperbarui =
          dompetAwal.copyWith(nama: 'Dompet Utama Diperbarui');
      when(mockDompetOpSqlite.ambilBerdasarkanId('d1'))
          .thenAnswer((_) async => dompetDiperbarui);

      // Setup navigator untuk mengembalikan true
      when(mockNavigatorObserver.didPush(any, any)).thenAnswer((invocation) {
        final route = invocation.positionalArguments[0] as MaterialPageRoute;
        Future.microtask(() => route.didComplete(true));
      });

      // Tap item transaksi
      await tester.tap(find.text('Gaji'));
      await tester.pumpAndSettle(); // Tunggu navigasi dan refresh

      // Verifikasi navigasi terjadi
      verify(mockNavigatorObserver.didPush(any, any)).called(1);

      // Verifikasi data dimuat ulang (mock dipanggil dua kali)
      verify(mockDompetOpSqlite.ambilBerdasarkanId('d1')).called(2);

      // Verifikasi UI sudah update dengan nama baru
      expect(find.text('Dompet Utama Diperbarui'), findsOneWidget);
    });

    testWidgets(
        '03. harus hapus transaksi dan refresh data saat on_delete ditekan',
        (tester) async {
      when(mockDompetOpSqlite.ambilBerdasarkanId('d1'))
          .thenAnswer((_) async => dompetAwal);
      when(mockTransaksiOpSqlite.getTransactionsByWalletId('d1'))
          .thenAnswer((_) async => daftarTransaksi);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Siapkan data setelah dihapus
      when(mockTransaksiOpSqlite.getTransactionsByWalletId('d1'))
          .thenAnswer((_) async => [daftarTransaksi[1]]); // Hanya tersisa 1
      when(mockDompetOpSqlite.ambilBerdasarkanId('d1'))
          .thenAnswer((_) async => dompetAwal.copyWith(saldo: 1000 - 5000));

      // Cari ikon hapus yang terkait dengan item 'Gaji'
      // Ini agak tricky, kita cari berdasarkan item-nya lalu cari ikon delete
      final gajiItem = find.widgetWithText(ListTile, 'Gaji');
      final deleteIcon = find.descendant(
        of: gajiItem,
        matching: find.byIcon(Icons.delete),
      );

      expect(deleteIcon, findsOneWidget);

      // Tekan tombol hapus
      await tester.tap(deleteIcon);
      await tester.pumpAndSettle();

      // Verifikasi method softDelete dipanggil
      verify(mockTransaksiOpSqlite.softDelete('t1')).called(1);

      // Verifikasi data dimuat ulang
      verify(mockDompetOpSqlite.ambilBerdasarkanId('d1')).called(2);
      verify(mockTransaksiOpSqlite.getTransactionsByWalletId('d1'))
          .called(2);

      // Verifikasi UI sudah update (item 'Gaji' hilang)
      expect(find.text('Gaji'), findsNothing);
      expect(find.text('Beli Kopi'), findsOneWidget);
    });

    testWidgets('04. harus navigasi ke FormTransaksi saat onEdit ditekan',
        (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Cari ikon edit yang terkait dengan item 'Gaji'
      final gajiItem = find.widgetWithText(ListTile, 'Gaji');
      final editIcon = find.descendant(
        of: gajiItem,
        matching: find.byIcon(Icons.edit),
      );

      expect(editIcon, findsOneWidget);

      // Tekan tombol edit
      await tester.tap(editIcon);
      await tester.pump(); // Start navigation

      // Verifikasi navigasi ke FormTransaksi terjadi
      verify(mockNavigatorObserver.didPush(any, any));
      final pushedRoute =
          verify(mockNavigatorObserver.didPush(captureAny, previous: any))
              .captured
              .last as MaterialPageRoute;
      expect(pushedRoute.builder(MockBuildContext()), isA<FormTransaksi>());
    });
  });
}

class MockBuildContext extends Mock implements BuildContext {}
