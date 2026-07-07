// path: test/admin/halaman/detail/detail_dompet_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/fitur/dompet/model/dompet_model.dart';
import 'package:wifi/fitur/dompet/page/detail_dompet.dart';
import 'package:wifi/fitur/dompet/provider/dompet_provider.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_global.dart';
import 'package:wifi/fitur/transaksi/widget/daftar_transaksi_widget.dart';

// ============================================================
// MOCK CLASSES
// ============================================================
class MockTransaksiOpGlobal extends Mock implements TransaksiOpGlobal {}
class MockDompetProvider extends Mock implements DompetProvider {}
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockTransaksiOpGlobal mockTransaksiOpGlobal;
  late MockDompetProvider mockDompetProvider;
  late MockNavigatorObserver mockNavigatorObserver;

  setUp(() {m
    mockTransaksiOpGlobal = MockTransaksiOpGlobal();
    mockDompetProvider = MockDompetProvider();
    mockNavigatorObserver = MockNavigatorObserver();
  });

  // Helper untuk membuat test widget dengan ProviderScope
  Widget buildTestWidget({
    required DompetModel dompet,
    required List<TransaksiModel> transaksiList,
    bool hasError = false,
  }) {
    return ProviderScope(
      overrides: [
        detailDompetProvider(dompet.id).overrideWithValue(
          hasError
              ? AsyncValue.error(Exception('Gagal memuat'), StackTrace.current)
              : AsyncValue.data(
                  DetailDompetState(
                    daftarTransaksi: transaksiList,
                    dompet: dompet,
                    totalTransaksi: transaksiList.length,
                    totalPemasukan: 1000000,
                    totalPengeluaran: 500000,
                    totalSaldo: 500000,
                    namaDompet: dompet.nama,
                  ),
                ),
        ),
      ],
      child: MaterialApp(
        navigatorObservers: [mockNavigatorObserver],
        home: DetailDompet(dompet: dompet),
      ),
    );
  }

  group('DetailDompet Widget Tests', () {
    final dompetUtama = DompetModel(
      id: 'dompet-1',
      nama: 'Dompet Utama',
      saldo: 5000000,
    );

    final transaksiGaji = TransaksiModel(
      id: 'trans-1',
      tanggal: DateTime.now(),
      deskripsi: 'Gaji',
      jumlah: 5000000,
      tipe: TipeTransaksi.income,
      idDompet: 'dompet-1',
      idKategori: 'kategori-1',
      idPelanggan: null,
      idPaket: null,
      tanggalMulai: null,
      tanggalBerakhir: null,
      statusAktivasi: false,
    );

    testWidgets(
      '01. harus menampilkan CircularProgressIndicator saat loading',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              detailDompetProvider(
                dompetUtama.id,
              ).overrideWithValue(const AsyncValue.loading()),
            ],
            child: MaterialApp(home: DetailDompet(dompet: dompetUtama)),
          ),
        );

        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets('02. harus menampilkan pesan error jika data gagal dimuat', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            detailDompetProvider(dompetUtama.id).overrideWithValue(
              AsyncValue.error(Exception('Gagal memuat'), StackTrace.current),
            ),
          ],
          child: MaterialApp(home: DetailDompet(dompet: dompetUtama)),
        ),
      );

      await tester.pump();

      expect(find.textContaining('Gagal memuat'), findsOneWidget);
    });

    testWidgets(
      '03. harus menampilkan "Belum ada transaksi." jika future selesai tanpa data',
      (tester) async {
        await tester.pumpWidget(
          buildTestWidget(dompet: dompetUtama, transaksiList: []),
        );

        await tester.pump();

        expect(find.text('Belum ada transaksi.'), findsOneWidget);
      },
    );

    testWidgets(
      '04. harus menampilkan detail dan daftar transaksi setelah data berhasil dimuat',
      (tester) async {
        await tester.pumpWidget(
          buildTestWidget(dompet: dompetUtama, transaksiList: [transaksiGaji]),
        );

        await tester.pump();

        // Verifikasi nama dompet
        expect(find.text('Dompet Utama'), findsOneWidget);

        // Verifikasi ringkasan keuangan
        expect(find.text('Rp 1.000.000'), findsOneWidget);
        expect(find.text('Rp 500.000'), findsOneWidget);
        expect(find.text('Rp 500.000'), findsOneWidget);

        // Verifikasi transaksi
        expect(find.text('Gaji'), findsOneWidget);
      },
    );

    testWidgets(
      '05. harus menampilkan "Belum ada transaksi." jika daftar transaksi kosong',
      (tester) async {
        await tester.pumpWidget(
          buildTestWidget(dompet: dompetUtama, transaksiList: []),
        );

        await tester.pump();

        expect(find.text('Belum ada transaksi.'), findsOneWidget);
      },
    );
  });

  group('Interaksi dan Navigasi', () {
    final dompetUtama = DompetModel(
      id: 'dompet-1',
      nama: 'Dompet Utama',
      saldo: 5000000,
    );

    final transaksiGaji = TransaksiModel(
      id: 'trans-1',
      tanggal: DateTime.now(),
      deskripsi: 'Gaji',
      jumlah: 5000000,
      tipe: TipeTransaksi.income,
      idDompet: 'dompet-1',
      idKategori: 'kategori-1',
      idPelanggan: null,
      idPaket: null,
      tanggalMulai: null,
      tanggalBerakhir: null,
      statusAktivasi: false,
    );

    testWidgets('01. harus memanggil Navigator.pop saat tombol back ditekan', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            detailDompetProvider(dompetUtama.id).overrideWithValue(
              AsyncValue.data(
                DetailDompetState(
                  daftarTransaksi: [transaksiGaji],
                  dompet: dompetUtama,
                  totalTransaksi: 1,
                  totalPemasukan: 1000000,
                  totalPengeluaran: 0,
                  totalSaldo: 1000000,
                  namaDompet: dompetUtama.nama,
                ),
              ),
            ),
          ],
          child: MaterialApp(
            navigatorObservers: [mockNavigatorObserver],
            home: DetailDompet(dompet: dompetUtama),
          ),
        ),
      );

      await tester.pump();

      // Cari tombol back
      final backButton = find.byIcon(Icons.arrow_back);
      expect(backButton, findsOneWidget);

      // Tap tombol back
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Verifikasi navigator dipanggil
      verify(() => mockNavigatorObserver.didPop(any(), any())).called(1);
    });

    testWidgets('02. harus navigasi ke DetailTransaksi saat item ditekan', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(dompet: dompetUtama, transaksiList: [transaksiGaji]),
      );

      await tester.pump();

      // Cari dan tap item transaksi
      final transaksiTile = find.text('Gaji');
      expect(transaksiTile, findsOneWidget);

      await tester.tap(transaksiTile);
      await tester.pumpAndSettle();

      // Verifikasi navigasi terjadi
      verify(() => mockNavigatorObserver.didPush(any(), any(), any())).called(1);
    });

    testWidgets(
      '03. harus hapus transaksi dan refresh data saat onDelete ditekan',
      (tester) async {
        // Mock delete operation
        when(
          () => mockTransaksiOpGlobal.softDelete(any()),
        ).thenAnswer((_) async => Future.value());

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              detailDompetProvider(dompetUtama.id).overrideWithValue(
                AsyncValue.data(
                  DetailDompetState(
                    daftarTransaksi: [transaksiGaji],
                    dompet: dompetUtama,
                    totalTransaksi: 1,
                    totalPemasukan: 1000000,
                    totalPengeluaran: 0,
                    totalSaldo: 1000000,
                    namaDompet: dompetUtama.nama,
                  ),
                ),
              ),
              transaksiOpGlobalProvider.overrideWithValue(
                mockTransaksiOpGlobal,
              ),
            ],
            child: MaterialApp(home: DetailDompet(dompet: dompetUtama)),
          ),
        );

        await tester.pump();

        // Long press pada item transaksi
        final transaksiTile = find.text('Gaji');
        expect(transaksiTile, findsOneWidget);

        await tester.longPress(transaksiTile);
        await tester.pump();

        // Tap tombol hapus di dialog
        final deleteButton = find.text('Hapus');
        expect(deleteButton, findsOneWidget);
        await tester.tap(deleteButton);
        await tester.pumpAndSettle();

        // Verifikasi delete dipanggil
        verify(() => mockTransaksiOpGlobal.softDelete(transaksiGaji.id)).called(1);
      },
    );

    testWidgets('04. harus navigasi ke FormTransaksi saat onEdit ditekan', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(dompet: dompetUtama, transaksiList: [transaksiGaji]),
      );

      await tester.pump();

      // Long press pada item transaksi
      final transaksiTile = find.text('Gaji');
      expect(transaksiTile, findsOneWidget);

      await tester.longPress(transaksiTile);
      await tester.pump();

      // Tap tombol edit di dialog
      final editButton = find.text('Edit');
      expect(editButton, findsOneWidget);
      await tester.tap(editButton);
      await tester.pumpAndSettle();

      // Verifikasi navigasi terjadi
      verify(() => mockNavigatorObserver.didPush(any(), any(), any())).called(1);
    });
  });
}