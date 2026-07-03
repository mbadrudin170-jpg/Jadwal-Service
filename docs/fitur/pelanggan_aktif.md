# Dokumentasi Fitur: pelanggan_aktif

## Daftar file

lib/fitur/pelanggan_aktif/helper/pengurut_pelanggan_aktif.dart
lib/fitur/pelanggan_aktif/model/detail_pelanggan_aktif_model.dart
lib/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart
lib/fitur/pelanggan_aktif/operasi/pelanggan_aktif_op_firebase.dart
lib/fitur/pelanggan_aktif/operasi/pelanggan_aktif_op_sqlite.dart
lib/fitur/pelanggan_aktif/page/detail_pelanggan_aktif.dart
lib/fitur/pelanggan_aktif/page/form_pelanggan_aktif.dart
lib/fitur/pelanggan_aktif/page/pelanggan_aktif_page.dart
lib/fitur/pelanggan_aktif/provider/pelanggan_aktif_provider.dart

## Isi file

### File: `lib/fitur/pelanggan_aktif/helper/pengurut_pelanggan_aktif.dart`
```dart
// path lib/fitur/pelanggan_aktif/helper/pengurut_pelanggan_aktif.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/shared/export/model.dart';

part 'pengurut_pelanggan_aktif.g.dart';

enum UrutanPelangganAktifEnum {
  berakhirHariIni('Berakhir Hari Ini'),
  terbaru('Terbaru'),
  terlama('Terlama'),
  tanggalMulai('Tanggal Mulai'),
  tanggalBerakhir('Tanggal Berakhir'),
  lunas('Lunas'),
  belumLunas('Belum Lunas'),
  namaAZ('Nama A-Z'),
  namaZA('Nama Z-A');

  const UrutanPelangganAktifEnum(this.teks);
  final String teks;
}

@riverpod
class UrutanPelangganAktifState extends _$UrutanPelangganAktifState {
  @override
  UrutanPelangganAktifEnum build() {
    return UrutanPelangganAktifEnum.berakhirHariIni;
  }

  void ubahUrutan(UrutanPelangganAktifEnum urutanBaru) {
    state = urutanBaru;
  }
}

int _compareNullableDates(DateTime? a, DateTime? b, {bool ascending = true}) {
  if (a == null && b == null) return 0;
  if (a == null) return 1; // null dianggap paling besar/lama
  if (b == null) return -1; // non-null dianggap lebih kecil/baru
  return ascending ? a.compareTo(b) : b.compareTo(a);
}

List<DetailPelangganAktifModel> urutkanPelangganAktif(
  List<DetailPelangganAktifModel> data,
  UrutanPelangganAktifEnum sortBy,
) {
  final sorted = List<DetailPelangganAktifModel>.from(data);
  final sekarang = DateTime.now();

  sorted.sort((a, b) {
    switch (sortBy) {
      case UrutanPelangganAktifEnum.berakhirHariIni:
        final sisaHariA = a.pelangganAktif.tanggalBerakhir
            .difference(sekarang)
            .inMilliseconds;
        final sisaHariB = b.pelangganAktif.tanggalBerakhir
            .difference(sekarang)
            .inMilliseconds;

        final lewatA = sisaHariA < 0;
        final lewatB = sisaHariB < 0;

        if (!lewatA && lewatB) return -1;
        if (lewatA && !lewatB) return 1;
        if (!lewatA) {
          return sisaHariA.compareTo(sisaHariB);
        }
        return sisaHariB.compareTo(sisaHariA);

      case UrutanPelangganAktifEnum.terbaru:
        return _compareNullableDates(
          a.pelangganAktif.diperbaruiPada,
          b.pelangganAktif.diperbaruiPada,
          ascending: false,
        );

      case UrutanPelangganAktifEnum.terlama:
        return _compareNullableDates(
          a.pelangganAktif.diperbaruiPada,
          b.pelangganAktif.diperbaruiPada,
        );

      case UrutanPelangganAktifEnum.tanggalMulai:
        return a.pelangganAktif.tanggalMulai.compareTo(
          b.pelangganAktif.tanggalMulai,
        );

      case UrutanPelangganAktifEnum.tanggalBerakhir:
        return b.pelangganAktif.tanggalBerakhir.compareTo(
          a.pelangganAktif.tanggalBerakhir,
        );

      case UrutanPelangganAktifEnum.lunas:
        return a.pelangganAktif.status.index.compareTo(
          b.pelangganAktif.status.index,
        );

      case UrutanPelangganAktifEnum.belumLunas:
        return b.pelangganAktif.status.index.compareTo(
          a.pelangganAktif.status.index,
        );

      case UrutanPelangganAktifEnum.namaAZ:
        return a.namaPelanggan.toLowerCase().compareTo(
          b.namaPelanggan.toLowerCase(),
        );

      case UrutanPelangganAktifEnum.namaZA:
        return b.namaPelanggan.toLowerCase().compareTo(
          a.namaPelanggan.toLowerCase(),
        );
    }
  });
  return sorted;
}

String ambilTeksUrutanPelangganAktif(UrutanPelangganAktifEnum option) =>
    option.teks;
```

### File: `lib/fitur/pelanggan_aktif/model/detail_pelanggan_aktif_model.dart`
```dart
// path lib/fitur/pelanggan_aktif/model/detail_pelanggan_aktif_model.dart

import 'package:wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';

class DetailPelangganAktifModel {
  final PelangganAktifModel pelangganAktif;

  final String namaPelanggan;

  final String namaPaket;

  DetailPelangganAktifModel({
    required this.pelangganAktif,
    required this.namaPelanggan,
    required this.namaPaket,
  });
}
```

### File: `lib/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart`
```dart
// path: lib/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/utils/parser_util.dart';

part 'pelanggan_aktif_model.freezed.dart';

@freezed
abstract class PelangganAktifModel with _$PelangganAktifModel implements HasId {
  const PelangganAktifModel._();
  const factory PelangganAktifModel({
    required String id,
    required String idPelanggan,
    required String idPaket,
    required String idTransaksi,
    required DateTime tanggalMulai,
    required DateTime tanggalBerakhir,
    required StatusPembayaran status,
    required DateTime? diperbaruiPada,
    @Default(false) bool diHapus,
    DateTime? diarsipkanPada,
  }) = _PelangganAktifModel;

  factory PelangganAktifModel.fromSqlite(Map<String, dynamic> map) {
    try {
      final tanggalMulai = ParserUtil.parseDateTime(
        map[NamaKolom.tanggalMulai],
      );
      final tanggalBerakhir = ParserUtil.parseDateTime(
        map[NamaKolom.tanggalBerakhir],
      );

      if (tanggalMulai == null) {
        throw ArgumentError.notNull('startDate from SQLite');
      }
      if (tanggalBerakhir == null) {
        throw ArgumentError.notNull('endDate from SQLite');
      }
      final model = PelangganAktifModel(
        id: map[NamaKolom.id] as String,
        idPelanggan: map[NamaKolom.idPelanggan] as String? ?? '',
        idPaket: map[NamaKolom.idPaket] as String? ?? '',
        idTransaksi: map[NamaKolom.idTransaksi] as String? ?? '',
        tanggalMulai: tanggalMulai,
        tanggalBerakhir: tanggalBerakhir,
        status:
            ParserUtil.safeParseEnum(
              StatusPembayaran.values,
              map[NamaKolom.status],
            ) ??
            StatusPembayaran.paid,
        diperbaruiPada: ParserUtil.parseDateTime(map[NamaKolom.diperbaruiPada]),
        diHapus: ParserUtil.parseBool(map[NamaKolom.dihapus]),
        diarsipkanPada: ParserUtil.parseDateTime(map[NamaKolom.diarsipkanPada]),
      );
      Log.info('PelangganAktifModel loaded from SQLite: ${model.id}');
      return model;
    } catch (e, s) {
      Log.error('Failed to parse from SQLite: $map', e: e, s: s);
      rethrow;
    }
  }

  Map<String, dynamic> toSqlite() {
    return {
      NamaKolom.id: id,
      NamaKolom.idPelanggan: idPelanggan,
      NamaKolom.idPaket: idPaket,
      NamaKolom.idTransaksi: idTransaksi,
      NamaKolom.tanggalMulai: tanggalMulai.millisecondsSinceEpoch,
      NamaKolom.tanggalBerakhir: tanggalBerakhir.millisecondsSinceEpoch,
      NamaKolom.status: status.name,
      NamaKolom.diperbaruiPada:
          (diperbaruiPada ?? DateTime.now()).millisecondsSinceEpoch,
      NamaKolom.dihapus: diHapus ? 1 : 0,
      NamaKolom.diarsipkanPada: diarsipkanPada?.millisecondsSinceEpoch,
    };
  }

  factory PelangganAktifModel.fromFirebase(
    String id,
    Map<String, dynamic> data,
  ) {
    try {
      final tanggalMulai = ParserUtil.parseDateTime(
        data[NamaKolom.tanggalMulai],
      );
      final tanggalBerakhir = ParserUtil.parseDateTime(
        data[NamaKolom.tanggalBerakhir],
      );

      if (tanggalMulai == null) {
        throw ArgumentError.notNull('startDate from Firebase');
      }
      if (tanggalBerakhir == null) {
        throw ArgumentError.notNull('endDate from Firebase');
      }

      final model = PelangganAktifModel(
        id: id,
        idPelanggan: data[NamaKolom.idPelanggan] as String? ?? '',
        idPaket: data[NamaKolom.idPaket] as String? ?? '',
        idTransaksi: data[NamaKolom.idTransaksi] as String? ?? '',
        tanggalMulai: tanggalMulai,
        tanggalBerakhir: tanggalBerakhir,
        status:
            ParserUtil.safeParseEnum(
              StatusPembayaran.values,
              data[NamaKolom.status],
            ) ??
            StatusPembayaran.paid,
        diperbaruiPada: ParserUtil.parseDateTime(
          data[NamaKolom.diperbaruiPada],
        ),
        diHapus: ParserUtil.parseBool(data[NamaKolom.dihapus]),
        diarsipkanPada: ParserUtil.parseDateTime(
          data[NamaKolom.diarsipkanPada],
        ),
      );
      Log.info('PelangganAktifModel loaded from Firebase: ${model.id}');
      return model;
    } catch (e, stack) {
      Log.error('Failed to parse from Firebase: $data', e: e, s: stack);
      rethrow;
    }
  }

  Map<String, dynamic> toFirebase() {
    Log.info('Preparing toFirebase for PelangganAktifModel $id');
    return {
      NamaKolom.id: id,
      NamaKolom.idPelanggan: idPelanggan,
      NamaKolom.idPaket: idPaket,
      NamaKolom.idTransaksi: idTransaksi,
      NamaKolom.tanggalMulai: Timestamp.fromDate(tanggalMulai),
      NamaKolom.tanggalBerakhir: Timestamp.fromDate(tanggalBerakhir),
      NamaKolom.status: status.name,
      NamaKolom.dihapus: diHapus,
      NamaKolom.diperbaruiPada: Timestamp.fromDate(
        (diperbaruiPada ?? DateTime.now()),
      ),
      NamaKolom.diarsipkanPada: diarsipkanPada != null
          ? Timestamp.fromDate(diarsipkanPada!)
          : null,
    };
  }
}
```

