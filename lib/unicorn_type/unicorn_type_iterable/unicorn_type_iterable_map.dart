
import 'package:unicorn/unicorn.dart';

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
