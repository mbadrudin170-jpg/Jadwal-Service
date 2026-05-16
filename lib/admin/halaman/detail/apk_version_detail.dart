// path: lib/admin/halaman/detail/apk_version_detail.dart
//
// 📂 FILE INI DIGUNAKAN OLEH:
//   - lib/admin/halaman/lainnya/apk_version_page.dart
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
class ApkVersionDetailPage extends StatelessWidget {
  /// Model versi APK yang akan ditampilkan.
  final ApkVersionModel apkVersion;

  /// Konstruktor untuk ApkVersionDetailPage.
  const ApkVersionDetailPage({
    super.key,
    required this.apkVersion,
  });

  @override
  Widget build(final BuildContext context) {
    Log.info(
      'Membangun halaman detail versi APK: ${apkVersion.latestVersion}.',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Versi APK'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Data',
            onPressed: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (final context) =>
                      ApkVersionForm(apkVersion: apkVersion),
                ),
              );

              if ((result ?? false) && context.mounted) {
                Navigator.pop(context, true);
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
            (final entry) =>
                _buildInfoRow(entry.key.name, entry.value.toString()),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tautan Unduhan',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          ...apkVersion.downloadLinks.entries.map(
            (final entry) => _buildInfoRow(entry.key.name, entry.value),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Youtube Tutorial', apkVersion.youtubeTutorial),
        ],
      ),
    );
  }

  Widget _buildInfoRow(final String label, final String value) {
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
