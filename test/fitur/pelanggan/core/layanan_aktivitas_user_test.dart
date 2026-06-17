
// path: test/fitur/pelanggan/core/layanan_aktivitas_user_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/fitur/pelanggan/core/layanan_aktivitas_user.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_firebase.dart';

import 'layanan_aktivitas_user_test.mocks.dart';

@GenerateMocks([PelangganOpFirebase, SharedPreferences])
void main() {
  late LayananAktivitasUser layananAktivitasUser;
  late MockPelangganOpFirebase mockPelangganOpFirebase;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockPelangganOpFirebase = MockPelangganOpFirebase();
    mockPrefs = MockSharedPreferences();
    layananAktivitasUser = LayananAktivitasUser(
      pelangganOpFirebase: mockPelangganOpFirebase,
      prefs: mockPrefs,
    );
  });

  const userId = 'user123';

  group('LayananAktivitasUser', () {
    test(
        '01. harus memanggil perbaruiTerakhirAktif saat pingAktivitas dipanggil pertama kali',
        () async {
      when(mockPrefs.getInt(any)).thenReturn(null);
      when(mockPelangganOpFirebase.perbaruiTerakhirAktif(any))
          .thenAnswer((_) async {});
      when(mockPrefs.setInt(any, any)).thenAnswer((_) async => true);

      await layananAktivitasUser.pingAktivitas(userId);

      verify(mockPelangganOpFirebase.perbaruiTerakhirAktif(userId)).called(1);
      verify(mockPrefs.setInt(LayananAktivitasUser.kunciPingTerakhirAktif, any))
          .called(1);
    });

    test(
        '02. harus memanggil perbaruiTerakhirAktif saat force true, meskipun belum waktunya',
        () async {
      final now = DateTime.now();
      final timestamp = now.millisecondsSinceEpoch;
      when(mockPrefs.getInt(any)).thenReturn(timestamp);
      when(mockPelangganOpFirebase.perbaruiTerakhirAktif(any))
          .thenAnswer((_) async {});
      when(mockPrefs.setInt(any, any)).thenAnswer((_) async => true);

      await layananAktivitasUser.pingAktivitas(userId, force: true);

      verify(mockPelangganOpFirebase.perbaruiTerakhirAktif(userId)).called(1);
      verify(mockPrefs.setInt(LayananAktivitasUser.kunciPingTerakhirAktif, any))
          .called(1);
    });

    test(
        '03. tidak boleh memanggil perbaruiTerakhirAktif jika belum waktunya (throttled)',
        () async {
      final now = DateTime.now();
      final timestamp = now
          .subtract(LayananAktivitasUser.jadwalPing - const Duration(minutes: 1))
          .millisecondsSinceEpoch;
      when(mockPrefs.getInt(any)).thenReturn(timestamp);

      await layananAktivitasUser.pingAktivitas(userId);

      verifyNever(mockPelangganOpFirebase.perbaruiTerakhirAktif(any));
      verifyNever(mockPrefs.setInt(any, any));
    });

    test(
        '04. harus memanggil perbaruiTerakhirAktif jika sudah waktunya (setelah throttle)',
        () async {
      final now = DateTime.now();
      final timestamp = now
          .subtract(LayananAktivitasUser.jadwalPing + const Duration(minutes: 1))
          .millisecondsSinceEpoch;
      when(mockPrefs.getInt(any)).thenReturn(timestamp);
      when(mockPelangganOpFirebase.perbaruiTerakhirAktif(any))
          .thenAnswer((_) async {});
      when(mockPrefs.setInt(any, any)).thenAnswer((_) async => true);

      await layananAktivitasUser.pingAktivitas(userId);

      verify(mockPelangganOpFirebase.perbaruiTerakhirAktif(userId)).called(1);
      verify(mockPrefs.setInt(LayananAktivitasUser.kunciPingTerakhirAktif, any))
          .called(1);
    });

    test('05. tidak boleh melakukan apa pun jika id pengguna kosong', () async {
      await layananAktivitasUser.pingAktivitas('');

      verifyNever(mockPelangganOpFirebase.perbaruiTerakhirAktif(any));
      verifyNever(mockPrefs.getInt(any));
      verifyNever(mockPrefs.setInt(any, any));
    });
  });
}
