// path: test/admin/halaman/detail/active_customer_detail_test.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/halaman/detail/detail_paket.dart';
import 'package:wifi/admin/halaman/detail/detail_pelanggan.dart';
import 'package:wifi/admin/halaman/detail/detail_pelanggan_aktif.dart';
import 'package:wifi/admin/halaman/form/form_pelanggan_aktif.dart';
import 'package:wifi/admin/providers/pelanggan_aktif_provider.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/fitur/whatsapp/info_paket.dart';
import 'package:wifi/shared/model/pelanggan_aktif_model.dart';
import 'package:wifi/shared/model/transaksi_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/pelanggan_op_sqlite.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/paket_op_sqlite.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/transaksi_op_sqlite.dart';
import 'package:wifi/shared/model/detail_pelanggan_aktif_model.dart';
import 'package:wifi/shared/enum/enum.dart';

// Mocks
class MockPelangganOpSqlite extends Mock implements PelangganOpSqlite {}

class MockPaketOpSqlite extends Mock implements PaketOpSqlite {}

class MockTransaksiOpsqlite extends Mock implements TransaksiOpSqlite {}

class MockPesanInfoPaket extends Mock implements PesanInfoPaket {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class FakeRoute extends Fake implements Route<dynamic> {}

void main() {
  // Data dummy
  final tCustomer = PelangganModel(
    id: 'cust1',
    name: 'John Doe',
    phone: '081234567890',
    password: 'password',
    address: '123 Main St',
    registrationDate: DateTime.now(),
    fcmToken: '',
    appVersion: '',
    platform: '',
    lastActive: DateTime.now(),
  );

  final tPackage = PaketModel(
    id: 'pkg1',
    name: 'Paket Kencang',
    price: 100000,
    duration: 30,
    durationType: 'days',
    rewardPoints: 10,
    type: '',
    isAvailable: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final tTransaction = TransaksiModel(
    id: 'trans1',
    customerId: 'cust1',
    packageId: 'pkg1',
    date: DateTime.now(),
    amount: 100000.0,
    type: TransactionType.income,
    paymentStatus: PaymentStatus.paid,
    description: '',
    walletId: '',
    categoryId: '',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final tActiveCustomer = PelangganAktifModel(
    id: 'active1',
    customerId: 'cust1',
    packageId: 'pkg1',
    transactionId: 'trans1',
    startDate: DateTime.now().subtract(const Duration(days: 10)),
    endDate: DateTime.now().add(const Duration(days: 20)),
    status: ActiveStatus.active,
  );

  final tActiveCustomerDetailModel = DetailPelangganAktifModel(
    pelangganAktif: tActiveCustomer,
    customerName: tCustomer.name,
    packageName: tPackage.name,
  );

  final tActiveCustomerState =
      PelangganAktifState(daftarPelangganAktif: [tActiveCustomerDetailModel]);

  late MockPelangganOpSqlite mockCustomerOp;
  late MockPaketOpSqlite mockPackageOp;
  late MockTransaksiOpsqlite mockTransactionOp;
  late MockPesanInfoPaket mockPesanInfoPaket;
  late MockNavigatorObserver mockNavigatorObserver;

  setUpAll(() {
    registerFallbackValue(FakeRoute());
  });

  setUp(() {
    mockCustomerOp = MockPelangganOpSqlite();
    mockPackageOp = MockPaketOpSqlite();
    mockTransactionOp = MockTransaksiOpsqlite();
    mockPesanInfoPaket = MockPesanInfoPaket();
    mockNavigatorObserver = MockNavigatorObserver();
  });

  // Helper untuk membuat test widget
  Widget createTestWidget(List<Override> overrides) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        home: DetailPelangganAktif(pelangganAktif: tActiveCustomer),
        navigatorObservers: [mockNavigatorObserver],
      ),
    );
  }

  group('activeCustomerDetailProvider Tests', () {
    test('01. harus mengembalikan data lengkap saat sukses', () async {
      final container = ProviderContainer(
        overrides: [
          pelangganAktifProvider.overrideWith((ref) async => tActiveCustomerState),
          pelangganOpSqliteProvider.overrideWithValue(mockCustomerOp),
          paketOpSqliteProvider.overrideWithValue(mockPackageOp),
          transaksiOpSqliteProvider.overrideWithValue(mockTransactionOp),
        ],
      );

      when(() => mockCustomerOp.ambilBerdasarkanId(tActiveCustomer.customerId))
          .thenAnswer((_) async => tCustomer);
      when(() => mockPackageOp.ambilBerdasarkanId(tActiveCustomer.packageId))
          .thenAnswer((_) async => tPackage);
      when(() => mockTransactionOp
              .ambilBerdasarkanId(tActiveCustomer.transactionId!))
          .thenAnswer((_) async => tTransaction);

      final result = await container
          .read(detailPelangganAktifProvider(tActiveCustomer.id).future);

      expect(result.pelanggan, tCustomer);
      expect(result.paket, tPackage);
      expect(result.transaksi, tTransaction);
      expect(result.pelangganAktif, tActiveCustomer);
    });

    test('02. harus throw exception saat pelanggan aktif tidak ditemukan',
        () async {
      final container = ProviderContainer(
        overrides: [
          pelangganAktifProvider.overrideWith(
              (ref) async => PelangganAktifState(daftarPelangganAktif: [])),
        ],
      );

      await expectLater(
        container.read(detailPelangganAktifProvider(tActiveCustomer.id).future),
        throwsA(isA<Exception>().having((e) => e.toString(), 'toString',
            contains('Data pelanggan aktif tidak ditemukan'))),
      );
    });

    test('03. harus throw exception saat pelanggan tidak ditemukan', () async {
      final container = ProviderContainer(
        overrides: [
          pelangganAktifProvider.overrideWith((ref) async => tActiveCustomerState),
          pelangganOpSqliteProvider.overrideWithValue(mockCustomerOp),
        ],
      );

      when(() => mockCustomerOp.ambilBerdasarkanId(any())).thenAnswer((_) async => null);

      await expectLater(
        container.read(detailPelangganAktifProvider(tActiveCustomer.id).future),
        throwsA(isA<Exception>().having(
            (e) => e.toString(), 'toString', contains('Pelanggan tidak ditemukan'))),
      );
    });
  });
}
