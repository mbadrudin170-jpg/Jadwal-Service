// path: test/shared/operasi/oeprasi_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/shared/operasi/active_customer_operation.dart';
import 'package:wifi/shared/operasi/apk_version_operation.dart';
import 'package:wifi/shared/operasi/category_operation.dart';
import 'package:wifi/shared/operasi/customer_operation.dart';
import 'package:wifi/shared/operasi/data_cleaning_operation.dart';
import 'package:wifi/shared/operasi/order_operation.dart';
import 'package:wifi/shared/operasi/package_operation.dart';
import 'package:wifi/shared/operasi/sub_category_operation.dart';
import 'package:wifi/shared/operasi/transaction_operation.dart';
import 'package:wifi/shared/operasi/upload_status_operation.dart';
import 'package:wifi/shared/operasi/wallet_operation.dart';

void main() {
  test('activeCustomerOperationProvider is created', () {
    final container = ProviderContainer();
    final activeCustomerOperation = container.read(activeCustomerOperationProvider);
    expect(activeCustomerOperation, isNotNull);
  });

  test('apkVersionOperationProvider is created', () {
    final container = ProviderContainer();
    final apkVersionOperation = container.read(apkVersionOperationProvider);
    expect(apkVersionOperation, isNotNull);
  });

  test('categoryOperationProvider is created', () {
    final container = ProviderContainer();
    final categoryOperation = container.read(categoryOperationProvider);
    expect(categoryOperation, isNotNull);
  });

  test('customerOperationProvider is created', () {
    final container = ProviderContainer();
    final customerOperation = container.read(customerOperationProvider);
    expect(customerOperation, isNotNull);
  });

  test('dataCleaningOperationProvider is created', () {
    final container = ProviderContainer();
    final dataCleaningOperation = container.read(dataCleaningOperationProvider);
    expect(dataCleaningOperation, isNotNull);
  });

  test('orderOperationProvider is created', () {
    final container = ProviderContainer();
    final orderOperation = container.read(orderOperationProvider);
    expect(orderOperation, isNotNull);
  });

  test('packageOperationProvider is created', () {
    final container = ProviderContainer();
    final packageOperation = container.read(packageOperationProvider);
    expect(packageOperation, isNotNull);
  });

  test('subCategoryOperationProvider is created', () {
    final container = ProviderContainer();
    final subCategoryOperation = container.read(subCategoryOperationProvider);
    expect(subCategoryOperation, isNotNull);
  });

  test('transactionOperationProvider is created', () {
    final container = ProviderContainer();
    final transactionOperation = container.read(transactionOperationProvider);
    expect(transactionOperation, isNotNull);
  });

  test('uploadStatusOperationProvider is created', () {
    final container = ProviderContainer();
    final uploadStatusOperation = container.read(uploadStatusOperationProvider);
    expect(uploadStatusOperation, isNotNull);
  });

  test('walletOperationProvider is created', () {
    final container = ProviderContainer();
    final walletOperation = container.read(walletOperationProvider);
    expect(walletOperation, isNotNull);
  });
}
