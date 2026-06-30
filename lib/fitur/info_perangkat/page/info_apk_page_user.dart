// path: lib/fitur/info_perangkat/page/info_apk_page_user.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/toast_util.dart';

class InfoApkPageUser extends StatefulWidget {
  const InfoApkPageUser({super.key});

  @override
  State<InfoApkPageUser> createState() => _InfoApkPageUserState();
}

class _InfoApkPageUserState extends State<InfoApkPageUser> {
  String _versi = '...';

  @override
  void initState() {
    super.initState();
    unawaited(_initPackageInfo());
  }

  Future<void> _initPackageInfo() async {
    try {
      final infoPerangkat = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _versi = infoPerangkat.version.split('-').first;
        });
      }
    } on Exception catch (e, st) {
      Log.error('Gagal mengambil info package', e: e, s: st);
      if (mounted) {
        ToastUtil.error(context, 'Gagal memuat versi aplikasi');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Info Aplikasi')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  showLicensePage(context: context);
                },
                child: const Text('Lihat Lisensi'),
              ),
              const Text(
                'Aplikasi Pelanggan',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              gapH8,
              Text(
                'Versi $_versi',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              gapH24,
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/image/ikon_apk.png'),
              ),
              gapH24,
              const Text(
                'Dibuat dengan Flutter',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
