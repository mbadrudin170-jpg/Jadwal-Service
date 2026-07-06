
// File: lib/admin/data/sqlite.dart

```dart
// path: lib/admin/data/sqlite.dart

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';

final sqliteDatabaseProvider = Provider<SqliteDatabase>((ref) {
  return SqliteDatabase.instance;
});
final sqliteProvider = FutureProvider((ref) async {
  final sqliteDb = ref.read(sqliteDatabaseProvider);
  final db = await sqliteDb.database;
  return db;
});

class SqliteDatabase {
  SqliteDatabase._internal() {
    Log.info('DatabaseHelper instance dibuat (singleton _internal).');
  }
  static final SqliteDatabase instance = SqliteDatabase._internal();
  static Database? _database;
  static const int _databaseVersion = 55;
  void debugSetDatabaseNull() {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      _database = null;
    }
  }

  Future<Database> get database async {
    Log.info('Memulai proses akses properti database getter.');
    if (_database != null) {
      Log.info('Instance database sudah ada di memori, mengembalikan...');
      return _database!;
    }
    Log.info('Instance database belum ada, memanggil _initDB().');
    try {
      _database = await _initDB();
      Log.info('Database berhasil diinisialisasi dan di-cache.');
      return _database!;
    } on Exception catch (e, st) {
      Log.error('Gagal total mendapatkan instance database.', e: e, s: st);
      rethrow;
    }
  }

  Future<Database> _initDB() async {
    Log.info('Memulai inisialisasi database (_initDB).');
    try {
      if (Platform.environment.containsKey('FLUTTER_TEST')) {
        Log.info('Mode TEST terdeteksi. Menggunakan database in-memory.');
        return databaseFactory.openDatabase(
          inMemoryDatabasePath,
          options: OpenDatabaseOptions(
            version: _databaseVersion,
            onCreate: membuatTabel,
            onUpgrade: _onUpgrade,
          ),
        );
      }

      Log.info('Mode PRODUKSI/DEBUG. Menggunakan database fisik.');
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final path = join(documentsDirectory.path, 'mydatabase.db');
      Log.info('Path database: $path');

      Log.info('Membuka database dengan versi $_databaseVersion...');
      return openDatabase(
        path,
        version: _databaseVersion,
        onCreate: membuatTabel,
        onUpgrade: _onUpgrade,
      );
    } on Exception catch (e, st) {
      Log.error('Gagal membuka atau membuat database.', e: e, s: st);
      rethrow;
    }
  }

  Future<void> _onUpgrade(
    final Database db,
    final int oldVersion,
    final int newVersion,
  ) async {
    Log.info('========================================');
    Log.info('MEMULAI PROSES UPGRADE DATABASE (IDEMPOTEN)');
    Log.info('Versi database lama: $oldVersion');
    Log.info('Versi database baru: $newVersion');
    Log.info('========================================');

    if (oldVersion < 45) {
      Log.info('[MIGRASI v45] Menjalankan migrasi untuk versi < 45.');
      await _migrateToV45(db);
    }

    if (oldVersion < 47) {
      Log.info('[MIGRASI v47] Memulai migrasi skema destruktif.');
      await _migrateToV47(db);
    }

    if (oldVersion < 48) {
      Log.info(
        '[MIGRASI v48] Menambahkan kolom `diperbarui` ke `status_aplikasi`.',
      );
      await _migrateToV48(db);
    }

    if (oldVersion < 49) {
      Log.info('[MIGRASI v49] Rename semua kolom ke snake_case Inggris.');
      await _migrateToV49(db);
    }

    if (oldVersion < 50) {
      Log.info('[MIGRASI v50] Rename semua nama tabel ke snake_case Inggris.');
      await _migrateToV50(db);
    }

    if (oldVersion < 51) {
      Log.info(
        '[MIGRASI v51] Menambahkan kolom `${NamaKolom.terakhirAktif}` ke tabel `${NamaTabel.pelanggan}`.',
      );
      await _migrateToV51(db);
    }

    if (oldVersion < 52) {
      Log.info('[MIGRASI v52] Membuat tabel `${NamaTabel.notifikasi}`.');
      await _migrateToV52(db);
    }

    if (oldVersion < 53) {
      Log.info(
        '[MIGRASI v53] Menambahkan kolom durasi bonus ke tabel transaksi.',
      );
      await _migrateToV53(db);
    }
    if (oldVersion < 54) {
      Log.info('[MIGRASI v54] Menyesuaikan tabel notifikasi dengan model.');
      await _migrateToV54(db);
    }
    if (oldVersion < 55) {
      Log.info('[MIGRASI v55] Menambahkan kolom role ke tabel pelanggan.');
      await db.execute(
        'ALTER TABLE ${NamaTabel.pelanggan} ADD COLUMN ${NamaKolom.role} TEXT DEFAULT "user"',
      );
    }
    Log.info('========================================');
    Log.info('PROSES UPGRADE DATABASE SELESAI');
    Log.info(
      'Database berhasil diupgrade dari versi $oldVersion ke versi $newVersion.',
    );
    Log.info('========================================');
  }

  Future<void> _migrateToV51(final Database db) async {
    Log.info('[MIGRASI v51] Menambahkan kolom ${NamaKolom.terakhirAktif}...');
    await db.execute(
      'ALTER TABLE ${NamaTabel.pelanggan} ADD COLUMN ${NamaKolom.terakhirAktif} INTEGER',
    );
    Log.info(
      '[MIGRASI v51] Penambahan kolom ${NamaKolom.terakhirAktif} selesai.',
    );
  }

  Future<void> _migrateToV52(final Database db) async {
    Log.info('[MIGRASI v52] Membuat tabel notification...');
    // Ganti definisi string-nya, atau lakukan replace saat eksekusi:
    await db.execute(
      _tabelNotification.replaceFirst(
        'CREATE TABLE',
        'CREATE TABLE IF NOT EXISTS',
      ),
    );
    Log.info('[MIGRASI v52] Tabel notification berhasil dibuat.');
  }

  Future<void> _migrateToV53(final Database db) async {
    Log.info(
      '[MIGRASI v53] Menambahkan kolom durasi_bonus dan durasi_bonus_type...',
    );

    const tableName = NamaTabel.transaksi;
    final results = await db.rawQuery('PRAGMA table_info("$tableName")');
    final existingColumns = results
        .map((row) => row['name'] as String)
        .toList();

    // Hanya tambahkan kolom jika belum ada dalam daftar kolom yang ada
    if (!existingColumns.contains(NamaKolom.durasiBonus)) {
      await db.execute(
        'ALTER TABLE "$tableName" ADD COLUMN ${NamaKolom.durasiBonus} INTEGER',
      );
    }

    if (!existingColumns.contains(NamaKolom.tipeDurasiBonus)) {
      await db.execute(
        'ALTER TABLE "$tableName" ADD COLUMN ${NamaKolom.tipeDurasiBonus} TEXT',
      );
    }
    Log.info('[MIGRASI v53] Penambahan kolom selesai.');
  }

  Future<void> _migrateToV54(final Database db) async {
    const tableName = NamaTabel.notifikasi;
    final results = await db.rawQuery('PRAGMA table_info("$tableName")');
    final existingColumns = results
        .map((row) => row['name'] as String)
        .toList();
    final columnsToAdd = {
      NamaKolom.tanggalMulai: 'INTEGER NOT NULL',
      NamaKolom.tanggalBerakhir: 'INTEGER NOT NULL',
      NamaKolom.tanggalTampil: 'INTEGER NOT NULL',
      NamaKolom.judul: 'TEXT NOT NULL',
      NamaKolom.deskripsi: 'TEXT NOT NULL',
      NamaKolom.statusDibaca: 'INTEGER NOT NULL DEFAULT 0',
      NamaKolom.tipe: 'TEXT NOT NULL',
      NamaKolom.diperbaruiPada: 'INTEGER NOT NULL',
      NamaKolom.idTujuan: 'TEXT NOT NULL',
      NamaKolom.userId: 'TEXT NOT NULL',
      NamaKolom.targetRole: 'TEXT NOT NULL',
    };

    for (final entry in columnsToAdd.entries) {
      if (!existingColumns.contains(entry.key)) {
        await db.execute(
          'ALTER TABLE "$tableName" ADD COLUMN ${entry.key} ${entry.value}',
        );
        Log.info('[MIGRASI v54] Kolom ${entry.key} ditambahkan ke $tableName.');
      }
    }

    // Hapus kolom 'pesan' dan 'status' jika masih ada (dari definisi lama)
    if (existingColumns.contains('pesan')) {
      // SQLite tidak mendukung DROP COLUMN langsung, jadi kita perlu membuat ulang tabel.
      // Namun, karena tabel notifikasi masih baru dan kemungkinan tidak ada data penting,
      // lebih aman untuk menghapus dan membuat ulang tabel.
      Log.warning(
        '[MIGRASI v54] Menghapus dan membuat ulang tabel notifikasi untuk membersihkan kolom usang.',
      );
      await db.execute('DROP TABLE IF EXISTS "$tableName"');
      await db.execute(
        _tabelNotification.replaceFirst(
          'CREATE TABLE',
          'CREATE TABLE IF NOT EXISTS',
        ),
      );
      Log.info(
        '[MIGRASI v54] Tabel notifikasi dibuat ulang dengan struktur terbaru.',
      );
    } else {
      // Jika tidak ada kolom usang, kita hanya menambahkan yang hilang.
      Log.info(
        '[MIGRASI v54] Tabel notifikasi sudah sesuai, hanya menambahkan kolom yang hilang.',
      );
    }
  }

  Future<void> _migrateToV45(final Database db) async {
    Log.info('[MIGRASI v45] Menangani tabel "pengaturan".');
    await db.execute('DROP TABLE IF EXISTS pengaturan');
    await db.execute(_tabelPengaturanV45);
    Log.info('[MIGRASI v45] Tabel `pengaturan` berhasil dibuat ulang.');
  }

  Future<void> _migrateToV47(final Database db) async {
    Log.info('[MIGRASI v47] Migrasi skema destruktif.');
    final batch = db.batch();
    final daftarTabel = <String>[
      'kategori',
      'sub_kategori',
      'paket',
      'pelanggan',
      'pelanggan_aktif',
      'transaksi',
      'dompet',
      'kritik_saran',
      'pesanan',
      'versi_apk_user',
      'pengaturan',
      'status_unggah',
      'pesan',
      'status_aplikasi',
    ];

    for (final namaTabel in daftarTabel) {
      batch.execute('DROP TABLE IF EXISTS $namaTabel');
    }
    _createAllTablesV47(batch);
    await batch.commit(noResult: true);
    Log.info('[MIGRASI v47] Selesai.');
  }

  Future<void> _migrateToV48(final Database db) async {
    await db.execute(
      'ALTER TABLE status_aplikasi ADD COLUMN diperbarui INTEGER',
    );
  }

  Future<void> _migrateToV49(final Database db) async {
    Log.info('[MIGRASI v49] Rename kolom ke snake_case...');

    await db.execute('ALTER TABLE dompet RENAME COLUMN namaDompet TO name');
    await db.execute('ALTER TABLE dompet RENAME COLUMN saldo TO balance');
    await db.execute(
      'ALTER TABLE dompet RENAME COLUMN diperbarui TO updated_at',
    );
    await db.execute(
      'ALTER TABLE dompet RENAME COLUMN diarsipkan TO archived_at',
    );

    await db.execute('ALTER TABLE kategori RENAME COLUMN nama TO name');
    await db.execute('ALTER TABLE kategori RENAME COLUMN tipe TO type');
    await db.execute(
      'ALTER TABLE kategori RENAME COLUMN id_sub_kategori TO sub_category_id',
    );
    await db.execute(
      'ALTER TABLE kategori RENAME COLUMN diperbarui TO updated_at',
    );
    await db.execute(
      'ALTER TABLE kategori RENAME COLUMN diarsipkan TO archived_at',
    );

    await db.execute('ALTER TABLE sub_kategori RENAME COLUMN nama TO name');
    await db.execute(
      'ALTER TABLE sub_kategori RENAME COLUMN id_kategori TO category_id',
    );
    await db.execute(
      'ALTER TABLE sub_kategori RENAME COLUMN diperbarui TO updated_at',
    );
    await db.execute(
      'ALTER TABLE sub_kategori RENAME COLUMN diarsipkan TO archived_at',
    );

    await db.execute('ALTER TABLE paket RENAME COLUMN nama TO name');
    await db.execute('ALTER TABLE paket RENAME COLUMN harga TO price');
    await db.execute('ALTER TABLE paket RENAME COLUMN durasi TO duration');
    await db.execute('ALTER TABLE paket RENAME COLUMN tipe TO type');
    await db.execute(
      'ALTER TABLE paket RENAME COLUMN jumlahPoin TO earned_points',
    );
    await db.execute(
      'ALTER TABLE paket RENAME COLUMN diperbarui TO updated_at',
    );
    await db.execute(
      'ALTER TABLE paket RENAME COLUMN diarsipkan TO archived_at',
    );
    await db.execute(
      'ALTER TABLE paket RENAME COLUMN poin_hadiah TO reward_points',
    );
    await db.execute(
      'ALTER TABLE paket RENAME COLUMN poin_penukaran TO redemption_points',
    );

    await db.execute('ALTER TABLE pelanggan RENAME COLUMN nama TO name');
    await db.execute('ALTER TABLE pelanggan RENAME COLUMN telepon TO phone');
    await db.execute('ALTER TABLE pelanggan RENAME COLUMN alamat TO address');
    await db.execute(
      'ALTER TABLE pelanggan RENAME COLUMN diperbarui TO updated_at',
    );
    await db.execute(
      'ALTER TABLE pelanggan RENAME COLUMN diarsipkan TO archived_at',
    );

    await db.execute(
      'ALTER TABLE pelanggan_aktif RENAME COLUMN id_pelanggan TO customer_id',
    );
    await db.execute(
      'ALTER TABLE pelanggan_aktif RENAME COLUMN id_paket TO package_id',
    );
    await db.execute(
      'ALTER TABLE pelanggan_aktif RENAME COLUMN id_transaksi TO transaction_id',
    );
    await db.execute(
      'ALTER TABLE pelanggan_aktif RENAME COLUMN tanggal_mulai TO start_date',
    );
    await db.execute(
      'ALTER TABLE pelanggan_aktif RENAME COLUMN tanggal_berakhir TO end_date',
    );
    await db.execute(
      'ALTER TABLE pelanggan_aktif RENAME COLUMN diperbarui TO updated_at',
    );
    await db.execute(
      'ALTER TABLE pelanggan_aktif RENAME COLUMN diarsipkan TO archived_at',
    );

    await db.execute(
      'ALTER TABLE transaksi RENAME COLUMN keterangan TO description',
    );
    await db.execute('ALTER TABLE transaksi RENAME COLUMN jumlah TO amount');
    await db.execute('ALTER TABLE transaksi RENAME COLUMN tanggal TO date');
    await db.execute('ALTER TABLE transaksi RENAME COLUMN tipe TO type');
    await db.execute(
      'ALTER TABLE transaksi RENAME COLUMN id_dompet TO wallet_id',
    );
    await db.execute(
      'ALTER TABLE transaksi RENAME COLUMN id_kategori TO category_id',
    );
    await db.execute(
      'ALTER TABLE transaksi RENAME COLUMN id_sub_kategori TO sub_category_id',
    );
    await db.execute(
      'ALTER TABLE transaksi RENAME COLUMN id_pelanggan TO customer_id',
    );
    await db.execute(
      'ALTER TABLE transaksi RENAME COLUMN id_paket TO package_id',
    );
    await db.execute(
      'ALTER TABLE transaksi RENAME COLUMN diperbarui TO updated_at',
    );
    await db.execute(
      'ALTER TABLE transaksi RENAME COLUMN diarsipkan TO archived_at',
    );
    await db.execute(
      'ALTER TABLE transaksi RENAME COLUMN id_dompet_tujuan TO destination_wallet_id',
    );
    await db.execute(
      'ALTER TABLE transaksi RENAME COLUMN poin_yang_dihasilkan TO earned_points',
    );
    await db.execute(
      'ALTER TABLE transaksi RENAME COLUMN poin_yang_digunakan TO used_points',
    );
    await db.execute(
      'ALTER TABLE transaksi RENAME COLUMN status_pembayaran TO payment_status',
    );
    await db.execute(
      'ALTER TABLE transaksi RENAME COLUMN durasi_paket TO package_duration',
    );
    await db.execute(
      'ALTER TABLE transaksi RENAME COLUMN tipe_durasi_paket TO duration_type',
    );
    await db.execute(
      'ALTER TABLE transaksi RENAME COLUMN tanggal_mulai TO start_date',
    );
    await db.execute(
      'ALTER TABLE transaksi RENAME COLUMN tanggal_berakhir TO end_date',
    );
    await db.execute(
      'ALTER TABLE transaksi RENAME COLUMN aktivasi_paket TO is_activated',
    );

    await db.execute('ALTER TABLE kritik_saran RENAME COLUMN isi TO content');
    await db.execute('ALTER TABLE kritik_saran RENAME COLUMN tanggal TO date');
    await db.execute(
      'ALTER TABLE kritik_saran RENAME COLUMN diperbarui TO updated_at',
    );
    await db.execute(
      'ALTER TABLE kritik_saran RENAME COLUMN diarsipkan TO archived_at',
    );

    await db.execute(
      'ALTER TABLE pesanan RENAME COLUMN id_pelanggan TO customer_id',
    );
    await db.execute(
      'ALTER TABLE pesanan RENAME COLUMN id_paket TO package_id',
    );
    await db.execute('ALTER TABLE pesanan RENAME COLUMN tanggal TO date');
    await db.execute(
      'ALTER TABLE pesanan RENAME COLUMN diperbarui TO updated_at',
    );
    await db.execute(
      'ALTER TABLE pesanan RENAME COLUMN diarsipkan TO archived_at',
    );

    await db.execute(
      'ALTER TABLE versi_apk_user RENAME COLUMN catatan_rilis TO release_notes',
    );
    await db.execute(
      'ALTER TABLE versi_apk_user RENAME COLUMN nomor_build_terbaru TO latest_build_number',
    );
    await db.execute(
      'ALTER TABLE versi_apk_user RENAME COLUMN tautan_unduhan TO download_links',
    );
    await db.execute(
      'ALTER TABLE versi_apk_user RENAME COLUMN versi_terbaru TO latest_version',
    );
    await db.execute(
      'ALTER TABLE versi_apk_user RENAME COLUMN wajib_update TO is_update_required',
    );
    await db.execute(
      'ALTER TABLE versi_apk_user RENAME COLUMN diperbarui TO updated_at',
    );
    await db.execute(
      'ALTER TABLE versi_apk_user RENAME COLUMN diarsipkan TO archived_at',
    );

    await db.execute(
      'ALTER TABLE pengaturan RENAME COLUMN interval_sinkronisasi_otomatis TO auto_sync_interval',
    );
    await db.execute(
      'ALTER TABLE pengaturan RENAME COLUMN hapus_otomatis_data_arsip TO auto_delete_archive_days',
    );
    await db.execute(
      'ALTER TABLE pengaturan RENAME COLUMN diperbarui TO updated_at',
    );
    await db.execute(
      'ALTER TABLE pengaturan RENAME COLUMN mode_pemeliharaan TO maintenance_mode',
    );
    await db.execute(
      'ALTER TABLE pengaturan RENAME COLUMN info_pemeliharaan TO maintenance_info',
    );

    await db.execute(
      'ALTER TABLE status_unggah RENAME COLUMN tabel TO table_name',
    );
    await db.execute(
      'ALTER TABLE status_unggah RENAME COLUMN diperbarui TO updated_at',
    );

    await db.execute(
      'ALTER TABLE status_aplikasi RENAME COLUMN diperbarui TO updated_at',
    );

    await db.execute('ALTER TABLE pesan RENAME COLUMN isi TO content');
    await db.execute('ALTER TABLE pesan RENAME COLUMN tanggal TO date');

    Log.info('[MIGRASI v49] Semua rename kolom selesai.');
  }

  Future<void> _migrateToV50(final Database db) async {
    Log.info('[MIGRASI v50] Rename tabel ke snake_case...');
    Log.warning('[MIGRASI v50] Data tetap AMAN. Hanya nama tabel diubah.');

    await db.execute('ALTER TABLE dompet RENAME TO ${NamaTabel.dompet}');
    await db.execute('ALTER TABLE kategori RENAME TO ${NamaTabel.kategori}');
    await db.execute(
      'ALTER TABLE sub_kategori RENAME TO ${NamaTabel.subKategori}',
    );
    await db.execute('ALTER TABLE paket RENAME TO ${NamaTabel.paket}');
    await db.execute('ALTER TABLE pelanggan RENAME TO ${NamaTabel.pelanggan}');
    await db.execute(
      'ALTER TABLE pelanggan_aktif RENAME TO ${NamaTabel.pelangganAktif}',
    );

    // diperbaiki: Ditambahkan escaping double quotes ("") untuk tabel transaction via TableNameValue
    await db.execute(
      'ALTER TABLE transaksi RENAME TO "${NamaTabel.transaksi}"',
    );
    await db.execute(
      'ALTER TABLE kritik_saran RENAME TO ${NamaTabel.feedback}',
    );

    // diperbaiki: Ditambahkan escaping double quotes ("") untuk tabel order via TableNameValue
    await db.execute(
      'ALTER TABLE pesanan RENAME TO "${NamaTabel.pesananPelanggan}"',
    );
    await db.execute(
      'ALTER TABLE versi_apk_user RENAME TO ${NamaTabel.versiApkUser}',
    );
    await db.execute('ALTER TABLE pengaturan RENAME TO ${NamaTabel.settings}');
    await db.execute(
      'ALTER TABLE status_unggah RENAME TO ${NamaTabel.statusUnggah}',
    );
    await db.execute('ALTER TABLE pesan RENAME TO ${NamaTabel.pesan}');

    Log.info('[MIGRASI v50] Semua rename tabel selesai.');
  }

  /// Membuat tabel-tabel database (untuk database baru).
  Future<void> membuatTabel(Database db, int version) async {
    Log.info('========================================');
    Log.info(
      'MEMULAI PEMBUATAN TABEL DATABASE (onCreate) UNTUK VERSI $version',
    );
    Log.info('========================================');
    final batch = db.batch();
    _membuatSemuaTabel(batch);
    try {
      await batch.commit(noResult: true);
      Log.info('PROSES PEMBUATAN TABEL & INDEX SELESAI');
    } on Exception catch (e, st) {
      Log.error('Gagal total saat membuat tabel atau index.', e: e, s: st);
      rethrow;
    }
  }

  void _membuatSemuaTabel(Batch batch) {
    batch.execute(_tabelKategori);
    batch.execute(_tabelSubKategori);
    batch.execute(_tabelPaket);
    batch.execute(_tabelPelanggan);
    batch.execute(_tabelPelangganAktif);
    batch.execute(_tabelTransaksi);
    batch.execute(_tabelDompet);
    batch.execute(_tabelFeedback);
    batch.execute(_tabelOrder);
    batch.execute(_tabelVersiApkUser);
    batch.execute(_tabelSetting);
    batch.execute(_tabelStatusUnggah);
    batch.execute(_tabelPesan);
    batch.execute(
      _tabelNotification,
    ); // 2. Tambahkan pembuatan tabel notifikasi
    Log.info('Semua 14 definisi tabel (v52) ditambahkan ke batch.');

    // diperbaiki: Index ditargetkan menggunakan escaping keyword "transaction" otomatis dari TableNameValue
    const trxTable = '"${NamaTabel.transaksi}"';
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_transaction_wallet_id ON $trxTable(${NamaKolom.idDompet})',
    );
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_transaction_destination_wallet_id ON $trxTable(${NamaKolom.idDompetTujuan})',
    );
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_transaction_is_deleted ON $trxTable(${NamaKolom.dihapus})',
    );
    Log.info('Semua 3 definisi index (v51) ditambahkan ke batch.');
  }

  void _createAllTablesV47(Batch batch) {
    batch.execute(_tabelKategoriV47);
    batch.execute(_tabelSubKategoriV47);
    batch.execute(_tabelPaketV47);
    batch.execute(_tabelPelangganV47);
    batch.execute(_tabelPelangganAktifV47);
    batch.execute(_tabelTransaksiV47);
    batch.execute(_tabelDompetV47);
    batch.execute(_tabelKritikSaranV47);
    batch.execute(_tabelPesananV47);
    batch.execute(_tabelVersiApkUserV47);
    batch.execute(_tabelPengaturanV45);
    batch.execute(_tabelStatusUnggahV47);
    batch.execute(_tabelStatusAplikasiV47);
    batch.execute(_tabelPesanV47);
  }

  // ============================================================
  // DEFINISI TABEL v51 (snake_case nama tabel + nama kolom via konstanta)
  // ============================================================

  static const String _tabelDompet =
      '''
    CREATE TABLE ${NamaTabel.dompet}(
      ${NamaKolom.id} TEXT PRIMARY KEY,
      ${NamaKolom.nama} TEXT NOT NULL,
      ${NamaKolom.saldo} REAL NOT NULL,
      ${NamaKolom.diperbaruiPada} INTEGER,
      ${NamaKolom.dihapus} INTEGER NOT NULL DEFAULT 0,
      ${NamaKolom.diarsipkanPada} INTEGER
    )
  ''';

  static const String _tabelTransaksi =
      '''
    CREATE TABLE "${NamaTabel.transaksi}" (
      ${NamaKolom.id} TEXT PRIMARY KEY,
      ${NamaKolom.deskripsi} TEXT NOT NULL,
      ${NamaKolom.jumlah} REAL NOT NULL,
      ${NamaKolom.tanggal} INTEGER NOT NULL,
      ${NamaKolom.tipe} TEXT NOT NULL,
      ${NamaKolom.idDompet} TEXT,
      ${NamaKolom.idKategori} TEXT,
      ${NamaKolom.idSubKategori} TEXT,
      ${NamaKolom.idPelanggan} TEXT,
      ${NamaKolom.idPaket} TEXT,
      ${NamaKolom.diperbaruiPada} INTEGER,
      ${NamaKolom.diarsipkanPada} INTEGER,
      ${NamaKolom.dihapus} INTEGER NOT NULL DEFAULT 0,
      ${NamaKolom.idDompetTujuan} TEXT,
      ${NamaKolom.poinDidapat} INTEGER NOT NULL DEFAULT 0,
      ${NamaKolom.poinDigunakan} INTEGER NOT NULL DEFAULT 0,
      ${NamaKolom.statusPembayaran} TEXT,
      ${NamaKolom.durasiPaket} INTEGER,
      ${NamaKolom.tipeDurasiPaket} TEXT,
      ${NamaKolom.durasiBonus} INTEGER,
      ${NamaKolom.tipeDurasiBonus} TEXT,
      ${NamaKolom.tanggalMulai} INTEGER,
      ${NamaKolom.tanggalBerakhir} INTEGER,
      ${NamaKolom.statusAktivasi} INTEGER DEFAULT 0
    )
  ''';

  static const String _tabelVersiApkUser =
      '''
    CREATE TABLE ${NamaTabel.versiApkUser}(
      ${NamaKolom.id} TEXT PRIMARY KEY,
      ${NamaKolom.catatanRilis} TEXT NOT NULL,
      ${NamaKolom.nomorBuildTerakhir} TEXT NOT NULL,
      ${NamaKolom.linkDownload} TEXT NOT NULL,
      ${NamaKolom.versiTerkahir} TEXT NOT NULL,
      ${NamaKolom.wajibUpdate} INTEGER NOT NULL,
      ${NamaKolom.linkYoutubeTutorial} TEXT NOT NULL,
      ${NamaKolom.dihapus} INTEGER NOT NULL DEFAULT 0,
      ${NamaKolom.diarsipkanPada} INTEGER,
      ${NamaKolom.diperbaruiPada} INTEGER
    )
  ''';

  static const String _tabelStatusUnggah =
      '''
    CREATE TABLE ${NamaTabel.statusUnggah}(
      ${NamaKolom.id} TEXT PRIMARY KEY,
      ${NamaKolom.value} TEXT NOT NULL,
      ${NamaKolom.diperbaruiPada} INTEGER
    )
  ''';

  static const String _tabelPesan =
      '''
    CREATE TABLE ${NamaTabel.pesan}(
      ${NamaKolom.id} TEXT PRIMARY KEY,
      ${NamaKolom.pesan} TEXT NOT NULL,
      ${NamaKolom.tanggal} INTEGER NOT NULL,
      ${NamaKolom.status} TEXT NOT NULL
    )
  ''';

  static const String _tabelSetting =
      '''
    CREATE TABLE ${NamaTabel.settings}(
      ${NamaKolom.id} TEXT PRIMARY KEY,
      ${NamaKolom.waktuOtomatisSinkronisasi} INTEGER NOT NULL DEFAULT 24,
      ${NamaKolom.waktuOtomatisHapusDataArsip} INTEGER NOT NULL DEFAULT 30,
      ${NamaKolom.diperbaruiPada} INTEGER,
      ${NamaKolom.modeMaintenance} INTEGER NOT NULL DEFAULT 0,
      ${NamaKolom.infoMaintenance} TEXT
    )
  ''';

  static const String _tabelKategori =
      '''
    CREATE TABLE ${NamaTabel.kategori}(
      ${NamaKolom.id} TEXT PRIMARY KEY,
      ${NamaKolom.nama} TEXT NOT NULL,
      ${NamaKolom.tipe} TEXT NOT NULL,
      ${NamaKolom.idSubKategori} TEXT,
      ${NamaKolom.diperbaruiPada} INTEGER,
      ${NamaKolom.dihapus} INTEGER NOT NULL DEFAULT 0,
      ${NamaKolom.diarsipkanPada} INTEGER
    )
  ''';

  static const String _tabelSubKategori =
      '''
    CREATE TABLE ${NamaTabel.subKategori}(
      ${NamaKolom.id} TEXT PRIMARY KEY,
      ${NamaKolom.nama} TEXT NOT NULL,
      ${NamaKolom.idKategori} TEXT NOT NULL,
      ${NamaKolom.diperbaruiPada} INTEGER,
      ${NamaKolom.dihapus} INTEGER NOT NULL DEFAULT 0,
      ${NamaKolom.diarsipkanPada} INTEGER,
      FOREIGN KEY (${NamaKolom.idKategori}) REFERENCES ${NamaTabel.kategori} (${NamaKolom.id}) ON DELETE CASCADE
    )
  ''';

  static const String _tabelPaket =
      '''
    CREATE TABLE ${NamaTabel.paket}(
      ${NamaKolom.id} TEXT PRIMARY KEY,
      ${NamaKolom.nama} TEXT NOT NULL,
      ${NamaKolom.harga} INTEGER NOT NULL,
      ${NamaKolom.durasi} INTEGER NOT NULL,
      ${NamaKolom.tipe} TEXT NOT NULL,
      ${NamaKolom.poinDidapat} INTEGER NOT NULL DEFAULT 0,
      ${NamaKolom.diperbaruiPada} INTEGER,
      ${NamaKolom.dihapus} INTEGER NOT NULL DEFAULT 0,
      ${NamaKolom.diarsipkanPada} INTEGER,
      ${NamaKolom.poinHadiah} INTEGER NOT NULL DEFAULT 0,
      ${NamaKolom.poinPenukaran} INTEGER NOT NULL DEFAULT 0,
      ${NamaKolom.statusPublik} INTEGER NOT NULL DEFAULT 1
    )
  ''';

  static const String _tabelPelanggan =
      '''
    CREATE TABLE ${NamaTabel.pelanggan}(
      ${NamaKolom.id} TEXT PRIMARY KEY,
      ${NamaKolom.nama} TEXT NOT NULL,
      ${NamaKolom.telepon} TEXT NOT NULL,
      ${NamaKolom.alamat} TEXT NOT NULL,
      ${NamaKolom.kataSandi} TEXT NOT NULL,
      ${NamaKolom.macAddress} TEXT NOT NULL,
      ${NamaKolom.role} TEXT NOT NULL DEFAULT 'user',
      ${NamaKolom.status} TEXT NOT NULL DEFAULT 'aktif',
      ${NamaKolom.diperbaruiPada} INTEGER,
      ${NamaKolom.diarsipkanPada} INTEGER,
      ${NamaKolom.dihapus} INTEGER NOT NULL DEFAULT 0,
      ${NamaKolom.terakhirAktif} INTEGER
    )
  ''';

  static const String _tabelPelangganAktif =
      '''
    CREATE TABLE ${NamaTabel.pelangganAktif}(
      ${NamaKolom.id} TEXT PRIMARY KEY,
      ${NamaKolom.idPelanggan} TEXT NOT NULL,
      ${NamaKolom.idPaket} TEXT NOT NULL,
      ${NamaKolom.idTransaksi} TEXT,
      ${NamaKolom.tanggalMulai} INTEGER,
      ${NamaKolom.tanggalBerakhir} INTEGER,
      ${NamaKolom.status} TEXT NOT NULL,
      ${NamaKolom.diperbaruiPada} INTEGER,
      ${NamaKolom.dihapus} INTEGER NOT NULL DEFAULT 0,
      ${NamaKolom.diarsipkanPada} INTEGER,
      FOREIGN KEY (${NamaKolom.idPelanggan}) REFERENCES ${NamaTabel.pelanggan} (${NamaKolom.id}) ON DELETE CASCADE ON UPDATE CASCADE,
      FOREIGN KEY (${NamaKolom.idPaket}) REFERENCES ${NamaTabel.paket} (${NamaKolom.id}) ON DELETE CASCADE ON UPDATE CASCADE,
      FOREIGN KEY (${NamaKolom.idTransaksi}) REFERENCES "${NamaTabel.transaksi}" (${NamaKolom.id}) ON DELETE SET NULL
    )
  ''';

  static const String _tabelFeedback =
      '''
    CREATE TABLE ${NamaTabel.feedback}(
      ${NamaKolom.id} TEXT PRIMARY KEY,
      ${NamaKolom.pesan} TEXT NOT NULL,
      ${NamaKolom.tanggal} INTEGER NOT NULL,
      ${NamaKolom.userId} TEXT NOT NULL,
      ${NamaKolom.diperbaruiPada} INTEGER,
      ${NamaKolom.dihapus} INTEGER NOT NULL DEFAULT 0,
      ${NamaKolom.diarsipkanPada} INTEGER,
      FOREIGN KEY (${NamaKolom.userId}) REFERENCES ${NamaTabel.pelanggan} (${NamaKolom.id}) ON DELETE CASCADE
    )
  ''';

  static const String _tabelOrder =
      '''
    CREATE TABLE "${NamaTabel.pesananPelanggan}" (
      ${NamaKolom.id} TEXT PRIMARY KEY,
      ${NamaKolom.idPelanggan} TEXT NOT NULL,
      ${NamaKolom.idPaket} TEXT NOT NULL,
      ${NamaKolom.tanggal} INTEGER NOT NULL,
      ${NamaKolom.status} TEXT,
      ${NamaKolom.diperbaruiPada} INTEGER,
      ${NamaKolom.dihapus} INTEGER NOT NULL DEFAULT 0,
      ${NamaKolom.diarsipkanPada} INTEGER,
      FOREIGN KEY (${NamaKolom.idPelanggan}) REFERENCES ${NamaTabel.pelanggan} (${NamaKolom.id}) ON DELETE CASCADE,
      FOREIGN KEY (${NamaKolom.idPaket}) REFERENCES ${NamaTabel.paket} (${NamaKolom.id}) ON DELETE CASCADE
    )
  ''';
  static const String _tabelNotification =
      '''
  CREATE TABLE ${NamaTabel.notifikasi}(
    ${NamaKolom.id} TEXT PRIMARY KEY,
    ${NamaKolom.tanggalMulai} INTEGER NOT NULL,
    ${NamaKolom.tanggalBerakhir} INTEGER NOT NULL,
    ${NamaKolom.tanggalTampil} INTEGER NOT NULL,
    ${NamaKolom.judul} TEXT NOT NULL,
    ${NamaKolom.deskripsi} TEXT NOT NULL,
    ${NamaKolom.statusDibaca} INTEGER NOT NULL DEFAULT 0,
    ${NamaKolom.tipe} TEXT NOT NULL,
    ${NamaKolom.diperbaruiPada} INTEGER NOT NULL,
    ${NamaKolom.idTujuan} TEXT NOT NULL,
    ${NamaKolom.userId} TEXT NOT NULL,
    ${NamaKolom.dihapus} INTEGER NOT NULL DEFAULT 0,
    ${NamaKolom.diarsipkanPada} INTEGER,
    ${NamaKolom.targetRole} TEXT NOT NULL
  )
''';
  // ============================================================
  // DEFINISI TABEL LAMA (Tetap Konstan untuk Jalur Migrasi Sinkron)
  // ============================================================

  static const String _tabelPengaturanV45 = '''
    CREATE TABLE pengaturan(
      id TEXT PRIMARY KEY, interval_sinkronisasi_otomatis INTEGER NOT NULL DEFAULT 24,
      hapus_otomatis_data_arsip INTEGER NOT NULL DEFAULT 30, diperbarui INTEGER,
      mode_pemeliharaan INTEGER NOT NULL DEFAULT 0, info_pemeliharaan TEXT
    )
  ''';

  static const String _tabelDompetV47 = '''
    CREATE TABLE dompet(
      id TEXT PRIMARY KEY, namaDompet TEXT NOT NULL, saldo REAL NOT NULL,
      diperbarui INTEGER, isDeleted INTEGER NOT NULL DEFAULT 0, diarsipkan INTEGER
    )
  ''';

  static const String _tabelTransaksiV47 = '''
    CREATE TABLE transaksi(
      id TEXT PRIMARY KEY, keterangan TEXT NOT NULL, jumlah REAL NOT NULL,
      tanggal INTEGER NOT NULL, tipe TEXT NOT NULL, id_dompet TEXT,
      id_kategori TEXT, id_sub_kategori TEXT, id_pelanggan TEXT, id_paket TEXT,
      diperbarui INTEGER, diarsipkan INTEGER, isDeleted INTEGER NOT NULL DEFAULT 0,
      id_dompet_tujuan TEXT, poin_yang_dihasilkan INTEGER NOT NULL DEFAULT 0,
      poin_yang_digunakan INTEGER NOT NULL DEFAULT 0, status_pembayaran TEXT,
      durasi_paket INTEGER, tipe_durasi_paket TEXT, tanggal_mulai INTEGER,
      tanggal_berakhir INTEGER, aktivasi_paket INTEGER DEFAULT 0
    )
  ''';

  static const String _tabelVersiApkUserV47 = '''
    CREATE TABLE versi_apk_user(
      id TEXT PRIMARY KEY, catatan_rilis TEXT NOT NULL, nomor_build_terbaru TEXT NOT NULL,
      tautan_unduhan TEXT NOT NULL, versi_terbaru TEXT NOT NULL, wajib_update INTEGER NOT NULL,
      youtube_tutorial TEXT NOT NULL, isDeleted INTEGER NOT NULL DEFAULT 0,
      diarsipkan INTEGER, diperbarui INTEGER
    )
  ''';

  static const String _tabelStatusUnggahV47 = '''
    CREATE TABLE status_unggah(
      tabel TEXT PRIMARY KEY, status INTEGER NOT NULL, ids TEXT NOT NULL, diperbarui INTEGER
    )
  ''';

  static const String _tabelStatusAplikasiV47 = '''
    CREATE TABLE status_aplikasi(
      id TEXT PRIMARY KEY, value TEXT NOT NULL, diperbarui INTEGER
    )
  ''';

  static const String _tabelPesanV47 = '''
    CREATE TABLE pesan(
      id TEXT PRIMARY KEY, isi TEXT NOT NULL, tanggal INTEGER NOT NULL, status TEXT NOT NULL
    )
  ''';

  static const String _tabelKategoriV47 = '''
    CREATE TABLE kategori(
      id TEXT PRIMARY KEY, nama TEXT NOT NULL, tipe TEXT NOT NULL,
      id_sub_kategori TEXT, diperbarui INTEGER, isDeleted INTEGER NOT NULL DEFAULT 0,
      diarsipkan INTEGER
    )
  ''';

  static const String _tabelSubKategoriV47 = '''
    CREATE TABLE sub_kategori(
      id TEXT PRIMARY KEY, nama TEXT NOT NULL, id_kategori TEXT NOT NULL,
      diperbarui INTEGER, isDeleted INTEGER NOT NULL DEFAULT 0, diarsipkan INTEGER,
      FOREIGN KEY (id_kategori) REFERENCES kategori (id) ON DELETE CASCADE
    )
  ''';

  static const String _tabelPaketV47 = '''
    CREATE TABLE paket(
      id TEXT PRIMARY KEY, nama TEXT NOT NULL, harga INTEGER NOT NULL,
      durasi INTEGER NOT NULL, tipe TEXT NOT NULL, jumlahPoin INTEGER NOT NULL DEFAULT 0,
      diperbarui INTEGER, isDeleted INTEGER NOT NULL DEFAULT 0, diarsipkan INTEGER,
      poin_hadiah INTEGER NOT NULL DEFAULT 0, poin_penukaran INTEGER NOT NULL DEFAULT 0,
      isPublic INTEGER NOT NULL DEFAULT 1
    )
  ''';

  static const String _tabelPelangganV47 = '''
    CREATE TABLE pelanggan(
      id TEXT PRIMARY KEY, nama TEXT NOT NULL, telepon TEXT NOT NULL,
      alamat TEXT NOT NULL, password TEXT NOT NULL, mac_address TEXT NOT NULL,
      status TEXT NOT NULL DEFAULT 'aktif', diperbarui INTEGER, diarsipkan INTEGER,
      isDeleted INTEGER NOT NULL DEFAULT 0
    )
  ''';

  static const String _tabelPelangganAktifV47 = '''
    CREATE TABLE pelanggan_aktif(
      id TEXT PRIMARY KEY, id_pelanggan TEXT NOT NULL, id_paket TEXT NOT NULL,
      id_transaksi TEXT, tanggal_mulai INTEGER, tanggal_berakhir INTEGER,
      status TEXT NOT NULL, diperbarui INTEGER, isDeleted INTEGER NOT NULL DEFAULT 0,
      diarsipkan INTEGER,
      FOREIGN KEY (id_pelanggan) REFERENCES pelanggan (id) ON DELETE CASCADE ON UPDATE CASCADE,
      FOREIGN KEY (id_paket) REFERENCES paket (id) ON DELETE CASCADE ON UPDATE CASCADE,
      FOREIGN KEY (id_transaksi) REFERENCES transaksi (id) ON DELETE SET NULL
    )
  ''';

  static const String _tabelKritikSaranV47 = '''
    CREATE TABLE kritik_saran(
      id TEXT PRIMARY KEY, isi TEXT NOT NULL, tanggal INTEGER NOT NULL,
      userId TEXT NOT NULL, diperbarui INTEGER, isDeleted INTEGER NOT NULL DEFAULT 0,
      diarsipkan INTEGER,
      FOREIGN KEY (userId) REFERENCES pelanggan (id) ON DELETE CASCADE
    )
  ''';

  static const String _tabelPesananV47 = '''
    CREATE TABLE pesanan(
      id TEXT PRIMARY KEY, id_pelanggan TEXT NOT NULL, id_paket TEXT NOT NULL,
      tanggal INTEGER NOT NULL, status TEXT, diperbarui INTEGER,
      isDeleted INTEGER NOT NULL DEFAULT 0, diarsipkan INTEGER,
      FOREIGN KEY (id_pelanggan) REFERENCES pelanggan (id) ON DELETE CASCADE,
      FOREIGN KEY (id_paket) REFERENCES paket (id) ON DELETE CASCADE
    )
  ''';
}
```

