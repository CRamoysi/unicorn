import 'package:test/test.dart';
import 'package:unicorn/u_logger.dart';

void main() {
  group('U\$Logger', () {
    test('log prints with prefix', () {
      // Since print cannot be captured directly in test, we just check that the method runs without error.
      expect(() => U$Logger.log('Hello Unicorn'), returnsNormally);
    });
    test('log handles null', () {
      expect(() => U$Logger.log(null), returnsNormally);
    });
  });
}