### File: `lib/fitur/pelanggan_aktif/operasi/pelanggan_aktif_op_firebase.dart`
```dart
// path lib/fitur/pelanggan_aktif/operasi/pelanggan_aktif_op_firebase.dart

import 'package:wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/firebase_operasi/base_op_firebase.dart';

class PelangganAktifOpFirebase extends BaseOpFirebase {
  final BaseOpFirebase _baseOp;
  final String _namaKoleksi = NamaTabel.pelangganAktif;

  PelangganAktifOpFirebase({required BaseOpFirebase baseOp})
    : _baseOp = baseOp {
    Log.info('OrderOpFirebase diinisialisasi.');
  }

  /// 1. Menambahkan pesanan baru
  Future<void> tambahPelangganAktif(PelangganAktifModel pelangganAktif) async {
    Log.info('Menambahkan pesanan baru: ${pelangganAktif.id}');
    await _baseOp.sisipkan(
      _namaKoleksi,
      pelangganAktif.id,
      pelangganAktif.toFirebase(),
    );
  }
}
```

### File: `lib/fitur/pelanggan_aktif/operasi/pelanggan_aktif_op_sqlite.dart`
```dart
// path: lib/fitur/pelanggan_aktif/operasi/pelanggan_aktif_op_sqlite.dart

import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/notifikasi/layanan_notifikasi.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_sqlite.dart';
import 'package:wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_sqlite.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_op_sqlite.dart';

class PelangganAktifOpSqlite {
  final SqliteDatabase sqliteDb;
  final BaseOpSqlite _baseOpSqlite;
  final LayananNotifikasi _layananNotifikasi;
  final PelangganOpSqlite _pelangganOpSqlite;
  final TransaksiOpSqlite _transaksiOpSqlite;
  final String _tabelPelangganAktif = NamaTabel.pelangganAktif;
  final String _tabelPelanggan = NamaTabel.pelanggan;
  final String _tabelPaket = NamaTabel.paket;

  DateTime get _nowUtc => DateTime.now().toUtc();

  PelangganAktifOpSqlite({
    required this.sqliteDb,
    required BaseOpSqlite baseOpSqlite,
    required PelangganOpSqlite pelangganOpSqlite,
    required LayananNotifikasi layananNotifikasi,
    required TransaksiOpSqlite transaksiOpSqlite,
  }) : _baseOpSqlite = baseOpSqlite,
       _pelangganOpSqlite = pelangganOpSqlite,
       _layananNotifikasi = layananNotifikasi,
       _transaksiOpSqlite = transaksiOpSqlite {
    Log.info(
      'PelangganAktifOperation diinisialisasi - Tabel: $_tabelPelangganAktif',
    );
  }

  Future<void> jadwalkanUlangSemuaNotifikasi() async {
    Log.info('MEMULAI PROSES PENJADWALAN ULANG SEMUA NOTIFIKASI...');
    try {
      final pelangganAktif = await ambilSemua();

      if (pelangganAktif.isEmpty) {
        Log.info('Tidak ada pelanggan aktif untuk dijadwalkan ulang.');
        return;
      }

      Log.info(
        'Ditemukan ${pelangganAktif.length} pelanggan aktif. Menjadwalkan ulang satu per satu...',
      );

      for (final pelangganAktif in pelangganAktif) {
        await jadwalkanNotifikasi(pelangganAktif);
      }

      Log.info('PROSES PENJADWALAN ULANG SEMUA NOTIFIKASI SELESAI.');
    } on Exception catch (e, st) {
      Log.error(
        'Gagal total saat proses penjadwalan ulang semua notifikasi',
        e: e,
        s: st,
      );
    }
  }

  Future<List<DetailPelangganAktifModel>>
  ambilSemuaPelangganAktifDenganDetail() async {
    final db = await sqliteDb.database;
    Log.info(
      'Mengambil semua pelanggan aktif dengan detail yang belum berakhir (JOIN)',
    );

    final query =
        '''
      SELECT
        ac.*,
        c.${NamaKolom.nama} as customer_name,
        p.${NamaKolom.nama} as package_name
      FROM $_tabelPelangganAktif ac
      LEFT JOIN $_tabelPelanggan c ON ac.${NamaKolom.idPelanggan} = c.${NamaKolom.id}
      LEFT JOIN $_tabelPaket p ON ac.${NamaKolom.idPaket} = p.${NamaKolom.id}
      WHERE ac.${NamaKolom.dihapus} = 0
        AND ac.${NamaKolom.tanggalBerakhir} >= ?
    ''';

    try {
      final List<Map<String, dynamic>> maps = await db.rawQuery(query, [
        _nowUtc.millisecondsSinceEpoch,
      ]);
      Log.info(
        'Berhasil mengambil ${maps.length} pelanggan aktif yang belum berakhir dengan detail.',
      );

      return List.generate(maps.length, (final i) {
        final map = maps[i];
        return DetailPelangganAktifModel(
          pelangganAktif: PelangganAktifModel.fromSqlite(map),
          namaPelanggan: map['customer_name'] as String? ?? 'Tanpa Nama',
          namaPaket: map['package_name'] as String? ?? 'Tanpa Paket',
        );
      });
    } on Exception catch (e, st) {
      Log.error(
        'Gagal melakukan query JOIN untuk pelanggan aktif yang belum berakhir',
        e: e,
        s: st,
      );
      rethrow;
    }
  }

  Future<PelangganAktifModel> tambahPelangganAktif(
    final PelangganAktifModel pelangganAktif, {
    final bool fromServer = false,
  }) async {
    try {
      final customerToSave = pelangganAktif.copyWith(diperbaruiPada: _nowUtc);

      await _baseOpSqlite.operasiKompleks<void>((txn) async {
        final data = customerToSave.toSqlite();
        await txn.insert(
          _tabelPelangganAktif,
          data,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }, dariServer: fromServer);

      await jadwalkanNotifikasi(customerToSave);

      return customerToSave;
    } on Exception catch (e, st) {
      Log.error('Gagal membuat active customer', e: e, s: st);
      rethrow;
    }
  }

  Future<List<PelangganAktifModel>> ambilSemua() async {
    try {
      final db = await sqliteDb.database;
      Log.info(
        'Mengambil semua active customer dari tabel $_tabelPelangganAktif',
      );

      final List<Map<String, dynamic>> maps = await db.query(
        _tabelPelangganAktif,
        where: '${NamaKolom.dihapus} = ?',
        whereArgs: [0],
      );

      Log.info('Berhasil mengambil ${maps.length} active customer');
      return List.generate(
        maps.length,
        (i) => PelangganAktifModel.fromSqlite(maps[i]),
      );
    } on Exception catch (e, st) {
      Log.error('Gagal mengambil semua active customer', e: e, s: st);
      rethrow;
    }
  }

  Future<PelangganAktifModel?> ambilBerdasarkanid(final String id) async {
    try {
      final db = await sqliteDb.database;
      Log.info(
        'Mencari active customer dengan ID: $id di tabel $_tabelPelangganAktif',
      );

      final List<Map<String, dynamic>> maps = await db.query(
        _tabelPelangganAktif,
        where: '${NamaKolom.id} = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        final pelangganAktif = PelangganAktifModel.fromSqlite(maps.first);
        Log.info('Active customer ID: $id ditemukan');
        return pelangganAktif;
      }

      Log.info('Active customer ID: $id tidak ditemukan');
      return null;
    } on Exception catch (e, st) {
      Log.error('Gagal mengambil active customer ID: $id', e: e, s: st);
      rethrow;
    }
  }

  Future<PelangganAktifModel> updatePelangganAktif(
    final PelangganAktifModel pelangganAktif, {
    final bool fromServer = false,
  }) async {
    try {
      final customerToSave = pelangganAktif.copyWith(diperbaruiPada: _nowUtc);
      Log.info('Memperbarui active customer ID: ${customerToSave.id}');
      await _baseOpSqlite.operasiKompleks<void>((txn) async {
        final data = customerToSave.toSqlite();
        await txn.update(
          _tabelPelangganAktif,
          data,
          where: '${NamaKolom.id} = ?',
          whereArgs: [customerToSave.id],
        );
      }, dariServer: fromServer);
      await jadwalkanNotifikasi(customerToSave);
      Log.info('Active customer ID: ${customerToSave.id} berhasil diperbarui');
      return customerToSave;
    } on Exception catch (e, st) {
      Log.error(
        'Gagal memperbarui active customer ID: ${pelangganAktif.id}',
        e: e,
        s: st,
      );
      rethrow;
    }
  }

  Future<void> jadwalkanNotifikasi(PelangganAktifModel pelangganAktif) async {
    try {
      Log.info(
        '(RE)SCHEDULING: Menjadwalkan notifikasi untuk active customer ID: ${pelangganAktif.id}',
      );

      final pelanggan = await _pelangganOpSqlite.ambilBerdasarkanId(
        pelangganAktif.idPelanggan,
      );
      final customerName = pelanggan?.nama ?? 'Tanpa Nama';

      await _layananNotifikasi.batalkanNotifikasi(pelangganAktif.id.hashCode);
      await _layananNotifikasi.batalkanNotifikasi(
        (pelangganAktif.id.hashCode + 1),
      );
      await _layananNotifikasi.batalkanNotifikasi(
        (pelangganAktif.id.hashCode + 2),
      );
      Log.info(
        'Membatalkan notifikasi yang ada sebelum menjadwalkan ulang notifiaksi',
      );

      final tanggalBerakhir = pelangganAktif.tanggalBerakhir;
      if (tanggalBerakhir.isAfter(DateTime.now())) {
        await _layananNotifikasi.jadwalNotifikasi(
          id: (pelangganAktif.id.hashCode + 2),
          judul: 'Masa Aktif Habis!',
          pesan: 'Paket WiFi untuk $customerName telah berakhir sekarang.',
          jadwal: tanggalBerakhir,
        );
      }

      final jadwalH1 = pelangganAktif.tanggalBerakhir.subtract(
        const Duration(days: 1),
      );
      if (jadwalH1.isAfter(DateTime.now())) {
        await _layananNotifikasi.jadwalNotifikasi(
          id: pelangganAktif.id.hashCode,
          judul: 'Paket Akan Segera Berakhir',
          pesan: 'Paket untuk pelanggan $customerName akan berakhir besok.',
          jadwal: jadwalH1,
        );
      }

      final jadwalH3 = pelangganAktif.tanggalBerakhir.subtract(
        const Duration(days: 3),
      );
      if (jadwalH3.isAfter(DateTime.now())) {
        await _layananNotifikasi.jadwalNotifikasi(
          id: (pelangganAktif.id.hashCode + 1),
          judul: 'Pengingat Paket',
          pesan:
              'Paket untuk pelanggan $customerName akan berakhir dalam 3 hari.',
          jadwal: jadwalH3,
        );
      }

      Log.info(
        'Penjadwalan notifikasi selesai untuk ID: ${pelangganAktif.id}',
        {'h3': jadwalH3, 'h1': jadwalH1, 'h0': tanggalBerakhir},
      );
    } catch (e, st) {
      Log.error(
        'Gagal menjadwalkan notifikasi untuk ID: ${pelangganAktif.id}',
        e: e,
        s: st,
      );
    }
  }

  Future<void> sisipkanAtauPerbaruiBatch(
    final List<PelangganAktifModel> daftarPelangganAktif, {
    final bool dariServer = false,
  }) async {
    try {
      Log.info(
        'Memproses batch ${daftarPelangganAktif.length} active customer di $_tabelPelangganAktif',
      );

      final data = daftarPelangganAktif
          .map((item) => item.copyWith(diperbaruiPada: _nowUtc).toSqlite())
          .toList();

      await _baseOpSqlite.sisipkanAtauPerbaruiBatch(
        _tabelPelangganAktif,
        data,
        dariServer: dariServer,
      );

      Log.info(
        'Batch ${daftarPelangganAktif.length} active customer berhasil diproses',
      );
    } catch (e, st) {
      Log.error(
        'Gagal memproses batch ${daftarPelangganAktif.length} active customer',
        e: e,
        s: st,
      );
      rethrow;
    }
  }

  Future<void> softDelete(String id, {bool dariServer = false}) async {
    try {
      Log.info('Mengarsipkan active customer ID: $id');

      final pelangganAktif = await ambilBerdasarkanid(id);
      if (pelangganAktif == null) {
        Log.info('Active customer ID: $id tidak ditemukan');
        return;
      }

      await _baseOpSqlite.operasiKompleks<void>((txn) async {
        final pelangganAktifArsip = pelangganAktif.copyWith(
          diperbaruiPada: _nowUtc,
          diHapus: true,
          diarsipkanPada: _nowUtc,
        );

        await txn.update(
          _tabelPelangganAktif,
          pelangganAktifArsip.toSqlite(),
          where: '${NamaKolom.id} = ?',
          whereArgs: [id],
        );

        await _layananNotifikasi.batalkanNotifikasi(id.hashCode);
        await _layananNotifikasi.batalkanNotifikasi((id.hashCode + 1));
        await _layananNotifikasi.batalkanNotifikasi((id.hashCode + 2));

        Log.info('Notifikasi telah di batalkan pada fungsi softDelete');
      }, dariServer: dariServer);

      Log.info('Active customer ID: $id berhasil diarsipkan');
    } catch (e, st) {
      Log.error('Gagal mengarsipkan active customer ID: $id', e: e, s: st);
      rethrow;
    }
  }

  Future<void> softDeletePelangganAktifDanTransaksi(
    String idPelangganAKtif,
    String? idTransaksi, {
    bool dariServer = false,
  }) async {
    final pelangganAktif = await ambilBerdasarkanid(idPelangganAKtif);
    if (pelangganAktif == null) {
      Log.info('Pelanggan aktif dengan ID $idPelangganAKtif tidak ditemukan');
      return;
    }
    TransaksiModel? transaksi;
    if (idTransaksi != null) {
      transaksi = await _transaksiOpSqlite.ambilBerdasarkanId(idTransaksi);
      if (transaksi == null) {
        Log.info('Transaksi dengan ID $idTransaksi tidak ditemukan');
      }
    }
    await _baseOpSqlite.operasiKompleks<void>((txn) async {
      final pelangganAktifArsip = pelangganAktif.copyWith(
        diperbaruiPada: _nowUtc,
        diHapus: true,
        diarsipkanPada: _nowUtc,
      );

      await txn.update(
        _tabelPelangganAktif,
        pelangganAktifArsip.toSqlite(),
        where: '${NamaKolom.id} = ?',
        whereArgs: [idPelangganAKtif],
      );
      if (idTransaksi != null && transaksi != null) {
        final transkasiArsip = transaksi.copyWith(
          diperbaruiPada: _nowUtc,
          diHapus: true,
          diarsipkanPada: _nowUtc,
        );

        await txn.update(
          NamaTabel.transaksi,
          transkasiArsip.toSqlite(),
          where: '${NamaKolom.id} = ?',
          whereArgs: [idTransaksi],
        );
      }
    });
  }

  Future<int> arsipkanLanggananKadaluarsa({bool dariServer = false}) async {
    try {
      Log.info('Memeriksa active customer kadaluarsa');
      final db = await sqliteDb.database;

      final List<Map<String, dynamic>> expiredCustomers = await db.query(
        _tabelPelangganAktif,
        where: '${NamaKolom.tanggalBerakhir} < ? AND ${NamaKolom.dihapus} = 0',
        whereArgs: [_nowUtc.millisecondsSinceEpoch],
      );

      if (expiredCustomers.isEmpty) {
        Log.info('Tidak ada active customer kadaluarsa');
        return 0;
      }

      final idsToArchive = expiredCustomers
          .map((final p) => p[NamaKolom.id] as String)
          .toList();

      await _baseOpSqlite.operasiKompleks<void>((txn) async {
        await txn.update(
          _tabelPelangganAktif,
          {
            NamaKolom.dihapus: 1,
            NamaKolom.diarsipkanPada: _nowUtc.millisecondsSinceEpoch,
            NamaKolom.diperbaruiPada: _nowUtc.millisecondsSinceEpoch,
          },
          where:
              '${NamaKolom.id} IN (${List.filled(idsToArchive.length, '?').join(',')})',
          whereArgs: idsToArchive,
        );

        for (final id in idsToArchive) {
          await _layananNotifikasi.batalkanNotifikasi(id.hashCode);
          await _layananNotifikasi.batalkanNotifikasi((id.hashCode + 1));
          await _layananNotifikasi.batalkanNotifikasi((id.hashCode + 2));
        }
      }, dariServer: dariServer);

      Log.info(
        '${idsToArchive.length} active customer kadaluarsa telah diarsipkan',
      );
      return idsToArchive.length;
    } catch (e, st) {
      Log.error('Gagal mengarsipkan active customer kadaluarsa', e: e, s: st);
      rethrow;
    }
  }

  Future<int> softDeleteAll({bool dariServer = false}) async {
    try {
      Log.info('Mengarsipkan SEMUA active customer');
      final pelangganAktif = await ambilSemua();

      if (pelangganAktif.isEmpty) {
        Log.info('Tidak ada active customer untuk diarsipkan');
        return 0;
      }

      final dataUntukDiarsip = pelangganAktif.map((p) => p.id).toList();

      await _baseOpSqlite.operasiKompleks<void>((final txn) async {
        await txn.update(
          _tabelPelangganAktif,
          {
            NamaKolom.dihapus: 1,
            NamaKolom.diarsipkanPada: _nowUtc.millisecondsSinceEpoch,
            NamaKolom.diperbaruiPada: _nowUtc.millisecondsSinceEpoch,
          },
          where:
              '${NamaKolom.id} IN (${List.filled(dataUntukDiarsip.length, '?').join(',')})',
          whereArgs: dataUntukDiarsip,
        );

        for (final id in dataUntukDiarsip) {
          await _layananNotifikasi.batalkanNotifikasi(id.hashCode);
          await _layananNotifikasi.batalkanNotifikasi((id.hashCode + 1));
          await _layananNotifikasi.batalkanNotifikasi((id.hashCode + 2));
        }
      }, dariServer: dariServer);

      Log.info('${dataUntukDiarsip.length} active customer telah diarsipkan');
      return dataUntukDiarsip.length;
    } catch (e, st) {
      Log.error('Gagal mengarsipkan semua active customer', e: e, s: st);
      rethrow;
    }
  }

  Future<List<PelangganAktifModel>> ambilBerdasarkanIds(
    List<String> ids,
  ) async {
    try {
      if (ids.isEmpty) {
        Log.info('getPelangganAktifsByIds dipanggil dengan list ID kosong');
        return [];
      }

      final db = await sqliteDb.database;
      final placeholders = List.filled(ids.length, '?').join(',');
      final List<Map<String, dynamic>> maps = await db.query(
        _tabelPelangganAktif,
        where: '${NamaKolom.id} IN ($placeholders)',
        whereArgs: ids,
      );

      Log.info('Ditemukan ${maps.length} dari ${ids.length} active customer');
      return List.generate(maps.length, (i) {
        return PelangganAktifModel.fromSqlite(maps[i]);
      });
    } catch (e, st) {
      Log.error('Gagal mengambil active customer berdasarkan IDs', e: e, s: st);
      rethrow;
    }
  }
}
```

