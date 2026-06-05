// path: lib/shared/operasi/firebase_operasi/settings_op_firebase.dart
// diubah: Rename kelas ke SettingsOpFirebase, menggunakan TableNameValue
//         dan ColumnNames untuk semua referensi koleksi dan kolom.
// diperbaiki: Menambahkan logging inisialisasi.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
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
  CollectionReference get _collection =>
      _db.collection(TableNameValue.get(TableName.settings));

  /// Mengambil pengaturan aplikasi dari Firestore.
  Future<Map<String, dynamic>> getSettings() async {
    try {
      final doc = await _collection.doc(globalSettingsId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        Log.info('Pengaturan dari Firestore berhasil diambil.', data);
        return data ?? {};
      }
      Log.warning('Dokumen pengaturan tidak ditemukan, pakai default.');
      return {
        ColumnNames.maintenanceMode: false,
        ColumnNames.maintenanceInfo:
            'Aplikasi sedang dalam pemeliharaan. Silakan coba lagi nanti.',
      };
    } on Exception catch (e, s) {
      Log.error('Error mengambil pengaturan.', e: e, st: s);
      return {
        ColumnNames.maintenanceMode: false,
        ColumnNames.maintenanceInfo:
            'Gagal memuat pengaturan. Menggunakan default.',
      };
    }
  }
}
