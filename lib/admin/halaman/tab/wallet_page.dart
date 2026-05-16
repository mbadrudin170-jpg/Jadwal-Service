import 'dart:ffi';

// path: lib/admin/halaman/tab/wallet_page.dart
// diubah: Refactor total ke Bahasa Inggris (class, method, variabel) dengan komentar Bahasa Indonesia.
// diubah: Memperbaiki LateInitializationError dengan menginisialisasi _walletOperation di initState.
// diubah: Menyesuaikan nama method dengan WalletOperation (getWallets, archiveOneWallet, dll).
// diubah: Mengganti nama file dari dompet.dart menjadi wallet_page.dart.

import 'dart:async';// === ANALISIS FILE DAN RELASI MENDALAM (TRACE BERANTAI) ===
//
// Saya ingin kamu menganalisis file berikut secara MENDALAM dan MENYELURUH:
//
// --- FILE UTAMA ---
// Nama file: dompet.dart
// Path: ~/myapp/lib/admin/halaman/tab/dompet.dart
//
// Isi file:
// ```dart
// // path: lib/admin/halaman/tab/wallet_page.dart
// diubah: Refactor total ke Bahasa Inggris (class, method, variabel) dengan komentar Bahasa Indonesia.
// diubah: Memperbaiki LateInitializationError dengan menginisialisasi _walletOperation di initState.
// diubah: Menyesuaikan nama method dengan WalletOperation (getWallets, archiveOneWallet, dll).
// diubah: Mengganti nama file dari dompet.dart menjadi wallet_page.dart.

import 'dart:async';// === ANALISIS FILE DAN RELASI MENDALAM (TRACE BERANTAI) ===
//
// Saya ingin kamu menganalisis file berikut secara MENDALAM dan MENYELURUH:
//
// --- FILE UTAMA ---
// Nama file: dompet.dart
// Path: ~/myapp/lib/admin/halaman/tab/dompet.dart
//
// Isi file:
// ```dart
// isi file lengkap
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
//    - Format: 'Apakah ada file lain yang meng-import dompet.dart? Tolong paste isinya'
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
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wifi/admin/halaman/detail/wallet_detail.dart';
import 'package:wifi/admin/halaman/form/wallet_form.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/wallet_model.dart';
import 'package:wifi/shared/operasi/transaction_operation.dart';
import 'package:wifi/shared/operasi/wallet_operation.dart';
import 'package:wifi/shared/utils/snackbar_util.dart';
import 'package:wifi/shared/widget/financial_summary_widget.dart';

// === INFORMASI DEPENDENCY ===
// 📂 FILE INI DIGUNAKAN OLEH:
//   - lib/admin/halaman/tab/admin_tab_page.dart (sebagai tab Dompet)
//
// 📂 FILE INI MENGGUNAKAN:
//   - lib/admin/halaman/detail/wallet_detail.dart (WalletDetailPage)
//   - lib/admin/halaman/form/wallet_form.dart (WalletForm)
//   - lib/shared/model/wallet_model.dart (WalletModel)
//   - lib/shared/operasi/wallet_operation.dart (WalletOperation)
//   - lib/shared/operasi/transaction_operation.dart (TransactionOperation)
//   - lib/shared/debug/log.dart (Log)
//   - lib/shared/utils/snackbar_util.dart (SnackBarUtil)
//   - lib/shared/widget/financial_summary_widget.dart (buildFinancialSummaryInfo)

/// Halaman untuk menampilkan dan mengelola dompet (wallet).
///
/// Menampilkan ringkasan keuangan (pemasukan, pengeluaran, total) dan daftar dompet.
class WalletPage extends StatefulWidget {
  /// Operasi dompet yang akan digunakan oleh halaman.
  final WalletOperation? walletOperation;

  /// Operasi transaksi yang akan digunakan oleh halaman, terutama untuk diteruskan ke halaman detail.
  final TransactionOperation? transactionOperation;

  /// Membuat instance dari [WalletPage].
  const WalletPage({
    super.key,
    this.walletOperation,
    this.transactionOperation,
  });

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  late final WalletOperation _walletOperation;
  late Future<List<WalletModel>> _walletListFuture;

