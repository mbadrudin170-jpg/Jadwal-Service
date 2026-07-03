# Dokumentasi Fitur: versi_apk

## Daftar file

- [lib/fitur/versi_apk/model/versi_apk_model.dart](lib/fitur/versi_apk/model/versi_apk_model.dart)
- [lib/fitur/versi_apk/operasi/versi_apk_op_firebase.dart](lib/fitur/versi_apk/operasi/versi_apk_op_firebase.dart)
- [lib/fitur/versi_apk/operasi/versi_apk_op_sqlite.dart](lib/fitur/versi_apk/operasi/versi_apk_op_sqlite.dart)
- [lib/fitur/versi_apk/page/detail_versi_apk.dart](lib/fitur/versi_apk/page/detail_versi_apk.dart)
- [lib/fitur/versi_apk/page/form_versi_apk.dart](lib/fitur/versi_apk/page/form_versi_apk.dart)
- [lib/fitur/versi_apk/page/update_apk_page_u.dart](lib/fitur/versi_apk/page/update_apk_page_u.dart)
- [lib/fitur/versi_apk/page/versi_apk_page.dart](lib/fitur/versi_apk/page/versi_apk_page.dart)
- [lib/fitur/versi_apk/service/layanan_cek_update_apk.dart](lib/fitur/versi_apk/service/layanan_cek_update_apk.dart)
- [lib/fitur/versi_apk/service/update_service.dart](lib/fitur/versi_apk/service/update_service.dart)

## Isi file

### File: `lib/fitur/versi_apk/model/versi_apk_model.dart`
```dart
// path: lib/fitur/versi_apk/model/versi_apk_model.dart

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wifi/fitur/info_perangkat/enum/arsitektur_apk.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/utils/parser_util.dart';

part 'versi_apk_model.freezed.dart';

@freezed
abstract class VersiApkModel with _$VersiApkModel implements HasId {
  const VersiApkModel._(); // Private constructor untuk method custom

  const factory VersiApkModel({
    required String id,
    @Default('') String catatanRilis,
    @Default(<ArsitekturApk, int>{}) Map<ArsitekturApk, int> nomorBuildTerakhir,
    @Default(<ArsitekturApk, String>{}) Map<ArsitekturApk, String> linkDownload,
    @Default('') String versiTerkahir,
    @Default(false) bool wajibUpdate,
    @Default('') String linkYoutubeTutorial,
    @Default(false) bool diHapus,
    DateTime? diarsipkanPada,
    DateTime? diperbaruiPada,
  }) = _VersiApkModel;

  // =========================
  // HELPERS
  // =========================

  static ArsitekturApk? _architectureFromString(String? value) {
    if (value == null) return null;
    for (final val in ArsitekturApk.values) {
      if (val.name == value) {
        return val;
      }
    }
    return null;
  }

  static Map<ArsitekturApk, int> _parseBuildNumber(dynamic data) {
    final result = <ArsitekturApk, int>{};
    Map<dynamic, dynamic>? mapData;

    if (data is Map) {
      mapData = data;
    } else if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map) mapData = decoded;
      } on FormatException catch (e, st) {
        Log.error('Failed to parse build number JSON', e: e, s: st);
      }
    }

    if (mapData != null) {
      for (final item in mapData.entries) {
        final architecture = _architectureFromString(item.key.toString());
        if (architecture != null) {
          result[architecture] = item.value is num
              ? (item.value as num).toInt()
              : 0;
        }
      }
    }

    return result;
  }

  static Map<ArsitekturApk, String> _parseDownloadLinks(dynamic data) {
    final result = <ArsitekturApk, String>{};
    Map<dynamic, dynamic>? mapData;

    if (data is Map) {
      mapData = data;
    } else if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map) mapData = decoded;
      } on FormatException catch (e, st) {
        Log.error('Failed to parse download links JSON', e: e, s: st);
      }
    }

    if (mapData != null) {
      for (final item in mapData.entries) {
        final architecture = _architectureFromString(item.key.toString());
        if (architecture != null) {
          result[architecture] = item.value?.toString() ?? '';
        }
      }
    }

    return result;
  }

  // =========================
  // SQLITE
  // =========================

  factory VersiApkModel.fromSqlite(Map<String, dynamic> map) {
    return VersiApkModel(
      id: map[NamaKolom.id] as String,
      catatanRilis: map[NamaKolom.catatanRilis] as String? ?? '',
      versiTerkahir: map[NamaKolom.versiTerkahir] as String? ?? '',
      linkYoutubeTutorial: map[NamaKolom.linkYoutubeTutorial] as String? ?? '',
      wajibUpdate: ParserUtil.parseBool(map[NamaKolom.wajibUpdate]),
      diHapus: ParserUtil.parseBool(map[NamaKolom.dihapus]),
      nomorBuildTerakhir: _parseBuildNumber(map[NamaKolom.nomorBuildTerakhir]),
      linkDownload: _parseDownloadLinks(map[NamaKolom.linkDownload]),
      diarsipkanPada: ParserUtil.parseDateTime(map[NamaKolom.diarsipkanPada]),
      diperbaruiPada: ParserUtil.parseDateTime(map[NamaKolom.diperbaruiPada]),
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      NamaKolom.id: id,
      NamaKolom.catatanRilis: catatanRilis,
      NamaKolom.versiTerkahir: versiTerkahir,
      NamaKolom.linkYoutubeTutorial: linkYoutubeTutorial,
      NamaKolom.diarsipkanPada: diarsipkanPada?.millisecondsSinceEpoch,
      NamaKolom.diperbaruiPada:
          (diperbaruiPada ?? DateTime.now()).millisecondsSinceEpoch,
      NamaKolom.nomorBuildTerakhir: jsonEncode(
        nomorBuildTerakhir.map((key, value) => MapEntry(key.name, value)),
      ),
      NamaKolom.linkDownload: jsonEncode(
        linkDownload.map((key, value) => MapEntry(key.name, value)),
      ),
      NamaKolom.wajibUpdate: wajibUpdate ? 1 : 0,
      NamaKolom.dihapus: diHapus ? 1 : 0,
    };
  }

  // =========================
  // FIREBASE
  // =========================

  factory VersiApkModel.fromFirebase(String id, Map<String, dynamic> map) {
    return VersiApkModel(
      id: id,
      catatanRilis: map[NamaKolom.catatanRilis] as String? ?? '',
      versiTerkahir: map[NamaKolom.versiTerkahir] as String? ?? '',
      linkYoutubeTutorial: map[NamaKolom.linkYoutubeTutorial] as String? ?? '',
      wajibUpdate: ParserUtil.parseBool(map[NamaKolom.wajibUpdate]),
      diHapus: ParserUtil.parseBool(map[NamaKolom.dihapus]),
      nomorBuildTerakhir: _parseBuildNumber(map[NamaKolom.nomorBuildTerakhir]),
      linkDownload: _parseDownloadLinks(map[NamaKolom.linkDownload]),
      diarsipkanPada: ParserUtil.parseDateTime(map[NamaKolom.diarsipkanPada]),
      diperbaruiPada: ParserUtil.parseDateTime(map[NamaKolom.diperbaruiPada]),
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      NamaKolom.id: id,
      NamaKolom.catatanRilis: catatanRilis,
      NamaKolom.versiTerkahir: versiTerkahir,
      NamaKolom.linkYoutubeTutorial: linkYoutubeTutorial,
      NamaKolom.diperbaruiPada: Timestamp.fromDate(
        (diperbaruiPada ?? DateTime.now()).toUtc(),
      ),
      NamaKolom.diarsipkanPada: diarsipkanPada != null
          ? Timestamp.fromDate(diarsipkanPada!.toUtc())
          : null,
      NamaKolom.nomorBuildTerakhir: nomorBuildTerakhir.map(
        (key, value) => MapEntry(key.name, value),
      ),
      NamaKolom.linkDownload: linkDownload.map(
        (key, value) => MapEntry(key.name, value),
      ),
      NamaKolom.wajibUpdate: wajibUpdate,
      NamaKolom.dihapus: diHapus,
    };
  }
}
```

