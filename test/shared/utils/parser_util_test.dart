// path: test/shared/utils/parser_util_test.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/shared/utils/parser_util.dart';

void main() {
  group('ParserUtil.parseDateTime', () {
    // Referensi waktu yang konsisten untuk pengujian
    final referenceTime = DateTime(2024, 8, 17, 10, 30);

    test('harus mengembalikan null jika input null', () {
      expect(ParserUtil.parseDateTime(null), isNull);
    });

    test('harus mengurai dari Timestamp Firestore', () {
      final timestamp = Timestamp.fromDate(referenceTime);
      expect(ParserUtil.parseDateTime(timestamp), referenceTime);
    });

    test('harus mengurai dari int (millisecondsSinceEpoch)', () {
      final milliseconds = referenceTime.millisecondsSinceEpoch;
      expect(ParserUtil.parseDateTime(milliseconds), referenceTime);
    });

    test('harus mengurai dari String ISO 8601', () {
      final isoString = referenceTime.toIso8601String();
      expect(ParserUtil.parseDateTime(isoString), referenceTime);
    });

    test('harus mengembalikan DateTime yang sudah ada', () {
      expect(ParserUtil.parseDateTime(referenceTime), referenceTime);
    });

    test('harus mengembalikan null untuk String format tidak valid', () {
      expect(ParserUtil.parseDateTime('17-08-2024'), isNull);
    });

    test('harus mengembalikan null untuk tipe data tidak dikenal', () {
      expect(ParserUtil.parseDateTime(123.45), isNull);
    });
  });

  group('ParserUtil.parseBool', () {
    test('harus mengembalikan false jika input null', () {
      expect(ParserUtil.parseBool(null), isFalse);
    });

    test('harus mengembalikan nilai bool yang sudah ada (true)', () {
      expect(ParserUtil.parseBool(true), isTrue);
    });

    test('harus mengembalikan nilai bool yang sudah ada (false)', () {
      expect(ParserUtil.parseBool(false), isFalse);
    });

    test('harus mengurai dari int (1 sebagai true)', () {
      expect(ParserUtil.parseBool(1), isTrue);
    });

    test('harus mengurai dari int (0 sebagai false)', () {
      expect(ParserUtil.parseBool(0), isFalse);
    });

    test('harus mengurai dari int (selain 1 sebagai false)', () {
      expect(ParserUtil.parseBool(2), isFalse);
      expect(ParserUtil.parseBool(-1), isFalse);
    });

    test('harus mengurai dari String "true" (case-insensitive)', () {
      expect(ParserUtil.parseBool('true'), isTrue);
      expect(ParserUtil.parseBool('True'), isTrue);
      expect(ParserUtil.parseBool('TRUE'), isTrue);
    });

    test('harus mengembalikan false untuk String selain "true"', () {
      expect(ParserUtil.parseBool('false'), isFalse);
      expect(ParserUtil.parseBool('yes'), isFalse);
      expect(ParserUtil.parseBool(''), isFalse);
    });

    test('harus mengembalikan false untuk tipe data tidak dikenal', () {
      expect(ParserUtil.parseBool(123.45), isFalse);
      expect(ParserUtil.parseBool(['true']), isFalse);
    });
  });
}
