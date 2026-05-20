// path: lib/admin/halaman/tes/halaman_tes.dart
import 'package:flutter/material.dart';
import 'package:wifi/shared/utils/toast_util.dart';

/// Halaman untuk melakukan tes tampilan dari berbagai jenis Toast.
class HalamanTes extends StatelessWidget {
  /// Membuat instance dari [HalamanTes].
  const HalamanTes({super.key});

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Halaman Uji Toast'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () {
                  ToastUtil.success(
                    context,
                    'Ini adalah contoh notifikasi sukses.',
                    logData: {'info': 'Tombol sukses ditekan'},
                  );
                },
                child: const Text('Tampilkan Toast Sukses'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  ToastUtil.error(
                    context,
                    'Ini adalah contoh notifikasi error.',
                    logData: {'info': 'Tombol error ditekan'},
                  );
                },
                child: const Text('Tampilkan Toast Error'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                onPressed: () {
                  ToastUtil.warning(
                    context,
                    'Ini adalah contoh notifikasi peringatan.',
                    logData: {'info': 'Tombol peringatan ditekan'},
                  );
                },
                child: const Text('Tampilkan Toast Peringatan'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: () {
                  ToastUtil.info(
                    context,
                    'Ini adalah contoh notifikasi informasi.',
                    logData: {'info': 'Tombol info ditekan'},
                  );
                },
                child: const Text('Tampilkan Toast Info'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
