import 'package:test/test.dart';
import 'package:unicorn/unicorn.dart';

void main() {
  group('U\$ListRemoveExtensions', () {
    test('extractWhere removes and returns matching elements', () {
      final list = [1, 2, 3, 4, 5];
      final removed = list.extractWhere((e) => e.isEven);
      expect(removed, [2, 4]);
      expect(list, [1, 3, 5]);
    });
    test('extractFirstWhere removes and returns first match', () {
      final list = [1, 2, 3, 4];
      final removed = list.extractFirstWhere((e) => e.isEven);
      expect(removed, 2);
      expect(list, [1, 3, 4]);
    });
    test('extractLastWhere removes and returns last match', () {
      final list = [1, 2, 3, 4];
      final removed = list.extractLastWhere((e) => e.isEven);
      expect(removed, 4);
      expect(list, [1, 2, 3]);
    });
    test('firstWhereOrNull returns first match or null', () {
      final list = [1, 2, 3];
      expect(list.firstWhereOrNull((e) => e.isEven), 2);
      expect(list.firstWhereOrNull((e) => e > 10), isNull);
    });
    test('sortBy sorts by key', () {
      final list = ['apple', 'pear', 'banana'];
      list.sortBy((s) => s.length);
      expect(list, ['pear', 'apple', 'banana']);
    });
    test('sortBy descending trie en ordre décroissant', () {
      final list = ['apple', 'pear', 'banana'];
      list.sortBy((s) => s.length, descending: true);
      expect(list, ['banana', 'apple', 'pear']);
    });
    test('sortBy sans descending reste croissant', () {
      final list = [3, 1, 2];
      list.sortBy((n) => n);
      expect(list, [1, 2, 3]);
    });
    test('equals compares lists', () {
      expect([1, 2, 3].equals([1, 2, 3]), isTrue);
      expect([1, 2, 3].equals([3, 2, 1]), isFalse);
      expect([1, 2].equals([1, 2, 3]), isFalse);
    });
    test('removeCountWhereAndReturn removes up to count', () {
      final list = [1, 2, 2, 2, 3];
      final removed = list.removeCountWhereAndReturn((e) => e == 2, 2);
      expect(removed, [2, 2]);
      expect(list, [1, 2, 3]);
    });
    test('removeCountWhereAndReturn rejects negative count', () {
      expect(
        () => [1, 2, 3].removeCountWhereAndReturn((e) => e.isEven, -1),
        throwsArgumentError,
      );
    });
    test('intersection, difference, union', () {
      final a = [1, 2, 3];
      final b = [2, 3, 4];
      expect(a.intersection(b), [2, 3]);
      expect(a.difference(b), [1]);
      expect(a.union(b).toSet(), {1, 2, 3, 4});
    });
  });

  group('U\$SetRemoveExtensions', () {
    test('extractWhere removes and returns matching', () {
      final set = {1, 2, 3, 4};
      final removed = set.extractWhere((e) => e.isEven);
      expect(removed, {2, 4});
      expect(set, {1, 3});
    });
    test('extractWhere evaluates predicate once per element', () {
      final set = {1, 2, 3};
      var calls = 0;
      set.extractWhere((e) {
        calls++;
        return e.isOdd;
      });
      expect(calls, 3);
    });
    test('extractFirstWhere removes and returns first match', () {
      final set = {1, 2, 3};
      final removed = set.extractFirstWhere((e) => e.isEven);
      expect(removed, 2);
      expect(set, {1, 3});
    });
    test('firstWhereOrNull returns first match or null', () {
      final set = {1, 2, 3};
      expect(set.firstWhereOrNull((e) => e.isEven), 2);
      expect(set.firstWhereOrNull((e) => e > 10), isNull);
    });
  });

  group('U\$MapRemoveExtensions', () {
    test('extractWhere removes and returns matching', () {
      final map = {1: 'a', 2: 'b', 3: 'c'};
      final removed = map.extractWhere((k, v) => k.isEven);
      expect(removed, {2: 'b'});
      expect(map, {1: 'a', 3: 'c'});
    });
    test('extractFirstWhere removes and returns first match', () {
      final map = {1: 'a', 2: 'b', 3: 'c'};
      final removed = map.extractFirstWhere((k, v) => v == 'b');
      expect(removed?.key, 2);
      expect(removed?.value, 'b');
      expect(map, {1: 'a', 3: 'c'});
    });
    test('firstWhereOrNull returns first match or null', () {
      final map = {1: 'a', 2: 'b'};
      final found = map.firstWhereOrNull((k, v) => v == 'b');
      expect(found?.key, 2);
      expect(found?.value, 'b');
      expect(map.firstWhereOrNull((k, v) => v == 'z'), isNull);
    });
    test('intersection, difference, compare', () {
      final a = {1: 'a', 2: 'b', 3: 'c'};
      final b = {2: 'b', 3: 'z', 4: 'd'};
      expect(a.intersection(b), {2: 'b'});
      expect(a.difference(b), {1: 'a', 3: 'c'});
      expect(a.intersectionKeys(b), {2, 3});
      expect(a.intersectionValues(b), {'b'});
      expect(a.intersectionKeysWithValues(b), {
        2: (thisValue: 'b', otherValue: 'b'),
        3: (thisValue: 'c', otherValue: 'z'),
      });
      final cmp = a.compare(b);
      expect(cmp.common, {2: 'b'});
      expect(cmp.onlyInThis, {1: 'a'});
      expect(cmp.onlyInOther, {4: 'd'});
      expect(cmp.differentValues, {3: (thisValue: 'c', otherValue: 'z')});
    });
    test('intersection does not match absent null values', () {
      final a = <int, String?>{1: null, 2: 'b'};
      final b = <int, String?>{2: 'b'};
      expect(a.intersection(b), {2: 'b'});
    });
  });

  group('U\$IterableExtensions', () {
    test('firstWhereOrNull returns first match or null', () {
      final it = [1, 2, 3];
      expect(it.firstWhereOrNull((e) => e.isEven), 2);
      expect(it.firstWhereOrNull((e) => e > 10), isNull);
    });
    test('sorted returns sorted list', () {
      final it = [3, 1, 2];
      expect(it.sorted(), [1, 2, 3]);
      expect(it.sorted((a, b) => b - a), [3, 2, 1]);
    });
    test('partition splits by predicate', () {
      final it = [1, 2, 3, 4];
      final parts = it.partition((e) => e.isEven);
      expect(parts.matching, [2, 4]);
      expect(parts.nonMatching, [1, 3]);
    });
    test('distinct returns unique elements', () {
      final it = [1, 2, 2, 3, 1];
      expect(it.distinct(), [1, 2, 3]);
      expect(it.distinct((e) => e % 2), [1, 2]);
    });
    test('toMap converts to map', () {
      final it = ['a', 'bb'];
      expect(it.toMap((e) => MapEntry(e, e.length)), {'a': 1, 'bb': 2});
    });
    test('toMap propagates converter errors', () {
      expect(
        () => ['a'].toMap<String, int>((e) => throw StateError('boom')),
        throwsStateError,
      );
    });
  });

  group('Global functions', () {
    test('u\$groupBy groups by key', () {
      final list = ['a', 'ab', 'b', 'ba'];
      final grouped = u$groupBy(list, (s) => s.length);
      expect(grouped, {
        1: ['a', 'b'],
        2: ['ab', 'ba']
      });
    });
    test('u\$groupBy propagates key function errors', () {
      expect(
        () => u$groupBy(['a'], (e) => throw StateError('boom')),
        throwsStateError,
      );
    });
    test('u\$partition splits into chunks', () {
      final list = [1, 2, 3, 4, 5];
      final parts = u$partition(list, 2).toList();
      expect(parts, [
        [1, 2],
        [3, 4],
        [5]
      ]);
    });
    test('u\$partition rejects invalid chunk size', () {
      expect(() => u$partition([1, 2, 3], 0), throwsArgumentError);
    });

    test('u\$zip associe les éléments deux à deux', () {
      final result = u$zip([1, 2, 3], ['a', 'b', 'c']).toList();
      expect(result, [(1, 'a'), (2, 'b'), (3, 'c')]);
    });

    test('u\$zip s\'arrête au plus court', () {
      final result = u$zip([1, 2, 3], ['a', 'b']).toList();
      expect(result, [(1, 'a'), (2, 'b')]);
    });

    test('u\$zip avec iterables vides retourne vide', () {
      expect(u$zip([], []).toList(), isEmpty);
    });
  });

}