### File: `lib/fitur/versi_apk/operasi/versi_apk_op_firebase.dart`
```dart
// path: lib/fitur/versi_apk/operasi/versi_apk_op_firebase.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/fitur/versi_apk/model/versi_apk_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';

class VersiApkOpFirebase {
  final FirebaseFirestore _firestore;

  VersiApkOpFirebase({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  late final CollectionReference<VersiApkModel> _koleksi = _firestore
      .collection(NamaTabel.versiApkUser)
      .withConverter<VersiApkModel>(
        fromFirestore: (snapshot, _) =>
            VersiApkModel.fromFirebase(snapshot.id, snapshot.data()!),
        toFirestore: (model, _) => model.toFirebase(),
      );

  Future<VersiApkModel?> ambilVersiTerbaru() async {
    Log.info('Memulai mengambil versi APK terbaru');
    try {
      final query = await _koleksi
          .where(NamaKolom.dihapus, isEqualTo: false)
          .where(NamaKolom.diarsipkanPada, isNull: true)
          .orderBy(NamaKolom.diperbaruiPada, descending: true)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data();
        Log.info('Versi APK terbaru berhasil diambil', data.toFirebase());
        return data;
      }
      Log.warning('Tidak ada versi APK aktif yang ditemukan');
      return null;
    } catch (e, st) {
      Log.error('Error saat mengambil versi APK', e: e, s: st);
      rethrow;
    }
  }
}
```

### File: `lib/fitur/versi_apk/operasi/versi_apk_op_sqlite.dart`
```dart
// path: lib/fitur/versi_apk/operasi/versi_apk_op_sqlite.dart

import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/info_perangkat/enum/arsitektur_apk.dart';
import 'package:wifi/fitur/versi_apk/model/versi_apk_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_op_sqlite.dart';

/// Kelas untuk operasi terkait data versi APK user di database lokal.
class VersiApkOpSqlite {
  final SqliteDatabase sqliteDb;
  final String _namaTabel = NamaTabel.versiApkUser;
  final BaseOpSqlite _baseOpSqlite;

  /// Konstruktor untuk [VersiApkOpSqlite].
  VersiApkOpSqlite({
    required final BaseOpSqlite baseOpSqlite,
    required this.sqliteDb,
  }) : _baseOpSqlite = baseOpSqlite {
    Log.info('VersiApkOpSqlite diinisialisasi - Tabel: $_namaTabel');
  }

  // =========================
  // OPERASI TULIS (WRITE)
  // =========================

  /// Menambah [VersiApkModel] baru ke database.
  Future<void> tambahVersiApk(
    final VersiApkModel apkVersion, {
    final bool dariServer = false,
  }) async {
    Log.info(
      'Menambah versi APK user baru - ID: ${apkVersion.id}, Versi: ${apkVersion.versiTerkahir}',
    );

    try {
      await _baseOpSqlite.sisipkan(
        _namaTabel,
        apkVersion.toSqlite(),
        dariServer: dariServer,
      );
      Log.info(
        'Versi APK user berhasil ditambahkan ke tabel $_namaTabel - ID: ${apkVersion.id}',
      );
    } catch (e, st) {
      Log.error(
        'Gagal menambah versi APK user - ID: ${apkVersion.id}, Versi: ${apkVersion.versiTerkahir}',
        e: e,
        s: st,
      );
      rethrow;
    }
  }

  /// Memperbarui [VersiApkModel] yang ada di database.
  Future<void> perbaruiVersiApk(
    final VersiApkModel versiApk, {
    final bool dariServer = false,
  }) async {
    Log.info(
      'Memperbarui versi APK user - ID: ${versiApk.id}, Versi: ${versiApk.versiTerkahir}',
    );

    try {
      await _baseOpSqlite.update(
        _namaTabel,
        versiApk.toSqlite(),
        versiApk.id,
        dariServer: dariServer,
      );
      Log.info(
        'Versi APK user berhasil diperbarui di tabel $_namaTabel - ID: ${versiApk.id}',
      );
    } catch (e, st) {
      Log.error(
        'Gagal memperbarui versi APK user - ID: ${versiApk.id}, Versi: ${versiApk.versiTerkahir}',
        e: e,
        s: st,
      );
      rethrow;
    }
  }

  /// Melakukan soft delete pada [VersiApkModel] berdasarkan [id].
  Future<void> softDelete(
    final String id, {
    final bool dariServer = false,
  }) async {
    Log.info('Memulai soft delete untuk versi APK ID: $id');
    try {
      await _baseOpSqlite.softDelete(_namaTabel, id, dariServer: dariServer);
      Log.info('Soft delete untuk versi APK ID: $id selesai.');
    } on Exception catch (e, st) {
      Log.error(
        'Gagal melakukan soft delete pada APK version ID: $id',
        e: e,
        s: st,
      );
      rethrow;
    }
  }

  /// Melakukan soft delete untuk semua [VersiApkModel] yang aktif.
  Future<int> softDeleteAll({final bool dariServer = false}) async {
    Log.info('Memulai proses soft delete untuk SEMUA versi APK aktif');
    try {
      final jumlah = await _baseOpSqlite.softDeleteAll(
        _namaTabel,
        dariServer: dariServer,
      );
      Log.info('Proses soft delete semua APK versions selesai. Total: $jumlah');
      return jumlah;
    } catch (e, st) {
      Log.error(
        'Gagal melakukan soft delete untuk semua APK versions',
        e: e,
        s: st,
      );
      rethrow;
    }
  }

  /// Menyisipkan atau memperbarui sekumpulan [VersiApkModel] dalam satu batch.
  Future<void> sisipkanAtauPerbaruiBatch(
    final List<VersiApkModel> daftarVersiApk, {
    final bool dariServer = false,
  }) async {
    Log.info(
      'Memulai operasi batch insert/update - Jumlah data: ${daftarVersiApk.length}, Tabel: $_namaTabel',
    );

    if (daftarVersiApk.isEmpty) {
      Log.info('Daftar model kosong, tidak ada data yang diproses dalam batch');
      return;
    }

    try {
      final daftarMap = daftarVersiApk
          .map((final model) => model.toSqlite())
          .toList();
      await _baseOpSqlite.sisipkanAtauPerbaruiBatch(
        _namaTabel,
        daftarMap,
        dariServer: dariServer,
      );
      Log.info(
        'Operasi batch berhasil - ${daftarMap.length} data diproses di tabel $_namaTabel',
      );
    } catch (e, st) {
      Log.error(
        'Gagal melakukan operasi batch - Jumlah data: ${daftarVersiApk.length}, Tabel: $_namaTabel',
        e: e,
        s: st,
      );
      rethrow;
    }
  }

  // =========================
  // OPERASI BACA (READ)
  // =========================

  /// Mengambil semua versi APK dari database.
  Future<List<VersiApkModel>> ambilSemuaVersiApk() async {
    Log.info(
      'Mengambil semua data versi APK dari tabel $_namaTabel (termasuk yang diarsipkan)',
    );

    try {
      final db = await sqliteDb.database;
      const orderBy = '${NamaKolom.diperbaruiPada} DESC';
      Log.info('Query: SELECT * FROM $_namaTabel ORDER BY $orderBy');

      final List<Map<String, dynamic>> maps = await db.query(
        _namaTabel,
        orderBy: orderBy,
      );

      final hasil = List.generate(
        maps.length,
        (i) => VersiApkModel.fromSqlite(maps[i]),
      );

      var jumlahAktif = 0;
      var jumlahArsip = 0;
      for (final model in hasil) {
        if (model.diHapus) {
          jumlahArsip++;
        } else {
          jumlahAktif++;
        }
      }

      Log.info(
        'Berhasil mengambil ${hasil.length} data versi APK - Aktif: $jumlahAktif, Diarsipkan: $jumlahArsip',
      );
      return hasil;
    } catch (e, st) {
      Log.error(
        'Gagal mengambil semua data versi APK dari tabel $_namaTabel, mengembalikan list kosong',
        e: e,
        s: st,
      );
      return [];
    }
  }

  /// Mengambil semua versi APK yang aktif dari database.
  Future<List<VersiApkModel>> ambilSemuaVersiApkAktif() async {
    Log.info(
      'Mengambil semua versi APK aktif (${NamaKolom.dihapus} = 0) dari tabel $_namaTabel',
    );

    try {
      final db = await sqliteDb.database;
      const where = '${NamaKolom.dihapus} = 0';
      const orderBy = '${NamaKolom.diperbaruiPada} DESC';
      Log.info(
        'Query: SELECT * FROM $_namaTabel WHERE $where ORDER BY $orderBy',
      );

      final maps = await db.query(_namaTabel, where: where, orderBy: orderBy);

      final hasil = List.generate(
        maps.length,
        (i) => VersiApkModel.fromSqlite(maps[i]),
      );

      Log.info('Berhasil mengambil ${hasil.length} versi APK aktif');

      for (var i = 0; i < (hasil.length < 3 ? hasil.length : 3); i++) {
        final v = hasil[i];
        Log.info(
          '  ${i + 1}. ID: ${v.id}, Versi: ${v.versiTerkahir}, Build Universal: ${v.nomorBuildTerakhir[ArsitekturApk.universal] ?? 0}',
        );
      }

      return hasil;
    } catch (e, st) {
      Log.error(
        'Gagal mengambil versi APK aktif dari tabel $_namaTabel, mengembalikan list kosong',
        e: e,
        s: st,
      );
      return [];
    }
  }

  /// Mengambil versi APK terbaru yang aktif dari database.
  Future<VersiApkModel?> ambilVersiApkTerakhir() async {
    Log.info('Mengambil versi APK terbaru (aktif) dari tabel $_namaTabel');

    try {
      final db = await sqliteDb.database;
      const where = '${NamaKolom.dihapus} = 0';
      const orderBy = '${NamaKolom.diperbaruiPada} DESC';
      Log.info(
        'Query: SELECT * FROM $_namaTabel WHERE $where ORDER BY $orderBy LIMIT 1',
      );

      final maps = await db.query(
        _namaTabel,
        where: where,
        orderBy: orderBy,
        limit: 1,
      );

      if (maps.isNotEmpty) {
        final model = VersiApkModel.fromSqlite(maps.first);
        Log.info(
          'Versi APK terbaru ditemukan - ID: ${model.id}, Versi: ${model.versiTerkahir}, Build Universal: ${model.nomorBuildTerakhir[ArsitekturApk.universal] ?? 0}, Diperbarui: ${model.diperbaruiPada?.toIso8601String()}',
        );
        return model;
      } else {
        Log.info(
          'Tidak ada versi APK aktif yang ditemukan di tabel $_namaTabel',
        );
        return null;
      }
    } catch (e, st) {
      Log.error(
        'Gagal mengambil versi APK terbaru dari tabel $_namaTabel, mengembalikan null',
        e: e,
        s: st,
      );
      return null;
    }
  }

  /// Mengambil [VersiApkModel] berdasarkan [id].
  Future<VersiApkModel?> ambilBerdasarkanId(String id) async {
    Log.info('Mengambil versi APK by ID: $id dari tabel $_namaTabel');

    try {
      final db = await sqliteDb.database;
      const where = 'id = ? AND ${NamaKolom.dihapus} = 0';
      Log.info('Query: SELECT * FROM $_namaTabel WHERE $where');

      final maps = await db.query(_namaTabel, where: where, whereArgs: [id]);

      if (maps.isNotEmpty) {
        final model = VersiApkModel.fromSqlite(maps.first);
        Log.info(
          'Versi APK ditemukan - ID: $id, Versi: ${model.versiTerkahir}, Build Universal: ${model.nomorBuildTerakhir[ArsitekturApk.universal] ?? 0}, Catatan: ${model.catatanRilis.length > 50 ? "${model.catatanRilis.substring(0, 50)}..." : model.catatanRilis}',
        );
        return model;
      } else {
        Log.info(
          'Versi APK dengan ID: $id tidak ditemukan (mungkin sudah diarsipkan atau tidak ada)',
        );
        return null;
      }
    } catch (e, st) {
      Log.error(
        'Gagal mengambil versi APK by ID: $id dari tabel $_namaTabel, mengembalikan null',
        e: e,
        s: st,
      );
      return null;
    }
  }
}
```

