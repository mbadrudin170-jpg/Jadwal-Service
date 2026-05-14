// path: lib/shared/operasi/pelanggan_aktif_operasi.dart
// diubah: Menggunakan DateTime.now().toUtc() untuk konsistensi waktu dan memperbaiki path.

import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/pelanggan_aktif_model.dart';
import 'package:wifi/shared/operasi/operasi_dasar.dart';
import 'package:wifi/shared/operasi/pelanggan_operasi.dart';
import 'package:wifi/shared/services/notifikasi/notifikasi_servis.dart';

/// Konstanta untuk generate UUID.
const uuid = Uuid();

/// Kelas untuk operasi terkait data pelanggan aktif di database lokal.
class PelangganAktifOperasi {
  /// Instance dari DatabaseHelper untuk mengakses database.
  final dbHelper = DatabaseHelper.instance;
  final OperasiDasar _operasiDasar = OperasiDasar();
  /// Instance dari NotifikasiServis untuk menjadwalkan notifikasi.
  late final NotifikasiServis notifikasiServis;
  final PelangganOperasi _pelangganOperasi = PelangganOperasi();

  /// Konstruktor untuk `PelangganAktifOperasi`.
  PelangganAktifOperasi({final NotifikasiServis? notifikasiServis}) {
    this.notifikasiServis = notifikasiServis ?? NotifikasiServis();
    Log.info(
      'PelangganAktifOperasi diinisialisasi dengan NotifikasiServis: ${notifikasiServis != null ? "dari parameter" : "instance baru"}',
    );
  }

