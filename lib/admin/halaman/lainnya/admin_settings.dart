// path: lib/admin/halaman/lainnya/admin_settings.dart
//
// 📂 FILE INI DIGUNAKAN OLEH:
//   - Digunakan sebagai halaman dalam navigasi admin (Settings).
//
// 📂 FILE INI MENGGUNAKAN:
//   - lib/admin/halaman/form/settings_form.dart (SettingsForm)
//   - lib/shared/model/settings_model.dart (SettingsModel)
//   - lib/shared/operasi/settings_operation.dart (SettingsOperation)
//   - lib/shared/utils/sync_manager.dart (SyncManager)
//   - lib/shared/utils/snackbar_util.dart (SnackBarUtil)
//   - lib/shared/debug/log.dart (Log)

import 'package:flutter/material.dart';
import 'package:wifi/admin/halaman/form/settings_form.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/settings_model.dart';
import 'package:wifi/shared/operasi/settings_operation.dart';
import 'package:wifi/shared/utils/snackbar_util.dart';
import 'package:wifi/shared/utils/sync_manager.dart';

/// Halaman untuk menampilkan dan mengelola konfigurasi pengaturan aplikasi.
///
/// Dari halaman ini, admin dapat melihat pengaturan saat ini, mengeditnya,
/// dan melakukan aksi terkait seperti mereset waktu sinkronisasi.
class SettingsAdminPage extends StatefulWidget {
  /// Membuat instance dari [SettingsAdminPage].
  const SettingsAdminPage({super.key});

  @override
  State<SettingsAdminPage> createState() => _SettingsAdminPageState();
}

class _SettingsAdminPageState extends State<SettingsAdminPage> {
  final SettingsOperation _settingsOperation = SettingsOperation();
  late Future<SettingsModel> _futureSettings;

  @override
  void initState() {
    super.initState();
    Log.info('Menginisialisasi halaman Pengaturan Aplikasi');
    _loadSettings();
  }

  // Fungsi untuk memuat data pengaturan dari database.
  void _loadSettings() {
    Log.info('Memuat data pengaturan dari database lokal');
    setState(() {
      _futureSettings = _settingsOperation.getSettings().then((final data) {
        Log.info('Data pengaturan berhasil dimuat dari database');
        Log.info(
          'Detail pengaturan - Interval sinkronisasi: ${data.autoSyncInterval} jam, Hapus arsip: ${data.autoDeleteArchiveDays} hari, Mode pemeliharaan: ${data.maintenanceMode ? "Aktif" : "Nonaktif"}, Info pemeliharaan: ${data.maintenanceInfo.isNotEmpty ? data.maintenanceInfo : "(kosong)"}',
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
  Future<void> _editSettings(final SettingsModel pengaturan) async {
    Log.info('Navigasi ke halaman Form Edit Pengaturan');
    Log.info(
      'Data pengaturan sebelum edit - Interval: ${pengaturan.autoSyncInterval} jam, Hapus arsip: ${pengaturan.autoDeleteArchiveDays} hari, Mode pemeliharaan: ${pengaturan.maintenanceMode}, Info: ${pengaturan.maintenanceInfo.isNotEmpty ? pengaturan.maintenanceInfo : "(kosong)"}',
    );

    final hasil = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (final context) => SettingsForm(settings: pengaturan),
      ),
    );

    if ((hasil ?? false) && mounted) {
      Log.info(
        'Data pengaturan berhasil diperbarui dari Form Edit, menyegarkan tampilan',
      );
      _loadSettings();
    } else if (hasil == false) {
      Log.info('Kembali dari Form Edit Pengaturan tanpa melakukan perubahan');
    } else {
      Log.info('Kembali dari Form Edit Pengaturan (hasil: $hasil)');
    }
  }

  // Fungsi untuk mereset waktu sinkronisasi
  Future<void> _resetSyncTime() async {
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
        'Pengguna mengonfirmasi reset. Memanggil SyncManager().resetSyncTime().',
      );
      try {
        await SyncManager().resetSyncTime();
        Log.info('Reset waktu sinkronisasi berhasil.');
        if (mounted) {
          SnackBarUtil.success(
            context,
            'Waktu sinkronisasi berhasil di-reset.',
          );
        }
      } on Exception catch (e, st) {
        Log.error('Gagal mereset waktu sinkronisasi', e: e, st: st);
        if (mounted) {
          SnackBarUtil.error(
            context,
            'Gagal mereset waktu sinkronisasi: $e',
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
      body: FutureBuilder<SettingsModel>(
        future: _futureSettings,
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
            final pengaturan = snapshot.data;
            Log.info('Data pengaturan tersedia, menampilkan detail pengaturan');
            Log.info(
              'Mode pemeliharaan: ${pengaturan!.maintenanceMode ? "Aktif" : "Nonaktif"}, Info: ${pengaturan.maintenanceInfo.isNotEmpty ? pengaturan.maintenanceInfo : "(kosong)"}',
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
                          nilai: '${pengaturan.autoSyncInterval} Jam',
                          ikon: Icons.sync,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoCard(
                          judul: 'Hapus Arsip Otomatis',
                          nilai: '${pengaturan.autoDeleteArchiveDays} Hari',
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
                                  pengaturan.maintenanceMode
                                      ? 'Aplikasi dalam mode pemeliharaan'
                                      : 'Aplikasi berjalan normal',
                                ),
                                value: pengaturan.maintenanceMode,
                                onChanged: null, // Read-only di halaman ini
                                secondary: Icon(
                                  pengaturan.maintenanceMode
                                      ? Icons.construction
                                      : Icons.check_circle_outline,
                                  color: pengaturan.maintenanceMode
                                      ? Colors.orange
                                      : Colors.green,
                                ),
                              ),
                              if (pengaturan.maintenanceMode)
                                ListTile(
                                  leading: const Icon(Icons.info_outline),
                                  title: const Text(
                                    'Info Pemeliharaan',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    pengaturan.maintenanceInfo.isNotEmpty
                                        ? pengaturan.maintenanceInfo
                                        : '(Tidak ada pesan diatur)',
                                  ),
                                  isThreeLine: true,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Tombol Reset Waktu Sinkronisasi
                        ElevatedButton.icon(
                          icon: const Icon(Icons.sync_problem),
                          label: const Text('Reset Waktu Sinkronisasi'),
                          onPressed: _resetSyncTime,
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
                      await _editSettings(pengaturan);
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
