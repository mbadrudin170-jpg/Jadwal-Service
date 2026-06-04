// path: test/shared/operasi/firebase_operasi/settings_op_firebase_test.dart
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/shared/constant/column_names.dart';
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
        ColumnNames.maintenanceMode: true,
        ColumnNames.maintenanceInfo: 'Sedang maintenance!',
      };
      await fakeFirestore
          .collection('settings')
          .doc('app')
          .set(settingsData);

      // Aksi
      final result = await settingsOp.getSettings();

      // Verifikasi
      expect(result, isNotNull);
      expect(result[ColumnNames.maintenanceMode], isTrue);
      expect(result[ColumnNames.maintenanceInfo], 'Sedang maintenance!');
    });

    test(
        '2. getSettings - seharusnya mengembalikan data default jika dokumen tidak ada',
        () async {
      // Aksi
      final result = await settingsOp.getSettings();

      // Verifikasi
      expect(result, isNotNull);
      expect(result[ColumnNames.maintenanceMode], isFalse);
      expect(result[ColumnNames.maintenanceInfo],
          'Aplikasi sedang dalam pemeliharaan. Silakan coba lagi nanti.');
    });
  });
}
