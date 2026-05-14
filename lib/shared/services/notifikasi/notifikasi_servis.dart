// path: lib/shared/services/notifikasi/notifikasi_servis.dart
// diperbaiki: Mengubah tampilkanNotifikasiLangsung untuk selalu menghasilkan ID unik secara internal
// agar setiap notifikasi memicu notifikasi melayang.

import 'dart:math'; // ditambah: Impor dart:math untuk menggunakan Random.

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:wifi/shared/debug/log.dart';

/// Fungsi ini akan dipanggil ketika notifikasi di-tap saat aplikasi berada di background.
@pragma('vm:entry-point')
void onDidReceiveBackgroundNotificationResponse(NotificationResponse response) {
  Log.info(
    'Notifikasi background di-tap. Payload: ${response.payload}',
  );
}

/// Kelas layanan untuk mengelola notifikasi lokal.
class NotifikasiServis {
  /// Instance dari `FlutterLocalNotificationsPlugin`.
  final FlutterLocalNotificationsPlugin plugin;
  final Random _random =
      Random(); // ditambah: Instance dari Random untuk ID unik.

  /// Channel notifikasi untuk notifikasi penting.
  AndroidNotificationChannel? channelNotifikasiPenting;

  /// Konstruktor default untuk `NotifikasiServis`.
  NotifikasiServis() : plugin = FlutterLocalNotificationsPlugin();

  /// Konstruktor internal untuk keperluan pengujian.
  @visibleForTesting
  NotifikasiServis.internal(this.plugin);

  /// Menginisialisasi layanan notifikasi.
  Future<void> inisialisasi() async {
    Log.info('Memulai proses inisialisasi pengaturan notifikasi...');

    await _setupAndroidChannel();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);

    try {
      await plugin.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: (response) {
          Log.info(
            'Notifikasi foreground di-tap. Payload: ${response.payload}',
          );
        },
        onDidReceiveBackgroundNotificationResponse:
            onDidReceiveBackgroundNotificationResponse,
      );
      Log.info('Layanan Notifikasi berhasil diinisialisasi.');
    } on Exception catch  (e, s) {
      Log.error(
        'Gagal melakukan inisialisasi layanan notifikasi',
        e: e,
        st: s,
      );
    }
  }

  Future<void> _setupAndroidChannel() async {
    channelNotifikasiPenting = const AndroidNotificationChannel(
      'notifikasi_penting_wifi_app',
      'Notifikasi Penting',
      description:
          'Channel ini digunakan untuk notifikasi penting dari aplikasi.',
      importance: Importance.max,
    );

    final androidPlugin = plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    try {
      await androidPlugin?.createNotificationChannel(channelNotifikasiPenting!);
      Log.info(
        'Android Notification Channel "Notifikasi Penting" berhasil dibuat.',
      );
    } on Exception catch  (e, s) {
      Log.error('Gagal membuat Android Notification Channel', e: e, st: s);
    }
  }

  /// Meminta izin notifikasi dari pengguna (khusus Android).
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
        await androidPlugin.requestNotificationsPermission();
        Log.info('Permintaan izin notifikasi Android telah diproses.');
      }
    } on Exception catch  (e, s) {
      Log.error(
        'Gagal meminta izin notifikasi',
        e: e,
        st: s,
      );
    }
  }

  /// Mendapatkan detail peluncuran aplikasi dari notifikasi.
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

  /// Menampilkan notifikasi secara langsung.
  Future<void> tampilkanNotifikasiLangsung({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (channelNotifikasiPenting == null) {
      Log.error(
        'Gagal menampilkan notifikasi: Channel belum diinisialisasi.',
      );
      return;
    }

    // ditambah: Hasilkan ID 32-bit integer yang unik dan acak.
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
    } on Exception catch  (e, s) {
      Log.error(
        'Gagal menampilkan notifikasi langsung',
        e: e,
        st: s,
      );
    }
  }

  /// Menjadwalkan notifikasi untuk ditampilkan di masa mendatang.
  Future<void> jadwalNotifikasi({
    required int id,
    required String title,
    required String body,
    required DateTime jadwal,
    String? payload,
  }) async {
    if (channelNotifikasiPenting == null) {
      Log.error(
        'Gagal menjadwalkan notifikasi: Channel belum diinisialisasi.',
      );
      return;
    }

    Log.info('Merencanakan notifikasi terjadwal (ID: $id) pada waktu: $jadwal');

    final androidDetails = AndroidNotificationDetails(
      channelNotifikasiPenting!.id,
      channelNotifikasiPenting!.name,
      channelDescription: channelNotifikasiPenting!.description,
      importance: Importance.max,
      priority: Priority.high,
    );
    final notificationDetails = NotificationDetails(android: androidDetails);

    try {
      await plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(jadwal, tz.local),
        notificationDetails: notificationDetails,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
      Log.info('Notifikasi terjadwal berhasil didaftarkan ke sistem.');
    } on Exception catch  (e, s) {
      Log.error(
        'Gagal mendaftarkan jadwal notifikasi',
        e: e,
        st: s,
      );
    }
  }

  /// Memperbarui jadwal notifikasi yang sudah ada.
  Future<void> perbaruiJadwalNotifikasi({
    required int id,
    required String title,
    required String body,
    required DateTime jadwal,
    String? payload,
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

    Log.info('Pembaruan jadwal selesai dilakukan.');
  }

  /// Membatalkan notifikasi berdasarkan [id].
  Future<void> batalNotifikasi(int id) async {
    Log.info('Membatalkan notifikasi aktif/terjadwal dengan ID: $id');
    try {
      await plugin.cancel(id: id);
      Log.info('Notifikasi ID: $id telah dihapus.');
    } on Exception catch  (e, s) {
      Log.error(
        'Gagal membatalkan notifikasi ID: $id',
        e: e,
        st: s,
      );
    }
  }

  /// Membatalkan semua notifikasi.
  Future<void> batalSemuaNotifikasi() async {
    Log.info(
      'Membersihkan semua notifikasi yang ada (aktif maupun terjadwal)...',
    );
    try {
      await plugin.cancelAll();
      Log.info('Seluruh notifikasi berhasil dibersihkan.');
    } on Exception catch  (e, s) {
      Log.error(
        'Terjadi kesalahan saat membersihkan semua notifikasi',
        e: e,
        st: s,
      );
    }
  }
}
