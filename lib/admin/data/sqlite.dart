// path: lib/admin/data/sqlite.dart
// diubah: Menaikkan versi DB ke 48, menambahkan kolom `diperbarui` ke `status_aplikasi`.
// ditambah: Menambahkan dokumentasi untuk anggota publik untuk memperbaiki peringatan analisis.
// TODO: apakah bisa ke baca
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

  // diubah: Versi dinaikkan ke 48 untuk menambahkan kolom `diperbarui` ke `status_aplikasi`.
  static const int _databaseVersion = 48;

  DatabaseHelper._internal() {
    Log.info('DatabaseHelper instance dibuat (singleton _internal).');
  }

  /// Atur ulang instance database (hanya untuk pengujian).
  void debugSetDatabaseNull() {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      _database = null;
    }
  }

  // --- DEFINISI TABEL (diperbarui di bawah) ---

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
      final Database db, final int oldVersion, final int newVersion) async {
    Log.info('========================================');
    Log.info('MEMULAI PROSES UPGRADE DATABASE (IDEMPOTEN)');
    Log.info('Versi database lama: $oldVersion');
    Log.info('Versi database baru: $newVersion');
    Log.info('========================================');

    final batch = db.batch();

    if (oldVersion < 45) {
      Log.info('[MIGRASI v45] Menjalankan migrasi untuk versi < 45.');
      await _migrateToV45(db);
    }

    if (oldVersion < 47) {
      Log.info(
          '[MIGRASI v47] Memulai migrasi skema untuk memperbaiki tabel `kritik_saran` (destruktif).');
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
          '[MIGRASI v47] Proses ini akan menghapus dan membuat ulang tabel. Data lokal akan direset.');

      for (final namaTabel in daftarTabel) {
        batch.execute('DROP TABLE IF EXISTS $namaTabel');
        Log.info('[MIGRASI v47] Jadwalkan DROP TABLE untuk `$namaTabel`.');
      }

      _createAllTables(batch);
      Log.info(
          '[MIGRASI v47] Menjadwalkan pembuatan ulang semua tabel dengan skema baru.');
    }

    if (oldVersion < 48) {
      Log.info(
          '[MIGRASI v48] Menambahkan kolom `diperbarui` ke tabel `status_aplikasi`.');
      batch
          .execute('ALTER TABLE status_aplikasi ADD COLUMN diperbarui INTEGER');
    }

    try {
      await batch.commit(noResult: true);
      Log.info('========================================');
      Log.info('PROSES UPGRADE DATABASE SELESAI');
      Log.info(
          'Database berhasil diupgrade dari versi $oldVersion ke versi $newVersion.');
      Log.info('========================================');
    } on Exception catch (e, st) {
      Log.error(
        'Gagal melakukan upgrade database dari versi $oldVersion ke versi $newVersion.',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  Future<void> _migrateToV45(final Database db) async {
    Log.info(
      '[MIGRASI v45] Menangani tabel "pengaturan" untuk memastikan PRIMARY KEY.',
    );
    await db.execute('DROP TABLE IF EXISTS pengaturan');
    await db.execute(_tabelPengaturan);
    Log.info('[MIGRASI v45] Tabel `pengaturan` berhasil dibuat ulang.');
  }

  /// Membuat tabel-tabel database.
  Future<void> createTables(final Database db, final int version) async {
    Log.info('========================================');
    Log.info(
        'MEMULAI PEMBUATAN TABEL DATABASE (onCreate) UNTUK VERSI $version');
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

  void _createAllTables(final Batch batch) {
    batch.execute(_tabelKategori);
    batch.execute(_tabelSubKategori);
    batch.execute(_tabelPaket);
    batch.execute(_tabelPelanggan);
    batch.execute(_tabelPelangganAktif);
    batch.execute(tabelTransaksi);
    batch.execute(tabelDompet);
    batch.execute(_tabelKritikSaran);
    batch.execute(_tabelPesanan);
    batch.execute(tabelVersiApkUser);
    batch.execute(_tabelPengaturan);
    batch.execute(_tabelStatusUnggah);
    batch.execute(_tabelStatusAplikasi);
    batch.execute(_tabelPesan);
    Log.info('Semua 14 definisi tabel ditambahkan ke batch.');

    batch.execute(
        'CREATE INDEX IF NOT EXISTS idx_transaksi_dompet ON transaksi(id_dompet)');
    batch.execute(
        'CREATE INDEX IF NOT EXISTS idx_transaksi_dompet_tujuan ON transaksi(id_dompet_tujuan)');
    batch.execute(
        'CREATE INDEX IF NOT EXISTS idx_transaksi_isDeleted ON transaksi(isDeleted)');
    Log.info('Semua 3 definisi index ditambahkan ke batch.');
  }

  /// String SQL untuk membuat tabel versi_apk_user.
  static const String tabelVersiApkUser = '''
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

  /// String SQL untuk membuat tabel dompet.
  static const String tabelDompet = '''
      CREATE TABLE dompet(
        id TEXT PRIMARY KEY,
        namaDompet TEXT NOT NULL,
        saldo REAL NOT NULL,
        diperbarui INTEGER,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        diarsipkan INTEGER
      )
    ''';

  /// String SQL untuk membuat tabel transaksi.
  static const String tabelTransaksi = '''
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

  static const String _tabelStatusUnggah = '''
    CREATE TABLE status_unggah(
      tabel TEXT PRIMARY KEY,
      status INTEGER NOT NULL,
      ids TEXT NOT NULL,
      diperbarui INTEGER
    )
  ''';

  // diubah: Menambahkan kolom `diperbarui`
  static const String _tabelStatusAplikasi = '''
    CREATE TABLE status_aplikasi(
      id TEXT PRIMARY KEY,
      value TEXT NOT NULL,
      diperbarui INTEGER
    )
  ''';

  static const String _tabelPesan = '''
    CREATE TABLE pesan(
      id TEXT PRIMARY KEY,
      isi TEXT NOT NULL,
      tanggal INTEGER NOT NULL,
      status TEXT NOT NULL
    )
  ''';

  static const String _tabelPengaturan = '''
    CREATE TABLE pengaturan(
      id TEXT PRIMARY KEY,
      interval_sinkronisasi_otomatis INTEGER NOT NULL DEFAULT 24,
      hapus_otomatis_data_arsip INTEGER NOT NULL DEFAULT 30,
      diperbarui INTEGER,
      mode_pemeliharaan INTEGER NOT NULL DEFAULT 0,
      info_pemeliharaan TEXT
    )
  ''';

  static const String _tabelKategori = '''
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

  static const String _tabelSubKategori = '''
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

  static const String _tabelPaket = '''
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

  static const String _tabelPelanggan = '''
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

  static const String _tabelPelangganAktif = '''
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

  static const String _tabelKritikSaran = '''
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

  static const String _tabelPesanan = '''
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
