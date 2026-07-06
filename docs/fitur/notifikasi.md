# Dokumentasi Fitur: notifikasi

## Daftar file

- [lib/fitur/notifikasi/enum/tipe_notifikasi_enum.dart](../../lib/fitur/notifikasi/enum/tipe_notifikasi_enum.dart)
- [lib/fitur/notifikasi/layanan_notifikasi.dart](../../lib/fitur/notifikasi/layanan_notifikasi.dart)
- [lib/fitur/notifikasi/model/notifikasi_model.dart](../../lib/fitur/notifikasi/model/notifikasi_model.dart)
- [lib/fitur/notifikasi/operasi/notifikasi_op_firebase.dart](../../lib/fitur/notifikasi/operasi/notifikasi_op_firebase.dart)
- [lib/fitur/notifikasi/operasi/notifikasi_op_sqlite.dart](../../lib/fitur/notifikasi/operasi/notifikasi_op_sqlite.dart)
- [lib/fitur/notifikasi/pengingat_paket_belum_lunas.dart](../../lib/fitur/notifikasi/pengingat_paket_belum_lunas.dart)
- [lib/fitur/notifikasi/penjadwal_notifikasi.dart](../../lib/fitur/notifikasi/penjadwal_notifikasi.dart)

## Isi file

### File: `lib/fitur/notifikasi/enum/tipe_notifikasi_enum.dart`
```dart
// path: lib/fitur/notfikasi/enum/tipe_notifikasi_enum.dart

enum TipeNotifikasiEnum { transaksi, events, order, info }

extension TipeNotifikasiExtension on TipeNotifikasiEnum {
  String get displayName {
    switch (this) {
      case TipeNotifikasiEnum.transaksi:
        return 'Transaksi';
      case TipeNotifikasiEnum.events:
        return 'Event';
      case TipeNotifikasiEnum.order:
        return 'Pesanan';
      case TipeNotifikasiEnum.info:
        return 'Info';
    }
  }
}
```

### File: `lib/fitur/notifikasi/layanan_notifikasi.dart`
```dart
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
```

