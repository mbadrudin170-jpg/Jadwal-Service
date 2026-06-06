// path: lib/shared/providers/shared_providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/user/services/storage/local_storage_service.dart';

part 'shared_providers.g.dart';

@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferences(Ref ref) {
  return SharedPreferences.getInstance();
}

@Riverpod(keepAlive: true)
Future<LocalStorageService> localStorageService(Ref ref) async {
  // Menunggu SharedPreferences selesai diinisialisasi.
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return LocalStorageService(prefs: prefs);
}
