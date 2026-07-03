import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/fitur/settings/model/settings_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';

class SettingsOpFirebase {
  final FirebaseFirestore _db;

  SettingsOpFirebase({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance {
    Log.info('SettingsOpFirebase diinisialisasi.');
  }

  CollectionReference get _koleksi => _db.collection(NamaTabel.settings);

  Future<Map<String, dynamic>> ambilPengaturan() async {
    try {
      final doc = await _koleksi.doc(idGlobalSetting).get();
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
