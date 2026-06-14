// path: test/shared/operasi/firebase_operasi/settings_op_firebase_test.dart
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/settings_op_firebase.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late SettingsOpFirebase settingsOp;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    settingsOp = SettingsOpFirebase(firestore: fakeFirestore);
  });

  group('Pengujian SettingsOpFirebase', () {
    test(
        '1. getSettings - seharusnya mengembalikan data pengaturan jika dokumen ada',
        () async {
      // Persiapan
      final settingsData = {
        NamaKolom.modeMaintenance: true,
        NamaKolom.infoMaintenance: 'Sedang maintenance!',
      };
      await fakeFirestore
          .collection(NamaTabel.get(TableName.settings))
          .doc(idGlobalSetting)
          .set(settingsData);

      // Aksi
      final result = await settingsOp.getSettings();

      // Verifikasi
      expect(result, isNotNull);
      expect(result[NamaKolom.modeMaintenance], isTrue);
      expect(result[NamaKolom.infoMaintenance], 'Sedang maintenance!');
    });

    test(
        '2. getSettings - seharusnya mengembalikan data default jika dokumen tidak ada',
        () async {
      // Aksi
      final result = await settingsOp.getSettings();

      // Verifikasi
      expect(result, isNotNull);
      expect(result[NamaKolom.modeMaintenance], isFalse);
      expect(result[NamaKolom.infoMaintenance],
          'Aplikasi sedang dalam pemeliharaan. Silakan coba lagi nanti.');
    });
  });
}
