import 'package:test/test.dart';
import 'package:unicorn/unicorn.dart';

void main() {
  group(r'type parsers', () {
    test('parses int, double, string, list and date time values', () {
      expect(U$Int.tryParse('42'), 42);
      expect(U$Double.tryParse('3.14'), 3.14);
      expect(U$String.tryParse(42), '42');
      expect(U$List.tryParse<String>([' a ', null, '']), [' a ', '']);
      expect(U$DateTime.tryParse('2024-01-01'), isA<DateTime>());
    });

    test('parses list elements through tryParse<T>', () {
      final values = <Object?>['1', 2, null, 'invalid'];

      expect(U$List.tryParse<int>(values), [1, 2]);
      expect(values.tryParseList<String>(), ['1', '2', 'invalid']);
    });

    test('custom cases override native parsers', () {
      expect(
        42.tryParse<int>(
          customCases: {int: (_) => 7},
        ),
        7,
      );
      expect(
        U$List.tryParse<int>([42], customCases: {int: (_) => 7}),
        [7],
      );
      expect(
        U$List.tryParse<DateTime>(
          ['invalid'],
          customCases: {Object: (_) => DateTime(2024)},
        ),
        [DateTime(2024)],
      );
    });
  });

  group(r'U$Bool.tryParse', () {
    test('parses bool, string and integer values', () {
      expect(U$Bool.tryParse(true), isTrue);
      expect(U$Bool.tryParse('true'), isTrue);
      expect(U$Bool.tryParse('1'), isTrue);
      expect(U$Bool.tryParse(1), isTrue);
      expect(U$Bool.tryParse(false), isFalse);
      expect(U$Bool.tryParse('false'), isFalse);
      expect(U$Bool.tryParse('0'), isFalse);
    });

    test('returns null for unsupported values', () {
      expect(U$Bool.tryParse('invalid'), isNull);
      expect(U$Bool.tryParse(null), isNull);
      expect(U$Bool.tryParse(2), isNull);
    });

    test('parse throws for unsupported values', () {
      expect(() => U$Bool.parse('invalid'), throwsFormatException);
      expect(() => U$Bool.parse(null), throwsFormatException);
    });

    test('all strict parsers throw when conversion fails', () {
      expect(() => U$Int.parse('invalid'), throwsFormatException);
      expect(() => U$Double.parse('invalid'), throwsFormatException);
      expect(() => U$String.parse(null), throwsFormatException);
      expect(() => U$List.parse<int>(['invalid']), throwsFormatException);
      expect(() => U$DateTime.parse('invalid'), throwsFormatException);
    });
  });

  group('orFalse/orTrue', () {
    test('bool.orFalse', () {
      expect(true.orFalse, true);
      expect(false.orFalse, false);
    });
    test('bool.orTrue', () {
      expect(true.orTrue, true);
      expect(false.orTrue, false);
    });
    test('bool?', () {
      expect((null as bool?).orFalse, false);
      expect((null as bool?).orTrue, true);
    });
  });

  group('trim/trimOrNull', () {
    test('String.t', () {
      final String? s = "  toto  ";
      final String s2 = "  tutu  ";
      expect(s.trim(), "toto");
      expect(s2.trim(), "tutu");
      expect(("  " as String?).trim(), "");
    });

    test('backward compatibility trim/trimOrNull', () {
      expect(("  toto  " as String?).trim(), "toto");
      expect("  ".trimOrNull, null);
    });
  });

  group('isNullOrEmpty', () {
    test('String?', () {
      final String? s = "  toto  ";
      final String? s2 = "  ";
      final String? s3 = null;
      final String? s4 = "";
      expect(s.isNullOrEmpty, false);
      expect(s2.isNullOrEmpty, false);
      expect(s3.isNullOrEmpty, true);
      expect(s4.isNullOrEmpty, true);
    });

    test('String', () {
      final String s = "  toto  ";
      final String s2 = "  ";
      final String s3 = "";
      expect(s.isNullOrEmpty, false);
      expect(s2.isNullOrEmpty, false);
      expect(s3.isNullOrEmpty, true);
    });
  });
}
