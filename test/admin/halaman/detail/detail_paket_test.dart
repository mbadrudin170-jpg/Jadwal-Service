// path: test/admin/halaman/detail/detail_dompet_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/fitur/dompet/model/dompet_model.dart';
import 'package:wifi/fitur/dompet/page/detail_dompet.dart';
import 'package:wifi/fitur/dompet/provider/dompet_provider.dart';
import 'package:wifi/fitur/transaksi/enum/tipe_transaksi.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_global.dart';

// ============================================================
// MOCK CLASSES
// ============================================================
class MockTransaksiOpGlobal extends Mock implements TransaksiOpGlobal {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

// Fake class untuk Route agar bisa digunakan sebagai fallback
class FakeRoute extends Fake implements Route<dynamic> {}

void main() {
  late MockTransaksiOpGlobal mockTransaksiOpGlobal;
  late MockNavigatorObserver mockNavigatorObserver;

  // Register fallback untuk Route agar any() bisa digunakan
  setUpAll(() {
    registerFallbackValue(FakeRoute());
  });

  setUp(() {
    mockTransaksiOpGlobal = MockTransaksiOpGlobal();
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
    final dompetUtama = const DompetModel(
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
      '03. harus menampilkan widget kosong saat daftar transaksi kosong',
      (tester) async {
        await tester.pumpWidget(
          buildTestWidget(dompet: dompetUtama, transaksiList: []),
        );

        await tester.pump();

        expect(find.text('Dompet Utama'), findsOneWidget);
      },
    );

    testWidgets(
      '04. harus menampilkan detail dan daftar transaksi setelah data berhasil dimuat',
      (tester) async {
        await tester.pumpWidget(
          buildTestWidget(dompet: dompetUtama, transaksiList: [transaksiGaji]),
        );

        await tester.pump();

        expect(find.text('Dompet Utama'), findsOneWidget);
        expect(find.text('Gaji'), findsOneWidget);
      },
    );

    testWidgets('05. harus menampilkan pesan saat daftar transaksi kosong', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(dompet: dompetUtama, transaksiList: []),
      );

      await tester.pump();

      expect(find.text('Dompet Utama'), findsOneWidget);
    });
  });

  group('Interaksi dan Navigasi', () {
    final dompetUtama = const DompetModel(
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
    );

    testWidgets('01. harus memanggil Navigator.pop saat tombol back ditekan', (
      tester,
    ) async {
      // Reset mock sebelum test
      reset(mockNavigatorObserver);

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

      // Cari tombol back - gunakan Icon
      final backButton = find.byIcon(Icons.arrow_back);
      expect(backButton, findsOneWidget);

      await tester.tap(backButton);
      await tester.pumpAndSettle();

      verify(() => mockNavigatorObserver.didPop(any(), any())).called(1);
    });

    testWidgets('02. harus navigasi ke DetailTransaksi saat item ditekan', (
      tester,
    ) async {
      // Reset mock sebelum test
      reset(mockNavigatorObserver);

      await tester.pumpWidget(
        buildTestWidget(dompet: dompetUtama, transaksiList: [transaksiGaji]),
      );

      await tester.pump();

      final transaksiTile = find.text('Gaji');
      expect(transaksiTile, findsOneWidget);

      await tester.tap(transaksiTile);
      await tester.pumpAndSettle();

      verify(() => mockNavigatorObserver.didPush(any(), any())).called(1);
    });

    testWidgets(
      '03. harus hapus transaksi dan refresh data saat onDelete ditekan',
      (tester) async {
        // Reset mock sebelum test
        reset(mockNavigatorObserver);
        reset(mockTransaksiOpGlobal);

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

        final transaksiTile = find.text('Gaji');
        expect(transaksiTile, findsOneWidget);

        await tester.longPress(transaksiTile);
        await tester.pump();

        final deleteButton = find.text('Hapus');
        expect(deleteButton, findsOneWidget);
        await tester.tap(deleteButton);
        await tester.pumpAndSettle();

        verify(() => mockTransaksiOpGlobal.softDelete(any<String>())).called(1);
      },
    );

    testWidgets('04. harus navigasi ke FormTransaksi saat onEdit ditekan', (
      tester,
    ) async {
      // Reset mock sebelum test
      reset(mockNavigatorObserver);

      await tester.pumpWidget(
        buildTestWidget(dompet: dompetUtama, transaksiList: [transaksiGaji]),
      );

      await tester.pump();

      final transaksiTile = find.text('Gaji');
      expect(transaksiTile, findsOneWidget);

      await tester.longPress(transaksiTile);
      await tester.pump();

      final editButton = find.text('Edit');
      expect(editButton, findsOneWidget);
      await tester.tap(editButton);
      await tester.pumpAndSettle();

      // Verifikasi navigasi terjadi
      verify(() => mockNavigatorObserver.didPush(any(), any())).called(1);
    });
  });
}