// File: lib/fitur/app_role/role_util.dart

```dart
// path: lib/shared/utils/role_util.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/app_role/app_role_enum.dart';
import 'package:wifi/shared/debug/log.dart';

part 'role_util.g.dart';

@Riverpod(keepAlive: true)
AppRole appRole(Ref ref) {
  throw UnimplementedError(
    'appRoleProvider harus di-override di dalam ProviderScope',
  );
}

class RoleUtil {
  static bool isAdmin(Ref ref) {
    final role = ref.watch(appRoleProvider);
    Log.info('Role saat ini: ${role.name}'); // ← lihat log ini
    return role == AppRole.admin;
  }

  static bool isUser(Ref ref) {
    return ref.watch(appRoleProvider) == AppRole.user;
  }

  static bool isInvestor(Ref ref) {
    return ref.watch(appRoleProvider) == AppRole.investor;
  }

  static bool hasRole(Ref ref, AppRole role) {
    return ref.watch(appRoleProvider) == role;
  }

  static Future<bool> isAdminAsync(Ref ref) async {
    final role = ref.watch(appRoleProvider);
    return role == AppRole.admin;
  }

  static Future<bool> isUserAsync(Ref ref) async {
    final role = ref.watch(appRoleProvider);
    return role == AppRole.user;
  }

  static Future<bool> hasRoleAsync(Ref ref, AppRole role) async {
    final currentRole = ref.watch(appRoleProvider);
    return currentRole == role;
  }

  static String getRoleName(Ref ref) {
    return ref.watch(appRoleProvider).name;
  }

  static Future<String> getRoleNameAsync(Ref ref) async {
    final role = ref.watch(appRoleProvider);
    return role.name;
  }
}

extension RoleExtension on WidgetRef {
  /// Mengecek apakah pengguna saat ini adalah admin.
  bool get isAdmin => watch(appRoleProvider) == AppRole.admin;

  /// Mengecek apakah pengguna saat ini adalah user.
  bool get isUser => watch(appRoleProvider) == AppRole.user;

  bool get isInvestor => watch(appRoleProvider) == AppRole.investor;

  /// Mengecek apakah pengguna saat ini memiliki role yang sama dengan [role].
  bool hasRole(AppRole role) => watch(appRoleProvider) == role;

  /// Mendapatkan role saat ini.
  AppRole get currentRole => watch(appRoleProvider);
}
```

