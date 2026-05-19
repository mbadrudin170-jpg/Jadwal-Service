// path: lib/main/main_admin/admin_prod.dart
// Fitur: Entry point untuk aplikasi admin (Production)
// Tujuan: Menginisialisasi Firebase dan layanan lainnya sebelum menjalankan aplikasi admin.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:wifi/admin/app_admin.dart';
import 'package:wifi/admin/firebase_option/firebase_option_admin_prod.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/services/notifikasi/notifikasi_servis.dart';

/// Fungsi utama untuk menjalankan aplikasi admin dalam mode produksi.
///
/// Menginisialisasi [WidgetsFlutterBinding] dan Firebase dengan opsi produksi,
/// serta menginisialisasi layanan notifikasi sebelum menjalankan [AppAdmin].
void main() async {
  Log.info('Memulai aplikasi admin mode produksi');
  // ditambah: Memastikan binding Flutter siap sebelum kode asynchronous dijalankan.
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // ditambah: Inisialisasi Firebase untuk platform saat ini dengan opsi produksi.
    Log.info('Menginisialisasi Firebase');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    Log.info('Firebase berhasil diinisialisasi');

    // Inisialisasi servis notifikasi menggunakan factory constructor Singleton.
    Log.info('Menginisialisasi layanan notifikasi');
    await NotifikasiServis().inisialisasi(iconName: '@mipmap/launcher_icon');
    // ditambah: Meminta izin notifikasi kepada pengguna.
    Log.info('Meminta izin notifikasi');
    await NotifikasiServis().requestPermissions();
    Log.info('Layanan notifikasi siap');

    // diubah: Menjalankan AppAdmin.
    Log.info('Menjalankan AppAdmin');
    runApp(const AppAdmin());
  } on Exception catch (e, st) {
    Log.error(
      'Gagal menginisialisasi aplikasi admin',
      e: e,
      st: st,
    );
    // SnackBar tidak dapat ditampilkan karena BuildContext belum tersedia di main().
    // Aplikasi tidak dapat dilanjutkan; error akan terlihat di console.
  }
}