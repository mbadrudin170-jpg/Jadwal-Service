// path: lib/user/providers/user_providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/shared/services/notifikasi/notifikasi_servis.dart';

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
NotifikasiServis notifikasiServis(Ref ref) {
  // DIHAPUS: NotifikasiServisRef
  return NotifikasiServis();
}