  @override
  void initState() {
    super.initState();
    Log.info('Halaman Wallet sedang diinisialisasi.');
    // Inisialisasi WalletOperation dari widget atau buat instance baru
    _walletOperation = widget.walletOperation ?? WalletOperation();
    _loadWallets();
  }

  /// Memuat ulang data dompet dari database.
  void _loadWallets() {
    Log.info('Memulai pemuatan data dompet dan ringkasan keuangan.');
    setState(() {
      _walletListFuture = _walletOperation.getWallets();
    });
    Log.info('Pemuatan data dompet dan ringkasan keuangan telah dijadwalkan.');
  }

  /// Navigasi ke halaman form tambah dompet.
  Future<void> _addWallet() async {
    Log.info('Navigasi ke halaman tambah dompet.');
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(builder: (final context) => const WalletForm()),
    );
    if (!mounted) return;
    if (result ?? false) {
      Log.info('Berhasil menambahkan dompet baru, memuat ulang data.');
      _loadWallets();
    }
  }

  /// Menampilkan dialog konfirmasi untuk menghapus semua dompet.
  Future<void> _showDeleteAllDialog() async {
    Log.info('Menampilkan dialog konfirmasi hapus semua dompet.');
    final walletList = await _walletOperation.getWallets();
    if (!mounted) return;

    if (walletList.isEmpty) {
      Log.warning('Tidak ada dompet untuk dihapus. Dialog tidak ditampilkan.');
      SnackBarUtil.info(
        context,
        'Tidak ada dompet untuk dihapus.',
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (final BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus semua dompet? Tindakan ini tidak dapat diurungkan.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Log.info('Pengguna membatalkan penghapusan semua dompet.');
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Hapus'),
              onPressed: () {
                Log.warning(
                  'Pengguna mengkonfirmasi penghapusan semua dompet melalui dialog. Memanggil _deleteAllWallets.',
                );
                Navigator.of(context).pop();
                unawaited(_deleteAllWallets());
              },
            ),
          ],
        );
      },
    );
  }

  /// Menampilkan dialog konfirmasi untuk mengarsipkan satu dompet.
  Future<void> _showArchiveOneDialog(final WalletModel wallet) async {
    Log.info(
      'Memicu fungsi _showArchiveOneDialog untuk dompet ID: ${wallet.id}, Nama: "${wallet.name}". Menampilkan dialog konfirmasi.',
    );
    await showDialog<void>(
      context: context,
      builder: (final BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Arsip'),
          content: Text(
            'Apakah Anda yakin ingin mengarsipkan dompet "${wallet.name}"?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Log.info(
                  'Pengguna membatalkan pengarsipan dompet ID: ${wallet.id}, Nama: "${wallet.name}". Dialog ditutup, tidak ada aksi.',
                );
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Arsipkan'),
              onPressed: () {
                Log.warning(
                  'Pengguna mengkonfirmasi pengarsipan dompet ID: ${wallet.id}, Nama: "${wallet.name}". Memanggil _archiveOneWallet.',
                );
                Navigator.of(context).pop();
                unawaited(_archiveOneWallet(wallet));
              },
            ),
          ],
        );
      },
    );
  }

  /// Mengarsipkan satu dompet (soft delete).
  Future<void> _archiveOneWallet(final WalletModel wallet) async {
    Log.info('Memulai pengarsipan dompet: "${wallet.name}".');
    try {
      await _walletOperation.archiveOneWallet(wallet.id);
      _loadWallets();
      if (!mounted) return;
      Log.info('Dompet "${wallet.name}" berhasil diarsipkan.');
      SnackBarUtil.success(
        context,
        'Dompet berhasil diarsipkan.',
      );
    } on Exception catch (e, s) {
      if (!mounted) return;
      Log.error(
        'Gagal mengarsipkan dompet: "${wallet.name}".',
        e: e,
        st: s,
      );
      SnackBarUtil.error(
        context,
        'Gagal mengarsipkan dompet: $e',
      );
    }
  }

  /// Menghapus semua dompet secara permanen.
  Future<void> _deleteAllWallets() async {
    Log.info('Memulai penghapusan semua dompet.');
    try {
      await _walletOperation.deleteAllWallets();
      _loadWallets();
      if (!mounted) return;
      Log.info('Semua dompet berhasil dihapus.');
      SnackBarUtil.success(
        context,
        'Semua dompet berhasil dihapus.',
      );
    } on Exception catch (e, s) {
      if (!mounted) return;
      Log.error('Gagal menghapus semua dompet.', e: e, st: s);
      SnackBarUtil.error(
        context,
        'Gagal menghapus dompet: $e',
      );
    }
  }

  @override
  Widget build(final BuildContext context) {
    Log.info('Membangun UI untuk Halaman Wallet.');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dompet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _showDeleteAllDialog,
            tooltip: 'Hapus Semua Dompet',
          ),
        ],
      ),
      body: Column(
        children: [
          FinancialSummary(
            walletOperation: _walletOperation,
          ),
          Expanded(
            child: FutureBuilder<List<WalletModel>>(
              future: _walletListFuture,
              builder: (final context, final snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  Log.info('Menunggu data dompet...');
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  Log.error(
                    'Error saat memuat data dompet.',
                    e: snapshot.error,
                    st: snapshot.stackTrace,
                  );
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  Log.info('Tidak ada data dompet ditemukan.');
                  return const Center(
                    child: Text('Tidak ada dompet ditemukan.'),
                  );
                } else {
                  Log.info(
                    'Berhasil memuat ${snapshot.data!.length} dompet, membangun daftar.',
                  );
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 8),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (final context, final index) {
                      final wallet = snapshot.data![index];
                      return WalletCard(
                        wallet: wallet,
                        onTap: () async {
                          Log.info(
                            'Navigasi ke detail dompet: "${wallet.name}".',
                          );
                          await Navigator.push<void>(
                            context,
                            MaterialPageRoute<void>(
                              builder: (final context) => WalletDetailPage(
                                wallet: wallet,
                                walletOperation: _walletOperation,
                                transactionOperation:
                                    widget.transactionOperation,
                              ),
                            ),
                          );
                          if (!mounted) return;
                          _loadWallets();
                        },
                        onLongPress: () => _showArchiveOneDialog(wallet),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addWallet,
        tooltip: 'Tambah Dompet',
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Widget untuk menampilkan ringkasan keuangan.
///
/// Menampilkan pemasukan, pengeluaran, dan total saldo dari semua dompet.
class FinancialSummary extends StatefulWidget {
  /// Operasi dompet yang akan digunakan untuk mengambil data ringkasan.
  final WalletOperation walletOperation;

  /// Membuat instance dari [FinancialSummary].
  const FinancialSummary({super.key, required this.walletOperation});

  @override
  State<FinancialSummary> createState() => _FinancialSummaryState();
}

class _FinancialSummaryState extends State<FinancialSummary> {
  late Future<List<double>> _summaryFuture;

  @override
  void initState() {
    super.initState();
    Log.info('Menginisialisasi widget Ringkasan Keuangan.');
    _loadSummary();
  }

  /// Memuat data ringkasan keuangan (pemasukan, pengeluaran, total).
  void _loadSummary() {
    Log.info('Memuat data ringkasan keuangan.');
    _summaryFuture = Future.wait([
      widget.walletOperation.getPositiveBalance(),
      widget.walletOperation.getNegativeBalance(),
      widget.walletOperation.getTotalBalance(),
    ]);
  }

  /// Method ini bisa dipanggil dari parent untuk me-refresh data ringkasan.
  void refresh() {
    Log.info('Memuat ulang data ringkasan keuangan atas permintaan parent.');
    setState(_loadSummary);
  }

  @override
  Widget build(final BuildContext context) {
    Log.info('Membangun UI untuk widget Ringkasan Keuangan.');
    return FutureBuilder<List<double>>(
      future: _summaryFuture,
      builder: (final context, final snapshot) {
        double income = 0.0;
        double expense = 0.0;
        double total = 0.0;

        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          final result = snapshot.data!;
          income = result[0];
          expense = result[1].abs(); // Tampilkan sebagai angka positif
          total = result[2];
          Log.info(
            'Ringkasan keuangan berhasil dihitung: Pemasukan=$income, Pengeluaran=$expense, Total=$total',
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          Log.info('Menunggu data ringkasan keuangan...');
        } else if (snapshot.hasError) {
          Log.error(
            'Gagal memuat ringkasan keuangan',
            e: snapshot.error,
            st: snapshot.stackTrace,
          );
        }

        return Card(
          margin: const EdgeInsets.all(12.0),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: snapshot.connectionState == ConnectionState.waiting
                ? const Center(child: CircularProgressIndicator())
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      buildFinancialSummaryInfo(
                        context: context,
                        label: 'Pemasukan',
                        amount: income,
                        color: Colors.green,
                      ),
                      buildFinancialSummaryInfo(
                        context: context,
                        label: 'Pengeluaran',
                        amount: expense,
                        color: Colors.red,
                      ),
                      buildFinancialSummaryInfo(
                        context: context,
                        label: 'Total',
                        amount: total,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

/// Widget kartu untuk menampilkan informasi dompet.
///
/// Menampilkan nama dompet dan saldo dalam bentuk kartu (Card).
class WalletCard extends StatelessWidget {
  /// Model dompet yang akan ditampilkan.
  final WalletModel wallet;

  /// Callback saat kartu di-tap.
  final VoidCallback onTap;

  /// Callback saat kartu di-long press.
  final VoidCallback onLongPress;

  /// Membuat instance dari [WalletCard].
  const WalletCard({
    super.key,
    required this.wallet,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(final BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: const Icon(
          Icons.account_balance_wallet,
          size: 40,
          color: Colors.blueAccent,
        ),
        title: Text(
          wallet.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(
          'Saldo: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(wallet.balance)}',
          style: TextStyle(
            fontSize: 16,
            color: wallet.balance < 0 ? Colors.red : Colors.black54,
          ),
        ),
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }
}
[{
	"resource": "/home/user/myapp/lib/admin/halaman/tab/dompet.dart",
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
	"message": "Target of URI doesn't exist: 'package:wifi/shared/widget/financial_summary_widget.dart'.\nTry creating the file referenced by the URI, or try using a URI for a file that does exist.",
	"source": "dart",
	"startLineNumber": 18,
	"startColumn": 8,
	"endLineNumber": 18,
	"endColumn": 66
},{
	"resource": "/home/user/myapp/lib/admin/halaman/tab/dompet.dart",
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
	"message": "The method 'WalletDetailPage' isn't defined for the type '_WalletPageState'.\nTry correcting the name to the name of an existing method, or defining a method named 'WalletDetailPage'.",
	"source": "dart",
	"startLineNumber": 281,
	"startColumn": 59,
	"endLineNumber": 281,
	"endColumn": 75
},{
	"resource": "/home/user/myapp/lib/admin/halaman/tab/dompet.dart",
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
	"message": "The method 'buildFinancialSummaryInfo' isn't defined for the type '_FinancialSummaryState'.\nTry correcting the name to the name of an existing method, or defining a method named 'buildFinancialSummaryInfo'.",
	"source": "dart",
	"startLineNumber": 393,
	"startColumn": 23,
	"endLineNumber": 393,
	"endColumn": 48
},{
	"resource": "/home/user/myapp/lib/admin/halaman/tab/dompet.dart",
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
	"message": "The method 'buildFinancialSummaryInfo' isn't defined for the type '_FinancialSummaryState'.\nTry correcting the name to the name of an existing method, or defining a method named 'buildFinancialSummaryInfo'.",
	"source": "dart",
	"startLineNumber": 399,
	"startColumn": 23,
	"endLineNumber": 399,
	"endColumn": 48
},{
	"resource": "/home/user/myapp/lib/admin/halaman/tab/dompet.dart",
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
	"message": "The method 'buildFinancialSummaryInfo' isn't defined for the type '_FinancialSummaryState'.\nTry correcting the name to the name of an existing method, or defining a method named 'buildFinancialSummaryInfo'.",
	"source": "dart",
	"startLineNumber": 405,
	"startColumn": 23,
	"endLineNumber": 405,
	"endColumn": 48
},{
	"resource": "/home/user/myapp/lib/admin/halaman/tab/dompet.dart",
	"owner": "_generated_diagnostic_collection_name_#2",
	"code": {
		"value": "unused_import",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/unused_import",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 4,
	"message": "Unused import: 'package:wifi/admin/halaman/detail/wallet_detail.dart'.\nTry removing the import directive.",
	"source": "dart",
	"startLineNumber": 11,
	"startColumn": 8,
	"endLineNumber": 11,
	"endColumn": 62
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
//    - Format: 'Apakah ada file lain yang meng-import dompet.dart? Tolong paste isinya'
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
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wifi/admin/halaman/detail/wallet_detail.dart';
import 'package:wifi/admin/halaman/form/wallet_form.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/wallet_model.dart';
import 'package:wifi/shared/operasi/transaction_operation.dart';
import 'package:wifi/shared/operasi/wallet_operation.dart';
import 'package:wifi/shared/utils/snackbar_util.dart';
import 'package:wifi/shared/widget/financial_summary_widget.dart';

// === INFORMASI DEPENDENCY ===
// 📂 FILE INI DIGUNAKAN OLEH:
//   - lib/admin/halaman/tab/admin_tab_page.dart (sebagai tab Dompet)
//
// 📂 FILE INI MENGGUNAKAN:
//   - lib/admin/halaman/detail/wallet_detail.dart (WalletDetailPage)
//   - lib/admin/halaman/form/wallet_form.dart (WalletForm)
//   - lib/shared/model/wallet_model.dart (WalletModel)
//   - lib/shared/operasi/wallet_operation.dart (WalletOperation)
//   - lib/shared/operasi/transaction_operation.dart (TransactionOperation)
//   - lib/shared/debug/log.dart (Log)
//   - lib/shared/utils/snackbar_util.dart (SnackBarUtil)
//   - lib/shared/widget/financial_summary_widget.dart (buildFinancialSummaryInfo)

/// Halaman untuk menampilkan dan mengelola dompet (wallet).
///
/// Menampilkan ringkasan keuangan (pemasukan, pengeluaran, total) dan daftar dompet.
class WalletPage extends StatefulWidget {
  /// Operasi dompet yang akan digunakan oleh halaman.
  final WalletOperation? walletOperation;

  /// Operasi transaksi yang akan digunakan oleh halaman, terutama untuk diteruskan ke halaman detail.
  final TransactionOperation? transactionOperation;

  /// Membuat instance dari [WalletPage].
  const WalletPage({
    super.key,
    this.walletOperation,
    this.transactionOperation,
  });

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  late final WalletOperation _walletOperation;
  late Future<List<WalletModel>> _walletListFuture;

  @override
  void initState() {
    super.initState();
    Log.info('Halaman Wallet sedang diinisialisasi.');
    // Inisialisasi WalletOperation dari widget atau buat instance baru
    _walletOperation = widget.walletOperation ?? WalletOperation();
    _loadWallets();
  }

  /// Memuat ulang data dompet dari database.
  void _loadWallets() {
    Log.info('Memulai pemuatan data dompet dan ringkasan keuangan.');
    setState(() {
      _walletListFuture = _walletOperation.getWallets();
    });
    Log.info('Pemuatan data dompet dan ringkasan keuangan telah dijadwalkan.');
  }

  /// Navigasi ke halaman form tambah dompet.
  Future<void> _addWallet() async {
    Log.info('Navigasi ke halaman tambah dompet.');
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(builder: (final context) => const WalletForm()),
    );
    if (!mounted) return;
    if (result ?? false) {
      Log.info('Berhasil menambahkan dompet baru, memuat ulang data.');
      _loadWallets();
    }
  }

  /// Menampilkan dialog konfirmasi untuk menghapus semua dompet.
  Future<void> _showDeleteAllDialog() async {
    Log.info('Menampilkan dialog konfirmasi hapus semua dompet.');
    final walletList = await _walletOperation.getWallets();
    if (!mounted) return;

    if (walletList.isEmpty) {
      Log.warning('Tidak ada dompet untuk dihapus. Dialog tidak ditampilkan.');
      SnackBarUtil.info(
        context,
        'Tidak ada dompet untuk dihapus.',
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (final BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus semua dompet? Tindakan ini tidak dapat diurungkan.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Log.info('Pengguna membatalkan penghapusan semua dompet.');
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Hapus'),
              onPressed: () {
                Log.warning(
                  'Pengguna mengkonfirmasi penghapusan semua dompet melalui dialog. Memanggil _deleteAllWallets.',
                );
                Navigator.of(context).pop();
                unawaited(_deleteAllWallets());
              },
            ),
          ],
        );
      },
    );
  }

  /// Menampilkan dialog konfirmasi untuk mengarsipkan satu dompet.
  Future<void> _showArchiveOneDialog(final WalletModel wallet) async {
    Log.info(
      'Memicu fungsi _showArchiveOneDialog untuk dompet ID: ${wallet.id}, Nama: "${wallet.name}". Menampilkan dialog konfirmasi.',
    );
    await showDialog<void>(
      context: context,
      builder: (final BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Arsip'),
          content: Text(
            'Apakah Anda yakin ingin mengarsipkan dompet "${wallet.name}"?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Log.info(
                  'Pengguna membatalkan pengarsipan dompet ID: ${wallet.id}, Nama: "${wallet.name}". Dialog ditutup, tidak ada aksi.',
                );
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Arsipkan'),
              onPressed: () {
                Log.warning(
                  'Pengguna mengkonfirmasi pengarsipan dompet ID: ${wallet.id}, Nama: "${wallet.name}". Memanggil _archiveOneWallet.',
                );
                Navigator.of(context).pop();
                unawaited(_archiveOneWallet(wallet));
              },
            ),
          ],
        );
      },
    );
  }

  /// Mengarsipkan satu dompet (soft delete).
  Future<void> _archiveOneWallet(final WalletModel wallet) async {
    Log.info('Memulai pengarsipan dompet: "${wallet.name}".');
    try {
      await _walletOperation.archiveOneWallet(wallet.id);
      _loadWallets();
      if (!mounted) return;
      Log.info('Dompet "${wallet.name}" berhasil diarsipkan.');
      SnackBarUtil.success(
        context,
        'Dompet berhasil diarsipkan.',
      );
    } on Exception catch (e, s) {
      if (!mounted) return;
      Log.error(
        'Gagal mengarsipkan dompet: "${wallet.name}".',
        e: e,
        st: s,
      );
      SnackBarUtil.error(
        context,
        'Gagal mengarsipkan dompet: $e',
      );
    }
  }

  /// Menghapus semua dompet secara permanen.
  Future<void> _deleteAllWallets() async {
    Log.info('Memulai penghapusan semua dompet.');
    try {
      await _walletOperation.deleteAllWallets();
      _loadWallets();
      if (!mounted) return;
      Log.info('Semua dompet berhasil dihapus.');
      SnackBarUtil.success(
        context,
        'Semua dompet berhasil dihapus.',
      );
    } on Exception catch (e, s) {
      if (!mounted) return;
      Log.error('Gagal menghapus semua dompet.', e: e, st: s);
      SnackBarUtil.error(
        context,
        'Gagal menghapus dompet: $e',
      );
    }
  }

  @override
  Widget build(final BuildContext context) {
    Log.info('Membangun UI untuk Halaman Wallet.');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dompet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _showDeleteAllDialog,
            tooltip: 'Hapus Semua Dompet',
          ),
        ],
      ),
      body: Column(
        children: [
          FinancialSummary(
            walletOperation: _walletOperation,
          ),
          Expanded(
            child: FutureBuilder<List<WalletModel>>(
              future: _walletListFuture,
              builder: (final context, final snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  Log.info('Menunggu data dompet...');
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  Log.error(
                    'Error saat memuat data dompet.',
                    e: snapshot.error,
                    st: snapshot.stackTrace,
                  );
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  Log.info('Tidak ada data dompet ditemukan.');
                  return const Center(
                    child: Text('Tidak ada dompet ditemukan.'),
                  );
                } else {
                  Log.info(
                    'Berhasil memuat ${snapshot.data!.length} dompet, membangun daftar.',
                  );
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 8),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (final context, final index) {
                      final wallet = snapshot.data![index];
                      return WalletCard(
                        wallet: wallet,
                        onTap: () async {
                          Log.info(
                            'Navigasi ke detail dompet: "${wallet.name}".',
                          );
                          await Navigator.push<void>(
                            context,
                            MaterialPageRoute<void>(
                              builder: (final context) => WalletDetailPage(
                                wallet: wallet,
                                walletOperation: _walletOperation,
                                transactionOperation:
                                    widget.transactionOperation,
                              ),
                            ),
                          );
                          if (!mounted) return;
                          _loadWallets();
                        },
                        onLongPress: () => _showArchiveOneDialog(wallet),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addWallet,
        tooltip: 'Tambah Dompet',
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Widget untuk menampilkan ringkasan keuangan.
///
/// Menampilkan pemasukan, pengeluaran, dan total saldo dari semua dompet.
class FinancialSummary extends StatefulWidget {
  /// Operasi dompet yang akan digunakan untuk mengambil data ringkasan.
  final WalletOperation walletOperation;

  /// Membuat instance dari [FinancialSummary].
  const FinancialSummary({super.key, required this.walletOperation});

  @override
  State<FinancialSummary> createState() => _FinancialSummaryState();
}

class _FinancialSummaryState extends State<FinancialSummary> {
  late Future<List<double>> _summaryFuture;

  @override
  void initState() {
    super.initState();
    Log.info('Menginisialisasi widget Ringkasan Keuangan.');
    _loadSummary();
  }

  /// Memuat data ringkasan keuangan (pemasukan, pengeluaran, total).
  void _loadSummary() {
    Log.info('Memuat data ringkasan keuangan.');
    _summaryFuture = Future.wait([
      widget.walletOperation.getPositiveBalance(),
      widget.walletOperation.getNegativeBalance(),
      widget.walletOperation.getTotalBalance(),
    ]);
  }

  /// Method ini bisa dipanggil dari parent untuk me-refresh data ringkasan.
  void refresh() {
    Log.info('Memuat ulang data ringkasan keuangan atas permintaan parent.');
    setState(_loadSummary);
  }

  @override
  Widget build(final BuildContext context) {
    Log.info('Membangun UI untuk widget Ringkasan Keuangan.');
    return FutureBuilder<List<double>>(
      future: _summaryFuture,
      builder: (final context, final snapshot) {
        double income = 0.0;
        double expense = 0.0;
        double total = 0.0;

        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          final result = snapshot.data!;
          income = result[0];
          expense = result[1].abs(); // Tampilkan sebagai angka positif
          total = result[2];
          Log.info(
            'Ringkasan keuangan berhasil dihitung: Pemasukan=$income, Pengeluaran=$expense, Total=$total',
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          Log.info('Menunggu data ringkasan keuangan...');
        } else if (snapshot.hasError) {
          Log.error(
            'Gagal memuat ringkasan keuangan',
            e: snapshot.error,
            st: snapshot.stackTrace,
          );
        }

        return Card(
          margin: const EdgeInsets.all(12.0),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: snapshot.connectionState == ConnectionState.waiting
                ? const Center(child: CircularProgressIndicator())
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      buildFinancialSummaryInfo(
                        context: context,
                        label: 'Pemasukan',
                        amount: income,
                        color: Colors.green,
                      ),
                      buildFinancialSummaryInfo(
                        context: context,
                        label: 'Pengeluaran',
                        amount: expense,
                        color: Colors.red,
                      ),
                      buildFinancialSummaryInfo(
                        context: context,
                        label: 'Total',
                        amount: total,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

/// Widget kartu untuk menampilkan informasi dompet.
///
/// Menampilkan nama dompet dan saldo dalam bentuk kartu (Card).
class WalletCard extends StatelessWidget {
  /// Model dompet yang akan ditampilkan.
  final WalletModel wallet;

  /// Callback saat kartu di-tap.
  final VoidCallback onTap;

  /// Callback saat kartu di-long press.
  final VoidCallback onLongPress;

  /// Membuat instance dari [WalletCard].
  const WalletCard({
    super.key,
    required this.wallet,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(final BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: const Icon(
          Icons.account_balance_wallet,
          size: 40,
          color: Colors.blueAccent,
        ),
        title: Text(
          wallet.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(
          'Saldo: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(wallet.balance)}',
          style: TextStyle(
            fontSize: 16,
            color: wallet.balance < 0 ? Colors.red : Colors.black54,
          ),
        ),
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }
}
