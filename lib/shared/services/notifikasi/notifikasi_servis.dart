// path: lib/shared/services/notifikasi/notifikasi_servis.dart

import 'dart:io'; // untuk Platform
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:wifi/shared/debug/log.dart';

final notifikasiServisProvider = Provider<NotifikasiServis>((ref) {
  Log.info('Membuat instance NotifikasiServis melalui Riverpod provider');
  // Factory constructor NotifikasiServis() sudah mengembalikan instance singleton
  return NotifikasiServis();
});
@pragma('vm:entry-point')
void onDidReceiveBackgroundNotificationResponse(
    final NotificationResponse response) {
  final String? payload = response.payload;
  if (response.payload != null) {
    debugPrint('notification payload: $payload');
  }
  debugPrint('Notifikasi background di-tap. Payload: ${response.payload}');
}

class NotifikasiServis {
  static NotifikasiServis? _instance;

  /// Menyediakan instance tunggal (Singleton) dari [NotifikasiServis].
  ///
  /// Jika instance belum ada, ia akan membuat yang baru.
  factory NotifikasiServis() {
    if (_instance == null) {
      Log.info('Membuat instance baru untuk NotifikasiServis (Singleton).');
      _instance = NotifikasiServis._internal();
    } else {
      Log.info('Menggunakan instance NotifikasiServis yang sudah ada.');
    }
    return _instance!;
  }

  /// Plugin utama untuk berinteraksi dengan notifikasi lokal.
  final FlutterLocalNotificationsPlugin plugin;

  final Random _random = Random();

  /// Channel notifikasi Android untuk pesan-pesan penting.
  AndroidNotificationChannel? channelNotifikasiPenting;

  static bool _zonaWaktuTelahDiinisialisasi = false;

  /// Konstruktor internal privat untuk implementasi Singleton.
  NotifikasiServis._internal() : plugin = FlutterLocalNotificationsPlugin() {
    Log.info('Konstruktor internal NotifikasiServis dipanggil.');
  }

  /// Konstruktor khusus untuk tujuan pengujian.
  /// Memungkinkan injeksi plugin palsu (mock).
  @visibleForTesting
  NotifikasiServis.testing(this.plugin);

  /// Menginisialisasi konfigurasi zona waktu untuk penjadwalan notifikasi.
  /// mengembalikan 'GMT' yang ambigu, dan menggantinya dengan 'Asia/Jakarta'
  /// agar penjadwalan sesuai dengan waktu lokal Indonesia.
  Future<void> _inisialisasiZonaWaktu() async {
    Log.info('Memeriksa status inisialisasi zona waktu.');
    if (_zonaWaktuTelahDiinisialisasi) {
      Log.info(
          'Inisialisasi zona waktu dilewati karena sudah berhasil dilakukan sebelumnya.');
      return;
    }

    try {
      Log.info('Memulai inisialisasi data zona waktu...');
      tz.initializeTimeZones();

      // [FIXED] Mengambil properti .identifier dari objek TimezoneInfo
      String zonaWaktuLokal =
          (await FlutterTimezone.getLocalTimezone()).identifier;
      Log.info('Zona waktu terdeteksi dari perangkat: $zonaWaktuLokal');

      // [DIPERBAIKI] Jika emulator mengembalikan "GMT" yang ambigu, gunakan "Asia/Jakarta".
      if (zonaWaktuLokal == 'GMT') {
        Log.warning(
          'Zona waktu "GMT" terdeteksi (kemungkinan dari emulator). Menggunakan "Asia/Jakarta" sebagai fallback.',
        );
        zonaWaktuLokal = 'Asia/Jakarta';
      }

      tz.Location lokasi;
      try {
        Log.info('Mencari lokasi untuk zona waktu: $zonaWaktuLokal');
        lokasi = tz.getLocation(zonaWaktuLokal);
      } on tz.LocationNotFoundException catch (e) {
        Log.error(
          'Lokasi untuk zona waktu "$zonaWaktuLokal" tidak ditemukan. Menggunakan "UTC" sebagai fallback utama. Detail: $e',
        );
        lokasi = tz.UTC;
      }

      tz.setLocalLocation(lokasi);
      Log.info(
          'Zona waktu lokal berhasil diatur ke: ${lokasi.name}. Inisialisasi selesai.');

      _zonaWaktuTelahDiinisialisasi = true;
    } on Exception catch (e, st) {
      Log.error(
        'Gagal total saat menginisialisasi zona waktu lokal.',
        e: e,
        st: st,
      );
    }
  }

