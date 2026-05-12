
import 'package:flutter/material.dart';

class InfoApkPage extends StatelessWidget {
  const InfoApkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Info Aplikasi'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Aplikasi Pelanggan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Versi 1.0.0',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Aplikasi ini dibuat untuk memudahkan pelanggan dalam mengelola langganan dan mendapatkan informasi terbaru.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
