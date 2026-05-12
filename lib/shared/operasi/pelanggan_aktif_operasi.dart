// path: lib/data/operasi/pelanggan_aktif_operasi.dart
// diubah: Menggunakan UTC untuk perbandingan waktu di arsipkanPelangganKadaluarsa dan hapusPermanenPelangganYangDiArsipkan untuk mencegah bug zona waktu.
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import 'package:admin_wifi/data/operasi/operasi_dasar.dart';
import 'package:admin_wifi/data/operasi/pelanggan_operasi.dart';
import 'package:admin_wifi/debug/log.dart';
import 'package:admin_wifi/services/notifikasi/notifikasi_servis.dart';
import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/model/pelanggan_aktif_model.dart';

const uuid = Uuid();

class PelangganAktifOperasi {
  final dbHelper = DatabaseHelper.instance;
  final OperasiDasar _operasiDasar = OperasiDasar();
  late final NotifikasiServis notifikasiServis;
  final PelangganOperasi _pelangganOperasi = PelangganOperasi();

  PelangganAktifOperasi({NotifikasiServis? notifikasiServis}) {
    this.notifikasiServis = notifikasiServis ?? NotifikasiServis();
    Log.info(
      'PelangganAktifOperasi diinisialisasi dengan NotifikasiServis: ${notifikasiServis != null ? "dari parameter" : "instance baru"}',
    );
  }