### File: `lib/fitur/versi_apk/page/detail_versi_apk.dart`
```dart
// path: lib/fitur/versi_apk/page/detail_versi_apk.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/versi_apk/model/versi_apk_model.dart';
import 'package:wifi/fitur/versi_apk/operasi/versi_apk_op_sqlite.dart';
import 'package:wifi/fitur/versi_apk/page/form_versi_apk.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/theme/app_sizes.dart';
import 'package:wifi/shared/theme/app_theme.dart';
import 'package:wifi/shared/utils/toast_util.dart';

class DetailVersiApk extends ConsumerStatefulWidget {
  final VersiApkModel versiApk;
  final VersiApkOpSqlite? versiApkOPSqlite;

  const DetailVersiApk({
    super.key,
    required this.versiApk,
    this.versiApkOPSqlite,
  });

  @override
  ConsumerState<DetailVersiApk> createState() => _DetailVersiApkState();
}

class _DetailVersiApkState extends ConsumerState<DetailVersiApk> {
  late VersiApkModel _versiApk;
  late final VersiApkOpSqlite _versiApkOpSqlite;

  @override
  void initState() {
    super.initState();
    _versiApk = widget.versiApk;
    _versiApkOpSqlite =
        widget.versiApkOPSqlite ?? ref.read(versiApkOpSqliteProvider);
  }

  Future<void> _bukaFormEdit() async {
    Log.info('Tombol edit APK ditekan, versi=${_versiApk.versiTerkahir}');
    final hasil = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => FormVersiApk(
          versiApk: _versiApk,
          versiApkOpSqlite: _versiApkOpSqlite,
        ),
      ),
    );

    if ((hasil ?? false) && mounted) {
      Log.info('Edit APK selesai dengan perubahan, memuat ulang data...');
      unawaited(_reloadData());
    } else {
      Log.info('Edit APK dibatalkan atau tanpa perubahan');
    }
  }

  Future<void> _reloadData() async {
    Log.info('Memuat ulang data untuk ID: ${_versiApk.id}');
    try {
      final daftarVersiApk = await _versiApkOpSqlite.ambilSemuaVersiApkAktif();
      final freshData = daftarVersiApk.firstWhere(
        (data) => data.id == _versiApk.id,
        orElse: () => _versiApk,
      );

      if (mounted) {
        setState(() {
          _versiApk = freshData;
        });
        ToastUtil.success(context, 'Data detail telah diperbarui.');
      }
    } catch (e, st) {
      Log.error('Gagal memuat ulang data APK', e: e, s: st);
      if (mounted) {
        ToastUtil.error(context, 'Gagal memuat ulang data detail.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Log.info('Membangun halaman detail versi APK: ${_versiApk.versiTerkahir}.');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Versi APK'),
        actions: [
          IconButton(
            icon: const Icon(TIcons.edit),
            tooltip: 'Edit Data',
            onPressed: _bukaFormEdit,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(TSizes.p16),
        children: [
          _buildInfoRow('Versi Terbaru', _versiApk.versiTerkahir),
          _buildInfoRow('Wajib Update', _versiApk.wajibUpdate ? 'Ya' : 'Tidak'),
          _buildInfoRow('Catatan Rilis', _versiApk.catatanRilis),
          gapH16,
          Text(
            'Nomor Build Terbaru',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          ..._versiApk.nomorBuildTerakhir.entries.map(
            (entry) => _buildInfoRow(entry.key.name, entry.value.toString()),
          ),
          gapH16,
          Text(
            'Tautan Unduhan',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          ..._versiApk.linkDownload.entries.map(
            (entry) => _buildInfoRow(entry.key.name, entry.value),
          ),
          gapH16,
          _buildInfoRow('Youtube Tutorial', _versiApk.linkYoutubeTutorial),
        ],
      ),
    );
  }

  Widget _buildInfoRow(final String label, final String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TSizes.p8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(': ', style: context.textTheme.bodyMedium),
          Flexible(child: Text(value, style: context.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
```

