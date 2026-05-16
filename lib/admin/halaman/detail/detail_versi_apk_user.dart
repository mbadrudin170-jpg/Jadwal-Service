// path: lib/admin/halaman/detail/detail_versi_apk_user.dart
import 'package:flutter/material.dart';
import 'package:wifi/admin/halaman/form/form_versi_apk_user.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/user_apk_version_model.dart';

/// Halaman untuk menampilkan detail dari sebuah versi APK.
class DetailVersiApkUser extends StatelessWidget {
  /// Model versi APK yang akan ditampilkan.
  final VersiApkUserModel versiApk;

  /// Konstruktor untuk DetailVersiApkUser.
  const DetailVersiApkUser({
    super.key,
    required this.versiApk,
  });

  @override
  Widget build(final BuildContext context) {
    Log.info(
      'Membangun halaman detail versi APK dengan versi terbaru: ${versiApk.versiTerbaru}.',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Versi APK',
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.edit,
            ),
            tooltip: 'Edit Data',
            onPressed: () async {
              Log.info(
                'Pengguna menekan tombol edit untuk versi APK: ${versiApk.versiTerbaru}.',
              );

              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (final context) {
                    Log.info(
                      'Membangun halaman FormVersiApkUser untuk proses edit.',
                    );

                    return FormVersiApkUser(
                      versiApkUser: versiApk,
                    );
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

                Navigator.pop(
                  context,
                  true,
                );

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
        padding: const EdgeInsets.all(
          16.0,
        ),
        children: [
          _buildInfoRow(
            'Versi Terbaru',
            versiApk.versiTerbaru,
          ),
          _buildInfoRow(
            'Wajib Update',
            versiApk.wajibUpdate ? 'Ya' : 'Tidak',
          ),
          _buildInfoRow(
            'Catatan Rilis',
            versiApk.catatanRilis,
          ),
          const SizedBox(
            height: 16,
          ),
          const Text(
            'Nomor Build Terbaru',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          ...versiApk.nomorBuildTerbaru.entries.map(
            (final entry) {
              Log.info(
                'Menampilkan nomor build untuk arsitektur: ${entry.key.name} dengan nilai: ${entry.value}.',
              );

              return _buildInfoRow(
                entry.key.name,
                entry.value.toString(),
              );
            },
          ),
          const SizedBox(
            height: 16,
          ),
          const Text(
            'Tautan Unduhan',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          ...versiApk.tautanUnduhan.entries.map(
            (final entry) {
              Log.info(
                'Menampilkan tautan unduhan untuk arsitektur: ${entry.key.name}.',
              );

              return _buildInfoRow(
                entry.key.name,
                entry.value,
              );
            },
          ),
          const SizedBox(
            height: 16,
          ),
          _buildInfoRow(
            'Youtube Tutorial',
            versiApk.youtubeTutorial,
          ),
        ],
      ),
    );
  }

  // untuk membangun baris informasi
  Widget _buildInfoRow(
    final String label,
    final String value,
  ) {
    Log.info(
      'Membangun info row dengan label: $label dan value: $value.',
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Text(
            ': ',
          ),
          Flexible(
            child: Text(
              value,
            ),
          ),
        ],
      ),
    );
  }
}
