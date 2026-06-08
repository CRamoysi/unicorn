// ignore_for_file: non_constant_identifier_names

part of 'unicorn.dart';

void U$Text(
  String text,
) {
  if (!U$.canDebug) {
    return;
  }

  final timestamp = DateTime.now().toIso8601String();
  debugPrint('${U$.unicornIcon} $timestamp - $text');
}