### File: `lib/fitur/notifikasi/model/notifikasi_model.dart`
```dart
// path: lib/fitur/notfikasi/model/notifikasi_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/utils/parser_util.dart';

part 'notifikasi_model.freezed.dart';

@freezed
abstract class NotifikasiModel with _$NotifikasiModel implements HasId {
  const NotifikasiModel._();
  const factory NotifikasiModel({
    required String id,
    required DateTime tanggalMulai,
    required DateTime tanggalBerakhir,
    required DateTime tanggalTampil,
    required String judul,
    required String deskripsi,
    @Default(false) bool setatusDibaca,
    required TipeNotifikasiEnum tipe,
    required DateTime diperbaruiPada,
    required String idTujuan,
    required String userId,
    @Default(false) bool dihapus,
    DateTime? diarsipkanPada,
    required AppRole targetRole,
  }) = _NotifikasiModel;

  factory NotifikasiModel.fromSqlite(Map<String, dynamic> map) {
    Log.info('Creating NotifikasiModel from SQLite: ${map[NamaKolom.id]}');
    return NotifikasiModel(
      id: map[NamaKolom.id] as String? ?? const Uuid().v4(),
      tanggalMulai:
          ParserUtil.parseDateTime(map[NamaKolom.tanggalMulai]) ??
          DateTime.now(),
      tanggalBerakhir:
          ParserUtil.parseDateTime(map[NamaKolom.tanggalBerakhir]) ??
          DateTime.now(),
      judul: map[NamaKolom.judul] as String? ?? '',
      deskripsi: map[NamaKolom.deskripsi] as String? ?? '',
      setatusDibaca: ParserUtil.parseBool(map[NamaKolom.statusDibaca]),
      tipe:
          ParserUtil.safeParseEnum(
            TipeNotifikasiEnum.values,
            map[NamaKolom.tipe],
          ) ??
          TipeNotifikasiEnum.transaksi,
      diperbaruiPada:
          ParserUtil.parseDateTime(map[NamaKolom.diperbaruiPada]) ??
          DateTime.now(),
      idTujuan: map[NamaKolom.idTujuan] as String? ?? '',
      targetRole:
          ParserUtil.safeParseEnum(AppRole.values, map[NamaKolom.targetRole]) ??
          AppRole.user,
      userId: map[NamaKolom.userId] as String? ?? '',
      dihapus: ParserUtil.parseBool(map[NamaKolom.dihapus]),
      diarsipkanPada: ParserUtil.parseDateTime(map[NamaKolom.diarsipkanPada]),
      tanggalTampil:
          ParserUtil.parseDateTime(map[NamaKolom.tanggalTampil]) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      NamaKolom.id: id,
      NamaKolom.tanggalMulai: tanggalMulai.millisecondsSinceEpoch,
      NamaKolom.tanggalBerakhir: tanggalBerakhir.millisecondsSinceEpoch,
      NamaKolom.judul: judul,
      NamaKolom.deskripsi: deskripsi,
      NamaKolom.statusDibaca: setatusDibaca ? 1 : 0,
      NamaKolom.tipe: tipe.name,
      NamaKolom.diperbaruiPada: diperbaruiPada.millisecondsSinceEpoch,
      NamaKolom.idTujuan: idTujuan,
      NamaKolom.targetRole: targetRole.name,
      NamaKolom.userId: userId,
      NamaKolom.dihapus: dihapus ? 1 : 0,
      NamaKolom.diarsipkanPada: diarsipkanPada?.millisecondsSinceEpoch,
      NamaKolom.tanggalTampil: tanggalTampil.millisecondsSinceEpoch,
    };
  }

  factory NotifikasiModel.fromFirebase(
    final String id,
    final Map<String, dynamic> data,
  ) {
    Log.info('Creating NotifikasiModel from Firebase: $id');
    return NotifikasiModel(
      id: id,
      tanggalMulai:
          ParserUtil.parseDateTime(data[NamaKolom.tanggalMulai]) ??
          DateTime.now(),
      tanggalBerakhir:
          ParserUtil.parseDateTime(data[NamaKolom.tanggalBerakhir]) ??
          DateTime.now(),
      tanggalTampil:
          ParserUtil.parseDateTime(data[NamaKolom.tanggalTampil]) ??
          DateTime.now(),
      judul: data[NamaKolom.judul] as String? ?? '',
      deskripsi: data[NamaKolom.deskripsi] as String? ?? '',
      setatusDibaca: ParserUtil.parseBool(data[NamaKolom.statusDibaca]),
      tipe:
          ParserUtil.safeParseEnum(
            TipeNotifikasiEnum.values,
            data[NamaKolom.tipe],
          ) ??
          TipeNotifikasiEnum.transaksi,
      diperbaruiPada:
          ParserUtil.parseDateTime(data[NamaKolom.diperbaruiPada]) ??
          DateTime.now(),
      idTujuan: data[NamaKolom.idTujuan] as String? ?? '',
      targetRole:
          ParserUtil.safeParseEnum(
            AppRole.values,
            data[NamaKolom.targetRole],
          ) ??
          AppRole.user,
      userId: data[NamaKolom.userId] as String? ?? '',
      dihapus: ParserUtil.parseBool(data[NamaKolom.dihapus]),
      diarsipkanPada: ParserUtil.parseDateTime(data[NamaKolom.diarsipkanPada]),
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      NamaKolom.id: id,
      NamaKolom.tanggalMulai: Timestamp.fromDate(tanggalMulai),
      NamaKolom.tanggalBerakhir: Timestamp.fromDate(tanggalBerakhir),
      NamaKolom.judul: judul,
      NamaKolom.deskripsi: deskripsi,
      NamaKolom.statusDibaca: setatusDibaca,
      NamaKolom.tipe: tipe.name,
      NamaKolom.diperbaruiPada: Timestamp.fromDate(diperbaruiPada),
      NamaKolom.idTujuan: idTujuan,
      NamaKolom.targetRole: targetRole.name,
      NamaKolom.userId: userId,
      NamaKolom.dihapus: dihapus,
      NamaKolom.tanggalTampil: Timestamp.fromDate(tanggalTampil),
      NamaKolom.diarsipkanPada: diarsipkanPada != null
          ? Timestamp.fromDate(diarsipkanPada!)
          : null,
    };
  }
}
```

