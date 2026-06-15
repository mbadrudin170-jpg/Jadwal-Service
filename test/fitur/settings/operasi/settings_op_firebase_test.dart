
// path: test/fitur/settings/operasi/settings_op_firebase_test.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/fitur/settings/model/settings_model.dart';
import 'package:wifi/fitur/settings/operasi/settings_op_firebase.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';

void main() {
  group('SettingsOpFirebase', () {
    late FakeFirebaseFirestore fakeFirestore;
    late SettingsOpFirebase settingsOpFirebase;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      settingsOpFirebase = SettingsOpFirebase(firestore: fakeFirestore);
    });

    final tSettingsData = {
      NamaKolom.modeMaintenance: true,
      NamaKolom.infoMaintenance: 'Maintenance',
    };

    test('01. harus mengembalikan data Map<String, dynamic> ketika dokumen ada di Firestore', () async {
      // Arrange
      await fakeFirestore
          .collection(NamaTabel.settings)
          .doc(idGlobalSetting)
          .set(tSettingsData);

      // Act
      final result = await settingsOpFirebase.ambilPengaturan();

      // Assert
      expect(result, tSettingsData);
    });

    test('02. harus mengembalikan Map default ketika dokumen tidak ditemukan', () async {
      // Act
      final result = await settingsOpFirebase.ambilPengaturan();

      // Assert
      expect(result[NamaKolom.modeMaintenance], false);
      expect(result[NamaKolom.infoMaintenance], 'Aplikasi sedang dalam pemeliharaan. Silakan coba lagi nanti.');
    });

    test('03. harus mengembalikan Map default dan mencatat error ketika terjadi Exception', () async {
      // Arrange
      // Simulate an error by using a mock that throws an exception
      final erroringFirestore = FakeFirebaseFirestore();
      final instance = SettingsOpFirebase(firestore: erroringFirestore);

      // To trigger an exception, we can try to set invalid data
      await erroringFirestore
          .collection(NamaTabel.settings)
          .doc(idGlobalSetting)
          .set({ 'unsupported_type': FieldValue.arrayUnion([1]) });

      // Act
      final result = await instance.ambilPengaturan();

      // Assert
      expect(result[NamaKolom.modeMaintenance], false);
      expect(result[NamaKolom.infoMaintenance], 'Gagal memuat pengaturan. Menggunakan default.');
    });
  });
}
