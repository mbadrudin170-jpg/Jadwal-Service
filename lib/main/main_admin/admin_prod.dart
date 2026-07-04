import 'package:wifi/admin/firebase_option/firebase_option_admin_prod.dart';
import 'package:wifi/main/main_admin/bootstrap_admin.dart';

void main() async {
  await bootstrapAdmin(
    firebaseOptions: DefaultFirebaseOptions.currentPlatform,
    debugSupabase: false,
    logPrefix: '[admin-prod]',
  );
}
