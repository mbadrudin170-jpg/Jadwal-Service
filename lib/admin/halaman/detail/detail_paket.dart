// path: lib/admin/halaman/detail/detail_paket.dart
import 'package:flutter/material.dart';
import 'package:wifi/admin/halaman/form/form_paket.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/paket_model.dart';

/// Halaman untuk menampilkan detail dari sebuah paket.
class DetailPaketPage extends StatefulWidget {
  /// Model paket yang akan ditampilkan.
  final PaketModel paket;

  /// Konstruktor untuk DetailPaketPage.
  const DetailPaketPage({
    super.key,
    required this.paket,
  });

  @override
  State<DetailPaketPage> createState() => _DetailPaketPageState();
}

class _DetailPaketPageState extends State<DetailPaketPage> {
  late PaketModel _paket;

  @override
  void initState() {
    super.initState();

    Log.info(
      'Membuka halaman detail paket.',
    );

    _paket = widget.paket;

    Log.info(
      'Data paket berhasil dimuat dengan nama paket: ${_paket.nama} dan ID: ${_paket.id}.',
    );
  }

  Future<void> _editPaket() async {
    Log.info(
      'Memulai navigasi ke halaman form edit paket untuk paket: ${_paket.nama}.',
    );

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (final context) {
          Log.info(
            'Membangun halaman FormPaket untuk proses edit.',
          );

          return FormPaket(
            paket: _paket,
          );
        },
      ),
    );

    Log.info(
      'Halaman edit paket selesai ditutup dengan hasil: $result.',
    );

    if (result ?? false) {
      Log.info(
        'Terdeteksi perubahan data paket setelah proses edit.',
      );

      if (mounted) {
        Log.info(
          'Widget masih mounted. Mengirim sinyal refresh ke halaman sebelumnya.',
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
          'Widget sudah tidak mounted saat ingin kembali ke halaman sebelumnya.',
        );
      }
    } else {
      Log.warning(
        'Pengguna membatalkan edit atau tidak ada perubahan data paket.',
      );
    }
  }

  @override
  Widget build(final BuildContext context) {
    Log.info(
      'Membangun UI halaman detail paket.',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _paket.nama,
        ),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Log.info(
              'Pengguna menekan tombol kembali pada halaman detail paket.',
            );

            Navigator.pop(context);

            Log.info(
              'Berhasil kembali ke halaman sebelumnya.',
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: _editPaket,
            icon: const Icon(
              Icons.edit,
            ),
            tooltip: 'Edit Paket',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(
          16.0,
        ),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              12,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(
              20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.inventory_2,
                      color: Colors.blueAccent,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      'Informasi Layanan',
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                _buildDetailRow(
                  'Nama Paket',
                  _paket.nama,
                ),
                _buildDetailRow(
                  'Harga Sewa',
                  'Rp ${_paket.harga}',
                ),
                _buildDetailRow(
                  'Masa Aktif',
                  '${_paket.durasi} ${_paket.tipe.name}',
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 8.0,
                  ),
                  child: Divider(
                    thickness: 1,
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.stars,
                      color: Colors.orange,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      'Sistem Poin',
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),
                _buildDetailRow(
                  'Poin Hadiah',
                  '${_paket.poinHadiah} Poin',
                  subTitle: 'Didapat saat beli paket',
                ),
                _buildDetailRow(
                  'Poin Penukaran',
                  '${_paket.poinPenukaran} Poin',
                  subTitle: 'Syarat tukar gratis',
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 8.0,
                  ),
                  child: Divider(
                    thickness: 1,
                  ),
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
    Log.info(
      'Membangun detail row dengan label: $label dan value: $value.',
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
                if (subTitle != null)
                  Text(
                    subTitle,
                    style: const TextStyle(
                      color: Colors.black38,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
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
