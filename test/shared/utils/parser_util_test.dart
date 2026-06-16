// path: test/shared/utils/parser_util_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/shared/utils/parser_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('ParserUtil', () {
    group('parseDateTime', () {
      // Buat tanggal uji yang presisinya hanya sampai milidetik untuk konsistensi
      final now = DateTime.now();
      final testDate =
          DateTime.fromMillisecondsSinceEpoch(now.millisecondsSinceEpoch);
      final timestamp = Timestamp.fromDate(testDate);

      test('01. harus mengembalikan null jika value null', () {
        expect(ParserUtil.parseDateTime(null), isNull);
      });

      test('02. harus mengonversi Timestamp ke DateTime', () {
        expect(ParserUtil.parseDateTime(timestamp), equals(testDate));
      });

      test('03. harus mengembalikan DateTime jika sudah DateTime', () {
        expect(ParserUtil.parseDateTime(testDate), equals(testDate));
      });

      test('04. harus mengonversi int (epoch) ke DateTime', () {
        expect(ParserUtil.parseDateTime(testDate.millisecondsSinceEpoch),
            equals(testDate));
      });

      test('05. harus mengonversi String ISO 8601 ke DateTime', () {
        expect(ParserUtil.parseDateTime(testDate.toIso8601String()),
            equals(testDate));
      });

      test('06. harus mengembalikan null untuk format yang tidak dikenal', () {
        expect(ParserUtil.parseDateTime('invalid date'), isNull);
        expect(ParserUtil.parseDateTime(123.45), isNull);
      });
    });

    group('parseBool', () {
      test('07. harus mengembalikan false jika value null', () {
        expect(ParserUtil.parseBool(null), isFalse);
      });

      test('08. harus mengembalikan bool jika sudah bool', () {
        expect(ParserUtil.parseBool(true), isTrue);
        expect(ParserUtil.parseBool(false), isFalse);
      });

      test('09. harus mengonversi int ke bool', () {
        expect(ParserUtil.parseBool(1), isTrue);
        expect(ParserUtil.parseBool(0), isFalse);
        expect(ParserUtil.parseBool(123), isFalse);
      });

      test('10. harus mengonversi String ke bool (case-insensitive)', () {
        expect(ParserUtil.parseBool('true'), isTrue);
        expect(ParserUtil.parseBool('TRUE'), isTrue);
        expect(ParserUtil.parseBool('1'), isTrue);
        expect(ParserUtil.parseBool('false'), isFalse);
        expect(ParserUtil.parseBool('FALSE'), isFalse);
        expect(ParserUtil.parseBool('0'), isFalse);
        expect(ParserUtil.parseBool('yes'), isFalse);
      });

      test('11. harus mengembalikan false untuk format yang tidak dikenal', () {
        expect(ParserUtil.parseBool('invalid'), isFalse);
        expect(ParserUtil.parseBool(123.45), isFalse);
        expect(ParserUtil.parseBool([1, 2, 3]), isFalse);
      });
    });
  });
}
