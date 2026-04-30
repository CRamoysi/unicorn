import 'package:test/test.dart';
import 'package:unicorn/u_logger.dart';

void main() {
  group('U\$Logger', () {
    test('log prints with prefix', () {
      expect(
        () => U$Logger.log('Hello Unicorn'),
        prints(allOf(contains('[U\$]'), contains('Hello Unicorn'))),
      );
    });
    test('log handles null', () {
      expect(() => U$Logger.log(null), returnsNormally);
    });
  });
}
