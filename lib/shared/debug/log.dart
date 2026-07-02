// path: lib/shared/debug/log.dart
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

const String _green = '\x1B[38;5;76m';
const String _reset = '\x1B[0m';
const String _red = '\x1B[31m';
const String _yellow = '\x1B[33m';
const String _cyan = '\x1B[36m';

final Random _random = Random();

String _buatKodeUnik() {
  const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  return String.fromCharCodes(
    Iterable.generate(
      6,
      (final _) => chars.codeUnitAt(_random.nextInt(chars.length)),
    ),
  );
}

String _formatData(final Object? data) {
  if (data == null) return '';

  Object? customEncoder(final Object? object) {
    if (object is DateTime) {
      return object.toIso8601String();
    }
    if (object is Timestamp) {
      return object.toDate().toIso8601String();
    }
    try {
      return (object as dynamic).toJson();
    } on Exception {
      return object.toString();
    }
  }

  try {
    if (data is Map || data is List) {
      final encoder = JsonEncoder.withIndent('  ', customEncoder);
      return '\nData: ${encoder.convert(data)}';
    }
    return '\nData: $data';
  } on Exception {
    return '\nData: $data';
  }
}

/// Mencatat pesan informasi.
void info(final String message, [final Object? data]) {
  _logCustom(
    message: '$message${_formatData(data)}',
    name: '✅',
    color: _green,
    level: 800,
  );
}

/// Mencatat pesan peringatan.
void warning(final String message, [final Object? data]) {
  _logCustom(
    message: '$message${_formatData(data)}',
    name: '⚠️',
    color: _yellow,
    level: 900,
  );
}

/// Mencatat pesan error.
void gagal(
  final String message, {
  final Object? e,
  final StackTrace? s,
  final Object? data,
}) {
  _logCustom(
    message: '$message${_formatData(data)}',
    name: '❌',
    color: _red,
    level: 1000,
    e: e,
    st: s,
  );
}

/// Mencatat panggilan API.
void api(
  final String path,
  final Map<String, dynamic> data, {
  required final String method,
}) {
  final String id = _buatKodeUnik();
  _logCustom(
    message: '[$method][$id] $path${_formatData(data)}',
    name: '🌐',
    color: _cyan,
    level: 500,
  );
}

void _logCustom({
  required final String message,
  required final String name,
  required final String color,
  required final int level,
  final Object? e,
  final StackTrace? st,
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
    '$color$message - $location$_reset',
    name: name,
    level: level,
    time: DateTime.now(),
    error: e,
    stackTrace: st,
  );
}
