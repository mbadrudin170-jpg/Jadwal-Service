// path: lib/user/providers/user_providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/akun/provider/akun_provider.dart';
import 'package:wifi/fitur/notfikasi/notifikasi_servis.dart';
import 'package:wifi/fitur/pelanggan/core/user_activity_service.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/shared/providers/shared_providers.dart';

part 'user_providers.g.dart';

@riverpod
class AppReadiness extends _$AppReadiness {
  @override
  bool build() => false; // Awalnya aplikasi belum siap
  void setReady(bool isReady) {
    state = isReady;
  }
}

@riverpod
LayananNotifikasi notifikasiServis(Ref ref) {
  return LayananNotifikasi();
}

@Riverpod(keepAlive: true)
Future<String?> userId(Ref ref) async {
  final akunState = await ref.watch(pengelolaAkunProvider.future);
  return akunState.akunSaatIni?.id;
}

@riverpod
Future<UserActivityService> userActivityService(Ref ref) async {
  final customerOp = ref.watch(customerOpFirebaseProvider);
  final prefs = ref.watch(sharedPreferencesProvider.future);
  return UserActivityService(
    customerOpFirebase: customerOp,
    prefs: await prefs,
  );
}
