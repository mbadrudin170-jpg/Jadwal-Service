// path: lib/fitur/settings/page/settings_page_a.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/settings/model/settings_model.dart';
import 'package:wifi/fitur/settings/page/form_settings.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/sync_manager.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/user/widget/theme_menu_widget.dart';

final settingsProvider = FutureProvider<SettingsModel>((ref) async {
  final settingsOp = ref.read(settingsOpSqliteProvider);
  return await settingsOp.getSettings();
});

class SettingsAdminPage extends ConsumerWidget {
  const SettingsAdminPage({super.key});

  Future<void> _editSettings(
    BuildContext context,
    WidgetRef ref,
    SettingsModel settings,
  ) async {
    Log.info('Navigasi ke halaman Form Edit Pengaturan');
    final hasil = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => FormSettings(settings: settings),
      ),
    );

    if ((hasil ?? false) && context.mounted) {
      Log.info('Pengaturan diperbarui, memuat ulang data...');
      ref.invalidate(settingsOpSqliteProvider);
    }
  }

  Future<void> _resetWaktuSinkroniasi(
      BuildContext context, WidgetRef ref) async {
    Log.info('Tombol Reset Waktu Sinkronisasi ditekan.');
    final konfirmasi = await showDialog<bool>(
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

    if ((konfirmasi ?? false) && context.mounted) {
      try {
        await ref.read(syncManagerProvider).resetWaktuSinkronisasi();
        if (context.mounted) {
          ToastUtil.success(context, 'Waktu sinkronisasi berhasil di-reset.');
        }
      } on Exception catch (e, st) {
        Log.error('Gagal mereset waktu sinkronisasi', e: e, s: st);
        if (context.mounted) {
          ToastUtil.error(context, 'Gagal mereset waktu sinkronisasi: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Log.info('Membangun UI halaman Pengaturan Aplikasi');
    final settingsAsyncValue = ref.watch(settingsProvider);
    final tema = ref.watch(temaProvider);
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
                        nilai: '${settings.waktuOtomatisSinkroniasi} Jam',
                        ikon: Icons.sync,
                        context: context,
                      ),
                      gapH12,
                      _buildInfoCard(
                        judul: 'Hapus Arsip Otomatis',
                        nilai: '${settings.waktuOtomatisHapusDataArsip} Hari',
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
                            currentThemeMode: tema.value ?? ThemeMode.system,
                            onThemeSelected: (theme) async {
                              await ref
                                  .read(temaProvider.notifier)
                                  .simpanModeTema(theme);
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
                                settings.modeMaintenance
                                    ? 'Aplikasi dalam mode pemeliharaan'
                                    : 'Aplikasi berjalan normal',
                              ),
                              value: settings.modeMaintenance,
                              onChanged: null,
                              secondary: Icon(
                                settings.modeMaintenance
                                    ? Icons.construction
                                    : Icons.check_circle_outline,
                                color: settings.modeMaintenance
                                    ? Colors.orange
                                    : Colors.green,
                              ),
                            ),
                            if (settings.modeMaintenance)
                              ListTile(
                                leading: const Icon(Icons.info_outline),
                                title: const Text(
                                  'Info Pemeliharaan',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  settings.infoMaintenance.isNotEmpty
                                      ? settings.infoMaintenance
                                      : '(Tidak ada pesan diatur)',
                                ),
                                isThreeLine: true,
                              ),
                          ],
                        ),
                      ),
                      gapH16,
                      ElevatedButton.icon(
                        icon: const Icon(Icons.sync_problem),
                        label: const Text('Reset Waktu Sinkronisasi'),
                        onPressed: () => _resetWaktuSinkroniasi(context, ref),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                gapH16,
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
        error: (e, s) {
          Log.error(
            'Gagal memuat pengaturan',
            e: e,
            s: s,
          );
          return Center(child: Text('Error: $e'));
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