### File: `lib/fitur/versi_apk/page/form_versi_apk.dart`
```dart
// path: lib/fitur/versi_apk/page/form_versi_apk.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/info_perangkat/enum/arsitektur_apk.dart';
import 'package:wifi/fitur/sinkronisasi/layanan_cek_sinkronisasi.dart';
import 'package:wifi/fitur/versi_apk/model/versi_apk_model.dart';
import 'package:wifi/fitur/versi_apk/operasi/versi_apk_op_sqlite.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/theme/app_sizes.dart';
import 'package:wifi/shared/theme/app_theme.dart';
import 'package:wifi/shared/utils/toast_util.dart';

class FormVersiApk extends ConsumerStatefulWidget {
  final VersiApkModel? versiApk;

  const FormVersiApk({
    super.key,
    this.versiApk,
    final VersiApkOpSqlite? versiApkOpSqlite,
  });
  @override
  ConsumerState<FormVersiApk> createState() => _FormVersiApkState();
}

class _FormVersiApkState extends ConsumerState<FormVersiApk> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool get _modeEdit => widget.versiApk != null;
  late TextEditingController _releaseNotesController;
  late TextEditingController _latestVersionController;
  late TextEditingController _youtubeTutorialController;
  late bool _perluUpdate;
  late TextEditingController _buildUniversalController;
  late TextEditingController _build32Controller;
  late TextEditingController _build64Controller;
  late TextEditingController _universalLinkController;
  late TextEditingController _link32Controller;
  late TextEditingController _link64Controller;
  final _latestVersionFocusNode = FocusNode();
  final _buildUniversalFocusNode = FocusNode();
  final _build32FocusNode = FocusNode();
  final _build64FocusNode = FocusNode();
  final _universalLinkFocusNode = FocusNode();
  final _link32FocusNode = FocusNode();
  final _link64FocusNode = FocusNode();
  final _releaseNotesFocusNode = FocusNode();
  final _youtubeTutorialFocusNode = FocusNode();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Log.info(
      'Menginisialisasi ApkVersionForm (Mode: ${_modeEdit ? 'Edit' : 'Tambah'})',
    );
    _releaseNotesController = TextEditingController();
    _latestVersionController = TextEditingController();
    _youtubeTutorialController = TextEditingController();
    _perluUpdate = false;
    _buildUniversalController = TextEditingController();
    _build32Controller = TextEditingController();
    _build64Controller = TextEditingController();
    _universalLinkController = TextEditingController();
    _link32Controller = TextEditingController();
    _link64Controller = TextEditingController();
    if (_modeEdit) {
      _populateControllers(widget.versiApk!);
    } else {
      unawaited(_muatDataVersiTerakhir());
    }
  }

  Future<void> _muatDataVersiTerakhir() async {
    final apkVersionOperasi = ref.read(versiApkOpSqliteProvider);
    Log.info('Memuat data rilis terakhir untuk otomatisasi input.');
    setState(() => _loading = true);
    try {
      final versiTerakhir = await apkVersionOperasi.ambilVersiApkTerakhir();
      if (versiTerakhir != null && mounted) {
        _latestVersionController.text = versiTerakhir.versiTerkahir;
        _youtubeTutorialController.text = versiTerakhir.linkYoutubeTutorial;
        final buildUniversalBerikutnya =
            (versiTerakhir.nomorBuildTerakhir[ArsitekturApk.universal] ?? 0) +
            1;
        final buildBit32Berikutnya =
            (versiTerakhir.nomorBuildTerakhir[ArsitekturApk.bit32] ?? 0) + 1;
        final buildBit64Berikutnya =
            (versiTerakhir.nomorBuildTerakhir[ArsitekturApk.bit64] ?? 0) + 1;
        _buildUniversalController.text = buildUniversalBerikutnya.toString();
        _build32Controller.text = buildBit32Berikutnya.toString();
        _build64Controller.text = buildBit64Berikutnya.toString();
        Log.info(
          'Data rilis sebelumnya ditemukan. Menyarankan build: $buildUniversalBerikutnya dan menyalin link tutorial.',
        );
      }
    } on Exception catch (e, s) {
      Log.error('Gagal memuat data versi terakhir', e: e, s: s);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _populateControllers(VersiApkModel data) {
    Log.info('Memasukkan data model ke dalam form controller (ID: ${data.id})');
    _releaseNotesController.text = data.catatanRilis;
    _latestVersionController.text = data.versiTerkahir;
    _youtubeTutorialController.text = data.linkYoutubeTutorial;
    _perluUpdate = data.wajibUpdate;
    _buildUniversalController.text =
        data.nomorBuildTerakhir[ArsitekturApk.universal]?.toString() ?? '';
    _build32Controller.text =
        data.nomorBuildTerakhir[ArsitekturApk.bit32]?.toString() ?? '';
    _build64Controller.text =
        data.nomorBuildTerakhir[ArsitekturApk.bit64]?.toString() ?? '';
    _universalLinkController.text =
        data.linkDownload[ArsitekturApk.universal] ?? '';
    _link32Controller.text = data.linkDownload[ArsitekturApk.bit32] ?? '';
    _link64Controller.text = data.linkDownload[ArsitekturApk.bit64] ?? '';
  }

  @override
  void dispose() {
    Log.info('Menghapus semua controller dan focus node (dispose)');
    _releaseNotesController.dispose();
    _latestVersionController.dispose();
    _youtubeTutorialController.dispose();
    _buildUniversalController.dispose();
    _build32Controller.dispose();
    _build64Controller.dispose();
    _universalLinkController.dispose();
    _link32Controller.dispose();
    _link64Controller.dispose();
    _latestVersionFocusNode.dispose();
    _buildUniversalFocusNode.dispose();
    _build32FocusNode.dispose();
    _build64FocusNode.dispose();
    _universalLinkFocusNode.dispose();
    _link32FocusNode.dispose();
    _link64FocusNode.dispose();
    _releaseNotesFocusNode.dispose();
    _youtubeTutorialFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    final apkVersionOperasi = ref.read(versiApkOpSqliteProvider);
    if (!_formKey.currentState!.validate()) {
      unawaited(
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      Log.info('Menampilkan dialog konfirmasi kepada pengguna');
      FocusScope.of(context).unfocus();
      final konfirmasi = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(TIcons.infoOutlined, color: context.colorScheme.primary),
              gapW12,
              const Text('Konfirmasi Simpan'),
            ],
          ),
          content: const Text(
            'Apakah data versi aplikasi yang Anda masukkan sudah benar?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Periksa Kembali'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Ya, Simpan'),
            ),
          ],
        ),
      );
      if (konfirmasi != true) {
        Log.info('Pengguna membatalkan proses penyimpanan');
        return;
      }
      if (!mounted) return;
      setState(() => _loading = true);
      Log.info('Sedang memproses penyimpanan ke database...');

      final nomorBuild = <ArsitekturApk, int>{};
      if (_buildUniversalController.text.isNotEmpty) {
        nomorBuild[ArsitekturApk.universal] = int.parse(
          _buildUniversalController.text,
        );
      }
      if (_build32Controller.text.isNotEmpty) {
        nomorBuild[ArsitekturApk.bit32] = int.parse(_build32Controller.text);
      }
      if (_build64Controller.text.isNotEmpty) {
        nomorBuild[ArsitekturApk.bit64] = int.parse(_build64Controller.text);
      }

      final tautanUnduhan = <ArsitekturApk, String>{};
      if (_universalLinkController.text.isNotEmpty) {
        tautanUnduhan[ArsitekturApk.universal] = _universalLinkController.text;
      }
      if (_link32Controller.text.isNotEmpty) {
        tautanUnduhan[ArsitekturApk.bit32] = _link32Controller.text;
      }
      if (_link64Controller.text.isNotEmpty) {
        tautanUnduhan[ArsitekturApk.bit64] = _link64Controller.text;
      }
      final dataToSave = VersiApkModel(
        id: widget.versiApk?.id ?? const Uuid().v4(),
        catatanRilis: _releaseNotesController.text,
        versiTerkahir: _latestVersionController.text,
        linkYoutubeTutorial: _youtubeTutorialController.text,
        wajibUpdate: _perluUpdate,
        nomorBuildTerakhir: nomorBuild,
        linkDownload: tautanUnduhan,
      );
      Log.info('Model Versi APK yang akan disimpan: ${dataToSave.toSqlite()}');
      try {
        if (_modeEdit) {
          Log.info('Menjalankan perintah update data...');
          await apkVersionOperasi.perbaruiVersiApk(dataToSave);
        } else {
          Log.info('Menjalankan perintah tambah data baru...');
          await apkVersionOperasi.tambahVersiApk(dataToSave);
        }
        unawaited(
          ref.read(layananCekSinkronisasiProvider).jalankanCekSinkronisasi(),
        );
        Log.info('Proses penyimpanan berhasil diselesaikan');
        if (!mounted) return;
        Navigator.of(context).pop(true);
      } on Exception catch (e, s) {
        Log.error('Terjadi kesalahan saat menyimpan data', e: e, s: s);
        if (!mounted) return;
        ToastUtil.error(context, 'Gagal menyimpan data: $e');
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_modeEdit ? 'Edit Versi APK' : 'Tambah Versi APK'),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                TSizes.p16,
                TSizes.p16,
                TSizes.p16,
                TSizes.p80,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _latestVersionController,
                    focusNode: _latestVersionFocusNode,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Versi Terbaru (Contoh: 1.0.0)',
                      prefixIcon: Icon(TIcons.infoOutlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (final v) => v!.isEmpty ? 'Wajib diisi' : null,
                    onFieldSubmitted: (final _) {
                      FocusScope.of(
                        context,
                      ).requestFocus(_buildUniversalFocusNode);
                    },
                  ),
                  gapH24,
                  _buildSectionTitle('Nomor Build'),
                  _buildNumberField(
                    _buildUniversalController,
                    'Build Universal',
                    _buildUniversalFocusNode,
                    _build32FocusNode,
                  ),
                  _buildNumberField(
                    _build32Controller,
                    'Build 32-bit',
                    _build32FocusNode,
                    _build64FocusNode,
                  ),
                  _buildNumberField(
                    _build64Controller,
                    'Build 64-bit',
                    _build64FocusNode,
                    _universalLinkFocusNode,
                  ),
                  gapH24,
                  _buildSectionTitle('Tautan Unduhan'),
                  _buildUrlField(
                    _universalLinkController,
                    'Tautan Universal',
                    _universalLinkFocusNode,
                    _link32FocusNode,
                  ),
                  _buildUrlField(
                    _link32Controller,
                    'Tautan 32-bit',
                    _link32FocusNode,
                    _link64FocusNode,
                  ),
                  _buildUrlField(
                    _link64Controller,
                    'Tautan 64-bit',
                    _link64FocusNode,
                    _releaseNotesFocusNode,
                  ),
                  gapH24,
                  TextFormField(
                    controller: _releaseNotesController,
                    focusNode: _releaseNotesFocusNode,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Catatan Rilis',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (final v) => v!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  gapH16,
                  TextFormField(
                    controller: _youtubeTutorialController,
                    focusNode: _youtubeTutorialFocusNode,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'URL Tutorial YouTube',
                      prefixIcon: Icon(TIcons.youtube, color: Colors.red),
                      border: OutlineInputBorder(),
                    ),
                    onFieldSubmitted: (_) => _saveForm(),
                  ),
                  SwitchListTile(
                    title: const Text('Wajib Update'),
                    value: _perluUpdate,
                    onChanged: (value) {
                      Log.info('Switch Wajib Update diubah ke: $value');
                      setState(() => _perluUpdate = value);
                    },
                  ),
                ],
              ),
            ),
          ),
          if (_loading)
            ColoredBox(
              color: Colors.black.withAlpha(128),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    gapH12,
                    Text(
                      'Menyimpan...',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(TSizes.p16),
        child: ElevatedButton(
          onPressed: _loading ? null : _saveForm,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: TSizes.p16),
          ),
          child: const Text('SIMPAN DATA RILIS'),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(final String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: TSizes.p8),
      child: Text(
        title,
        style: context.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: context.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildNumberField(
    final TextEditingController controller,
    final String label,
    final FocusNode focusNode,
    final FocusNode? nextFocusNode,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: TSizes.p12),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        textInputAction: nextFocusNode != null
            ? TextInputAction.next
            : TextInputAction.done,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        onFieldSubmitted: (final _) {
          if (nextFocusNode != null) {
            FocusScope.of(context).requestFocus(nextFocusNode);
          }
        },
      ),
    );
  }

  Widget _buildUrlField(
    final TextEditingController controller,
    final String label,
    final FocusNode focusNode,
    final FocusNode? nextFocusNode,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: TSizes.p12),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        textInputAction: nextFocusNode != null
            ? TextInputAction.next
            : TextInputAction.done,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(TIcons.link),
        ),
        keyboardType: TextInputType.url,
        onFieldSubmitted: (final _) {
          if (nextFocusNode != null) {
            FocusScope.of(context).requestFocus(nextFocusNode);
          }
        },
      ),
    );
  }
}
```

