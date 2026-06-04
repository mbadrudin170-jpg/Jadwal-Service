// path: test/shared/services/notifikasi/notifikasi_servis_test.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/shared/services/notifikasi/notifikasi_servis.dart';

import 'notifikasi_servis_test.mocks.dart';

// Menjalankan build_runner: flutter pub run build_runner build --delete-conflicting-outputs
@GenerateMocks([
  FlutterLocalNotificationsPlugin,
  AndroidFlutterLocalNotificationsPlugin,
])
void main() {
  late NotifikasiServis notifikasiServis;
  late MockFlutterLocalNotificationsPlugin mockPlugin;
  late MockAndroidFlutterLocalNotificationsPlugin mockAndroidPlugin;

  setUp(() {
    mockPlugin = MockFlutterLocalNotificationsPlugin();
    mockAndroidPlugin = MockAndroidFlutterLocalNotificationsPlugin();
    notifikasiServis = NotifikasiServis.testing(mockPlugin);

    // Mengatur agar pemanggilan resolvePlatformSpecificImplementation mengembalikan mock android
    when(mockPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>())
        .thenReturn(mockAndroidPlugin);
  });

  group('Pengujian NotifikasiServis', () {
    test('1. Inisialisasi berhasil memanggil metode yang diperlukan', () async {
      // Atur stub untuk metode yang dipanggil di dalam inisialisasi
      when(mockAndroidPlugin.requestNotificationsPermission())
          .thenAnswer((_) async => true);
      when(mockAndroidPlugin.requestExactAlarmsPermission())
          .thenAnswer((_) async => true);
      when(mockAndroidPlugin.createNotificationChannel(any))
          .thenAnswer((_) async => {});
      when(mockPlugin.initialize(
        settings: anyNamed('settings'),
        onDidReceiveNotificationResponse:
            anyNamed('onDidReceiveNotificationResponse'),
        onDidReceiveBackgroundNotificationResponse:
            anyNamed('onDidReceiveBackgroundNotificationResponse'),
      )).thenAnswer((_) async => true);

      await notifikasiServis.inisialisasi(iconName: 'app_icon');

      // Verifikasi bahwa metode initialize pada plugin dipanggil
      verify(mockPlugin.initialize(
        settings: anyNamed('settings'),
        onDidReceiveNotificationResponse:
            anyNamed('onDidReceiveNotificationResponse'),
        onDidReceiveBackgroundNotificationResponse:
            anyNamed('onDidReceiveBackgroundNotificationResponse'),
      )).called(1);

      // Verifikasi bahwa channel notifikasi dibuat
      verify(mockAndroidPlugin.createNotificationChannel(any)).called(1);
    });

    test('2. tampilkanNotifikasiLangsung memanggil show pada plugin', () async {
      // Inisialisasi channel terlebih dahulu
      notifikasiServis.channelNotifikasiPenting =
          const AndroidNotificationChannel('id', 'name');
      when(mockPlugin.show(
        id: anyNamed('id'),
        title: anyNamed('title'),
        body: anyNamed('body'),
        notificationDetails: anyNamed('notificationDetails'),
        payload: anyNamed('payload'),
      )).thenAnswer((_) async => {});

      const title = 'Judul Notifikasi';
      const body = 'Isi notifikasi.';
      await notifikasiServis.tampilkanNotifikasiLangsung(
          title: title, body: body);

      // Verifikasi bahwa metode show dipanggil dengan benar
      verify(mockPlugin.show(
        id: anyNamed('id'),
        title: title,
        body: body,
        notificationDetails: any,
      )).called(1);
    });

    test('3. jadwalNotifikasi memanggil zonedSchedule pada plugin', () async {
      // Inisialisasi channel dan izin
      notifikasiServis.channelNotifikasiPenting =
          const AndroidNotificationChannel('id', 'name');
      // Anggap izin sudah didapat untuk menyederhanakan tes
      // Anda bisa membuat tes terpisah untuk logika `pastikanIzinExactAlarm`
      when(mockPlugin.pendingNotificationRequests())
          .thenAnswer((_) async => []);
      when(mockPlugin.zonedSchedule(
        id: anyNamed('id'),
        title: anyNamed('title'),
        body: anyNamed('body'),
        scheduledDate: anyNamed('scheduledDate'),
        notificationDetails: anyNamed('notificationDetails'),
        payload: anyNamed('payload'),
        androidScheduleMode: anyNamed('androidScheduleMode'),
      )).thenAnswer((_) async {});

      final jadwal = DateTime.now().add(const Duration(hours: 1));
      await notifikasiServis.jadwalNotifikasi(
          id: 1, title: 'Jadwal', body: 'Isi jadwal', jadwal: jadwal);

      verify(mockPlugin.zonedSchedule(
        id: 1,
        title: 'Jadwal',
        body: 'Isi jadwal',
        scheduledDate: anyNamed('scheduledDate'),
        notificationDetails: any,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      )).called(1);
    });

    test('4. batalNotifikasi memanggil cancel pada plugin', () async {
      when(mockPlugin.cancel(id: anyNamed('id'))).thenAnswer((_) async {});

      const id = 123;
      await notifikasiServis.batalNotifikasi(id);

      verify(mockPlugin.cancel(id: id)).called(1);
    });

    test('5. batalSemuaNotifikasi memanggil cancelAll pada plugin', () async {
      when(mockPlugin.cancelAll()).thenAnswer((_) async {});

      await notifikasiServis.batalSemuaNotifikasi();

      verify(mockPlugin.cancelAll()).called(1);
    });
  });
}
