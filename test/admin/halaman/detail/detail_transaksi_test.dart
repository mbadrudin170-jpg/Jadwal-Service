// path: test/admin/halaman/detail/detail_transaksi_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/fitur/transaksi/page/detail_transaksi.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/dompet/model/dompet_model.dart';
import 'package:wifi/fitur/kategori/model/kategori_model.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/shared/enum/enum.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/dompet_op_sqlite.dart';
import 'package:wifi/fitur/kategori/operasi/kategori_op_sqlite.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/paket_op_sqlite.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_sqlite.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_sqlite.dart';

// Mocks
class MockPelangganOpSqlite extends Mock implements PelangganOpSqlite {}

class MockPaketOpSqlite extends Mock implements PaketOpSqlite {}

class MockTransaksiOpsqlite extends Mock implements TransactionOperation {}

class MockDompetOpSqlite extends Mock implements DompetOpSqlite {}

class MockKategoriOpSqlite extends Mock implements KategoriOpSqlite {}

void main() {
  late MockPelangganOpSqlite mockCustomerOperation;
  late MockPaketOpSqlite mockPackageOperation;
  late MockTransaksiOpsqlite mockTransactionOperation;
  late MockDompetOpSqlite mockWalletOperation;
  late MockKategoriOpSqlite mockCategoryOperation;

  final tTransaction = TransaksiModel(
    id: '1',
    tanggal: DateTime.now(),
    deskripsi: 'Test Transaction',
    jumlah: 100.0,
    tipe: TransactionType.pemasukan,
    idDompet: 'wallet1',
    idKategori: 'cat1',
    statusPembayaran: PaymentStatus.lunas,
    idPelanggan: 'cust1',
    idPaket: 'pkg1',
  );

  setUp(() {
    mockCustomerOperation = MockPelangganOpSqlite();
    mockPackageOperation = MockPaketOpSqlite();
    mockTransactionOperation = MockTransaksiOpsqlite();
    mockWalletOperation = MockDompetOpSqlite();
    mockCategoryOperation = MockKategoriOpSqlite();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        pelangganOpSqliteProvider.overrideWithValue(mockCustomerOperation),
        paketOpSqliteProvider.overrideWithValue(mockPackageOperation),
        transaksiOpSqliteProvider.overrideWithValue(mockTransactionOperation),
        dompetOpSqliteProvider.overrideWithValue(mockWalletOperation),
        kategoriOpSqliteProvider.overrideWithValue(mockCategoryOperation),
      ],
      child: MaterialApp(
        home: DetailTransaksi(transaksi: tTransaction),
      ),
    );
  }

  group('Halaman DetailTransaksi', () {
    testWidgets('01. harus menampilkan detail transaksi', (tester) async {
      when(() => mockWalletOperation.ambilBerdasarkanId(any())).thenAnswer(
          (_) async => DompetModel(id: 'wallet1', nama: 'Test Wallet', saldo: 0));
      when(() => mockCategoryOperation.ambilBerdasarkanId(any())).thenAnswer(
          (_) async => KategoriModel(
              id: 'cat1', nama: 'Test Category', tipe: TipeKategori.pemasukan));
      when(() => mockCustomerOperation.ambilBerdasarkanId(any())).thenAnswer(
          (_) async => PelangganModel(
                id: 'cust1',
                nama: 'Test Customer',
                telepon: '',
                kataSandi: '',
                alamat: '',
              ));
      when(() => mockPackageOperation.ambilBerdasarkanId(any())).thenAnswer(
          (_) async => PaketModel(
                id: 'pkg1',
                nama: 'Test Package',
                harga: 100,
                durasi: 30,
                tipeDurasi: 'hari',
                poinReward: 10,
                tipe: 'publik',
                isTersedia: true,
              ));

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.pumpAndSettle();

      expect(find.text('Test Transaction'), findsOneWidget);
      expect(find.text('Test Wallet'), findsOneWidget);
      expect(find.text('Test Category'), findsOneWidget);
      expect(find.text('Test Customer'), findsOneWidget);
      expect(find.text('Test Package'), findsOneWidget);
    });
  });
}
