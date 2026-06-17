// path lib/user/providers/user_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/akun/provider/akun_provider.dart';
import 'package:wifi/fitur/notfikasi/layanan_notifikasi.dart';
import 'package:wifi/fitur/pelanggan/core/layanan_aktivitas_user.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/shared/providers/shared_providers.dart';

part 'user_provider.g.dart';

@riverpod
class AppReadiness extends _$AppReadiness {
  @override
  bool build() => false; // Awalnya aplikasi belum siap
  void setReady(bool isReady) {
    state = isReady;
  }
}

@riverpod
LayananNotifikasi layananNotifikasi(Ref ref) {
  return LayananNotifikasi();
}

@Riverpod(keepAlive: true)
Future<String?> userId(Ref ref) async {
  final akunState = await ref.watch(pengelolaAkunProvider.future);
  return akunState.akunSaatIni?.id;
}

@riverpod
Future<LayananAktivitasUser> layananAktivitasUser(Ref ref) async {
  final customerOp = ref.watch(pelangganOpFirebaseProvider);
  final prefs = ref.watch(sharedPreferencesProvider.future);
  return LayananAktivitasUser(
    pelangganOpFirebase: customerOp,
    prefs: await prefs,
  );
}