### File: `lib/fitur/pelanggan_aktif/page/detail_pelanggan_aktif.dart`
```dart
// path lib/fitur/pelanggan_aktif/page/detail_pelanggan_aktif.dart

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/paket/page/detail_paket.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan/page/user/detail_pelanggan.dart';
import 'package:wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:wifi/fitur/pelanggan_aktif/page/form_pelanggan_aktif.dart';
import 'package:wifi/fitur/pelanggan_aktif/provider/pelanggan_aktif_provider.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_global.dart';
import 'package:wifi/fitur/whatsapp/info_paket.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/theme/app_sizes.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/perhitungan_util.dart';
import 'package:wifi/shared/utils/toast_util.dart';

final detailPleangganAktifProvider =
    FutureProvider.family<
      ({
        PelangganModel? pelanggan,
        PaketModel? paket,
        TransaksiModel? transaksi,
        PelangganAktifModel pelangganAktif,
      }),
      String
    >((ref, id) async {
      final pelangganAktifState = await ref.watch(
        pelangganAktifProvider.future,
      );
      final daftarPelangganAktif = pelangganAktifState.daftarPelangganAktif;
      final detailPelangganAktif = daftarPelangganAktif.firstWhereOrNull(
        (detail) => detail.pelangganAktif.id == id,
      );
      if (detailPelangganAktif == null) {
        throw Exception('Data pelanggan aktif tidak ditemukan dalam daftar.');
      }
      final pelangganAktif = detailPelangganAktif.pelangganAktif;
      final pelangganOpSqlite = ref.watch(pelangganOpSqliteProvider);
      final paketOpSqlite = ref.watch(paketOpSqliteProvider);
      final transaksiOpsqlite = ref.watch(transaksiOpGlobalProvider);
      final hasil = await Future.wait<Object?>([
        pelangganOpSqlite.ambilBerdasarkanId(pelangganAktif.idPelanggan),
        pelangganAktif.idPaket.isNotEmpty
            ? paketOpSqlite.ambilBerdasarkanId(pelangganAktif.idPaket)
            : Future<PaketModel?>.value(),
        (pelangganAktif.idTransaksi.isNotEmpty)
            ? transaksiOpsqlite.ambilBerdasarkanId(pelangganAktif.idTransaksi)
            : Future<TransaksiModel?>.value(),
      ]);
      return (
        pelanggan: hasil[0] as PelangganModel?,
        paket: hasil[1] as PaketModel?,
        transaksi: hasil[2] as TransaksiModel?,
        pelangganAktif: pelangganAktif,
      );
    });

class DetailPelangganAktif extends ConsumerStatefulWidget {
  final PelangganAktifModel pelangganAktif;
  const DetailPelangganAktif({super.key, required this.pelangganAktif});
  @override
  ConsumerState<DetailPelangganAktif> createState() =>
      _DetailPelangganAktifState();
}

class _DetailPelangganAktifState extends ConsumerState<DetailPelangganAktif> {
  @override
  void initState() {
    super.initState();
    Log.info('Membuka halaman Detail Pelanggan Aktif');
    Log.info('  - ID Pelanggan Aktif: ${widget.pelangganAktif.id}');
  }

  Future<void> _bukaWhatsApp(String phone) async {
    var formatNomor = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (formatNomor.startsWith('0')) {
      formatNomor = '62${formatNomor.substring(1)}';
    } else if (!formatNomor.startsWith('62')) {
      formatNomor = '62$formatNomor';
    }
    final whatsappUri = Uri.parse('https://wa.me/$formatNomor');
    try {
      Log.info('Mencoba membuka WhatsApp: $formatNomor');
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
        Log.info('Berhasil membuka WhatsApp.');
      } else {
        throw Exception('Could not launch $whatsappUri');
      }
    } on Exception catch (e, s) {
      Log.error('Gagal membuka WhatsApp', e: e, s: s);
      if (!mounted) return;
      ToastUtil.error(
        context,
        'Tidak dapat membuka WhatsApp. Pastikan sudah terinstal.',
      );
    }
  }

  void _bukaFormEdit(PelangganAktifModel pelangganaktif) {
    Log.info('Navigasi ke form edit pelanggan aktif ID: ${pelangganaktif.id}');
    unawaited(
      Navigator.push<void>(
        context,
        MaterialPageRoute(
          builder: (context) =>
              FormPelangganAktif(pelangganAktif: pelangganaktif),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Log.info(
      'Membangun UI detail pelanggan aktif untuk ID: ${widget.pelangganAktif.id}.',
    );
    final detailAsync = ref.watch(
      detailPleangganAktifProvider(widget.pelangganAktif.id),
    );
    return detailAsync.when(
      skipLoadingOnReload: true,
      data: (data) => _buildScaffold(context, data),
      loading: () => const Scaffold(body: Center(child: Text(''))),
      error: (e, s) =>
          Scaffold(body: Center(child: Text('Terjadi kesalahan: $e'))),
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    ({
      PelangganModel? pelanggan,
      PaketModel? paket,
      TransaksiModel? transaksi,
      PelangganAktifModel pelangganAktif,
    })
    data,
  ) {
    final pelangganAktif = data.pelangganAktif;
    final pelanggan = data.pelanggan;
    final paket = data.paket;
    final transaksi = data.transaksi;
    return Scaffold(
      appBar: AppBar(
        title: Text(pelanggan?.nama ?? 'Detail Pelanggan'),
        actions: [
          IconButton(
            icon: const Icon(TIcons.edit),
            onPressed: () => _bukaFormEdit(pelangganAktif),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: TextButton(
                          onPressed: () {
                            if (pelanggan != null) {
                              Log.info(
                                'Navigasi ke detail pelanggan: ${pelanggan.nama}',
                              );
                              unawaited(
                                Navigator.push<void>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailPelanggan(
                                      idPelanggan: pelanggan.id,
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                          child: Text(
                            pelanggan?.nama ?? pelangganAktif.idPelanggan,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(color: Colors.blue),
                          ),
                        ),
                      ),
                      gapH16,
                      const Divider(),
                      _buildWhatsAppInfoRow(
                        context,
                        'No HP',
                        pelanggan?.telepon ?? 'Tidak ditemukan',
                      ),
                      InkWell(
                        onTap: () {
                          if (paket != null) {
                            Log.info('Navigasi ke detail paket: ${paket.nama}');
                            unawaited(
                              Navigator.push<void>(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (context) =>
                                      DetailPaketPage(paket: paket),
                                ),
                              ),
                            );
                          }
                        },
                        child: _buildInfoRow(
                          context,
                          'Paket',
                          paket?.nama ?? ' (ID: ${pelangganAktif.idPaket})',
                        ),
                      ),
                      _buildInfoRow(
                        context,
                        'Status',
                        pelangganAktif.status.displayName,
                      ),
                      if (transaksi != null) ...[
                        if (transaksi.poinDidapat > 0)
                          _buildInfoRow(
                            context,
                            'Poin Hadiah',
                            '${transaksi.poinDidapat} Poin',
                          ),
                        if (transaksi.poinDigunakan > 0)
                          _buildInfoRow(
                            context,
                            'Poin Penukaran',
                            '${transaksi.poinDigunakan} Poin',
                          ),
                      ],
                      if (transaksi != null && (transaksi.durasiBonus) > 0)
                        _buildInfoRow(
                          context,
                          'Bonus',
                          '${transaksi.durasiBonus} ${transaksi.tipeDurasiBonus?.displayName ?? ""}',
                        ),
                      _buildInfoRow(
                        context,
                        'Mulai',
                        FormatWaktuLengkap.formatSingkat(
                          pelangganAktif.tanggalMulai,
                        ),
                      ),
                      _buildInfoRow(
                        context,
                        'Berakhir',
                        FormatWaktuLengkap.formatSingkat(
                          pelangganAktif.tanggalBerakhir,
                        ),
                      ),
                      const Divider(),
                      gapH16,
                      Text(
                        PerhitunganUtil.cobaAmbilTeksSisaMasaAktif(
                          pelangganAktif.tanggalBerakhir,
                        ),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: PerhitunganUtil.ambilWarnaSisaMasaAktif(
                            pelangganAktif.tanggalBerakhir,
                          ),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      gapH24,
                      ElevatedButton.icon(
                        icon: const Icon(Icons.send_to_mobile),
                        label: const Text('Kirim Info via WhatsApp'),
                        onPressed: () {
                          Log.info('Tombol kirim info WhatsApp ditekan.');
                          unawaited(
                            ref
                                .read(pesanInfoPaketProvider)
                                .kirimRincianPaket(pelangganAktif),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    final String label,
    final String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          gapH8,
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatsAppInfoRow(
    BuildContext context,
    final String label,
    final String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          InkWell(
            onTap: () => _bukaWhatsApp(value),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              child: Row(
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  gapH8,
                  FaIcon(
                    FontAwesomeIcons.whatsapp,
                    color: Colors.green.shade700,
                    size: TSizes.p20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

### File: `lib/fitur/pelanggan_aktif/page/form_pelanggan_aktif.dart`
```dart
// path: lib/fitur/pelanggan_aktif/page/form_pelanggan_aktif.dart

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/dompet/model/dompet_model.dart';
import 'package:wifi/fitur/kategori/enum/tipe_kategori.dart';
import 'package:wifi/fitur/kategori/model/kategori_model.dart';
import 'package:wifi/fitur/notifikasi/model/notifikasi_model.dart';
import 'package:wifi/fitur/paket/core/perhitungan_paket.dart';
import 'package:wifi/fitur/paket/enum/tipe_durasi_paket.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:wifi/fitur/pelanggan_aktif/provider/pelanggan_aktif_provider.dart';
import 'package:wifi/fitur/sinkronisasi/layanan_cek_sinkronisasi.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/transaksi/enum/tipe_transaksi.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_global.dart';
import 'package:wifi/shared/common/teks.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/theme/app_sizes.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/perhitungan_util.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/input/input_angka.dart';
import 'package:wifi/shared/widget/pemilih_tanggal_waktu_widget.dart';

