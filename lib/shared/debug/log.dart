// path: lib/shared/debug/log.dart
import 'dart:convert'; // Tambahkan untuk memformat data Map/List
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';

/// Kelas utilitas untuk logging yang terstruktur dan berwarna selama pengembangan.
///
/// Menyediakan metode logging untuk berbagai level: info, warning, error, dan api.
/// Log hanya akan muncul dalam mode debug.
class Log {
  static const String _green = '\x1B[38;5;76m';
  static const String _reset = '\x1B[0m';
  static const String _red = '\x1B[31m';
  static const String _yellow = '\x1B[33m';
  static const String _cyan = '\x1B[36m';

  /// Helper untuk memformat data agar rapi jika berupa Map atau List.
  static String _formatData(Object? data) {
    if (data == null) return '';
    try {
      if (data is Map || data is List) {
        // Menggunakan JsonEncoder agar tampilan di console berbaris rapi (pretty print)
        return '\nData: ${const JsonEncoder.withIndent('  ').convert(data)}';
      }
      return '\nData: $data';
    } on Exception catch (_) {
      return '\nData: $data';
    }
  }

  /// Mencatat pesan informasi.
  ///
  /// Pesan akan berwarna hijau dan memiliki level 800.
  /// `data` opsional dapat dilewatkan untuk dicetak dalam format JSON yang rapi.
  static void info(String message, [Object? data]) {
    _logCustom(
      '$message${_formatData(data)}',
      name: '✅',
      color: _green,
      level: 800,
    );
  }

  /// Mencatat pesan peringatan.
  ///
  /// Pesan akan berwarna kuning dan memiliki level 900.
  /// `data` opsional dapat dilewatkan untuk dicetak.
  static void warning(String message, [Object? data]) {
    _logCustom(
      '$message${_formatData(data)}',
      name: '⚠️',
      color: _yellow,
      level: 900,
    );
  }

  /// Mencatat pesan error.
  ///
  /// Pesan akan berwarna merah dan memiliki level 1000.
  /// `e` (exception) dan `st` (stack trace) opsional dapat dilewatkan.
  static void error(
    String message, {
    Object? e,
    StackTrace? st,
    Object? data,
  }) {
    _logCustom(
      '$message${_formatData(data)}',
      name: '❌',
      color: _red,
      level: 1000,
      e: e,
      st: st,
    );
  }

  /// Mencatat pesan yang berhubungan dengan panggilan API atau Firestore.
  ///
  /// `path` adalah endpoint atau path koleksi.
  /// `data` adalah payload atau data yang dikembalikan.
  /// `method` adalah metode HTTP (GET, POST, dll.) atau operasi Firestore (SET, UPDATE).
  static void api(
    String path,
    Map<String, dynamic> data, {
    required String method,
  }) {
    _logCustom(
      '[$method] $path${_formatData(data)}',
      name: '🌐',
      color: _cyan,
      level: 500,
    );
  }

  /// Metode internal untuk melakukan logging kustom.
  ///
  /// Mengambil detail pemanggil dari stack trace untuk memberikan lokasi log yang tepat.
  static void _logCustom(
    String message, {
    required String name,
    required String color,
    required int level,
    Object? e,
    StackTrace? st,
  }) {
    if (!kDebugMode) return;

    final trace = StackTrace.current.toString().split('\n');
    final String callerRow = trace.length > 2 ? trace[2] : 'Unknown';
    final match = RegExp(r'#2\s+(.+)\s+\((.+)\)').firstMatch(callerRow);

    String location = '';
    if (match != null) {
      final methodCaller = match.group(1);
      final fileInfo = match.group(2);
      location = '[ $methodCaller ] - $fileInfo';
    }

    dev.log(
      '$color $message - $location$_reset',
      name: name,
      level: level,
      time: DateTime.now(),
      error: e,
      stackTrace: st,
    );
  }
}