### File: `lib/fitur/versi_apk/page/update_apk_page_u.dart`
```dart
// path: lib/fitur/versi_apk/page/update_apk_page_u.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wifi/fitur/info_perangkat/enum/arsitektur_apk.dart';
import 'package:wifi/fitur/info_perangkat/model/info_perangkat_model.dart';
import 'package:wifi/fitur/versi_apk/model/versi_apk_model.dart';
import 'package:wifi/fitur/versi_apk/service/update_service.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/theme/app_sizes.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/user/page/login_page.dart';
import 'package:wifi/user/page/main_page.dart';
import 'package:wifi/user/providers/user_provider.dart';

class UpdateApkPage extends ConsumerStatefulWidget {
  final VersiApkModel infoApk;
  final InfoPerangkatModel infoPaket;
  final ArsitekturApk arsitektur;

  const UpdateApkPage({
    super.key,
    required this.infoApk,
    required this.infoPaket,
    required this.arsitektur,
  });

  @override
  ConsumerState<UpdateApkPage> createState() => _UpdateApkPageState();
}

class _UpdateApkPageState extends ConsumerState<UpdateApkPage>
    with SingleTickerProviderStateMixin {
  late final List<String> _changelog;
  final UpdateService _updateService = UpdateService();

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // State untuk melacak progres unduhan
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  final String _ukuranFile = 'Memeriksa...'; // Placeholder awal

  @override
  void initState() {
    super.initState();
    _inisialisasiAnimasi();
    FlutterNativeSplash.remove();
    _changelog = widget.infoApk.catatanRilis
        .split('\n')
        .map((final e) => e.trim())
        .where((final e) => e.isNotEmpty)
        .toList();
    _pulseController.repeat(reverse: true);
    // TODO: Implementasi pengambilan ukuran file jika memungkinkan
  }

  void _inisialisasiAnimasi() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _unduhPembaruan() async {
    final urlUnduh =
        widget.infoApk.linkDownload[widget.arsitektur] ??
        widget.infoApk.linkDownload[ArsitekturApk.universal];

    if (urlUnduh == null || urlUnduh.isEmpty) {
      if (mounted) {
        ToastUtil.error(context, 'Link download belum tersedia.');
      }
      return;
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    final namaFile = 'update_v${widget.infoApk.versiTerkahir}.apk';

    try {
      await _updateService.downloadDanInstallApk(
        url: urlUnduh,
        namaFile: namaFile,
        onProgress: (final progress) {
          setState(() {
            _downloadProgress = progress;
          });
        },
      );
      // Jika berhasil, instalasi akan dimulai oleh service.
      // Reset state jika pengguna kembali ke halaman ini.
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    } on Exception catch (e, st) {
      Log.error('Gagal mengunduh atau install pembaruan', e: e, s: st);
      if (mounted) {
        ToastUtil.error(context, e.toString());
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  Future<void> _bukaTutorial() async {
    final url = widget.infoApk.linkYoutubeTutorial;
    if (url.isEmpty) {
      if (mounted) {
        ToastUtil.info(context, 'Link tutorial belum tersedia.');
      }
      return;
    }
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch $url');
      }
    } on Exception catch (e, st) {
      Log.error('Gagal membuka URL Tutorial', e: e, s: st);
      if (mounted) {
        ToastUtil.error(context, 'Gagal membuka link tutorial.');
      }
    }
  }

  Future<void> _lewatiUpdateDanNavigasi() async {
    final userId = await ref.watch(userIdProvider.future);
    if (userId != null) {
      Log.info('Pengguna sudah login. Mengalihkan ke MainPage.');
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const MainPage()),
      );
    } else {
      if (!mounted) return;

      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: ((_) => const LoginPage())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            gapH12,
            _buildAnimasiHeader(),
            gapH32,
            _buildKartuVersi(),
            gapH20,
            _buildKartuStatusUpdate(),
            gapH24,
            _buildTombolAksi(),
            gapH20,
            if (_changelog.isNotEmpty) _buildChangelogCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildTombolAksi() {
    final perluUpdate = widget.infoApk.wajibUpdate;
    final adaTutorial = widget.infoApk.linkYoutubeTutorial.isNotEmpty;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton.icon(
            onPressed: _isDownloading ? null : _unduhPembaruan,
            icon: _isDownloading
                ? const SizedBox.shrink()
                : const Icon(TIcons.downloadRounded, size: 24),
            label: _isDownloading
                ? const Text(
                    'Mengunduh...',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  )
                : const Text(
                    'Download Pembaruan',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
            style: FilledButton.styleFrom(
              backgroundColor: _isDownloading
                  ? Colors.grey
                  : const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
          ),
        ),
        if (!perluUpdate || adaTutorial) ...[
          gapH12,
          Row(
            children: [
              if (adaTutorial)
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _bukaTutorial,
                      icon: const Icon(TIcons.youtube, color: Colors.red),
                      label: const Text(
                        'Tutorial',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red.withAlpha(77)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ),
              if (adaTutorial && !perluUpdate) gapW12,
              if (!perluUpdate)
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      onPressed: _lewatiUpdateDanNavigasi,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Lewati',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              if (kDebugMode)
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      onPressed: _lewatiUpdateDanNavigasi,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Lewati',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildAnimasiHeader() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (final _, final child) {
        return Transform.scale(scale: _pulseAnimation.value, child: child);
      },
      child: Container(
        width: 130,
        height: 130,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6B6B).withAlpha(102),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Center(
          child: Icon(TIcons.systemUpdate, size: 65, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildKartuVersi() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildBarisVersi(
            icon: TIcons.phoneAndroid,
            iconColor: const Color(0xFF6C63FF),
            label: 'Versi Saat Ini',
            version: widget.infoPaket.versi.split('-').first,
            apakahSaatIni: true,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, thickness: 1),
          ),
          _buildBarisVersi(
            icon: TIcons.cloudDone,
            iconColor: Colors.orange,
            label: 'Versi Terbaru',
            version: widget.infoApk.versiTerkahir.split('-').first,
            apakahSaatIni: false,
            lencana: 'BARU',
          ),
        ],
      ),
    );
  }

  Widget _buildBarisVersi({
    required final IconData icon,
    required final Color iconColor,
    required final String label,
    required final String version,
    required final bool apakahSaatIni,
    final String? lencana,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withAlpha(26),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        gapW16,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              gapH4,
              Row(
                children: [
                  Text(
                    'v$version',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  if (lencana != null) ...[
                    gapW12,
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'BARU',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        if (apakahSaatIni)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withAlpha(26),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.withAlpha(77)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(TIcons.check, color: Colors.green, size: 16),
                gapW4,
                Text(
                  'Aktif',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildKartuStatusUpdate() {
    if (_isDownloading) {
      return _buildKontainerStatus(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mengunduh pembaruan...',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3142),
              ),
            ),
            gapH12,
            LinearProgressIndicator(
              value: _downloadProgress,
              minHeight: 12,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF6C63FF),
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            gapH8,
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${(_downloadProgress * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return _buildKontainerStatus(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              TIcons.warningAmber,
              color: Colors.orange,
              size: 22,
            ),
          ),
          gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pembaruan Tersedia!',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3142),
                  ),
                ),
                Text(
                  'Ukuran: $_ukuranFile',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKontainerStatus({required final Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withAlpha(38)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildChangelogCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B).withAlpha(26),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  TIcons.listAlt,
                  color: Color(0xFFFF6B6B),
                  size: 22,
                ),
              ),
              gapW12,
              const Text(
                'Apa yang Baru?',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
                ),
              ),
            ],
          ),
          gapH20,
          ..._changelog.map(
            (final item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6C63FF).withAlpha(102),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  gapW16,
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
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

### File: `lib/fitur/versi_apk/page/versi_apk_page.dart`
```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/info_perangkat/enum/arsitektur_apk.dart';
import 'package:wifi/fitur/versi_apk/model/versi_apk_model.dart';
import 'package:wifi/fitur/versi_apk/operasi/versi_apk_op_sqlite.dart';
import 'package:wifi/fitur/versi_apk/page/detail_versi_apk.dart';
import 'package:wifi/fitur/versi_apk/page/form_versi_apk.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/utils/toast_util.dart';

