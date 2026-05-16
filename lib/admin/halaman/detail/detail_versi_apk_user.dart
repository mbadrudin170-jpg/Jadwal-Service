// path: lib/admin/halaman/detail/detail_versi_apk_user.dart
//
// 📂 FILE INI DIGUNAKAN OLEH:
//   - lib/admin/halaman/lainnya/versi_apk_user.dart
//
// 📂 FILE INI MENGGUNAKAN:
//   - lib/admin/halaman/form/apk_version_form.dart (ApkVersionForm)
//   - lib/shared/model/apk_version_model.dart (ApkVersionModel)
//   - lib/shared/debug/log.dart (Log)

import 'package:flutter/material.dart';
import 'package:wifi/admin/halaman/form/apk_version_form.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/apk_version_model.dart';

/// Halaman untuk menampilkan detail dari sebuah versi APK.
class DetailVersiApkUser extends StatelessWidget {
  /// Model versi APK yang akan ditampilkan.
  final ApkVersionModel apkVersion;

  /// Konstruktor untuk DetailVersiApkUser.
  const DetailVersiApkUser({
    super.key,
    required this.apkVersion,
  });

  @override
  Widget build(final BuildContext context) {
    Log.info(
      'Membangun halaman detail versi APK dengan versi terbaru: ${apkVersion.latestVersion}.',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Versi APK'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Data',
            onPressed: () async {
              Log.info(
                'Pengguna menekan tombol edit untuk versi APK: ${apkVersion.latestVersion}.',
              );

              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (final context) {
                    Log.info(
                      'Membangun halaman ApkVersionForm untuk proses edit.',
                    );
                    return ApkVersionForm(apkVersion: apkVersion);
                  },
                ),
              );

              Log.info(
                'Halaman form edit versi APK selesai ditutup dengan hasil: $result.',
              );

              if ((result ?? false) && context.mounted) {
                Log.info(
                  'Berhasil edit data versi APK dan mengirim sinyal refresh ke halaman sebelumnya.',
                );
                Navigator.pop(context, true);
                Log.info(
                  'Berhasil kembali ke halaman sebelumnya dengan status refresh.',
                );
              } else {
                Log.warning(
                  'Tidak ada perubahan data versi APK atau widget sudah tidak mounted.',
                );
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildInfoRow('Versi Terbaru', apkVersion.latestVersion),
          _buildInfoRow(
              'Wajib Update', apkVersion.isUpdateRequired ? 'Ya' : 'Tidak'),
          _buildInfoRow('Catatan Rilis', apkVersion.releaseNotes),
          const SizedBox(height: 16),
          const Text(
            'Nomor Build Terbaru',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          ...apkVersion.latestBuildNumber.entries.map(
            (final entry) {
              Log.info(
                'Menampilkan nomor build untuk arsitektur: ${entry.key.name} dengan nilai: ${entry.value}.',
              );
              return _buildInfoRow(entry.key.name, entry.value.toString());
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Tautan Unduhan',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          ...apkVersion.downloadLinks.entries.map(
            (final entry) {
              Log.info(
                'Menampilkan tautan unduhan untuk arsitektur: ${entry.key.name}.',
              );
              return _buildInfoRow(entry.key.name, entry.value);
            },
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Youtube Tutorial', apkVersion.youtubeTutorial),
        ],
      ),
    );
  }

  Widget _buildInfoRow(final String label, final String value) {
    Log.info('Membangun info row dengan label: $label dan value: $value.');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Text(': '),
          Flexible(child: Text(value)),
        ],
      ),
    );
  }
}
