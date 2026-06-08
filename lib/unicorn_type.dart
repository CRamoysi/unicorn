part of 'unicorn.dart';

extension UnicornMapExtension<K, V> on Map<K, V>? {
  T? getV<T>(
    K key, [
    Map<Type, dynamic>? customCases,
  ]) {
    if (this?.isNotEmpty != true) {
      return (null).tryParse<T>(
        customCases: customCases,
      );
    }

    final value = this![key];
    if (value is T) {
      return value;
    }

    return value.tryParse<T>(
      customCases: customCases,
    );
  }
}

extension UnicornIterableExtension<T> on Iterable<T?>? {
  Iterable<T> get whereNotNull {
    if (this == null) return const Iterable.empty();
    return this!.whereType<T>();
  }
}

extension UnicornNullableExtension<T> on T? {
  T or(T fallback) => this ?? fallback;
}

extension UnicornBoolExtension on bool? {
  bool get orFalse => this ?? false;
  bool get orTrue => this ?? true;
}

extension UnicornIntExtension on int? {
  int get orZero => this ?? 0;
}

extension UnicornDoubleExtension on double? {
  double get orZero => this ?? 0.0;
}

extension UnicornStringExtension on String? {
  String? get trimOrNull {
    if (this == null) return null;
    final trimmed = this!.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String get trim => this?.trim() ?? '';
}

extension UnicornListStringExtension on List<String>? {
  List<String> get cleanAndTrim {
    if (this == null) return const [];
    return this!.map((e) => e.trimOrNull).whereNotNull.toList(growable: false);
  }
}

extension UnicornTypeExtension on Object? {
  /// Parse la valeur courante vers le type cible T.
  ///
  /// Priorite de resolution:
  /// 1) valeur deja du type T
  /// 2) custom case associe au type runtime exact de la valeur
  /// 3) conversions natives (int, double, String, List<String>, DateTime depuis String, bool)
  /// 4) fallback customCases[Object]
  ///
  /// Cas speciaux de customCases:
  /// - Object: fallback global quand rien d'autre ne matche
  /// - Null: fallback dedie quand la valeur source est null
  ///
  /// Exemples:
  ///
  /// ```dart
  /// final a = '123'.tryParse<int>(); // 123
  /// final b = 'abc'.tryParse<int>(customCases: {Object: (_) => 0}); // 0
  /// final c = null.tryParse<String>(customCases: {Null: (_) => 'N/A'}); // N/A
  /// ```
  ///
  /// ```dart
  /// final dt = raw.tryParse<DateTime>(customCases: {
  ///   Timestamp: (v) => (v as Timestamp).toDate(),
  ///   int: (v) => DateTime.fromMillisecondsSinceEpoch(v as int),
  ///   Object: (_) => DateTime.now().toUtc(),
  /// });
  /// ```
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
    if (value is T) return value as T;

    final customCase = customCases?[value.runtimeType];
    if (customCase is Function) {
      final parsed = customCase(value);
      if (parsed is T) return parsed;
    }

    switch (T) {
      case const (int):
        if (value is int) return value as T;
        if (value is num) return value.toInt() as T;
        return (int.tryParse('$value') as T?) ?? fallback(value);
      case const (double):
        if (value is double) return value as T;
        if (value is num) return value.toDouble() as T;
        return (double.tryParse('$value') as T?) ?? fallback(value);
      case const (String):
        return '$value' as T;
      case const (List<String>):
        if (value is! List) {
          return fallback(value);
        }
        return value
            .map((item) => item?.toString().trim() ?? '')
            .where((item) => item.isNotEmpty)
            .toList(growable: false) as T;
      case const (DateTime):
        if (value is DateTime) return value as T;
        if (value is String) {
          return (DateTime.tryParse(value) as T?) ?? fallback(value);
        }
        break;
      case const (bool):
        if (value is bool) return value as T;
        //si c'est 'true' ou 1 alors true
        if (value is String) {
          final lower = value.toLowerCase();
          if (lower == 'true' || lower == '1') return true as T;
        }
        if (value is int) {
          if (value == 1) return true as T;
        }
        // sinon false
        return false as T;
    }
    return fallback(value);
  }
}
