// ignore_for_file: non_constant_identifier_names
part of 'unicorn.dart';


void U$Log(
  String? text,{
    DateTime? timestamp,
    String? name,
    StackTrace? stackTrace,
    Object? error,
}) {
  if (!U$.canDebug) {
    return;
  }
  dev.log(
    '${U$.unicornIcon} ${(timestamp ?? DateTime.now()).toIso8601String()} - $text',
    name: name ?? 'U\$',
    stackTrace: stackTrace,
    error: error,
  );
}
