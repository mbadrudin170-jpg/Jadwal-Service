// path: test/fitur/settings/settings_op_firebase_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/fitur/settings/operasi/settings_op_firebase.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

// Mock class untuk Firestore yang rusak (simulasi error)
class BrokenFirebaseFirestore extends Mock implements FirebaseFirestore {
  @override
  CollectionReference<Map<String, dynamic>> collection(String name) {
    throw Exception('Firestore error');
  }
}

void main() {
  late SettingsOpFirebase settingsOpFirebase;
  late FirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    settingsOpFirebase = SettingsOpFirebase(firestore: fakeFirestore);
  });

  group('ambilPengaturan', () {
    test('01. harus mengembalikan data pengaturan jika dokumen ada', () async {
      // Arrange
      final data = {
        NamaKolom.modeMaintenance: true,
        NamaKolom.infoMaintenance: 'Sedang maintenance',
      };
      await fakeFirestore.collection('settings').doc('global_config').set(data);

      // Act
      final result = await settingsOpFirebase.ambilPengaturan();

      // Assert
      expect(result, equals(data));
    });

    test('02. harus mengembalikan data default jika dokumen tidak ada',
        () async {
      // Act
      final result = await settingsOpFirebase.ambilPengaturan();

      // Assert
      expect(
          result,
          equals({
            NamaKolom.modeMaintenance: false,
            NamaKolom.infoMaintenance:
                'Aplikasi sedang dalam pemeliharaan. Silakan coba lagi nanti.',
          }));
    });

    test('03. harus mengembalikan data default jika terjadi error', () async {
      // Arrange
      final brokenFirestore = BrokenFirebaseFirestore();
      settingsOpFirebase = SettingsOpFirebase(firestore: brokenFirestore);

      // Act
      final result = await settingsOpFirebase.ambilPengaturan();

      // Assert
      expect(
          result,
          equals({
            NamaKolom.modeMaintenance: false,
            NamaKolom.infoMaintenance:
                'Gagal memuat pengaturan. Menggunakan default.',
          }));
    });
  });
}
