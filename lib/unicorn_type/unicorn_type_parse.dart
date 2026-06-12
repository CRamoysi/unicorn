extension UnicornTypeExtension on Object? {
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
        if (value is String) {
          final lower = value.toLowerCase();
          if (lower == 'true' || lower == '1') return true as T;
        }
        if (value is int) {
          if (value == 1) return true as T;
        }
        return false as T;
    }
    return fallback(value);
  }
}