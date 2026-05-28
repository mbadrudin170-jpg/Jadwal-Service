// path: lib/shared/debug/global_key.dart
import 'package:flutter/material.dart';

/// Kunci global untuk mengakses ScaffoldMessenger dari mana saja.
/// INI HANYA UNTUK DEBUGGING SEMENTARA.
/// Hapus file ini dan penggunaannya setelah selesai debugging.
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