  Future<PelangganAktifModel> createPelangganAktif(
    PelangganAktifModel pelangganAktif,
  ) async {
    try {
      final idBaru = pelangganAktif.id.isEmpty ? uuid.v4() : pelangganAktif.id;
      final pelangganUntukDisimpan = pelangganAktif.copyWith(
        id: idBaru,
        diperbarui: DateTime.now().toUtc(), // diubah: simpan dalam UTC
      );

      Log.info(
        'Membuat pelanggan aktif baru - ID: $idBaru, ID Pelanggan: ${pelangganUntukDisimpan.idPelanggan}, ID Paket: ${pelangganUntukDisimpan.idPaket}, Berakhir: ${pelangganUntukDisimpan.tanggalBerakhir.toIso8601String()}',
      );

      await _operasiDasar.jalankanOperasiKompleks((txn) async {
        final data = pelangganUntukDisimpan.toSqlite();
        Log.info('Menyisipkan data pelanggan aktif ke tabel pelanggan_aktif');

        await txn.insert(
          'pelanggan_aktif',
          data,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });

      Log.info('Transaksi database berhasil. Menjadwalkan notifikasi...');

      await _jadwalkanNotifikasi(pelangganUntukDisimpan);

      Log.info(
        'Pelanggan aktif ID: $idBaru berhasil dibuat dan notifikasi dijadwalkan.',
      );
      return pelangganUntukDisimpan;
    } catch (e, stackTrace) {
      Log.error(
        'Gagal membuat pelanggan aktif - ID Pelanggan: ${pelangganAktif.idPelanggan}, ID Paket: ${pelangganAktif.idPaket}',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

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
      final sekarang = DateTime.now();
      final tigaHariLagi = sekarang.add(const Duration(days: 3));

      for (var map in maps) {
        final tanggalBerakhirString = map['tanggal_berakhir'] as String? ?? '';
        if (tanggalBerakhirString.isNotEmpty) {
          final tanggalBerakhir = DateTime.parse(tanggalBerakhirString);
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
        (i) => PelangganAktifModel.fromSqlite(maps[i]),
      );
    } catch (e, stackTrace) {
      Log.error(
        'Gagal mengambil semua pelanggan aktif dari database lokal',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<PelangganAktifModel?> ambilSatuPelangganAktif(String id) async {
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
    } catch (e, stackTrace) {
      Log.error(
        'Gagal mengambil pelanggan aktif ID: $id',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<PelangganAktifModel> updatePelangganAktif(
    PelangganAktifModel pelangganAktif,
  ) async {
    try {
      final pelangganUntukDisimpan = pelangganAktif.copyWith(
        diperbarui: DateTime.now().toUtc(), // diubah: simpan dalam UTC
      );

      Log.info(
        'Memperbarui pelanggan aktif ID: ${pelangganUntukDisimpan.id} - ID Pelanggan: ${pelangganUntukDisimpan.idPelanggan}, ID Paket: ${pelangganUntukDisimpan.idPaket}',
      );

      await _operasiDasar.jalankanOperasiKompleks((txn) async {
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
      });

      Log.info('Update database berhasil. Menjadwalkan ulang notifikasi...');
      await _jadwalkanNotifikasi(pelangganUntukDisimpan);

      Log.info(
        'Pelanggan aktif ID: ${pelangganUntukDisimpan.id} berhasil diperbarui',
      );
      return pelangganUntukDisimpan;
    } catch (e, stackTrace) {
      Log.error(
        'Gagal memperbarui pelanggan aktif ID: ${pelangganAktif.id}',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> _jadwalkanNotifikasi(PelangganAktifModel pelangganAktif) async {
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
    } catch (e, stackTrace) {
      Log.error(
        'Gagal menjadwalkan notifikasi untuk pelanggan aktif ID: ${pelangganAktif.id}',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> sisipkanAtauPerbaruiBatch(
    List<PelangganAktifModel> items,
  ) async {
    try {
      Log.info('Memproses batch ${items.length} pelanggan aktif');

      final data = items.map((item) => item.toSqlite()).toList();
      Log.info('Mengonversi ${data.length} item ke format SQLite');

      await _operasiDasar.sisipkanAtauPerbaruiBatch('pelanggan_aktif', data);

      Log.info('Batch ${items.length} pelanggan aktif berhasil diproses');
    } catch (e, stackTrace) {
      Log.error(
        'Gagal memproses batch ${items.length} pelanggan aktif',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> arsipkanPelangganAktif(String id) async {
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

      await _operasiDasar.jalankanOperasiKompleks((txn) async {
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
      });

      Log.info(
        'Pelanggan aktif ID: $id berhasil diarsipkan dengan notifikasi dibatalkan',
      );
    } catch (e, stackTrace) {
      Log.error(
        'Gagal mengarsipkan pelanggan aktif ID: $id',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> hapusPermanenPelangganYangDiArsipkan() async {
    try {
      await _operasiDasar.jalankanOperasiKompleks((txn) async {
        // diubah: Menggunakan UTC untuk konsistensi
        final batasWaktu = DateTime.now().toUtc().subtract(
          const Duration(days: 30),
        );
        Log.info(
          'Mencari pelanggan diarsipkan sebelum ${batasWaktu.toIso8601String()} (30 hari yang lalu)',
        );

        final List<Map<String, dynamic>> pelangganKadaluarsa = await txn.query(
          'pelanggan_aktif',
          where: 'diarsipkan IS NOT NULL AND diarsipkan < ?',
          whereArgs: [
            batasWaktu.toIso8601String(),
          ], // diubah: Membandingkan dengan string UTC
        );

        if (pelangganKadaluarsa.isEmpty) {
          Log.info('Tidak ada pelanggan aktif diarsipkan lebih dari 30 hari');
          return;
        }

        final idsUntukDihapus = pelangganKadaluarsa
            .map((map) => map['id'] as String)
            .toList();

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
      });
    } catch (e, stackTrace) {
      Log.error(
        'Gagal menghapus permanen pelanggan diarsipkan',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> hapusSemuaPelangganAktif() async {
    try {
      Log.info('PERINGATAN: Menghapus SEMUA pelanggan aktif secara permanen');

      await _operasiDasar.jalankanOperasiKompleks((txn) async {
        await txn.delete('pelanggan_aktif');
        Log.info('Semua data di tabel pelanggan_aktif telah dihapus permanen');
      });

      Log.info('Operasi hapus semua pelanggan aktif selesai');
    } catch (e, stackTrace) {
      Log.error(
        'Gagal menghapus semua pelanggan aktif',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<int> arsipkanPelangganKadaluarsa() async {
    try {
      Log.info('Memeriksa pelanggan kadaluarsa untuk diarsipkan');
      final db = await dbHelper.database;
      final sekarang = DateTime.now()
          .toUtc(); // diubah: Menggunakan UTC untuk konsistensi

      final List<Map<String, dynamic>> pelangganKadaluarsa = await db.query(
        'pelanggan_aktif',
        where: 'tanggal_berakhir < ? AND isDeleted = 0',
        whereArgs: [
          sekarang.toIso8601String(),
        ], // diubah: Membandingkan dengan string UTC
      );

      if (pelangganKadaluarsa.isEmpty) {
        Log.info('Tidak ada pelanggan kadaluarsa yang perlu diarsipkan');
        return 0;
      }

      final idsToArchive = pelangganKadaluarsa
          .map((p) => p['id'] as String)
          .toList();
      Log.info(
        'Ditemukan ${idsToArchive.length} pelanggan kadaluarsa (berakhir sebelum ${sekarang.toIso8601String()})',
      );

      await _operasiDasar.jalankanOperasiKompleks((txn) async {
        final now = DateTime.now()
            .toUtc()
            .toIso8601String(); // diubah: simpan dalam UTC
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
      });

      Log.info('${idsToArchive.length} pelanggan kadaluarsa telah diarsipkan');
      return idsToArchive.length;
    } catch (e, stackTrace) {
      Log.error(
        'Gagal mengarsipkan pelanggan kadaluarsa',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<int> arsipkanSemuaPelangganAktif() async {
    try {
      Log.info('Mengarsipkan SEMUA pelanggan aktif');
      final semuaPelanggan = await ambilSemuaPelangganAktif();

      if (semuaPelanggan.isEmpty) {
        Log.info('Tidak ada pelanggan aktif untuk diarsipkan');
        return 0;
      }

      final idsToArchive = semuaPelanggan.map((p) => p.id).toList();
      Log.info('Mengarsipkan ${idsToArchive.length} pelanggan aktif');

      await _operasiDasar.jalankanOperasiKompleks((txn) async {
        final now = DateTime.now()
            .toUtc()
            .toIso8601String(); // diubah: simpan dalam UTC
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
      });

      Log.info('${idsToArchive.length} pelanggan aktif telah diarsipkan');
      return idsToArchive.length;
    } catch (e, stackTrace) {
      Log.error(
        'Gagal mengarsipkan semua pelanggan aktif',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<List<PelangganAktifModel>> getPelangganAktifByIds(
    List<String> ids,
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

      return List.generate(maps.length, (i) {
        return PelangganAktifModel.fromSqlite(maps[i]);
      });
    } catch (e, stackTrace) {
      Log.error(
        'Gagal mengambil pelanggan aktif berdasarkan IDs (${ids.length} ID)',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
