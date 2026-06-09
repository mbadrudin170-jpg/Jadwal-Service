// path: lib/shared/providers/shared_providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/fitur/notfikasi/notifikasi_servis.dart';
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
      'appRoleProvider harus di-override di dalam ProviderScope');
}

@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferences(Ref ref) {
  return SharedPreferences.getInstance();
}

@Riverpod(keepAlive: true)
Future<LayananPenyimpananLokal> localStorageService(Ref ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return LayananPenyimpananLokal(prefs: prefs);
}

/// Provider sederhana yang hanya membuat instance NotifikasiServis.
@Riverpod(keepAlive: true)
NotifikasiServis notifikasiServis(Ref ref) {
  return NotifikasiServis();
}

/// Controller utama untuk notifikasi.
/// Tonton provider ini dari UI untuk menginisialisasi listener.
@Riverpod(keepAlive: true)
void pengontrolNotifikasi(Ref ref) {
  final role = ref.watch(appRoleProvider);
  final servis = ref.watch(notifikasiServisProvider);
  final notifikasiOp = ref.watch(notifikasiOpFirebaseProvider);

  Log.info('Menginisialisasi Notifikasi Controller untuk peran: $role');

  if (role == AppRole.admin) {
    // LOGIKA UNTUK ADMIN
    Log.info('Mode Admin: Memulai pemantauan notifikasi umum.');
    servis.pantauNotifikasiUmum(notifikasiOp);
  } else {
    // LOGIKA UNTUK USER
    Log.info('Mode User: Menyiapkan listener untuk status login.');
    ref.listen(localStorageServiceProvider, (previous, next) {
      next.when(
        data: (localStorage) async {
          final customer = await localStorage.ambilAkunLogin();
          if (customer != null) {
            Log.info(
                'User login terdeteksi, memulai pemantauan untuk ${customer.id}');
            servis.pantauNotifikasiUser(notifikasiOp, customer.id);
          } else {
            Log.info(
                'User logout terdeteksi, menghentikan pemantauan notifikasi.');
            servis.hentikanPemantauanNotifikasi();
          }
        },
        loading: () => Log.info('Menunggu LocalStorageService siap...'),
        error: (e, st) {
          Log.error('Error pada localStorageServiceProvider', e: e, st: st);
          servis.hentikanPemantauanNotifikasi();
        },
      );
    });
  }

  ref.onDispose(() {
    Log.info(
        'Notifikasi controller di-dispose, menghentikan semua pemantauan.');
    servis.hentikanPemantauanNotifikasi();
  });
}
