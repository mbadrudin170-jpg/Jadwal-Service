// path: test/admin/halaman/form/subscription_history_form_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/halaman/form/form_riwayat_aktivasi.dart';
import 'package:wifi/fitur/notfikasi/notifikasi_servis.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/shared/providers/shared_providers.dart';
import 'package:wifi/shared/services/koneksi_internet_service.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/operasi/firebase_operasi/transaction_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';

class MockTransactionOpFirebase extends Mock implements TransactionOpFirebase {}

class MockNotifikasiServis extends Mock implements LayananNotifikasi {}

class MockKoneksiInternetService extends Mock
    implements KoneksiInternetService {}

void main() {
  late MockTransactionOpFirebase mockTransactionOperation;
  late MockNotifikasiServis mockNotifikasiServis;
  late MockKoneksiInternetService mockKoneksiInternetService;

  final transaction = TransaksiModel(
    id: '1',
    tanggal: DateTime.now(),
    deskripsi: 'Test Transaction',
    jumlah: 10000,
    tipe: TipeTransaksi.income,
    idDompet: 'wallet1',
    idKategori: 'category1',
    idPelanggan: 'customer1',
    idPaket: 'package1',
    statusPembayaran: PaymentStatus.paid,
  );

  setUp(() {
    mockTransactionOperation = MockTransactionOpFirebase();
    mockNotifikasiServis = MockNotifikasiServis();
    mockKoneksiInternetService = MockKoneksiInternetService();
  });

  ProviderContainer makeProviderContainer() {
    final container = ProviderContainer(
      overrides: [
        transactionOpFirebaseProvider
            .overrideWithValue(mockTransactionOperation),
        notifikasiServisProvider.overrideWithValue(mockNotifikasiServis),
        koneksiInternetServiceProvider
            .overrideWithValue(mockKoneksiInternetService),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Widget createTestWidget(ProviderContainer container,
      {required TransaksiModel transaction}) {
    return ProviderScope(
      parent: container,
      child: MaterialApp(
        home: FromRiwayatAktivasi(transaksi: transaction),
      ),
    );
  }

  testWidgets('01. Tes tampilan awal form riwayat langganan', (tester) async {
    final container = makeProviderContainer();
    await tester
        .pumpWidget(createTestWidget(container, transaction: transaction));

    await tester.pumpAndSettle();

    expect(find.text('Edit Riwayat Langganan'), findsOneWidget);
    expect(find.text('Simpan Perubahan'), findsOneWidget);
  });
}
