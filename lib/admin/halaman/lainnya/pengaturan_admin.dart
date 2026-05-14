// path: lib/admin/halaman/lainnya/pengaturan_admin.dart

import 'package:flutter/material.dart';
import 'package:wifi/admin/halaman/form/form_pengaturan.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/pengaturan_model.dart';
import 'package:wifi/shared/operasi/pengaturan_operasi.dart';
import 'package:wifi/shared/utils/sync_manager.dart'; // ditambah: import SyncManager

/// Halaman untuk menampilkan dan mengelola konfigurasi pengaturan aplikasi.
///
/// Dari halaman ini, admin dapat melihat pengaturan saat ini, mengeditnya,
/// dan melakukan aksi terkait seperti mereset waktu sinkronisasi.
class PengaturanAdmin extends StatefulWidget {
  /// Membuat instance dari [PengaturanAdmin].
  const PengaturanAdmin({super.key});

  @override
  State<PengaturanAdmin> createState() => _PengaturanAdminState();
}

class _PengaturanAdminState extends State<PengaturanAdmin> {
  final PengaturanOperasi _pengaturanOperasi = PengaturanOperasi();
  late Future<PengaturanModel> _futurePengaturan;

  @override
  void initState() {
    super.initState();
    Log.info('Menginisialisasi halaman Pengaturan Aplikasi');
    _loadPengaturan();
  }

  // Fungsi untuk memuat data pengaturan dari database.
  void _loadPengaturan() {
    Log.info('Memuat data pengaturan dari database lokal');
    setState(() {
      _futurePengaturan = _pengaturanOperasi.getPengaturan().then((final data) {
        Log.info('Data pengaturan berhasil dimuat dari database');
        Log.info(
          'Detail pengaturan - Interval sinkronisasi: ${data.intervalSinkronisasiOtomatis} jam, Hapus arsip: ${data.hapusOtomatisDataArsip} hari, Mode pemeliharaan: ${data.modePemeliharaan ? "Aktif" : "Nonaktif"}, Info pemeliharaan: ${data.infoPemeliharaan.isNotEmpty ? data.infoPemeliharaan : "(kosong)"}',
        );
        return data;
      }).catchError((final Object e, final StackTrace st) {
        Log.error(
          'Gagal memuat data pengaturan dari database lokal',
          e: e,
          st: st,
        );
        throw Exception('Gagal memuat data pengaturan: $e');
      });
    });
  }

