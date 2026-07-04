import 'package:wifi/admin/firebase_option/firebase_option_admin_dev.dart';
import 'package:wifi/main/main_admin/bootstrap_admin.dart';

void main() async {
  await bootstrapAdmin(
    firebaseOptions: DefaultFirebaseOptions.currentPlatform,
    debugSupabase: true,
    logPrefix: '[admin-dev]',
  );
}