enum UrutanSortir { buildZA, buildAZ, versionZA, versionAZ }

class VersiApkPage extends ConsumerStatefulWidget {
  final VersiApkOpSqlite? operation;
  const VersiApkPage({super.key, this.operation});
  @override
  ConsumerState<VersiApkPage> createState() => _VersiApkState();
}

class _VersiApkState extends ConsumerState<VersiApkPage> {
  late final VersiApkOpSqlite _versiApkOpSqlite;
  List<VersiApkModel> _daftarVersiApk = [];
  bool _loading = true;
  String? _error;
  UrutanSortir _currentSort = UrutanSortir.buildZA;
  @override
  void initState() {
    super.initState();
    Log.info('Menginisialisasi halaman Versi APK User');
    _versiApkOpSqlite = ref.read(versiApkOpSqliteProvider);
    unawaited(_loadData());
  }

  void _sortList() {
    Log.info('Mengurutkan data berdasarkan: ${_getSortName(_currentSort)}');
    _daftarVersiApk.sort((final a, final b) {
      final buildA = a.nomorBuildTerakhir[ArsitekturApk.universal] ?? 0;
      final buildB = b.nomorBuildTerakhir[ArsitekturApk.universal] ?? 0;
      switch (_currentSort) {
        case UrutanSortir.buildZA:
          return buildB.compareTo(buildA);
        case UrutanSortir.buildAZ:
          return buildA.compareTo(buildB);
        case UrutanSortir.versionZA:
          return b.versiTerkahir.compareTo(a.versiTerkahir);
        case UrutanSortir.versionAZ:
          return a.versiTerkahir.compareTo(b.versiTerkahir);
      }
    });
  }

