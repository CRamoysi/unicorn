
/// Parseur statique des valeurs booléennes.
class U$Bool {
  const U$Bool._();

  /// Convertit une valeur en booléen.
  ///
  /// Lève une [FormatException] si la valeur ne peut pas être interprétée.
  static bool parse(Object? value) =>
      tryParse(value) ?? (throw FormatException('Invalid bool: $value'));

  /// Tente de convertir une valeur en booléen.
  ///
  /// Retourne `true` pour `true`, `1` et les chaînes `"true"` ou `"1"`.
  /// Retourne `false` pour `false`, `0` et les chaînes `"false"` ou `"0"`.
  /// Retourne `null` si la valeur ne peut pas être interprétée.
  static bool? tryParse(Object? value) {
    if (value is bool) return value;
    if (value is String) {
      final lower = value.toLowerCase().trim();
      if (lower == 'true' || lower == '1') return true;
      if (lower == 'false' || lower == '0') return false;
    }
    if (value is int && (value == 0 || value == 1)) {
      return value == 1;
    }
    return null;
}
}

extension UnicornBoolExtension on bool? {
  bool get orFalse => this ?? false;
  bool get orTrue => this ?? true;
}
