// path: lib/admin/halaman/lainnya/customer.dart
// diubah: Menghapus import yang tidak digunakan dan memperbaiki gaya penulisan fungsi.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wifi/admin/halaman/detail/detail_customer.dart';
import 'package:wifi/admin/halaman/form/customer_form.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/customer_model.dart';
import 'package:wifi/shared/operasi/customer_operation.dart';
import 'package:wifi/shared/utils/snackbar_util.dart';

/// Enum untuk menentukan opsi pengurutan daftar customer.
enum OpsiUrut {
  /// Urutkan berdasarkan nama dari A hingga Z.
  namaAZ,

  /// Urutkan berdasarkan nama dari Z hingga A.
  namaZA,
}

/// Halaman untuk menampilkan dan mengelola daftar semua customer.
///
/// Admin dapat mencari, mengurutkan, menambah, mengedit, dan mengarsipkan customer.
class CustomerPage extends StatefulWidget {
  /// Membuat instance dari [CustomerPage].
  const CustomerPage({super.key});

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  final CustomerOperation _customerOperation = CustomerOperation();

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<CustomerModel> _allCustomers = [];
  List<CustomerModel> _filteredCustomers = [];
  bool _isLoading = true;

  OpsiUrut _opsiUrutSaatIni = OpsiUrut.namaAZ;

  @override
  void initState() {
    super.initState();
    Log.info(
      'Menginisialisasi state untuk CustomerPage. Memanggil _refreshCustomerList untuk pertama kali.',
    );
    unawaited(_refreshCustomerList());
    _searchController.addListener(_filterPelanggan);
  }

