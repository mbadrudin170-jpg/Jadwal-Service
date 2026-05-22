// path: lib/admin/halaman/detail/package_detail.dart
//
// 📂 FILE INI DIGUNAKAN OLEH:
//   - lib/admin/halaman/lainnya/package.dart
//   - lib/admin/halaman/detail/subscription_history_detail.dart (DetailLanggananTransaksiPage)
//
// 📂 FILE INI MENGGUNAKAN:
//   - lib/admin/halaman/form/package_form.dart (PackageForm)
//   - lib/shared/model/package_model.dart (PackageModel)
//   - lib/shared/debug/log.dart (Log)

import 'package:flutter/material.dart';
import 'package:wifi/admin/halaman/form/package_form.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/package_model.dart';

/// Halaman untuk menampilkan detail dari sebuah paket.
class PackageDetailPage extends StatefulWidget {
  /// Model paket yang akan ditampilkan.
  final PackageModel package;

  /// Konstruktor untuk PackageDetailPage.
  const PackageDetailPage({
    super.key,
    required this.package,
  });

  @override
  State<PackageDetailPage> createState() => _PackageDetailPageState();
}

class _PackageDetailPageState extends State<PackageDetailPage> {
  late PackageModel _package;

  @override
  void initState() {
    super.initState();
    Log.info('Membuka halaman detail paket.');
    _package = widget.package;
    Log.info(
        'Data paket berhasil dimuat: ${_package.name}, ID: ${_package.id}.');
  }

  Future<void> _editPackage() async {
    Log.info('Navigasi ke form edit paket: ${_package.name}.');
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (final context) => PackageForm(package: _package),
      ),
    );

    if (result ?? false) {
      Log.info('Perubahan data paket terdeteksi.');
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_package.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: _editPackage,
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Paket',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.inventory_2, color: Colors.blueAccent),
                    const SizedBox(width: 8),
                    Text(
                      'Informasi Layanan',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildDetailRow('Nama Paket', _package.name),
                _buildDetailRow('Harga Sewa', 'Rp ${_package.price}'),
                _buildDetailRow(
                    'Masa Aktif', '${_package.duration} ${_package.type.displayName}'),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(thickness: 1),
                ),
                Row(
                  children: [
                    const Icon(Icons.stars, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(
                      'Sistem Poin',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDetailRow('Poin Hadiah', '${_package.rewardPoints} Poin',
                    subTitle: 'Didapat saat beli paket'),
                _buildDetailRow(
                    'Poin Penukaran', '${_package.redemptionPoints} Poin',
                    subTitle: 'Syarat tukar gratis'),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(thickness: 1),
                ),
                _buildDetailRow(
                  'Status Publik',
                  _package.isPublic ? 'Tersedia di Aplikasi' : 'Hanya Admin',
                  customValueColor:
                      _package.isPublic ? Colors.green : Colors.red,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    final String label,
    final String value, {
    final String? subTitle,
    final Color? customValueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
                if (subTitle != null)
                  Text(subTitle,
                      style: const TextStyle(
                          color: Colors.black38,
                          fontSize: 11,
                          fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: customValueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
