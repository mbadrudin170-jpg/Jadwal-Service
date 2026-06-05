// path: lib/shared/providers/shared_providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/user/services/storage/local_storage_service.dart';

part 'shared_providers.g.dart';

/// Provider untuk menyediakan instance SharedPreferences secara asynchronous.
@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferences(Ref ref) {
  return SharedPreferences.getInstance();
}

/// DIUBAH: Provider diubah menjadi FutureProvider untuk menangani inisialisasi async.
@Riverpod(keepAlive: true)
Future<LocalStorageService> localStorageService(Ref ref) async {
  // Menunggu SharedPreferences selesai diinisialisasi.
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return LocalStorageService(prefs: prefs);
}
