// path: lib/user/page/info_apk_page_user.dart


import 'dart:async';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wifi/admin/halaman/tes/halaman_tes.dart';
import 'package:wifi/shared/export/theme.dart';

class InfoApkPageUser extends StatefulWidget {
  const InfoApkPageUser({super.key});

  @override
  State<InfoApkPageUser> createState() => _InfoApkPageUserState();
}

class _InfoApkPageUserState extends State<InfoApkPageUser> {
  String _version = '...';

  @override
  void initState() {
    super.initState();
    unawaited(_initPackageInfo());
  }

  Future<void> _initPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _version = packageInfo.version.split('-').first;
      });
    }
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Info Aplikasi'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  unawaited(Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (final context) => const HalamanTes(),
                    ),
                  ));
                },
                child: const Text('Pergi ke Detail'),
              ),
              TextButton(
                onPressed: () {
                  showLicensePage(context: context);
                },
                child: const Text('Lihat Lisensi'),
              ),
              const Text(
                'Aplikasi Pelanggan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              gapH8,
              Text(
                'Versi $_version',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              gapH24,
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/image/ikon_apk.png'),
              ),
              gapH24,
              const Text(
                'Dibuat dengan Flutter',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