class FormPelangganAktif extends ConsumerStatefulWidget {
  final PelangganAktifModel? pelangganAktif;

  const FormPelangganAktif({super.key, this.pelangganAktif});

  @override
  ConsumerState<FormPelangganAktif> createState() => _FormPelangganAktifState();
}

class _FormPelangganAktifState extends ConsumerState<FormPelangganAktif> {
  final _formKey = GlobalKey<FormState>();

  List<PelangganModel> _daftarPelanggan = [];
  List<PaketModel> _daftarPaket = [];
  List<DompetModel> _dompetList = [];
  List<KategoriModel> _kategoriPemasukanList = [];
  List<KategoriModel> _kategoriPengeluaranList = [];
  List<KategoriModel> get _kategoriList =>
      _gunakanPoin ? _kategoriPengeluaranList : _kategoriPemasukanList;
  PelangganModel? _pelangganDipilih;
  PaketModel? _paketDipilih;
  DompetModel? _dompetDipilih;
  KategoriModel? _kategoriDipilih;
  bool _isLoading = true;
  bool _menyimpan = false;
  bool _gunakanPoin = false;
  late TextEditingController _durasiBonusController;
  TipeDurasiPaket _tipeBonusDurasi = TipeDurasiPaket.minutes;
  bool _bonus = false;
  int _saldoPoinPelanggan = 0;
  DateTime? _pilihTanggal;
  TimeOfDay? _pilihJam;
  StatusPembayaran _statusPembayaran = StatusPembayaran.paid;
  bool get _modeEdit => widget.pelangganAktif != null;
  int hitungPoinEfektif() {
    if (_paketDipilih == null) {
      return 0;
    }
    return _gunakanPoin ? _paketDipilih!.poinPenukaran : 0;
  }

