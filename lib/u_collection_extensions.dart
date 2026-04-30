/// U$CollectionExtensions : Extensions génériques pour List, Set, Map, Iterable.
/// Fournit des méthodes utilitaires avancées pour manipuler les collections.

// ===================== List Extensions =====================
extension U$ListRemoveExtensions<T> on List<T> {
  List<T> extractWhere(bool Function(T) test) {
    final removed = <T>[];
    removeWhere((element) {
      if (test(element)) {
        removed.add(element);
        return true;
      }
      return false;
    });
    return removed;
  }

  T? extractFirstWhere(bool Function(T) test) {
    final index = indexWhere(test);
    return index != -1 ? removeAt(index) : null;
  }

  T? extractLastWhere(bool Function(T) test) {
    final index = lastIndexWhere(test);
    return index != -1 ? removeAt(index) : null;
  }

  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }

  void sortBy<K extends Comparable<Object?>>(K Function(T) keyOf) {
    if (isEmpty) return;
    sort((a, b) {
      final keyA = keyOf(a);
      final keyB = keyOf(b);
      return keyA.compareTo(keyB);
    });
  }

  bool equals(List<T> other) {
    try {
      if (identical(this, other)) return true;
      if (length != other.length) return false;
      for (var i = 0; i < length; i++) {
        try {
          if (this[i] != other[i]) return false;
        } catch (_) {
          return false;
        }
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  List<T> removeCountWhereAndReturn(bool Function(T) test, int count) {
    if (count < 0) {
      throw ArgumentError.value(count, 'count', 'Count must be non-negative');
    }
    final removed = <T>[];
    var foundCount = 0;
    removeWhere((element) {
      if (foundCount < count && test(element)) {
        removed.add(element);
        foundCount++;
        return true;
      }
      return false;
    });
    return removed;
  }
}

extension U$ListIntersectionExtensions<T> on List<T> {
  List<T> intersection(List<T> other) {
    final otherSet = other.toSet();
    return where((element) => otherSet.contains(element)).toList();
  }

  List<T> difference(List<T> other) {
    final otherSet = other.toSet();
    return where((element) => !otherSet.contains(element)).toList();
  }

  List<T> union(List<T> other) => {...this, ...other}.toList();
}

// ===================== Set Extensions =====================
extension U$SetRemoveExtensions<T> on Set<T> {
  Set<T> extractWhere(bool Function(T) test) {
    final removed = <T>{};
    for (final element in this) {
      if (test(element)) removed.add(element);
    }
    removeAll(removed);
    return removed;
  }

  T? extractFirstWhere(bool Function(T) test) {
    var found = false;
    T? matched;
    for (final element in this) {
      if (test(element)) {
        found = true;
        matched = element;
        break;
      }
    }
    if (found) remove(matched);
    return matched;
  }

  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

// ===================== Map Extensions =====================
extension U$MapRemoveExtensions<K, V> on Map<K, V> {
  Map<K, V> extractWhere(bool Function(K key, V value) test) {
    final removed = <K, V>{};
    removeWhere((key, value) {
      if (test(key, value)) {
        removed[key] = value;
        return true;
      }
      return false;
    });
    return removed;
  }

  MapEntry<K, V>? extractFirstWhere(bool Function(K key, V value) test) {
    MapEntry<K, V>? matchedEntry;
    for (final entry in entries) {
      if (test(entry.key, entry.value)) {
        matchedEntry = entry;
        break;
      }
    }
    if (matchedEntry != null) remove(matchedEntry.key);
    return matchedEntry;
  }

  MapEntry<K, V>? firstWhereOrNull(bool Function(K key, V value) test) {
    for (final entry in entries) {
      if (test(entry.key, entry.value)) return entry;
    }
    return null;
  }
}

extension U$MapIntersectionExtensions<K, V> on Map<K, V> {
  Map<K, V> intersection(Map<K, V> other) {
    final result = <K, V>{};
    forEach((key, value) {
      if (other.containsKey(key) && other[key] == value) result[key] = value;
    });
    return result;
  }

  Set<K> intersectionKeys(Map<K, V> other) =>
      keys.toSet().intersection(other.keys.toSet());
  Set<V> intersectionValues(Map<K, V> other) =>
      values.toSet().intersection(other.values.toSet());
  Map<K, ({V thisValue, V otherValue})> intersectionKeysWithValues(
      Map<K, V> other) {
    final result = <K, ({V thisValue, V otherValue})>{};
    forEach((key, value) {
      if (other.containsKey(key)) {
        result[key] = (thisValue: value, otherValue: other[key] as V);
      }
    });
    return result;
  }

  Map<K, V> difference(Map<K, V> other) {
    final result = <K, V>{};
    forEach((key, value) {
      if (!other.containsKey(key) || other[key] != value) result[key] = value;
    });
    return result;
  }

  ({
    Map<K, V> common,
    Map<K, V> onlyInThis,
    Map<K, V> onlyInOther,
    Map<K, ({V thisValue, V otherValue})> differentValues
  }) compare(Map<K, V> other) {
    final common = <K, V>{};
    final onlyInThis = <K, V>{};
    final onlyInOther = <K, V>{...other};
    final differentValues = <K, ({V thisValue, V otherValue})>{};
    forEach((key, value) {
      if (other.containsKey(key)) {
        onlyInOther.remove(key);
        if (other[key] == value) {
          common[key] = value;
        } else {
          differentValues[key] =
              (thisValue: value, otherValue: other[key] as V);
        }
      } else {
        onlyInThis[key] = value;
      }
    });
    return (
      common: common,
      onlyInThis: onlyInThis,
      onlyInOther: onlyInOther,
      differentValues: differentValues
    );
  }
}

// ===================== Iterable Extensions =====================
extension U$IterableExtensions<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }

  List<T> sorted([int Function(T a, T b)? compare]) {
    final list = toList();
    if (list.isEmpty) return list;
    if (compare != null) {
      list.sort(compare);
    } else {
      list.sort();
    }
    return list;
  }

  ({List<T> matching, List<T> nonMatching}) partition(bool Function(T) test) {
    final matching = <T>[];
    final nonMatching = <T>[];
    for (final element in this) {
      if (test(element)) {
        matching.add(element);
      } else {
        nonMatching.add(element);
      }
    }
    return (matching: matching, nonMatching: nonMatching);
  }

  List<T> distinct([Object? Function(T)? by]) {
    if (isEmpty) return <T>[];
    final seen = <Object?>{};
    final result = <T>[];
    for (final element in this) {
      final key = by != null ? by(element) : element;
      if (seen.add(key)) result.add(element);
    }
    return result;
  }

  Map<K, V> toMap<K, V>(MapEntry<K, V> Function(T) toEntry) {
    final result = <K, V>{};
    for (final element in this) {
      final entry = toEntry(element);
      result[entry.key] = entry.value;
    }
    return result;
  }
}

// ===================== Fonctions globales =====================
Map<K, List<T>> u$groupBy<T, K>(
    Iterable<T> iterable, K Function(T) keyFunction) {
  final result = <K, List<T>>{};
  for (final element in iterable) {
    final key = keyFunction(element);
    result.putIfAbsent(key, () => <T>[]).add(element);
  }
  return result;
}

List<List<T>> u$partition<T>(Iterable<T> iterable, int size) {
  if (size <= 0) {
    throw ArgumentError.value(size, 'size', 'Size must be positive');
  }
  final iterator = iterable.iterator;
  final result = <List<T>>[];
  while (iterator.moveNext()) {
    final chunk = <T>[iterator.current];
    for (var i = 1; i < size && iterator.moveNext(); i++) {
      chunk.add(iterator.current);
    }
    result.add(chunk);
  }
  return result;
}
