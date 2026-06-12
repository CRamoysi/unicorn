
import 'package:unicorn/unicorn_type/unicorn_type_string.dart';

extension UnicornListStringExtension on List<String>? {
  List<String> get cleanAndTrim {
    if (this == null) return const [];
    return this!
        .map((e) => e.trimOrNull)
        .whereType<String>()
        .toList(growable: false);
  }
}