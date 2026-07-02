// path: test/fitur/notfikasi/layanan_notifikasi_test.dart
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:wifi/fitur/notifikasi/enum/tipe_notifikasi_enum.dart';
import 'package:wifi/fitur/notifikasi/layanan_notifikasi.dart';
import 'package:wifi/fitur/notifikasi/model/notifikasi_model.dart';
import 'package:wifi/fitur/notifikasi/operasi/notifikasi_op_firebase.dart';
import 'package:wifi/shared/enum/app_role_enum.dart';

import 'layanan_notifikasi_test.mocks.dart';

@GenerateMocks([
  FlutterLocalNotificationsPlugin,
  AndroidFlutterLocalNotificationsPlugin,
  NotifikasiOpFirebase,
])
void main() {
  late MockFlutterLocalNotificationsPlugin mockPlugin;
  late MockAndroidFlutterLocalNotificationsPlugin mockAndroidPlugin;
  late LayananNotifikasi layananNotifikasi;

  // Mock for timezone
  const timezoneChannel = MethodChannel(
    'plugins.flutter.io/flutter_timezone',
  );
  // Mock for permission handler
  const permissionChannel = MethodChannel(
    'flutter.baseflow.com/permissions/methods',
  );

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Initialize timezone data for testing
    tz.initializeTimeZones();
    // Set a known timezone for consistent test results
    tz.setLocalLocation(tz.getLocation('America/Detroit'));

    // Mock for FlutterTimezone
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(timezoneChannel, (
          methodCall,
        ) async {
          if (methodCall.method == 'getLocalTimezone') {
            return 'America/Detroit';
          }
          return null;
        });

    // Mock for Permission Handler
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, (
          methodCall,
        ) async {
          if (methodCall.method == 'checkPermissionStatus') {
            return PermissionStatus.granted.index;
          }
          if (methodCall.method == 'requestPermissions') {
            return {
              Permission.scheduleExactAlarm.value:
                  PermissionStatus.granted.index,
            };
          }
          return null;
        });
  });

  setUp(() {
    mockPlugin = MockFlutterLocalNotificationsPlugin();
    mockAndroidPlugin = MockAndroidFlutterLocalNotificationsPlugin();
    layananNotifikasi = LayananNotifikasi.testing(mockPlugin);

    // Stub the platform-specific implementation resolving
    when(
      mockPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >(),
    ).thenReturn(mockAndroidPlugin);

    // Stubbing channel creation to avoid null errors on channelNotifikasiPenting
    when(
      mockAndroidPlugin.createNotificationChannel(any),
    ).thenAnswer((_) async {});
    when(
      mockAndroidPlugin.requestExactAlarmsPermission(),
    ).thenAnswer((_) async => true);
    when(
      mockAndroidPlugin.requestNotificationsPermission(),
    ).thenAnswer((_) async => true);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(timezoneChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, null);
  });

  group('Inisialisasi', () {
    test(
      '01. harus menginisialisasi plugin dan channel dengan benar',
      () async {
        const iconName = '@mipmap/ic_launcher';
        when(
          mockPlugin.initialize(
            settings: anyNamed('settings'),
            onDidReceiveNotificationResponse: anyNamed(
              'onDidReceiveNotificationResponse',
            ),
            onDidReceiveBackgroundNotificationResponse: anyNamed(
              'onDidReceiveBackgroundNotificationResponse',
            ),
          ),
        ).thenAnswer((_) async => true);

        await layananNotifikasi.inisialisasiNotifikasi(iconName: iconName);

        verify(mockAndroidPlugin.createNotificationChannel(any)).called(1);

        final captured = verify(
          mockPlugin.initialize(
            settings: captureAnyNamed('settings'),
            onDidReceiveNotificationResponse: captureAnyNamed(
              'onDidReceiveNotificationResponse',
            ),
            onDidReceiveBackgroundNotificationResponse: captureAnyNamed(
              'onDidReceiveBackgroundNotificationResponse',
            ),
          ),
        ).captured;

        final settings = captured.first as InitializationSettings;
        expect(settings.android, isNotNull);
        expect(settings.android!.defaultIcon, equals(iconName));
        expect(captured[1], isNotNull);
        expect(captured[2], isNotNull);
      },
    );

    test(
      '02. _inisialisasiZonaWaktu menangani zona waktu GMT sebagai fallback',
      () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(timezoneChannel, (
              methodCall,
            ) async {
              if (methodCall.method == 'getLocalTimezone') {
                return 'GMT';
              }
              return null;
            });

        await layananNotifikasi.inisialisasiNotifikasi(iconName: 'test_icon');

        expect(tz.local.name, 'Asia/Jakarta');

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              timezoneChannel,
              (methodCall) async => 'America/Detroit',
            );
        tz.setLocalLocation(tz.getLocation('America/Detroit'));
      },
    );
  });

  group('Operasi Notifikasi', () {
    setUp(() async {
      await layananNotifikasi.inisialisasiNotifikasi(iconName: 'test_icon');
      clearInteractions(mockPlugin);
      clearInteractions(mockAndroidPlugin);
    });

    test(
      '03. tampilkanNotifikasiLangsung harus memanggil plugin.show dengan benar',
      () async {
        const title = 'Judul Tes';
        const body = 'Isi Tes';
        const payload = 'payload_tes';

        when(
          mockPlugin.show(
            id: anyNamed('id'),
            title: anyNamed('title'),
            body: anyNamed('body'),
            notificationDetails: anyNamed('notificationDetails'),
            payload: anyNamed('payload'),
          ),
        ).thenAnswer((_) async {});

        await layananNotifikasi.tampilkanNotifikasiLangsung(
          title: title,
          body: body,
          payload: payload,
        );

        final captured = verify(
          mockPlugin.show(
            id: captureAnyNamed('id'),
            title: captureAnyNamed('title'),
            body: captureAnyNamed('body'),
            notificationDetails: captureAnyNamed('notificationDetails'),
            payload: captureAnyNamed('payload'),
          ),
        ).captured;

        expect(captured[0], payload.hashCode);
        expect(captured[1], title);
        expect(captured[2], body);
        expect(captured[3], isA<NotificationDetails>());
        expect(captured[4], payload);
      },
    );

    test(
      '04. jadwalNotifikasi harus memanggil plugin.zonedSchedule dengan benar',
      () async {
        final jadwal = DateTime.now().add(const Duration(minutes: 5));
        const id = 123;
        const title = 'Jadwal Tes';
        const body = 'Isi Jadwal';

        when(
          mockPlugin.zonedSchedule(
            id: anyNamed('id'),
            title: anyNamed('title'),
            body: anyNamed('body'),
            scheduledDate: anyNamed('scheduledDate'),
            notificationDetails: anyNamed('notificationDetails'),
            payload: anyNamed('payload'),
            androidScheduleMode: anyNamed('androidScheduleMode'),
          ),
        ).thenAnswer((_) async {});

        await layananNotifikasi.jadwalNotifikasi(
          id: id,
          judul: title,
          pesan: body,
          jadwal: jadwal,
        );

        final captured = verify(
          mockPlugin.zonedSchedule(
            id: captureAnyNamed('id'),
            title: captureAnyNamed('title'),
            body: captureAnyNamed('body'),
            scheduledDate: captureAnyNamed('scheduledDate'),
            notificationDetails: captureAnyNamed('notificationDetails'),
            payload: anyNamed('payload'),
            androidScheduleMode: captureAnyNamed('androidScheduleMode'),
          ),
        ).captured;

        expect(captured[0], id);
        expect(captured[1], title);
        expect(captured[2], body);
        expect(captured[3], isA<tz.TZDateTime>());
        expect((captured[3] as tz.TZDateTime).year, jadwal.year);
        expect((captured[3] as tz.TZDateTime).month, jadwal.month);
        expect((captured[3] as tz.TZDateTime).day, jadwal.day);
        expect(captured[5], AndroidScheduleMode.exactAllowWhileIdle);
      },
    );

    test(
      '05. perbaruiJadwalNotifikasi harus membatalkan dan menjadwalkan ulang',
      () async {
        const id = 456;
        final jadwal = DateTime.now().add(const Duration(hours: 1));

        when(mockPlugin.cancel(id: anyNamed('id'))).thenAnswer((_) async {});
        when(
          mockPlugin.zonedSchedule(
            id: anyNamed('id'),
            title: anyNamed('title'),
            body: anyNamed('body'),
            scheduledDate: anyNamed('scheduledDate'),
            notificationDetails: anyNamed('notificationDetails'),
            payload: anyNamed('payload'),
            androidScheduleMode: anyNamed('androidScheduleMode'),
          ),
        ).thenAnswer((_) async {});

        await layananNotifikasi.perbaruiJadwalNotifikasi(
          id: id,
          title: 'Diperbarui',
          body: 'Isi baru',
          jadwal: jadwal,
        );

        verifyInOrder([
          mockPlugin.cancel(id: id),
          mockPlugin.zonedSchedule(
            id: id,
            title: 'Diperbarui',
            body: 'Isi baru',
            scheduledDate: any,
            notificationDetails: any,
            payload: any,
            androidScheduleMode: any,
          ),
        ]);
      },
    );

    test(
      '06. batalNotifikasi harus memanggil plugin.cancel dengan ID',
      () async {
        const id = 789;
        when(mockPlugin.cancel(id: anyNamed('id'))).thenAnswer((_) async {});

        await layananNotifikasi.batalkanNotifikasi(id);

        verify(mockPlugin.cancel(id: id)).called(1);
      },
    );

    test('07. batalSemuaNotifikasi harus memanggil plugin.cancelAll', () async {
      when(mockPlugin.cancelAll()).thenAnswer((_) async {});

      await layananNotifikasi.batalkanSemuaNotifikasi();

      verify(mockPlugin.cancelAll()).called(1);
    });
  });

  group('Pemantauan Notifikasi', () {
    late MockNotifikasiOpFirebase mockNotifikasiOp;
    late StreamController<List<NotifikasiModel>> streamController;

    setUp(() async {
      mockNotifikasiOp = MockNotifikasiOpFirebase();
      streamController = StreamController<List<NotifikasiModel>>.broadcast();

      await layananNotifikasi.inisialisasiNotifikasi(iconName: 'test');
      clearInteractions(mockPlugin);
    });

    tearDown(() {
      streamController.close();
      layananNotifikasi.hentikanPemantauanNotifikasi();
    });

    test(
      '08. pantauNotifUser harus menampilkan notifikasi untuk data baru di stream',
      () async {
        final notif1 = NotifikasiModel(
          id: '1',
          judul: 'Judul 1',
          deskripsi: 'Desk 1',
          tanggalMulai: DateTime.now(),
          tanggalBerakhir: DateTime.now().add(const Duration(days: 1)),
          tanggalTampil: DateTime.now(),
          tipe: TipeNotifikasiEnum.info,
          idTujuan: 'tujuan1',
          userId: 'user1',
          diperbaruiPada: DateTime.now(),
          targetRole: AppRole.user,
        );
        when(
          mockNotifikasiOp.getByUserId('user1'),
        ).thenAnswer((_) => streamController.stream);
        when(
          mockPlugin.show(
            id: anyNamed('id'),
            title: anyNamed('title'),
            body: anyNamed('body'),
            notificationDetails: anyNamed('notificationDetails'),
            payload: anyNamed('payload'),
          ),
        ).thenAnswer((_) async {});

        layananNotifikasi.pantauNotifUser(mockNotifikasiOp, 'user1');

        streamController.add([notif1]);
        await Future<void>.delayed(const Duration(milliseconds: 100));

        verify(
          mockPlugin.show(
            id: anyNamed('id'),
            title: 'Judul 1',
            body: 'Desk 1',
            notificationDetails: any,
            payload: 'notifikasi_id_1',
          ),
        ).called(1);
      },
    );

    test('09. pantauNotifUser tidak menampilkan notifikasi duplikat', () async {
      final notif1 = NotifikasiModel(
        id: '1',
        judul: 'Judul 1',
        deskripsi: 'Desk 1',
        tanggalMulai: DateTime.now(),
        tanggalBerakhir: DateTime.now().add(const Duration(days: 1)),
        tanggalTampil: DateTime.now(),
        tipe: TipeNotifikasiEnum.info,
        idTujuan: 'tujuan1',
        userId: 'user1',
        diperbaruiPada: DateTime.now(),
        targetRole: AppRole.user,
      );
      when(
        mockNotifikasiOp.getByUserId('user1'),
      ).thenAnswer((_) => streamController.stream);
      when(
        mockPlugin.show(
          id: anyNamed('id'),
          title: anyNamed('title'),
          body: anyNamed('body'),
          notificationDetails: anyNamed('notificationDetails'),
          payload: anyNamed('payload'),
        ),
      ).thenAnswer((_) async {});

      layananNotifikasi.pantauNotifUser(mockNotifikasiOp, 'user1');

      streamController.add([notif1]);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      verify(
        mockPlugin.show(
          id: anyNamed('id'),
          title: 'Judul 1',
          body: 'Desk 1',
          notificationDetails: any,
          payload: any,
        ),
      ).called(1);

      streamController.add([notif1]);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      verifyNoMoreInteractions(mockPlugin);
    });

    test(
      '10. hentikanPemantauanNotifikasi harus menutup subscription',
      () async {
        when(
          mockNotifikasiOp.getByUserId(any),
        ).thenAnswer((_) => streamController.stream);
        layananNotifikasi.pantauNotifUser(mockNotifikasiOp, 'user1');

        expect(streamController.hasListener, isTrue);

        layananNotifikasi.hentikanPemantauanNotifikasi();

        expect(streamController.hasListener, isFalse);
      },
    );
  });
}
