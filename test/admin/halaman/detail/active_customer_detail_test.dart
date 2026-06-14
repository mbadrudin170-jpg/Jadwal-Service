// path: test/admin/halaman/detail/active_customer_detail_test.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/halaman/detail/detail_pelanggan_aktif.dart';
import 'package:wifi/admin/providers/detail_langganan_provider.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/shared/enum/enum.dart';
import 'package:wifi/shared/model/pelanggan_aktif_model.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/paket_op_sqlite.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/pelanggan_op_sqlite.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/transaction_operation.dart';

// Mocks
class MockPelangganOpSqlite extends Mock implements PelangganOpSqlite {}

class MockPaketOpSqlite extends Mock implements PaketOpSqlite {}

class MockTransaksiOpsqlite extends Mock implements TransactionOperation {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class FakeRoute extends Fake implements Route<dynamic> {}

void main() {
  // Data dummy
  final tCustomer = PelangganModel(
    id: 'cust1',
    nama: 'John Doe',
    telepon: '081234567890',
    kataSandi: 'password',
    alamat: '123 Main St',
  );

  final tPackage = PaketModel(
    id: 'pkg1',
    nama: 'Paket Kencang',
    harga: 100000,
    durasi: 30,
    tipeDurasi: 'hari',
    poinReward: 10,
    tipe: 'publik',
    isTersedia: true,
  );

  final tTransaction = TransaksiModel(
    id: 'trans1',
    idPelanggan: 'cust1',
    idPaket: 'pkg1',
    tanggal: DateTime.now(),
    jumlah: 100000.0,
    tipe: TransactionType.pemasukan,
    statusPembayaran: PaymentStatus.lunas,
    deskripsi: '',
    idDompet: '',
    idKategori: '',
  );

  final tActiveCustomer = PelangganAktifModel(
    id: 'active1',
    idPelanggan: 'cust1',
    idPaket: 'pkg1',
    idTransaksi: 'trans1',
    tanggalMulai: DateTime.now().subtract(const Duration(days: 10)),
    tanggalAkhir: DateTime.now().add(const Duration(days: 20)),
    status: ActiveStatus.aktif,
  );

  late MockPelangganOpSqlite mockCustomerOp;
  late MockPaketOpSqlite mockPackageOp;
  late MockTransaksiOpsqlite mockTransactionOp;
  late MockNavigatorObserver mockNavigatorObserver;

  setUpAll(() {
    registerFallbackValue(FakeRoute());
  });

  setUp(() {
    mockCustomerOp = MockPelangganOpSqlite();
    mockPackageOp = MockPaketOpSqlite();
    mockTransactionOp = MockTransaksiOpsqlite();
    mockNavigatorObserver = MockNavigatorObserver();
  });

  group('detailLanggananProvider Tests', () {
    test('01. harus mengembalikan data lengkap saat sukses', () async {
      when(() => mockCustomerOp.ambilBerdasarkanId(any()))
          .thenAnswer((_) async => tCustomer);
      when(() => mockPackageOp.ambilBerdasarkanId(any()))
          .thenAnswer((_) async => tPackage);
      when(() => mockTransactionOp.ambilBerdasarkanId(any()))
          .thenAnswer((_) async => tTransaction);

      final container = ProviderContainer(
        overrides: [
          pelangganOpSqliteProvider.overrideWithValue(mockCustomerOp),
          paketOpSqliteProvider.overrideWithValue(mockPackageOp),
          transaksiOpSqliteProvider.overrideWithValue(mockTransactionOp),
        ],
      );

      final result = await container
          .read(detailLanggananProvider(tActiveCustomer).future);

      expect(result.pelanggan, tCustomer);
      expect(result.paket, tPackage);
      expect(result.transaksi, tTransaction);
    });

    test('02. harus throw exception saat pelanggan tidak ditemukan', () async {
      when(() => mockCustomerOp.ambilBerdasarkanId(any()))
          .thenAnswer((_) async => null);
      when(() => mockPackageOp.ambilBerdasarkanId(any()))
          .thenAnswer((_) async => tPackage);
      when(() => mockTransactionOp.ambilBerdasarkanId(any()))
          .thenAnswer((_) async => tTransaction);

      final container = ProviderContainer(
        overrides: [
          pelangganOpSqliteProvider.overrideWithValue(mockCustomerOp),
          paketOpSqliteProvider.overrideWithValue(mockPackageOp),
          transaksiOpSqliteProvider.overrideWithValue(mockTransactionOp),
        ],
      );

      await expectLater(
        container.read(detailLanggananProvider(tActiveCustomer).future),
        throwsA(isA<Exception>().having((e) => e.toString(), 'toString',
            contains('Pelanggan dengan ID cust1 tidak ditemukan'))),
      );
    });
  });

  group('Widget DetailPelangganAktif', () {
    testWidgets('03. harus menampilkan CircularProgressIndicator saat loading',
        (tester) async {
      final provider = detailLanggananProvider(tActiveCustomer);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            provider.overrideWith(
              (ref) => const AsyncValue.loading(),
            ),
          ],
          child: MaterialApp(
            home: DetailPelangganAktif(pelangganAktif: tActiveCustomer),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('04. harus menampilkan pesan error saat terjadi kesalahan',
        (tester) async {
      final provider = detailLanggananProvider(tActiveCustomer);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            provider.overrideWith(
              (ref) => AsyncValue.error('Error', StackTrace.current),
            ),
          ],
          child: MaterialApp(
            home: DetailPelangganAktif(pelangganAktif: tActiveCustomer),
          ),
        ),
      );

      expect(find.text('Error'), findsOneWidget);
    });
  });
}
