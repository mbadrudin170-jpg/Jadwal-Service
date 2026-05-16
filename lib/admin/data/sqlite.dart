// path: lib/admin/data/sqlite.dart
// diubah: Menaikkan versi DB ke 49, menambahkan migrasi _migrateToV49
//         untuk mengganti semua nama kolom ke snake_case Inggris agar
//         konsisten dengan ColumnNames dan semua Model.
//         Data lama AMAN karena menggunakan ALTER TABLE RENAME COLUMN.
// diubah: Memperbarui semua definisi tabel CREATE TABLE ke nama kolom baru.
// ditambah: Menambahkan dokumentasi untuk anggota publik.

import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wifi/shared/debug/log.dart';

/// Kelas pembantu untuk mengelola database SQLite.
class DatabaseHelper {
  /// Instance tunggal dari DatabaseHelper.
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  // diubah: Versi dinaikkan ke 49 untuk rename semua kolom ke snake_case Inggris.
  static const int _databaseVersion = 49;

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
        '[MIGRASI v47] Memulai migrasi skema untuk memperbaiki tabel `kritik_saran` (destruktif).',
      );
      await _migrateToV47(db);
    }

    if (oldVersion < 48) {
      Log.info(
        '[MIGRASI v48] Menambahkan kolom `diperbarui` ke tabel `status_aplikasi`.',
      );
      await _migrateToV48(db);
    }

    if (oldVersion < 49) {
      Log.info(
        '[MIGRASI v49] Rename semua kolom ke snake_case Inggris agar konsisten dengan ColumnNames.',
      );
      await _migrateToV49(db);
    }

    Log.info('========================================');
    Log.info('PROSES UPGRADE DATABASE SELESAI');
    Log.info(
      'Database berhasil diupgrade dari versi $oldVersion ke versi $newVersion.',
    );
    Log.info('========================================');
  }

  Future<void> _migrateToV45(final Database db) async {
    Log.info(
      '[MIGRASI v45] Menangani tabel "pengaturan" untuk memastikan PRIMARY KEY.',
    );
    await db.execute('DROP TABLE IF EXISTS pengaturan');
    await db.execute(_tabelPengaturan);
    Log.info('[MIGRASI v45] Tabel `pengaturan` berhasil dibuat ulang.');
  }

  Future<void> _migrateToV47(final Database db) async {
    Log.info(
      '[MIGRASI v47] Memulai migrasi skema destruktif untuk memperbaiki schema.',
    );
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

    Log.warning(
      '[MIGRASI v47] Proses ini akan menghapus dan membuat ulang tabel.',
    );

    for (final namaTabel in daftarTabel) {
      batch.execute('DROP TABLE IF EXISTS $namaTabel');
      Log.info('[MIGRASI v47] Jadwalkan DROP TABLE untuk `$namaTabel`.');
    }

    // Gunakan definisi tabel v47 (nama kolom lama)
    _createAllTablesV47(batch);
    await batch.commit(noResult: true);
    Log.info('[MIGRASI v47] Tabel berhasil dibuat ulang dengan skema v47.');
  }

  Future<void> _migrateToV48(final Database db) async {
    Log.info(
      '[MIGRASI v48] Menambahkan kolom `diperbarui` ke tabel `status_aplikasi`.',
    );
    await db.execute(
      'ALTER TABLE status_aplikasi ADD COLUMN diperbarui INTEGER',
    );
    Log.info('[MIGRASI v48] Kolom `diperbarui` berhasil ditambahkan.');
  }

  Future<void> _migrateToV49(final Database db) async {
    Log.info(
      '[MIGRASI v49] Memulai rename semua kolom ke snake_case Inggris.',
    );
    Log.warning(
      '[MIGRASI v49] Data tetap AMAN. Hanya nama kolom yang diubah.',
    );

    // ============================================================
    // TABEL: dompet
    // ============================================================
    Log.info('[MIGRASI v49] Rename kolom tabel `dompet`...');
    await db.execute('ALTER TABLE dompet RENAME COLUMN namaDompet TO name');
    await db.execute('ALTER TABLE dompet RENAME COLUMN saldo TO balance');
    await db
        .execute('ALTER TABLE dompet RENAME COLUMN diperbarui TO updated_at');
    await db
        .execute('ALTER TABLE dompet RENAME COLUMN diarsipkan TO archived_at');

    // ============================================================
    // TABEL: kategori
    // ============================================================
    Log.info('[MIGRASI v49] Rename kolom tabel `kategori`...');
    await db.execute('ALTER TABLE kategori RENAME COLUMN nama TO name');
    await db.execute('ALTER TABLE kategori RENAME COLUMN tipe TO type');
    await db.execute(
        'ALTER TABLE kategori RENAME COLUMN id_sub_kategori TO sub_category_id');
    await db
        .execute('ALTER TABLE kategori RENAME COLUMN diperbarui TO updated_at');
    await db.execute(
        'ALTER TABLE kategori RENAME COLUMN diarsipkan TO archived_at');

    // ============================================================
    // TABEL: sub_kategori
    // ============================================================
    Log.info('[MIGRASI v49] Rename kolom tabel `sub_kategori`...');
    await db.execute('ALTER TABLE sub_kategori RENAME COLUMN nama TO name');
    await db.execute(
        'ALTER TABLE sub_kategori RENAME COLUMN id_kategori TO category_id');
    await db.execute(
        'ALTER TABLE sub_kategori RENAME COLUMN diperbarui TO updated_at');
    await db.execute(
        'ALTER TABLE sub_kategori RENAME COLUMN diarsipkan TO archived_at');

    // ============================================================
    // TABEL: paket
    // ============================================================
    Log.info('[MIGRASI v49] Rename kolom tabel `paket`...');
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

    // ============================================================
    // TABEL: pelanggan
    // ============================================================
    Log.info('[MIGRASI v49] Rename kolom tabel `pelanggan`...');
    await db.execute('ALTER TABLE pelanggan RENAME COLUMN nama TO name');
    await db.execute('ALTER TABLE pelanggan RENAME COLUMN telepon TO phone');
    await db.execute('ALTER TABLE pelanggan RENAME COLUMN alamat TO address');
    await db.execute(
        'ALTER TABLE pelanggan RENAME COLUMN diperbarui TO updated_at');
    await db.execute(
        'ALTER TABLE pelanggan RENAME COLUMN diarsipkan TO archived_at');

    // ============================================================
    // TABEL: pelanggan_aktif
    // ============================================================
    Log.info('[MIGRASI v49] Rename kolom tabel `pelanggan_aktif`...');
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

    // ============================================================
    // TABEL: transaksi
    // ============================================================
    Log.info('[MIGRASI v49] Rename kolom tabel `transaksi`...');
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

    // ============================================================
    // TABEL: kritik_saran
    // ============================================================
    Log.info('[MIGRASI v49] Rename kolom tabel `kritik_saran`...');
    await db.execute('ALTER TABLE kritik_saran RENAME COLUMN isi TO content');
    await db.execute('ALTER TABLE kritik_saran RENAME COLUMN tanggal TO date');
    await db.execute(
        'ALTER TABLE kritik_saran RENAME COLUMN diperbarui TO updated_at');
    await db.execute(
        'ALTER TABLE kritik_saran RENAME COLUMN diarsipkan TO archived_at');

    // ============================================================
    // TABEL: pesanan
    // ============================================================
    Log.info('[MIGRASI v49] Rename kolom tabel `pesanan`...');
    await db.execute(
        'ALTER TABLE pesanan RENAME COLUMN id_pelanggan TO customer_id');
    await db
        .execute('ALTER TABLE pesanan RENAME COLUMN id_paket TO package_id');
    await db.execute('ALTER TABLE pesanan RENAME COLUMN tanggal TO date');
    await db
        .execute('ALTER TABLE pesanan RENAME COLUMN diperbarui TO updated_at');
    await db
        .execute('ALTER TABLE pesanan RENAME COLUMN diarsipkan TO archived_at');

    // ============================================================
    // TABEL: versi_apk_user
    // ============================================================
    Log.info('[MIGRASI v49] Rename kolom tabel `versi_apk_user`...');
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
        'ALTER TABLE versi_apk_user RENAME COLUMN youtube_tutorial TO youtube_tutorial');
    await db.execute(
        'ALTER TABLE versi_apk_user RENAME COLUMN diperbarui TO updated_at');
    await db.execute(
        'ALTER TABLE versi_apk_user RENAME COLUMN diarsipkan TO archived_at');

    // ============================================================
    // TABEL: pengaturan
    // ============================================================
    Log.info('[MIGRASI v49] Rename kolom tabel `pengaturan`...');
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

    // ============================================================
    // TABEL: status_unggah
    // ============================================================
    Log.info('[MIGRASI v49] Rename kolom tabel `status_unggah`...');
    await db
        .execute('ALTER TABLE status_unggah RENAME COLUMN tabel TO table_name');
    await db
        .execute('ALTER TABLE status_unggah RENAME COLUMN status TO status');
    await db.execute('ALTER TABLE status_unggah RENAME COLUMN ids TO ids');
    await db.execute(
        'ALTER TABLE status_unggah RENAME COLUMN diperbarui TO updated_at');

    // ============================================================
    // TABEL: status_aplikasi
    // ============================================================
    Log.info('[MIGRASI v49] Rename kolom tabel `status_aplikasi`...');
    await db
        .execute('ALTER TABLE status_aplikasi RENAME COLUMN value TO value');
    await db.execute(
        'ALTER TABLE status_aplikasi RENAME COLUMN diperbarui TO updated_at');

    // ============================================================
    // TABEL: pesan
    // ============================================================
    Log.info('[MIGRASI v49] Rename kolom tabel `pesan`...');
    await db.execute('ALTER TABLE pesan RENAME COLUMN isi TO content');
    await db.execute('ALTER TABLE pesan RENAME COLUMN tanggal TO date');
    await db.execute('ALTER TABLE pesan RENAME COLUMN status TO status');

    Log.info('[MIGRASI v49] Semua rename kolom selesai.');
  }

  /// Membuat tabel-tabel database (untuk database baru, versi 49).
  Future<void> createTables(final Database db, final int version) async {
    Log.info('========================================');
    Log.info(
      'MEMULAI PEMBUATAN TABEL DATABASE (onCreate) UNTUK VERSI $version',
    );
    Log.info('========================================');
    final batch = db.batch();
    _createAllTables(batch);
    try {
      await batch.commit(noResult: true);
      Log.info('========================================');
      Log.info('PROSES PEMBUATAN TABEL & INDEX SELESAI');
      Log.info('========================================');
    } on Exception catch (e, st) {
      Log.error('Gagal total saat membuat tabel atau index.', e: e, st: st);
      rethrow;
    }
  }

  /// Membuat semua tabel dengan nama kolom snake_case Inggris (v49).
  void _createAllTables(final Batch batch) {
    batch.execute(_tabelKategori);
    batch.execute(_tabelSubKategori);
    batch.execute(_tabelPaket);
    batch.execute(_tabelPelanggan);
    batch.execute(_tabelPelangganAktif);
    batch.execute(_tabelTransaksi);
    batch.execute(_tabelDompet);
    batch.execute(_tabelKritikSaran);
    batch.execute(_tabelPesanan);
    batch.execute(_tabelVersiApkUser);
    batch.execute(_tabelPengaturan);
    batch.execute(_tabelStatusUnggah);
    batch.execute(_tabelStatusAplikasi);
    batch.execute(_tabelPesan);
    Log.info('Semua 14 definisi tabel (v49) ditambahkan ke batch.');

    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_transaksi_wallet_id ON transaksi(wallet_id)',
    );
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_transaksi_destination_wallet_id ON transaksi(destination_wallet_id)',
    );
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_transaksi_is_deleted ON transaksi(is_deleted)',
    );
    Log.info('Semua 3 definisi index (v49) ditambahkan ke batch.');
  }

  /// Membuat semua tabel dengan nama kolom lama (v47, untuk migrasi destruktif).
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
    batch.execute(_tabelPengaturanV47);
    batch.execute(_tabelStatusUnggahV47);
    batch.execute(_tabelStatusAplikasiV47);
    batch.execute(_tabelPesanV47);
    Log.info('Semua 14 definisi tabel (v47) ditambahkan ke batch.');
  }

  // ============================================================
  // DEFINISI TABEL v49 (snake_case Inggris)
  // ============================================================

  static const String _tabelDompet = '''
    CREATE TABLE dompet(
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      balance REAL NOT NULL,
      updated_at INTEGER,
      is_deleted INTEGER NOT NULL DEFAULT 0,
      archived_at INTEGER
    )
  ''';

  static const String _tabelTransaksi = '''
    CREATE TABLE transaksi(
      id TEXT PRIMARY KEY,
      description TEXT NOT NULL,
      amount REAL NOT NULL,
      date INTEGER NOT NULL,
      type TEXT NOT NULL,
      wallet_id TEXT,
      category_id TEXT,
      sub_category_id TEXT,
      customer_id TEXT,
      package_id TEXT,
      updated_at INTEGER,
      archived_at INTEGER,
      is_deleted INTEGER NOT NULL DEFAULT 0,
      destination_wallet_id TEXT,
      earned_points INTEGER NOT NULL DEFAULT 0,
      used_points INTEGER NOT NULL DEFAULT 0,
      payment_status TEXT,
      package_duration INTEGER,
      duration_type TEXT,
      start_date INTEGER,
      end_date INTEGER,
      is_activated INTEGER DEFAULT 0
    )
  ''';

  static const String _tabelVersiApkUser = '''
    CREATE TABLE versi_apk_user(
      id TEXT PRIMARY KEY,
      release_notes TEXT NOT NULL,
      latest_build_number TEXT NOT NULL,
      download_links TEXT NOT NULL,
      latest_version TEXT NOT NULL,
      is_update_required INTEGER NOT NULL,
      youtube_tutorial TEXT NOT NULL,
      is_deleted INTEGER NOT NULL DEFAULT 0,
      archived_at INTEGER,
      updated_at INTEGER
    )
  ''';

  static const String _tabelStatusUnggah = '''
    CREATE TABLE status_unggah(
      table_name TEXT PRIMARY KEY,
      status INTEGER NOT NULL,
      ids TEXT NOT NULL,
      updated_at INTEGER
    )
  ''';

  static const String _tabelStatusAplikasi = '''
    CREATE TABLE status_aplikasi(
      id TEXT PRIMARY KEY,
      value TEXT NOT NULL,
      updated_at INTEGER
    )
  ''';

  static const String _tabelPesan = '''
    CREATE TABLE pesan(
      id TEXT PRIMARY KEY,
      content TEXT NOT NULL,
      date INTEGER NOT NULL,
      status TEXT NOT NULL
    )
  ''';

  static const String _tabelPengaturan = '''
    CREATE TABLE pengaturan(
      id TEXT PRIMARY KEY,
      auto_sync_interval INTEGER NOT NULL DEFAULT 24,
      auto_delete_archive_days INTEGER NOT NULL DEFAULT 30,
      updated_at INTEGER,
      maintenance_mode INTEGER NOT NULL DEFAULT 0,
      maintenance_info TEXT
    )
  ''';

  static const String _tabelKategori = '''
    CREATE TABLE kategori(
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      type TEXT NOT NULL,
      sub_category_id TEXT,
      updated_at INTEGER,
      is_deleted INTEGER NOT NULL DEFAULT 0,
      archived_at INTEGER
    )
  ''';

  static const String _tabelSubKategori = '''
    CREATE TABLE sub_kategori(
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      category_id TEXT NOT NULL,
      updated_at INTEGER,
      is_deleted INTEGER NOT NULL DEFAULT 0,
      archived_at INTEGER,
      FOREIGN KEY (category_id) REFERENCES kategori (id) ON DELETE CASCADE
    )
  ''';

  static const String _tabelPaket = '''
    CREATE TABLE paket(
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      price INTEGER NOT NULL,
      duration INTEGER NOT NULL,
      type TEXT NOT NULL,
      earned_points INTEGER NOT NULL DEFAULT 0,
      updated_at INTEGER,
      is_deleted INTEGER NOT NULL DEFAULT 0,
      archived_at INTEGER,
      reward_points INTEGER NOT NULL DEFAULT 0,
      redemption_points INTEGER NOT NULL DEFAULT 0,
      is_public INTEGER NOT NULL DEFAULT 1
    )
  ''';

  static const String _tabelPelanggan = '''
    CREATE TABLE pelanggan(
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      phone TEXT NOT NULL,
      address TEXT NOT NULL,
      password TEXT NOT NULL,
      mac_address TEXT NOT NULL,
      status TEXT NOT NULL DEFAULT 'aktif',
      updated_at INTEGER,
      archived_at INTEGER,
      is_deleted INTEGER NOT NULL DEFAULT 0
    )
  ''';

  static const String _tabelPelangganAktif = '''
    CREATE TABLE pelanggan_aktif(
      id TEXT PRIMARY KEY,
      customer_id TEXT NOT NULL,
      package_id TEXT NOT NULL,
      transaction_id TEXT,
      start_date INTEGER,
      end_date INTEGER,
      status TEXT NOT NULL,
      updated_at INTEGER,
      is_deleted INTEGER NOT NULL DEFAULT 0,
      archived_at INTEGER,
      FOREIGN KEY (customer_id) REFERENCES pelanggan (id) ON DELETE CASCADE ON UPDATE CASCADE,
      FOREIGN KEY (package_id) REFERENCES paket (id) ON DELETE CASCADE ON UPDATE CASCADE,
      FOREIGN KEY (transaction_id) REFERENCES transaksi (id) ON DELETE SET NULL
    )
  ''';

  static const String _tabelKritikSaran = '''
    CREATE TABLE kritik_saran(
      id TEXT PRIMARY KEY,
      content TEXT NOT NULL,
      date INTEGER NOT NULL,
      user_id TEXT NOT NULL,
      updated_at INTEGER,
      is_deleted INTEGER NOT NULL DEFAULT 0,
      archived_at INTEGER,
      FOREIGN KEY (user_id) REFERENCES pelanggan (id) ON DELETE CASCADE
    )
  ''';

  static const String _tabelPesanan = '''
    CREATE TABLE pesanan(
      id TEXT PRIMARY KEY,
      customer_id TEXT NOT NULL,
      package_id TEXT NOT NULL,
      date INTEGER NOT NULL,
      status TEXT,
      updated_at INTEGER,
      is_deleted INTEGER NOT NULL DEFAULT 0,
      archived_at INTEGER,
      FOREIGN KEY (customer_id) REFERENCES pelanggan (id) ON DELETE CASCADE,
      FOREIGN KEY (package_id) REFERENCES paket (id) ON DELETE CASCADE
    )
  ''';

  // ============================================================
  // DEFINISI TABEL v47 (nama kolom lama, untuk migrasi destruktif)
  // ============================================================

  static const String _tabelDompetV47 = '''
    CREATE TABLE dompet(
      id TEXT PRIMARY KEY,
      namaDompet TEXT NOT NULL,
      saldo REAL NOT NULL,
      diperbarui INTEGER,
      isDeleted INTEGER NOT NULL DEFAULT 0,
      diarsipkan INTEGER
    )
  ''';

  static const String _tabelTransaksiV47 = '''
    CREATE TABLE transaksi(
      id TEXT PRIMARY KEY,
      keterangan TEXT NOT NULL,
      jumlah REAL NOT NULL,
      tanggal INTEGER NOT NULL,
      tipe TEXT NOT NULL,
      id_dompet TEXT,
      id_kategori TEXT,
      id_sub_kategori TEXT,
      id_pelanggan TEXT,
      id_paket TEXT,
      diperbarui INTEGER,
      diarsipkan INTEGER,
      isDeleted INTEGER NOT NULL DEFAULT 0,
      id_dompet_tujuan TEXT,
      poin_yang_dihasilkan INTEGER NOT NULL DEFAULT 0,
      poin_yang_digunakan INTEGER NOT NULL DEFAULT 0,
      status_pembayaran TEXT,
      durasi_paket INTEGER,
      tipe_durasi_paket TEXT,
      tanggal_mulai INTEGER,
      tanggal_berakhir INTEGER,
      aktivasi_paket INTEGER DEFAULT 0
    )
  ''';

  static const String _tabelVersiApkUserV47 = '''
    CREATE TABLE versi_apk_user(
      id TEXT PRIMARY KEY,
      catatan_rilis TEXT NOT NULL,
      nomor_build_terbaru TEXT NOT NULL,
      tautan_unduhan TEXT NOT NULL,
      versi_terbaru TEXT NOT NULL,
      wajib_update INTEGER NOT NULL,
      youtube_tutorial TEXT NOT NULL,
      isDeleted INTEGER NOT NULL DEFAULT 0,
      diarsipkan INTEGER,
      diperbarui INTEGER
    )
  ''';

  static const String _tabelStatusUnggahV47 = '''
    CREATE TABLE status_unggah(
      tabel TEXT PRIMARY KEY,
      status INTEGER NOT NULL,
      ids TEXT NOT NULL,
      diperbarui INTEGER
    )
  ''';

  static const String _tabelStatusAplikasiV47 = '''
    CREATE TABLE status_aplikasi(
      id TEXT PRIMARY KEY,
      value TEXT NOT NULL,
      diperbarui INTEGER
    )
  ''';

  static const String _tabelPesanV47 = '''
    CREATE TABLE pesan(
      id TEXT PRIMARY KEY,
      isi TEXT NOT NULL,
      tanggal INTEGER NOT NULL,
      status TEXT NOT NULL
    )
  ''';

  static const String _tabelPengaturanV47 = '''
    CREATE TABLE pengaturan(
      id TEXT PRIMARY KEY,
      interval_sinkronisasi_otomatis INTEGER NOT NULL DEFAULT 24,
      hapus_otomatis_data_arsip INTEGER NOT NULL DEFAULT 30,
      diperbarui INTEGER,
      mode_pemeliharaan INTEGER NOT NULL DEFAULT 0,
      info_pemeliharaan TEXT
    )
  ''';

  static const String _tabelKategoriV47 = '''
    CREATE TABLE kategori(
      id TEXT PRIMARY KEY,
      nama TEXT NOT NULL,
      tipe TEXT NOT NULL,
      id_sub_kategori TEXT,
      diperbarui INTEGER,
      isDeleted INTEGER NOT NULL DEFAULT 0,
      diarsipkan INTEGER
    )
  ''';

  static const String _tabelSubKategoriV47 = '''
    CREATE TABLE sub_kategori(
      id TEXT PRIMARY KEY,
      nama TEXT NOT NULL,
      id_kategori TEXT NOT NULL,
      diperbarui INTEGER,
      isDeleted INTEGER NOT NULL DEFAULT 0,
      diarsipkan INTEGER,
      FOREIGN KEY (id_kategori) REFERENCES kategori (id) ON DELETE CASCADE
    )
  ''';

  static const String _tabelPaketV47 = '''
    CREATE TABLE paket(
      id TEXT PRIMARY KEY,
      nama TEXT NOT NULL,
      harga INTEGER NOT NULL,
      durasi INTEGER NOT NULL,
      tipe TEXT NOT NULL,
      jumlahPoin INTEGER NOT NULL DEFAULT 0,
      diperbarui INTEGER,
      isDeleted INTEGER NOT NULL DEFAULT 0,
      diarsipkan INTEGER,
      poin_hadiah INTEGER NOT NULL DEFAULT 0,
      poin_penukaran INTEGER NOT NULL DEFAULT 0,
      isPublic INTEGER NOT NULL DEFAULT 1
    )
  ''';

  static const String _tabelPelangganV47 = '''
    CREATE TABLE pelanggan(
      id TEXT PRIMARY KEY,
      nama TEXT NOT NULL,
      telepon TEXT NOT NULL,
      alamat TEXT NOT NULL,
      password TEXT NOT NULL,
      mac_address TEXT NOT NULL,
      status TEXT NOT NULL DEFAULT 'aktif',
      diperbarui INTEGER,
      diarsipkan INTEGER,
      isDeleted INTEGER NOT NULL DEFAULT 0
    )
  ''';

  static const String _tabelPelangganAktifV47 = '''
    CREATE TABLE pelanggan_aktif(
      id TEXT PRIMARY KEY,
      id_pelanggan TEXT NOT NULL,
      id_paket TEXT NOT NULL,
      id_transaksi TEXT,
      tanggal_mulai INTEGER,
      tanggal_berakhir INTEGER,
      status TEXT NOT NULL,
      diperbarui INTEGER,
      isDeleted INTEGER NOT NULL DEFAULT 0,
      diarsipkan INTEGER,
      FOREIGN KEY (id_pelanggan) REFERENCES pelanggan (id) ON DELETE CASCADE ON UPDATE CASCADE,
      FOREIGN KEY (id_paket) REFERENCES paket (id) ON DELETE CASCADE ON UPDATE CASCADE,
      FOREIGN KEY (id_transaksi) REFERENCES transaksi (id) ON DELETE SET NULL
    )
  ''';

  static const String _tabelKritikSaranV47 = '''
    CREATE TABLE kritik_saran(
      id TEXT PRIMARY KEY,
      isi TEXT NOT NULL,
      tanggal INTEGER NOT NULL,
      userId TEXT NOT NULL,
      diperbarui INTEGER,
      isDeleted INTEGER NOT NULL DEFAULT 0,
      diarsipkan INTEGER,
      FOREIGN KEY (userId) REFERENCES pelanggan (id) ON DELETE CASCADE
    )
  ''';

  static const String _tabelPesananV47 = '''
    CREATE TABLE pesanan(
      id TEXT PRIMARY KEY,
      id_pelanggan TEXT NOT NULL,
      id_paket TEXT NOT NULL,
      tanggal INTEGER NOT NULL,
      status TEXT,
      diperbarui INTEGER,
      isDeleted INTEGER NOT NULL DEFAULT 0,
      diarsipkan INTEGER,
      FOREIGN KEY (id_pelanggan) REFERENCES pelanggan (id) ON DELETE CASCADE,
      FOREIGN KEY (id_paket) REFERENCES paket (id) ON DELETE CASCADE
    )
  ''';
}
