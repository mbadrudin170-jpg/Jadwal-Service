// path: test/shared/services/notifikasi/notifikasi_servis_test.dart
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/model/notifikasi_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/notifikasi_op_firebase.dart';
import 'package:wifi/fitur/notfikasi/notifikasi_servis.dart';

import 'notifikasi_servis_test.mocks.dart';

// Menjalankan build_runner: flutter pub run build_runner build --delete-conflicting-outputs
@GenerateMocks([
  FlutterLocalNotificationsPlugin,
  AndroidFlutterLocalNotificationsPlugin,
  NotifikasiOpFirebase,
])
void main() {
  // WAJIB: Atasi error "Binding has not yet been initialized"
  TestWidgetsFlutterBinding.ensureInitialized();

  late NotifikasiServis notifikasiServis;
  late MockFlutterLocalNotificationsPlugin mockPlugin;
  late MockAndroidFlutterLocalNotificationsPlugin mockAndroidPlugin;
  late MockNotifikasiOpFirebase mockNotifikasiOp;

  // Mengatur handler palsu untuk background channel
  const MethodChannel channel =
      MethodChannel('dexterous.com/flutter/local_notifications');

  setUp(() {
    mockPlugin = MockFlutterLocalNotificationsPlugin();
    mockAndroidPlugin = MockAndroidFlutterLocalNotificationsPlugin();
    mockNotifikasiOp = MockNotifikasiOpFirebase();
    notifikasiServis = NotifikasiServis.testing(mockPlugin);

    // Mengatur agar pemanggilan resolvePlatformSpecificImplementation mengembalikan mock android
    when(mockPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>())
        .thenReturn(mockAndroidPlugin);

    // Atur mock untuk channel background agar tidak error saat inisialisasi
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'initialize') {
        return true;
      }
      if (methodCall.method == 'pendingNotificationRequests') {
        return [];
      }
      return null;
    });

    // Atur mock untuk FlutterTimezone
    const MethodChannel timezoneChannel = MethodChannel('flutter_timezone');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(timezoneChannel,
            (MethodCall methodCall) async {
      if (methodCall.method == 'getLocalTimezone') {
        return 'Asia/Jakarta';
      }
      return null;
    });

    // Atur mock untuk permission_handler
    const MethodChannel permissionChannel =
        MethodChannel('flutter.baseflow.com/permissions/methods');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel,
            (MethodCall methodCall) async {
      if (methodCall.method == 'checkPermissionStatus') {
        return 1; // Index 1 adalah PermissionStatus.granted
      }
      return null;
    });

    // Inisialisasi channel notifikasi penting
    notifikasiServis.channelNotifikasiPenting =
        const AndroidNotificationChannel('id', 'name');
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('flutter_timezone'), null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('flutter.baseflow.com/permissions/methods'),
            null);
  });

  group('Pengujian NotifikasiServis', () {
    test('1. Inisialisasi berhasil memanggil metode yang diperlukan', () async {
      // Atur stub
      when(mockAndroidPlugin.requestNotificationsPermission())
          .thenAnswer((_) async => true);
      when(mockAndroidPlugin.requestExactAlarmsPermission())
          .thenAnswer((_) async => true);
      when(mockAndroidPlugin.createNotificationChannel(any))
          .thenAnswer((_) async {});
      when(mockPlugin.initialize(
        settings: anyNamed('settings'),
        onDidReceiveNotificationResponse:
            anyNamed('onDidReceiveNotificationResponse'),
        onDidReceiveBackgroundNotificationResponse:
            anyNamed('onDidReceiveBackgroundNotificationResponse'),
      )).thenAnswer((_) async => true);

      await notifikasiServis.inisialisasi(iconName: 'app_icon');

      // Verifikasi
      verify(mockPlugin.initialize(
        settings: anyNamed('settings'),
        onDidReceiveNotificationResponse:
            anyNamed('onDidReceiveNotificationResponse'),
        onDidReceiveBackgroundNotificationResponse:
            anyNamed('onDidReceiveBackgroundNotificationResponse'),
      )).called(1);
      verify(mockAndroidPlugin.createNotificationChannel(any)).called(1);
    });

    test('2. tampilkanNotifikasiLangsung memanggil show pada plugin', () async {
      when(mockPlugin.show(
        id: anyNamed('id'),
        title: anyNamed('title'),
        body: anyNamed('body'),
        notificationDetails: anyNamed('notificationDetails'),
        payload: anyNamed('payload'),
      )).thenAnswer((_) async {});

      const title = 'Judul Notifikasi';
      const body = 'Isi notifikasi.';
      await notifikasiServis.tampilkanNotifikasiLangsung(
          title: title, body: body);

      // Verifikasi
      final verification = verify(mockPlugin.show(
        id: anyNamed('id'),
        title: captureAnyNamed('title'),
        body: captureAnyNamed('body'),
        notificationDetails: anyNamed('notificationDetails'),
        payload: anyNamed('payload'),
      ));
      verification.called(1);
      expect(verification.captured[0], title);
      expect(verification.captured[1], body);
    });

    test('3. jadwalNotifikasi memanggil zonedSchedule pada plugin', () async {
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
      const id = 1;
      const title = 'Jadwal';
      const body = 'Isi jadwal';

      await notifikasiServis.jadwalNotifikasi(
          id: id, title: title, body: body, jadwal: jadwal);

      // Verifikasi
      final verification = verify(mockPlugin.zonedSchedule(
        id: captureAnyNamed('id'),
        title: captureAnyNamed('title'),
        body: captureAnyNamed('body'),
        scheduledDate: captureAnyNamed('scheduledDate'),
        notificationDetails: anyNamed('notificationDetails'),
        payload: anyNamed('payload'),
        androidScheduleMode: anyNamed('androidScheduleMode'),
      ));

      verification.called(1);
      expect(verification.captured[0], id);
      expect(verification.captured[1], title);
      expect(verification.captured[2], body);
      expect(verification.captured[3], isA<tz.TZDateTime>());
    });

    test('4. batalNotifikasi memanggil cancel pada plugin', () async {
      when(mockPlugin.cancel(id: anyNamed('id'), tag: anyNamed('tag')))
          .thenAnswer((_) async {});

      const id = 123;
      await notifikasiServis.batalNotifikasi(id);

      verify(mockPlugin.cancel(id: anyNamed('id'))).called(1);
    });

    test('5. batalSemuaNotifikasi memanggil cancelAll pada plugin', () async {
      when(mockPlugin.cancelAll()).thenAnswer((_) async {});

      await notifikasiServis.batalSemuaNotifikasi();

      verify(mockPlugin.cancelAll()).called(1);
    });

    test(
        '6. pantauNotifikasiUser harus menampilkan notifikasi dari stream dan mencegah duplikat',
        () async {
      // 1. Setup
      final streamController = StreamController<List<NotifikasiModel>>();
      final now = DateTime.now();
      final notif1 = NotifikasiModel(
        id: 'notif-1',
        title: 'Judul 1',
        description: 'Deskripsi 1',
        tanggalTampil: now,
        startDate: now,
        endDate: now.add(const Duration(days: 1)),
        type: TipeNotifikasiEnum.info,
        updatedAt: now,
        idTujuan: 'user-1',
        userId: 'user-1',
      );
      final notif2 = NotifikasiModel(
        id: 'notif-2',
        title: 'Judul 2',
        description: 'Deskripsi 2',
        tanggalTampil: now,
        startDate: now,
        endDate: now.add(const Duration(days: 1)),
        type: TipeNotifikasiEnum.info,
        updatedAt: now,
        idTujuan: 'user-2',
        userId: 'user-2',
      );

      when(mockNotifikasiOp.getByUserId(any))
          .thenAnswer((_) => streamController.stream);

      when(mockPlugin.show(
        id: anyNamed('id'),
        title: anyNamed('title'),
        body: anyNamed('body'),
        notificationDetails: anyNamed('notificationDetails'),
        payload: anyNamed('payload'),
      )).thenAnswer((_) async => {});

      // 2. Action
      notifikasiServis.pantauNotifikasiUser(mockNotifikasiOp, 'user-1');

      // 3. Menambahkan data ke stream
      streamController.add([notif1, notif2]);

      // Tunggu sebentar agar stream diproses
      await Future.delayed(Duration.zero);

      // 4. Verifikasi
      verify(mockPlugin.show(
        id: anyNamed('id'),
        title: 'Judul 1',
        body: 'Deskripsi 1',
        notificationDetails: anyNamed('notificationDetails'),
        payload: 'notifikasi_id_notif-1',
      )).called(1);

      verify(mockPlugin.show(
        id: anyNamed('id'),
        title: 'Judul 2',
        body: 'Deskripsi 2',
        notificationDetails: anyNamed('notificationDetails'),
        payload: 'notifikasi_id_notif-2',
      )).called(1);

      // 5. Menambahkan data yang sama lagi (plus satu baru) untuk menguji pencegahan duplikat
      final notif3 = NotifikasiModel(
        id: 'notif-3',
        title: 'Judul 3',
        description: 'Deskripsi 3',
        tanggalTampil: now,
        startDate: now,
        endDate: now.add(const Duration(days: 1)),
        type: TipeNotifikasiEnum.info,
        updatedAt: now,
        idTujuan: 'user-3',
        userId: 'user-3',
      );
      streamController.add([notif1, notif2, notif3]);

      await Future.delayed(Duration.zero);

      verify(mockPlugin.show(
        id: anyNamed('id'),
        title: 'Judul 3',
        body: 'Deskripsi 3',
        notificationDetails: anyNamed('notificationDetails'),
        payload: 'notifikasi_id_notif-3',
      )).called(1);

      verifyNever(mockPlugin.show(
        id: anyNamed('id'),
        title: 'Judul 1',
        body: 'Deskripsi 1',
        notificationDetails: anyNamed('notificationDetails'),
        payload: 'notifikasi_id_notif-1',
      ));

      verifyNever(mockPlugin.show(
        id: anyNamed('id'),
        title: 'Judul 2',
        body: 'Deskripsi 2',
        notificationDetails: anyNamed('notificationDetails'),
        payload: 'notifikasi_id_notif-2',
      ));

      // 6. Cleanup
      notifikasiServis.hentikanPemantauanNotifikasi();
      streamController.close();
    });

    test(
        '7. pantauNotifikasiUmum harus menampilkan notifikasi dari stream dan mencegah duplikat',
        () async {
      // 1. Setup
      final streamController = StreamController<List<NotifikasiModel>>();
      final now = DateTime.now();
      final notif1 = NotifikasiModel(
        id: 'notif-umum-1',
        title: 'Umum 1',
        description: 'Deskripsi Umum 1',
        tanggalTampil: now,
        startDate: now,
        endDate: now.add(const Duration(days: 1)),
        type: TipeNotifikasiEnum.order,
        updatedAt: now,
        idTujuan: '',
        userId: '',
      );
      final notif2 = NotifikasiModel(
        id: 'notif-umum-2',
        title: 'Umum 2',
        description: 'Deskripsi Umum 2',
        tanggalTampil: now,
        startDate: now,
        endDate: now.add(const Duration(days: 1)),
        type: TipeNotifikasiEnum.transaksi,
        updatedAt: now,
        idTujuan: '',
        userId: '',
      );

      when(mockNotifikasiOp.getKhususAdmin())
          .thenAnswer((_) => streamController.stream);

      when(mockPlugin.show(
        id: anyNamed('id'),
        title: anyNamed('title'),
        body: anyNamed('body'),
        notificationDetails: anyNamed('notificationDetails'),
        payload: anyNamed('payload'),
      )).thenAnswer((_) async => {});

      // 2. Action
      notifikasiServis.pantauNotifikasiUmum(mockNotifikasiOp);

      // 3. Menambahkan data ke stream
      streamController.add([notif1, notif2]);

      // Tunggu sebentar agar stream diproses
      await Future.delayed(Duration.zero);

      // 4. Verifikasi
      verify(mockPlugin.show(
        id: anyNamed('id'),
        title: 'Umum 1',
        body: 'Deskripsi Umum 1',
        notificationDetails: anyNamed('notificationDetails'),
        payload: 'notifikasi_id_notif-umum-1',
      )).called(1);

      verify(mockPlugin.show(
        id: anyNamed('id'),
        title: 'Umum 2',
        body: 'Deskripsi Umum 2',
        notificationDetails: anyNamed('notificationDetails'),
        payload: 'notifikasi_id_notif-umum-2',
      )).called(1);

      // 5. Menambahkan data yang sama lagi (plus satu baru) untuk menguji pencegahan duplikat
      final notif3 = NotifikasiModel(
        id: 'notif-umum-3',
        title: 'Umum 3',
        description: 'Deskripsi Umum 3',
        tanggalTampil: now,
        startDate: now,
        endDate: now.add(const Duration(days: 1)),
        type: TipeNotifikasiEnum.order,
        updatedAt: now,
        idTujuan: '',
        userId: '',
      );
      streamController.add([notif1, notif2, notif3]);

      await Future.delayed(Duration.zero);

      verify(mockPlugin.show(
        id: anyNamed('id'),
        title: 'Umum 3',
        body: 'Deskripsi Umum 3',
        notificationDetails: anyNamed('notificationDetails'),
        payload: 'notifikasi_id_notif-umum-3',
      )).called(1);

      verifyNever(mockPlugin.show(
        id: anyNamed('id'),
        title: 'Umum 1',
        body: 'Deskripsi Umum 1',
        notificationDetails: anyNamed('notificationDetails'),
        payload: 'notifikasi_id_notif-umum-1',
      ));

      verifyNever(mockPlugin.show(
        id: anyNamed('id'),
        title: 'Umum 2',
        body: 'Deskripsi Umum 2',
        notificationDetails: anyNamed('notificationDetails'),
        payload: 'notifikasi_id_notif-umum-2',
      ));

      // 6. Cleanup
      notifikasiServis.hentikanPemantauanNotifikasi();
      streamController.close();
    });
  });
}
