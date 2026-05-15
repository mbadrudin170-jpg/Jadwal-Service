// path: lib/main/main_admin/admin_dev.dart
// diubah: Mengurutkan impor dan mendaftarkan adapter Hive.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'package:wifi/admin/app_admin.dart';
import 'package:wifi/admin/firebase_option/firebase_option_admin_dev.dart';
import 'package:wifi/shared/enum/status_pembayaran_enum.dart';
import 'package:wifi/shared/enum/tipe_transaksi_enum.dart';
import 'package:wifi/shared/model/transaksi_model.dart';
import 'package:wifi/shared/services/notifikasi/notifikasi_servis.dart';

// Generated files
import 'package:wifi/shared/enum/status_pembayaran_enum.g.dart';
import 'package:wifi/shared/enum/tipe_transaksi_enum.g.dart';
import 'package:wifi/shared/model/transaksi_model.g.dart';


/// Fungsi utama untuk menjalankan aplikasi admin dalam mode pengembangan.
void main() async {
  // Memastikan binding Flutter siap.
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Hive.
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);

  // Daftarkan semua adapter yang diperlukan untuk Hive.
  Hive.registerAdapter(TransaksiModelAdapter());
  Hive.registerAdapter(TipeTransaksiEnumAdapter());
  Hive.registerAdapter(StatusPembayaranEnumAdapter());

  // Inisialisasi Firebase.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inisialisasi servis notifikasi.
  final notifikasiServis = NotifikasiServis();
  await notifikasiServis.inisialisasi();
  await notifikasiServis.requestPermissions();

  // Menjalankan aplikasi.
  runApp(const AppAdmin());
}
