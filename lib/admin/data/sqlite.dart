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
  final dbHelper = ref.read(sqliteDatabaseProvider);
  final db = await dbHelper.database;
  return db;
});

/// Kelas pembantu untuk mengelola database SQLite.
class SqliteDatabase {
  /// Instance tunggal dari DatabaseHelper.
  static final SqliteDatabase instance = SqliteDatabase._internal();
  static Database? _database;

  // diubah: Versi dinaikkan ke 53 untuk menambah kolom durasi bonus di transaksi.
  static const int _databaseVersion = 53;

  SqliteDatabase._internal() {
    Log.info('DatabaseHelper instance dibuat (singleton _internal).');
  }

  /// Atur ulang instance database (hanya untuk pengujian).
  void debugSetDatabaseNull() {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      _database = null;
    }
  }

  /// Mendapatkan instance database.
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
            onCreate: createTables,
            onUpgrade: _onUpgrade,
          ),
        );
      }

      Log.info('Mode PRODUKSI/DEBUG. Menggunakan database fisik.');
      final Directory documentsDirectory =
          await getApplicationDocumentsDirectory();
      final String path = join(documentsDirectory.path, 'mydatabase.db');
      Log.info('Path database: $path');

      Log.info('Membuka database dengan versi $_databaseVersion...');
      return openDatabase(
        path,
        version: _databaseVersion,
        onCreate: createTables,
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
      Log.info(
        '[MIGRASI v47] Memulai migrasi skema destruktif.',
      );
      await _migrateToV47(db);
    }

    if (oldVersion < 48) {
      Log.info(
        '[MIGRASI v48] Menambahkan kolom `diperbarui` ke `status_aplikasi`.',
      );
      await _migrateToV48(db);
    }

    if (oldVersion < 49) {
      Log.info(
        '[MIGRASI v49] Rename semua kolom ke snake_case Inggris.',
      );
      await _migrateToV49(db);
    }

    if (oldVersion < 50) {
      Log.info(
        '[MIGRASI v50] Rename semua nama tabel ke snake_case Inggris.',
      );
      await _migrateToV50(db);
    }

    if (oldVersion < 51) {
      Log.info(
        '[MIGRASI v51] Menambahkan kolom `${NamaKolom.lastActiveAt}` ke tabel `${NamaTabel.customer}`.',
      );
      await _migrateToV51(db);
    }

    if (oldVersion < 52) {
      Log.info(
        '[MIGRASI v52] Membuat tabel `${NamaTabel.notification}`.',
      );
      await _migrateToV52(db);
    }

    if (oldVersion < 53) {
      Log.info(
        '[MIGRASI v53] Menambahkan kolom durasi bonus ke tabel transaksi.',
      );
      await _migrateToV53(db);
    }

    Log.info('========================================');
    Log.info('PROSES UPGRADE DATABASE SELESAI');
    Log.info(
        'Database berhasil diupgrade dari versi $oldVersion ke versi $newVersion.');
    Log.info('========================================');
  }

  Future<void> _migrateToV51(final Database db) async {
    Log.info('[MIGRASI v51] Menambahkan kolom ${NamaKolom.lastActiveAt}...');
    await db.execute(
      'ALTER TABLE ${NamaTabel.customer} ADD COLUMN ${NamaKolom.lastActiveAt} INTEGER',
    );
    Log.info(
        '[MIGRASI v51] Penambahan kolom ${NamaKolom.lastActiveAt} selesai.');
  }

  Future<void> _migrateToV52(final Database db) async {
    Log.info('[MIGRASI v52] Membuat tabel notification...');
    await db.execute(_tabelNotification);
    Log.info('[MIGRASI v52] Tabel notification berhasil dibuat.');
  }

  Future<void> _migrateToV53(final Database db) async {
    Log.info(
        '[MIGRASI v53] Menambahkan kolom durasi_bonus dan durasi_bonus_type...');

    const String tableName = NamaTabel.transactions;
    // Mengambil informasi kolom yang ada saat ini di tabel transactions
    final results = await db.rawQuery('PRAGMA table_info("$tableName")');
    final existingColumns =
        results.map((row) => row['name'] as String).toList();

    // Hanya tambahkan kolom jika belum ada dalam daftar kolom yang ada
    if (!existingColumns.contains(NamaKolom.durasiBonus)) {
      await db.execute(
        'ALTER TABLE "$tableName" ADD COLUMN ${NamaKolom.durasiBonus} INTEGER',
      );
    }

    if (!existingColumns.contains(NamaKolom.durasiBonusType)) {
      await db.execute(
        'ALTER TABLE "$tableName" ADD COLUMN ${NamaKolom.durasiBonusType} TEXT',
      );
    }
    Log.info('[MIGRASI v53] Penambahan kolom selesai.');
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
    final List<String> daftarTabel = [
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
    await db
        .execute('ALTER TABLE dompet RENAME COLUMN diperbarui TO updated_at');
    await db
        .execute('ALTER TABLE dompet RENAME COLUMN diarsipkan TO archived_at');

    await db.execute('ALTER TABLE kategori RENAME COLUMN nama TO name');
    await db.execute('ALTER TABLE kategori RENAME COLUMN tipe TO type');
    await db.execute(
        'ALTER TABLE kategori RENAME COLUMN id_sub_kategori TO sub_category_id');
    await db
        .execute('ALTER TABLE kategori RENAME COLUMN diperbarui TO updated_at');
    await db.execute(
        'ALTER TABLE kategori RENAME COLUMN diarsipkan TO archived_at');

    await db.execute('ALTER TABLE sub_kategori RENAME COLUMN nama TO name');
    await db.execute(
        'ALTER TABLE sub_kategori RENAME COLUMN id_kategori TO category_id');
    await db.execute(
        'ALTER TABLE sub_kategori RENAME COLUMN diperbarui TO updated_at');
    await db.execute(
        'ALTER TABLE sub_kategori RENAME COLUMN diarsipkan TO archived_at');

    await db.execute('ALTER TABLE paket RENAME COLUMN nama TO name');
    await db.execute('ALTER TABLE paket RENAME COLUMN harga TO price');
    await db.execute('ALTER TABLE paket RENAME COLUMN durasi TO duration');
    await db.execute('ALTER TABLE paket RENAME COLUMN tipe TO type');
    await db
        .execute('ALTER TABLE paket RENAME COLUMN jumlahPoin TO earned_points');
    await db
        .execute('ALTER TABLE paket RENAME COLUMN diperbarui TO updated_at');
    await db
        .execute('ALTER TABLE paket RENAME COLUMN diarsipkan TO archived_at');
    await db.execute(
        'ALTER TABLE paket RENAME COLUMN poin_hadiah TO reward_points');
    await db.execute(
        'ALTER TABLE paket RENAME COLUMN poin_penukaran TO redemption_points');

    await db.execute('ALTER TABLE pelanggan RENAME COLUMN nama TO name');
    await db.execute('ALTER TABLE pelanggan RENAME COLUMN telepon TO phone');
    await db.execute('ALTER TABLE pelanggan RENAME COLUMN alamat TO address');
    await db.execute(
        'ALTER TABLE pelanggan RENAME COLUMN diperbarui TO updated_at');
    await db.execute(
        'ALTER TABLE pelanggan RENAME COLUMN diarsipkan TO archived_at');

    await db.execute(
        'ALTER TABLE pelanggan_aktif RENAME COLUMN id_pelanggan TO customer_id');
    await db.execute(
        'ALTER TABLE pelanggan_aktif RENAME COLUMN id_paket TO package_id');
    await db.execute(
        'ALTER TABLE pelanggan_aktif RENAME COLUMN id_transaksi TO transaction_id');
    await db.execute(
        'ALTER TABLE pelanggan_aktif RENAME COLUMN tanggal_mulai TO start_date');
    await db.execute(
        'ALTER TABLE pelanggan_aktif RENAME COLUMN tanggal_berakhir TO end_date');
    await db.execute(
        'ALTER TABLE pelanggan_aktif RENAME COLUMN diperbarui TO updated_at');
    await db.execute(
        'ALTER TABLE pelanggan_aktif RENAME COLUMN diarsipkan TO archived_at');

    await db.execute(
        'ALTER TABLE transaksi RENAME COLUMN keterangan TO description');
    await db.execute('ALTER TABLE transaksi RENAME COLUMN jumlah TO amount');
    await db.execute('ALTER TABLE transaksi RENAME COLUMN tanggal TO date');
    await db.execute('ALTER TABLE transaksi RENAME COLUMN tipe TO type');
    await db
        .execute('ALTER TABLE transaksi RENAME COLUMN id_dompet TO wallet_id');
    await db.execute(
        'ALTER TABLE transaksi RENAME COLUMN id_kategori TO category_id');
    await db.execute(
        'ALTER TABLE transaksi RENAME COLUMN id_sub_kategori TO sub_category_id');
    await db.execute(
        'ALTER TABLE transaksi RENAME COLUMN id_pelanggan TO customer_id');
    await db
        .execute('ALTER TABLE transaksi RENAME COLUMN id_paket TO package_id');
    await db.execute(
        'ALTER TABLE transaksi RENAME COLUMN diperbarui TO updated_at');
    await db.execute(
        'ALTER TABLE transaksi RENAME COLUMN diarsipkan TO archived_at');
    await db.execute(
        'ALTER TABLE transaksi RENAME COLUMN id_dompet_tujuan TO destination_wallet_id');
    await db.execute(
        'ALTER TABLE transaksi RENAME COLUMN poin_yang_dihasilkan TO earned_points');
    await db.execute(
        'ALTER TABLE transaksi RENAME COLUMN poin_yang_digunakan TO used_points');
    await db.execute(
        'ALTER TABLE transaksi RENAME COLUMN status_pembayaran TO payment_status');
    await db.execute(
        'ALTER TABLE transaksi RENAME COLUMN durasi_paket TO package_duration');
    await db.execute(
        'ALTER TABLE transaksi RENAME COLUMN tipe_durasi_paket TO duration_type');
    await db.execute(
        'ALTER TABLE transaksi RENAME COLUMN tanggal_mulai TO start_date');
    await db.execute(
        'ALTER TABLE transaksi RENAME COLUMN tanggal_berakhir TO end_date');
    await db.execute(
        'ALTER TABLE transaksi RENAME COLUMN aktivasi_paket TO is_activated');

    await db.execute('ALTER TABLE kritik_saran RENAME COLUMN isi TO content');
    await db.execute('ALTER TABLE kritik_saran RENAME COLUMN tanggal TO date');
    await db.execute(
        'ALTER TABLE kritik_saran RENAME COLUMN diperbarui TO updated_at');
    await db.execute(
        'ALTER TABLE kritik_saran RENAME COLUMN diarsipkan TO archived_at');

    await db.execute(
        'ALTER TABLE pesanan RENAME COLUMN id_pelanggan TO customer_id');
    await db
        .execute('ALTER TABLE pesanan RENAME COLUMN id_paket TO package_id');
    await db.execute('ALTER TABLE pesanan RENAME COLUMN tanggal TO date');
    await db
        .execute('ALTER TABLE pesanan RENAME COLUMN diperbarui TO updated_at');
    await db
        .execute('ALTER TABLE pesanan RENAME COLUMN diarsipkan TO archived_at');

    await db.execute(
        'ALTER TABLE versi_apk_user RENAME COLUMN catatan_rilis TO release_notes');
    await db.execute(
        'ALTER TABLE versi_apk_user RENAME COLUMN nomor_build_terbaru TO latest_build_number');
    await db.execute(
        'ALTER TABLE versi_apk_user RENAME COLUMN tautan_unduhan TO download_links');
    await db.execute(
        'ALTER TABLE versi_apk_user RENAME COLUMN versi_terbaru TO latest_version');
    await db.execute(
        'ALTER TABLE versi_apk_user RENAME COLUMN wajib_update TO is_update_required');
    await db.execute(
        'ALTER TABLE versi_apk_user RENAME COLUMN diperbarui TO updated_at');
    await db.execute(
        'ALTER TABLE versi_apk_user RENAME COLUMN diarsipkan TO archived_at');

    await db.execute(
        'ALTER TABLE pengaturan RENAME COLUMN interval_sinkronisasi_otomatis TO auto_sync_interval');
    await db.execute(
        'ALTER TABLE pengaturan RENAME COLUMN hapus_otomatis_data_arsip TO auto_delete_archive_days');
    await db.execute(
        'ALTER TABLE pengaturan RENAME COLUMN diperbarui TO updated_at');
    await db.execute(
        'ALTER TABLE pengaturan RENAME COLUMN mode_pemeliharaan TO maintenance_mode');
    await db.execute(
        'ALTER TABLE pengaturan RENAME COLUMN info_pemeliharaan TO maintenance_info');

    await db
        .execute('ALTER TABLE status_unggah RENAME COLUMN tabel TO table_name');
    await db.execute(
        'ALTER TABLE status_unggah RENAME COLUMN diperbarui TO updated_at');

    await db.execute(
        'ALTER TABLE status_aplikasi RENAME COLUMN diperbarui TO updated_at');

    await db.execute('ALTER TABLE pesan RENAME COLUMN isi TO content');
    await db.execute('ALTER TABLE pesan RENAME COLUMN tanggal TO date');

    Log.info('[MIGRASI v49] Semua rename kolom selesai.');
  }

  Future<void> _migrateToV50(final Database db) async {
    Log.info('[MIGRASI v50] Rename tabel ke snake_case...');
    Log.warning('[MIGRASI v50] Data tetap AMAN. Hanya nama tabel diubah.');

    await db.execute('ALTER TABLE dompet RENAME TO ${NamaTabel.wallet}');
    await db.execute('ALTER TABLE kategori RENAME TO ${NamaTabel.category}');
    await db
        .execute('ALTER TABLE sub_kategori RENAME TO ${NamaTabel.subCategory}');
    await db.execute('ALTER TABLE paket RENAME TO ${NamaTabel.package}');
    await db.execute('ALTER TABLE pelanggan RENAME TO ${NamaTabel.customer}');
    await db.execute(
        'ALTER TABLE pelanggan_aktif RENAME TO ${NamaTabel.activeCustomer}');

    // diperbaiki: Ditambahkan escaping double quotes ("") untuk tabel transaction via TableNameValue
    await db
        .execute('ALTER TABLE transaksi RENAME TO "${NamaTabel.transactions}"');
    await db
        .execute('ALTER TABLE kritik_saran RENAME TO ${NamaTabel.feedback}');

    // diperbaiki: Ditambahkan escaping double quotes ("") untuk tabel order via TableNameValue
    await db
        .execute('ALTER TABLE pesanan RENAME TO "${NamaTabel.customerOrder}"');
    await db.execute(
        'ALTER TABLE versi_apk_user RENAME TO ${NamaTabel.userApkVersion}');
    await db.execute('ALTER TABLE pengaturan RENAME TO ${NamaTabel.settings}');
    await db.execute(
        'ALTER TABLE status_unggah RENAME TO ${NamaTabel.uploadStatus}');
    await db.execute('ALTER TABLE pesan RENAME TO ${NamaTabel.message}');

    Log.info('[MIGRASI v50] Semua rename tabel selesai.');
  }

  /// Membuat tabel-tabel database (untuk database baru).
  Future<void> createTables(final Database db, final int version) async {
    Log.info('========================================');
    Log.info(
        'MEMULAI PEMBUATAN TABEL DATABASE (onCreate) UNTUK VERSI $version');
    Log.info('========================================');
    final batch = db.batch();
    _createAllTables(batch);
    try {
      await batch.commit(noResult: true);
      Log.info('PROSES PEMBUATAN TABEL & INDEX SELESAI');
    } on Exception catch (e, st) {
      Log.error('Gagal total saat membuat tabel atau index.', e: e, s: st);
      rethrow;
    }
  }

  void _createAllTables(final Batch batch) {
    batch.execute(_tabelCategory);
    batch.execute(_tabelSubCategory);
    batch.execute(_tabelPackage);
    batch.execute(_tabelCustomer);
    batch.execute(_tabelActiveCustomer);
    batch.execute(_tabelTransaction);
    batch.execute(_tabelWallet);
    batch.execute(_tabelFeedback);
    batch.execute(_tabelOrder);
    batch.execute(_tabelUserApkVersion);
    batch.execute(_tabelSetting);
    batch.execute(_tabelUploadStatus);
    batch.execute(_tabelMessage);
    batch
        .execute(_tabelNotification); // 2. Tambahkan pembuatan tabel notifikasi
    Log.info('Semua 14 definisi tabel (v52) ditambahkan ke batch.');

    // diperbaiki: Index ditargetkan menggunakan escaping keyword "transaction" otomatis dari TableNameValue
    const String trxTable = '"${NamaTabel.transactions}"';
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_transaction_wallet_id ON $trxTable(${NamaKolom.walletId})',
    );
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_transaction_destination_wallet_id ON $trxTable(${NamaKolom.destinationWalletId})',
    );
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_transaction_is_deleted ON $trxTable(${NamaKolom.isDeleted})',
    );
    Log.info('Semua 3 definisi index (v51) ditambahkan ke batch.');
  }

  void _createAllTablesV47(final Batch batch) {
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

  static const String _tabelWallet = '''
    CREATE TABLE ${NamaTabel.wallet}(
      ${NamaKolom.id} TEXT PRIMARY KEY,
      ${NamaKolom.name} TEXT NOT NULL,
      ${NamaKolom.balance} REAL NOT NULL,
      ${NamaKolom.updatedAt} INTEGER,
      ${NamaKolom.isDeleted} INTEGER NOT NULL DEFAULT 0,
      ${NamaKolom.archivedAt} INTEGER
    )
  ''';

  static const String _tabelTransaction = '''
    CREATE TABLE "${NamaTabel.transactions}" (
      ${NamaKolom.id} TEXT PRIMARY KEY,
      ${NamaKolom.description} TEXT NOT NULL,
      ${NamaKolom.amount} REAL NOT NULL,
      ${NamaKolom.date} INTEGER NOT NULL,
      ${NamaKolom.type} TEXT NOT NULL,
      ${NamaKolom.walletId} TEXT,
      ${NamaKolom.categoryId} TEXT,
      ${NamaKolom.subCategoryId} TEXT,
      ${NamaKolom.customerId} TEXT,
      ${NamaKolom.packageId} TEXT,
      ${NamaKolom.updatedAt} INTEGER,
      ${NamaKolom.archivedAt} INTEGER,
      ${NamaKolom.isDeleted} INTEGER NOT NULL DEFAULT 0,
      ${NamaKolom.destinationWalletId} TEXT,
      ${NamaKolom.earnedPoints} INTEGER NOT NULL DEFAULT 0,
      ${NamaKolom.usedPoints} INTEGER NOT NULL DEFAULT 0,
      ${NamaKolom.paymentStatus} TEXT,
      ${NamaKolom.packageDuration} INTEGER,
      ${NamaKolom.durationType} TEXT,
      ${NamaKolom.durasiBonus} INTEGER,
      ${NamaKolom.durasiBonusType} TEXT,
      ${NamaKolom.startDate} INTEGER,
      ${NamaKolom.endDate} INTEGER,
      ${NamaKolom.isActivated} INTEGER DEFAULT 0
    )
  ''';

  static const String _tabelUserApkVersion = '''
    CREATE TABLE ${NamaTabel.userApkVersion}(
      ${NamaKolom.id} TEXT PRIMARY KEY,
      ${NamaKolom.releaseNotes} TEXT NOT NULL,
      ${NamaKolom.latestBuildNumber} TEXT NOT NULL,
      ${NamaKolom.downloadLinks} TEXT NOT NULL,
      ${NamaKolom.latestVersion} TEXT NOT NULL,
      ${NamaKolom.isUpdateRequired} INTEGER NOT NULL,
      ${NamaKolom.youtubeTutorial} TEXT NOT NULL,
      ${NamaKolom.isDeleted} INTEGER NOT NULL DEFAULT 0,
      ${NamaKolom.archivedAt} INTEGER,
      ${NamaKolom.updatedAt} INTEGER
    )
  ''';

  static const String _tabelUploadStatus = '''
    CREATE TABLE ${NamaTabel.uploadStatus}(
      ${NamaKolom.id} TEXT PRIMARY KEY,
      ${NamaKolom.value} TEXT NOT NULL,
      ${NamaKolom.updatedAt} INTEGER
    )
  ''';

  static const String _tabelMessage = '''
    CREATE TABLE ${NamaTabel.message}(
      ${NamaKolom.id} TEXT PRIMARY KEY,
      ${NamaKolom.content} TEXT NOT NULL,
      ${NamaKolom.date} INTEGER NOT NULL,
      ${NamaKolom.status} TEXT NOT NULL
    )
  ''';

  static const String _tabelSetting = '''
    CREATE TABLE ${NamaTabel.settings}(
      ${NamaKolom.id} TEXT PRIMARY KEY,
      ${NamaKolom.autoSyncInterval} INTEGER NOT NULL DEFAULT 24,
      ${NamaKolom.autoDeleteArchiveDays} INTEGER NOT NULL DEFAULT 30,
      ${NamaKolom.updatedAt} INTEGER,
      ${NamaKolom.maintenanceMode} INTEGER NOT NULL DEFAULT 0,
      ${NamaKolom.maintenanceInfo} TEXT
    )
  ''';

  static const String _tabelCategory = '''
    CREATE TABLE ${NamaTabel.category}(
      ${NamaKolom.id} TEXT PRIMARY KEY,
      ${NamaKolom.name} TEXT NOT NULL,
      ${NamaKolom.type} TEXT NOT NULL,
      ${NamaKolom.subCategoryId} TEXT,
      ${NamaKolom.updatedAt} INTEGER,
      ${NamaKolom.isDeleted} INTEGER NOT NULL DEFAULT 0,
      ${NamaKolom.archivedAt} INTEGER
    )
  ''';

  static const String _tabelSubCategory = '''
    CREATE TABLE ${NamaTabel.subCategory}(
      ${NamaKolom.id} TEXT PRIMARY KEY,
      ${NamaKolom.name} TEXT NOT NULL,
      ${NamaKolom.categoryId} TEXT NOT NULL,
      ${NamaKolom.updatedAt} INTEGER,
      ${NamaKolom.isDeleted} INTEGER NOT NULL DEFAULT 0,
      ${NamaKolom.archivedAt} INTEGER,
      FOREIGN KEY (${NamaKolom.categoryId}) REFERENCES ${NamaTabel.category} (${NamaKolom.id}) ON DELETE CASCADE
    )
  ''';

  static const String _tabelPackage = '''
    CREATE TABLE ${NamaTabel.package}(
      ${NamaKolom.id} TEXT PRIMARY KEY,
      ${NamaKolom.name} TEXT NOT NULL,
      ${NamaKolom.price} INTEGER NOT NULL,
      ${NamaKolom.duration} INTEGER NOT NULL,
      ${NamaKolom.type} TEXT NOT NULL,
      ${NamaKolom.earnedPoints} INTEGER NOT NULL DEFAULT 0,
      ${NamaKolom.updatedAt} INTEGER,
      ${NamaKolom.isDeleted} INTEGER NOT NULL DEFAULT 0,
      ${NamaKolom.archivedAt} INTEGER,
      ${NamaKolom.rewardPoints} INTEGER NOT NULL DEFAULT 0,
      ${NamaKolom.redemptionPoints} INTEGER NOT NULL DEFAULT 0,
      ${NamaKolom.isPublic} INTEGER NOT NULL DEFAULT 1
    )
  ''';

  static const String _tabelCustomer = '''
    CREATE TABLE ${NamaTabel.customer}(
      ${NamaKolom.id} TEXT PRIMARY KEY,
      ${NamaKolom.name} TEXT NOT NULL,
      ${NamaKolom.phone} TEXT NOT NULL,
      ${NamaKolom.address} TEXT NOT NULL,
      ${NamaKolom.password} TEXT NOT NULL,
      ${NamaKolom.macAddress} TEXT NOT NULL,
      ${NamaKolom.status} TEXT NOT NULL DEFAULT 'aktif',
      ${NamaKolom.updatedAt} INTEGER,
      ${NamaKolom.archivedAt} INTEGER,
      ${NamaKolom.isDeleted} INTEGER NOT NULL DEFAULT 0,
      ${NamaKolom.lastActiveAt} INTEGER
    )
  ''';

  static const String _tabelActiveCustomer = '''
    CREATE TABLE ${NamaTabel.activeCustomer}(
      ${NamaKolom.id} TEXT PRIMARY KEY,
      ${NamaKolom.customerId} TEXT NOT NULL,
      ${NamaKolom.packageId} TEXT NOT NULL,
      ${NamaKolom.transactionId} TEXT,
      ${NamaKolom.startDate} INTEGER,
      ${NamaKolom.endDate} INTEGER,
      ${NamaKolom.status} TEXT NOT NULL,
      ${NamaKolom.updatedAt} INTEGER,
      ${NamaKolom.isDeleted} INTEGER NOT NULL DEFAULT 0,
      ${NamaKolom.archivedAt} INTEGER,
      FOREIGN KEY (${NamaKolom.customerId}) REFERENCES ${NamaTabel.customer} (${NamaKolom.id}) ON DELETE CASCADE ON UPDATE CASCADE,
      FOREIGN KEY (${NamaKolom.packageId}) REFERENCES ${NamaTabel.package} (${NamaKolom.id}) ON DELETE CASCADE ON UPDATE CASCADE,
      FOREIGN KEY (${NamaKolom.transactionId}) REFERENCES "${NamaTabel.transactions}" (${NamaKolom.id}) ON DELETE SET NULL
    )
  ''';

  static const String _tabelFeedback = '''
    CREATE TABLE ${NamaTabel.feedback}(
      ${NamaKolom.id} TEXT PRIMARY KEY,
      ${NamaKolom.content} TEXT NOT NULL,
      ${NamaKolom.date} INTEGER NOT NULL,
      ${NamaKolom.userId} TEXT NOT NULL,
      ${NamaKolom.updatedAt} INTEGER,
      ${NamaKolom.isDeleted} INTEGER NOT NULL DEFAULT 0,
      ${NamaKolom.archivedAt} INTEGER,
      FOREIGN KEY (${NamaKolom.userId}) REFERENCES ${NamaTabel.customer} (${NamaKolom.id}) ON DELETE CASCADE
    )
  ''';

  static const String _tabelOrder = '''
    CREATE TABLE "${NamaTabel.customerOrder}" (
      ${NamaKolom.id} TEXT PRIMARY KEY,
      ${NamaKolom.customerId} TEXT NOT NULL,
      ${NamaKolom.packageId} TEXT NOT NULL,
      ${NamaKolom.date} INTEGER NOT NULL,
      ${NamaKolom.status} TEXT,
      ${NamaKolom.updatedAt} INTEGER,
      ${NamaKolom.isDeleted} INTEGER NOT NULL DEFAULT 0,
      ${NamaKolom.archivedAt} INTEGER,
      FOREIGN KEY (${NamaKolom.customerId}) REFERENCES ${NamaTabel.customer} (${NamaKolom.id}) ON DELETE CASCADE,
      FOREIGN KEY (${NamaKolom.packageId}) REFERENCES ${NamaTabel.package} (${NamaKolom.id}) ON DELETE CASCADE
    )
  ''';

  // 1. Definisi tabel notifikasi
  static const String _tabelNotification = '''
    CREATE TABLE ${NamaTabel.notification}(
      ${NamaKolom.id} TEXT PRIMARY KEY,
      ${NamaKolom.content} TEXT NOT NULL,
      ${NamaKolom.date} INTEGER NOT NULL,
      ${NamaKolom.status} TEXT NOT NULL,
      ${NamaKolom.updatedAt} INTEGER,
      ${NamaKolom.isDeleted} INTEGER NOT NULL DEFAULT 0,
      ${NamaKolom.archivedAt} INTEGER
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