// File: lib/fitur/investor/page/portofolio.dart

```dart
// path: lib/fitur/investor/page/portofolio.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/app_role/role_util.dart';
import 'package:wifi/shared/common/teks.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/user/providers/user_provider.dart';

/// Model data portofolio investor.
class InvestorPortofolio {
  final String id;
  final String userId;
  final String namaInvestor;
  final double persentase; // 0.0 - 1.0
  final double totalModal;
  final double totalDividenDiterima;
  final List<DividenHistory> riwayatDividen;

  InvestorPortofolio({
    required this.id,
    required this.userId,
    required this.namaInvestor,
    required this.persentase,
    required this.totalModal,
    this.totalDividenDiterima = 0,
    this.riwayatDividen = const [],
  });
}

/// Model riwayat dividen.
class DividenHistory {
  final String id;
  final DateTime tanggal;
  final double jumlah;
  final String keterangan;

  DividenHistory({
    required this.id,
    required this.tanggal,
    required this.jumlah,
    required this.keterangan,
  });
}

/// Provider untuk mengambil data portofolio investor yang sedang login.
final investorPortofolioProvider = FutureProvider<InvestorPortofolio?>((
  ref,
) async {
  final userId = await ref.watch(userIdProvider.future);
  if (userId == null || userId.isEmpty) {
    Log.warning('UserId tidak ditemukan untuk mengambil portofolio investor.');
    return null;
  }

  // TODO: Ambil data dari SQLite atau Firebase sesuai kebutuhan.
  // Karena ini masih contoh, kita akan kembalikan data dummy.
  // Nanti bisa diganti dengan query ke database yang sebenarnya.
  Log.info('Mengambil data portofolio untuk investor ID: $userId');

  // Data dummy untuk demonstrasi
  return InvestorPortofolio(
    id: 'portofolio_1',
    userId: userId,
    namaInvestor: 'Budi Investor',
    persentase: 0.4, // 40%
    totalModal: 5000000,
    totalDividenDiterima: 1200000,
    riwayatDividen: [
      DividenHistory(
        id: 'div_1',
        tanggal: DateTime(2025, 6, 1),
        jumlah: 600000,
        keterangan: 'Dividen Q2 2025',
      ),
      DividenHistory(
        id: 'div_2',
        tanggal: DateTime(2025, 3, 1),
        jumlah: 600000,
        keterangan: 'Dividen Q1 2025',
      ),
    ],
  );
});

/// Halaman portofolio untuk investor (read-only).
class HalamanPortofolio extends ConsumerWidget {
  const HalamanPortofolio({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInvestor = ref.isInvestor;
    if (!isInvestor) {
      return Scaffold(
        appBar: AppBar(title: const Text('Portofolio')),
        body: const Center(
          child: Text('Anda tidak memiliki akses ke halaman ini.'),
        ),
      );
    }

    final portofolioAsync = ref.watch(investorPortofolioProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Portofolio Saya')),
      body: portofolioAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(TIcons.errorOutlined, size: 60, color: Colors.red),
              gapH16,
              const TeksIsiBesar(
                'Gagal memuat data portofolio.',
                warna: Colors.red,
              ),
              gapH8,
              TeksIsiSedang('Error: $err'),
              gapH16,
              ElevatedButton.icon(
                onPressed: () => ref.refresh(investorPortofolioProvider),
                icon: const Icon(TIcons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
        data: (portofolio) {
          if (portofolio == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(TIcons.warningAmber, size: 60, color: Colors.orange),
                  gapH16,
                  TeksIsiBesar('Data portofolio tidak ditemukan.'),
                  TeksIsiSedang('Hubungi admin untuk informasi lebih lanjut.'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(investorPortofolioProvider),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kartu Ringkasan
                  _buildKartuRingkasan(portofolio),
                  gapH24,

                  // Detail Kepemilikan
                  _buildDetailKepemilikan(portofolio),
                  gapH24,

                  // Riwayat Dividen
                  _buildRiwayatDividen(portofolio),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildKartuRingkasan(InvestorPortofolio portofolio) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: TColors.primaryColor.withAlpha(25),
                  radius: 28,
                  child: const Icon(
                    TIcons.person,
                    size: 32,
                    color: TColors.primaryColor,
                  ),
                ),
                gapW16,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TeksJudulSedang(
                      portofolio.namaInvestor,
                      tebalFont: FontWeight.bold,
                    ),
                    TeksIsiKecil('ID Investor: ${portofolio.id}'),
                  ],
                ),
              ],
            ),
            gapH16,
            const Divider(),
            gapH16,
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TeksIsiKecil('Total Modal', warna: Colors.grey),
                      TeksJudulSedang(
                        FormatUang.formatMataUang(portofolio.totalModal),
                        tebalFont: FontWeight.bold,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const TeksIsiKecil('Persentase', warna: Colors.grey),
                      TeksJudulSedang(
                        '${(portofolio.persentase * 100).toStringAsFixed(1)}%',
                        tebalFont: FontWeight.bold,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            gapH12,
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TeksIsiKecil(
                        'Dividen Diterima',
                        warna: Colors.grey,
                      ),
                      TeksJudulSedang(
                        FormatUang.formatMataUang(
                          portofolio.totalDividenDiterima,
                        ),
                        tebalFont: FontWeight.bold,
                        warna: Colors.green,
                      ),
                    ],
                  ),
                ),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TeksIsiKecil('Dividen Berikutnya', warna: Colors.grey),
                      TeksJudulSedang(
                        'Belum ditentukan',
                        tebalFont: FontWeight.bold,
                        warna: Colors.orange,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailKepemilikan(InvestorPortofolio portofolio) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(TIcons.points, color: TColors.primaryColor),
                gapW8,
                TeksJudulKecil(
                  'Detail Kepemilikan',
                  tebalFont: FontWeight.bold,
                ),
              ],
            ),
            gapH16,
            _buildBarisDetail('Nama', portofolio.namaInvestor),
            _buildBarisDetail(
              'Modal Disetor',
              FormatUang.formatMataUang(portofolio.totalModal),
            ),
            _buildBarisDetail(
              'Persentase',
              '${(portofolio.persentase * 100).toStringAsFixed(1)}%',
            ),
            _buildBarisDetail(
              'Total Dividen',
              FormatUang.formatMataUang(portofolio.totalDividenDiterima),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiwayatDividen(InvestorPortofolio portofolio) {
    final riwayat = portofolio.riwayatDividen;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(TIcons.history, color: TColors.primaryColor),
                gapW8,
                TeksJudulKecil('Riwayat Dividen', tebalFont: FontWeight.bold),
              ],
            ),
            gapH16,
            if (riwayat.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: TeksIsiSedang(
                    'Belum ada riwayat dividen.',
                    warna: Colors.grey,
                  ),
                ),
              )
            else
              ...riwayat.map(_buildItemDividen),
          ],
        ),
      ),
    );
  }

  Widget _buildItemDividen(DividenHistory dividen) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TeksIsiSedang(dividen.keterangan, tebalFont: FontWeight.w500),
                TeksIsiKecil(
                  FormatTanggal.formatDasar(dividen.tanggal),
                  warna: Colors.grey,
                ),
              ],
            ),
          ),
          TeksIsiSedang(
            FormatUang.formatMataUang(dividen.jumlah),
            tebalFont: FontWeight.bold,
            warna: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildBarisDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TeksIsiSedang(label, warna: Colors.grey.shade700),
          TeksIsiSedang(value, tebalFont: FontWeight.w500),
        ],
      ),
    );
  }
}
```

