// path: lib/admin/halaman/tab/pesanan.dart
// diubah: Menambahkan dokumentasi untuk mengatasi error public_member_api_docs.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/pesanan_model.dart';
import 'package:wifi/shared/operasi/order_operation.dart';

/// Halaman untuk menampilkan dan mengelola daftar pesanan.
class HalamanPesan extends StatefulWidget {
  /// Konstruktor untuk HalamanPesan.
  const HalamanPesan({super.key});

  @override
  State<HalamanPesan> createState() => _HalamanPesanState();
}
// === ANALISIS FILE DAN RELASI MENDALAM (TRACE BERANTAI) ===
//
// Saya ingin kamu menganalisis file berikut secara MENDALAM dan MENYELURUH:
//
// --- FILE UTAMA ---
// Nama file: pesanan.dart
// Path: ~/myapp/lib/admin/halaman/tab/pesanan.dart
//
// Isi file:
// ```dart
// [{
	"resource": "/home/user/myapp/lib/admin/halaman/tab/pesanan.dart",
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
	"message": "Target of URI doesn't exist: 'package:wifi/shared/model/pesanan_model.dart'.\nTry creating the file referenced by the URI, or try using a URI for a file that does exist.",
	"source": "dart",
	"startLineNumber": 9,
	"startColumn": 8,
	"endLineNumber": 9,
	"endColumn": 54
},{
	"resource": "/home/user/myapp/lib/admin/halaman/tab/pesanan.dart",
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
	"message": "Undefined class 'PesananOperasi'.\nTry changing the name to the name of an existing class, or creating a class with the name 'PesananOperasi'.",
	"source": "dart",
	"startLineNumber": 22,
	"startColumn": 9,
	"endLineNumber": 22,
	"endColumn": 23
},{
	"resource": "/home/user/myapp/lib/admin/halaman/tab/pesanan.dart",
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
	"message": "The method 'PesananOperasi' isn't defined for the type '_HalamanPesanState'.\nTry correcting the name to the name of an existing method, or defining a method named 'PesananOperasi'.",
	"source": "dart",
	"startLineNumber": 22,
	"startColumn": 40,
	"endLineNumber": 22,
	"endColumn": 54
},{
	"resource": "/home/user/myapp/lib/admin/halaman/tab/pesanan.dart",
	"owner": "_generated_diagnostic_collection_name_#2",
	"code": {
		"value": "non_type_as_type_argument",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/non_type_as_type_argument",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "The name 'PesananModel' isn't a type, so it can't be used as a type argument.\nTry correcting the name to an existing type, or defining a type named 'PesananModel'.",
	"source": "dart",
	"startLineNumber": 24,
	"startColumn": 8,
	"endLineNumber": 24,
	"endColumn": 20
},{
	"resource": "/home/user/myapp/lib/admin/halaman/tab/pesanan.dart",
	"owner": "_generated_diagnostic_collection_name_#2",
	"code": {
		"value": "non_type_as_type_argument",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/non_type_as_type_argument",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "The name 'PesananModel' isn't a type, so it can't be used as a type argument.\nTry correcting the name to an existing type, or defining a type named 'PesananModel'.",
	"source": "dart",
	"startLineNumber": 63,
	"startColumn": 12,
	"endLineNumber": 63,
	"endColumn": 24
},{
	"resource": "/home/user/myapp/lib/admin/halaman/tab/pesanan.dart",
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
	"message": "Undefined class 'PesananModel'.\nTry changing the name to the name of an existing class, or creating a class with the name 'PesananModel'.",
	"source": "dart",
	"startLineNumber": 107,
	"startColumn": 13,
	"endLineNumber": 107,
	"endColumn": 25
},{
	"resource": "/home/user/myapp/lib/admin/halaman/tab/pesanan.dart",
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
	"message": "Undefined class 'PesananModel'.\nTry changing the name to the name of an existing class, or creating a class with the name 'PesananModel'.",
	"source": "dart",
	"startLineNumber": 170,
	"startColumn": 36,
	"endLineNumber": 170,
	"endColumn": 48
},{
	"resource": "/home/user/myapp/lib/admin/halaman/tab/pesanan.dart",
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
	"message": "Undefined class 'PesananModel'.\nTry changing the name to the name of an existing class, or creating a class with the name 'PesananModel'.",
	"source": "dart",
	"startLineNumber": 433,
	"startColumn": 34,
	"endLineNumber": 433,
	"endColumn": 46
},{
	"resource": "/home/user/myapp/lib/admin/halaman/tab/pesanan.dart",
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
	"message": "Undefined class 'PesananModel'.\nTry changing the name to the name of an existing class, or creating a class with the name 'PesananModel'.",
	"source": "dart",
	"startLineNumber": 600,
	"startColumn": 31,
	"endLineNumber": 600,
	"endColumn": 43
},{
	"resource": "/home/user/myapp/lib/admin/halaman/tab/pesanan.dart",
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
	"message": "Undefined class 'PesananModel'.\nTry changing the name to the name of an existing class, or creating a class with the name 'PesananModel'.",
	"source": "dart",
	"startLineNumber": 618,
	"startColumn": 31,
	"endLineNumber": 618,
	"endColumn": 43
},{
	"resource": "/home/user/myapp/lib/admin/halaman/tab/pesanan.dart",
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
	"message": "Undefined class 'PesananModel'.\nTry changing the name to the name of an existing class, or creating a class with the name 'PesananModel'.",
	"source": "dart",
	"startLineNumber": 623,
	"startColumn": 41,
	"endLineNumber": 623,
	"endColumn": 53
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
//    - Format: 'Apakah ada file lain yang meng-import pesanan.dart? Tolong paste isinya'
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
class _HalamanPesanState extends State<HalamanPesan> {
  final PesananOperasi _pesanOperasi = PesananOperasi();

  List<PesananModel> _daftarPesanan = [];
  bool _isLoading = true;
  String _filterStatus = 'semua';

  @override
  void initState() {
    super.initState();
    Log.info('========================================');
    Log.info('LIFECYCLE: initState() - Halaman HalamanPesan');
    Log.info('Menginisialisasi halaman daftar pesanan.');
    Log.info('Filter default: "semua" (menampilkan seluruh pesanan).');
    Log.info('========================================');
    Log.info(
      'Memanggil _muatPesanan() untuk memuat data pesanan dari database.',
    );
    unawaited(_muatPesanan());
  }

  @override
  void dispose() {
    Log.info('========================================');
    Log.info('LIFECYCLE: dispose() - Halaman HalamanPesan');
    Log.info('Membersihkan resource halaman daftar pesanan.');
    Log.info('========================================');
    super.dispose();
  }

  Future<void> _muatPesanan() async {
    Log.info('========================================');
    Log.info('MEMUAT DATA PESANAN');
    Log.info('Filter status: "$_filterStatus"');
    Log.info('========================================');

    Log.info(
      'Mengatur state _isLoading menjadi true untuk menampilkan indikator loading.',
    );
    setState(() => _isLoading = true);

    try {
      List<PesananModel> pesanan;
      if (_filterStatus == 'semua') {
        Log.info(
          'Mengambil SEMUA pesanan dari database (tanpa filter status).',
        );
        pesanan = await _pesanOperasi.ambilSemuaPesanan();
        Log.info(
          'Berhasil mengambil semua pesanan. Jumlah: ${pesanan.length} pesanan.',
        );
      } else {
        Log.info('Mengambil pesanan dengan filter status: "$_filterStatus".');
        pesanan = await _pesanOperasi.ambilPesananByStatus(_filterStatus);
        Log.info(
          'Berhasil mengambil pesanan dengan status "$_filterStatus". Jumlah: ${pesanan.length} pesanan.',
        );
      }

      Log.info('Memperbarui state dengan data pesanan yang telah diambil.');
      Log.info('  - _daftarPesanan: ${pesanan.length} item');
      Log.info('  - _isLoading: false');

      setState(() {
        _daftarPesanan = pesanan;
        _isLoading = false;
      });

      Log.info(
        'State berhasil diperbarui. UI akan menampilkan ${pesanan.length} pesanan.',
      );
    } on Exception catch (e, s) {
      Log.error(
        'Gagal memuat data pesanan dari database. '
        'Filter yang digunakan: "$_filterStatus". '
        'Kemungkinan penyebab: koneksi database gagal, tabel pesanan tidak ditemukan, '
        'atau terjadi error saat query data.',
        e: e,
        st: s,
      );
      Log.info('Mengatur _isLoading menjadi false meskipun terjadi error.');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(
      final PesananModel pesanan, final String statusBaru) async {
    Log.info('========================================');
    Log.info('MENGUBAH STATUS PESANAN');
    Log.info('ID Pesanan: ${pesanan.id}');
    Log.info('ID Pelanggan: ${pesanan.idPelanggan}');
    Log.info('ID Paket: ${pesanan.idPaket}');
    Log.info('Status Lama: "${pesanan.status}"');
    Log.info('Status Baru: "$statusBaru"');
    Log.info('========================================');

    try {
      Log.info(
        'Memanggil _pesanOperasi.updateStatusPesanan() untuk mengubah status di database.',
      );
      await _pesanOperasi.updateStatusPesanan(pesanan.id, statusBaru);
      Log.info(
        'Status pesanan berhasil diubah di database dari "${pesanan.status}" menjadi "$statusBaru".',
      );

      Log.info(
        'Memanggil _muatPesanan() untuk memperbarui tampilan daftar pesanan.',
      );
      await _muatPesanan();
      Log.info('Daftar pesanan berhasil dimuat ulang.');

      if (mounted) {
        Log.info('Widget masih mounted. Menampilkan SnackBar sukses.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Status pesanan #${pesanan.id} diubah menjadi "$statusBaru"',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        Log.info('SnackBar sukses telah ditampilkan.');
      } else {
        Log.warning(
          'Widget sudah tidak mounted. Tidak dapat menampilkan SnackBar.',
        );
      }
    } on Exception catch (e, s) {
      Log.error(
        'Gagal mengubah status pesanan #${pesanan.id} dari "${pesanan.status}" menjadi "$statusBaru". '
        'Kemungkinan penyebab: koneksi database gagal, data pesanan tidak ditemukan, '
        'atau nilai status baru tidak valid.',
        e: e,
        st: s,
      );
      if (mounted) {
        Log.info('Menampilkan SnackBar error ke pengguna.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengubah status: $e'),
            backgroundColor: Colors.red,
          ),
        );
        Log.info('SnackBar error telah ditampilkan.');
      }
    }
  }

  Future<void> _hapusPesanan(final PesananModel pesanan) async {
    Log.info('========================================');
    Log.info('KONFIRMASI HAPUS PESANAN');
    Log.info('ID Pesanan: ${pesanan.id}');
    Log.info('ID Pelanggan: ${pesanan.idPelanggan}');
    Log.info('ID Paket: ${pesanan.idPaket}');
    Log.info('Status: "${pesanan.status}"');
    Log.info('Menampilkan dialog konfirmasi kepada pengguna.');
    Log.info('========================================');

    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (final context) => AlertDialog(
        title: const Text('Hapus Pesanan'),
        content: Text('Yakin hapus pesanan dari ${pesanan.idPelanggan}?'),
        actions: [
          TextButton(
            onPressed: () {
              Log.info('Dialog Hapus: Pengguna memilih BATAL.');
              Navigator.pop(context, false);
            },
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Log.info('Dialog Hapus: Pengguna memilih HAPUS.');
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    Log.info(
      'Hasil konfirmasi: ${konfirmasi ?? false ? "DISETUJUI (true)" : "DIBATALKAN (${konfirmasi ?? "null"})"}',
    );

    if (konfirmasi ?? false) {
      Log.info(
        'Pengguna mengkonfirmasi penghapusan. Memproses hapus pesanan...',
      );
      try {
        Log.info(
          'Memanggil _pesanOperasi.hapusPesanan() untuk menghapus pesanan #${pesanan.id} dari database.',
        );
        await _pesanOperasi.hapusPesanan(pesanan.id);
        Log.info('Pesanan #${pesanan.id} berhasil dihapus dari database.');

        Log.info(
          'Memanggil _muatPesanan() untuk memperbarui tampilan daftar pesanan.',
        );
        await _muatPesanan();
        Log.info('Daftar pesanan berhasil dimuat ulang.');

        if (mounted) {
          Log.info('Widget masih mounted. Menampilkan SnackBar sukses hapus.');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pesanan berhasil dihapus'),
              backgroundColor: Colors.red,
            ),
          );
          Log.info('SnackBar sukses hapus telah ditampilkan.');
        } else {
          Log.warning(
            'Widget sudah tidak mounted. Tidak dapat menampilkan SnackBar.',
          );
        }
      } on Exception catch (e, s) {
        Log.error(
          'Gagal menghapus pesanan #${pesanan.id}. '
          'Kemungkinan penyebab: koneksi database gagal, data pesanan tidak ditemukan, '
          'atau terjadi constraint violation.',
          e: e,
          st: s,
        );
        if (mounted) {
          Log.info('Menampilkan SnackBar error ke pengguna.');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus pesanan: $e'),
              backgroundColor: Colors.red,
            ),
          );
          Log.info('SnackBar error telah ditampilkan.');
        }
      }
    } else {
      Log.info(
        'Penghapusan dibatalkan oleh pengguna. Tidak ada perubahan data.',
      );
    }
  }

  @override
  Widget build(final BuildContext context) {
    Log.info('========================================');
    Log.info('LIFECYCLE: build() - Membangun UI HalamanPesan');
    Log.info('Status loading: $_isLoading');
    Log.info('Filter aktif: "$_filterStatus"');
    Log.info('Jumlah pesanan ditampilkan: ${_daftarPesanan.length}');
    Log.info('========================================');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pesanan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Log.info(
                'AKSI: Tombol Refresh ditekan. Memuat ulang data pesanan.',
              );
              unawaited(_muatPesanan());
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          _buildSummaryCards(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _daftarPesanan.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox, size: 80, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'Belum ada pesanan',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : _buildPesananList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _filterChip('Semua', 'semua'),
            const SizedBox(width: 8),
            _filterChip('Baru', 'baru'),
            const SizedBox(width: 8),
            _filterChip('Diproses', 'diproses'),
            const SizedBox(width: 8),
            _filterChip('Selesai', 'selesai'),
            const SizedBox(width: 8),
            _filterChip('Ditolak', 'ditolak'),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(final String label, final String value) {
    final isSelected = _filterStatus == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (final selected) {
        Log.info(
          'FILTER: FilterChip "$label" (value: "$value") dipilih. Selected: $selected',
        );
        Log.info('  - Filter sebelumnya: "$_filterStatus"');
        Log.info('  - Filter baru: "$value"');
        setState(() => _filterStatus = value);
        Log.info(
          'State _filterStatus berhasil diperbarui. Memanggil _muatPesanan() dengan filter baru.',
        );
        unawaited(_muatPesanan());
      },
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildSummaryCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _summaryCard(
              'Total Pesanan',
              '${_daftarPesanan.length}',
              Icons.receipt_long,
              Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(final String title, final String value,
      final IconData icon, final Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPesananList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _daftarPesanan.length,
      itemBuilder: (final context, final index) {
        final pesanan = _daftarPesanan[index];
        Log.info(
          'Membangun kartu pesanan ke-${index + 1}/${_daftarPesanan.length}: '
          '#${pesanan.id} (Status: ${pesanan.status})',
        );
        return _buildPesananCard(pesanan);
      },
    );
  }

  Widget _buildPesananCard(final PesananModel pesanan) {
    final Color statusColor = _getStatusColor(pesanan);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: statusColor.withAlpha((0.3 * 255).round()),
        ),
      ),
      child: InkWell(
        onTap: () {
          Log.info(
            'TAP: Kartu pesanan #${pesanan.id} di-tap. Menampilkan detail pesanan.',
          );
          unawaited(_showPesananDetail(pesanan));
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: statusColor.withAlpha(25),
                        child: Icon(Icons.person, color: statusColor),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pesanan.idPelanggan,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Pesanan #${pesanan.id}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusText(pesanan),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  const Icon(Icons.wifi, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      pesanan.idPaket,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('dd MMM yyyy HH:mm').format(pesanan.tanggal),
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _actionButton('Proses', Icons.play_arrow, Colors.blue, () {
                    Log.info(
                      'AKSI: Tombol "Proses" ditekan untuk pesanan #${pesanan.id}.',
                    );
                    unawaited(_updateStatus(pesanan, 'diproses'));
                  }),
                  const SizedBox(width: 8),
                  _actionButton('Selesai', Icons.check_circle, Colors.green,
                      () {
                    Log.info(
                      'AKSI: Tombol "Selesai" ditekan untuk pesanan #${pesanan.id}.',
                    );
                    unawaited(_updateStatus(pesanan, 'selesai'));
                  }),
                  const SizedBox(width: 8),
                  _actionButton('Tolak', Icons.cancel, Colors.red, () {
                    Log.info(
                      'AKSI: Tombol "Tolak" ditekan untuk pesanan #${pesanan.id}.',
                    );
                    unawaited(_updateStatus(pesanan, 'ditolak'));
                  }),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.grey),
                    onPressed: () {
                      Log.info(
                        'AKSI: Tombol "Hapus" ditekan untuk pesanan #${pesanan.id}.',
                      );
                      unawaited(_hapusPesanan(pesanan));
                    },
                    tooltip: 'Hapus',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton(
    final String label,
    final IconData icon,
    final Color color,
    final VoidCallback onPressed,
  ) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: color),
      label: Text(label, style: TextStyle(color: color, fontSize: 12)),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Color _getStatusColor(final PesananModel pesanan) {
    switch (pesanan.status) {
      case 'baru':
        return Colors.blue;
      case 'diproses':
        return Colors.orange;
      case 'selesai':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      default:
        Log.warning(
          'Status pesanan tidak dikenal: "${pesanan.status}" untuk pesanan #${pesanan.id}. Menggunakan warna default (grey).',
        );
        return Colors.grey;
    }
  }

  String _getStatusText(final PesananModel pesanan) {
    return pesanan.status.substring(0, 1).toUpperCase() +
        pesanan.status.substring(1);
  }

  Future<void> _showPesananDetail(final PesananModel pesanan) async {
    Log.info('========================================');
    Log.info('MENAMPILKAN DETAIL PESANAN (Bottom Sheet)');
    Log.info('ID Pesanan: ${pesanan.id}');
    Log.info('ID Pelanggan: ${pesanan.idPelanggan}');
    Log.info('ID Paket: ${pesanan.idPaket}');
    Log.info('Status: "${pesanan.status}"');
    Log.info(
      'Tanggal: ${DateFormat("dd MMM yyyy HH:mm").format(pesanan.tanggal)}',
    );
    Log.info('========================================');

    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (final context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Detail Pesanan #${pesanan.id}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _detailRow('Nama Pelanggan', pesanan.idPelanggan),
            _detailRow('Paket', pesanan.idPaket),
            _detailRow(
              'Tanggal',
              DateFormat('dd MMM yyyy HH:mm').format(pesanan.tanggal),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
    Log.info('Bottom Sheet detail pesanan #${pesanan.id} ditutup.');
  }

  Widget _detailRow(final String label, final String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
