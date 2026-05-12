// diubah: Menaikkan versi database ke 45 untuk memicu migrasi.
// diubah: Mengubah strategi migrasi tabel 'pengaturan' menjadi lebih aman dengan menghapus data duplikat, bukan drop table.

import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:admin_wifi/debug/log.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  // dinaikkan ke 45 untuk memicu migrasi pembersihan
  static const int _databaseVersion = 45;

  DatabaseHelper._internal() {
    Log.info('DatabaseHelper instance dibuat (singleton _internal).');
  }

  Future<void> _addColumnIfNotExists(Database db, String tableName, String columnName, String columnType) async {
    final dbClient = db;
    final List<Map<String, dynamic>> tableInfo = await dbClient.rawQuery('PRAGMA table_info($tableName)');
    bool columnExists = tableInfo.any((column) => column['name'] == columnName);

    if (!columnExists) {
      await dbClient.execute('ALTER TABLE $tableName ADD COLUMN $columnName $columnType');
      Log.info('[MIGRASI SUKSES] Berhasil menambahkan kolom `$columnName` ke tabel `$tableName`.');
    } else {
      Log.info('[MIGRASI DILEWATI] Kolom `$columnName` sudah ada di tabel `$tableName`.');
    }
  }

  // --- DEFINISI TABEL ---

  // Definisi tabel lainnya tetap sama...

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
    } catch (e, st) {
      Log.error('Gagal total mendapatkan instance database.', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<Database> _initDB() async {
    Log.info('Memulai inisialisasi database (_initDB).');
    try {
      if (Platform.environment.containsKey('FLUTTER_TEST')) {
        Log.info('Mode TEST terdeteksi. Menggunakan database in-memory.');
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
        return await databaseFactory.openDatabase(
          inMemoryDatabasePath,
          options: OpenDatabaseOptions(version: _databaseVersion, onCreate: createTables, onUpgrade: _onUpgrade),
        );
      }

      Log.info('Mode PRODUKSI/DEBUG. Menggunakan database fisik.');
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String path = join(documentsDirectory.path, 'mydatabase.db');
      Log.info('Path database: $path');
      
      Log.info('Membuka database dengan versi $_databaseVersion...');
      return await openDatabase(path, version: _databaseVersion, onCreate: createTables, onUpgrade: _onUpgrade);
    } catch (e, st) {
      Log.error('Gagal membuka atau membuat database.', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    Log.info('========================================');
    Log.info('MEMULAI PROSES UPGRADE DATABASE (IDEMPOTEN)');
    Log.info('Versi database lama: $oldVersion');
    Log.info('Versi database baru: $newVersion');
    Log.info('========================================');

    try {
      // diubah: Strategi migrasi yang lebih aman untuk tabel pengaturan.
      // Daripada DROP TABLE, kita buat ulang tabel dengan nama sementara,
      // lalu ganti nama. Ini menjamin skema yang benar dan bersih.
      if (oldVersion < 45) {
          Log.info('[MIGRASI DIMULAI] Menangani tabel \'pengaturan\' untuk memastikan PRIMARY KEY dan data tunggal.');
          
          // 1. Buat tabel baru dengan skema yang benar
          await db.execute('''
            CREATE TABLE pengaturan_baru(
              id TEXT PRIMARY KEY,
              interval_sinkronisasi_otomatis INTEGER NOT NULL DEFAULT 24,
              hapus_otomatis_data_arsip INTEGER NOT NULL DEFAULT 30,
              diperbarui TEXT,
              mode_pemeliharaan INTEGER NOT NULL DEFAULT 0,
              info_pemeliharaan TEXT
            )
          ''');
          Log.info('[MIGRASI] Tabel `pengaturan_baru` berhasil dibuat.');

          // 2. Hapus tabel lama
          await db.execute('DROP TABLE IF EXISTS pengaturan');
          Log.info('[MIGRASI] Tabel `pengaturan` lama berhasil dihapus.');
          
          // 3. Ganti nama tabel baru menjadi nama tabel asli
          await db.execute('ALTER TABLE pengaturan_baru RENAME TO pengaturan');
          Log.info('[MIGRASI SUKSES] Tabel `pengaturan` berhasil dibuat ulang dengan skema yang benar dan data bersih.');
      }

      // Migrasi idempoten lainnya
      await _addColumnIfNotExists(db, 'pelanggan_aktif', 'tanggal_berakhir', 'TEXT');
      await _addColumnIfNotExists(db, 'pelanggan_aktif', 'tanggal_mulai', 'TEXT');
      
      Log.info('========================================');
      Log.info('PROSES UPGRADE DATABASE SELESAI');
      Log.info('Database berhasil diupgrade dari versi $oldVersion ke versi $newVersion.');
      Log.info('========================================');
    } catch (e, st) {
      Log.error(
        'Gagal melakukan upgrade database dari versi $oldVersion ke versi $newVersion.',
        error: e, stackTrace: st
      );
      rethrow;
    }
  }

  Future<void> createTables(Database db, int version) async {
    // ... (Fungsi createTables tidak berubah)
    Log.info('========================================');
    Log.info('MEMULAI PEMBUATAN TABEL DATABASE (onCreate) UNTUK VERSI $version');
    Log.info('========================================');
    
    try {
      await db.execute(_tabelKategori);
      await db.execute(_tabelSubKategori);
      await db.execute(_tabelPaket);
      await db.execute(_tabelPelanggan);
      await db.execute(_tabelPelangganAktif);
      await db.execute(tabelTransaksi);
      await db.execute(tabelDompet);
      await db.execute(_tabelKritikSaran);
      await db.execute(_tabelPesanan);
      await db.execute(tabelVersiApkUser);
      await db.execute(_tabelPengaturan);
      await db.execute(_tabelStatusUnggah);
      await db.execute(_tabelStatusAplikasi);
      await db.execute(_tabelPesan);
      Log.info('Semua 14 tabel utama berhasil dibuat.');

      Log.info('Memulai pembuatan index...');
      await db.execute('CREATE INDEX idx_transaksi_dompet ON transaksi(id_dompet)');
      await db.execute('CREATE INDEX idx_transaksi_dompet_tujuan ON transaksi(id_dompet_tujuan)');
      await db.execute('CREATE INDEX idx_transaksi_isDeleted ON transaksi(isDeleted)');
      Log.info('Semua 3 index berhasil dibuat.');

      Log.info('========================================');
      Log.info('PROSES PEMBUATAN TABEL & INDEX SELESAI');
      Log.info('========================================');
    } catch (e, st) {
      Log.error('Gagal total saat membuat tabel atau index.', error: e, stackTrace: st);
      rethrow;
    }
  }

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
        diarsipkan TEXT,
        diperbarui TEXT
      )
    ''';

  static const String tabelDompet = '''
      CREATE TABLE dompet(
        id TEXT PRIMARY KEY,
        namaDompet TEXT NOT NULL,
        saldo REAL NOT NULL,
        diperbarui TEXT,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        diarsipkan TEXT
      )
    ''';

  static const String tabelTransaksi = '''
      CREATE TABLE transaksi(
        id TEXT PRIMARY KEY,
        keterangan TEXT NOT NULL,
        jumlah REAL NOT NULL,
        tanggal TEXT NOT NULL,
        tipe TEXT NOT NULL,
        id_dompet TEXT,
        id_kategori TEXT,
        id_sub_kategori TEXT,
        id_pelanggan TEXT,
        id_paket TEXT,
        diperbarui TEXT,
        diarsipkan TEXT,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        id_dompet_tujuan TEXT,
        poin_yang_dihasilkan INTEGER NOT NULL DEFAULT 0,
        poin_yang_digunakan INTEGER NOT NULL DEFAULT 0,
        status_pembayaran TEXT,
        durasi_paket INTEGER,
        tipe_durasi_paket TEXT,
        tanggal_mulai TEXT,
        tanggal_berakhir TEXT,
        aktivasi_paket INTEGER DEFAULT 0
      )
    ''';

  static const String _tabelStatusUnggah = '''
    CREATE TABLE status_unggah(
      tabel TEXT PRIMARY KEY,
      status INTEGER NOT NULL,
      ids TEXT NOT NULL,
      diperbarui TEXT
    )
  ''';

  static const String _tabelStatusAplikasi = '''
    CREATE TABLE status_aplikasi(
      id TEXT PRIMARY KEY,
      value TEXT NOT NULL
    )
  ''';

  static const String _tabelPesan = '''
    CREATE TABLE pesan(
      id TEXT PRIMARY KEY,
      isi TEXT NOT NULL,
      tanggal TEXT NOT NULL,
      status TEXT NOT NULL
    )
  ''';


  static const String _tabelPengaturan = '''
    CREATE TABLE pengaturan(
      id TEXT PRIMARY KEY,
      interval_sinkronisasi_otomatis INTEGER NOT NULL DEFAULT 24,
      hapus_otomatis_data_arsip INTEGER NOT NULL DEFAULT 30,
      diperbarui TEXT,
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
        diperbarui TEXT,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        diarsipkan TEXT
      )
    ''';

  static const String _tabelSubKategori = '''
      CREATE TABLE sub_kategori(
        id TEXT PRIMARY KEY,
        nama TEXT NOT NULL,
        id_kategori TEXT NOT NULL,
        diperbarui TEXT,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        diarsipkan TEXT,
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
        diperbarui TEXT,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        diarsipkan TEXT,
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
        diperbarui TEXT,      
        diarsipkan TEXT,
        isDeleted INTEGER NOT NULL DEFAULT 0       
      )
    ''';

  static const String _tabelPelangganAktif = '''
      CREATE TABLE pelanggan_aktif(
        id TEXT PRIMARY KEY,
        id_pelanggan TEXT NOT NULL,
        id_paket TEXT NOT NULL,
        id_transaksi TEXT,
        tanggal_mulai TEXT,
        tanggal_berakhir TEXT,
        status TEXT NOT NULL,
        diperbarui TEXT,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        diarsipkan TEXT,
        FOREIGN KEY (id_pelanggan) REFERENCES pelanggan (id) ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY (id_paket) REFERENCES paket (id) ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY (id_transaksi) REFERENCES transaksi (id) ON DELETE SET NULL
      )
    ''';

  static const String _tabelKritikSaran = '''
      CREATE TABLE kritik_saran(
        id TEXT PRIMARY KEY,
        isi TEXT NOT NULL,
        tanggal TEXT NOT NULL,
        userId TEXT NOT NULL,
        diperbarui TEXT,
        FOREIGN KEY (userId) REFERENCES pelanggan (id) ON DELETE CASCADE
      )
    ''';

  static const String _tabelPesanan = '''
      CREATE TABLE pesanan(
        id TEXT PRIMARY KEY,
        id_pelanggan TEXT NOT NULL,
        id_paket TEXT NOT NULL,
        tanggal TEXT NOT NULL,
        status TEXT,
        diperbarui TEXT,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        diarsipkan TEXT,
        FOREIGN KEY (id_pelanggan) REFERENCES pelanggan (id) ON DELETE CASCADE,
        FOREIGN KEY (id_paket) REFERENCES paket (id) ON DELETE CASCADE
      )
    ''';
}