### File: `lib/fitur/notifikasi/operasi/notifikasi_op_firebase.dart`
```dart
// path: lib/fitur/notfikasi/operasi/notifikasi_op_firebase.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/fitur/notifikasi/model/notifikasi_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/operasi/firebase_operasi/base_op_firebase.dart';

class NotifikasiOpFirebase {
  final FirebaseFirestore _firestore;
  final BaseOpFirebase _baseOp;
  final String _koleksi = NamaTabel.notifikasi;

  NotifikasiOpFirebase({
    required FirebaseFirestore firestore,
    required BaseOpFirebase baseOp,
  }) : _firestore = firestore,
       _baseOp = baseOp;

  Stream<List<NotifikasiModel>> getNotifAktif() {
    final now = DateTime.now();
    return _firestore
        .collection(_koleksi)
        .where(NamaKolom.dihapus, isEqualTo: false)
        .where(NamaKolom.statusDibaca, isEqualTo: false)
        .where(
          NamaKolom.tanggalTampil,
          isLessThanOrEqualTo: Timestamp.fromDate(now),
        )
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return NotifikasiModel.fromFirebase(doc.id, doc.data());
          }).toList();
        });
  }

  /// Mendapatkan stream notifikasi aktif untuk user tertentu (belum dibaca & belum dihapus)
  Stream<List<NotifikasiModel>> getByUserId(String userId) {
    return _firestore
        .collection(_koleksi)
        .where(NamaKolom.userId, isEqualTo: userId)
        .where(NamaKolom.targetRole, isEqualTo: AppRole.user.name)
        .where(NamaKolom.dihapus, isEqualTo: false)
        .where(NamaKolom.statusDibaca, isEqualTo: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NotifikasiModel.fromFirebase(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<List<NotifikasiModel>> getById(String id) {
    return _firestore.collection(_koleksi).doc(id).snapshots().map((snapshot) {
      if (!snapshot.exists) return [];
      final data = snapshot.data()!;
      if (data[NamaKolom.dihapus] == true ||
          data[NamaKolom.statusDibaca] == true) {
        return [];
      }
      return [NotifikasiModel.fromFirebase(snapshot.id, data)];
    });
  }

  // TODO : tambahkan unit test
  Stream<List<NotifikasiModel>> ambilKhususAdmin() {
    final now = DateTime.now();
    return _firestore
        .collection(_koleksi)
        .where(NamaKolom.targetRole, isEqualTo: AppRole.admin.name)
        .where(NamaKolom.tipe, isEqualTo: TipeNotifikasiEnum.order.name)
        .where(NamaKolom.statusDibaca, isEqualTo: false)
        .where(NamaKolom.dihapus, isEqualTo: false)
        .where(
          NamaKolom.tanggalTampil,
          isLessThanOrEqualTo: Timestamp.fromDate(now),
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NotifikasiModel.fromFirebase(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> addNotifikasi(NotifikasiModel notifikasi) async {
    try {
      Log.info('Saving notification to Firebase via BaseOp: ${notifikasi.id}');
      await _baseOp.sisipkan(_koleksi, notifikasi.id, notifikasi.toFirebase());
    } catch (e) {
      Log.error('Error saving notification: $e');
      rethrow;
    }
  }

  Future<void> updateNotif(NotifikasiModel notifikasi) async {
    try {
      Log.info(
        'Updating notification in Firebase via BaseOp: ${notifikasi.id}',
      );
      await _baseOp.update(_koleksi, notifikasi.id, notifikasi.toFirebase());
    } catch (e) {
      Log.error('Error updating notification: $e');
      rethrow;
    }
  }

  Future<void> softDeleteNotifikasi(String id) async {
    try {
      Log.info('Soft delete notifikasi: $id');
      await _baseOp.softDelete(_koleksi, id);
      Log.info('Soft delete notifikasi berhasil: $id');
    } catch (e, s) {
      Log.error('gagal fungsi soft delete notifikasi$e$s');
      rethrow;
    }
  }

  Future<void> hapusBerdasarkanIdTransaksi(String idTransaksi) async {
    try {
      Log.info(
        'Menghapus notifikasi berdasarkan idTujuan (transactionId): $idTransaksi',
      );
      final querySnapshot = await _firestore
          .collection(_koleksi)
          .where(NamaKolom.idTujuan, isEqualTo: idTransaksi)
          .get();
      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      Log.info('Berhasil menghapus ${querySnapshot.docs.length} notifikasi.');
    } catch (e, st) {
      Log.error(
        'Gagal menghapus notifikasi berdasarkan transactionId',
        e: e,
        s: st,
      );
      rethrow;
    }
  }

  /// Menandai notifikasi sebagai sudah dibaca.
  Future<void> tandaiSudahDibaca(String id) async {
    try {
      Log.info('Marking notification as read via BaseOp: $id');
      await _baseOp.update(_koleksi, id, {NamaKolom.statusDibaca: true});
    } catch (e) {
      Log.error('Error marking notification as read: $e');
      rethrow;
    }
  }
}
```

