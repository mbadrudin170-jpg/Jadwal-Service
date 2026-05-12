// path: lib/admin/halaman/tab/fungsi_menampilkan_notifikasi.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:wifi/shared/debug/log.dart';

@pragma('vm:entry-point')
void onDidReceiveNotificationResponse(
  NotificationResponse notificationResponse,
) async {
  Log.info(
    'Notifikasi di-tap oleh pengguna. '
    'ID Notifikasi: ${notificationResponse.id}, '
    'Payload: ${notificationResponse.payload ?? "Tidak ada payload"}. '
    'Fungsi ini dipanggil saat aplikasi menerima respons dari notifikasi yang diklik pengguna.',
  );
}

class NotifikasiServis {
  final FlutterLocalNotificationsPlugin plugin;

  NotifikasiServis() : plugin = FlutterLocalNotificationsPlugin() {
    Log.info(
      'NotifikasiServis instance dibuat. '
      'Menggunakan FlutterLocalNotificationsPlugin default.',
    );
  }

  @visibleForTesting
  NotifikasiServis.internal(this.plugin) {
    Log.info(
      'NotifikasiServis instance dibuat (internal/testing). '
      'Menggunakan FlutterLocalNotificationsPlugin yang di-inject. '
      'Instance plugin: ${plugin.hashCode}',
    );
  }

  Future<void> inisialisasi() async {
    Log.info(
      'Memulai konfigurasi dan inisialisasi plugin notifikasi lokal. '
      'Proses ini mencakup pengaturan channel Android, pengaturan iOS, '
      'dan inisialisasi zona waktu.',
    );
    try {
      Log.info(
        'Membuat konfigurasi inisialisasi untuk platform Android. '
        'Menggunakan icon @mipmap/ic_launcher sebagai ikon notifikasi.',
      );
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      Log.info(
        'Membuat konfigurasi inisialisasi untuk platform iOS (Darwin).',
      );
      const DarwinInitializationSettings darwinInitializationSettings =
          DarwinInitializationSettings();

      Log.info(
        'Menggabungkan konfigurasi Android dan iOS ke dalam InitializationSettings.',
      );
      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: androidInitializationSettings,
        iOS: darwinInitializationSettings,
      );

      Log.info(
        'Memanggil plugin.initialize() dengan konfigurasi yang telah dibuat. '
        'Mendaftarkan callback onDidReceiveNotificationResponse untuk menangani notifikasi yang di-tap.',
      );
      await plugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
        onDidReceiveBackgroundNotificationResponse:
            onDidReceiveNotificationResponse,
      );
      Log.info(
        'Plugin notifikasi berhasil diinisialisasi. '
        'Callback untuk notifikasi foreground dan background telah terdaftar.',
      );

      Log.info(
        'Menginisialisasi data zona waktu dari package timezone. '
        'Ini diperlukan untuk menjadwalkan notifikasi berdasarkan waktu lokal.',
      );
      tz.initializeTimeZones();
      
      Log.info(
        'Mengatur lokasi zona waktu default ke Asia/Jakarta (WIB).',
      );
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

