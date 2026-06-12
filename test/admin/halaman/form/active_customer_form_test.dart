// path: test/admin/halaman/form/active_customer_form_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/halaman/form/form_pelanggan_aktif.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/shared/model/active_customer_model.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/shared/model/wallet_model.dart';
import 'package:wifi/shared/model/category_model.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/shared/operasi/firebase_operasi/notifikasi_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/customer_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/paeket_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/transaction_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/dompet_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/kategori_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/active_customer_op_firebase.dart';

// Mocks
class MockCustomerOpFirebase extends Mock implements CustomerOpFirebase {}

class MockPaketOpFirebase extends Mock implements PaketOpFirebase {}

class MockTransactionOpFirebase extends Mock implements TransactionOpFirebase {}

class MockDompetOpFirebase extends Mock implements DompetOpFirebase {}

class MockKategoriOpFirebase extends Mock implements KategoriOpFirebase {}

class MockActiveCustomerOpFirebase extends Mock
    implements ActiveCustomerOpFirebase {}

class MockNotifikasiOpFirebase extends Mock implements NotifikasiOpFirebase {}

void main() {
  late MockCustomerOpFirebase mockCustomerOperation;
  late MockPaketOpFirebase mockPackageOperation;
  late MockTransactionOpFirebase mockTransactionOperation;
  late MockDompetOpFirebase mockDompetOpFirebase;
  late MockKategoriOpFirebase mockCategoryOperation;
  late MockActiveCustomerOpFirebase mockActiveCustomerOperation;
  late MockNotifikasiOpFirebase mockNotifikasiOpFirebase;

  setUp(() {
    mockCustomerOperation = MockCustomerOpFirebase();
    mockPackageOperation = MockPaketOpFirebase();
    mockTransactionOperation = MockTransactionOpFirebase();
    mockDompetOpFirebase = MockDompetOpFirebase();
    mockCategoryOperation = MockKategoriOpFirebase();
    mockActiveCustomerOperation = MockActiveCustomerOpFirebase();
    mockNotifikasiOpFirebase = MockNotifikasiOpFirebase();
  });

  Widget createWidgetUnderTest({PelangganAktifModel? activeCustomer}) {
    return ProviderScope(
      overrides: [
        customerOpFirebaseProvider.overrideWithValue(mockCustomerOperation),
        paketOpFirebaseProvider.overrideWithValue(mockPackageOperation),
        transactionOpFirebaseProvider
            .overrideWithValue(mockTransactionOperation),
        dompetOpFirebaseProvider.overrideWithValue(mockDompetOpFirebase),
        kategoriOpFirebaseProvider.overrideWithValue(mockCategoryOperation),
        activeCustomerOpFirebaseProvider
            .overrideWithValue(mockActiveCustomerOperation),
        notifikasiOpFirebaseProvider
            .overrideWithValue(mockNotifikasiOpFirebase),
      ],
      child: MaterialApp(
        home: FormPelangganAktif(pelangganAktif: activeCustomer),
      ),
    );
  }

  testWidgets('01. should show loading indicator and then the form',
      (tester) async {
    when(() => mockCustomerOperation.ambilSemuaPelanggan())
        .thenAnswer((_) async => <PelangganModel>[]);
    when(() => mockPackageOperation.ambilSemuaPaketAktif())
        .thenAnswer((_) async => <PaketModel>[]);
    when(() => mockDompetOpFirebase.ambilSemuaDompet())
        .thenAnswer((_) async => <WalletModel>[]);
    when(() => mockCategoryOperation.ambilSemuaKategori())
        .thenAnswer((_) async => <CategoryModel>[]);

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.byType(Form), findsOneWidget);
  });
}
