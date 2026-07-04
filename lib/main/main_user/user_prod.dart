// path: lib/main/main_user/user_dev.dart

import 'package:wifi/main/main_user/bootstrap_user.dart';
import 'package:wifi/user/firebase_option/firebase_option_user_prod.dart';

void main() async {
  await bootstrapUser(
    firebaseOptions: DefaultFirebaseOptions.currentPlatform,
    logPrefix: '[main-dev]',
  );
}
