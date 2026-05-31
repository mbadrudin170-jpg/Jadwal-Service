// path: lib/admin/halaman/lainnya/settings_page_a.dart
// REFAKTOR: Mengubah StatefulWidget menjadi ConsumerWidget, menggunakan FutureProvider
// untuk data asinkron, dan mengakses semua dependensi (ThemeProvider, SyncManager) melalui Riverpod.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/admin/halaman/form/settings_form.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/model/settings_model.dart';
import 'package:wifi/shared/operasi/settings_operation.dart';
import 'package:wifi/shared/utils/sync_manager.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/user/widget/theme_menu_widget.dart';

/// Halaman untuk menampilkan dan mengelola konfigurasi pengaturan aplikasi.
class SettingsAdminPage extends ConsumerWidget {
  const SettingsAdminPage({super.key});

  // Fungsi untuk menavigasi ke halaman form edit dan memuat ulang data jika ada perubahan.
  Future<void> _editSettings(
    BuildContext context,
    WidgetRef ref,
    SettingsModel currentSettings,
  ) async {
    Log.info('Navigasi ke halaman Form Edit Pengaturan');
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsForm(settings: currentSettings),
      ),
    );

    if (result == true && context.mounted) {
      Log.info('Pengaturan diperbarui, memuat ulang data...');
      // Invalidate provider untuk memicu pembaruan data
      ref.invalidate(settingsOperationProvider);
    }
  }

  // Fungsi untuk mereset waktu sinkronisasi
  Future<void> _resetSyncTime(BuildContext context, WidgetRef ref) async {
    Log.info('Tombol Reset Waktu Sinkronisasi ditekan.');
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
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

    if (confirm == true && context.mounted) {
      try {
        // Mengakses SyncManager melalui provider
        await ref.read(syncManagerProvider).resetSyncTime();
        ToastUtil.success(context, 'Waktu sinkronisasi berhasil di-reset.');
      } on Exception catch (e, st) {
        Log.error('Gagal mereset waktu sinkronisasi', e: e, st: st);
        ToastUtil.error(context, 'Gagal mereset waktu sinkronisasi: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Log.info('Membangun UI halaman Pengaturan Aplikasi');
    final settingsAsyncValue = ref.watch(settingsOperationProvider);
    final currentThemeMode = ref.watch(themeProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Aplikasi'),
      ),
      body: settingsAsyncValue.when(
        data: (settings) {
          Log.info('Data pengaturan tersedia, menampilkan detail.');
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      _buildInfoCard(
                        judul: 'Sinkronisasi Otomatis',
                        nilai: '${settings.autoSyncInterval} Jam',
                        ikon: Icons.sync,
                        context: context,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        judul: 'Hapus Arsip Otomatis',
                        nilai: '${settings.autoDeleteArchiveDays} Hari',
                        ikon: Icons.auto_delete_outlined,
                        context: context,
                      ),
                      const Divider(height: 24, thickness: 1),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 15),
                          leading: const Icon(Icons.palette_outlined, size: 40),
                          title: const Text('Mode Tema Aplikasi',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          trailing: ThemeMenuWidget(
                            currentThemeMode:
                                currentThemeMode.value ?? ThemeMode.system,
                            onThemeSelected: (theme) {
                              ref
                                  .read(themeProvider.notifier)
                                  .setThemeMode(theme);
                            },
                          ),
                        ),
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
                                settings.maintenanceMode
                                    ? 'Aplikasi dalam mode pemeliharaan'
                                    : 'Aplikasi berjalan normal',
                              ),
                              value: settings.maintenanceMode,
                              onChanged: null, // Read-only
                              secondary: Icon(
                                settings.maintenanceMode
                                    ? Icons.construction
                                    : Icons.check_circle_outline,
                                color: settings.maintenanceMode
                                    ? Colors.orange
                                    : Colors.green,
                              ),
                            ),
                            if (settings.maintenanceMode)
                              ListTile(
                                leading: const Icon(Icons.info_outline),
                                title: const Text(
                                  'Info Pemeliharaan',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  settings.maintenanceInfo.isNotEmpty
                                      ? settings.maintenanceInfo
                                      : '(Tidak ada pesan diatur)',
                                ),
                                isThreeLine: true,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.sync_problem),
                        label: const Text('Reset Waktu Sinkronisasi'),
                        onPressed: () => _resetSyncTime(context, ref),
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
                  onPressed: () => _editSettings(context, ref, settings),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          Log.error(
            'Gagal memuat pengaturan',
            e: error,
            st: stackTrace,
          );
          return Center(child: Text('Error: $error'));
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required String judul,
    required String nilai,
    required IconData ikon,
    required BuildContext context,
  }) {
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