// File: lib/fitur/pelanggan/model/pelanggan_model.dart

```dart
// path: lib/fitur/pelanggan/model/pelanggan_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wifi/fitur/app_role/app_role_enum.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/utils/parser_util.dart';

part 'pelanggan_model.freezed.dart';

@freezed
abstract class PelangganModel with _$PelangganModel implements HasId {
  const PelangganModel._();
  const factory PelangganModel({
    required String id,
    required String nama,
    required String telepon,
    required String alamat,
    required String kataSandi,
    required String macAddress,
    @Default(AppRole.user) AppRole role,
    DateTime? diperbaruiPada,
    @Default(false) bool diHapus,
    DateTime? diarsipkanPada,
    DateTime? terkahirAktif,
  }) = _PelangganModel;
  factory PelangganModel.fromSqlite(Map<String, dynamic> map) {
    Log.info('Creating CustomerModel from SQLite: ${map[NamaKolom.id]}');
    return PelangganModel(
      id: map[NamaKolom.id] as String? ?? '',
      nama: map[NamaKolom.nama] as String? ?? '',
      telepon: map[NamaKolom.telepon] as String? ?? '',
      alamat: map[NamaKolom.alamat] as String? ?? '',
      kataSandi: map[NamaKolom.kataSandi] as String? ?? '',
      macAddress: map[NamaKolom.macAddress] as String? ?? '',
      role:
          ParserUtil.safeParseEnum(AppRole.values, map[NamaKolom.role]) ??
          AppRole.user, // <-- perbaikan
      diHapus: ParserUtil.parseBool(map[NamaKolom.dihapus]),
      diperbaruiPada: ParserUtil.parseDateTime(map[NamaKolom.diperbaruiPada]),
      diarsipkanPada: ParserUtil.parseDateTime(map[NamaKolom.diarsipkanPada]),
      terkahirAktif: ParserUtil.parseDateTime(map[NamaKolom.terakhirAktif]),
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      NamaKolom.id: id,
      NamaKolom.nama: nama,
      NamaKolom.telepon: telepon,
      NamaKolom.alamat: alamat,
      NamaKolom.kataSandi: kataSandi,
      NamaKolom.macAddress: macAddress,
      NamaKolom.role: role.name, // <-- tambahkan
      NamaKolom.dihapus: diHapus ? 1 : 0,
      NamaKolom.diperbaruiPada:
          (diperbaruiPada ?? DateTime.now()).millisecondsSinceEpoch,
      NamaKolom.diarsipkanPada: diarsipkanPada?.millisecondsSinceEpoch,
      NamaKolom.terakhirAktif: terkahirAktif?.millisecondsSinceEpoch,
    };
  }

  factory PelangganModel.fromFirebase(String id, Map<String, dynamic> data) {
    Log.info('Creating CustomerModel from Firebase: $id');
    return PelangganModel(
      id: id,
      nama: data[NamaKolom.nama] as String? ?? '',
      telepon: data[NamaKolom.telepon] as String? ?? '',
      alamat: data[NamaKolom.alamat] as String? ?? '',
      kataSandi: data[NamaKolom.kataSandi] as String? ?? '',
      macAddress: data[NamaKolom.macAddress] as String? ?? '',
      role:
          ParserUtil.safeParseEnum(AppRole.values, data[NamaKolom.role]) ??
          AppRole.user, // <-- tambahkan
      diHapus: ParserUtil.parseBool(data[NamaKolom.dihapus]),
      diperbaruiPada: ParserUtil.parseDateTime(data[NamaKolom.diperbaruiPada]),
      diarsipkanPada: ParserUtil.parseDateTime(data[NamaKolom.diarsipkanPada]),
      terkahirAktif: ParserUtil.parseDateTime(data[NamaKolom.terakhirAktif]),
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      NamaKolom.id: id,
      NamaKolom.nama: nama,
      NamaKolom.telepon: telepon,
      NamaKolom.alamat: alamat,
      NamaKolom.kataSandi: kataSandi,
      NamaKolom.macAddress: macAddress,
      NamaKolom.role: role.name, // <-- tambahkan
      NamaKolom.dihapus: diHapus,
      NamaKolom.diperbaruiPada: Timestamp.fromDate(
        (diperbaruiPada ?? DateTime.now()).toUtc(),
      ),
      NamaKolom.diarsipkanPada: diarsipkanPada != null
          ? Timestamp.fromDate(diarsipkanPada!.toUtc())
          : null,
      NamaKolom.terakhirAktif: terkahirAktif != null
          ? Timestamp.fromDate(terkahirAktif!.toUtc())
          : null,
    };
  }
}
```