  /// Membuat [PelangganAktifModel] baru di database.
  Future<PelangganAktifModel> createPelangganAktif(
    final PelangganAktifModel pelangganAktif, {
    final bool dariServer = false,
  }) async {
    try {
      final idBaru = pelangganAktif.id.isEmpty ? uuid.v4() : pelangganAktif.id;
      final pelangganUntukDisimpan = pelangganAktif.copyWith(
        id: idBaru,
        diperbarui: DateTime.now().toUtc(), // diubah: simpan dalam UTC
      );

      Log.info(
        'Membuat pelanggan aktif baru - ID: $idBaru, ID Pelanggan: ${pelangganUntukDisimpan.idPelanggan}, ID Paket: ${pelangganUntukDisimpan.idPaket}, Berakhir: ${pelangganUntukDisimpan.tanggalBerakhir.toIso8601String()}',
      );

      await _operasiDasar.jalankanOperasiKompleks(
        (final txn) async {
          final data = pelangganUntukDisimpan.toSqlite();
          Log.info('Menyisipkan data pelanggan aktif ke tabel pelanggan_aktif');

          await txn.insert(
            'pelanggan_aktif',
            data,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        },
        dariServer: dariServer,
      );

      Log.info('Transaksi database berhasil. Menjadwalkan notifikasi...');

      await _jadwalkanNotifikasi(pelangganUntukDisimpan);

      Log.info(
        'Pelanggan aktif ID: $idBaru berhasil dibuat dan notifikasi dijadwalkan.',
      );
      return pelangganUntukDisimpan;
    } on Exception catch (e, st) {
      Log.error(
        'Gagal membuat pelanggan aktif - ID Pelanggan: ${pelangganAktif.idPelanggan}, ID Paket: ${pelangganAktif.idPaket}',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Mengambil semua pelanggan aktif (tidak diarsipkan).
  Future<List<PelangganAktifModel>> ambilSemuaPelangganAktif() async {
    try {
      final db = await dbHelper.database;
      Log.info(
        'Mengambil semua pelanggan aktif (isDeleted = 0) dari database lokal',
      );

      final List<Map<String, dynamic>> maps = await db.query(
        'pelanggan_aktif',
        where: 'isDeleted = ?',
        whereArgs: [0],
      );

      Log.info('Berhasil mengambil ${maps.length} pelanggan aktif');

      int jumlahMendekatiBerakhir = 0;
      final sekarang = DateTime.now().toUtc();
      final tigaHariLagi = sekarang.add(const Duration(days: 3));

      for (var map in maps) {
        final tanggalBerakhirInt = map['tanggal_berakhir'] as int? ?? 0;
        if (tanggalBerakhirInt > 0) {
          final tanggalBerakhir = DateTime.fromMillisecondsSinceEpoch(tanggalBerakhirInt, isUtc: true);
          if (tanggalBerakhir.isBefore(tigaHariLagi) &&
              tanggalBerakhir.isAfter(sekarang)) {
            jumlahMendekatiBerakhir++;
          }
        }
      }

      if (jumlahMendekatiBerakhir > 0) {
        Log.info(
          '$jumlahMendekatiBerakhir pelanggan aktif akan berakhir dalam 3 hari ke depan',
        );
      }

      return List.generate(
        maps.length,
        (final i) => PelangganAktifModel.fromSqlite(maps[i]),
      );
    } on Exception catch (e, st) {
      Log.error(
        'Gagal mengambil semua pelanggan aktif dari database lokal',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Mengambil [PelangganAktifModel] berdasarkan [id].
  Future<PelangganAktifModel?> ambilSatuPelangganAktif(final String id) async {
    try {
      final db = await dbHelper.database;
      Log.info('Mencari pelanggan aktif dengan ID: $id');

      final List<Map<String, dynamic>> maps = await db.query(
        'pelanggan_aktif',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        final pelangganAktif = PelangganAktifModel.fromSqlite(maps.first);
        Log.info(
          'Pelanggan aktif ID: $id ditemukan - ID Pelanggan: ${pelangganAktif.idPelanggan}, ID Paket: ${pelangganAktif.idPaket}',
        );
        return pelangganAktif;
      }

      Log.info('Pelanggan aktif ID: $id tidak ditemukan di database');
      return null;
    } on Exception catch (e, st) {
      Log.error(
        'Gagal mengambil pelanggan aktif ID: $id',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Memperbarui [PelangganAktifModel] yang ada di database.
  Future<PelangganAktifModel> updatePelangganAktif(
    final PelangganAktifModel pelangganAktif, {
    final bool dariServer = false,
  }) async {
    try {
      final pelangganUntukDisimpan = pelangganAktif.copyWith(
        diperbarui: DateTime.now().toUtc(), // diubah: simpan dalam UTC
      );

      Log.info(
        'Memperbarui pelanggan aktif ID: ${pelangganUntukDisimpan.id} - ID Pelanggan: ${pelangganUntukDisimpan.idPelanggan}, ID Paket: ${pelangganUntukDisimpan.idPaket}',
      );

      await _operasiDasar.jalankanOperasiKompleks(
        (final txn) async {
          final data = pelangganUntukDisimpan.toSqlite();
          Log.info(
            'Menjalankan update di tabel pelanggan_aktif dengan conflict replace',
          );

          await txn.update(
            'pelanggan_aktif',
            data,
            where: 'id = ?',
            whereArgs: [pelangganUntukDisimpan.id],
          );
        },
        dariServer: dariServer,
      );

      Log.info('Update database berhasil. Menjadwalkan ulang notifikasi...');
      await _jadwalkanNotifikasi(pelangganUntukDisimpan);

      Log.info(
        'Pelanggan aktif ID: ${pelangganUntukDisimpan.id} berhasil diperbarui',
      );
      return pelangganUntukDisimpan;
    } on Exception catch (e, st) {
      Log.error(
        'Gagal memperbarui pelanggan aktif ID: ${pelangganAktif.id}',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Menjadwalkan notifikasi untuk [PelangganAktifModel].
  Future<void> _jadwalkanNotifikasi(final PelangganAktifModel pelangganAktif) async {
    try {
      Log.info(
        'Menjadwalkan notifikasi untuk pelanggan aktif ID: ${pelangganAktif.id}',
      );
      Log.info(
        'Tanggal berakhir: ${pelangganAktif.tanggalBerakhir.toIso8601String()}',
      );

      final pelanggan = await _pelangganOperasi.getPelangganById(
        pelangganAktif.idPelanggan,
      );
      final namaPelanggan = pelanggan?.nama ?? 'Tanpa Nama';
      Log.info('Nama pelanggan: $namaPelanggan');

      // Batalkan notifikasi lama
      Log.info(
        'Membatalkan notifikasi lama untuk hash ID: ${pelangganAktif.id.hashCode}, ${pelangganAktif.id.hashCode + 1}, ${pelangganAktif.id.hashCode + 2}',
      );
      await notifikasiServis.batalNotifikasi(pelangganAktif.id.hashCode);
      await notifikasiServis.batalNotifikasi((pelangganAktif.id.hashCode + 1));
      await notifikasiServis.batalNotifikasi((pelangganAktif.id.hashCode + 2));

      // --- 1. NOTIFIKASI TEPAT SAAT BERAKHIR ---
      final jadwalTepatWaktu = pelangganAktif.tanggalBerakhir;
      if (jadwalTepatWaktu.isAfter(DateTime.now())) {
        await notifikasiServis.jadwalNotifikasi(
          id: (pelangganAktif.id.hashCode + 2),
          title: 'Masa Aktif Habis!',
          body: 'Paket WiFi untuk $namaPelanggan telah berakhir sekarang.',
          jadwal: jadwalTepatWaktu,
        );
        Log.info(
          'Notifikasi TEPAT WAKTU dijadwalkan untuk ${jadwalTepatWaktu.toIso8601String()} (${jadwalTepatWaktu.difference(DateTime.now()).inHours} jam dari sekarang)',
        );
      } else {
        Log.info(
          'Notifikasi tepat waktu dilewati karena tanggal berakhir ${jadwalTepatWaktu.toIso8601String()} sudah lewat (${DateTime.now().difference(jadwalTepatWaktu).inHours} jam yang lalu)',
        );
      }

      // --- 2. NOTIFIKASI H-1 ---
      final jadwalNotifikasiH1 = pelangganAktif.tanggalBerakhir.subtract(
        const Duration(days: 1),
      );
      if (jadwalNotifikasiH1.isAfter(DateTime.now())) {
        await notifikasiServis.jadwalNotifikasi(
          id: pelangganAktif.id.hashCode,
          title: 'Paket Akan Segera Berakhir',
          body: 'Paket untuk pelanggan $namaPelanggan akan berakhir besok.',
          jadwal: jadwalNotifikasiH1,
        );
        Log.info(
          'Notifikasi H-1 dijadwalkan untuk ${jadwalNotifikasiH1.toIso8601String()} (${jadwalNotifikasiH1.difference(DateTime.now()).inHours} jam dari sekarang)',
        );
      } else {
        Log.info(
          'Notifikasi H-1 dilewati karena jadwal ${jadwalNotifikasiH1.toIso8601String()} sudah lewat',
        );
      }

      // --- 3. NOTIFIKASI H-3 ---
      final jadwalNotifikasiH3 = pelangganAktif.tanggalBerakhir.subtract(
        const Duration(days: 3),
      );
      if (jadwalNotifikasiH3.isAfter(DateTime.now())) {
        await notifikasiServis.jadwalNotifikasi(
          id: (pelangganAktif.id.hashCode + 1),
          title: 'Pengingat Paket',
          body:
              'Paket untuk pelanggan $namaPelanggan akan berakhir dalam 3 hari.',
          jadwal: jadwalNotifikasiH3,
        );
        Log.info(
          'Notifikasi H-3 dijadwalkan untuk ${jadwalNotifikasiH3.toIso8601String()} (${jadwalNotifikasiH3.difference(DateTime.now()).inHours} jam dari sekarang)',
        );
      } else {
        Log.info(
          'Notifikasi H-3 dilewati karena jadwal ${jadwalNotifikasiH3.toIso8601String()} sudah lewat',
        );
      }

      Log.info(
        'Penjadwalan notifikasi selesai untuk pelanggan aktif ID: ${pelangganAktif.id}',
      );
    } on Exception catch (e, st) {
      Log.error(
        'Gagal menjadwalkan notifikasi untuk pelanggan aktif ID: ${pelangganAktif.id}',
        e: e,
        st: st,
      );
    }
  }

  /// Menyisipkan atau memperbarui sekumpulan [PelangganAktifModel] dalam satu batch.
  Future<void> sisipkanAtauPerbaruiBatch(
    final List<PelangganAktifModel> items, {
    final bool dariServer = false,
  }) async {
    try {
      Log.info('Memproses batch ${items.length} pelanggan aktif');

      final data = items
          .map(
            (final item) =>
                item.copyWith(diperbarui: DateTime.now().toUtc()).toSqlite(),
          )
          .toList();
      Log.info('Mengonversi ${data.length} item ke format SQLite');

      await _operasiDasar.sisipkanAtauPerbaruiBatch(
        'pelanggan_aktif',
        data,
        dariServer: dariServer,
      );

      Log.info('Batch ${items.length} pelanggan aktif berhasil diproses');
    } on Exception catch (e, st) {
      Log.error(
        'Gagal memproses batch ${items.length} pelanggan aktif',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Mengarsipkan [PelangganAktifModel] berdasarkan [id].
  Future<void> arsipkanPelangganAktif(
    final String id, {
    final bool dariServer = false,
  }) async {
    try {
      Log.info('Mengarsipkan pelanggan aktif ID: $id');

      final pelangganAktif = await ambilSatuPelangganAktif(id);
      if (pelangganAktif == null) {
        Log.info(
          'Pelanggan aktif ID: $id tidak ditemukan, tidak dapat mengarsipkan',
        );
        return;
      }

      Log.info(
        'Data sebelum arsip - ID Pelanggan: ${pelangganAktif.idPelanggan}, ID Paket: ${pelangganAktif.idPaket}, Berakhir: ${pelangganAktif.tanggalBerakhir.toIso8601String()}',
      );

      await _operasiDasar.jalankanOperasiKompleks(
        (final txn) async {
          final pelangganDiarsipkan = pelangganAktif.copyWith(
            isDeleted: true,
            diarsipkan: DateTime.now().toUtc(), // diubah: simpan dalam UTC
          );

          Log.info(
            'Menandai isDeleted=true, diarsipkan=${pelangganDiarsipkan.diarsipkan?.toIso8601String()}',
          );
          await txn.update(
            'pelanggan_aktif',
            pelangganDiarsipkan.toSqlite(),
            where: 'id = ?',
            whereArgs: [id],
          );

          Log.info('Membatalkan notifikasi terkait...');
          await notifikasiServis.batalNotifikasi(id.hashCode);
          await notifikasiServis.batalNotifikasi((id.hashCode + 1));
          await notifikasiServis.batalNotifikasi((id.hashCode + 2));
        },
        dariServer: dariServer,
      );

      Log.info(
        'Pelanggan aktif ID: $id berhasil diarsipkan dengan notifikasi dibatalkan',
      );
    } on Exception catch (e, st) {
      Log.error(
        'Gagal mengarsipkan pelanggan aktif ID: $id',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Menghapus permanen pelanggan yang sudah diarsipkan lebih dari 30 hari.
  Future<void> hapusPermanenPelangganYangDiArsipkan({
    final bool dariServer = false,
  }) async {
    try {
      await _operasiDasar.jalankanOperasiKompleks(
        (final txn) async {
          final batasWaktu = DateTime.now().toUtc().subtract(
                const Duration(days: 30),
              );
          Log.info(
            'Mencari pelanggan diarsipkan sebelum ${batasWaktu.toIso8601String()} (30 hari yang lalu)',
          );

          final List<Map<String, dynamic>> pelangganKadaluarsa =
              await txn.query(
            'pelanggan_aktif',
            where: 'diarsipkan IS NOT NULL AND diarsipkan < ?',
            whereArgs: [
              batasWaktu.millisecondsSinceEpoch,
            ],
          );

          if (pelangganKadaluarsa.isEmpty) {
            Log.info('Tidak ada pelanggan aktif diarsipkan lebih dari 30 hari');
            return;
          }

          final idsUntukDihapus =
              pelangganKadaluarsa.map((final map) => map['id'] as String).toList();

          Log.info(
            'Ditemukan ${idsUntukDihapus.length} pelanggan diarsipkan kadaluarsa, menghapus permanen...',
          );

          final count = await txn.delete(
            'pelanggan_aktif',
            where:
                'id IN (${List.filled(idsUntukDihapus.length, '?').join(',')})',
            whereArgs: idsUntukDihapus,
          );

          Log.info(
            '$count pelanggan aktif diarsipkan lebih dari 30 hari telah dihapus permanen',
          );
        },
        dariServer: dariServer,
      );
    } on Exception catch (e, st) {
      Log.error(
        'Gagal menghapus permanen pelanggan diarsipkan',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Mengarsipkan pelanggan yang sudah kadaluarsa.
  Future<int> arsipkanPelangganKadaluarsa({final bool dariServer = false}) async {
    try {
      Log.info('Memeriksa pelanggan kadaluarsa untuk diarsipkan');
      final db = await dbHelper.database;
      final sekarang = DateTime.now().toUtc();

      final List<Map<String, dynamic>> pelangganKadaluarsa = await db.query(
        'pelanggan_aktif',
        where: 'tanggal_berakhir < ? AND isDeleted = 0',
        whereArgs: [
          sekarang.millisecondsSinceEpoch,
        ],
      );

      if (pelangganKadaluarsa.isEmpty) {
        Log.info('Tidak ada pelanggan kadaluarsa yang perlu diarsipkan');
        return 0;
      }

      final idsToArchive =
          pelangganKadaluarsa.map((final p) => p['id'] as String).toList();
      Log.info(
        'Ditemukan ${idsToArchive.length} pelanggan kadaluarsa (berakhir sebelum ${sekarang.toIso8601String()})',
      );

      await _operasiDasar.jalankanOperasiKompleks(
        (final txn) async {
          final now = DateTime.now().toUtc().millisecondsSinceEpoch;
          Log.info(
            'Menandai ${idsToArchive.length} pelanggan sebagai isDeleted=1, diarsipkan=$now',
          );

          await txn.update(
            'pelanggan_aktif',
            {'isDeleted': 1, 'diarsipkan': now, 'diperbarui': now},
            where: 'id IN (${List.filled(idsToArchive.length, '?').join(',')})',
            whereArgs: idsToArchive,
          );

          Log.info(
            'Membatalkan notifikasi untuk ${idsToArchive.length} pelanggan kadaluarsa...',
          );
          for (final id in idsToArchive) {
            await notifikasiServis.batalNotifikasi(id.hashCode);
            await notifikasiServis.batalNotifikasi((id.hashCode + 1));
            await notifikasiServis.batalNotifikasi((id.hashCode + 2));
          }
        },
        dariServer: dariServer,
      );

      Log.info('${idsToArchive.length} pelanggan kadaluarsa telah diarsipkan');
      return idsToArchive.length;
    } on Exception catch (e, st) {
      Log.error(
        'Gagal mengarsipkan pelanggan kadaluarsa',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Mengarsipkan semua pelanggan aktif.
  Future<int> arsipkanSemuaPelangganAktif({final bool dariServer = false}) async {
    try {
      Log.info('Mengarsipkan SEMUA pelanggan aktif');
      final semuaPelanggan = await ambilSemuaPelangganAktif();

      if (semuaPelanggan.isEmpty) {
        Log.info('Tidak ada pelanggan aktif untuk diarsipkan');
        return 0;
      }

      final idsToArchive = semuaPelanggan.map((final p) => p.id).toList();
      Log.info('Mengarsipkan ${idsToArchive.length} pelanggan aktif');

      await _operasiDasar.jalankanOperasiKompleks(
        (final txn) async {
          final now = DateTime.now()
              .toUtc()
              .millisecondsSinceEpoch; // diubah: simpan dalam UTC
          Log.info(
            'Menandai ${idsToArchive.length} pelanggan sebagai isDeleted=1, diarsipkan=$now',
          );

          await txn.update(
            'pelanggan_aktif',
            {'isDeleted': 1, 'diarsipkan': now, 'diperbarui': now},
            where: 'id IN (${List.filled(idsToArchive.length, '?').join(',')})',
            whereArgs: idsToArchive,
          );

          Log.info(
            'Membatalkan notifikasi untuk ${idsToArchive.length} pelanggan...',
          );
          for (final id in idsToArchive) {
            await notifikasiServis.batalNotifikasi(id.hashCode);
            await notifikasiServis.batalNotifikasi((id.hashCode + 1));
            await notifikasiServis.batalNotifikasi((id.hashCode + 2));
          }
        },
        dariServer: dariServer,
      );

      Log.info('${idsToArchive.length} pelanggan aktif telah diarsipkan');
      return idsToArchive.length;
    } on Exception catch (e, st) {
      Log.error(
        'Gagal mengarsipkan semua pelanggan aktif',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Mengambil beberapa [PelangganAktifModel] berdasarkan daftar [ids].
  Future<List<PelangganAktifModel>> getPelangganAktifByIds(
    final List<String> ids,
  ) async {
    try {
      if (ids.isEmpty) {
        Log.info(
          'getPelangganAktifByIds dipanggil dengan list ID kosong, mengembalikan list kosong',
        );
        return [];
      }

      final db = await dbHelper.database;
      Log.info('Mencari ${ids.length} pelanggan aktif berdasarkan IDs');

      final placeholders = List.filled(ids.length, '?').join(',');
      final List<Map<String, dynamic>> maps = await db.query(
        'pelanggan_aktif',
        where: 'id IN ($placeholders)',
        whereArgs: ids,
      );

      Log.info(
        'Ditemukan ${maps.length} dari ${ids.length} pelanggan aktif yang dicari (${ids.length - maps.length} tidak ditemukan)',
      );

      return List.generate(maps.length, (final i) {
        return PelangganAktifModel.fromSqlite(maps[i]);
      });
    } on Exception catch (e, st) {
      Log.error(
        'Gagal mengambil pelanggan aktif berdasarkan IDs (${ids.length} ID)',
        e: e,
        st: st,
      );
      rethrow;
    }
  }
}
