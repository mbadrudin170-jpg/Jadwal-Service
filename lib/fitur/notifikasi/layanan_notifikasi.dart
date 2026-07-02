// path: lib/fitur/notfikasi/layanan_notifikasi.dart

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:wifi/fitur/notifikasi/model/notifikasi_model.dart';
import 'package:wifi/fitur/notifikasi/operasi/notifikasi_op_firebase.dart';
import 'package:wifi/shared/debug/log.dart';

/// Callback yang dipanggil saat pengguna mengetuk notifikasi di background.
///
/// Dipicu oleh sistem ketika aplikasi tidak sedang berjalan dan pengguna
/// berinteraksi dengan notifikasi. Payload notifikasi dicatat untuk
/// pemrosesan lebih lanjut.
@pragma('vm:entry-point')
void onDidReceiveBackgroundNotificationResponse(
  final NotificationResponse response,
) {
  final payload = response.payload;
  if (response.payload != null) {
    debugPrint('notification payload: $payload');
  }
  debugPrint('Notifikasi background di-tap. Payload: ${response.payload}');
}

/// Layanan utama untuk mengelola notifikasi lokal dan Firebase.
///
/// Menyediakan fungsi-fungsi untuk menampilkan notifikasi langsung,
/// menjadwalkan notifikasi, memantau notifikasi dari Firebase,
/// serta mengelola izin dan channel Android. Kelas ini mengimplementasikan
/// pola singleton agar seluruh aplikasi menggunakan satu instance yang sama.
class LayananNotifikasi {
  static LayananNotifikasi? _instance;

  /// Mendapatkan instance singleton [LayananNotifikasi].
  ///
  /// Jika belum ada, akan dibuat instance baru. Jika sudah ada, instance
  /// yang sama akan dikembalikan.
  factory LayananNotifikasi() {
    if (_instance == null) {
      Log.info('Membuat instance baru untuk NotifikasiServis (Singleton).');
      _instance = LayananNotifikasi._internal();
    } else {
      Log.info('Menggunakan instance NotifikasiServis yang sudah ada.');
    }
    return _instance!;
  }

  /// Plugin utama untuk notifikasi lokal Flutter.
  final FlutterLocalNotificationsPlugin plugin;

  /// Generator angka acak untuk membuat ID notifikasi unik.
  final Random _random = Random();

  /// Channel notifikasi Android untuk notifikasi penting.
  AndroidNotificationChannel? channelNotifikasiPenting;

  /// Menandakan apakah zona waktu sudah berhasil diinisialisasi.
  static bool _zonaWaktuTelahDiinisialisasi = false;

  /// Kumpulan ID notifikasi yang sudah pernah ditampilkan, untuk mencegah
  /// duplikasi.
  final Set<String> _idNotifikasiTampil = {};

  /// Langganan stream notifikasi Firebase yang aktif.
  StreamSubscription<List<NotifikasiModel>>? _langgananNotifikasiFirebase;

  /// Konstruktor internal untuk singleton.
  ///
  /// Tidak dapat dipanggil langsung dari luar. Gunakan factory constructor.
  LayananNotifikasi._internal() : plugin = FlutterLocalNotificationsPlugin() {
    Log.info('Konstruktor internal NotifikasiServis dipanggil.');
  }

  /// Konstruktor untuk keperluan pengujian (testing).
  ///
  /// Memungkinkan injeksi dependency [FlutterLocalNotificationsPlugin].
  @visibleForTesting
  LayananNotifikasi.testing(this.plugin);