// File: lib/fitur/pelanggan/page/admin/form_pelanggan.dart

```dart
// path lib/fitur/pelanggan/page/admin/form_pelanggan.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/fitur/app_role/app_role_enum.dart';
import 'package:wifi/fitur/app_role/role_util.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_global.dart';
import 'package:wifi/fitur/sinkronisasi/layanan_cek_sinkronisasi.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/services/koneksi_internet_service.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/theme/app_sizes.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/input/input_mac_address.dart';
import 'package:wifi/shared/widget/input/input_password.dart';
import 'package:wifi/shared/widget/input/input_teks.dart';
import 'package:wifi/shared/widget/input/input_telepon.dart';

class FormPelanggan extends ConsumerStatefulWidget {
  final PelangganModel? pelanggan;

  const FormPelanggan({super.key, this.pelanggan});

  @override
  ConsumerState<FormPelanggan> createState() => _FormPelangganState();
}

class _FormPelangganState extends ConsumerState<FormPelanggan> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _teleponController = TextEditingController();
  final _alamatController = TextEditingController();
  final _passwordController = TextEditingController();
  final _macAddressController = TextEditingController();

  final _namaFocusNode = FocusNode();
  final _teleponFocusNode = FocusNode();
  final _alamatFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _macAddressFocusNode = FocusNode();
  AppRole _selectedRole = AppRole.user;
  bool get _modeEdit => widget.pelanggan != null;
  bool _menyimpan = false;

  @override
  void initState() {
    super.initState();
    Log.info(
      'Membuka form_pelanggan dalam mode: ${_modeEdit ? "Edit" : "Tambah"}.',
    );
    if (_modeEdit) {
      Log.info(
        'Mode Edit: Mempopulasikan form dengan data pelanggan ID: ${widget.pelanggan!.id}',
      );
      _namaController.text = widget.pelanggan!.nama;
      _teleponController.text = widget.pelanggan!.telepon;
      _alamatController.text = widget.pelanggan!.alamat;
      _passwordController.text = widget.pelanggan!.kataSandi;
      _macAddressController.text = widget.pelanggan!.macAddress;
      _selectedRole = widget.pelanggan!.role;
    }
  }

  @override
  void dispose() {
    Log.info(
      'Menjalankan dispose di CustomerForm. Membersihkan semua controllers dan focus nodes.',
    );
    _namaController.dispose();
    _teleponController.dispose();
    _alamatController.dispose();
    _passwordController.dispose();
    _macAddressController.dispose();
    _namaFocusNode.dispose();
    _teleponFocusNode.dispose();
    _alamatFocusNode.dispose();
    _passwordFocusNode.dispose();
    _macAddressFocusNode.dispose();
    super.dispose();
  }

  Future<void> _simpanPelanggan() async {
    if (_menyimpan) return;
    if (ref.isUser) {
      final isOnline = await ref
          .read(koneksiInternetServiceProvider)
          .cekInternet();
      if (!isOnline) {
        if (!mounted) return;
        ToastUtil.error(context, 'Cek koneksi internet Anda');
        return;
      }
    }
    final pelangganOp = ref.read(pelangganOpGlobalProvider);
    Log.info('Tombol "Simpan" ditekan.');
    if (!_formKey.currentState!.validate()) {
      Log.warning('Form tidak valid. Proses penyimpanan dibatalkan.');
      return;
    }
    try {
      Log.info('Form valid. Memulai proses penyimpanan.');
      setState(() => _menyimpan = true);
      final pelangganBaru = PelangganModel(
        id: _modeEdit ? widget.pelanggan!.id : const Uuid().v4(),
        nama: _namaController.text.trim(),
        telepon: _teleponController.text.trim(),
        alamat: _alamatController.text.trim(),
        kataSandi: _passwordController.text,
        macAddress: _macAddressController.text.trim().toUpperCase(),
        role: _selectedRole,
      );
      Log.info(
        'Model Pelanggan yang akan disimpan: ${pelangganBaru.toFirebase()}',
      );

      if (_modeEdit) {
        Log.info(
          'Menjalankan operasi UPDATE untuk pelanggan ID: ${pelangganBaru.id}',
        );
        await pelangganOp.updatePelanggan(pelangganBaru);
      } else {
        Log.info(
          'Menjalankan operasi CREATE untuk pelanggan baru: ${pelangganBaru.nama}',
        );
        await pelangganOp.tambahPelanggan(pelangganBaru);
      }
      if (mounted) {
        ToastUtil.success(context, 'Data pelanggan berhasil disimpan.');
      }
      if (mounted) {
        Navigator.pop(context);
      }
      unawaited(() {
        if (ref.isAdmin) {
          Log.info('jalankan sinkroniasi');
          ref.read(layananCekSinkronisasiProvider).jalankanCekSinkronisasi();
        }
      }());
    } catch (e, s) {
      Log.error('Gagal menyimpan data pelanggan ke database.', e: e, s: s);
      if (mounted) {
        ToastUtil.error(context, 'Nomor telepon dan password sudah digunakan.');
      }
      return;
    } finally {
      if (mounted) {
        setState(() => _menyimpan = false);
        Log.info('Proses penyimpanan selesai. isSaving diatur ke false.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Log.info('Membangun UI CustomerForm. isSaving: $_menyimpan');
    return Scaffold(
      appBar: AppBar(
        title: Text(_modeEdit ? 'Edit Pelanggan' : 'Tambah Pelanggan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.p16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InputTeks(
                  controller: _namaController,
                  focusNode: _namaFocusNode,
                  nextFocusNode: _teleponFocusNode,
                  label: 'Nama Pelanggan',
                  prefixIcon: TIcons.personOutlined,
                ),
                gapH16,
                InputTelepon(
                  controller: _teleponController,
                  focusNode: _teleponFocusNode,
                  nextFocusNode: _alamatFocusNode,
                ),
                gapH16,
                InputTeks(
                  controller: _alamatController,
                  focusNode: _alamatFocusNode,
                  nextFocusNode: _passwordFocusNode,
                  label: 'Alamat Lengkap',
                  prefixIcon: TIcons.home,
                ),
                gapH16,
                InputPassword(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  nextFocusNode: _macAddressFocusNode,
                ),
                gapH16,
                if (ref.isAdmin)
                  DropdownButtonFormField<AppRole>(
                    value: _selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Peran (Role)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(TIcons.person),
                    ),
                    items: AppRole.values.map((role) {
                      return DropdownMenuItem<AppRole>(
                        value: role,
                        child: Text(role.name.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (newRole) {
                      if (newRole != null) {
                        setState(() {
                          _selectedRole = newRole;
                        });
                      }
                    },
                    validator: (value) =>
                        value == null ? 'Role harus dipilih' : null,
                  ),
                gapH16,
                if (ref.isAdmin)
                  InputMacAddress(
                    controller: _macAddressController,
                    focusNode: _macAddressFocusNode,
                    onSubmitted: (_) => _simpanPelanggan(),
                    textInputAction: TextInputAction.done,
                  ),
                gapH32,
                ElevatedButton(
                  onPressed: _menyimpan ? null : _simpanPelanggan,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _menyimpan
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text('SIMPAN'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

// File: lib/main/main_admin/bootstrap_admin.dart

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wifi/admin/app_admin.dart';
import 'package:wifi/fitur/app_role/app_role_enum.dart';
import 'package:wifi/fitur/app_role/role_util.dart';
import 'package:wifi/fitur/background/layanan_latar_belakang.dart';
import 'package:wifi/fitur/background/layanan_peluncuran.dart';
import 'package:wifi/shared/constant/app_constants.dart';
import 'package:wifi/shared/debug/log.dart';

Future<void> bootstrapAdmin({
  required FirebaseOptions firebaseOptions,
  required bool debugSupabase,
  required String logPrefix,
}) async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  Log.info('Memuat variabel lingkungan dari file .env...');
  await dotenv.load();
  Log.info('Variabel lingkungan berhasil dimuat.');

  Log.info('Menginisialisasi Firebase...');
  await Firebase.initializeApp(options: firebaseOptions);
  Log.info('Inisialisasi Firebase selesai.');

  Log.info('Menginisialisasi Supabase...');
  final supabaseUrl = dotenv.env[AppConstants.supabaseUrlKey] ?? '';
  final supabasePublishableKey =
      dotenv.env[AppConstants.supabasePublishableKey] ?? '';

  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('app_role', AppRole.admin.name);

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );

  Log.info('Inisialisasi Supabase selesai.');

  if (debugSupabase) {
    Log.info('DEBUG URL: $supabaseUrl');
    Log.info('DEBUG PUBLISHABLE KEY LENGTH: ${supabasePublishableKey.length}');
  }

  if (supabaseUrl.isEmpty || supabasePublishableKey.isEmpty) {
    Log.error('❌ ERROR KRUSIAL: Nilai di file .env kosong atau tidak terbaca!');
  }

  Log.info('Menginisialisasi Background Services...');
  await LayananLatarBelakang.inisialisasi();
  Log.info('Inisialisasi Background Services selesai.');

  final container = ProviderContainer();
  try {
    Log.info('Menjadwalkan tugas pengarsipan pelanggan kedaluwarsa...');
    await LayananPeluncuran().jadwalkanTugasArsipPeriodik(container);
    Log.info('Tugas pengarsipan berhasil dijadwalkan.');
  } finally {
    container.dispose();
  }

  Log.info('Menginisialisasi Google Mobile Ads SDK...');
  await MobileAds.instance.initialize();
  Log.info('Inisialisasi Google Mobile Ads SDK selesai.');

  Intl.defaultLocale = 'id_ID';

  Log.info(
    '$logPrefix Memulai aplikasi admin. Menyerahkan kendali ke AppAdmin...',
  );

  runApp(
    ProviderScope(
      overrides: [appRoleProvider.overrideWithValue(AppRole.admin)],
      child: const AppAdmin(),
    ),
  );
}
```