  // Fungsi untuk menavigasi ke halaman form edit dan memuat ulang data jika ada perubahan.
  Future<void> _editPengaturan(final PengaturanModel pengaturan) async {
    Log.info('Navigasi ke halaman Form Edit Pengaturan');
    Log.info(
      'Data pengaturan sebelum edit - Interval: ${pengaturan.intervalSinkronisasiOtomatis} jam, Hapus arsip: ${pengaturan.hapusOtomatisDataArsip} hari, Mode pemeliharaan: ${pengaturan.modePemeliharaan}, Info: ${pengaturan.infoPemeliharaan.isNotEmpty ? pengaturan.infoPemeliharaan : "(kosong)"}',
    );

    final hasil = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (final context) => FormPengaturan(pengaturan: pengaturan),
      ),
    );

    if ((hasil ?? false) && mounted) {
      Log.info(
        'Data pengaturan berhasil diperbarui dari Form Edit, menyegarkan tampilan',
      );
      _loadPengaturan();
    } else if (hasil == false) {
      Log.info('Kembali dari Form Edit Pengaturan tanpa melakukan perubahan');
    } else {
      Log.info('Kembali dari Form Edit Pengaturan (hasil: $hasil)');
    }
  }

  // ditambah: Fungsi untuk mereset waktu sinkronisasi
  Future<void> _resetWaktuSinkronisasi() async {
    Log.info('Tombol Reset Waktu Sinkronisasi ditekan.');
    final bool? konfirmasi = await showDialog<bool>(
      context: context,
      builder: (final context) => AlertDialog(
        title: const Text('Konfirmasi Reset'),
        content: const Text(
          'Anda yakin ingin mereset waktu sinkronisasi? Tindakan ini akan memaksa aplikasi untuk mengunggah semua data yang dimodifikasi dan mengunduh semua data dari server pada siklus sinkronisasi berikutnya.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (konfirmasi ?? false) {
      Log.info(
        'Pengguna mengonfirmasi reset. Memanggil SyncManager().resetWaktuSinkronisasi().',
      );
      try {
        await SyncManager().resetWaktuSinkronisasi();
        Log.info('Reset waktu sinkronisasi berhasil.');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Waktu sinkronisasi berhasil di-reset.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } on Exception catch (e, st) {
        Log.error('Gagal mereset waktu sinkronisasi', e: e, st: st);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal mereset waktu sinkronisasi: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(final BuildContext context) {
    Log.info('Membangun UI halaman Pengaturan Aplikasi');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Aplikasi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Log.info('Kembali ke halaman sebelumnya dari Pengaturan');
            Navigator.of(context).pop();
          },
        ),
      ),
      body: FutureBuilder<PengaturanModel>(
        future: _futurePengaturan,
        builder: (final context, final snapshot) {
          Log.info('FutureBuilder status: ${snapshot.connectionState}');

          if (snapshot.connectionState == ConnectionState.waiting) {
            Log.info(
              'Menampilkan indikator loading, data pengaturan masih dimuat',
            );
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            Log.error(
              'FutureBuilder mendeteksi error saat memuat data pengaturan',
              e: snapshot.error,
              st: snapshot.stackTrace,
            );
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final pengaturan = snapshot.data!;
            Log.info('Data pengaturan tersedia, menampilkan detail pengaturan');
            Log.info(
              'Mode pemeliharaan: ${pengaturan.modePemeliharaan ? "Aktif" : "Nonaktif"}, Info: ${pengaturan.infoPemeliharaan.isNotEmpty ? pengaturan.infoPemeliharaan : "(kosong)"}',
            );

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        _buildInfoCard(
                          judul: 'Sinkronisasi Otomatis',
                          nilai:
                              '${pengaturan.intervalSinkronisasiOtomatis} Jam',
                          ikon: Icons.sync,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoCard(
                          judul: 'Hapus Arsip Otomatis',
                          nilai: '${pengaturan.hapusOtomatisDataArsip} Hari',
                          ikon: Icons.auto_delete_outlined,
                        ),
                        const Divider(height: 24, thickness: 1),
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              SwitchListTile(
                                title: const Text(
                                  'Mode Pemeliharaan',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  pengaturan.modePemeliharaan
                                      ? 'Aplikasi dalam mode pemeliharaan'
                                      : 'Aplikasi berjalan normal',
                                ),
                                value: pengaturan.modePemeliharaan,
                                onChanged: null, // Read-only di halaman ini
                                secondary: Icon(
                                  pengaturan.modePemeliharaan
                                      ? Icons.construction
                                      : Icons.check_circle_outline,
                                  color: pengaturan.modePemeliharaan
                                      ? Colors.orange
                                      : Colors.green,
                                ),
                              ),
                              if (pengaturan.modePemeliharaan)
                                ListTile(
                                  leading: const Icon(Icons.info_outline),
                                  title: const Text(
                                    'Info Pemeliharaan',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    pengaturan.infoPemeliharaan.isNotEmpty
                                        ? pengaturan.infoPemeliharaan
                                        : '(Tidak ada pesan diatur)',
                                  ),
                                  isThreeLine: true,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // ditambah: Tombol Reset Waktu Sinkronisasi
                        ElevatedButton.icon(
                          icon: const Icon(Icons.sync_problem),
                          label: const Text('Reset Waktu Sinkronisasi'),
                          onPressed: _resetWaktuSinkronisasi,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Pengaturan'),
                    onPressed: () async {
                      Log.info('Tombol Edit Pengaturan ditekan');
                      await _editPengaturan(pengaturan);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ),
            );
          } else {
            Log.warning(
              'Data pengaturan tidak tersedia (null), menampilkan pesan kosong',
            );
            return const Center(child: Text('Pengaturan tidak ditemukan.'));
          }
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required final String judul,
    required final String nilai,
    required final IconData ikon,
  }) {
    Log.info('Membangun kartu info: $judul dengan nilai: $nilai');
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 15,
        ),
        leading: Icon(ikon, size: 40, color: Theme.of(context).primaryColor),
        title: Text(judul, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(
          nilai,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