### File: `lib/fitur/notifikasi/operasi/notifikasi_op_sqlite.dart`
```dart
// path lib/fitur/notfikasi/operasi/notifikasi_op_sqlite.dart
// path: lib/fitur/notfikasi/operasi/notifikasi_op_sqlite.dart

import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/notifikasi/model/notifikasi_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_op_sqlite.dart';

/// Kelas untuk operasi terkait data notifikasi di database lokal.
class NotifikasiOpSqlite {
  final SqliteDatabase sqliteDb;
  final BaseOpSqlite _baseOpSqlite;
  final String _namaTabel = NamaTabel.notifikasi;
  final DateTime _nowUtc = DateTime.now().toUtc();

  /// Konstruktor dengan injeksi dependensi.
  NotifikasiOpSqlite({
    required this.sqliteDb,
    required BaseOpSqlite baseOpSqlite,
  }) : _baseOpSqlite = baseOpSqlite {
    Log.info('NotifikasiOpSqlite diinisialisasi - Tabel: $_namaTabel');
  }

  // =========================
  // OPERASI TULIS (WRITE)
  // =========================

  /// Menambahkan notifikasi baru ke database.
  Future<void> tambahNotifikasi(
    NotifikasiModel notifikasi, {
    bool dariServer = false,
  }) async {
    Log.info('Menambahkan notifikasi baru - ID: ${notifikasi.id}');
    try {
      final data = notifikasi.copyWith(diperbaruiPada: _nowUtc).toSqlite();
      await _baseOpSqlite.sisipkan(_namaTabel, data, dariServer: dariServer);
      Log.info('Notifikasi berhasil ditambahkan - ID: ${notifikasi.id}');
    } catch (e, st) {
      Log.error(
        'Gagal menambahkan notifikasi - ID: ${notifikasi.id}',
        e: e,
        s: st,
      );
      rethrow;
    }
  }

  /// Memperbarui notifikasi yang sudah ada di database.
  Future<void> perbaruiNotifikasi(
    NotifikasiModel notifikasi, {
    bool dariServer = false,
  }) async {
    Log.info('Memperbarui notifikasi - ID: ${notifikasi.id}');
    try {
      final data = notifikasi.copyWith(diperbaruiPada: _nowUtc).toSqlite();
      await _baseOpSqlite.update(
        _namaTabel,
        data,
        notifikasi.id,
        dariServer: dariServer,
      );
      Log.info('Notifikasi berhasil diperbarui - ID: ${notifikasi.id}');
    } catch (e, st) {
      Log.error(
        'Gagal memperbarui notifikasi - ID: ${notifikasi.id}',
        e: e,
        s: st,
      );
      rethrow;
    }
  }

  /// Menandai notifikasi sebagai sudah dibaca.
  Future<void> tandaiSudahDibaca(String id, {bool dariServer = false}) async {
    Log.info('Menandai notifikasi sudah dibaca - ID: $id');
    try {
      final data = {
        NamaKolom.statusDibaca: 1,
        NamaKolom.diperbaruiPada: _nowUtc.millisecondsSinceEpoch,
      };
      await _baseOpSqlite.update(_namaTabel, data, id, dariServer: dariServer);
      Log.info('Notifikasi berhasil ditandai sudah dibaca - ID: $id');
    } catch (e, st) {
      Log.error(
        'Gagal menandai notifikasi sudah dibaca - ID: $id',
        e: e,
        s: st,
      );
      rethrow;
    }
  }

  /// Melakukan soft delete pada notifikasi berdasarkan ID.
  Future<void> softDelete(String id, {bool dariServer = false}) async {
    Log.info('Memulai soft delete notifikasi - ID: $id');
    try {
      await _baseOpSqlite.softDelete(_namaTabel, id, dariServer: dariServer);
      Log.info('Soft delete notifikasi berhasil - ID: $id');
    } catch (e, st) {
      Log.error('Gagal soft delete notifikasi - ID: $id', e: e, s: st);
      rethrow;
    }
  }

  /// Melakukan soft delete pada semua notifikasi.
  Future<int> softDeleteAll({bool dariServer = false}) async {
    Log.info('Memulai soft delete semua notifikasi');
    try {
      final count = await _baseOpSqlite.softDeleteAll(
        _namaTabel,
        dariServer: dariServer,
      );
      Log.info('Soft delete semua notifikasi berhasil - Total: $count');
      return count;
    } catch (e, st) {
      Log.error('Gagal soft delete semua notifikasi', e: e, s: st);
      rethrow;
    }
  }

  /// Menghapus notifikasi secara permanen dari database.
  Future<void> hapusPermanen(String id, {bool dariServer = false}) async {
    Log.warning('Menghapus notifikasi secara permanen - ID: $id');
    try {
      await _baseOpSqlite.delete(_namaTabel, id, dariServer: dariServer);
      Log.info('Notifikasi berhasil dihapus permanen - ID: $id');
    } catch (e, st) {
      Log.error('Gagal menghapus permanen notifikasi - ID: $id', e: e, s: st);
      rethrow;
    }
  }

  /// Menyisipkan atau memperbarui beberapa notifikasi sekaligus (batch).
  Future<void> sisipkanAtauPerbaruiBatch(
    List<NotifikasiModel> daftarNotifikasi, {
    bool dariServer = false,
  }) async {
    if (daftarNotifikasi.isEmpty) {
      Log.info('Daftar notifikasi kosong, batch dibatalkan.');
      return;
    }

    Log.info(
      'Memulai batch insert/update untuk ${daftarNotifikasi.length} notifikasi',
    );
    try {
      final data = daftarNotifikasi
          .map((item) => item.copyWith(diperbaruiPada: _nowUtc).toSqlite())
          .toList();
      await _baseOpSqlite.sisipkanAtauPerbaruiBatch(
        _namaTabel,
        data,
        dariServer: dariServer,
      );
      Log.info('Batch ${daftarNotifikasi.length} notifikasi berhasil diproses');
    } catch (e, st) {
      Log.error('Gagal memproses batch notifikasi', e: e, s: st);
      rethrow;
    }
  }

  // =========================
  // OPERASI BACA (READ)
  // =========================

  /// Mengambil semua notifikasi dari database.
  Future<List<NotifikasiModel>> ambilSemua({
    bool tampilkanYangDiarsip = false,
  }) async {
    Log.info('Mengambil semua notifikasi dari tabel $_namaTabel');
    try {
      final db = await sqliteDb.database;
      final query = tampilkanYangDiarsip ? null : '${NamaKolom.dihapus} = 0';
      final List<Map<String, dynamic>> maps = await db.query(
        _namaTabel,
        where: query,
        orderBy: '${NamaKolom.tanggalTampil} DESC',
      );
      final hasil = List.generate(
        maps.length,
        (i) => NotifikasiModel.fromSqlite(maps[i]),
      );
      Log.info('Berhasil mengambil ${hasil.length} notifikasi');
      return hasil;
    } catch (e, st) {
      Log.error('Gagal mengambil semua notifikasi', e: e, s: st);
      rethrow;
    }
  }

  /// Mengambil semua notifikasi yang aktif (belum dibaca dan belum dihapus).
  Future<List<NotifikasiModel>> ambilNotifikasiAktif() async {
    Log.info('Mengambil notifikasi aktif dari tabel $_namaTabel');
    try {
      final db = await sqliteDb.database;
      final now = DateTime.now().millisecondsSinceEpoch;
      final List<Map<String, dynamic>> maps = await db.query(
        _namaTabel,
        where:
            '${NamaKolom.dihapus} = 0 AND ${NamaKolom.statusDibaca} = 0 AND ${NamaKolom.tanggalTampil} <= ?',
        whereArgs: [now],
        orderBy: '${NamaKolom.tanggalTampil} DESC',
      );
      final hasil = List.generate(
        maps.length,
        (i) => NotifikasiModel.fromSqlite(maps[i]),
      );
      Log.info('Berhasil mengambil ${hasil.length} notifikasi aktif');
      return hasil;
    } catch (e, st) {
      Log.error('Gagal mengambil notifikasi aktif', e: e, s: st);
      rethrow;
    }
  }

  /// Mengambil notifikasi berdasarkan ID pengguna.
  Future<List<NotifikasiModel>> ambilBerdasarkanUserId(
    String userId, {
    bool tampilkanYangDiarsip = false,
  }) async {
    Log.info('Mengambil notifikasi untuk User ID: $userId');
    try {
      final db = await sqliteDb.database;
      final query = tampilkanYangDiarsip
          ? '${NamaKolom.userId} = ?'
          : '${NamaKolom.userId} = ? AND ${NamaKolom.dihapus} = 0';
      final List<Map<String, dynamic>> maps = await db.query(
        _namaTabel,
        where: query,
        whereArgs: [userId],
        orderBy: '${NamaKolom.tanggalTampil} DESC',
      );
      final hasil = List.generate(
        maps.length,
        (i) => NotifikasiModel.fromSqlite(maps[i]),
      );
      Log.info(
        'Berhasil mengambil ${hasil.length} notifikasi untuk User $userId',
      );
      return hasil;
    } catch (e, st) {
      Log.error(
        'Gagal mengambil notifikasi untuk User ID: $userId',
        e: e,
        s: st,
      );
      rethrow;
    }
  }

  /// Mengambil notifikasi berdasarkan ID.
  Future<NotifikasiModel?> ambilBerdasarkanId(String id) async {
    Log.info('Mengambil notifikasi berdasarkan ID: $id');
    try {
      final db = await sqliteDb.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _namaTabel,
        where: '${NamaKolom.id} = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        final hasil = NotifikasiModel.fromSqlite(maps.first);
        Log.info('Notifikasi ditemukan - ID: $id');
        return hasil;
      }
      Log.info('Notifikasi dengan ID: $id tidak ditemukan');
      return null;
    } catch (e, st) {
      Log.error('Gagal mengambil notifikasi berdasarkan ID: $id', e: e, s: st);
      rethrow;
    }
  }

  /// Mengambil notifikasi berdasarkan ID tujuan (misal: ID transaksi).
  Future<List<NotifikasiModel>> ambilBerdasarkanIdTujuan(
    String idTujuan, {
    bool tampilkanYangDiarsip = false,
  }) async {
    Log.info('Mengambil notifikasi untuk ID Tujuan: $idTujuan');
    try {
      final db = await sqliteDb.database;
      final query = tampilkanYangDiarsip
          ? '${NamaKolom.idTujuan} = ?'
          : '${NamaKolom.idTujuan} = ? AND ${NamaKolom.dihapus} = 0';
      final List<Map<String, dynamic>> maps = await db.query(
        _namaTabel,
        where: query,
        whereArgs: [idTujuan],
        orderBy: '${NamaKolom.tanggalTampil} DESC',
      );
      final hasil = List.generate(
        maps.length,
        (i) => NotifikasiModel.fromSqlite(maps[i]),
      );
      Log.info(
        'Berhasil mengambil ${hasil.length} notifikasi untuk ID Tujuan $idTujuan',
      );
      return hasil;
    } catch (e, st) {
      Log.error(
        'Gagal mengambil notifikasi untuk ID Tujuan: $idTujuan',
        e: e,
        s: st,
      );
      rethrow;
    }
  }

  /// Menghapus notifikasi berdasarkan ID tujuan.
  Future<void> hapusBerdasarkanIdTujuan(
    String idTujuan, {
    bool dariServer = false,
  }) async {
    Log.info('Menghapus notifikasi berdasarkan ID Tujuan: $idTujuan');
    try {
      await _baseOpSqlite.operasiKompleks<void>((txn) async {
        await txn.delete(
          _namaTabel,
          where: '${NamaKolom.idTujuan} = ?',
          whereArgs: [idTujuan],
        );
        Log.info('Notifikasi dengan ID Tujuan $idTujuan berhasil dihapus');
      }, dariServer: dariServer);
    } catch (e, st) {
      Log.error(
        'Gagal menghapus notifikasi berdasarkan ID Tujuan: $idTujuan',
        e: e,
        s: st,
      );
      rethrow;
    }
  }
}
```