// File: lib/main/main_user/bootstrap_user.dart

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gma_mediation_unity/gma_mediation_unity.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wifi/fitur/app_role/role_util.dart';
import 'package:wifi/fitur/background/layanan_latar_belakang.dart';
import 'package:wifi/shared/constant/app_constants.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/fitur/app_role/app_role_enum.dart';
import 'package:wifi/user/app_user.dart';

Future<void> bootstrapUser({
  required FirebaseOptions firebaseOptions,
  required String logPrefix,
}) async {
  // Memastikan binding Flutter siap dan menahan native splash screen.
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  Log.info('Memuat variabel lingkungan dari file .env...');
  await dotenv.load();
  Log.info('Variabel lingkungan berhasil dimuat.');

  Log.info('Menginisialisasi Firebase...');
  await Firebase.initializeApp(options: firebaseOptions);

  Log.info('Inisialisasi Firebase selesai.');
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('app_role', AppRole.user.name);

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  Log.info('Menginisialisasi Supabase...');
  final supabaseUrl = dotenv.env[AppConstants.supabaseUrlKey]!;
  final supabasePublishableKey =
      dotenv.env[AppConstants.supabasePublishableKey]!;
  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );
  Log.info('Inisialisasi Supabase selesai.');

  Log.info('Menginisialisasi workmanager');
  await LayananLatarBelakang.inisialisasi();

  Log.info('Menginisialisasi GmaMediationUnity');
  await GmaMediationUnity().setGDPRConsent(true);
  await GmaMediationUnity().setCCPAConsent(true);

  Log.info('Menginisialisasi MobileAds');
  await MobileAds.instance.initialize();
  Intl.defaultLocale = 'id_ID';

  Log.info(
    '$logPrefix Memulai aplikasi user. Menyerahkan kendali ke AppUser...',
  );

  // Native splash akan dihilangkan dari dalam SplashScreenUser.
  runApp(
    ProviderScope(
      overrides: [appRoleProvider.overrideWithValue(AppRole.user)],
      child: const AppUser(),
    ),
  );
}
```

// File: lib/shared/constant/nama_kolom.dart

```dart
// path: lib/shared/constant/nama_kolom.dart

