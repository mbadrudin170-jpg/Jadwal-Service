// path: lib/user/page/kritik_dan_saran.dart
// diubah: Memperbaiki urutan argumen saat memanggil KritikSaranModel.fromFirebase.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wifi/shared/model/kritik_saran_model.dart';
import 'package:wifi/user/page/form_kritik_dan_saran.dart';

class RiwayatKritikDanSaranPage extends StatelessWidget {
  final String userId;

  const RiwayatKritikDanSaranPage({super.key, required this.userId});

  void _showOptionsDialog(BuildContext context, KritikSaranModel kritik) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pilih Aksi'),
          content: const Text(
            'Apa yang ingin Anda lakukan dengan masukan ini?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _showDeleteConfirmationDialog(context, kritik.id);
              },
            ),
            TextButton(
              child: const Text('Edit'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FormKritikDanSaran(
                      userId: userId,
                      kritikId: kritik.id,
                      initialValue: kritik.isi,
                    ),
                  ),
                );
              },
            ),
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus masukan ini? Tindakan ini tidak dapat diurungkan.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Ya, Hapus',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteKritik(context, docId);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteKritik(BuildContext context, String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('kritik_saran')
          .doc(docId)
          .delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Masukan berhasil dihapus.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus masukan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Masukan'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('kritik_saran')
            .where('userId', isEqualTo: userId)
            .orderBy('tanggal', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('Terjadi kesalahan saat memuat data.'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'Anda belum pernah mengirim masukan.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final kritiks = snapshot.data!.docs
              .map((doc) => KritikSaranModel.fromFirebase(
                  doc.id, doc.data() as Map<String, dynamic>))
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: kritiks.length,
            itemBuilder: (context, index) {
              final kritik = kritiks[index];
              final formattedDate = DateFormat.yMMMMd(
                'id_ID',
              ).add_jm().format(kritik.tanggal);

              final formattedUpdatedDate = kritik.diperbarui != null
                  ? ' (diperbarui: ${DateFormat.yMMMMd('id_ID').add_jm().format(kritik.diperbarui!)})'
                  : '';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  onTap: () => _showOptionsDialog(context, kritik),
                  leading: const Icon(
                    Icons.feedback_outlined,
                    color: Colors.blueAccent,
                  ),
                  title: Text(kritik.isi),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '$formattedDate$formattedUpdatedDate',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FormKritikDanSaran(userId: userId),
            ),
          );
        },
        icon: const Icon(Icons.add_comment_outlined),
        label: const Text('Beri Masukan'),
        tooltip: 'Beri Masukan Baru',
      ),
    );
  }
}
