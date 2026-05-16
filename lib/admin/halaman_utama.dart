// path: lib/admin/halaman_utama.dart
// diubah: Mengganti IndexedStack dengan widget langsung untuk mengatasi konflik Hero.

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:wifi/admin/halaman/tab/wallet_page.dart';
import 'package:wifi/admin/halaman/tab/lainnya.dart';
import 'package:wifi/admin/halaman/tab/pelanggan_aktif.dart';
import 'package:wifi/admin/halaman/tab/transaction_page.dart';
import 'package:wifi/shared/data/services/sync_check_service.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/services/expired_subscription_check_service.dart';
// === ANALISIS FILE DAN RELASI MENDALAM (TRACE BERANTAI) ===
//
// Saya ingin kamu menganalisis file berikut secara MENDALAM dan MENYELURUH:
//
// --- FILE UTAMA ---
// Nama file: halaman_utama.dart
// Path: ~/myapp/lib/admin/halaman_utama.dart
//
// Isi file:
// ```dart
// [{
	"resource": "/home/user/myapp/lib/admin/halaman_utama.dart",
	"owner": "_generated_diagnostic_collection_name_#2",
	"code": {
		"value": "uri_does_not_exist",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/uri_does_not_exist",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "Target of URI doesn't exist: 'package:wifi/admin/halaman/tab/pelanggan_aktif.dart'.\nTry creating the file referenced by the URI, or try using a URI for a file that does exist.",
	"source": "dart",
	"startLineNumber": 10,
	"startColumn": 8,
	"endLineNumber": 10,
	"endColumn": 61
},{
	"resource": "/home/user/myapp/lib/admin/halaman_utama.dart",
	"owner": "_generated_diagnostic_collection_name_#2",
	"code": {
		"value": "undefined_class",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/undefined_class",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "Undefined class 'PengecekanWaktuSyncService'.\nTry changing the name to the name of an existing class, or creating a class with the name 'PengecekanWaktuSyncService'.",
	"source": "dart",
	"startLineNumber": 34,
	"startColumn": 9,
	"endLineNumber": 34,
	"endColumn": 35
},{
	"resource": "/home/user/myapp/lib/admin/halaman_utama.dart",
	"owner": "_generated_diagnostic_collection_name_#2",
	"code": {
		"value": "undefined_method",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/undefined_method",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "The method 'PengecekanWaktuSyncService' isn't defined for the type '_HalamanUtamaState'.\nTry correcting the name to the name of an existing method, or defining a method named 'PengecekanWaktuSyncService'.",
	"source": "dart",
	"startLineNumber": 34,
	"startColumn": 51,
	"endLineNumber": 34,
	"endColumn": 77
},{
	"resource": "/home/user/myapp/lib/admin/halaman_utama.dart",
	"owner": "_generated_diagnostic_collection_name_#2",
	"code": {
		"value": "creation_with_non_type",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/creation_with_non_type",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "The name 'PelangganAktifPage' isn't a class.\nTry correcting the name to match an existing class.",
	"source": "dart",
	"startLineNumber": 40,
	"startColumn": 11,
	"endLineNumber": 40,
	"endColumn": 29
},{
	"resource": "/home/user/myapp/lib/admin/halaman_utama.dart",
	"owner": "_generated_diagnostic_collection_name_#2",
	"code": {
		"value": "creation_with_non_type",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/creation_with_non_type",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "The name 'DompetPage' isn't a class.\nTry correcting the name to match an existing class.",
	"source": "dart",
	"startLineNumber": 41,
	"startColumn": 11,
	"endLineNumber": 41,
	"endColumn": 21
},{
	"resource": "/home/user/myapp/lib/admin/halaman_utama.dart",
	"owner": "_generated_diagnostic_collection_name_#2",
	"code": {
		"value": "creation_with_non_type",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/creation_with_non_type",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "The name 'TransaksiPage' isn't a class.\nTry correcting the name to match an existing class.",
	"source": "dart",
	"startLineNumber": 42,
	"startColumn": 11,
	"endLineNumber": 42,
	"endColumn": 24
},{
	"resource": "/home/user/myapp/lib/admin/halaman_utama.dart",
	"owner": "_generated_diagnostic_collection_name_#2",
	"code": {
		"value": "undefined_method",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/undefined_method",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "The method 'CekLanggananKadaluarsaService' isn't defined for the type '_HalamanUtamaState'.\nTry correcting the name to the name of an existing method, or defining a method named 'CekLanggananKadaluarsaService'.",
	"source": "dart",
	"startLineNumber": 80,
	"startColumn": 13,
	"endLineNumber": 80,
	"endColumn": 42
},{
	"resource": "/home/user/myapp/lib/admin/halaman_utama.dart",
	"owner": "_generated_diagnostic_collection_name_#2",
	"code": {
		"value": "directives_ordering",
		"target": {
			"$mid": 1,
			"path": "/lints/directives_ordering",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 4,
	"message": "Sort directive sections alphabetically.\nTry sorting the directives.",
	"source": "dart",
	"startLineNumber": 9,
	"startColumn": 1,
	"endLineNumber": 9,
	"endColumn": 54
}]
// ```
//
// --- ATURAN PENTING (WAJIB DIPATUHI) ---
//
// ATURAN TRACE BERANTAI:
// - Jika file ini import/reference/memanggil file B, kamu WAJIB menanyakan isi file B
// - Jika file B ternyata juga import/reference/memanggil file C, kamu WAJIB menanyakan isi file C
// - Jika file C import file D, tanyakan file D, begitu seterusnya sampai AKAR
// - Jangan berhenti sebelum SEMUA rantai dependency terlacak
// - Jangan berspekulasi atau menebak isi file lain, WAJIB minta isinya padaku
// - Kalau kamu butuh isi file terkait, TANYAKAN dengan format: 'Tolong paste isi file [nama_file]'
//
// ATURAN DUA ARAH:
// - Selain file yang di-import, kamu juga WAJIB menanyakan file yang meng-import file utama ini
// - Trace dua arah: ke atas (parent/caller) dan ke bawah (child/dependency)
//
// --- TUGAS KAMU ---
//
// 1. IDENTIFIKASI SEMUA IMPORT & DEPENDENCY
//    - Sebutkan SATU PER SATU import yang ada di file ini
//    - Untuk SETIAP import, sebutkan nama file dan path-nya
//    - Jelaskan kegunaan masing-masing import
//
// 2. TRACE BERANTAI KE BAWAH (FILE YANG DI-IMPORT)
//    - Untuk SETIAP file yang di-import, WAJIB minta isinya padaku
//    - Format: 'Tolong paste isi file [nama_file] di path [path_file]'
//    - Kalau di file import itu ada import lagi, ulangi terus sampai ke akar
//    - Tampilkan dependency chain lengkap: File A → File B → File C → ... → File Akar
//
// 3. TRACE BERANTAI KE ATAS (FILE YANG MENG-IMPORT FILE INI)
//    - WAJIB tanyakan file-file yang meng-import file utama ini
//    - Format: 'Apakah ada file lain yang meng-import halaman_utama.dart? Tolong paste isinya'
//    - Kalau ada, trace terus ke atas: File X → File Y → ... → File Utama
//
// 4. ANALISIS MASALAH DI SETIAP LEVEL RANTAI
//    - Di setiap file dalam rantai, analisis potensi error
//    - Cek apakah error di file utama disebabkan oleh file import
//    - Cek sampai ke akar penyebab, jangan cuma di permukaan
//    - Siapa yang pertama kali menyebabkan masalah di rantai ini?
//
// 5. DAMPAK PERUBAHAN SEPANJANG RANTAI
//    - Kalau file utama diubah, trace dampaknya ke SEMUA file di rantai
//    - Kalau file akar diubah, trace dampaknya ke file utama
//    - Di setiap level, sebutkan apa yang akan error/terpengaruh
//
// 6. VISUALISASI RANTAI DEPENDENCY
//    - Gambarkan diagram rantai lengkap: File A → File B → File C → File D
//    - Tandai file mana yang bermasalah
//    - Tandai arah aliran data/dependency
//
// 7. KONTEKS PROJECT
//    - Di folder mana file ini berada?
//    - Apa peran file ini dalam arsitektur project?
//    - File apa saja yang satu folder/feature?
//
// 8. POTENSI MASALAH DI SELURUH RANTAI
//    - Circular dependency?
//    - Import tidak digunakan?
//    - Best practice dilanggar?
//    - Potensi bug dari relasi?
//
// 9. REKOMENDASI PERBAIKAN
//    - Perbaikan untuk file utama
//    - Perbaikan untuk file-file di rantai (kalau perlu)
//    - Saran restruktur dependency kalau diperlukan
//
// --- FORMAT JAWABAN ---
// 1. Mulai dengan identifikasi import file utama
// 2. TANYAKAN padaku SATU PER SATU file yang dibutuhkan
// 3. Tunggu aku berikan isinya, baru lanjut analisis
// 4. JANGAN LANGSUNG menyimpulkan sebelum SEMUA file di rantai diperiksa
// 5. Tampilkan dependency chain lengkap di akhir
// Setelah melakukan perbaikan list semua file yang telah diperbaiki dari awal kita mualai hingga saat ini
// Setelah melakukan pekerjaan beritahukan ke saya sisa tokok AI yang belum terpakai agar proses kita tidak terpotong
// ubah nama class, file variabel, parameter ke dalam bahasa inggris untuk menjaga konsistensi projek tapi untuk komentar wajib indonesia
// tambahkan inofrmasi didalam file file ini digunakan oleh file apa saja dan bungkus dengan komentar
/// Halaman utama aplikasi admin yang menampilkan navigasi tab.
class HalamanUtama extends StatefulWidget {
  /// Menandakan apakah aplikasi sedang berjalan dalam mode offline.
  ///
  /// Default-nya adalah `false` (mode online).
  final bool isOffline;

  /// Membuat instance [HalamanUtama].
  ///
  /// Parameter [isOffline] menentukan status koneksi awal halaman.
  const HalamanUtama({super.key, this.isOffline = false});

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  late StreamSubscription<List<ConnectivityResult>> _koneksiSubscription;
  final PengecekanWaktuSyncService _syncService = PengecekanWaktuSyncService();
  bool _sedangSinkronisasi = false;

  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    const PelangganAktifPage(),
    const DompetPage(),
    const TransaksiPage(),
    const LainnyaPage(),
  ];

  void _onItemTapped(final int index) {
    Log.info(
      'Pengguna menekan bottom navigation index: $index.',
    );

    if (_selectedIndex == index) {
      Log.info(
        'Index yang ditekan sama dengan halaman aktif saat ini. Tidak ada perubahan state.',
      );
      return;
    }

    setState(() {
      Log.info(
        'Mengubah selected index dari $_selectedIndex menjadi $index.',
      );
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    Log.info(
      'Memulai inisialisasi halaman utama. Status offline: ${widget.isOffline}.',
    );
    WidgetsBinding.instance.addPostFrameCallback((final _) async {
      Log.info(
        'Frame pertama selesai dirender.',
      );
      _cekDanTampilkanPesanOffline();
      Log.info(
        'Menjalankan proses pengecekan langganan kadaluarsa.',
      );
      await CekLanggananKadaluarsaService().prosesLanggananKadaluarsa();
      await _sinkronisasiDataSaatOnline();
    });
    _koneksiSubscription =
        Connectivity().onConnectivityChanged.listen(_onKoneksiBerubah);
  }

  @override
  Future<void> dispose() async {
    Log.info('Menutup HalamanUtama, membersihkan semua listener.');
    await _koneksiSubscription.cancel();
    super.dispose();
  }

  Future<void> _onKoneksiBerubah(final List<ConnectivityResult> hasil) async {
    final terkoneksi = hasil.contains(ConnectivityResult.mobile) ||
        hasil.contains(ConnectivityResult.wifi);
    if (terkoneksi) {
      Log.info(
        'Terdeteksi perubahan koneksi: KEMBALI ONLINE. Memicu sinkronisasi.',
      );
      await _sinkronisasiDataSaatOnline();
    } else {
      Log.warning('Terdeteksi perubahan koneksi: OFFLINE.');
    }
  }

  Future<void> _sinkronisasiDataSaatOnline() async {
    if (_sedangSinkronisasi) return;

    if (mounted) setState(() => _sedangSinkronisasi = true);
    try {
      await _syncService.jalankanPengecekanDanSinkronisasi();
    } finally {
      if (mounted) setState(() => _sedangSinkronisasi = false);
    }
  }

  void _cekDanTampilkanPesanOffline() {
    Log.info(
      'Memeriksa status koneksi aplikasi.',
    );
    if (widget.isOffline) {
      Log.warning(
        'Aplikasi berjalan dalam mode offline. Menampilkan snackbar peringatan.',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda dalam mode offline. Data mungkin tidak terbaru.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 5),
        ),
      );
      Log.info(
        'Snackbar offline berhasil ditampilkan.',
      );
    } else {
      Log.info(
        'Aplikasi berjalan dalam mode online.',
      );
    }
  }

  @override
  Widget build(final BuildContext context) {
    Log.info(
      'Membangun UI halaman utama dengan selected index: $_selectedIndex.',
    );
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person_pin_circle),
            label: 'Aktif',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Dompet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Transaksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apps),
            label: 'Lainnya',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(
          context,
        ).colorScheme.onSurface.withAlpha(179),
        onTap: _onItemTapped,
        showUnselectedLabels: true,
      ),
    );
  }
}
