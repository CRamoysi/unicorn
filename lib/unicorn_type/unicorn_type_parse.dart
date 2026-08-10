import 'package:unicorn/unicorn_type/unicorn_type_bool.dart';
import 'package:unicorn/unicorn_type/unicorn_type_iterable/unicorn_type_iterable_list.dart';
import 'package:unicorn/unicorn_type/unicorn_type_num.dart';
import 'package:unicorn/unicorn_type/unicorn_type_string.dart';

/// Parseur statique des valeurs [DateTime].
class U$DateTime {
  const U$DateTime._();

  /// Convertit une valeur en [DateTime].
  ///
  /// Lève une [FormatException] si la valeur n'est pas une date valide.
  static DateTime parse(Object? value) =>
      tryParse(value) ?? (throw FormatException('Invalid DateTime: $value'));

  /// Convertit une date ou une chaîne ISO-8601 en [DateTime].
  ///
  /// Retourne `null` si la valeur n'est ni une date ni une chaîne valide.
  static DateTime? tryParse(Object? value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

extension UnicornTypeExtension on Object? {
  /// Parse la valeur courante vers le type cible [T].
  ///
  /// Priorite de resolution:
  /// 1) custom case associe au type runtime exact de la valeur
  /// 2) valeur deja du type T
  /// 3) conversions natives (int, double, String, DateTime, bool)
  /// 4) fallback customCases[Object]
  ///
  /// Cas speciaux de customCases:
  /// - Null: fallback dedie quand la valeur source est null
  /// - Object: fallback global quand rien d'autre ne matche
  ///
  /// Types natifs pris en charge : [int], [double], [String],
  /// [DateTime] et [bool]. Utilisez [tryParseList] pour les listes.
  ///
  /// Retourne `null` lorsqu'aucun parseur ne peut produire une valeur de type
  /// [T]. Le cas [bool] respecte également cette règle.
  T? tryParse<T>({
    Map<Type, dynamic>? customCases,
  }) {
    final value = this;
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
        return (U$DateTime.tryParse(value) as T?) ?? fallback(value);
      case const (bool):
        return (U$Bool.tryParse(value) as T?) ?? fallback(value);
    }
    return fallback(value);
  }

  /// Parse la valeur courante en liste d'éléments de type [E].
  ///
  /// Les éléments nulls ou impossibles à convertir sont ignorés.
  List<E>? tryParseList<E>({
    Map<Type, dynamic>? customCases,
  }) {
    return U$List.tryParse<E>(this, customCases: customCases);
  }
}
