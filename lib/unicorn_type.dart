export 'unicorn_type/unicorn_type_bool.dart';
export 'unicorn_type/unicorn_type_iterable.dart';
export 'unicorn_type/unicorn_type_num.dart';
export 'unicorn_type/unicorn_type_parse.dart';
export 'unicorn_type/unicorn_type_string.dart';


extension UnicornNullableExtension<T> on T?{
  T or(T fallback) => this ?? fallback;
  T? orNull(T fallback) => this ?? fallback;
}

extension UnicornOnNullExtension on Null{
  T or<T>(T fallback) => fallback;
  T? orNull<T>(T fallback) => fallback;
}