  int hitungSisaPoin() {
    final poinDipakai = hitungPoinEfektif();
    return (_saldoPoinPelanggan - poinDipakai).clamp(0, 999999999);
  }

  int _statusPembayaranNotif = 0;

  @override
  void initState() {
    super.initState();
    _durasiBonusController = TextEditingController();
    _loadAllData().catchError((Object e, StackTrace st) {
      Log.error('Gagal memuat data di FormPelangganAktif', e: e, s: st);
      if (mounted) {
        ToastUtil.error(context, 'Gagal memuat data. Silakan coba lagi.');
        setState(() => _isLoading = false);
        if (widget.pelangganAktif?.status == StatusPembayaran.unpaid) {
          setState(() {
            _statusPembayaranNotif = 1;
          });
          Log.info('Bernilai $_statusPembayaranNotif');
        }
      }
    });
  }

  @override
  void dispose() {
    _durasiBonusController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    Log.info('Memulai memuat semua data untuk FormPelangganAktif');
    final pelangganOpSqlite = ref.read(pelangganOpSqliteProvider);
    final paketOpsqlite = ref.read(paketOpSqliteProvider);
    final transaksiOperasi = ref.read(transaksiOpGlobalProvider);
    final dompetOpSqlite = ref.read(dompetOpSqliteProvider);
    final kategoriOpSqlite = ref.read(kategoriOpSqliteProvider);
    try {
      final pa = widget.pelangganAktif;
      final transaksiTerkaitFuture = pa?.idTransaksi != null
          ? transaksiOperasi.ambilBerdasarkanId(pa!.idTransaksi)
          : Future<TransaksiModel?>.value();
      final hasil = await Future.wait<Object?>([
        pelangganOpSqlite.ambilSemua(),
        paketOpsqlite.ambilSemua(),
        dompetOpSqlite.ambilSemua(),
        kategoriOpSqlite.ambilSemua(),
        transaksiTerkaitFuture,
      ]);
      if (!mounted) {
        return;
      }
      final daftarPelanggan = (hasil[0] as List<PelangganModel>)
        ..sort((a, b) => a.nama.toLowerCase().compareTo(b.nama.toLowerCase()));
      final daftarPaket = (hasil[1] as List<PaketModel>)
        ..sort(
          (a, b) => PerhitunganPaket()
              .hitungDurasiPaket(a)
              .compareTo(PerhitunganPaket().hitungDurasiPaket(b)),
        );
      final daftarDompet = (hasil[2] as List<DompetModel>)
          .where((d) => !d.dihapus)
          .toList();
      final semuaKategori = hasil[3] as List<KategoriModel>;
      final kategoriPemasukanList = semuaKategori
          .where((k) => k.tipe == TipeKategori.income && !k.diHapus)
          .toList();
      final daftarKategoriPengeluaran = semuaKategori
          .where((k) => k.tipe == TipeKategori.expense && !k.diHapus)
          .toList();
      final transaksiTerkait = hasil.length > 4 && hasil[4] is TransaksiModel
          ? hasil[4] as TransaksiModel?
          : null;
      setState(() {
        _daftarPelanggan = daftarPelanggan;
        _daftarPaket = daftarPaket;
        _dompetList = daftarDompet;
        _kategoriPemasukanList = kategoriPemasukanList;
        _kategoriPengeluaranList = daftarKategoriPengeluaran;
      });
      Log.info('Semua data berhasil dimuat.');
      if (_modeEdit) {
        await _mapEditData(transaksiTerkait);
      } else {
        _mapNewData();
      }
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      Log.info('Semua data berhasil dimuat.');
    } catch (e, s) {
      Log.error('Gagal memuat data referensi', e: e, s: s);
      if (mounted) {
        ToastUtil.error(context, 'Gagal memuat data: $e');
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _mapEditData(TransaksiModel? transaksi) async {
    final transaksiOperasi = ref.read(transaksiOpGlobalProvider);
    final pa = widget.pelangganAktif!;
    Log.info('Memetakan data edit untuk PelangganAktif ID: ${pa.id}');
    _pelangganDipilih = _daftarPelanggan.firstWhereOrNull(
      (p) => p.id == pa.idPelanggan,
    );
    _paketDipilih = _daftarPaket.firstWhereOrNull((p) => p.id == pa.idPaket);
    if (transaksi != null) {
      Log.info(
        'Transaksi terkait (ID: ${transaksi.id}) ditemukan. Memetakan dompet dan kategori.',
      );
      _dompetDipilih = _dompetList.firstWhereOrNull(
        (d) => d.id == transaksi.idDompet,
      );
      final kategoriSumber = transaksi.tipe == TipeTransaksi.income
          ? _kategoriPemasukanList
          : _kategoriPengeluaranList;
      _kategoriDipilih = kategoriSumber.firstWhereOrNull(
        (k) => k.id == transaksi.idKategori,
      );
      if (transaksi.durasiBonus > 0) {
        _bonus = true;
        _durasiBonusController.text = transaksi.durasiBonus.toString();
        _tipeBonusDurasi = transaksi.tipeDurasiBonus ?? TipeDurasiPaket.hours;
      }
    } else {
      Log.warning(
        'Transaksi terkait untuk PelangganAktif ID: ${pa.id} tidak ditemukan.',
      );
      if (mounted) {
        ToastUtil.info(
          context,
          'Info: Transaksi asli tidak ditemukan, pilih ulang dompet/kategori.',
        );
      }
    }
    _pilihTanggal = pa.tanggalMulai;
    _pilihJam = TimeOfDay.fromDateTime(pa.tanggalMulai);
    _statusPembayaran = pa.status;
    if (_pelangganDipilih != null) {
      final poin = await transaksiOperasi.ambilTotalPoin(_pelangganDipilih!.id);
      if (mounted) {
        setState(() => _saldoPoinPelanggan = poin);
      }
    }
    Log.info('Pemetaan data edit selesai.');
  }

  void _mapNewData() {
    Log.info('Menginisialisasi form untuk entri baru.');
    final now = DateTime.now();
    _pilihTanggal = now;
    _pilihJam = TimeOfDay.fromDateTime(now);
    if (_dompetList.isNotEmpty) {
      _dompetDipilih = _dompetList.first;
    }
    if (_kategoriPemasukanList.isNotEmpty) {
      _kategoriDipilih =
          _kategoriPemasukanList.firstWhereOrNull(
            (k) => k.nama.toLowerCase() == 'aktivasi paket',
          ) ??
          _kategoriPemasukanList.first;
    }
  }

  Future<void> _memilihTanggal(BuildContext context) async {
    Log.info('Memilih tanggal, saat ini: $_pilihTanggal');
    final terpilih = await showDatePicker(
      context: context,
      initialDate: _pilihTanggal ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (terpilih != null && terpilih != _pilihTanggal) {
      setState(() => _pilihTanggal = terpilih);
      Log.info('Tanggal dipilih: ${FormatTanggal.formatDasar(terpilih)}');
    }
  }

  Future<void> _memilihJam(BuildContext context) async {
    Log.info('Memilih waktu, saat ini: $_pilihJam');
    final initial = _pilihJam ?? TimeOfDay.fromDateTime(DateTime.now());
    final terpilih = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (terpilih != null && terpilih != _pilihJam) {
      setState(() => _pilihJam = terpilih);
      Log.info('Waktu dipilih: ${terpilih.hour}:${terpilih.minute}');
    }
  }

  Future<bool> _simpanData() async {
    Log.info('Mulai menyimpan form, isEditMode=$_modeEdit');
    final notifikasiOpSqlite = ref.read(notifikasiOpSqliteProvider);
    final pelangganAktif = ref.read(pelangganAktifProvider.notifier);
    final transaksiOp = ref.read(transaksiOpGlobalProvider);

    if (!(_formKey.currentState?.validate() ?? false)) {
      Log.warning('Validasi form gagal');
      if (mounted) {
        ToastUtil.error(context, 'Data belum lengkap');
      }
      return false;
    }
    if (_pelangganDipilih == null ||
        _paketDipilih == null ||
        _pilihTanggal == null ||
        _pilihJam == null ||
        _dompetDipilih == null ||
        _kategoriDipilih == null) {
      Log.warning('Data form belum lengkap');
      if (mounted) {
        ToastUtil.error(context, 'Harap lengkapi semua data');
      }
      return false;
    }
    try {
      final tanggalMulai = DateTime(
        _pilihTanggal!.year,
        _pilihTanggal!.month,
        _pilihTanggal!.day,
        _pilihJam!.hour,
        _pilihJam!.minute,
      );
      var durasiBonus = 0;
      if (_bonus) {
        durasiBonus =
            int.tryParse(_durasiBonusController.text.replaceAll('.', '')) ?? 0;
        if (durasiBonus <= 0) {
          ToastUtil.error(
            context,
            'Durasi bonus harus diisi dan lebih dari 0.',
          );
          return false;
        }
      }
      final tanggalBerakhir = PerhitunganUtil.hitungTanggalBerakhir(
        tanggalMulai,
        _paketDipilih!,
        durasiBonus: durasiBonus,
        tipeDurasiBonus: _bonus ? _tipeBonusDurasi : null,
      );
      final idTransaksi =
          (_modeEdit && widget.pelangganAktif?.idTransaksi != null)
          ? widget.pelangganAktif!.idTransaksi
          : const Uuid().v4();
      final sekarang = DateTime.now();
      final pelangganAktifData = PelangganAktifModel(
        id: _modeEdit ? widget.pelangganAktif!.id : const Uuid().v4(),
        idPelanggan: _pelangganDipilih!.id,
        idPaket: _paketDipilih!.id,
        tanggalMulai: tanggalMulai,
        tanggalBerakhir: tanggalBerakhir,
        status: _statusPembayaran,
        idTransaksi: idTransaksi,
        diperbaruiPada: sekarang,
      );
      final transaksiData = TransaksiModel(
        id: idTransaksi,
        tanggal: tanggalMulai,
        deskripsi: _gunakanPoin
            ? 'Tukar Poin ${_paketDipilih!.nama}'
            : 'Aktivasi Paket: ${_paketDipilih!.nama}',
        jumlah: _gunakanPoin ? 0 : _paketDipilih!.harga.toDouble(),
        tipe: _gunakanPoin ? TipeTransaksi.expense : TipeTransaksi.income,
        idDompet: _dompetDipilih!.id,
        idKategori: _kategoriDipilih!.id,
        idPelanggan: _pelangganDipilih!.id,
        idPaket: _paketDipilih?.id,
        statusPembayaran: _statusPembayaran,
        poinDidapat: _gunakanPoin ? 0 : _paketDipilih!.poinHadiah,
        poinDigunakan: _gunakanPoin ? _paketDipilih!.poinPenukaran : 0,
        durasiPaket: _paketDipilih!.durasi,
        tipeDurasiPaket: _paketDipilih!.tipe,
        durasiBonus: durasiBonus,
        tipeDurasiBonus: _bonus ? _tipeBonusDurasi : null,
        tanggalMulai: tanggalMulai,
        tanggalBerakhir: tanggalBerakhir,
        statusAktivasi: true,
      );
      Log.info(
        'Menyimpan data: customerId=${_pelangganDipilih!.id}, packageId=${_paketDipilih!.id}, transaksiId=$idTransaksi',
      );
      if (_modeEdit) {
        await Future.wait([
          pelangganAktif.updatePelangganAktif(pelangganAktifData),
          transaksiOp.perbaruiTransaksi(transaksiData),
        ]);
        unawaited(notifikasiOpSqlite.hapusBerdasarkanIdTujuan(idTransaksi));
        Log.info(
          'menghapus data notifikasi dalam mode edit agar data selalu terbaru',
        );
      } else {
        await Future.wait([
          pelangganAktif.tambahPelangganAktif(pelangganAktifData),
          transaksiOp.tambahTransaksi(transaksiData),
        ]);
      }
      final totalDurasi = tanggalBerakhir.difference(tanggalMulai);
      final durasiSetengahJalan = Duration(
        microseconds: (totalDurasi.inMicroseconds / 2).round(),
      );
      final tanggalNotifikasiSetengahJalan = tanggalMulai.add(
        durasiSetengahJalan,
      );
      final daftarNotifikasi = <NotifikasiModel>[
        NotifikasiModel(
          id: const Uuid().v4(),
          tanggalMulai: tanggalMulai,
          tanggalBerakhir: tanggalBerakhir,
          userId: _pelangganDipilih!.id,
          tanggalTampil: tanggalNotifikasiSetengahJalan,
          judul: 'Info: Setengah Perjalanan Paket',
          deskripsi:
              'Anda telah menggunakan 50% dari masa aktif paket ${_paketDipilih!.nama}.',
          idTujuan: idTransaksi,
          targetRole: AppRole.user,
          tipe: TipeNotifikasiEnum.transaksi,
          diperbaruiPada: sekarang,
        ),
        NotifikasiModel(
          id: const Uuid().v4(),
          tanggalMulai: tanggalMulai,
          tanggalBerakhir: tanggalBerakhir,
          userId: _pelangganDipilih!.id,
          tanggalTampil: tanggalBerakhir.subtract(const Duration(days: 1)),
          judul: 'Pengingat: Masa Aktif Segera Habis',
          deskripsi:
              'Masa aktif paket ${_paketDipilih!.nama} Anda akan berakhir besok.',
          idTujuan: idTransaksi,
          targetRole: AppRole.user,
          tipe: TipeNotifikasiEnum.transaksi,
          diperbaruiPada: sekarang,
        ),
        NotifikasiModel(
          id: const Uuid().v4(),
          tanggalMulai: tanggalMulai,
          tanggalBerakhir: tanggalBerakhir,
          userId: _pelangganDipilih!.id,
          tanggalTampil: tanggalBerakhir,
          judul: 'Masa Aktif Paket Habis',
          deskripsi:
              'Masa aktif untuk paket ${_paketDipilih!.nama} telah berakhir hari ini.',
          idTujuan: idTransaksi,
          targetRole: AppRole.user,
          tipe: TipeNotifikasiEnum.transaksi,
          diperbaruiPada: sekarang,
        ),
        NotifikasiModel(
          id: const Uuid().v4(),
          tanggalMulai: tanggalMulai,
          tanggalBerakhir: tanggalBerakhir,
          userId: _pelangganDipilih!.id,
          tanggalTampil: tanggalBerakhir.add(const Duration(days: 1)),
          judul: 'Masa Aktif Telah Berakhir',
          deskripsi:
              'Masa aktif untuk paket ${_paketDipilih!.nama} telah berakhir kemarin. Silakan perpanjang.',
          idTujuan: idTransaksi,
          targetRole: AppRole.user,
          tipe: TipeNotifikasiEnum.transaksi,
          diperbaruiPada: sekarang,
        ),
      ];
      await Future.wait(
        daftarNotifikasi.map(notifikasiOpSqlite.tambahNotifikasi),
      );
      unawaited(
        ref.read(layananCekSinkronisasiProvider).jalankanCekSinkronisasi(),
      );
      return true;
    } catch (e, s) {
      Log.error('Gagal menyimpan data pelanggan aktif.', e: e, s: s);
      if (mounted) {
        ToastUtil.error(context, 'Gagal menyimpan: $e');
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _modeEdit ? 'Edit Pelanggan Aktif' : 'Form Pelanggan Aktif',
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(TSizes.p16),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildPoinSwitch(),
                      gapH16,
                      _buildPelangganDropdown(),
                      gapH16,
                      _buildPaketDropdown(),
                      gapH16,
                      _buildDompetDropdown(),
                      gapH16,
                      _buildTombolBonus(),
                      _buildDurasiBonus(),
                      gapH16,
                      _buildKategoriDropdown(),
                      gapH24,
                      PemilihTanggalWaktuWidget(
                        tanggalTerpilih: _pilihTanggal,
                        waktuTerpilih: _pilihJam,
                        onPilihTanggal: () => _memilihTanggal(context),
                        onPilihWaktu: () => _memilihJam(context),
                      ),
                      gapH8,
                      _buildStatusPembayaranButtons(),
                      gapH24,
                      _buildInfoTanggalBerakhir(),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: _buildTombolSimpan(),
    );
  }

  Widget _buildPoinSwitch() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TSizes.p16,
        vertical: TSizes.p8,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Gunakan Poin',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              gapH4,
              if (_gunakanPoin)
                Text(
                  'Poin dipakai: ${hitungPoinEfektif()}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              Text(
                'Sisa poin: ${hitungSisaPoin()}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          Switch(
            value: _gunakanPoin,
            onChanged: (value) {
              if (!mounted) return;
              setState(() {
                _gunakanPoin = value;
                Log.info(
                  'Penggunaan poin diubah: $_gunakanPoin, poin efektif=${hitungPoinEfektif()}',
                );
                _kategoriDipilih = null;
                if (_kategoriList.isNotEmpty) {
                  _kategoriDipilih = _kategoriList.first;
                  Log.info(
                    'Kategori otomatis dipilih: ${_kategoriDipilih!.nama} (${_kategoriList.length} kategori tersedia)',
                  );
                } else {
                  Log.warning(
                    'Tidak ada kategori tersedia untuk mode ${_gunakanPoin ? "pengeluaran" : "pemasukan"}',
                  );
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPelangganDropdown() {
    final transaksiOperasi = ref.read(transaksiOpGlobalProvider);
    return DropdownButtonFormField<PelangganModel>(
      key: const Key('pelanggan_dropdown'),
      decoration: const InputDecoration(
        labelText: 'Pilih Pelanggan',
        border: OutlineInputBorder(),
      ),
      initialValue: _pelangganDipilih,
      items: _daftarPelanggan
          .map((p) => DropdownMenuItem(value: p, child: Text(p.nama)))
          .toList(),
      onChanged: (newValue) async {
        if (newValue == null) {
          return;
        }
        final saldoPoin = await transaksiOperasi.ambilTotalPoin(newValue.id);
        if (mounted) {
          setState(() {
            Log.info(
              'Pelanggan dipilih: id=${newValue.id} nama=${newValue.nama}, saldoPoin=$saldoPoin',
            );
            _pelangganDipilih = newValue;
            _saldoPoinPelanggan = saldoPoin;
            if (_kategoriList.isNotEmpty && _kategoriDipilih == null) {
              _kategoriDipilih = _kategoriList.first;
            }
          });
        }
      },
      validator: (v) => v == null ? 'Pelanggan tidak boleh kosong' : null,
    );
  }

  Widget _buildPaketDropdown() {
    return DropdownButtonFormField<PaketModel>(
      key: const Key('paket_dropdown'),
      decoration: const InputDecoration(
        labelText: 'Pilih Paket',
        border: OutlineInputBorder(),
      ),
      initialValue: _paketDipilih,
      items: _daftarPaket
          .map((p) => DropdownMenuItem(value: p, child: Text(p.nama)))
          .toList(),
      onChanged: (newValue) {
        if (!mounted) return;
        Log.info(
          'Paket dipilih: id=${(newValue)?.id} nama=${(newValue)?.nama}',
        );
        setState(() => _paketDipilih = newValue);
      },
      validator: (v) => v == null ? 'Paket tidak boleh kosong' : null,
    );
  }

  Widget _buildDompetDropdown() {
    return DropdownButtonFormField<DompetModel>(
      key: const Key('dompet_dropdown'),
      decoration: const InputDecoration(
        labelText: 'Pilih Dompet',
        border: OutlineInputBorder(),
      ),
      initialValue: _dompetDipilih,
      items: _dompetList
          .map((d) => DropdownMenuItem(value: d, child: Text(d.nama)))
          .toList(),
      onChanged: (newValue) {
        Log.info('Dompet dipilih: id=${newValue?.id} nama=${newValue?.nama}');
        setState(() => _dompetDipilih = newValue);
      },
      validator: (v) => v == null ? 'Dompet tidak boleh kosong' : null,
    );
  }

  Widget _buildKategoriDropdown() {
    if (_kategoriList.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(TSizes.p12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.orange.shade300),
          borderRadius: BorderRadius.circular(8),
          color: Colors.orange.shade50,
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
            gapW8,
            Expanded(
              child: Text(
                _gunakanPoin
                    ? 'Belum ada kategori pengeluaran. Buat kategori terlebih dahulu.'
                    : 'Belum ada kategori pemasukan. Buat kategori terlebih dahulu.',
                style: TextStyle(color: Colors.orange.shade700, fontSize: 14),
              ),
            ),
          ],
        ),
      );
    }
    return DropdownButtonFormField<KategoriModel>(
      key: const Key('kategori_dropdown'),
      decoration: const InputDecoration(
        labelText: 'Pilih Kategori Transaksi',
        border: OutlineInputBorder(),
      ),
      initialValue: _kategoriDipilih,
      items: _kategoriList
          .map((k) => DropdownMenuItem(value: k, child: Text(k.nama)))
          .toList(),
      onChanged: (newValue) {
        Log.info('Kategori dipilih: id=${newValue?.id} nama=${newValue?.nama}');
        setState(() => _kategoriDipilih = newValue);
      },
      validator: (v) {
        if (v == null) {
          return _kategoriList.isEmpty
              ? 'Tidak ada kategori tersedia. Silakan buat kategori terlebih dahulu.'
              : 'Kategori tidak boleh kosong';
        }
        return null;
      },
    );
  }

  Widget _buildStatusPembayaranButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _statusPembayaran == StatusPembayaran.paid
                  ? Theme.of(context).primaryColor
                  : Colors.grey[200],
              foregroundColor: _statusPembayaran == StatusPembayaran.paid
                  ? Colors.white
                  : Colors.black,
            ),
            onPressed: () {
              Log.info('Status pembayaran diubah: paid');
              setState(() => _statusPembayaran = StatusPembayaran.paid);
            },
            child: const Text('Lunas'),
          ),
        ),
        gapW8,
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _statusPembayaran == StatusPembayaran.unpaid
                  ? Theme.of(context).primaryColor
                  : Colors.grey[200],
              foregroundColor: _statusPembayaran == StatusPembayaran.unpaid
                  ? Colors.white
                  : Colors.black,
            ),
            onPressed: () {
              Log.info('Status pembayaran diubah: unpaid');
              setState(() => _statusPembayaran = StatusPembayaran.unpaid);
            },
            child: const Text('Belum Lunas'),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTanggalBerakhir() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tanggal Mulai:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              (_pilihTanggal == null || _pilihJam == null)
                  ? 'Pilih Tanggal & Jam'
                  : FormatWaktuLengkap.formatSingkat(
                      DateTime(
                        _pilihTanggal!.year,
                        _pilihTanggal!.month,
                        _pilihTanggal!.day,
                        _pilihJam!.hour,
                        _pilihJam!.minute,
                      ),
                    ),
            ),
          ],
        ),
        gapH8,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tanggal Berakhir:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text((() {
              if (_pilihTanggal != null &&
                  _pilihJam != null &&
                  _paketDipilih != null) {
                final startDate = DateTime(
                  _pilihTanggal!.year,
                  _pilihTanggal!.month,
                  _pilihTanggal!.day,
                  _pilihJam!.hour,
                  _pilihJam!.minute,
                );
                final nilaiBonus = _bonus
                    ? (int.tryParse(_durasiBonusController.text) ?? 0)
                    : 0;
                final endDate = PerhitunganUtil.hitungTanggalBerakhir(
                  startDate,
                  _paketDipilih!,
                  durasiBonus: nilaiBonus,
                  tipeDurasiBonus: _bonus ? _tipeBonusDurasi : null,
                );

                return FormatWaktuLengkap.formatSingkat(endDate);
              } else {
                return 'Pilih paket & tanggal mulai';
              }
            }())),
          ],
        ),
      ],
    );
  }

  Widget _buildTombolBonus() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const TeksIsiBesar('Bonus'),
        Switch(
          value: _bonus,
          onChanged: (value) {
            setState(() {
              _bonus = value;
              Log.info('Status bonus diubah: $_bonus');
            });
          },
        ),
      ],
    );
  }

  Widget _buildDurasiBonus() {
    if (!_bonus) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        gapH8,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: InputAngka(
                controller: _durasiBonusController,
                label: 'Durasi Bonus',
                enabled: _bonus,
                prefixIcon: TIcons.timer,
              ),
            ),
            gapW8,
            Expanded(
              child: DropdownButtonFormField<TipeDurasiPaket>(
                key: const Key('dropdown_bonus_duration_type'),
                initialValue: _tipeBonusDurasi,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: TipeDurasiPaket.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.displayName),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(() {
                      _tipeBonusDurasi = newValue;
                      Log.info('Tipe durasi bonus diubah: $_tipeBonusDurasi');
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTombolSimpan() {
    return Padding(
      padding: const EdgeInsets.all(TSizes.p16),
      child: ElevatedButton(
        onPressed: _menyimpan
            ? null
            : () async {
                setState(() {
                  _menyimpan = true;
                });
                Log.info('Tombol Simpan ditekan');
                final berhasil = await _simpanData();
                if (!mounted) {
                  setState(() {
                    _menyimpan = false;
                  });
                  return;
                }
                setState(() {
                  _menyimpan = false;
                });
                if (berhasil) {
                  ToastUtil.success(context, 'Data berhasil disimpan');
                  Navigator.pop(context);
                } else {
                  ToastUtil.error(context, 'Data tidak terimpan');
                }
              },
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
        ),
        child: _menyimpan
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text('Simpan'),
      ),
    );
  }
}
```

### File: `lib/fitur/pelanggan_aktif/page/pelanggan_aktif_page.dart`
```dart
// path: lib/fitur/pelanggan_aktif/page/pelanggan_aktif_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/pelanggan_aktif/helper/pengurut_pelanggan_aktif.dart';
import 'package:wifi/fitur/pelanggan_aktif/model/detail_pelanggan_aktif_model.dart';
import 'package:wifi/fitur/pelanggan_aktif/page/detail_pelanggan_aktif.dart';
import 'package:wifi/fitur/pelanggan_aktif/page/form_pelanggan_aktif.dart';
import 'package:wifi/fitur/pelanggan_aktif/provider/pelanggan_aktif_provider.dart';
import 'package:wifi/fitur/sinkronisasi/layanan_cek_sinkronisasi.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/transaksi/provider/transaksi_provider.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/operation.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/theme/app_sizes.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/perhitungan_util.dart';
import 'package:wifi/shared/utils/toast_util.dart';

enum OpsiLanjutan { softDeleteAll, arsipkanKadaluarsa, batal }

class PelangganAktifPage extends ConsumerStatefulWidget {
  const PelangganAktifPage({super.key});

  @override
  ConsumerState<PelangganAktifPage> createState() => _PelangganAktifPageState();
}

class _PelangganAktifPageState extends ConsumerState<PelangganAktifPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _mencari = false;

  @override
  void initState() {
    super.initState();
    Log.info('ActiveCustomerPage initState');
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(_inisialisasiAwal());
      }
    });
  }

  Future<void> _inisialisasiAwal() async {
    try {
      await _pelangganAktifOpSqlite.arsipkanLanggananKadaluarsa();
    } catch (e) {
      Log.error('Gagal menjalankan arsip otomatis saat aplikasi dibuka', e: e);
    }
    if (mounted) {
      await ref.read(pelangganAktifProvider.notifier).perbaruiData();
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  PelangganAktifOpSqlite get _pelangganAktifOpSqlite =>
      ref.read(pelangganAktifOpSqliteProvider);
  TransaksiOpSqlite get _transaksiOpsqlite =>
      ref.read(transaksiOpSqliteProvider);

  void _onSearchChanged() {
    setState(() {});
  }

  Future<void> refreshData() async {
    try {
      await _pelangganAktifOpSqlite.arsipkanLanggananKadaluarsa();
    } catch (e) {
      Log.error('Gagal arsip otomatis saat refresh', e: e);
    }
    await ref.read(pelangganAktifProvider.notifier).perbaruiData();
  }

  Future<void> _softDeletePelangganAktif(
    final DetailPelangganAktifModel pelanggan,
  ) async {
    final idPelangganAktif = pelanggan.pelangganAktif.id;
    final namaPelanggan = pelanggan.namaPelanggan;
    final idTransaksi = pelanggan.pelangganAktif.idTransaksi;
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Arsipkan'),
        content: Text('Yakin ingin mengarsipkan pelanggan "$namaPelanggan"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (konfirmasi == true) {
      try {
        await _pelangganAktifOpSqlite.softDeletePelangganAktifDanTransaksi(
          idPelangganAktif,
          idTransaksi,
        );
        ref.read(transaksiProvider.notifier).invalidateProviderTransaksi();
        Log.info('Berhasil soft delete pelanggan ID: $idPelangganAktif');
        if (mounted) {
          ToastUtil.success(
            context,
            'Pelanggan "$namaPelanggan" berhasil diarsipkan.',
          );
        }
        await ref.read(pelangganAktifProvider.notifier).perbaruiData();
      } on Exception catch (e, s) {
        Log.error(
          'Gagal soft delete pelanggan ID: $idPelangganAktif',
          e: e,
          s: s,
        );
        if (mounted) {
          ToastUtil.error(context, 'Gagal mengarsipkan pelanggan: $e');
        }
      }
    } else {
      Log.info(
        'Soft delete pelanggan ID: $idPelangganAktif dibatalkan oleh user',
      );
    }
  }

  Future<void> _tampilkanDialogUrutan() async {
    final currentSort = ref.read(urutanPelangganAktifStateProvider);
    await showDialog<UrutanPelangganAktifEnum>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Urutkan Berdasarkan'),
        contentPadding: const EdgeInsets.only(
          top: TSizes.p12,
          bottom: TSizes.p12,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: UrutanPelangganAktifEnum.values.map((o) {
                    final diPilih = currentSort == o;
                    return ListTile(
                      dense: true,
                      visualDensity: const VisualDensity(vertical: -2),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: TSizes.p24,
                      ),
                      title: Text(
                        ambilTeksUrutanPelangganAktif(o),
                        style: TextStyle(
                          fontSize: TSizes.p16,
                          fontWeight: diPilih
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: diPilih
                              ? Theme.of(context).primaryColor
                              : null,
                        ),
                      ),
                      trailing: diPilih
                          ? Icon(
                              TIcons.check,
                              color: Theme.of(context).primaryColor,
                              size: 18,
                            )
                          : null,
                      onTap: () {
                        ref
                            .read(urutanPelangganAktifStateProvider.notifier)
                            .ubahUrutan(o);
                        Navigator.pop(ctx);
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }

  Future<void> _opsiLanjutan() async {
    Log.info('Membuka opsi lanjutan');
    final selected = await showDialog<OpsiLanjutan>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Opsi Lanjutan'),
        children: [
          SimpleDialogOption(
            onPressed: () =>
                Navigator.pop(ctx, OpsiLanjutan.arsipkanKadaluarsa),
            child: const Text('Arsipkan pelanggan kadaluarsa'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, OpsiLanjutan.softDeleteAll),
            child: const Text(
              'Hapus Semua',
              style: TextStyle(color: Colors.red),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, OpsiLanjutan.batal),
            child: const Text('Batal'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    switch (selected) {
      case OpsiLanjutan.softDeleteAll:
        Log.warning('Opsi arsipkan semua dipilih');
        final konfirmasi = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Konfirmasi Arsipkan Semua'),
            content: const Text(
              'Yakin ingin mengarsipkan SEMUA pelanggan aktif?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Arsipkan Semua'),
              ),
            ],
          ),
        );
        if (konfirmasi == true) {
          try {
            Log.warning('Eksekusi arsipkan semua pelanggan aktif');
            await _pelangganAktifOpSqlite.softDeleteAll();
            await _transaksiOpsqlite.softDeleteAll();
            if (mounted) {
              ToastUtil.success(context, 'Berhasil mengarsipkan  pelanggan.');
            }
            unawaited(
              ref
                  .read(layananCekSinkronisasiProvider)
                  .jalankanCekSinkronisasi(),
            );
            await ref.read(pelangganAktifProvider.notifier).perbaruiData();
          } catch (e, s) {
            Log.error('Gagal mengarsipkan semua pelanggan aktif', e: e, s: s);
            if (mounted) {
              ToastUtil.error(
                context,
                'Gagal mengarsipkan semua pelanggan: $e',
              );
            }
          }
        }
        break;
      case OpsiLanjutan.arsipkanKadaluarsa:
        try {
          Log.info('Mulai arsipkan pelanggan kadaluarsa');
          final count = await _pelangganAktifOpSqlite
              .arsipkanLanggananKadaluarsa();
          Log.info('Selesai arsipkan kadaluarsa, jumlah=$count');
          if (mounted) {
            ToastUtil.success(
              context,
              '$count pelanggan kadaluarsa diarsipkan.',
            );
          }
          await ref.read(pelangganAktifProvider.notifier).perbaruiData();
        } catch (e, s) {
          Log.error('Gagal mengarsipkan pelanggan kadaluarsa', e: e, s: s);
          if (mounted) {
            ToastUtil.error(
              context,
              'Gagal mengarsipkan pelanggan kadaluarsa: $e',
            );
          }
        }
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pelangganAktifAsync = ref.watch(pelangganAktifProvider);
    return Scaffold(
      appBar: AppBar(
        title: _mencari
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Cari data...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
              )
            : const Text('Pelanggan Aktif'),
        actions: _mencari
            ? [
                IconButton(
                  icon: const Icon(TIcons.close),
                  onPressed: () {
                    setState(() => _mencari = false);
                    _searchController.clear();
                  },
                ),
              ]
            : [
                IconButton(
                  icon: const Icon(TIcons.search),
                  onPressed: () => setState(() => _mencari = true),
                ),
                IconButton(
                  icon: const Icon(TIcons.filter),
                  onPressed: _tampilkanDialogUrutan,
                ),
                IconButton(
                  icon: const Icon(TIcons.delete),
                  onPressed: _opsiLanjutan,
                ),
              ],
      ),
      body: RefreshIndicator(
        onRefresh: refreshData,
        child: pelangganAktifAsync.when(
          skipLoadingOnReload: true,
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) {
            Log.error('Error UI Pelanggan Aktif', e: error, s: stack);
            return Center(child: Text('Terjadi kesalahan: $error'));
          },
          data: (state) {
            final sortBy = ref.watch(urutanPelangganAktifStateProvider);
            final urutkan = urutkanPelangganAktif(
              state.daftarPelangganAktif,
              sortBy,
            );
            final query = _searchController.text.toLowerCase();
            final displayedCustomers = urutkan
                .where((c) => c.namaPelanggan.toLowerCase().contains(query))
                .toList();
            if (displayedCustomers.isEmpty) {
              return Center(
                child: Text(
                  query.isNotEmpty
                      ? 'Pelanggan tidak ditemukan.'
                      : 'Tidak ada pelanggan aktif.',
                ),
              );
            }

            return ListView.builder(
              itemCount: displayedCustomers.length,
              itemBuilder: (_, i) {
                final detail = displayedCustomers[i];
                final c = detail.pelangganAktif;
                return Card(
                  margin: const EdgeInsets.only(
                    left: TSizes.p16,
                    right: TSizes.p16,
                    bottom: TSizes.p12,
                  ),
                  child: InkWell(
                    onLongPress: () => _softDeletePelangganAktif(detail),
                    onTap: () async {
                      await Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              DetailPelangganAktif(pelangganAktif: c),
                        ),
                      );
                    },
                    child: ListTile(
                      title: Text(
                        detail.namaPelanggan,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(detail.namaPaket),
                          Text(
                            'Pembayaran: ${c.status.displayName}',
                            style: TextStyle(
                              color: c.status == StatusPembayaran.paid
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Status: ${PerhitunganUtil.cobaAmbilTeksSisaMasaAktif(c.tanggalBerakhir)}',
                            style: TextStyle(
                              color: PerhitunganUtil.ambilWarnaSisaMasaAktif(
                                c.tanggalBerakhir,
                              ),
                            ),
                          ),
                          Text(
                            'Berakhir: ${FormatTanggal.formatDasar(c.tanggalBerakhir)} ${FormatJam.formatJamMenit(c.tanggalBerakhir)}',
                          ),
                        ],
                      ),
                      trailing: const Icon(TIcons.chevronRight),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_active_customer',
        onPressed: () => Navigator.push<void>(
          context,
          MaterialPageRoute<void>(builder: (_) => const FormPelangganAktif()),
        ),
        child: const Icon(TIcons.add),
      ),
    );
  }
}
```

### File: `lib/fitur/pelanggan_aktif/provider/pelanggan_aktif_provider.dart`
```dart
// path: lib/fitur/pelanggan_aktif/provider/pelanggan_aktif_provider.dart

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:wifi/fitur/pelanggan_aktif/operasi/pelanggan_aktif_op_sqlite.dart';
import 'package:wifi/fitur/transaksi/provider/transaksi_provider.dart';
import 'package:wifi/shared/export/model.dart';

part 'pelanggan_aktif_provider.g.dart';
part 'pelanggan_aktif_provider.freezed.dart';

@freezed
abstract class PelangganAktifState with _$PelangganAktifState {
  const factory PelangganAktifState({
    @Default([]) List<DetailPelangganAktifModel> daftarPelangganAktif,
    @Default(0) int jumlahPelangganAktif,
  }) = _PelangganAktifState;
}

@Riverpod(keepAlive: true)
class PelangganAktif extends _$PelangganAktif {
  PelangganAktifOpSqlite get pelangganAktifOpSqlite =>
      ref.watch(pelangganAktifOpSqliteProvider);

  @override
  FutureOr<PelangganAktifState> build() {
    return _ambilData();
  }

  Future<PelangganAktifState> _ambilData() async {
    final operasi = ref.read(pelangganAktifOpSqliteProvider);
    final hasil = await operasi.ambilSemuaPelangganAktifDenganDetail();
    return PelangganAktifState(
      daftarPelangganAktif: hasil,
      jumlahPelangganAktif: hasil.length,
    );
  }

  Future<void> tambahPelangganAktif(PelangganAktifModel pelangganAktif) async {
    await pelangganAktifOpSqlite.tambahPelangganAktif(pelangganAktif);
    invalidatePelangganAktif();
  }

  Future<void> updatePelangganAktif(PelangganAktifModel pelangganAktif) async {
    await pelangganAktifOpSqlite.updatePelangganAktif(pelangganAktif);
    invalidatePelangganAktif();
  }

  Future<void> perbaruiData() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final data = await pelangganAktifOpSqlite
          .ambilSemuaPelangganAktifDenganDetail();
      return PelangganAktifState(
        daftarPelangganAktif: data,
        jumlahPelangganAktif: data.length,
      );
    });
  }

  void invalidatePelangganAktif() {
    ref.invalidateSelf();
    ref.invalidate(transaksiProvider);
  }
}

@freezed
abstract class DetailPelangganAktifState with _$DetailPelangganAktifState {
  const factory DetailPelangganAktifState({
    required PelangganAktifModel pelangganAktif,
    required PelangganModel pelanggan,
    required TransaksiModel transaksi,
    required PaketModel paket,
  }) = _DetailPelangganAktifState;
}

@riverpod
Future<void> detailPelangganAktif(Ref ref) async {
  final pelangganAktifOpSqlite = ref.read(pelangganAktifOpSqliteProvider);
  await pelangganAktifOpSqlite.ambilSemuaPelangganAktifDenganDetail();
  return;
}
```