  /// Menginisialisasi layanan notifikasi.
  ///
  /// Wajib dipanggil sebelum menggunakan fitur notifikasi lainnya.
  ///
  /// [iconName] adalah nama resource drawable untuk ikon notifikasi Android.
  Future<void> inisialisasi({required final String iconName}) async {
    Log.info('Memulai proses inisialisasi NotifikasiServis...');

    await _inisialisasiZonaWaktu();
    Log.info('inisialisai');
    await _setupAndroidChannel();

    final android = AndroidInitializationSettings(iconName);

    const ios = DarwinInitializationSettings();
    final settings = InitializationSettings(android: android, iOS: ios);

    try {
      Log.info('Menginisialisasi plugin flutter_local_notifications.');
      await plugin.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: (final response) {
          Log.info(
            'Notifikasi foreground di-tap. Payload: ${response.payload}',
          );
        },
        onDidReceiveBackgroundNotificationResponse:
            onDidReceiveBackgroundNotificationResponse,
      );
      Log.info('Layanan Notifikasi berhasil diinisialisasi secara lengkap.');
    } on Exception catch (e, s) {
      Log.error(
        'Gagal melakukan inisialisasi plugin notifikasi',
        e: e,
        st: s,
      );
    }
  }

  /// Menyiapkan channel notifikasi khusus untuk Android.
  Future<void> _setupAndroidChannel() async {
    Log.info('Memulai pengaturan channel notifikasi Android.');
    channelNotifikasiPenting = const AndroidNotificationChannel(
      'notifikasi_penting_wifi_app',
      'Notifikasi Penting',
      description:
          'Channel ini digunakan untuk notifikasi penting dari aplikasi.',
      importance: Importance.max,
    );
    Log.info(
        'Objek AndroidNotificationChannel dibuat: ${channelNotifikasiPenting!.id}');

    final androidPlugin = plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();
    if (androidPlugin == null) {
      Log.warning(
          'Gagal mendapatkan implementasi plugin Android. Tidak dapat membuat channel.');
      return;
    }
    try {
      await androidPlugin.createNotificationChannel(channelNotifikasiPenting!);
      Log.info(
        'Android Notification Channel "Notifikasi Penting" berhasil dibuat.',
      );
    } on Exception catch (e, s) {
      Log.error('Gagal membuat Android Notification Channel', e: e, st: s);
    }
  }

  /// Meminta izin dari pengguna untuk menampilkan notifikasi.
  Future<void> requestPermissions() async {
    Log.info('Meminta izin notifikasi dari pengguna...');
    try {
      if (kIsWeb) {
        Log.warning('Permintaan izin tidak berlaku untuk platform web.');
        return;
      }

      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
          plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final bool? granted =
            await androidPlugin.requestNotificationsPermission();
        Log.info(
            'Izin notifikasi diberikan oleh pengguna: ${granted ?? false}');
      } else {
        Log.warning(
            'Gagal mendapatkan implementasi plugin Android. Tidak dapat meminta izin.');
      }
    } on Exception catch (e, s) {
      Log.error(
        'Gagal meminta izin notifikasi',
        e: e,
        st: s,
      );
    }
  }

  /// Mendapatkan detail notifikasi yang menyebabkan aplikasi diluncurkan.
  ///
  /// Berguna untuk menangani aksi setelah pengguna men-tap notifikasi
  /// saat aplikasi dalam keadaan terminasi.
  Future<NotificationAppLaunchDetails?> getDetailPeluncuranNotifikasi() async {
    Log.info('Memeriksa apakah aplikasi diluncurkan melalui notifikasi...');
    final details = await plugin.getNotificationAppLaunchDetails();

    if (details != null && details.didNotificationLaunchApp) {
      Log.info(
        'Aplikasi diluncurkan dari notifikasi dengan ID: ${details.notificationResponse?.id}',
      );
    } else {
      Log.info('Aplikasi diluncurkan secara normal (bukan dari notifikasi).');
    }

    return details;
  }

  /// Menampilkan notifikasi secara langsung (instan).
  ///
  /// ID notifikasi dibuat secara acak.
  Future<void> tampilkanNotifikasiLangsung({
    required final String title,
    required final String body,
    final String? payload,
  }) async {
    Log.info(
        'Memeriksa channel notifikasi sebelum menampilkan notifikasi langsung.');
    if (channelNotifikasiPenting == null) {
      Log.error(
        'Gagal menampilkan notifikasi: Channel belum diinisialisasi.',
      );
      return;
    }
    Log.info('Channel notifikasi ditemukan: ${channelNotifikasiPenting!.id}');

    final int id = _random.nextInt(pow(2, 31).toInt());
    Log.info('Mengirim notifikasi langsung (ID Unik: $id, Judul: $title)');

    final androidDetails = AndroidNotificationDetails(
      channelNotifikasiPenting!.id,
      channelNotifikasiPenting!.name,
      channelDescription: channelNotifikasiPenting!.description,
      importance: Importance.max,
      priority: Priority.high,
    );
    final notificationDetails = NotificationDetails(android: androidDetails);

    try {
      await plugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
        payload: payload,
      );
      Log.info('Notifikasi langsung berhasil ditampilkan di layar.');
    } on Exception catch (e, s) {
      Log.error(
        'Gagal menampilkan notifikasi langsung',
        e: e,
        st: s,
      );
    }
  }

  /// Menjadwalkan notifikasi untuk ditampilkan di masa depan.
  ///
  /// [id] harus unik untuk setiap notifikasi yang dijadwalkan.
  Future<void> jadwalNotifikasi({
    required final int id,
    required final String title,
    required final String body,
    required final DateTime jadwal,
    final String? payload,
  }) async {
    Log.info('Memeriksa channel notifikasi sebelum menjadwalkan notifikasi.');
    if (channelNotifikasiPenting == null) {
      Log.error(
        'Gagal menjadwalkan notifikasi: Channel belum diinisialisasi.',
      );
      return;
    }
    Log.info('Channel notifikasi ditemukan: ${channelNotifikasiPenting!.id}');
    final pending = await plugin.pendingNotificationRequests();
    Log.info('=== DAFTAR NOTIFIKASI TERJADWAL (${pending.length}) ===');
    for (var notif in pending) {
      Log.info('ID: ${notif.id}, Title: ${notif.title}, Scheduled: $notif');
    }

    // Memastikan izin exact alarm diberikan sebelum menjadwalkan
    final bool hasPermission = await pastikanIzinExactAlarm();
    if (!hasPermission) {
      Log.error(
          'Gagal menjadwalkan notifikasi karena izin exact alarm ditolak.');
      // Mungkin tampilkan snackbar ke pengguna di sini
      return;
    }

    Log.info('Merencanakan notifikasi terjadwal (ID: $id) pada waktu: $jadwal');

    final androidDetails = AndroidNotificationDetails(
      channelNotifikasiPenting!.id,
      channelNotifikasiPenting!.name,
      channelDescription: channelNotifikasiPenting!.description,
      importance: Importance.max,
      priority: Priority.high,
      // DIPERBAIKI: Menggunakan resource dari @drawable yang sudah terverifikasi ada.
    );
    final notificationDetails = NotificationDetails(android: androidDetails);

    try {
      final tz.TZDateTime scheduledTZDate =
          tz.TZDateTime.from(jadwal, tz.local);
      Log.info(
          'Waktu notifikasi dikonversi ke zona waktu lokal (${tz.local.name}): $scheduledTZDate');

      await plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledTZDate,
        notificationDetails: notificationDetails,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      Log.info('Notifikasi terjadwal berhasil didaftarkan ke sistem.');
    } on Exception catch (e, s) {
      Log.error(
        'Gagal mendaftarkan jadwal notifikasi',
        e: e,
        st: s,
      );
    }
  }

  /// Memperbarui notifikasi yang sudah ada atau menjadwalkannya jika belum ada.
  ///
  /// Ini adalah kombinasi dari `batalNotifikasi` dan `jadwalNotifikasi`.
  Future<void> perbaruiJadwalNotifikasi({
    required final int id,
    required final String title,
    required final String body,
    required final DateTime jadwal,
    final String? payload,
  }) async {
    Log.info('Memulai pembaruan jadwal notifikasi untuk ID: $id');

    await batalNotifikasi(id);
    await jadwalNotifikasi(
      id: id,
      title: title,
      body: body,
      jadwal: jadwal,
      payload: payload,
    );

    Log.info('Pembaruan jadwal selesai dilakukan untuk ID: $id.');
  }

  /// Membatalkan notifikasi yang terjadwal atau yang sedang ditampilkan.
  Future<void> batalNotifikasi(final int id) async {
    Log.info('Membatalkan notifikasi aktif/terjadwal dengan ID: $id');
    try {
      await plugin.cancel(id: id);
      Log.info('Perintah pembatalan untuk notifikasi ID: $id telah dikirim.');
    } on Exception catch (e, s) {
      Log.error(
        'Gagal membatalkan notifikasi ID: $id',
        e: e,
        st: s,
      );
    }
  }

  /// Membatalkan semua notifikasi yang telah dibuat oleh aplikasi.
  Future<void> batalSemuaNotifikasi() async {
    Log.info(
      'Membersihkan semua notifikasi yang ada (aktif maupun terjadwal)...',
    );
    try {
      await plugin.cancelAll();
      Log.info('Seluruh notifikasi berhasil dibersihkan.');
    } on Exception catch (e, s) {
      Log.error(
        'Terjadi kesalahan saat membersihkan semua notifikasi',
        e: e,
        st: s,
      );
    }
  }

  /// Memastikan aplikasi memiliki izin Exact Alarm di Android.
  /// Jika tidak, arahkan pengguna ke pengaturan.
  Future<bool> pastikanIzinExactAlarm() async {
    if (!Platform.isAndroid) return true;

    Log.info('Memeriksa izin SCHEDULE_EXACT_ALARM.');
    final status = await Permission.scheduleExactAlarm.status;
    Log.info('Status izin SCHEDULE_EXACT_ALARM saat ini: $status');

    if (status.isGranted) {
      Log.info('Izin SCHEDULE_EXACT_ALARM sudah diberikan.');
      return true;
    } else {
      Log.warning('Izin SCHEDULE_EXACT_ALARM belum diberikan. Meminta izin...');
      final newStatus = await Permission.scheduleExactAlarm.request();
      Log.info('Status izin setelah meminta: $newStatus');
      if (newStatus.isGranted) {
        Log.info('Izin SCHEDULE_EXACT_ALARM berhasil didapatkan.');
        return true;
      } else {
        Log.error('Izin SCHEDULE_EXACT_ALARM ditolak oleh pengguna.');
        // Optionally, open app settings
        // await openAppSettings();
        return false;
      }
    }
  }
}
