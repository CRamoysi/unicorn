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

    test('show lance StateError si le chrono tourne encore', () {
      final clock = U$Clock();
      const name = 'show-running';

      clock.start(name);
      expect(() => clock.show(name), throwsStateError);
      clock.stop(name);
    });

    test('show lance StateError si le chrono est inconnu', () {
      final clock = U$Clock();
      expect(() => clock.show('inconnu'), throwsStateError);
    });

    test('elapsed retourne la durée en cours sans stopper', () async {
      final clock = U$Clock();
      const name = 'elapsed-test';

      clock.start(name);
      await Future<void>.delayed(const Duration(milliseconds: 5));
      final d = clock.elapsed(name);
      expect(d.inMicroseconds, greaterThan(0));
      clock.stop(name);
    });

    test('elapsed lance StateError si le chrono nest pas lancé', () {
      final clock = U$Clock();
      expect(() => clock.elapsed('inexistant'), throwsStateError);
    });

    test('remove supprime le chrono et rend getDuration impossible', () {
      final clock = U$Clock();
      const name = 'a-supprimer';

      clock.start(name);
      clock.stop(name);
      clock.remove(name);

      expect(() => clock.getDuration(name), throwsStateError);
    });

    test('clear supprime tous les chronos', () {
      final clock = U$Clock();
      clock.start('x');
      clock.stop('x');
      clock.start('y');
      clock.stop('y');

      clock.clear();

      expect(() => clock.getDuration('x'), throwsStateError);
      expect(() => clock.getDuration('y'), throwsStateError);
    });
  });

  group('U\$', () {
    test('canDebug reflète forceDebug', () {
      U$.forceDebug = true;
      expect(U$.forceDebug, isTrue);
      expect(U$.canDebug, isTrue);

      U$.forceDebug = false;
      expect(U$.forceDebug, isFalse);
    });
  });

  group('U\$Log', () {
    test('ne lance pas d\'exception', () {
      // ignore: avoid_print
      expect(() => U$Log('message de test'), returnsNormally);
    });

    test('accepte error et stackTrace sans exception', () {
      expect(
        () => U$Log('erreur', error: Exception('oops'), stackTrace: StackTrace.current),
        returnsNormally,
      );
    });
  });
}
