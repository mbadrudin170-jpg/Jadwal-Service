import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

// ditambah: Impor file-file Firebase Options yang akan kita gunakan.
// Kita asumsikan nama-nama file ini. Jika nama file Anda berbeda,
// kita perlu menyesuaikannya.
import 'firebase_options_user_dev.dart' as firebase_options_user_dev;
import 'firebase_options_user_prod.dart' as firebase_options_user_prod;
import 'firebase_options_admin_dev.dart' as firebase_options_admin_dev;
import 'firebase_options_admin_prod.dart' as firebase_options_admin_prod;

// ditambah: Fungsi ini akan mengembalikan FirebaseOptions yang benar berdasarkan
// flavor yang dilewatkan melalui --dart-define.
FirebaseOptions getFirebaseOptions() {
  // ditambah: Membaca flavor dari variabel environment.
  const flavor = String.fromEnvironment('flavor');

  // ditambah: Logika untuk memilih FirebaseOptions yang sesuai.
  switch (flavor) {
    case 'userDev':
      return firebase_options_user_dev.DefaultFirebaseOptions.currentPlatform;
    case 'userProd':
      return firebase_options_user_prod.DefaultFirebaseOptions.currentPlatform;
    case 'adminDev':
      return firebase_options_admin_dev.DefaultFirebaseOptions.currentPlatform;
    case 'adminProd':
      return firebase_options_admin_prod.DefaultFirebaseOptions.currentPlatform;
    default:
      // ditambah: Jika tidak ada flavor yang cocok, kita lempar error.
      throw UnsupportedError('Flavor \'$flavor\' tidak didukung.');
  }
}