### File: `lib/fitur/notifikasi/pengingat_paket_belum_lunas.dart`
```dart
// path lib/fitur/notfikasi/pengingat_paket_belum_lunas.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wifi/fitur/app_role/role_util.dart';
import 'package:wifi/fitur/notifikasi/layanan_notifikasi.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/shared/providers/shared_providers.dart';
import 'package:wifi/user/providers/user_provider.dart'
    hide layananNotifikasiProvider;

const String waktuTerkahirNotif = 'last_notif_date';

/// Service untuk mengecek paket belum lunas dan menampilkan notifikasi pengingat.
class PengingatService {
  final LayananNotifikasi _notifServis;
  final Ref _ref;

  PengingatService(this._ref, this._notifServis);

  /// Mengecek transaksi dengan status belum lunas dan menampilkan notifikasi
  /// jika ada dan belum pernah ditampilkan hari ini.
  Future<void> cekDanTampilkanPengingatTagihan() async {
    Log.info('[PengingatTagihan] Memulai pengecekan paket belum lunas.');

    try {
      final role = _ref.read(appRoleProvider);
      if (role == AppRole.admin) {
        return;
      }
      final prefs = await _ref.read(sharedPreferencesProvider.future);
      final hariIni = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final terakhirNotif = prefs.getString(waktuTerkahirNotif) ?? '';
      if (terakhirNotif == hariIni) {
        Log.info(
          '[PengingatTagihan] Notifikasi sudah tampil hari ini, dilewati.',
        );
        return;
      }
      final userId = await _ref.read(userIdProvider.future);
      if (userId == null) {
        return;
      }
      final transaksiOpFirebase = _ref.read(transaksiOpFirebaseProvider);
      final daftarBelumLunas = await transaksiOpFirebase
          .ambilBelumLunasBerdasarkanIdPelanggan(userId);
      if (daftarBelumLunas.isNotEmpty) {
        Log.info(
          '[PengingatTagihan] Ditemukan ${daftarBelumLunas.length} paket belum lunas.',
        );
        await _notifServis.tampilkanNotifikasiLangsung(
          title: 'Pengingat Tagihan',
          body:
              'Anda memiliki ${daftarBelumLunas.length} paket yang belum lunas. Segera lakukan pembayaran.',
        );
        await prefs.setString(waktuTerkahirNotif, hariIni);
        Log.info('[PengingatTagihan] Notifikasi berhasil ditampilkan.');
      } else {
        Log.info('[PengingatTagihan] Tidak ada paket belum lunas.');
      }
    } on Exception catch (e, st) {
      Log.error(
        '[PengingatTagihan] Gagal mengecek atau menampilkan notifikasi.',
        e: e,
        s: st,
      );
    }
  }
}

/// Provider untuk service pengingat.
final pengingatServiceProvider = Provider<PengingatService>((ref) {
  final notifServis = ref.watch(layananNotifikasiProvider);
  return PengingatService(ref, notifServis);
});
```

