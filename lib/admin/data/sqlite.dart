// path: lib/admin/data/sqlite.dart

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';

final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});
final databaseProvider = FutureProvider((ref) async {
  final dbHelper = ref.read(databaseHelperProvider);
  final db = await dbHelper.database;
  return db;
});

/// Kelas pembantu untuk mengelola database SQLite.
class DatabaseHelper {
  /// Instance tunggal dari DatabaseHelper.
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  // diubah: Versi dinaikkan ke 53 untuk menambah kolom durasi bonus di transaksi.
  static const int _databaseVersion = 53;

  DatabaseHelper._internal() {
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
      Log.error('Gagal total mendapatkan instance database.', e: e, st: st);
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
      Log.error('Gagal membuka atau membuat database.', e: e, st: st);
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
        '[MIGRASI v51] Menambahkan kolom `${ColumnNames.lastActiveAt}` ke tabel `${TableNameValue.get(TableName.customer)}`.',
      );
      await _migrateToV51(db);
    }

    if (oldVersion < 52) {
      Log.info(
        '[MIGRASI v52] Membuat tabel `${TableNameValue.get(TableName.notification)}`.',
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
    Log.info('[MIGRASI v51] Menambahkan kolom ${ColumnNames.lastActiveAt}...');
    await db.execute(
      'ALTER TABLE ${TableNameValue.get(TableName.customer)} ADD COLUMN ${ColumnNames.lastActiveAt} INTEGER',
    );
    Log.info(
        '[MIGRASI v51] Penambahan kolom ${ColumnNames.lastActiveAt} selesai.');
  }

  Future<void> _migrateToV52(final Database db) async {
    Log.info('[MIGRASI v52] Membuat tabel notification...');
    await db.execute(_tabelNotification);
    Log.info('[MIGRASI v52] Tabel notification berhasil dibuat.');
  }

  Future<void> _migrateToV53(final Database db) async {
    Log.info(
        '[MIGRASI v53] Menambahkan kolom durasi_bonus dan durasi_bonus_type...');

    final String tableName = TableNameValue.get(TableName.transactions);
    // Mengambil informasi kolom yang ada saat ini di tabel transactions
    final results = await db.rawQuery('PRAGMA table_info("$tableName")');
    final existingColumns =
        results.map((row) => row['name'] as String).toList();

    // Hanya tambahkan kolom jika belum ada dalam daftar kolom yang ada
    if (!existingColumns.contains(ColumnNames.durasiBonus)) {
      await db.execute(
        'ALTER TABLE "$tableName" ADD COLUMN ${ColumnNames.durasiBonus} INTEGER',
      );
    }

    if (!existingColumns.contains(ColumnNames.durasiBonusType)) {
      await db.execute(
        'ALTER TABLE "$tableName" ADD COLUMN ${ColumnNames.durasiBonusType} TEXT',
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

    await db.execute(
        'ALTER TABLE dompet RENAME TO ${TableNameValue.get(TableName.wallet)}');
    await db.execute(
        'ALTER TABLE kategori RENAME TO ${TableNameValue.get(TableName.category)}');
    await db.execute(
        'ALTER TABLE sub_kategori RENAME TO ${TableNameValue.get(TableName.subCategory)}');
    await db.execute(
        'ALTER TABLE paket RENAME TO ${TableNameValue.get(TableName.package)}');
    await db.execute(
        'ALTER TABLE pelanggan RENAME TO ${TableNameValue.get(TableName.customer)}');
    await db.execute(
        'ALTER TABLE pelanggan_aktif RENAME TO ${TableNameValue.get(TableName.activeCustomer)}');

    // diperbaiki: Ditambahkan escaping double quotes ("") untuk tabel transaction via TableNameValue
    await db.execute(
        'ALTER TABLE transaksi RENAME TO "${TableNameValue.get(TableName.transactions)}"');
    await db.execute(
        'ALTER TABLE kritik_saran RENAME TO ${TableNameValue.get(TableName.feedback)}');

    // diperbaiki: Ditambahkan escaping double quotes ("") untuk tabel order via TableNameValue
    await db.execute(
        'ALTER TABLE pesanan RENAME TO "${TableNameValue.get(TableName.customerOrder)}"');
    await db.execute(
        'ALTER TABLE versi_apk_user RENAME TO ${TableNameValue.get(TableName.userApkVersion)}');
    await db.execute(
        'ALTER TABLE pengaturan RENAME TO ${TableNameValue.get(TableName.settings)}');
    await db.execute(
        'ALTER TABLE status_unggah RENAME TO ${TableNameValue.get(TableName.uploadStatus)}');
    await db.execute(
        'ALTER TABLE pesan RENAME TO ${TableNameValue.get(TableName.message)}');

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
      Log.error('Gagal total saat membuat tabel atau index.', e: e, st: st);
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
    final String trxTable = '"${TableNameValue.get(TableName.transactions)}"';
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_transaction_wallet_id ON $trxTable(${ColumnNames.walletId})',
    );
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_transaction_destination_wallet_id ON $trxTable(${ColumnNames.destinationWalletId})',
    );
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_transaction_is_deleted ON $trxTable(${ColumnNames.isDeleted})',
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

  static final String _tabelWallet = '''
    CREATE TABLE ${TableNameValue.get(TableName.wallet)}(
      ${ColumnNames.id} TEXT PRIMARY KEY,
      ${ColumnNames.name} TEXT NOT NULL,
      ${ColumnNames.balance} REAL NOT NULL,
      ${ColumnNames.updatedAt} INTEGER,
      ${ColumnNames.isDeleted} INTEGER NOT NULL DEFAULT 0,
      ${ColumnNames.archivedAt} INTEGER
    )
  ''';

  static final String _tabelTransaction = '''
    CREATE TABLE "${TableNameValue.get(TableName.transactions)}" (
      ${ColumnNames.id} TEXT PRIMARY KEY,
      ${ColumnNames.description} TEXT NOT NULL,
      ${ColumnNames.amount} REAL NOT NULL,
      ${ColumnNames.date} INTEGER NOT NULL,
      ${ColumnNames.type} TEXT NOT NULL,
      ${ColumnNames.walletId} TEXT,
      ${ColumnNames.categoryId} TEXT,
      ${ColumnNames.subCategoryId} TEXT,
      ${ColumnNames.customerId} TEXT,
      ${ColumnNames.packageId} TEXT,
      ${ColumnNames.updatedAt} INTEGER,
      ${ColumnNames.archivedAt} INTEGER,
      ${ColumnNames.isDeleted} INTEGER NOT NULL DEFAULT 0,
      ${ColumnNames.destinationWalletId} TEXT,
      ${ColumnNames.earnedPoints} INTEGER NOT NULL DEFAULT 0,
      ${ColumnNames.usedPoints} INTEGER NOT NULL DEFAULT 0,
      ${ColumnNames.paymentStatus} TEXT,
      ${ColumnNames.packageDuration} INTEGER,
      ${ColumnNames.durationType} TEXT,
      ${ColumnNames.durasiBonus} INTEGER,
      ${ColumnNames.durasiBonusType} TEXT,
      ${ColumnNames.startDate} INTEGER,
      ${ColumnNames.endDate} INTEGER,
      ${ColumnNames.isActivated} INTEGER DEFAULT 0
    )
  ''';

  static final String _tabelUserApkVersion = '''
    CREATE TABLE ${TableNameValue.get(TableName.userApkVersion)}(
      ${ColumnNames.id} TEXT PRIMARY KEY,
      ${ColumnNames.releaseNotes} TEXT NOT NULL,
      ${ColumnNames.latestBuildNumber} TEXT NOT NULL,
      ${ColumnNames.downloadLinks} TEXT NOT NULL,
      ${ColumnNames.latestVersion} TEXT NOT NULL,
      ${ColumnNames.isUpdateRequired} INTEGER NOT NULL,
      ${ColumnNames.youtubeTutorial} TEXT NOT NULL,
      ${ColumnNames.isDeleted} INTEGER NOT NULL DEFAULT 0,
      ${ColumnNames.archivedAt} INTEGER,
      ${ColumnNames.updatedAt} INTEGER
    )
  ''';

  static final String _tabelUploadStatus = '''
    CREATE TABLE ${TableNameValue.get(TableName.uploadStatus)}(
      ${ColumnNames.id} TEXT PRIMARY KEY,
      ${ColumnNames.value} TEXT NOT NULL,
      ${ColumnNames.updatedAt} INTEGER
    )
  ''';

  static final String _tabelMessage = '''
    CREATE TABLE ${TableNameValue.get(TableName.message)}(
      ${ColumnNames.id} TEXT PRIMARY KEY,
      ${ColumnNames.content} TEXT NOT NULL,
      ${ColumnNames.date} INTEGER NOT NULL,
      ${ColumnNames.status} TEXT NOT NULL
    )
  ''';

  static final String _tabelSetting = '''
    CREATE TABLE ${TableNameValue.get(TableName.settings)}(
      ${ColumnNames.id} TEXT PRIMARY KEY,
      ${ColumnNames.autoSyncInterval} INTEGER NOT NULL DEFAULT 24,
      ${ColumnNames.autoDeleteArchiveDays} INTEGER NOT NULL DEFAULT 30,
      ${ColumnNames.updatedAt} INTEGER,
      ${ColumnNames.maintenanceMode} INTEGER NOT NULL DEFAULT 0,
      ${ColumnNames.maintenanceInfo} TEXT
    )
  ''';

  static final String _tabelCategory = '''
    CREATE TABLE ${TableNameValue.get(TableName.category)}(
      ${ColumnNames.id} TEXT PRIMARY KEY,
      ${ColumnNames.name} TEXT NOT NULL,
      ${ColumnNames.type} TEXT NOT NULL,
      ${ColumnNames.subCategoryId} TEXT,
      ${ColumnNames.updatedAt} INTEGER,
      ${ColumnNames.isDeleted} INTEGER NOT NULL DEFAULT 0,
      ${ColumnNames.archivedAt} INTEGER
    )
  ''';

  static final String _tabelSubCategory = '''
    CREATE TABLE ${TableNameValue.get(TableName.subCategory)}(
      ${ColumnNames.id} TEXT PRIMARY KEY,
      ${ColumnNames.name} TEXT NOT NULL,
      ${ColumnNames.categoryId} TEXT NOT NULL,
      ${ColumnNames.updatedAt} INTEGER,
      ${ColumnNames.isDeleted} INTEGER NOT NULL DEFAULT 0,
      ${ColumnNames.archivedAt} INTEGER,
      FOREIGN KEY (${ColumnNames.categoryId}) REFERENCES ${TableNameValue.get(TableName.category)} (${ColumnNames.id}) ON DELETE CASCADE
    )
  ''';

  static final String _tabelPackage = '''
    CREATE TABLE ${TableNameValue.get(TableName.package)}(
      ${ColumnNames.id} TEXT PRIMARY KEY,
      ${ColumnNames.name} TEXT NOT NULL,
      ${ColumnNames.price} INTEGER NOT NULL,
      ${ColumnNames.duration} INTEGER NOT NULL,
      ${ColumnNames.type} TEXT NOT NULL,
      ${ColumnNames.earnedPoints} INTEGER NOT NULL DEFAULT 0,
      ${ColumnNames.updatedAt} INTEGER,
      ${ColumnNames.isDeleted} INTEGER NOT NULL DEFAULT 0,
      ${ColumnNames.archivedAt} INTEGER,
      ${ColumnNames.rewardPoints} INTEGER NOT NULL DEFAULT 0,
      ${ColumnNames.redemptionPoints} INTEGER NOT NULL DEFAULT 0,
      ${ColumnNames.isPublic} INTEGER NOT NULL DEFAULT 1
    )
  ''';

  static final String _tabelCustomer = '''
    CREATE TABLE ${TableNameValue.get(TableName.customer)}(
      ${ColumnNames.id} TEXT PRIMARY KEY,
      ${ColumnNames.name} TEXT NOT NULL,
      ${ColumnNames.phone} TEXT NOT NULL,
      ${ColumnNames.address} TEXT NOT NULL,
      ${ColumnNames.password} TEXT NOT NULL,
      ${ColumnNames.macAddress} TEXT NOT NULL,
      ${ColumnNames.status} TEXT NOT NULL DEFAULT 'aktif',
      ${ColumnNames.updatedAt} INTEGER,
      ${ColumnNames.archivedAt} INTEGER,
      ${ColumnNames.isDeleted} INTEGER NOT NULL DEFAULT 0,
      ${ColumnNames.lastActiveAt} INTEGER
    )
  ''';

  static final String _tabelActiveCustomer = '''
    CREATE TABLE ${TableNameValue.get(TableName.activeCustomer)}(
      ${ColumnNames.id} TEXT PRIMARY KEY,
      ${ColumnNames.customerId} TEXT NOT NULL,
      ${ColumnNames.packageId} TEXT NOT NULL,
      ${ColumnNames.transactionId} TEXT,
      ${ColumnNames.startDate} INTEGER,
      ${ColumnNames.endDate} INTEGER,
      ${ColumnNames.status} TEXT NOT NULL,
      ${ColumnNames.updatedAt} INTEGER,
      ${ColumnNames.isDeleted} INTEGER NOT NULL DEFAULT 0,
      ${ColumnNames.archivedAt} INTEGER,
      FOREIGN KEY (${ColumnNames.customerId}) REFERENCES ${TableNameValue.get(TableName.customer)} (${ColumnNames.id}) ON DELETE CASCADE ON UPDATE CASCADE,
      FOREIGN KEY (${ColumnNames.packageId}) REFERENCES ${TableNameValue.get(TableName.package)} (${ColumnNames.id}) ON DELETE CASCADE ON UPDATE CASCADE,
      FOREIGN KEY (${ColumnNames.transactionId}) REFERENCES "${TableNameValue.get(TableName.transactions)}" (${ColumnNames.id}) ON DELETE SET NULL
    )
  ''';

  static final String _tabelFeedback = '''
    CREATE TABLE ${TableNameValue.get(TableName.feedback)}(
      ${ColumnNames.id} TEXT PRIMARY KEY,
      ${ColumnNames.content} TEXT NOT NULL,
      ${ColumnNames.date} INTEGER NOT NULL,
      ${ColumnNames.userId} TEXT NOT NULL,
      ${ColumnNames.updatedAt} INTEGER,
      ${ColumnNames.isDeleted} INTEGER NOT NULL DEFAULT 0,
      ${ColumnNames.archivedAt} INTEGER,
      FOREIGN KEY (${ColumnNames.userId}) REFERENCES ${TableNameValue.get(TableName.customer)} (${ColumnNames.id}) ON DELETE CASCADE
    )
  ''';

  static final String _tabelOrder = '''
    CREATE TABLE "${TableNameValue.get(TableName.customerOrder)}" (
      ${ColumnNames.id} TEXT PRIMARY KEY,
      ${ColumnNames.customerId} TEXT NOT NULL,
      ${ColumnNames.packageId} TEXT NOT NULL,
      ${ColumnNames.date} INTEGER NOT NULL,
      ${ColumnNames.status} TEXT,
      ${ColumnNames.updatedAt} INTEGER,
      ${ColumnNames.isDeleted} INTEGER NOT NULL DEFAULT 0,
      ${ColumnNames.archivedAt} INTEGER,
      FOREIGN KEY (${ColumnNames.customerId}) REFERENCES ${TableNameValue.get(TableName.customer)} (${ColumnNames.id}) ON DELETE CASCADE,
      FOREIGN KEY (${ColumnNames.packageId}) REFERENCES ${TableNameValue.get(TableName.package)} (${ColumnNames.id}) ON DELETE CASCADE
    )
  ''';

  // 1. Definisi tabel notifikasi
  static final String _tabelNotification = '''
    CREATE TABLE ${TableNameValue.get(TableName.notification)}(
      ${ColumnNames.id} TEXT PRIMARY KEY,
      ${ColumnNames.content} TEXT NOT NULL,
      ${ColumnNames.date} INTEGER NOT NULL,
      ${ColumnNames.status} TEXT NOT NULL,
      ${ColumnNames.updatedAt} INTEGER,
      ${ColumnNames.isDeleted} INTEGER NOT NULL DEFAULT 0,
      ${ColumnNames.archivedAt} INTEGER
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