abstract final class NamaKolom {
  static const String id = 'id';
  static const String dihapus = 'is_deleted';
  static const String diperbaruiPada = 'updated_at';
  static const String diarsipkanPada = 'archived_at';
  static const String nama = 'name';
  static const String saldo = 'balance';
  static const String deskripsi = 'description';
  static const String jumlah = 'amount';
  static const String tanggal = 'date';
  static const String tipe = 'type';
  static const String idDompet = 'wallet_id';
  static const String idKategori = 'category_id';
  static const String idSubKategori = 'sub_category_id';
  static const String idPelanggan = 'customer_id';
  static const String idPaket = 'package_id';
  static const String idTransaksi = 'transaction_id';
  static const String idDompetTujuan = 'destination_wallet_id';
  static const String poinDidapat = 'earned_points';
  static const String poinDigunakan = 'used_points';
  static const String statusPembayaran = 'payment_status';
  static const String durasiPaket = 'package_duration';
  static const String tipeDurasiPaket = 'duration_type';
  static const String tanggalMulai = 'start_date';
  static const String tanggalBerakhir = 'end_date';
  static const String statusAktivasi = 'is_activated';
  static const String harga = 'price';
  static const String durasi = 'duration';
  static const String poinHadiah = 'reward_points';
  static const String poinPenukaran = 'redemption_points';
  static const String statusPublik = 'is_public';
  static const String telepon = 'phone';
  static const String alamat = 'address';
  static const String kataSandi = 'password';
  static const String macAddress = 'mac_address';
  static const String status = 'status';
  static const String pesan = 'content';
  static const String userId = 'user_id';
  static const String catatanRilis = 'release_notes';
  static const String nomorBuildTerakhir = 'latest_build_number';
  static const String linkDownload = 'download_links';
  static const String versiTerkahir = 'latest_version';
  static const String wajibUpdate = 'is_update_required';
  static const String terakhirAktif = 'last_active_at';
  static const String linkYoutubeTutorial = 'youtube_tutorial';
  static const String waktuOtomatisSinkronisasi = 'auto_sync_interval';
  static const String waktuOtomatisHapusDataArsip = 'auto_delete_archive_days';
  static const String modeMaintenance = 'maintenance_mode';
  static const String infoMaintenance = 'maintenance_info';
  static const String namaTabel = 'table_name';
  static const String ids = 'ids';
  static const String value = 'value';
  static const String linkGambar = 'image_url';
  static const String statusAktif = 'is_active';
  static const String tanggalDibuat = 'created_at';
  static const String judul = 'title';
  static const String statusDibaca = 'is_read';
  static const String idTujuan = 'id_tujuan';
  static const String tanggalTampil = 'tanggal_tampil';
  static const String durasiBonus = 'durasi_bonus';
  static const String tipeDurasiBonus = 'durasi_bonus_type';
  static const String targetRole = 'target_role';

