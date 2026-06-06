// path: lib/shared/providers/shared_providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/shared/services/notifikasi/notifikasi_servis.dart';
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

@Riverpod(keepAlive: true)
NotifikasiServis notifikasiServis(Ref ref) {
  Log.info(
      'Membuat instance NotifikasiServis dan memulai pemantauan Firebase.');

  // 1. Dapatkan dependensi NotifikasiOpFirebase dari providernya.
  final notifikasiOp = ref.watch(notifikasiOpFirebaseProvider);

  // 2. Buat instance NotifikasiServis.
  final servis = NotifikasiServis();

  // 3. Langsung panggil fungsi untuk memulai pemantauan.
  servis.pantauNotifikasiDariFirebase(notifikasiOp);

  // 4. Daftarkan fungsi cleanup/dispose.
  ref.onDispose(() {
    Log.info(
        'Provider di-dispose, menghentikan pemantauan notifikasi Firebase.');
    servis.hentikanPemantauanNotifikasi();
  });

  // 5. Kembalikan instance servis.
  return servis;
}
