// path: test/admin/halaman/form/active_customer_form_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/halaman/form/active_customer_form.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/shared/model/model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/notifikasi_op_firebase.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/active_customer_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/category_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/customer_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/dompet_op_sqlite.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/paket_Op_Sqlite.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/transaction_operation.dart';

class MockCustomerOperation extends Mock implements CustomerOperation {}

class MockPackageOperation extends Mock implements PaketOpSqlite {}

class MockTransactionOperation extends Mock implements TransactionOperation {}

class MockDompetOpSqlite extends Mock implements DompetOpSqlite {}

class MockCategoryOperation extends Mock implements CategoryOperation {}

class MockActiveCustomerOperation extends Mock
    implements ActiveCustomerOperation {}

class MockNotifikasiOpFirebase extends Mock implements NotifikasiOpFirebase {}

void main() {
  late MockCustomerOperation mockCustomerOperation;
  late MockPackageOperation mockPackageOperation;
  late MockTransactionOperation mockTransactionOperation;
  late MockDompetOpSqlite mockDompetOpSqlite;
  late MockCategoryOperation mockCategoryOperation;
  late MockActiveCustomerOperation mockActiveCustomerOperation;
  late MockNotifikasiOpFirebase mockNotifikasiOpFirebase;

  setUp(() {
    mockCustomerOperation = MockCustomerOperation();
    mockPackageOperation = MockPackageOperation();
    mockTransactionOperation = MockTransactionOperation();
    mockDompetOpSqlite = MockDompetOpSqlite();
    mockCategoryOperation = MockCategoryOperation();
    mockActiveCustomerOperation = MockActiveCustomerOperation();
    mockNotifikasiOpFirebase = MockNotifikasiOpFirebase();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        customerOperationProvider.overrideWithValue(mockCustomerOperation),
        packageOperationProvider.overrideWithValue(mockPackageOperation),
        transactionOperationProvider
            .overrideWithValue(mockTransactionOperation),
        walletOperationProvider.overrideWithValue(mockDompetOpSqlite),
        categoryOperationProvider.overrideWithValue(mockCategoryOperation),
        activeCustomerOperationProvider
            .overrideWithValue(mockActiveCustomerOperation),
        notifikasiOpFirebaseProvider
            .overrideWithValue(mockNotifikasiOpFirebase),
      ],
      child: const MaterialApp(
        home: FormPelangganAktif(),
      ),
    );
  }

  testWidgets('01. should show loading indicator and then the form',
      (tester) async {
    when(() => mockCustomerOperation.ambilSemua()).thenAnswer((_) async => []);
    when(() => mockPackageOperation.ambilBerdasarkanAktif())
        .thenAnswer((_) async => []);
    when(() => mockDompetOpSqlite.getWallets()).thenAnswer((_) async => []);
    when(() => mockCategoryOperation.getCategories())
        .thenAnswer((_) async => []);

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.byType(Form), findsOneWidget);
  });
}
