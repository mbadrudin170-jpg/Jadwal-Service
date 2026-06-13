// path: lib/fitur/background/alarm_utils.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/services/arsipkan_langganan_kadaluarsa_service.dart';

/// Callback untuk alarm yang dieksekusi di background isolate.
@pragma('vm:entry-point')
Future<void> alarmCallback() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Log.info('ALARM TERPICU: Memulai proses pengecekan langganan kedaluwarsa...');
  final container = ProviderContainer();
  try {
    final service = container.read(arsipLanggananKadaluarsaServiceProvider);
    await service.prosesArsipLanggananKadaluarsa();
  } finally {
    container.dispose();
  }
  Log.info('ALARM SELESAI: Proses pengecekan langganan kedaluwarsa selesai.');
}