  Future<void> _loadData() async {
    Log.info('Memuat data versi APK aktif');
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final daftarVersi = await _versiApkOpSqlite.ambilSemuaVersiApkAktif();
      Log.info('Berhasil memuat ${daftarVersi.length} data versi APK aktif');
      if (!mounted) return;
      setState(() {
        _daftarVersiApk = daftarVersi;
        _sortList();
        _loading = false;
      });
    } on Exception catch (e, s) {
      Log.error('Gagal memuat data versi APK', e: e, s: s);
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat data: $e';
        _loading = false;
      });
    }
  }

  Future<void> _navigasiKeDetail(VersiApkModel versiApk) async {
    if (!mounted) return;
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (final context) => DetailVersiApk(
          versiApk: versiApk,
          versiApkOPSqlite: _versiApkOpSqlite,
        ),
      ),
    );
    Log.info('Kembali dari detail, memuat ulang data.');
    unawaited(_loadData());
  }

  Future<void> _bukaFormEdit(VersiApkModel versiApk) async {
    if (!mounted) return;
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => FormVersiApk(
          versiApk: versiApk,
          versiApkOpSqlite: _versiApkOpSqlite,
        ),
      ),
    );
    if ((result ?? false) && mounted) {
      ToastUtil.success(context, 'Data berhasil diperbarui.');
      unawaited(_loadData());
    }
  }

  Future<void> _navigasiKeForm() async {
    if (!mounted) return;
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (final context) =>
            FormVersiApk(versiApkOpSqlite: _versiApkOpSqlite),
      ),
    );
    if ((result ?? false) && mounted) {
      ToastUtil.success(context, 'Data baru berhasil ditambahkan.');
      unawaited(_loadData());
    }
  }

  Future<void> _tampilkanDialogUrutan() async {
    if (!mounted) return;
    final newSort = await showDialog<UrutanSortir>(
      context: context,
      builder: (final context) {
        return _SortDialog(currentSort: _currentSort);
      },
    );
    if (newSort != null && newSort != _currentSort) {
      setState(() {
        _currentSort = newSort;
        _sortList();
      });
    }
  }

  Future<void> _showOptionsDialog(VersiApkModel versi) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (c) => SimpleDialog(
        title: Text('Opsi Versi ${versi.versiTerkahir}'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(c);
              unawaited(_bukaFormEdit(versi));
            },
            child: const ListTile(
              leading: Icon(TIcons.edit),
              title: Text('Edit'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(c);
              unawaited(_showArchiveDialog(versi));
            },
            child: const ListTile(
              leading: Icon(TIcons.archive),
              title: Text('Arsipkan'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showArchiveDialog(VersiApkModel versi) async {
    if (!mounted) return;
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Arsipkan Versi APK?'),
        content: Text(
          'Anda yakin ingin mengarsipkan versi ${versi.versiTerkahir}?',
        ),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.pop(c, false),
          ),
          TextButton(
            child: const Text('Arsipkan'),
            onPressed: () => Navigator.pop(c, true),
          ),
        ],
      ),
    );
    if (konfirmasi ?? false) {
      unawaited(_softDelete(versi));
    }
  }

  Future<void> _softDelete(final VersiApkModel version) async {
    Log.info('Memulai proses soft delete untuk ID: ${version.id}');
    try {
      await _versiApkOpSqlite.softDelete(version.id);
      if (!mounted) return;
      setState(() {
        _daftarVersiApk.removeWhere((final v) => v.id == version.id);
      });
      ToastUtil.success(
        context,
        'Versi ${version.versiTerkahir} berhasil diarsipkan.',
      );
    } on Exception catch (e, s) {
      Log.error('Gagal soft delete data ID: ${version.id}', e: e, s: s);
      if (!mounted) return;
      ToastUtil.error(context, 'Gagal mengarsipkan: $e');
    }
  }

  Future<void> _softDeleteAll() async {
    if (!mounted) return;
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Arsipkan Semua Versi?'),
        content: const Text(
          'Anda yakin ingin mengarsipkan semua versi APK yang aktif?',
        ),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.pop(c, false),
          ),
          TextButton(
            child: const Text('Arsipkan Semua'),
            onPressed: () => Navigator.pop(c, true),
          ),
        ],
      ),
    );

    if (konfirmasi ?? false) {
      Log.info('Memulai proses soft delete untuk semua versi APK aktif');
      try {
        final count = await _versiApkOpSqlite.softDeleteAll();
        if (!mounted) return;
        ToastUtil.success(context, 'Berhasil mengarsipkan $count versi APK.');
        unawaited(_loadData());
      } catch (e, s) {
        Log.error('Gagal soft delete semua versi APK', e: e, s: s);
        if (!mounted) return;
        ToastUtil.error(context, 'Gagal mengarsipkan semua: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Versi APK'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.archive_outlined),
            onPressed: _softDeleteAll,
            tooltip: 'Arsipkan Semua',
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _tampilkanDialogUrutan,
            tooltip: 'Urutkan',
          ),
        ],
      ),
      body: _buildContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigasiKeForm,
        tooltip: 'Tambah Versi APK',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(_error!, textAlign: TextAlign.center),
        ),
      );
    }

    if (_daftarVersiApk.isEmpty) {
      return const Center(child: Text('Tidak ada data versi APK.'));
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        itemCount: _daftarVersiApk.length,
        itemBuilder: (context, index) {
          final apkVersion = _daftarVersiApk[index];
          final buildUniversal =
              apkVersion.nomorBuildTerakhir[ArsitekturApk.universal] ?? 0;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(
                'Versi: ${apkVersion.versiTerkahir} (Build: $buildUniversal)',
              ),
              subtitle: Text(
                apkVersion.catatanRilis,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => _navigasiKeDetail(apkVersion),
              onLongPress: () => _showOptionsDialog(apkVersion),
            ),
          );
        },
      ),
    );
  }
}

class _SortDialog extends StatefulWidget {
  const _SortDialog({required this.currentSort});
  final UrutanSortir currentSort;

  @override
  State<_SortDialog> createState() => _SortDialogState();
}

class _SortDialogState extends State<_SortDialog> {
  late UrutanSortir _selectedSort;

  @override
  void initState() {
    super.initState();
    _selectedSort = widget.currentSort;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Urutkan Berdasarkan'),
      content: RadioGroup<UrutanSortir>(
        groupValue: _selectedSort,
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedSort = value;
            });
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: UrutanSortir.values.map((final order) {
            return RadioListTile<UrutanSortir>(
              title: Text(_getSortName(order)),
              value: order,
            );
          }).toList(),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Batal'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text('OK'),
          onPressed: () => Navigator.of(context).pop(_selectedSort),
        ),
      ],
    );
  }
}

String _getSortName(final UrutanSortir order) {
  switch (order) {
    case UrutanSortir.buildZA:
      return 'Build (Terbaru ke Terlama)';
    case UrutanSortir.buildAZ:
      return 'Build (Terlama ke Terbaru)';
    case UrutanSortir.versionZA:
      return 'Versi (Z-A)';
    case UrutanSortir.versionAZ:
      return 'Versi (A-Z)';
  }
}

