
// path: test/admin/halaman/form/active_customer_form_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/halaman/form/active_customer_form.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/shared/services/koneksi_internet_service.dart';

class MockCustomerOperation extends Mock implements CustomerOperation {}
class MockPackageOperation extends Mock implements PackageOperation {}
class MockTransactionOperation extends Mock implements TransactionOperation {}
class MockWalletOperation extends Mock implements WalletOperation {}
class MockCategoryOperation extends Mock implements CategoryOperation {}
class MockActiveCustomerOperation extends Mock implements ActiveCustomerOperation {}
class MockKoneksiInternetService extends Mock implements KoneksiInternetService {}
class MockNotifikasiOpFirebase extends Mock implements NotifikasiOpFirebase {}

void main() {
  late MockCustomerOperation mockCustomerOperation;
  late MockPackageOperation mockPackageOperation;
  late MockTransactionOperation mockTransactionOperation;
  late MockWalletOperation mockWalletOperation;
  late MockCategoryOperation mockCategoryOperation;
  late MockActiveCustomerOperation mockActiveCustomerOperation;
  late MockKoneksiInternetService mockKoneksiInternetService;
  late MockNotifikasiOpFirebase mockNotifikasiOpFirebase;

  setUp(() {
    mockCustomerOperation = MockCustomerOperation();
    mockPackageOperation = MockPackageOperation();
    mockTransactionOperation = MockTransactionOperation();
    mockWalletOperation = MockWalletOperation();
    mockCategoryOperation = MockCategoryOperation();
    mockActiveCustomerOperation = MockActiveCustomerOperation();
    mockKoneksiInternetService = MockKoneksiInternetService();
    mockNotifikasiOpFirebase = MockNotifikasiOpFirebase();
  });

  ProviderContainer makeProviderContainer() {
    final container = ProviderContainer(
      overrides: [
        customerOperationProvider.overrideWithValue(mockCustomerOperation),
        packageOperationProvider.overrideWithValue(mockPackageOperation),
        transactionOperationProvider.overrideWithValue(mockTransactionOperation),
        walletOperationProvider.overrideWithValue(mockWalletOperation),
        categoryOperationProvider.overrideWithValue(mockCategoryOperation),
        activeCustomerOperationProvider.overrideWithValue(mockActiveCustomerOperation),
        koneksiInternetServiceProvider.overrideWithValue(mockKoneksiInternetService),
        notifikasiOpFirebaseProvider.overrideWithValue(mockNotifikasiOpFirebase),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Widget createTestWidget(ProviderContainer container, {ActiveCustomerModel? pelangganAktif}) {
    return ProviderScope(
      parent: container,
      child: MaterialApp(
        home: FormPelangganAktif(pelangganAktif: pelangganAktif),
      ),
    );
  }

  testWidgets('1. Tes tampilan awal form pelanggan aktif (mode buat baru)', (tester) async {
    when(() => mockCustomerOperation.getAll()).thenAnswer((_) async => []);
    when(() => mockPackageOperation.getByAktif()).thenAnswer((_) async => []);
    when(() => mockWalletOperation.getWallets()).thenAnswer((_) async => []);
    when(() => mockCategoryOperation.getCategories()).thenAnswer((_) async => []);

    final container = makeProviderContainer();
    await tester.pumpWidget(createTestWidget(container));
    
    await tester.pumpAndSettle(); 

    expect(find.text('Form Pelanggan Aktif'), findsOneWidget);
    expect(find.byKey(const Key('pelanggan_dropdown')), findsOneWidget);
    expect(find.byKey(const Key('paket_dropdown')), findsOneWidget);
    expect(find.byKey(const Key('dompet_dropdown')), findsOneWidget);
    expect(find.byKey(const Key('kategori_dropdown')), findsOneWidget);
    expect(find.text('Simpan'), findsOneWidget);
  });
}
