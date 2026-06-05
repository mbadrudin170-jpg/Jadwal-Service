// path: lib/user/providers/user_providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

/// Provider untuk mendapatkan ID pengguna yang sedang login dari SharedPreferences.
@riverpod
Future<String?> userId(Ref ref) async {
  final prefs = await SharedPreferences.getInstance();
  // Kunci 'userId' digunakan saat login di `login_page.dart` dan `splash_screen_user.dart`.
  return prefs.getString('userId');
}
