// path: lib/admin/halaman/lainnya/package_activation_history.dart// diubah: Memperbaiki unawaited future.
// === ANALISIS FILE DAN RELASI MENDALAM (TRACE BERANTAI) ===
//
// Saya ingin kamu menganalisis file berikut secara MENDALAM dan MENYELURUH:
//
// --- FILE UTAMA ---
// Nama file: package_activation_history.dart
// Path: ~/myapp/lib/admin/halaman/lainnya/package_activation_history.dart
//
// Isi file:
// ```dart
// [{
	"resource": "/home/user/myapp/lib/admin/halaman/lainnya/package_activation_history.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
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
	"message": "Target of URI doesn't exist: 'package:wifi/admin/halaman/detail/subscription_history_detail.dart'.\nTry creating the file referenced by the URI, or try using a URI for a file that does exist.",
	"source": "dart",
	"startLineNumber": 6,
	"startColumn": 8,
	"endLineNumber": 6,
	"endColumn": 76
},{
	"resource": "/home/user/myapp/lib/admin/halaman/lainnya/package_activation_history.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
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
	"message": "Target of URI doesn't exist: 'package:wifi/admin/halaman/widget/package_name.dart'.\nTry creating the file referenced by the URI, or try using a URI for a file that does exist.",
	"source": "dart",
	"startLineNumber": 7,
	"startColumn": 8,
	"endLineNumber": 7,
	"endColumn": 61
},{
	"resource": "/home/user/myapp/lib/admin/halaman/lainnya/package_activation_history.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
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
	"message": "Target of URI doesn't exist: 'package:wifi/admin/halaman/widget/customer_name.dart'.\nTry creating the file referenced by the URI, or try using a URI for a file that does exist.",
	"source": "dart",
	"startLineNumber": 8,
	"startColumn": 8,
	"endLineNumber": 8,
	"endColumn": 62
},{
	"resource": "/home/user/myapp/lib/admin/halaman/lainnya/package_activation_history.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
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
	"message": "The method 'SubscriptionHistoryDetailPage' isn't defined for the type '_PackageActivationHistoryPageState'.\nTry correcting the name to the name of an existing method, or defining a method named 'SubscriptionHistoryDetailPage'.",
	"source": "dart",
	"startLineNumber": 349,
	"startColumn": 31,
	"endLineNumber": 349,
	"endColumn": 60
},{
	"resource": "/home/user/myapp/lib/admin/halaman/lainnya/package_activation_history.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
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
	"message": "The method 'CustomerNameWidget' isn't defined for the type '_PackageActivationHistoryPageState'.\nTry correcting the name to the name of an existing method, or defining a method named 'CustomerNameWidget'.",
	"source": "dart",
	"startLineNumber": 365,
	"startColumn": 28,
	"endLineNumber": 365,
	"endColumn": 46
},{
	"resource": "/home/user/myapp/lib/admin/halaman/lainnya/package_activation_history.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
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
	"message": "The method 'PackageNameWidget' isn't defined for the type '_PackageActivationHistoryPageState'.\nTry correcting the name to the name of an existing method, or defining a method named 'PackageNameWidget'.",
	"source": "dart",
	"startLineNumber": 372,
	"startColumn": 25,
	"endLineNumber": 372,
	"endColumn": 42
},{
	"resource": "/home/user/myapp/lib/admin/halaman/lainnya/package_activation_history.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
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
	"startLineNumber": 8,
	"startColumn": 1,
	"endLineNumber": 8,
	"endColumn": 63
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
//    - Format: 'Apakah ada file lain yang meng-import package_activation_history.dart? Tolong paste isinya'
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
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wifi/admin/halaman/detail/subscription_history_detail.dart';
import 'package:wifi/admin/halaman/widget/package_name.dart';
import 'package:wifi/admin/halaman/widget/customer_name.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/payment_status_enum.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/operasi/transaction_operation.dart';
import 'package:wifi/shared/utils/format_util.dart';

/// Enum untuk opsi pengurutan riwayat aktivasi paket.
enum OpsiUrutkan {
  /// Urutkan berdasarkan paket yang akan berakhir hari ini.
  berakhirHariIni,

  /// Urutkan berdasarkan transaksi terbaru.
  terbaru,

  /// Urutkan berdasarkan transaksi terlama.
  terlama,

  /// Tampilkan transaksi lunas di bagian atas.
  lunas,

  /// Tampilkan transaksi yang belum lunas di bagian atas.
  belumLunas
}

/// Halaman untuk menampilkan riwayat aktivasi paket langganan.
///
/// Admin dapat melihat, mengurutkan, dan membuka detail setiap transaksi
/// aktivasi paket yang pernah dilakukan.
class PackageActivationHistoryPage extends StatefulWidget {
  /// Membuat instance dari [PackageActivationHistoryPage].
  const PackageActivationHistoryPage({super.key});

  @override
  State<PackageActivationHistoryPage> createState() =>
      _PackageActivationHistoryPageState();
}

class _PackageActivationHistoryPageState extends State<PackageActivationHistoryPage> {
  final TransactionOperation _transactionOperation = TransactionOperation();
  late Future<List<TransactionModel>> _transactionListFuture;
  OpsiUrutkan _urutanAktif = OpsiUrutkan.terbaru;

  @override
  void initState() {
    super.initState();
    Log.info('Menginisialisasi halaman Riwayat Aktivasi Paket');
    unawaited(_loadHistory());
  }

  Future<void> _loadHistory() async {
    Log.info('Memuat data transaksi aktivasi paket dari database');
    setState(() {
      _transactionListFuture =
          _transactionOperation.getTransactionsByPackageActivation().then((final list) {
        Log.info(
          'Berhasil memuat ${list.length} data transaksi aktivasi paket',
        );

        // Log ringkasan setiap transaksi
        int jumlahLunas = 0;
        int jumlahBelumLunas = 0;
        int jumlahBerakhirHariIni = 0;
        final sekarang = DateTime.now();

        for (var transaksi in list) {
          if (transaksi.paymentStatus == PaymentStatus.paid) {
            jumlahLunas++;
          } else {
            jumlahBelumLunas++;
          }

          if (transaksi.endDate != null &&
              transaksi.endDate!.year == sekarang.year &&
              transaksi.endDate!.month == sekarang.month &&
              transaksi.endDate!.day == sekarang.day) {
            jumlahBerakhirHariIni++;
          }

          Log.info(
            'Transaksi ID: ${transaksi.id} - Pelanggan ID: ${transaksi.customerId ?? "N/A"}, Paket ID: ${transaksi.packageId ?? "N/A"}, Status: ${transaksi.paymentStatus.name}, Mulai: ${transaksi.startDate != null ? FormatUtil.formatDateBasic(transaksi.startDate!) : "N/A"}, Berakhir: ${transaksi.endDate != null ? FormatUtil.formatDateBasic(transaksi.endDate!) : "N/A"}',
          );
        }

        Log.info(
          'Ringkasan transaksi - Total: ${list.length}, Lunas: $jumlahLunas, Belum Lunas: $jumlahBelumLunas, Berakhir Hari Ini: $jumlahBerakhirHariIni',
        );

        _urutkanList(list, _urutanAktif);
        return list;
      }).catchError((final Object error, final StackTrace st) {
        Log.error(
          'Gagal memuat data transaksi aktivasi paket dari database',
          e: error,
          st: st,
        );
        throw Exception('Gagal memuat data transaksi: $error');
      });
    });
  }

  void _urutkanList(
      final List<TransactionModel> list, final OpsiUrutkan pilihan) {
    Log.info(
      'Mengurutkan ${list.length} data transaksi berdasarkan: ${pilihan.name}',
    );
    int Function(TransactionModel, TransactionModel) comparator;

    switch (pilihan) {
      case OpsiUrutkan.terbaru:
        comparator = (final a, final b) =>
            (b.updatedAt ?? b.date).compareTo(a.updatedAt ?? a.date);
        Log.info('Pengurutan: Terbaru (berdasarkan waktu update/tanggal)');
        break;
      case OpsiUrutkan.terlama:
        comparator = (final a, final b) =>
            (a.updatedAt ?? a.date).compareTo(b.updatedAt ?? b.date);
        Log.info('Pengurutan: Terlama (berdasarkan waktu update/tanggal)');
        break;
      case OpsiUrutkan.lunas:
        comparator = (final a, final b) {
          final isLunasA = a.paymentStatus == PaymentStatus.paid;
          final isLunasB = b.paymentStatus == PaymentStatus.paid;
          if (isLunasA == isLunasB) {
            Log.info(
              'Status sama (${isLunasA ? "lunas" : "belum lunas"}), posisi tidak berubah',
            );
            return 0;
          }
          final result = isLunasA ? -1 : 1;
          Log.info(
            'Memindahkan transaksi ${isLunasA ? "lunas" : "belum lunas"} ke ${isLunasA ? "atas" : "bawah"}',
          );
          return result;
        };
        Log.info('Pengurutan: Lunas di atas, Belum Lunas di bawah');
        break;
      case OpsiUrutkan.belumLunas:
        comparator = (final a, final b) {
          final isLunasA = a.paymentStatus == PaymentStatus.paid;
          final isLunasB = b.paymentStatus == PaymentStatus.paid;
          if (isLunasA == isLunasB) {
            Log.info(
              'Status sama (${isLunasA ? "lunas" : "belum lunas"}), posisi tidak berubah',
            );
            return 0;
          }
          final result = isLunasA ? 1 : -1;
          Log.info(
            'Memindahkan transaksi ${isLunasA ? "lunas" : "belum lunas"} ke ${isLunasA ? "bawah" : "atas"}',
          );
          return result;
        };
        Log.info('Pengurutan: Belum Lunas di atas, Lunas di bawah');
        break;
      case OpsiUrutkan.berakhirHariIni:
        comparator = (final a, final b) {
          final sekarang = DateTime.now();
          final tanggalSekarangStr = FormatUtil.formatDateBasic(sekarang);

          bool isHariIni(final DateTime? tanggal) {
            if (tanggal == null) return false;
            return tanggal.year == sekarang.year &&
                tanggal.month == sekarang.month &&
                tanggal.day == sekarang.day;
          }

          final aHariIni = isHariIni(a.endDate);
          final bHariIni = isHariIni(b.endDate);

          if (aHariIni == bHariIni) {
            Log.info(
              'Status berakhir hari ini sama ($aHariIni), posisi tidak berubah',
            );
            return 0;
          }

          final result = aHariIni ? -1 : 1;
          Log.info(
            'Transaksi ${aHariIni ? "berakhir $tanggalSekarangStr" : "tidak berakhir hari ini"} dipindahkan ke ${aHariIni ? "atas" : "bawah"}',
          );
          return result;
        };
        Log.info(
          'Pengurutan: Berakhir Hari Ini (${FormatUtil.formatDateBasic(DateTime.now())}) di atas',
        );
        break;
    }

    list.sort(comparator);

    // Log 5 data teratas setelah pengurutan
    Log.info('5 data teratas setelah pengurutan ${pilihan.name}:');
    for (int i = 0; i < (list.length < 5 ? list.length : 5); i++) {
      final t = list[i];
      Log.info(
        '  ${i + 1}. ID: ${t.id} - Status: ${t.paymentStatus.name} - Berakhir: ${t.endDate != null ? FormatUtil.formatDateBasic(t.endDate!) : "N/A"}',
      );
    }

    Log.info('Proses pengurutan selesai, ${list.length} data telah diurutkan');
  }

  Future<void> _showUrutkanDialog() async {
    Log.info(
      'Menampilkan dialog opsi pengurutan, urutan saat ini: ${_urutanAktif.name}',
    );
    final OpsiUrutkan? pilihan = await showDialog<OpsiUrutkan>(
      context: context,
      builder: (final BuildContext context) {
        Widget buildOption(final String text, final OpsiUrutkan value) {
          final bool isSelected = _urutanAktif == value;
          return SimpleDialogOption(
            onPressed: () {
              Log.info(
                'User memilih opsi urutkan: ${value.name} (${isSelected ? "sudah aktif" : "berubah"} dari ${_urutanAktif.name})',
              );
              Navigator.pop(context, value);
            },
            child: Text(
              text,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }

        return SimpleDialog(
          title: const Text('Urutkan Berdasarkan'),
          children: <Widget>[
            buildOption('Berakhir Hari Ini', OpsiUrutkan.berakhirHariIni),
            buildOption('Terbaru', OpsiUrutkan.terbaru),
            buildOption('Terlama', OpsiUrutkan.terlama),
            buildOption('Status (Lunas di Atas)', OpsiUrutkan.lunas),
            buildOption('Status (Belum Lunas di Atas)', OpsiUrutkan.belumLunas),
          ],
        );
      },
    );

    if (pilihan != null && pilihan != _urutanAktif) {
      Log.info(
        'Menerapkan perubahan urutan dari ${_urutanAktif.name} ke ${pilihan.name}',
      );
      final list = await _transactionListFuture;
      setState(() {
        _urutanAktif = pilihan;
        _urutkanList(list, pilihan);
        _transactionListFuture = Future.value(list);
      });
      Log.info('Urutan berhasil diubah ke ${pilihan.name}');
    } else if (pilihan == _urutanAktif) {
      Log.info(
        'User memilih urutan yang sama (${_urutanAktif.name}), tidak ada perubahan',
      );
    } else {
      Log.info('Dialog urutkan ditutup tanpa memilih opsi');
    }
  }

  @override
  Widget build(final BuildContext context) {
    Log.info(
      'Membangun UI halaman Riwayat Aktivasi Paket, urutan aktif: ${_urutanAktif.name}',
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Langganan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Log.info(
              'Kembali ke halaman sebelumnya dari Riwayat Aktivasi Paket',
            );
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showUrutkanDialog,
            tooltip: 'Urutkan',
          ),
        ],
      ),
      body: FutureBuilder<List<TransactionModel>>(
        future: _transactionListFuture,
        builder: (final context, final snapshot) {
          Log.info('FutureBuilder status: ${snapshot.connectionState}');

          if (snapshot.connectionState == ConnectionState.waiting) {
            Log.info(
              'Menampilkan indikator loading, data transaksi masih dimuat',
            );
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            Log.error(
              'FutureBuilder mendeteksi error saat menampilkan data transaksi',
              e: snapshot.error,
              st: snapshot.stackTrace,
            );
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            Log.info(
              'Data riwayat aktivasi kosong, menampilkan pesan tidak ada data',
            );
            return const Center(
              child: Text('Tidak ada riwayat langganan ditemukan.'),
            );
          } else {
            final dataLength = snapshot.data!.length;
            Log.info('Menampilkan $dataLength data transaksi dalam ListView');

            return ListView.builder(
              itemCount: dataLength,
              itemBuilder: (final context, final index) {
                final transaksi = snapshot.data![index];
                final paymentStatusColor =
                    transaksi.paymentStatus == PaymentStatus.paid
                        ? Colors.green
                        : Colors.red;

                Log.info(
                  'Membangun item ke-${index + 1} dari $dataLength - ID: ${transaksi.id}, Pelanggan: ${transaksi.customerId ?? "N/A"}, Status: ${transaksi.paymentStatus.name}',
                );

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  child: ListTile(
                    onTap: () async {
                      Log.info(
                        'Navigasi ke halaman Detail Transaksi ID: ${transaksi.id}, Pelanggan ID: ${transaksi.customerId ?? "N/A"}',
                      );
                      final result = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (final context) =>
                              SubscriptionHistoryDetailPage(
                            transactionId: transaksi.id,
                          ),
                        ),
                      );
                      if (result ?? false) {
                        Log.info(
                          'Kembali dari Detail Transaksi ID: ${transaksi.id} dengan perubahan data, menyegarkan daftar',
                        );
                        await _loadHistory();
                      } else {
                        Log.info(
                          'Kembali dari Detail Transaksi ID: ${transaksi.id} tanpa perubahan data',
                        );
                      }
                    },
                    title: CustomerNameWidget(
                      customerId: transaksi.customerId ?? ' ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PackageNameWidget(
                          packageId: transaksi.packageId ?? '',
                          style: TextStyle(color: paymentStatusColor),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Status: ${transaksi.paymentStatus.name}',
                          style: TextStyle(
                            color: paymentStatusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (transaksi.startDate != null &&
                            transaksi.endDate != null)
                          Text(
                            'Aktif: ${FormatUtil.formatDateBasic(transaksi.startDate!)} - ${FormatUtil.formatDateBasic(transaksi.endDate!)}',
                          ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