  @override
  void dispose() {
    Log.info(
      'Membersihkan resource di CustomerPage. _searchController di-dispose.',
    );
    _searchController.dispose();
    super.dispose();
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Cari nama customer...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
            )
          : const Text('Daftar Pelanggan'),
      actions: [
        IconButton(
          icon: const Icon(Icons.sort),
          tooltip: 'Urutkan',
          onPressed: _showSortDialog,
        ),
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          onPressed: () {
            Log.info(
              'Tombol search/close ditekan. Mengubah state _isSearching.',
            );
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                Log.info(
                  'Mode pencarian dinonaktifkan. Membersihkan search controller.',
                );
                _searchController.clear();
              } else {
                Log.info('Mode pencarian diaktifkan.');
              }
            });
          },
        ),
      ],
    );
  }

  Future<void> _showSortDialog() async {
    Log.info('Menampilkan dialog opsi pengurutan.');
    OpsiUrut? groupValue = _opsiUrutSaatIni;
    final OpsiUrut? result = await showDialog<OpsiUrut>(
      context: context,
      builder: (final BuildContext context) {
        return StatefulBuilder(
          builder: (final context, final setState) {
            void handleRadioValueChanged(final OpsiUrut? value) {
              setState(() {
                groupValue = value;
              });
            }

            return AlertDialog(
              title: const Text('Urutkan Berdasarkan'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  RadioListTile<OpsiUrut>(
                    title: const Text('Nama (A-Z)'),
                    value: OpsiUrut.namaAZ,
                    groupValue: groupValue,
                    onChanged: handleRadioValueChanged,
                  ),
                  RadioListTile<OpsiUrut>(
                    title: const Text('Nama (Z-A)'),
                    value: OpsiUrut.namaZA,
                    groupValue: groupValue,
                    onChanged: handleRadioValueChanged,
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Batal'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(groupValue);
                  },
                ),
              ],
            );
          },
        );
      },
    );
    if (result != null) {
      _applySort(result);
    }
  }

  void _applySort(final OpsiUrut option) {
    Log.info('Menerapkan pengurutan: $option');
    setState(() {
      _opsiUrutSaatIni = option;
      switch (option) {
        case OpsiUrut.namaAZ:
          _filteredCustomers.sort(
            (final a, final b) =>
                a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );
          break;
        case OpsiUrut.namaZA:
          _filteredCustomers.sort(
            (final a, final b) =>
                b.name.toLowerCase().compareTo(a.name.toLowerCase()),
          );
          break;
      }
    });
  }

  Future<void> _refreshCustomerList() async {
    Log.info(
      'Memulai proses refresh daftar customer. Mengatur _isLoading ke true.',
    );
    if (mounted) setState(() => _isLoading = true);

    try {
      final list = await _customerOperation.getCustomers();
      Log.info('Berhasil mengambil ${list.length} data customer.');

      if (mounted) {
        setState(() {
          _allCustomers = list;
          _filteredCustomers = list;
          _applySort(_opsiUrutSaatIni); // Terapkan urutan yang ada
          _isLoading = false;
          Log.info(
            'State diperbarui dengan daftar pelanggan yang baru. _isLoading diatur ke false.',
          );
        });
      }
    } on Exception catch (e, s) {
      Log.error(
        'Gagal total saat memuat daftar customer.',
        e: e,
        st: s,
      );
      if (mounted) {
        setState(() => _isLoading = false);
        SnackBarUtil.error(
            context, 'Gagal memuat data customer. Silakan coba lagi.');
      }
    }
  }

  void _filterPelanggan() {
    final query = _searchController.text.toLowerCase();
    Log.info(
      'Listener _searchController aktif. Memfilter daftar dengan query: "$query".',
    );

    setState(() {
      _filteredCustomers = _allCustomers
          .where((final p) => p.name.toLowerCase().contains(query))
          .toList();
      _applySort(_opsiUrutSaatIni); // Terapkan kembali urutan setelah filter
      Log.info(
        'Filter selesai. Ditemukan ${_filteredCustomers.length} pelanggan yang cocok.',
      );
    });
  }

  Future<void> _addCustomer() async {
    Log.info(
      'Tombol FAB (+) ditekan. Menavigasi ke CustomerForm untuk menambah data baru.',
    );
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (final context) => const CustomerForm()),
    );
    if (result ?? false) {
      Log.info(
        'Kembali dari CustomerForm dengan hasil sukses (true). Memanggil _refreshCustomerList untuk memuat ulang data.',
      );
      await _refreshCustomerList();
    } else {
      Log.info(
        'Kembali dari CustomerForm tanpa hasil (false atau null). Tidak ada aksi yang diambil.',
      );
    }
  }

  Future<void> _showDialogOpsi(final CustomerModel customer) async {
    Log.info(
      'Menampilkan dialog opsi (Edit/Arsipkan) untuk pelanggan: ${customer.name} (ID: ${customer.id}).',
    );
    await showDialog<void>(
      context: context,
      builder: (final BuildContext dialogContext) {
        return AlertDialog(
          title: Text(customer.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Pelanggan'),
                onTap: () async {
                  Log.info(
                    'Opsi "Edit Pelanggan" dipilih. Menutup dialog dan menavigasi ke CustomerForm dengan data yang ada.',
                  );
                  Navigator.of(dialogContext).pop();
                  await Navigator.push<void>(
                    context,
                    MaterialPageRoute(
                      builder: (final context) =>
                          CustomerForm(customer: customer),
                    ),
                  );
                  await _refreshCustomerList();
                },
              ),
              ListTile(
                leading: const Icon(Icons.archive_outlined),
                title: const Text('Arsipkan Pelanggan'),
                onTap: () async {
                  Log.info(
                    'Opsi "Arsipkan Pelanggan" dipilih. Menutup dialog dan memanggil _showDialogArsipkan.',
                  );
                  Navigator.of(dialogContext).pop();
                  await _showDialogArsipkan(customer);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showDialogArsipkan(final CustomerModel customer) async {
    Log.info(
      'Menampilkan dialog konfirmasi pengarsipan untuk pelanggan "${customer.name}".',
    );
    await showDialog<void>(
      context: context,
      builder: (final BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Arsip'),
          content: Text(
            'Apakah Anda yakin ingin mengarsipkan pelanggan "${customer.name}"?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Log.info('Pengguna membatalkan proses pengarsipan.');
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Arsipkan',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                Log.info(
                  'Pengguna mengonfirmasi pengarsipan. Memanggil _archiveCustomer dengan ID: ${customer.id}.',
                );
                Navigator.of(context).pop();
                await _archiveCustomer(customer.id);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _archiveCustomer(final String id) async {
    Log.info('Memulai proses pengarsipan untuk ID pelanggan: $id.');
    try {
      await _customerOperation.archiveCustomer(id);
      Log.info(
        'Berhasil mengarsipkan pelanggan dengan ID: $id. Memuat ulang daftar dan menampilkan SnackBar.',
      );
      await _refreshCustomerList();
      if (mounted) {
        SnackBarUtil.success(context, 'Pelanggan berhasil diarsipkan.');
      }
    } on Exception catch (e, s) {
      Log.error(
        'Gagal mengarsipkan pelanggan dengan ID: $id.',
        e: e,
        st: s,
      );
      if (mounted) {
        SnackBarUtil.error(context, 'Gagal mengarsipkan customer.');
      }
    }
  }

  @override
  Widget build(final BuildContext context) {
    Log.info('Membangun UI CustomerPage. Status loading: $_isLoading.');
    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _refreshCustomerList,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCustomer,
        tooltip: 'Tambah Pelanggan',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent() {
    if (_filteredCustomers.isEmpty) {
      Log.info('Membangun UI content: Daftar pelanggan kosong.');
      return Center(
        child: Text(
          _isSearching
              ? 'Pelanggan tidak ditemukan untuk pencarian ini.'
              : 'Belum ada customer. Tekan tombol + untuk menambah.',
          textAlign: TextAlign.center,
        ),
      );
    }

    Log.info(
      'Membangun UI content: Menampilkan ListView dengan ${_filteredCustomers.length} customer.',
    );
    return ListView.builder(
      itemCount: _filteredCustomers.length,
      itemBuilder: (final context, final index) {
        final pelanggan = _filteredCustomers[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            title: Text(
              customer.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(customer.macAddress),
            onTap: () async {
              Log.info(
                'ListTile untuk pelanggan "${customer.name}" ditekan. Menavigasi ke CustomerDetailPage.',
              );
              await Navigator.push<void>(
                context,
                MaterialPageRoute(
                  builder: (final context) =>
                      CustomerDetailPage(customerId: customer.id),
                ),
              );
              await _refreshCustomerList();
            },
            onLongPress: () async {
              Log.info(
                'ListTile untuk pelanggan "${customer.name}" ditekan lama (long press). Memanggil _showDialogOpsi.',
              );
              await _showDialogOpsi(customer);
            },
          ),
        );
      },
    );
  }
}
// === ANALISIS FILE DAN RELASI MENDALAM (TRACE BERANTAI) ===
//
// Saya ingin kamu menganalisis file berikut secara MENDALAM dan MENYELURUH:
//
// --- FILE UTAMA ---
// Nama file: customer.dart
// Path: ~/myapp/lib/admin/halaman/lainnya/customer.dart
//
// Isi file:
// ```dart
// [{
	"resource": "/home/user/myapp/lib/admin/halaman/lainnya/customer.dart",
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
	"message": "Target of URI doesn't exist: 'package:wifi/admin/halaman/detail/detail_customer.dart'.\nTry creating the file referenced by the URI, or try using a URI for a file that does exist.",
	"source": "dart",
	"startLineNumber": 7,
	"startColumn": 8,
	"endLineNumber": 7,
	"endColumn": 64
},{
	"resource": "/home/user/myapp/lib/admin/halaman/lainnya/customer.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "undefined_identifier",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/undefined_identifier",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "Undefined name 'customer'.\nTry correcting the name to one that is defined, or defining the name.",
	"source": "dart",
	"startLineNumber": 410,
	"startColumn": 15,
	"endLineNumber": 410,
	"endColumn": 23
},{
	"resource": "/home/user/myapp/lib/admin/halaman/lainnya/customer.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "undefined_identifier",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/undefined_identifier",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "Undefined name 'customer'.\nTry correcting the name to one that is defined, or defining the name.",
	"source": "dart",
	"startLineNumber": 413,
	"startColumn": 28,
	"endLineNumber": 413,
	"endColumn": 36
},{
	"resource": "/home/user/myapp/lib/admin/halaman/lainnya/customer.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "undefined_identifier",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/undefined_identifier",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "Undefined name 'customer'.\nTry correcting the name to one that is defined, or defining the name.",
	"source": "dart",
	"startLineNumber": 416,
	"startColumn": 46,
	"endLineNumber": 416,
	"endColumn": 54
},{
	"resource": "/home/user/myapp/lib/admin/halaman/lainnya/customer.dart",
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
	"message": "The method 'CustomerDetailPage' isn't defined for the type '_CustomerPageState'.\nTry correcting the name to the name of an existing method, or defining a method named 'CustomerDetailPage'.",
	"source": "dart",
	"startLineNumber": 422,
	"startColumn": 23,
	"endLineNumber": 422,
	"endColumn": 41
},{
	"resource": "/home/user/myapp/lib/admin/halaman/lainnya/customer.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "undefined_identifier",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/undefined_identifier",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "Undefined name 'customer'.\nTry correcting the name to one that is defined, or defining the name.",
	"source": "dart",
	"startLineNumber": 422,
	"startColumn": 54,
	"endLineNumber": 422,
	"endColumn": 62
},{
	"resource": "/home/user/myapp/lib/admin/halaman/lainnya/customer.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "undefined_identifier",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/undefined_identifier",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "Undefined name 'customer'.\nTry correcting the name to one that is defined, or defining the name.",
	"source": "dart",
	"startLineNumber": 429,
	"startColumn": 46,
	"endLineNumber": 429,
	"endColumn": 54
},{
	"resource": "/home/user/myapp/lib/admin/halaman/lainnya/customer.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "undefined_identifier",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/undefined_identifier",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "Undefined name 'customer'.\nTry correcting the name to one that is defined, or defining the name.",
	"source": "dart",
	"startLineNumber": 431,
	"startColumn": 37,
	"endLineNumber": 431,
	"endColumn": 45
},{
	"resource": "/home/user/myapp/lib/admin/halaman/lainnya/customer.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "unused_local_variable",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/unused_local_variable",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 4,
	"message": "The value of the local variable 'pelanggan' isn't used.\nTry removing the variable or using it.",
	"source": "dart",
	"startLineNumber": 405,
	"startColumn": 15,
	"endLineNumber": 405,
	"endColumn": 24
},{
	"resource": "/home/user/myapp/lib/admin/halaman/lainnya/customer.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "deprecated_member_use",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/deprecated_member_use",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 2,
	"message": "'groupValue' is deprecated and shouldn't be used. Use a RadioGroup ancestor to manage group value instead. This feature was deprecated after v3.32.0-0.0.pre.\nTry replacing the use of the deprecated member with the replacement.",
	"source": "dart",
	"startLineNumber": 129,
	"startColumn": 21,
	"endLineNumber": 129,
	"endColumn": 31,
	"tags": [
		2
	]
},{
	"resource": "/home/user/myapp/lib/admin/halaman/lainnya/customer.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "deprecated_member_use",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/deprecated_member_use",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 2,
	"message": "'onChanged' is deprecated and shouldn't be used. Use RadioGroup to handle value change instead. This feature was deprecated after v3.32.0-0.0.pre.\nTry replacing the use of the deprecated member with the replacement.",
	"source": "dart",
	"startLineNumber": 130,
	"startColumn": 21,
	"endLineNumber": 130,
	"endColumn": 30,
	"tags": [
		2
	]
},{
	"resource": "/home/user/myapp/lib/admin/halaman/lainnya/customer.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "deprecated_member_use",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/deprecated_member_use",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 2,
	"message": "'groupValue' is deprecated and shouldn't be used. Use a RadioGroup ancestor to manage group value instead. This feature was deprecated after v3.32.0-0.0.pre.\nTry replacing the use of the deprecated member with the replacement.",
	"source": "dart",
	"startLineNumber": 135,
	"startColumn": 21,
	"endLineNumber": 135,
	"endColumn": 31,
	"tags": [
		2
	]
},{
	"resource": "/home/user/myapp/lib/admin/halaman/lainnya/customer.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "deprecated_member_use",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/deprecated_member_use",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 2,
	"message": "'onChanged' is deprecated and shouldn't be used. Use RadioGroup to handle value change instead. This feature was deprecated after v3.32.0-0.0.pre.\nTry replacing the use of the deprecated member with the replacement.",
	"source": "dart",
	"startLineNumber": 136,
	"startColumn": 21,
	"endLineNumber": 136,
	"endColumn": 30,
	"tags": [
		2
	]
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
//    - Format: 'Apakah ada file lain yang meng-import customer.dart? Tolong paste isinya'
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