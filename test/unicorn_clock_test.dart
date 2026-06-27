import 'dart:async';

import 'package:test/test.dart';
import 'package:unicorn/unicorn.dart';

void main() {
  group('U\$Clock', () {
    test('measures elapsed duration after start/stop', () async {
      final clock = U$Clock();
      const name = 'basic';

      clock.start(name);
      await Future<void>.delayed(const Duration(milliseconds: 5));
      clock.stop(name);

      final d = clock.getDuration(name);
      expect(d.inMicroseconds, greaterThan(0));
    });

    test('throws if stopping a non-running stopwatch', () {
      final clock = U$Clock();
      const name = 'not-running';

      expect(() => clock.stop(name), throwsStateError);
    });

    test('throws if reading duration while still running', () {
      final clock = U$Clock();
      const name = 'running';

      clock.start(name);
      expect(() => clock.getDuration(name), throwsStateError);
      clock.stop(name);
    });

    test('throws when start is called twice with reset=false', () {
      final clock = U$Clock();
      const name = 'double-start';

      clock.start(name);
      expect(() => clock.start(name, reset: false), throwsStateError);
      clock.stop(name);
    });

    test('reset=true recreates stopwatch and allows restart', () async {
      final clock = U$Clock();
      const name = 'reset';

      clock.start(name);
      await Future<void>.delayed(const Duration(milliseconds: 2));
      clock.stop(name);
      final first = clock.getDuration(name);

      clock.start(name, reset: true);
      await Future<void>.delayed(const Duration(milliseconds: 2));
      clock.stop(name);
      final second = clock.getDuration(name);

      expect(first.inMicroseconds, greaterThan(0));
      expect(second.inMicroseconds, greaterThan(0));
    });
  });
}