class RadioGroup<T> extends StatelessWidget {
  final T groupValue;
  final ValueChanged<T?> onChanged;
  final Widget child;
  const RadioGroup({
    super.key,
    required this.groupValue,
    required this.onChanged,
    required this.child,
  });

  @override
  Widget build(final BuildContext context) {
    return child;
  }
}
```

### File: `lib/fitur/versi_apk/service/layanan_cek_update_apk.dart`
```dart
// path: lib/fitur/versi_apk/service/layanan_cek_update_apk.dart

import 'dart:async';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/fitur/info_perangkat/enum/arsitektur_apk.dart';
import 'package:wifi/fitur/info_perangkat/model/info_perangkat_model.dart';
import 'package:wifi/fitur/info_perangkat/service/layanan_info_paket.dart';
import 'package:wifi/fitur/info_perangkat/service/layanan_info_perangkat.dart';
import 'package:wifi/fitur/versi_apk/model/versi_apk_model.dart';
import 'package:wifi/fitur/versi_apk/operasi/versi_apk_op_firebase.dart';
import 'package:wifi/fitur/versi_apk/page/update_apk_page_u.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/user/services/storage/layanan_penyimpanan_lokal.dart';

/// Kelas layanan untuk memeriksa pembaruan aplikasi.
class LayananCekUpdateApk {
  /// Konteks build untuk navigasi.
  final BuildContext? context;

  final SharedPreferences prefs;

  final LayananPenyimpananLokal penyimpananLokal;

  final LayananInfoPaket _layananInfoPaket = LayananInfoPaket();
  final LayananInfoPerangkat _layananInfoPerangkat;
  final VersiApkOpFirebase _versiApkOpFirebase = VersiApkOpFirebase();

  LayananCekUpdateApk({
    this.context,
    required this.prefs,
    required this.penyimpananLokal,
  }) : _layananInfoPerangkat = LayananInfoPerangkat(DeviceInfoPlugin()) {
    Log.info('UpdateCheckService diinisialisasi.');
  }

  /// Memeriksa pembaruan dan mengembalikan semua informasi yang relevan.
  Future<
    ({
      bool perluUpdate,
      VersiApkModel? infoApk,
      InfoPerangkatModel? infoPaket,
      ArsitekturApk? arsitektur,
    })
  >
  ambilInfoUpdate() async {
    Log.info('Memulai pengecekan informasi pembaruan lengkap.');
    try {
      final infoPaket = await _layananInfoPaket.ambilInfoPaket();
      if (infoPaket == null) {
        Log.warning('Gagal mendapatkan info paket lokal.');
        return (
          perluUpdate: false,
          infoApk: null,
          infoPaket: null,
          arsitektur: null,
        );
      }

      final infoPerangkat = await _layananInfoPerangkat
          .ambilArsitekturPerangkat();
      final arsitektur = _tentukanArsitektur(infoPerangkat);
      if (arsitektur == null) {
        Log.warning('Gagal menentukan arsitektur.');
        return (
          perluUpdate: false,
          infoApk: null,
          infoPaket: infoPaket,
          arsitektur: null,
        );
      }

      final apkTerbaru = await _versiApkOpFirebase.ambilVersiTerbaru();
      if (apkTerbaru == null) {
        Log.info('Tidak ada data versi APK di Firebase.');
        return (
          perluUpdate: false,
          infoApk: null,
          infoPaket: infoPaket,
          arsitektur: arsitektur,
        );
      }

      final nomorBuildSekarang = int.tryParse(infoPaket.nomorBuild) ?? 0;
      final nomorBuildTerbaru = apkTerbaru.nomorBuildTerakhir[arsitektur] ?? 0;
      Log.info('Perbandingan versi', {
        'buildSekarang': nomorBuildSekarang,
        'buildTerbaru': nomorBuildTerbaru,
        'arsitektur': arsitektur.name,
      });

      final perluUpdate = nomorBuildTerbaru > nomorBuildSekarang;
      return (
        perluUpdate: perluUpdate,
        infoApk: perluUpdate ? apkTerbaru : null,
        infoPaket: infoPaket,
        arsitektur: arsitektur,
      );
    } catch (e, st) {
      Log.error(
        'Terjadi kesalahan saat memeriksa ambilInfoUpdate.',
        e: e,
        s: st,
      );
      return (
        perluUpdate: false,
        infoApk: null,
        infoPaket: null,
        arsitektur: null,
      );
    }
  }

  /// Memeriksa pembaruan dan menavigasi jika perlu.
  Future<void> cekUpdateDanNavigasi() async {
    Log.info('Memulai proses pengecekan pembaruan dan navigasi.');
    if (context == null) {
      Log.error('BuildContext tidak tersedia untuk checkUpdateAndNavigate.');
      return;
    }
    final infoUpdate = await ambilInfoUpdate();
    if (infoUpdate.perluUpdate &&
        infoUpdate.infoApk != null &&
        infoUpdate.infoPaket != null &&
        infoUpdate.arsitektur != null) {
      Log.info('Pembaruan tersedia! Menavigasi ke halaman update.');
      if (context!.mounted) {
        unawaited(
          Navigator.of(context!).pushReplacement(
            MaterialPageRoute<void>(
              builder: (ctx) => UpdateApkPage(
                infoApk: infoUpdate.infoApk!,
                infoPaket: infoUpdate.infoPaket!,
                arsitektur: infoUpdate.arsitektur!,
              ),
            ),
          ),
        );
      }
    } else {
      Log.info('Aplikasi sudah versi terbaru. Tidak ada navigasi.');
    }
  }

  ArsitekturApk? _tentukanArsitektur(final Map<String, dynamic> infoPerangkat) {
    if (infoPerangkat['error'] != null) {
      return null;
    }

    final arsitekturPerangkat = List<String>.from(
      infoPerangkat['supportedAbis'] as Iterable<dynamic>,
    );
    if (arsitekturPerangkat.contains('arm64-v8a')) {
      return ArsitekturApk.bit64;
    } else if (arsitekturPerangkat.contains('armeabi-v7a')) {
      return ArsitekturApk.bit32;
    } else {
      Log.warning('Arsitektur tidak didukung (bukan 64-bit, 32-bit, ).', {
        'supportedAbis': arsitekturPerangkat,
      });
      return ArsitekturApk.universal;
    }
  }
}
```

### File: `lib/fitur/versi_apk/service/update_service.dart`
```dart
// path: lib/fitur/versi_apk/service/update_service.dart

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wifi/shared/debug/log.dart';

class UpdateService {
  final Dio _dio = Dio();

  Future<void> downloadDanInstallApk({
    required final String url,
    required final String namaFile,
    final void Function(double)? onProgress,
  }) async {
    try {
      final temporaryDirectory = await getTemporaryDirectory();
      final apkFilePath = '${temporaryDirectory.path}/$namaFile';
      Log.info('Mulai mengunduh dari: $url ke: $apkFilePath');

      await _dio.download(
        url,
        apkFilePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            final progressValue = received / total;
            onProgress(progressValue);
            Log.info('Progres unduhan: ${progressValue * 100}%', {
              'data: $progressValue',
            });
          }
        },
      );

      Log.info('Unduhan selesai: $apkFilePath');

      final apkFile = File(apkFilePath);
      if (!apkFile.existsSync()) {
        throw Exception('File APK tidak ditemukan setelah diunduh.');
      }

      Log.info('Membuka file APK untuk instalasi...');
      final hasilInstall = await OpenFilex.open(apkFilePath);

      if (hasilInstall.type != ResultType.done) {
        throw Exception('Gagal memulai instalasi: ${hasilInstall.message}');
      }
    } catch (e, s) {
      Log.error('Error saat mengunduh (Dio)', e: e, s: s);
      throw Exception(
        'Gagal mengunduh pembaruan. Periksa koneksi internet Anda.',
      );
    }
  }
}
```

