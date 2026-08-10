/// Parseur statique des valeurs entières.
class U$Int {
  const U$Int._();

  /// Convertit une valeur en entier.
  ///
  /// Lève une [FormatException] si la valeur ne peut pas être convertie.
  static int parse(Object? value) =>
      tryParse(value) ?? (throw FormatException('Invalid int: $value'));

  /// Convertit une valeur en entier, ou retourne `null` si la conversion échoue.
  static int? tryParse(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value');
  }
}

/// Parseur statique des valeurs décimales.
class U$Double {
  const U$Double._();

  /// Convertit une valeur en nombre décimal.
  ///
  /// Lève une [FormatException] si la valeur ne peut pas être convertie.
  static double parse(Object? value) =>
      tryParse(value) ?? (throw FormatException('Invalid double: $value'));

  /// Convertit une valeur en nombre décimal, ou retourne `null` si la conversion échoue.
  static double? tryParse(Object? value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse('$value');
  }
}

extension UnicornIntExtension on int? {
  int get orZero => this ?? 0;
}

extension UnicornDoubleExtension on double? {
  double get orZero => this ?? 0.0;
}