      Log.info(
        'Inisialisasi NotifikasiServis BERHASIL. '
        'Plugin siap digunakan untuk menjadwalkan dan menampilkan notifikasi. '
        'Timezone: Asia/Jakarta.',
      );
    } catch (e, s) {
      Log.error(
        'Gagal menginisialisasi plugin notifikasi lokal. '
        'Proses inisialisasi mengalami kegagalan. '
        'Kemungkinan penyebab: plugin tidak terpasang dengan benar, '
        'konfigurasi platform tidak valid, atau zona waktu gagal diinisialisasi. '
        'Notifikasi tidak akan berfungsi sampai masalah ini diperbaiki.',
        error: e,
        st: s,
      );
    }
  }

  Future<bool> requestPermissions() async {
    Log.info(
      'Meminta izin notifikasi dari sistem operasi. '
      'Proses ini akan memeriksa dan meminta izin untuk platform Android dan iOS.',
    );
    try {
      Log.info(
        'Memeriksa apakah platform Android tersedia dan meminta izin notifikasi.',
      );
      bool? androidResult;
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      if (androidImplementation != null) {
        Log.info(
          'Implementasi Android ditemukan. Meminta izin notifikasi Android...',
        );
        androidResult = await androidImplementation
            .requestNotificationsPermission();
        Log.info(
          'Hasil permintaan izin Android: ${androidResult == true ? "DIBERIKAN" : "DITOLAK"}.',
        );
      } else {
        Log.info(
          'Implementasi Android tidak ditemukan. Melewati permintaan izin Android.',
        );
      }

      Log.info(
        'Memeriksa apakah platform iOS tersedia dan meminta izin notifikasi.',
      );
      bool? iosResult;
      final IOSFlutterLocalNotificationsPlugin? iOSImplementation = plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (iOSImplementation != null) {
        Log.info(
          'Implementasi iOS ditemukan. Meminta izin notifikasi iOS (alert, badge, sound)...',
        );
        iosResult = await iOSImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        Log.info(
          'Hasil permintaan izin iOS: ${iosResult == true ? "DIBERIKAN" : "DITOLAK"}.',
        );
      } else {
        Log.info(
          'Implementasi iOS tidak ditemukan. Melewati permintaan izin iOS.',
        );
      }

      final bool finalResult = (androidResult ?? false) || (iosResult ?? false);
      Log.info(
        'Hasil akhir permintaan izin notifikasi: ${finalResult ? "IZIN DIBERIKAN (minimal satu platform memberikan izin)" : "IZIN DITOLAK (semua platform menolak izin)"}. '
        'Android: ${androidResult ?? "tidak tersedia"}, '
        'iOS: ${iosResult ?? "tidak tersedia"}.',
      );
      return finalResult;
    } catch (e, s) {
      Log.error(
        'Gagal meminta izin notifikasi dari sistem operasi. '
        'Proses permintaan izin mengalami kegagalan. '
        'Kemungkinan penyebab: plugin tidak mendukung platform saat ini, '
        'terjadi error saat berkomunikasi dengan sistem operasi, '
        'atau pengguna telah menolak izin secara permanen.',
        error: e,
        st: s,
      );
      return false;
    }
  }

  Future<void> jadwalNotifikasi({
    required int id,
    required String title,
    required String body,
    required DateTime jadwal,
  }) async {
    Log.info(
      'Mencoba menjadwalkan notifikasi baru. '
      'ID Notifikasi: $id, '
      'Judul: "$title", '
      'Isi: "$body", '
      'Waktu Dijadwalkan: $jadwal (${jadwal.toIso8601String()}).',
    );
    try {
      Log.info(
        'Membuat konfigurasi detail notifikasi untuk platform Android. '
        'Channel ID: id_kadaluarsa_paket, '
        'Channel Name: Notifikasi Kadaluarsa Paket, '
        'Importance: max, '
        'Priority: high.',
      );
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
            'id_kadaluarsa_paket',
            'Notifikasi Kadaluarsa Paket',
            channelDescription:
                'Channel untuk notifikasi paket yang akan berakhir',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false,
          );

      Log.info(
        'Membungkus konfigurasi Android ke dalam NotificationDetails.',
      );
      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
      );

      Log.info(
        'Mengkonversi DateTime menjadi TZDateTime dengan zona waktu lokal (Asia/Jakarta).',
      );
      final tzDateTime = tz.TZDateTime.from(jadwal, tz.local);
      Log.info(
        'TZDateTime berhasil dibuat: ${tzDateTime.toIso8601String()}.',
      );

      Log.info(
        'Memanggil plugin.zonedSchedule() untuk menjadwalkan notifikasi. '
        'Mode penjadwalan Android: inexact (untuk efisiensi baterai).',
      );
      await plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tzDateTime,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexact,
      );

      Log.info(
        'Notifikasi BERHASIL dijadwalkan. '
        'ID: $id, '
        'Judul: "$title", '
        'Akan muncul pada: $jadwal (${jadwal.toIso8601String()}).',
      );
    } catch (e, s) {
      Log.error(
        'Gagal menjadwalkan notifikasi dengan ID: $id. '
        'Proses penjadwalan notifikasi mengalami kegagalan. '
        'Kemungkinan penyebab: ID duplikat, waktu yang sudah lewat, '
        'plugin belum diinisialisasi, atau izin notifikasi belum diberikan.',
        error: e,
        st: s,
      );
    }
  }

  Future<void> batalNotifikasi({required int id}) async {
    Log.info(
      'Mencoba membatalkan notifikasi yang telah dijadwalkan. '
      'ID Notifikasi yang akan dibatalkan: $id.',
    );
    try {
      Log.info(
        'Memanggil plugin.cancel() untuk membatalkan notifikasi dengan ID: $id.',
      );
      await plugin.cancel(id: id);
      Log.info(
        'Notifikasi dengan ID: $id BERHASIL dibatalkan. '
        'Notifikasi tidak akan muncul pada waktu yang telah dijadwalkan.',
      );
    } catch (e, s) {
      Log.error(
        'Gagal membatalkan notifikasi dengan ID: $id. '
        'Proses pembatalan notifikasi mengalami kegagalan. '
        'Kemungkinan penyebab: notifikasi dengan ID tersebut tidak ditemukan, '
        'plugin belum diinisialisasi, atau terjadi error sistem.',
        error: e,
        st: s,
      );
    }
  }

  Future<void> tampilkanNotifikasiLangsung({
    required int id,
    required String title,
    required String body,
  }) async {
    Log.info(
      'Mencoba menampilkan notifikasi secara langsung (segera). '
      'ID Notifikasi: $id, '
      'Judul: "$title", '
      'Isi: "$body".',
    );
    try {
      Log.info(
        'Membuat konfigurasi detail notifikasi langsung untuk platform Android. '
        'Channel ID: id_notifikasi_langsung, '
        'Channel Name: Notifikasi Langsung, '
        'Importance: max, '
        'Priority: high, '
        'showWhen: true.',
      );
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
            'id_notifikasi_langsung',
            'Notifikasi Langsung',
            channelDescription:
                'Channel untuk notifikasi yang ditampilkan langsung',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
          );

      Log.info(
        'Membungkus konfigurasi Android ke dalam NotificationDetails.',
      );
      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
      );

      Log.info(
        'Memanggil plugin.show() untuk menampilkan notifikasi secara langsung.',
      );
      await plugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
      );

      Log.info(
        'Notifikasi langsung BERHASIL ditampilkan. '
        'ID: $id, '
        'Judul: "$title", '
        'Isi: "$body". '
        'Notifikasi akan muncul di notification tray pengguna.',
      );
    } catch (e, s) {
      Log.error(
        'Gagal menampilkan notifikasi langsung dengan ID: $id. '
        'Proses menampilkan notifikasi secara langsung mengalami kegagalan. '
        'Kemungkinan penyebab: plugin belum diinisialisasi, '
        'izin notifikasi belum diberikan, atau channel belum terdaftar.',
        error: e,
        st: s,
      );
    }
  }
}
