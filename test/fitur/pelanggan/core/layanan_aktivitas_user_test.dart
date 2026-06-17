
// path: test/fitur/pelanggan/core/layanan_aktivitas_user_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/fitur/pelanggan/core/layanan_aktivitas_user.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late LayananAktivitasUser layananAktivitasUser;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    layananAktivitasUser = LayananAktivitasUser(mockSharedPreferences);
  });

  group('LayananAktivitasUser', () {
    test('01. harus mengembalikan nilai default jika tidak ada data', () async {
      when(mockSharedPreferences.getString(any)).thenReturn(null);

      final waktu = await layananAktivitasUser.getWaktuAktivitasTerakhir();

      expect(waktu, isNull);
    });

    test('02. harus mengembalikan waktu aktivitas terakhir yang tersimpan', () async {
      final waktuTersimpan = DateTime.now().toIso8601String();
      when(mockSharedPreferences.getString(any)).thenReturn(waktuTersimpan);

      final waktu = await layananAktivitasUser.getWaktuAktivitasTerakhir();

      expect(waktu, isA<DateTime>());
      expect(waktu?.toIso8601String(), waktuTersimpan);
    });

    test('03. harus menyimpan waktu aktivitas terakhir', () async {
      final waktuSekarang = DateTime.now();
      when(mockSharedPreferences.setString(any, any))
          .thenAnswer((_) async => true);

      await layananAktivitasUser.setWaktuAktivitasTerakhir(waktuSekarang);

      verify(mockSharedPreferences.setString(
        LayananAktivitasUser.keyWaktuAktivitas,
        waktuSekarang.toIso8601String(),
      ));
    });
  });
}