### File: `lib/fitur/notifikasi/penjadwal_notifikasi.dart`
```dart
// path: lib/fitur/notfikasi/penjadwal_notifikasi.dart
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/notifikasi/layanan_notifikasi.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_firebase.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/services/arsipkan_langganan_kadaluarsa_service.dart';

class PenjadwalNotifikasi {
  static Future<void> aturNotifikasiLangganan(
    LayananNotifikasi layananNotifikasi,
    final String userId, {
    @visibleForTesting TransaksiOpFirebase? transaksiOp,
  }) async {
    Log.info(
      'Memulai pengecekan untuk penjadwalan notifikasi untuk pengguna: $userId',
    );
    final idNotifikasiAkhir = userId.hashCode;
    final idNotifikasiTengah = '${userId}_midpoint'.hashCode;

    final idAlarm = idNotifikasiAkhir;

    try {
      final transaksiOpFirebase = transaksiOp ?? TransaksiOpFirebase();

      final transaksi = await transaksiOpFirebase
          .ambilTransaksiLunasTerbaruBerdasarkanIdPelanggan(userId);
      if (transaksi != null &&
          transaksi.tanggalMulai != null &&
          transaksi.tanggalBerakhir != null &&
          transaksi.tanggalBerakhir!.isAfter(DateTime.now())) {
        final waktuJadwal = transaksi.tanggalBerakhir!;
        Log.info(
          'Langganan aktif ditemukan (ID: ${transaksi.id}). Menjadwalkan notifikasi & alarm akhir pada $waktuJadwal',
        );

        // 1. Jadwalkan Notifikasi Visual
        await layananNotifikasi.perbaruiJadwalNotifikasi(
          id: idNotifikasiAkhir,
          title: 'Voucher Telah Berakhir',
          body:
              'Masa aktif paket Anda telah berakhir. Perpanjang sekarang untuk terhubung lagi.',
          jadwal: waktuJadwal,
          payload: 'subscription_expired',
        );

        // 2. Jadwalkan Alarm untuk Eksekusi Background
        await AndroidAlarmManager.oneShotAt(
          waktuJadwal,
          idAlarm,
          _callbackAlarm, // Fungsi top-level
          exact: true, // Memastikan eksekusi tepat waktu
          wakeup: true, // Membangunkan perangkat jika dalam mode sleep
        );
        Log.info(
          'Alarm untuk ID $idAlarm berhasil dijadwalkan pada $waktuJadwal',
        );

        // -- Logika untuk Notifikasi Tengah Periode (tidak berubah) --
        final totalDurasi = transaksi.tanggalBerakhir!.difference(
          transaksi.tanggalMulai!,
        );
        final durasiTengah = totalDurasi.inSeconds ~/ 2;
        final tanggalTengah = transaksi.tanggalMulai!.add(
          Duration(seconds: durasiTengah),
        );

        if (tanggalTengah.isAfter(DateTime.now())) {
          Log.info(
            'Menjadwalkan notifikasi tengah periode pada $tanggalTengah',
          );
          await layananNotifikasi.perbaruiJadwalNotifikasi(
            id: idNotifikasiTengah,
            title: 'Status voucher Anda',
            body:
                'Masa aktif paket Anda sudah berjalan 50%. Terima kasih telah menggunakan layanan kami.',
            jadwal: tanggalTengah,
            payload: 'subscription_midpoint',
          );
        } else {
          Log.info(
            'Tanggal tengah periode sudah lewat. Membatalkan notifikasi jika ada.',
          );
          await layananNotifikasi.batalkanNotifikasi(idNotifikasiTengah);
        }
      } else {
        // Jika tidak ada langganan aktif, batalkan semua notifikasi DAN alarm.
        Log.info(
          'Tidak ada langganan aktif. Membatalkan semua notifikasi dan alarm untuk pengguna ini.',
        );
        await layananNotifikasi.batalkanNotifikasi(idNotifikasiAkhir);
        await layananNotifikasi.batalkanNotifikasi(idNotifikasiTengah);
        await AndroidAlarmManager.cancel(idAlarm);
        Log.info('Alarm dengan ID $idAlarm juga dibatalkan.');
      }
    } on Exception catch (e, st) {
      Log.error('Gagal mengatur notifikasi dari Firebase', e: e, s: st);
      // Jika terjadi error, coba batalkan semua notifikasi dan alarm untuk kebersihan.
      await layananNotifikasi.batalkanNotifikasi(idNotifikasiAkhir);
      await layananNotifikasi.batalkanNotifikasi(idNotifikasiTengah);
      await AndroidAlarmManager.cancel(idAlarm);
      Log.info('Alarm dengan ID $idAlarm juga dibatalkan karena error.');
    }
  }
}

@pragma('vm:entry-point')
Future<void> _callbackAlarm() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    final container = ProviderContainer();
    try {
      final service = container.read(arsipLanggananKadaluarsaServiceProvider);
      await service.prosesArsipLanggananKadaluarsa();
    } catch (e, st) {
      Log.error('Gagal menjalankan callback alarm', e: e, s: st);
    } finally {
      container.dispose();
    }
  } catch (e, st) {
    Log.error('Gagal inisialisasi callback alarm', e: e, s: st);
  }
}
```

