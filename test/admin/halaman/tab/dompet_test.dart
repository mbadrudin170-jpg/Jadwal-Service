// path: test/admin/halaman/tab/dompet_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/admin/halaman/detail/wallet_detail.dart';
import 'package:wifi/admin/halaman/form/form_dompet.dart';
import 'package:wifi/admin/halaman/tab/wallet_page.dart';
import 'package:wifi/shared/model/dompet_model.dart';
import 'package:wifi/shared/operasi/transaction_operation.dart';
import 'package:wifi/shared/operasi/wallet_operation.dart';

import 'dompet_test.mocks.dart';

@GenerateMocks([DompetOperasi, TransaksiOperasi])
void main() {
  late MockDompetOperasi mockDompetOperasi;
  late MockTransaksiOperasi mockTransaksiOperasi;

  setUp(() {
    mockDompetOperasi = MockDompetOperasi();
    mockTransaksiOperasi = MockTransaksiOperasi();

    when(mockDompetOperasi.getTotalSaldoPositif()).thenAnswer((final _) async => 0.0);
    when(mockDompetOperasi.getTotalSaldoNegatif()).thenAnswer((final _) async => 0.0);
    when(mockDompetOperasi.getTotalSaldo()).thenAnswer((final _) async => 0.0);
  });

  Widget createTestableWidget() {
    return MaterialApp(
      home: DompetPage(
        dompetOperasi: mockDompetOperasi,
        transaksiOperasi: mockTransaksiOperasi,
      ),
    );
  }

  final dummyDompetList = [
    DompetModel(id: '1', namaDompet: 'Dompet Utama', saldo: 1500000),
    DompetModel(id: '2', namaDompet: 'Dompet Cadangan', saldo: 500000),
  ];

  void mockGetDompet(final List<DompetModel> dompets) {
    when(mockDompetOperasi.getDompet()).thenAnswer((final _) async => dompets);
  }

  void mockGetDompetFailure(final Exception error) {
    when(mockDompetOperasi.getDompet()).thenAnswer((final _) => Future.error(error));
  }

  group('Render Awal', () {
    testWidgets('Harus menampilkan pesan kosong ketika tidak ada dompet',
        (final tester) async {
      mockGetDompet([]);
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();
      expect(find.text('Tidak ada dompet ditemukan.'), findsOneWidget);
      expect(find.byType(DompetCard), findsNothing);
    });

    testWidgets('Harus menampilkan daftar dompet ketika ada data',
        (final tester) async {
      mockGetDompet(dummyDompetList);
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();
      expect(find.byType(DompetCard), findsNWidgets(2));
      expect(find.text('Dompet Utama'), findsOneWidget);
    });

    testWidgets('Harus menampilkan pesan error ketika Future gagal',
        (final tester) async {
      final exception = Exception('Koneksi Gagal');
      mockGetDompetFailure(exception);
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();
      expect(find.text('Error: $exception'), findsOneWidget);
    });
  });

  group('Aksi Navigasi dan Memuat Ulang', () {
    testWidgets(
        'Harus menavigasi ke FormDompet saat FloatingActionButton ditekan',
        (final tester) async {
      mockGetDompet([]);
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.byType(FormDompet), findsOneWidget);
    });

    testWidgets('Harus memuat ulang data saat kembali dari FormDompet',
        (final tester) async {
      mockGetDompet([]);
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();
      expect(find.text('Dompet Baru'), findsNothing);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      mockGetDompet([DompetModel(id: '3', namaDompet: 'Dompet Baru', saldo: 0)]);

      final navigator = Navigator.of(tester.element(find.byType(FormDompet)));
      navigator.pop(true);
      await tester.pumpAndSettle();

      expect(find.text('Dompet Baru'), findsOneWidget);
    });

    testWidgets('Harus menavigasi ke DetailDompet saat Card di-tap',
        (final tester) async {
      mockGetDompet(dummyDompetList);
      when(mockDompetOperasi.getDompetById(any))
          .thenAnswer((final _) async => dummyDompetList.first);
      when(mockTransaksiOperasi.ambilTransaksiByDompetId(any))
          .thenAnswer((final _) async => []);

      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Dompet Utama'));
      await tester.pumpAndSettle();

      expect(find.byType(DetailDompet), findsOneWidget);
      expect(
          find.descendant(
              of: find.byType(AppBar),
              matching: find.text('Dompet Utama')),
          findsOneWidget);
    });
  });

  group('Aksi Hapus dan Arsip', () {
    testWidgets('Harus menampilkan SnackBar jika hapus semua tapi kosong',
        (final tester) async {
      mockGetDompet([]);
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_sweep));
      await tester.pumpAndSettle();

      expect(find.text('Tidak ada dompet untuk dihapus.'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('Harus menghapus semua dompet setelah konfirmasi',
        (final tester) async {
      mockGetDompet(dummyDompetList);
      when(mockDompetOperasi.hapusSemuaDompet()).thenAnswer((final _) async => true);

      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();
      expect(find.byType(DompetCard), findsNWidgets(2));

      await tester.tap(find.byIcon(Icons.delete_sweep));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);

      mockGetDompet([]);

      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      expect(find.text('Semua dompet berhasil dihapus.'), findsOneWidget);
      expect(find.text('Tidak ada dompet ditemukan.'), findsOneWidget);
      expect(find.byType(DompetCard), findsNothing);
    });

    testWidgets('Harus mengarsipkan satu dompet setelah konfirmasi',
        (final tester) async {
      mockGetDompet(dummyDompetList);
      final dompetUntukDiarsip = dummyDompetList.first;
      when(mockDompetOperasi.arsipkanSatuDompet(dompetUntukDiarsip.id))
          .thenAnswer((final _) async => true);

      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      await tester.longPress(find.text('Dompet Utama'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);

      mockGetDompet([dummyDompetList.last]);

      await tester.tap(find.text('Arsipkan'));
      await tester.pumpAndSettle();

      expect(find.text('Dompet berhasil diarsipkan.'), findsOneWidget);
      expect(find.text('Dompet Utama'), findsNothing);
      expect(find.text('Dompet Cadangan'), findsOneWidget);
    });
  });
}
