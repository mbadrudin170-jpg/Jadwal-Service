// path: lib/screens/update_check_screen.dart

import 'package:flutter/material.dart';
import 'package:wifi/services/apk_version_service.dart';
import 'package:wifi/shared/model/apk_version_model.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateCheckScreen extends StatefulWidget {
  const UpdateCheckScreen({super.key});

  @override
  State<UpdateCheckScreen> createState() => _UpdateCheckScreenState();
}

class _UpdateCheckScreenState extends State<UpdateCheckScreen> {
  final ApkVersionService _apkVersionService = ApkVersionService();
  Future<ApkVersionModel?>? _versionFuture;

  @override
  void initState() {
    super.initState();
    _fetchLatestVersion();
  }

  void _fetchLatestVersion() {
    setState(() {
      _versionFuture = _apkVersionService.getLatestVersion();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cek Pembaruan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchLatestVersion,
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder<ApkVersionModel?>(
          future: _versionFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (snapshot.hasError) {
              return Text('Terjadi kesalahan: ${snapshot.error}');
            }

            final version = snapshot.data;
            if (version == null) {
              return const Text('Tidak ada informasi pembaruan tersedia.');
            }

            return _buildVersionInfoCard(context, version);
          },
        ),
      ),
    );
  }

  Widget _buildVersionInfoCard(BuildContext context, ApkVersionModel version) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Versi Terbaru: ${version.latestVersion}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            if (version.releaseNotes.isNotEmpty)
              Text(
                'Catatan Rilis:\n${version.releaseNotes}',
              ),
            const SizedBox(height: 16),
            if (version.isUpdateRequired)
              const Text(
                'Pembaruan ini wajib diinstal.',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (version.downloadLinks.isNotEmpty) {
                    final downloadLink =
                        version.downloadLinks.entries.first.value;
                    final uri = Uri.parse(downloadLink);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('Tidak bisa membuka link: $downloadLink')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.download),
                label: const Text('Unduh Sekarang'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
