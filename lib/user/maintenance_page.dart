// path: lib/user/maintenance_page.dart
import 'package:flutter/material.dart';

class MaintenancePage extends StatelessWidget {
  final String maintenanceInfo;

  const MaintenancePage({super.key, required this.maintenanceInfo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aplikasi dalam Perbaikan'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 80,
                color: Colors.orange,
              ),
              const SizedBox(height: 24),
              Text(
                'Pemberitahuan Pemeliharaan',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                maintenanceInfo,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
