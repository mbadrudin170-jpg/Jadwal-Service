// path: lib/shared/operasi/firebase_operasi/settings_op_firebase.dart
// diubah: Rename kelas ke SettingsOpFirebase, menggunakan TableNameValue
//         dan ColumnNames untuk semua referensi koleksi dan kolom.
// diperbaiki: Menambahkan logging inisialisasi.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/model.dart';

/// Kelas untuk mengelola operasi terkait data pengaturan di Firestore.
class SettingsOpFirebase {
  final FirebaseFirestore _db;

  /// Konstruktor untuk inisialisasi dengan instance FirebaseFirestore.
  SettingsOpFirebase({final FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance {
    Log.info('SettingsOpFirebase diinisialisasi.');
  }

  /// Mendapatkan referensi ke koleksi setting.
  CollectionReference get _collection => _db.collection(NamaTabel.settings);

  /// Mengambil pengaturan aplikasi dari Firestore.
  Future<Map<String, dynamic>> getSettings() async {
    try {
      final doc = await _collection.doc(idGlobalSetting).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        Log.info('Pengaturan dari Firestore berhasil diambil.', data);
        return data ?? {};
      }
      Log.warning('Dokumen pengaturan tidak ditemukan, pakai default.');
      return {
        NamaKolom.modeMaintenance: false,
        NamaKolom.infoMaintenance:
            'Aplikasi sedang dalam pemeliharaan. Silakan coba lagi nanti.',
      };
    } on Exception catch (e, s) {
      Log.error('Error mengambil pengaturan.', e: e, s: s);
      return {
        NamaKolom.modeMaintenance: false,
        NamaKolom.infoMaintenance:
            'Gagal memuat pengaturan. Menggunakan default.',
      };
    }
  }
}
