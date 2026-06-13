import 'package:test/test.dart';
import 'package:unicorn/unicorn.dart';

void main() {
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
