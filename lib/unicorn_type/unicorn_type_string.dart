/// Parseur statique des valeurs texte.
class U$String {
  const U$String._();

  /// Convertit une valeur en chaîne.
  ///
  /// Lève une [FormatException] si la valeur est `null`.
  static String parse(Object? value) =>
      tryParse(value) ?? (throw FormatException('Invalid String: null'));

  /// Convertit une valeur non nulle en chaîne, ou retourne `null` pour `null`.
  static String? tryParse(Object? value) => value?.toString();
}

extension UnicornStringNullableExtension on String? {
  String? get trimOrNull {
    if (this == null) return null;
    final trimmed = this!.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String trim() => this?.trim() ?? '';

  bool get isNullOrEmpty => this == null || this!.isEmpty;
  bool get isNotNullOrEmpty => this != null && this!.isNotEmpty;
}
