// path: lib/admin/halaman/detail/detail_paket.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/admin/halaman/form/form_paket.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';

/// Halaman untuk menampilkan detail dari sebuah paket.
class DetailPaketPage extends ConsumerStatefulWidget {
  /// Model paket yang akan ditampilkan.
  final PaketModel paket;

  /// Konstruktor untuk PackageDetailPage.
  const DetailPaketPage({
    super.key,
    required this.paket,
  });

  @override
  ConsumerState<DetailPaketPage> createState() => _DetailPaketState();
}

class _DetailPaketState extends ConsumerState<DetailPaketPage> {
  late PaketModel _paket;

  @override
  void initState() {
    super.initState();
    Log.info('Membuka halaman detail paket.');
    _paket = widget.paket;
    Log.info('Data paket berhasil dimuat: ${_paket.name}, ID: ${_paket.id}.');
  }

  Future<void> _navigasiKeEdit() async {
    Log.info('Navigasi ke form edit paket: ${_paket.name}.');
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (final context) => FormPaket(paket: _paket),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_paket.name),
        actions: [
          IconButton(
            onPressed: _navigasiKeEdit,
            icon: const Icon(TIcons.edit),
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
                    gapH8,
                    Text(
                      'Informasi Layanan',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                gapH20,
                _buildDetailRow('Nama Paket', _paket.name),
                _buildDetailRow('Harga Sewa', 'Rp ${_paket.price}'),
                _buildDetailRow('Masa Aktif',
                    '${_paket.duration} ${_paket.type.displayName}'),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(thickness: 1),
                ),
                Row(
                  children: [
                    const Icon(TIcons.points, color: Colors.orange),
                    gapH8,
                    Text(
                      'Sistem Poin',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                gapH12,
                _buildDetailRow('Poin Hadiah', '${_paket.rewardPoints} Poin',
                    subTitle: 'Didapat saat beli paket'),
                _buildDetailRow(
                    'Poin Penukaran', '${_paket.redemptionPoints} Poin',
                    subTitle: 'Syarat tukar gratis'),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(thickness: 1),
                ),
                _buildDetailRow(
                  'Status Publik',
                  _paket.isPublic ? 'Tersedia di Aplikasi' : 'Hanya Admin',
                  customValueColor: _paket.isPublic ? Colors.green : Colors.red,
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
