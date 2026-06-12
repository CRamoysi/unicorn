import 'unicorn_type_iterable/unicorn_type_iterable_map.dart';
import 'unicorn_type_iterable/unicorn_type_iterable_list.dart';

extension UnicornIterableExtension<T> on Iterable<T?>? {
  Iterable<T> get whereNotNull {
    if (this == null) return const Iterable.empty();
    return this!.whereType<T>();
  }
}
