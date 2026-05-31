// path: lib/admin/providers/app_providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/admin/repository/statistik_repository.dart';
import 'package:wifi/shared/export/operation.dart';
import 'package:wifi/shared/model/settings_model.dart';
import 'package:wifi/shared/operasi/settings_operation.dart';
import 'package:wifi/shared/operasi/transaction_operation.dart';
import 'package:wifi/shared/services/notifikasi/notifikasi_servis.dart';
import 'package:wifi/shared/utils/sync_manager.dart';

part 'app_providers.g.dart';

// Provider yang dipindahkan ke shared_providers.dart:
// - sharedPreferencesProvider
// - localStorageServiceProvider
// - themeNotifierProvider

// Provider sederhana untuk NotifikasiServis
@riverpod
NotifikasiServis notifikasiServis(ref) {
  return NotifikasiServis();
}

// Provider sederhana untuk SyncManager
@riverpod
SyncManager syncManager(ref) {
  return SyncManager();
}

// Provider untuk SettingsOperation
@riverpod
SettingsOperation settingsOperation(ref) {
  return SettingsOperation();
}

// FutureProvider untuk mendapatkan data settings secara asinkron
@riverpod
Future<SettingsModel> settings(ref) {
  return ref.watch(settingsOperationProvider).getSettings();
}

// Provider untuk TransactionOperation
@riverpod
TransactionOperation transactionOperation(ref) {
  return TransactionOperation();
}

@riverpod
StatistikRepository statistikRepository(ref) {
  return StatistikRepository();
}

@riverpod
ActiveCustomerOperation activeCustomerOperation(ref) {
  return ActiveCustomerOperation();
}
