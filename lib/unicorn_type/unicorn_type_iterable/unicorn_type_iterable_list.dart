import 'package:unicorn/unicorn_type/unicorn_type_bool.dart';
import 'package:unicorn/unicorn_type/unicorn_type_num.dart';
import 'package:unicorn/unicorn_type/unicorn_type_string.dart';


/// Parseur statique des listes dont les éléments sont parsés individuellement.
class U$List<T> {
  const U$List._();

  /// Parse une valeur en liste de [T].
  ///
  /// Lève une [FormatException] si la valeur n'est pas une liste ou si un
  /// élément ne peut pas être converti.
  static List<T> parse<T>(Object? value, {Map<Type, dynamic>? customCases}) {
    if (value is! List) {
      throw FormatException('Invalid List: $value');
    }

    final result = <T>[];
    for (final item in value) {
      final parsed = _tryParseListItem<T>(item, customCases: customCases);
      if (parsed == null) {
        throw FormatException('Invalid List<$T> item: $item');
      }
      result.add(parsed);
    }
    return result.toList(growable: false);
  }

  /// Convertit une liste non typée en liste de [T].
  ///
  /// Les éléments qui ne peuvent pas être parsés vers [T], ainsi que les
  /// valeurs nulles, sont ignorés. [customCases] est transmis au parseur de
  /// chaque élément. Retourne `null` si la valeur source n'est pas une liste.
  static List<T>? tryParse<T>(Object? value, {Map<Type, dynamic>? customCases}) {
    if (value is! List) return null;

    return (value as List<Object?>)
        .map((item) => _tryParseListItem<T>(item, customCases: customCases))
        .whereType<T>()
        .where((item) => item != null)
        .toList(growable: false);
  }
}

T? _tryParseListItem<T>(Object? value, {Map<Type, dynamic>? customCases}) {
  T? fallback([Object? raw]) {
    final defaultCase = customCases?[Object];
    if (defaultCase is Function) {
      final parsed = defaultCase(raw);
      if (parsed is T) return parsed;
    }
    return null;
  }

  if (value == null) {
    final nullCase = customCases?[Null];
    if (nullCase is Function) {
      final parsed = nullCase(null);
      if (parsed is T) return parsed;
    }
    return fallback(null);
  }
  final customCase = customCases?[value.runtimeType];
  if (customCase is Function) {
    final parsed = customCase(value);
    if (parsed is T) return parsed;
  }
  if (value is T) return value as T;

  switch (T) {
    case const (int):
      return (U$Int.tryParse(value) as T?) ?? fallback(value);
    case const (double):
      return (U$Double.tryParse(value) as T?) ?? fallback(value);
    case const (String):
      return U$String.tryParse(value) as T;
    case const (DateTime):
      if (value is DateTime) return value as T;
      if (value is String) return (DateTime.tryParse(value) as T?);
      return fallback(value);
    case const (bool):
      return (U$Bool.tryParse(value) as T?) ?? fallback(value);
  }
  return fallback(value);
}

extension UnicornListStringExtension on Iterable<String>? {
  List<String> get cleanAndTrim {
    if (this == null) return const [];
    return this!
        .map((e) => e.trimOrNull)
        .whereType<String>()
        .toList(growable: false);
  }
}
