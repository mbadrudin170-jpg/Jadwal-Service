// path: lib/shared/providers/shared_providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/fitur/notfikasi/layanan_notifikasi.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/app_role_enum.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/user/services/storage/layanan_penyimpanan_lokal.dart';

part 'shared_providers.g.dart';

/// Provider ini WAJIB di-override di root setiap aplikasi (main_user.dart/main_admin.dart).
/// Ini digunakan untuk memberi tahu provider lain dalam konteks aplikasi mana mereka berjalan.
@Riverpod(keepAlive: true)
AppRole appRole(Ref ref) {
  throw UnimplementedError(
    'appRoleProvider harus di-override di dalam ProviderScope',
  );
}

@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferences(Ref ref) {
  return SharedPreferences.getInstance();
}

@Riverpod(keepAlive: true)
Future<LayananPenyimpananLokal> layananPenyimpananLokal(Ref ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return LayananPenyimpananLokal(prefs: prefs);
}

/// Provider sederhana yang hanya membuat instance NotifikasiServis.
@Riverpod(keepAlive: true)
LayananNotifikasi layananNotifikasi(Ref ref) {
  return LayananNotifikasi();
}

/// Controller utama untuk notifikasi.
/// Tonton provider ini dari UI untuk menginisialisasi listener.
@Riverpod(keepAlive: true)
void pengontrolNotifikasi(Ref ref) {
  final role = ref.watch(appRoleProvider);
  final layananNotifikasi = ref.watch(layananNotifikasiProvider);
  final notifikasiOpFirebase = ref.watch(notifikasiOpFirebaseProvider);
  Log.info('Menginisialisasi Notifikasi Controller untuk peran: $role');
  if (role == AppRole.admin) {
    Log.info('Mode Admin: Memulai pemantauan notifikasi umum.');
    layananNotifikasi.pantauNotifUmum(notifikasiOpFirebase);
  } else {
    Log.info('Mode User: Menyiapkan listener untuk status login.');
    ref.listen(layananPenyimpananLokalProvider, (previous, next) {
      next.when(
        data: (penyimpananLokal) async {
          final pelanggan = await penyimpananLokal.ambilAkunLogin();
          if (pelanggan != null) {
            Log.info(
              'User login terdeteksi, memulai pemantauan untuk ${pelanggan.id}',
            );
            layananNotifikasi.pantauNotifUser(
              notifikasiOpFirebase,
              pelanggan.id,
            );
          } else {
            Log.info(
              'User logout terdeteksi, menghentikan pemantauan notifikasi.',
            );
            layananNotifikasi.hentikanPemantauanNotifikasi();
          }
        },
        loading: () => Log.info('Menunggu LocalStorageService siap...'),
        error: (e, s) {
          Log.error('Error pada localStorageServiceProvider', e: e, s: s);
          layananNotifikasi.hentikanPemantauanNotifikasi();
        },
      );
    });
  }

  ref.onDispose(() {
    Log.info(
      'Notifikasi controller di-dispose, menghentikan semua pemantauan.',
    );
    layananNotifikasi.hentikanPemantauanNotifikasi();
  });
}
