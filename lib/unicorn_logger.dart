// ignore_for_file: non_constant_identifier_names
import 'dart:developer' as dev;

import 'package:unicorn/unicorn_core.dart';

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
