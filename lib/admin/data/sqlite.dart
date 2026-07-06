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
      await db.execute(_tabelNotification);
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