  // Pelanggan
  static const String role = 'role';

  static const String voucher = 'voucher';
  static const String terpakai = 'used';
  static const String tipeVoucher = 'tipeVoucher';
}
```

// File: lib/user/page/login_page.dart

```dart
// path: lib/user/page/login_page.dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/data_dummy/halaman_data_dummy.dart';
import 'package:wifi/fitur/akun/page/daftar_akun_page.dart';
import 'package:wifi/fitur/akun/provider/akun_provider.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/shared/providers/shared_providers.dart';
import 'package:wifi/shared/services/koneksi_internet_service.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/input/input_password.dart';
import 'package:wifi/shared/widget/input/input_telepon.dart';
import 'package:wifi/user/page/main_page.dart';
import 'package:wifi/user/providers/user_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController _teleponController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _teleponFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _sedangLogin = false;

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
  }

  Future<void> _showErrorAlert(String pesan) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Akun tidak ditemukan'),
        content: Text(pesan),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cek Kembali'),
          ),
        ],
      ),
    );
  }

  Future<void> _prosesLogin() async {
    final telepon = _teleponController.text.trim();
    final kataSandi = _passwordController.text.trim();

    // Validasi format
    if (telepon.isEmpty || kataSandi.isEmpty) {
      return;
    }
    if (!RegExp(r'^[0-9]{10,13}$').hasMatch(telepon)) {
      await _showErrorAlert('Nomor telepon tidak valid (minimal 10 digit).');
      return;
    }

    if (_sedangLogin) return;
    setState(() => _sedangLogin = true);

    try {
      final internetService = ref.read(koneksiInternetServiceProvider);
      final isConnected = await internetService.cekInternet();
      if (!isConnected) {
        if (!mounted) return;
        ToastUtil.error(context, 'Tidak ada koneksi internet.');
        return;
      }

      // Proses login ke Firestore
      final firestore = ref.read(firestoreProvider);
      final querySnapshot = await firestore
          .collection(NamaTabel.pelanggan)
          .where(NamaKolom.telepon, isEqualTo: telepon)
          .where(NamaKolom.kataSandi, isEqualTo: kataSandi)
          .where(NamaKolom.dihapus, isEqualTo: false)
          .limit(1)
          .get();

      if (!mounted) return;

      if (querySnapshot.docs.isEmpty) {
        await _showErrorAlert('Nomor telepon tidak terdaftar.');
        return;
      }

      // Verifikasi password (misal dengan hash)
      final userDoc = querySnapshot.docs.first;
      final pelanggan = PelangganModel.fromFirebase(userDoc.id, userDoc.data());
      await ref.read(pengelolaAkunProvider.notifier).login(pelanggan);

      // Navigasi
      if (!mounted) return;
      unawaited(
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const MainPage())),
      );

      // Tugas sekunder
      try {
        final layananAktivitasUser = await ref.read(
          layananAktivitasUserProvider.future,
        );
        unawaited(
          layananAktivitasUser.pingAktivitas(pelanggan.id, paksa: true),
        );
      } catch (e, s) {
        Log.error('Gagal ping activity', e: e, s: s);
      }
    } catch (e, s) {
      Log.error('Login error', e: e, s: s);
      if (mounted) {
        await _showErrorAlert('Terjadi kesalahan. Silakan coba lagi.');
      }
    } finally {
      if (mounted) setState(() => _sedangLogin = false);
    }
  }

  Future<void> _tanganiPilihAkunTersedia() async {
    if (_sedangLogin) return;
    final layananPenyimpananLokal = await ref.read(
      layananPenyimpananLokalProvider.future,
    );
    final akun = await layananPenyimpananLokal.ambilDaftarAkun();
    if (!mounted) return;

    if (akun.isEmpty) {
      ToastUtil.info(
        context,
        'Tidak ada akun yang tersimpan. Silakan login manual.',
      );
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (context) => const DaftarAkunPage()),
      );
    }
  }

  @override
  void dispose() {
    _teleponController.dispose();
    _passwordController.dispose();
    _teleponFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Silakan Masuk',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              gapH32,
              InputTelepon(
                controller: _teleponController,
                focusNode: _teleponFocusNode,
                nextFocusNode: _passwordFocusNode,
                enabled: !_sedangLogin,
              ),
              gapH16,
              InputPassword(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                onSubmitted: (_) => _prosesLogin(),
                textInputAction: TextInputAction.done,
                enabled: !_sedangLogin,
              ),
              gapH24,
              ElevatedButton(
                onPressed: _sedangLogin ? null : _prosesLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: TColors.primaryColor.withValues(
                    alpha: 0.5,
                  ),
                ),
                child: _sedangLogin
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text('Login'),
              ),
              gapH16,
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Atau',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              gapH16,
              OutlinedButton.icon(
                icon: const Icon(Icons.people_alt_outlined),
                label: const Text('Pilih dari Akun Tersimpan'),
                onPressed: _sedangLogin ? null : _tanganiPilihAkunTersedia,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              gapH8,
              Align(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (kDebugMode)
                      TextButton(
                        onPressed: () {
                          unawaited(
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (context) => const HalamanDataDummy(),
                              ),
                            ),
                          );
                        },
                        child: const Text('Debug: Dummy'),
                      ),

                    TextButton(
                      onPressed: _sedangLogin
                          ? null
                          : () {
                              unawaited(
                                showDialog<void>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text(
                                      'Fitur Dalam Pengembangan',
                                    ),
                                    content: const Text(
                                      'Fitur ini sedang kami kerjakan.',
                                    ),
                                    actions: [
                                      TextButton(
                                        child: const Text('OK'),
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                      child: const Text('Lupa Sandi?'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```