  /// Menginisialisasi data zona waktu lokal yang akan digunakan oleh
  /// notifikasi terjadwal.
  ///
  /// Hanya dijalankan sekali. Jika zona waktu perangkat adalah 'GMT'
  /// (umumnya pada emulator), akan menggunakan 'Asia/Jakarta' sebagai fallback.
  Future<void> _inisialisasiZonaWaktu() async {
    Log.info('Memeriksa status inisialisasi zona waktu.');
    if (_zonaWaktuTelahDiinisialisasi) {
      Log.info(
        'Inisialisasi zona waktu dilewati karena sudah berhasil dilakukan sebelumnya.',
      );
      return;
    }
    try {
      Log.info('Memulai inisialisasi data zona waktu...');
      tz.initializeTimeZones();
      var zonaWaktuLokal =
          (await FlutterTimezone.getLocalTimezone()).identifier;
      Log.info('Zona waktu terdeteksi dari perangkat: $zonaWaktuLokal');
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
        'Zona waktu lokal berhasil diatur ke: ${lokasi.name}. Inisialisasi selesai.',
      );
      _zonaWaktuTelahDiinisialisasi = true;
    } on Exception catch (e, st) {
      Log.error(
        'Gagal total saat menginisialisasi zona waktu lokal.',
        e: e,
        s: st,
      );
    }
  }

  /// Melakukan inisialisasi penuh layanan notifikasi.
  ///
  /// Termasuk inisialisasi zona waktu, pembuatan channel Android, dan
  /// pendaftaran plugin notifikasi lokal. Harus dipanggil sebelum
  /// menggunakan fitur notifikasi lainnya.
  Future<void> inisialisasiNotifikasi({required String iconName}) async {
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
        onDidReceiveNotificationResponse: (response) {
          Log.info(
            'Notifikasi foreground di-tap. Payload: ${response.payload}',
          );
        },
        onDidReceiveBackgroundNotificationResponse:
            onDidReceiveBackgroundNotificationResponse,
      );
      Log.info('Layanan Notifikasi berhasil diinisialisasi secara lengkap.');
    } on Exception catch (e, s) {
      Log.error('Gagal melakukan inisialisasi plugin notifikasi', e: e, s: s);
    }
  }

  /// Membuat dan mendaftarkan channel notifikasi Android.
  ///
  /// Channel ini digunakan untuk semua notifikasi penting dari aplikasi.
  /// Juga meminta izin notifikasi dan exact alarm.
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
      'Objek AndroidNotificationChannel dibuat: ${channelNotifikasiPenting!.id}',
    );

    final androidPlugin = plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();
    if (androidPlugin == null) {
      Log.warning(
        'Gagal mendapatkan implementasi plugin Android. Tidak dapat membuat channel.',
      );
      return;
    }
    try {
      await androidPlugin.createNotificationChannel(channelNotifikasiPenting!);
      Log.info(
        'Android Notification Channel "Notifikasi Penting" berhasil dibuat.',
      );
    } on Exception catch (e, s) {
      Log.error('Gagal membuat Android Notification Channel', e: e, s: s);
    }
  }

  /// Memulai pemantauan notifikasi umum (broadcast) dari Firebase.
  ///
  /// Setiap notifikasi baru akan langsung ditampilkan kepada pengguna,
  /// lalu ditandai sebagai sudah dibaca (soft delete) di Firebase.
  void pantauNotifUmum(NotifikasiOpFirebase notifikasiOp) {
    Log.info('Memulai pemantauan notifikasi umum dari Firebase...');
    unawaited(_langgananNotifikasiFirebase?.cancel());
    _langgananNotifikasiFirebase = notifikasiOp.ambilKhususAdmin().listen(
      (listNotifikasi) async {
        for (final notifikasi in listNotifikasi) {
          if (!_idNotifikasiTampil.contains(notifikasi.id)) {
            await tampilkanNotifikasiLangsung(
              title: notifikasi.judul,
              body: notifikasi.deskripsi,
              payload: 'notifikasi_id_${notifikasi.id}',
            );
            _idNotifikasiTampil.add(notifikasi.id);
            await notifikasiOp.softDeleteNotifikasi(notifikasi.id);
          }
        }
      },
      onError: (Object e, StackTrace st) {
        Log.error('Error pada stream notifikasi umum', e: e, s: st);
      },
    );
  }

  /// Memantau notifikasi yang dikirim khusus untuk pengguna tertentu.
  ///
  /// [userId] digunakan untuk memfilter notifikasi dari Firebase.
  void pantauNotifUser(NotifikasiOpFirebase notifikasiOp, String userId) {
    Log.info('Memulai pemantauan notifikasi dari Firebase...');
    unawaited(_langgananNotifikasiFirebase?.cancel());
    _langgananNotifikasiFirebase = notifikasiOp
        .getByUserId(userId)
        .listen(
          (listNotifikasi) async {
            Log.info(
              'Menerima ${listNotifikasi.length} notifikasi aktif dari stream.',
            );
            for (final notifikasi in listNotifikasi) {
              if (!_idNotifikasiTampil.contains(notifikasi.id)) {
                Log.info(
                  'Menampilkan notifikasi baru: ${notifikasi.id} - ${notifikasi.judul}',
                );
                await tampilkanNotifikasiLangsung(
                  title: notifikasi.judul,
                  body: notifikasi.deskripsi,
                  payload: 'notifikasi_id_${notifikasi.id}',
                );
                _idNotifikasiTampil.add(notifikasi.id);
                await notifikasiOp.softDeleteNotifikasi(notifikasi.id);
              }
            }
          },
          onError: (Object e, StackTrace st) {
            Log.error('Error pada stream notifikasi Firebase', e: e, s: st);
          },
          onDone: () {
            Log.warning('Stream notifikasi Firebase selesai.');
          },
        );
  }

  /// Menghentikan semua pemantauan notifikasi dari Firebase.
  ///
  /// Membersihkan langganan dan menghapus daftar ID notifikasi yang sudah
  /// ditampilkan.
  void hentikanPemantauanNotifikasi() {
    Log.info('Menghentikan pemantauan notifikasi dari Firebase.');
    unawaited(_langgananNotifikasiFirebase?.cancel());
    _idNotifikasiTampil.clear();
  }

  /// Meminta izin notifikasi kepada pengguna.
  ///
  /// Hanya berlaku pada platform Android. Untuk platform lain akan diabaikan.
  Future<void> mintaIzin() async {
    Log.info('Meminta izin notifikasi dari pengguna...');
    try {
      if (kIsWeb) {
        Log.warning('Permintaan izin tidak berlaku untuk platform web.');
        return;
      }
      final androidPlugin = plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        Log.info(
          'Izin notifikasi diberikan oleh pengguna: ${granted ?? false}',
        );
      } else {
        Log.warning(
          'Gagal mendapatkan implementasi plugin Android. Tidak dapat meminta izin.',
        );
      }
    } on Exception catch (e, s) {
      Log.error('Gagal meminta izin notifikasi', e: e, s: s);
    }
  }

  /// Mendapatkan detail peluncuran notifikasi saat aplikasi dibuka.
  ///
  /// Mengembalikan [NotificationAppLaunchDetails] jika aplikasi diluncurkan
  /// melalui notifikasi, atau `null` jika tidak.
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

  /// Menampilkan notifikasi secara langsung (tanpa penjadwalan).
  ///
  /// Notifikasi akan muncul segera setelah dipanggil. ID notifikasi dibuat
  /// berdasarkan hash payload atau acak.
  Future<void> tampilkanNotifikasiLangsung({
    required final String title,
    required final String body,
    final String? payload,
  }) async {
    Log.info(
      'Memeriksa channel notifikasi sebelum menampilkan notifikasi langsung.',
    );
    if (channelNotifikasiPenting == null) {
      Log.error('Gagal menampilkan notifikasi: Channel belum diinisialisasi.');
      return;
    }
    Log.info('Channel notifikasi ditemukan: ${channelNotifikasiPenting!.id}');

    final id = payload?.hashCode ?? _random.nextInt(pow(2, 31).toInt());
    Log.info('Mengirim notifikasi langsung (ID: $id, Judul: $title)');
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
      Log.error('Gagal menampilkan notifikasi langsung', e: e, s: s);
    }
  }

  /// Menjadwalkan notifikasi untuk waktu tertentu di masa depan.
  ///
  /// Memerlukan izin exact alarm. Waktu dijadwalkan dalam zona waktu lokal.
  Future<void> jadwalNotifikasi({
    required final int id,
    required final String judul,
    required final String pesan,
    required final DateTime jadwal,
    final String? payload,
  }) async {
    Log.info('Memeriksa channel notifikasi sebelum menjadwalkan notifikasi.');
    if (channelNotifikasiPenting == null) {
      Log.error('Gagal menjadwalkan notifikasi: Channel belum diinisialisasi.');
      return;
    }
    Log.info('Channel notifikasi ditemukan: ${channelNotifikasiPenting!.id}');
    final pending = await plugin.pendingNotificationRequests();
    Log.info('=== DAFTAR NOTIFIKASI TERJADWAL (${pending.length}) ===');
    for (final notif in pending) {
      Log.info('ID: ${notif.id}, Title: ${notif.title}, Scheduled: $notif');
    }

    final hasPermission = await mengecekIzinExactAlarm();
    if (!hasPermission) {
      Log.error(
        'Gagal menjadwalkan notifikasi karena izin exact alarm ditolak.',
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
    final detailNotifikasi = NotificationDetails(android: androidDetails);
    try {
      final waktuTerjadwalTZ = tz.TZDateTime.from(jadwal, tz.local);
      Log.info(
        'Waktu notifikasi dikonversi ke zona waktu lokal (${tz.local.name}): $waktuTerjadwalTZ',
      );
      await plugin.zonedSchedule(
        id: id,
        title: judul,
        body: pesan,
        scheduledDate: waktuTerjadwalTZ,
        notificationDetails: detailNotifikasi,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      Log.info('Notifikasi terjadwal berhasil didaftarkan ke sistem.');
    } on Exception catch (e, s) {
      Log.error('Gagal mendaftarkan jadwal notifikasi', e: e, s: s);
    }
  }

  /// Memperbarui jadwal notifikasi yang sudah ada.
  ///
  /// Membatalkan notifikasi lama dengan ID yang sama, lalu menjadwalkan
  /// ulang dengan data terbaru.
  Future<void> perbaruiJadwalNotifikasi({
    required final int id,
    required final String title,
    required final String body,
    required final DateTime jadwal,
    final String? payload,
  }) async {
    Log.info('Memulai pembaruan jadwal notifikasi untuk ID: $id');

    await batalkanNotifikasi(id);
    await jadwalNotifikasi(
      id: id,
      judul: title,
      pesan: body,
      jadwal: jadwal,
      payload: payload,
    );
    Log.info('Pembaruan jadwal selesai dilakukan untuk ID: $id.');
  }

  /// Membatalkan notifikasi aktif atau terjadwal berdasarkan ID.
  Future<void> batalkanNotifikasi(int id) async {
    Log.info('Membatalkan notifikasi aktif/terjadwal dengan ID: $id');
    try {
      await plugin.cancel(id: id);
      Log.info('Perintah pembatalan untuk notifikasi ID: $id telah dikirim.');
    } on Exception catch (e, s) {
      Log.error('Gagal membatalkan notifikasi ID: $id', e: e, s: s);
      rethrow;
    }
  }

  /// Membatalkan semua notifikasi yang sedang aktif maupun terjadwal.
  Future<void> batalkanSemuaNotifikasi() async {
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
        s: s,
      );
    }
  }

  /// Memeriksa dan meminta izin `SCHEDULE_EXACT_ALARM` pada Android.
  ///
  /// Mengembalikan `true` jika izin diberikan, `false` jika ditolak.
  /// Untuk platform selain Android langsung mengembalikan `true`.
  Future<bool> mengecekIzinExactAlarm() async {
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
        return false;
      }
    }
  }
}
